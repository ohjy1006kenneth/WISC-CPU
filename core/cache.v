/* Assume no default net types to avoid issues. */
// none

/**
 *  Cache module which will be used to create Icache and Dcache.
 *
 *  Meta-data block VLTT_TTTT (T = tag, V = valid, L = LRU)
 *
 *  Address breakdown: TTTT_TTSS_SSSS_OOOO (T = tag, S = set, O = offset)
 */
module cache(
    input wire clk,
    input wire rst_n,

    /* Interface with datapath */
    input wire [15:0] data_in,
    input wire [15:0] addr,
    input wire wen, 
    input wire ren,
    output wire [15:0] data_out,
    output wire stall,

    /* Interface with multi-cycle memory */
    input wire [15:0] MEM_din,
    input wire memory_data_valid,
    input wire memory_wdone,
    output wire [15:0] MEM_addr,
    output wire MEM_RE,
    output wire MEM_WE
);

    /**
     *  Declare intermediate signals.
     */
    wire [5:0] tag;     // Tag bits
    wire [5:0] set;     // Set index
    wire [2:0] block;   // Block offset within cache block

    wire [63:0] line_enable;    // 1-hot Set line index across 2 ways
    wire [7:0] word_enable;     // 1-hot word enable within cache block

    wire data0_write;   // Write enable signal for data word in way 0
    wire data1_write;   // Write enable signal for data word in way 1

    wire [15:0] data0_in;  // Data word to be written to way 0
    wire [15:0] data1_in;  // Data word to be written to way 1
    wire [7:0] meta0_in;  // Meta-data byte to be written to way 0
    wire [7:0] meta1_in;  // Meta-data byte to be written to way 1

    wire [15:0] data0_out;  // Data word output for way 0
    wire [15:0] data1_out;  // Data word output for way 1
    wire [7:0] meta0_out;   // Meta-data for way 0
    wire [7:0] meta1_out;   // Meta-data for way 1

    wire hit;   // Whether read/write was a cache hit in general 
    wire hit0;  // Whether read/write was a cache hit in way 0
    wire hit1;  // Whether read/write was a cache hit in way 1

    wire way_target;    // Holds the way we which to write to (0 or 1);

    wire write_data_array;  // write enable to cache data array to signal when filling with memory_data
    wire write_tag_array;   // write enable to cache tag array to signal when all words are filled in to data array
    
    wire fsm_busy;          // Whether cache miss handler FSM is busy 

    /**
     *  Assign the tag bits, set index, and block offset from address input.
     *  Also, assign the valid bit and LRU bit.
     */
    assign tag = addr[15:10];
    assign set = addr[9:4]; // TODO Jared check this
    // We have decreased the size of the cache, therefore tag goes up by one
    // and set down by one
    wire[2:0] write_block;
    assign block = fsm_busy ? write_block : addr[3:1];

    /**
     *  Instantiate 6 to 64 decoder to decode the set bits. This turns the
     *  set bits into an index inside a way.
     */
    Decoder_6_64 SetDecode(
        .in(set),
        .out(line_enable)
    );

    /**
     *  Instantiate 3 to 8 decoder to decode the word offset within a cache
     *  block.
     */
    Decoder_3_8 BlockDecode(
        .in(block),
        .out(word_enable)
    );

    /**
     *  Instantiate data array to hold data blocks for way 0.
     */
    DataArray DArray0(
	    .clk(clk),
	    .rst(~rst_n), 
	    .DataIn(data0_in),
	    .Write(data0_write),
	    .BlockEnable(line_enable), 
	    .WordEnable(word_enable),
	    .DataOut(data0_out)
    );

    /**
     *  Instantiate data array to hold data blocks for way 1.
     */
    DataArray DArray1(
	    .clk(clk),
	    .rst(~rst_n), 
	    .DataIn(data1_in),
	    .Write(data1_write),
	    .BlockEnable(line_enable), 
	    .WordEnable(word_enable),
	    .DataOut(data1_out)
    );

    /**
     *  Construct the data inputs for way 0 and way 1.
     */
    assign data0_in = hit0 ? data_in : MEM_din;
    assign data1_in = hit1 ? data_in : MEM_din;

    /**
     *  Logic for determining when to write a word to data block for each way.
     */
    assign data0_write = ~way_target & (write_data_array | (hit0 & wen));
    assign data1_write = way_target & (write_data_array | (hit1 & wen));
    
    /**
     *  Instantiate meta-data array to hold 64 sets for way 0, containing
     *  tag bits, valid bit, and one bit for LRU replacement.
     */
    MetaDataArray MArray0(
	    .clk(clk),
	    .rst(~rst_n),
	    .DataIn(meta0_in),
	    .Write(write_tag_array),
	    .BlockEnable(line_enable),
	    .DataOut(meta0_out)
    );

    /**
     *  Instantiate meta-data array to hold 64 sets for way 1, containing
     *  tag bits, valid bit, and one bit for LRU replacement.
     */
    MetaDataArray MArray1(
	    .clk(clk),
	    .rst(~rst_n),
	    .DataIn(meta1_in),
	    .Write(write_tag_array),
	    .BlockEnable(line_enable),
	    .DataOut(meta1_out)
    );

    /**
     *  Construct the meta-data byte inputs. If writing of meta-data byte
     *  within a way goes through, valid bit will always be a 1. If the
     *  way target is 1, then way target 0 should write back the same data
     *  except with an updated LRU bit to keep in sync.
     */
    assign meta0_in = way_target ? {meta0_out[7], 1'b0, meta0_out[5:0]} : {1'b1, 1'b1, tag};
    assign meta1_in = ~way_target ? {meta1_out[7], 1'b1, meta1_out[5:0]} : {1'b1, 1'b0, tag};

    /**
     *  Detect if cache hit in either way.
     */
    assign hit0 = (meta0_out[5:0] == tag) & meta0_out[7];
    assign hit1 = (meta1_out[5:0] == tag) & meta1_out[7];
    assign hit = hit0 | hit1;

    /**
     *  Depending on which way the tag matched, return corresponding word
     *  from the correct cache block.
     */
    assign data_out = hit0 ? data0_out : hit1 ? data1_out : 16'h0000;   
    wire fsm_state;
    wire[2:0] curblock;
    /**
     *  State machine for handling reading from and writing to memory.
     */
    cache_fill_FSM CacheController(
        .clk(clk),
        .rst_n(rst_n),
        .miss_detected(~hit & (ren|wen)),
        .miss_address(addr),
        .fsm_busy(fsm_busy),
        .write_data_array(write_data_array),
        .write_tag_array(write_tag_array),
        .memory_address(MEM_addr),
        .memory_data(MEM_din),
        .memory_data_valid(memory_data_valid),
        .state(fsm_state),
        .write_block(write_block),
        .curblock(curblock)
    );

    /**
     *  Stall processor if FSM is busy.
     *
     *  NOTE: May need to check if either ~hit or wen & ~MEM_wdone is needed here too
     */
    assign stall = fsm_busy | (wen & ~memory_wdone);

    /**
     *  Logic to decide which way we are going to write to. First, checks if
     *  we have a cache hit, and if we do have a hit (for a write) we will
     *  write to that way. Otherwise, if one of the ways is not valid yet
     *  (way 0 has priority) then we write to that. Otherwise, we use LRU
     *  bit to decide which block to write to (evicting current block).
     *
     *  Here, only checking LRU bit on first way, but both LRU bits held in
     *  the meta-data array should be the same.
     */
    assign way_target = hit0 ? 1'b0 : hit1 ? 1'b1 : 
                        ~meta0_out[7] ? 1'b0 : ~meta1_out[7] ? 1'b1 :
                        meta0_out[6];

    /**
     *  We need to read from main memory when any cache miss happens.
     */
    // Assert read enable when we are still reading from the cache
    assign MEM_RE = fsm_busy & (curblock != 3'h7);//wtf

    /**
     *  We write to main memory if we are performing write and get cache hit,
     *  either a hit initially or after bringing in the block from memory.
     */
    assign MEM_WE = hit & wen;
    
endmodule

/* Revert default net type after module to be wire. */
// wire

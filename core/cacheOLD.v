// none
/**
 * This module implements a two way set associative cache
 * [F E D C B | A 9 8 7 6 5 4 | 3 2 1 | 0 ]
 * TAG    | S bits (7)    | block offset | byte offset
 *
 * Metadata storage:
 * 7 6 5 4 3 2 1 0
 * valid lru x tag
 */
module cache(
    input wire clk,
    input wire rst_n,

// Interface with datapath
    input wire[15:0] addr,  // Address to read or write to
    input wire[15:0] data_in,
    input wire RE,    // Read enable
    input wire WE,    // Write enable

    output wire[15:0] rdata,// Data read from cache -- DONE!
    output wire stall, // high if we missed it -- DONE!
// Interface to memory
    output wire MEM_RE,
    output wire MEM_WE,
    output wire[15:0] MEM_wdata,
    output wire MEM_addr,
    input wire[15:0] MEM_rdata,
    input wire MEM_rdata_valid,
    input wire MEM_wdone
);
// Transaction process with memory
// READ:
// MEM_RE asserted
// MEM_addr set to to address to read from
// If MEM_rdata_valid, move to next byte
// Repeat until all bytes read
// De assert MEM_RE
// Write into cache
// WRITE (cache hit):
// MEM_WE asserted
// MEM_addr set to the address to write to
// If MEM_wdone, release MEM_WE
// WRITE (cache miss)
// Perform READ and prior WRITE at same time
// Then, write the new data into the cache.

wire[4:0] tag;
wire[6:0] set;
wire[2:0] block;
assign tag = addr[15:11];
assign set = addr[10:4];
assign block = addr[3:1];

wire d1_write;
wire d2_write;
wire[127:0] line_enable;
wire[7:0] word_enable;
// Produce word enable signal from block offset
// Or, If we're writing into the cache from memory via the FSM, through that
ReadDecoder_4_16 r0({1'b0, fsm_busy ? MEMORY_memory_address[3:1] : block}, word_enable);
wire[15:0] d1_out;
wire[15:0] d2_out;
// DATA ARRAYS
DataArray d1(.clk(clk),.rst(~rst_n),.DataIn(data_in),.Write(d1_write),
    .BlockEnable(line_enable),.WordEnable(word_enable),.DataOut(d1_out));
DataArray d2(.clk(clk),.rst(~rst_n),.DataIn(data_in),.Write(d2_write),
    .BlockEnable(line_enable),.WordEnable(word_enable),.DataOut(d2_out));

wire m1_write;
wire m2_write;
wire [7:0] m1_out;
wire [7:0] m2_out;

// METADATA ARRAYS
MetaDataArray m1(
    .clk(clk),
    .rst(~rst_n),
    .DataIn({1'b1, ~m1_out[6], 1'b0, tag}),
    .Write(m1_write),
    .BlockEnable(line_enable),
    .DataOut(m1_out)
);
MetaDataArray m2(
    .clk(clk),
    .rst(~rst_n),
    .DataIn({3'b100, tag}),
    .Write(m2_write),
    .BlockEnable(line_enable),
    .DataOut(m2_out)
);
// Store LRU
wire[127:0] lru_raw;
dff lru_array[127:0](
    .q(lru_raw),
    .d({128{~way_target}}), // Otherwise, if we hit way 1, switch it to 1, else we hit 1 and should be 0
    .wen({128{write_tag_array | (hit1 | hit2 & (RE|WE))}} & line_enable), // Enable this for writes when we hit the cache (happens on a read or write), or when we write the tag in during a miss
    .clk(clk),
    .rst(~rst_n)
);
wire lru;
assign lru = |(lru_raw & line_enable);

// Control signals
// First, select which block we're going to inspect in the cache
// (this is required to determine if we hit the cache)
// To do this, we will use our handy scaled up ReadDecoder_7_128
// that I totally didn't just write
ReadDecoder_7_128 r1(
    .RegId(set),
    .Wordline(line_enable)
);

// Detect hits
wire hit1;
wire hit2;
wire hit;
assign hit1 = m1_out[7] & (m1_out[4:0] == addr[4:0]);
assign hit2 = m2_out[7] & (m2_out[4:0] == addr[4:0]);
assign rdata = hit1 ? d1_out : hit2 ? d2_out : 16'hF00D;

assign hit = hit1 | hit2;
assign stall = ~hit | fsm_busy | WE&~MEM_wdone;//TODO may be able to remove this last condition

// On write, which one do we target?
wire way_target;
assign way_target = hit1 ? 0 : hit2 ? 1 : // If we hit the cache, use that
        ~m1_out[7] ? 0 : ~m2_out[7] ? 1 : // Otherwise use whichever is open
        lru; // Otherwise use the least recently used
// Turn on write enable if way target is 0 and any of
// FSM is trying to fill it
// WE hit on 1 and we're writing
assign d1_write = ~way_target & (write_data_array | (hit1 & WE));

wire fsm_busy;
wire write_data_array;
wire write_tag_array;
wire[15:0] MEMORY_memory_address;
wire[15:0] MEMORY_memory_data;
wire MEMORY_memory_data_valid;
// State machine for handling reading from and writing to memory.
cache_fill_FSM cfm(
    .clk(clk),
    .rst_n(rst_n),
    .miss_detected(~hit),
    .miss_address(addr),
    .fsm_busy(fsm_busy),
    .write_data_array(write_data_array),
    .write_tag_array(write_tag_array),
    .memory_address(MEMORY_memory_address),
    .memory_data(MEMORY_memory_data),
    .memory_data_valid(MEMORY_memory_data_valid)
);

assign MEM_addr = MEMORY_memory_address;
assign MEMORY_memory_data = MEM_rdata;
assign MEMORY_memory_data_valid = MEM_rdata_valid;
assign MEM_RE = RE & fsm_busy;
assign MEM_WE = WE;
endmodule
// wire

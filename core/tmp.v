/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the cache controller to handle cache misses.
 *
 *   -  The data and address ports of the cache and memory are 16 bits wide
 *      each. The cache capacity is 2KB (i.e., 2048B), memory is 64KB 
 *      (i.e., 65536B), and block size is 16 bytes. Memory is byte-addressable.
 *
 *   -  On both read and write misses, you need to bring in the correct block
 *      from memory to the cache.
 *
 *   -  A single data transfer between cache and memory is of an entire cache
 *      block and is thus 16 bytes but the data transfer granularity (i.e.,
 *      width of data ports in cache/memory and wires between them) is only
 *      2-byte words. So you will need to sequentially grab 8 chunks of data
 *      from memory and insert them word-by-word into the cache block.
 *
 *   -  Each 2-byte word of data requires 4 cycles to be read from memory;
 *      i.e., memory access latency is 4 cycles.
 *  
 *   -  The cache is write-through, so there is no data to be written back
 *      from the cache to memory upon eviction (No dirty bit).
 *
 *   -  The cache controller stalls the processor on a miss, and only after
 *      the entire cache block is brought into the cache is the stall signal 
 *      deasserted.
 */
module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array,
                    write_tag_array, memory_address, memory_data, memory_data_valid);

    /**
     *  Define module inputs and outputs.
     */
    input clk, rst_n;               // System clock and active low reset
    input miss_detected;            // active high when tag match logic detects a miss
    input [15:0] miss_address;      // address that missed the cache
    input [15:0] memory_data;       // data returned by memory (after delay)
    input memory_data_valid;        // active high indicates valid data returning on memory bus
    output fsm_busy;                // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    output write_data_array;        // write enable to cache data array to signal when filling with memory_data
    output write_tag_array;         // write enable to cache tag array to signal when all words are filled in to data array
    output [15:0] memory_address;   // address to read from memory

    /**
     *  Define intermediate signals.
     */
    wire curr_state;                // Current state
    wire next_state;                // Next State

    wire [3:0] chunks_rcv;          // # of chunks received from memory
    wire [3:0] next_chunks_rcv;     // Next number of chunks to store as received
    wire [3:0] incr_chunks_rcv;     // Incremented # of chunks received from memory

    wire [15:0] next_mem_addr;      // Next memory addr to access word within block
    wire [15:0] incr_mem_addr;      // Memory address + 2 when requesting new words within block

    wire all_received;              // All 16-bytes making up block in mem have been received
    wire request_blk;               // FSM output to request the correct addr from memory
    wire request_chunk;             // FSM output to request getting 2-byte chunk from mem
    wire incr_chunk_cnt;            // FSM output to increase count of chunks received

    /**
     *  Define states.
     */
    localparam IDLE_STATE = 1'b0;
    localparam WAIT_STATE = 1'b1;

    /**
     *  Instantiate 16-bit adder to calculate next memory address to read from
     *  memory (always even).
     */
    CLA_16bit MemAddrAdder(.Sum(incr_mem_addr), .CarryOut(), .A(memory_address), .B(16'h2), .CarryIn(1'b0));

    /**
     *  Logic to assign the next memory address to read. On initial request
     *  of a block from memory, the next memory address to read from is the
     *  address that was missed, but offset to 0. Then, if a chunk is 
     *  requested, the next memory address to read will be the current memory
     *  address incremented by 2 to get the next word. Otherwise, the memory
     *  address to read should stay the same.
     */
    assign next_mem_addr = (request_blk) ? {miss_address[15:4], 4'h0} : ((request_chunk) ? incr_mem_addr : memory_address);

    /**
     *  Implement register to hold current memory address cache controller is
     *  reading word from. To pull in a block from memory into cache, need to
     *  read from 8 different memory addresses, with the controller starting 
     *  from ...0000 and ending at ...1110 (because memory is byte
     *  addressable, LSB is always 0).
     */
    dff MemAddrReg[15:0] (.q(memory_address), .d(next_mem_addr), .wen(16'hFFFF), .clk({16{clk}}), .rst({16{~rst_n}}));

    /**
     *  Instantiate 4-bit adder to increment the number of chunks that have
     *  been received from memory. P and G outputs are unused here because
     *  CLA_16bit uses those, but they are not needed here for an explicit
     *  4-bit adder implementation of the module.
     */
    CLA_4bit ChunkCntr(.Sum(incr_chunks_rcv), .P(), .G(), .A(chunks_rcv), .B(4'h1), .CarryIn(1'b0));

    /**
     *  Logic to assign the number of chunks received in transaction of
     *  getting a block from memory into cache.
     */
    assign next_chunks_rcv = (incr_chunk_cnt) ? incr_chunks_rcv : ((~fsm_busy) ? 4'h0 : next_chunks_rcv);

    /**
     *  Chunk counter register. Holds the number of chunks that have been
     *  received.
     */
    dff ChunkCntrReg[3:0] (.q(chunks_rcv), .d(next_chunks_rcv), .wen(4'hF), .clk({4{clk}}), .rst({4{~rst_n}}));

    /**
     *  Set the flag that all 8 word chunks have been received if the MSB
     *  of the chunks received vector is set to a 1 (meaning 1000 = 8).
     */
    assign all_received = chunks_rcv[3];

    /**
     *  Implement FSM output logic.
     */
    assign fsm_busy = ((curr_state == IDLE_STATE) & miss_detected) | ((curr_state == WAIT_STATE) & (~all_received));
    assign request_blk = ((curr_state == IDLE_STATE) & miss_detected);
    assign request_chunk = ((curr_state == WAIT_STATE) & memory_data_valid);
    assign incr_chunk_cnt = ((curr_state == WAIT_STATE) & memory_data_valid);
    assign write_data_array = ((curr_state == WAIT_STATE) & memory_data_valid);
    assign write_tag_array = ((curr_state == WAIT_STATE) & all_received);

    /**
     *  Implement next state logic.
     */
    assign next_state = ((curr_state == IDLE_STATE) & miss_detected) | ((curr_state == WAIT_STATE) & ~all_received);

    /**
     *  Implement state register.
     */
    dff StateReg(.q(curr_state), .d(next_state), .wen(1'b1), .clk(clk), .rst(~rst_n));

endmodule

/* Revert default net type after module to be wire. */
// wire
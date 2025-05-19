/**
 *
 * Memory -- single cycle version
 *
 * written for CS/ECE 552, Spring '07
 * Pratap Ramamurthy, 19 Mar 2006
 *
 * Modified for CS/ECE 552, Spring '18
 * Gokul Ravi, 08 Mar 2018
 *
 * This is a byte-addressable,
 * 16-bit wide memory
 * Note: The last bit of the address has to be 0.
 *
 * All reads happen combinationally with zero delay.
 * All writes occur on rising clock edge.
 * Concurrent read and write not allowed.
 *
 * On reset, memory loads from file "loadfile_all.img".
 * (You may change the name of the file in
 * the $readmemh statement below.)
 * File format:
 *     @0
 *     <hex data 0>
 *     <hex data 1>
 *     ...etc
 */
module memory1c (data_out, data_in, addr, enable, wr, clk, rst);

    /**
     *  Define address width parameter.
     */
    parameter ADDR_WIDTH = 16;

    /**
     *  Define module inputs and outputs.
     */
    input [15:0] data_in;           // Input data to be written to memory
    input [ADDR_WIDTH-1 :0] addr;   // Address to write data to in memory
    input enable;                   // Memory enable, without it data_out = 0
    input wr;                       // Write enable signal, 1 = write, 0 = read
    input clk;                      // Clock signal
    input rst;                      // Reset signal
    output wire [15:0] data_out;    // Data read out

    /**
     *  Intermediate registers.
     */
    reg [15:0] mem [0:2**ADDR_WIDTH-1]; // Memory array holding data
    reg loaded;                         // 1 if file loaded, 0 otherwise  

    /**
     *  Data out is M[addr] with LSB removed if doing read operation (en = 1
     *  and wr = 0). Otherwise, data out is 0.
     */
    assign data_out = (enable & (~wr)) ? {mem[addr[ADDR_WIDTH-1 :1]]} : 0;

    /**
     *  Initialize flag to signal that file has not been loaded at start.
     */
    initial begin
        loaded = 0;
    end

    /**
     *  Controls logic at posedge of clock. Either in reset and loading dat
     *  from files, or not in reset and write signal is asserted.
     */
    always @(posedge clk) begin

        /**
         *  If reset is asserted at posedge of clock, load data from 
         *  file into memory.
         */
        if (rst) begin

            /**
             *  If file hasn't been loaded, load into memory array and set
             * flag to 1. 
             */
            if (!loaded) begin
                // $readmemh("loadfile_all.img", mem);
                $readmemh("simple.img", mem);
                loaded = 1;
            end            
        end else begin
            
            /**
             *  If en and wr are both high, write data input into memory array.
             */
            if (enable & wr) begin
                mem[addr[ADDR_WIDTH-1 :1]] = data_in[15:0];
            end
        end
    end
    
endmodule 

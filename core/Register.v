/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is a register. Each register is made of 16 bit-cells for storage
 *  of a 16-bit number. There are 16 registers for the register file. Each
 *  register can be read and written.
 */
module Register(clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1, Bitline2);

    /**
     *  Define module inputs and outputs.
     */
    input clk;                          // global clock
    input rst;                          // Active high rest
    input [15:0] D;                     // Bit to be written
    input WriteReg;                     // Write register enable signal
    input ReadEnable1, ReadEnable2;     // Read data enables
    inout [15:0] Bitline1, Bitline2;    // Source data bit lines (can be Z)

    /**
     *  Instantiate 16 bit-cells.
     */
    BitCell BitCells[15:0] (.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteReg),
                            .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), 
                            .Bitline1(Bitline1), .Bitline2(Bitline2));

endmodule

/* Revert default net type after module to be wire. */
// wire
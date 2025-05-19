/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is a bit cell, which consists of a storage component (DFF) and
 *  tri-state buffers. There are 16 bit-cells per register, storing one bit
 *  for each bit cell.
 */
module BitCell(clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2, Bitline1, Bitline2);

    /**
     *  Define module inputs and outputs.
     */
    input wire clk;                          // global clock
    input wire rst;                          // Active high rest
    input wire D;                            // Bit to be written
    input wire WriteEnable;                  // Write enable signal
    input wire ReadEnable1, ReadEnable2;     // Read data enables
    inout wire Bitline1, Bitline2;           // Source data bit lines (can be Z)

    /**
     *  Intermediate DFF output. Drives either bitline1 or bitline2.
     */
    wire Q;

    /**
     *  Instantiate DFF for storing bit.
     */
    dff DFF (.q(Q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

    /**
     *  Tri state logic for deciding what SrcData line is read.
     */
    assign Bitline1 = ReadEnable1 ? Q : 1'bZ;
    assign Bitline2 = ReadEnable2 ? Q : 1'bZ;

endmodule

/* Revert default net type after module to be wire. */
// wire
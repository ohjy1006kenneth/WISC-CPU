/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the PC register. It hold the 16-bit program counter.
 */
module PC(clk, rst, NewPC, CurrPC);

    /**
     *  Define module inputs and outputs.
     */
    input clk;                  // global clock
    input rst;                  // Active high rest
    input [15:0] NewPC;         // New program counter to get written
    output [15:0] CurrPC;       // Current program counter

    /**
     *  Instantiate 16 DFFs to store the program counter. Write enable is
     *  always active. Q output is current PC and data in is the new PC.
     */
    dff PCReg[15:0] (.q(CurrPC), .d(NewPC), .wen(16'hFFFF), .clk({16{clk}}), .rst({16{rst}}));

endmodule

/* Revert default net type after module to be wire. */
// wire

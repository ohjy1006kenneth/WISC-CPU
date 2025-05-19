/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the MEM/WB pipeline register.
 */
module MEM_WB(
    input wire clk,
    input wire rst,
    input wire [15:0] MEM_ALUOut,
    input wire [15:0] MEM_MemData,
    input wire [3:0] MEM_RegDst,
    input wire MEM_RegWrite,
    input wire MEM_MemToReg,
    input wire MEM_HLT,
    input wire WEN, // for DMEM_STALL

    output wire [15:0] WB_ALUOut,
    output wire [15:0] WB_MemData,
    output wire [3:0] WB_RegDst,
    output wire WB_RegWrite,
    output wire WB_HLT,
    output wire WB_MemToReg
);

    /**
     *  Store ALUOut:   ALU result that could be written to register file.
     */
    dff ALUOutReg[15:0] (.q(WB_ALUOut), .d(MEM_ALUOut), .wen(16'hFFFF), .clk({16{clk}}), .rst({16{rst}}));

    /**
     *  Store MemData:  Output data from memory stage.
     */
    dff MemDataReg[15:0] (.q(WB_MemData), .d(MEM_MemData), .wen(16'hFFFF), .clk({16{clk}}), .rst({16{rst}}));

    /**
     *  Store RegDst:   Used in write back stage for register file destination.
     */
    dff RegDstReg[3:0] (.q(WB_RegDst), .d(MEM_RegDst), .wen(4'hF), .clk({4{clk}}), .rst({4{rst}}));

    /**
     *  Store RegWrite: Write enable signal used during write back stage.
     */
    dff RegWriteReg (.q(WB_RegWrite), .d(MEM_RegWrite), .wen(1'b1), .clk(clk), .rst(rst|~WEN));

    /**
     *  Store MemToReg: Used to select which data is written to register file
     *                  in the write back stage.
     */
    dff MemToRegReg (.q(WB_MemToReg), .d(MEM_MemToReg), .wen(1'b1), .clk(clk), .rst(rst));
    
    dff halt(.q(WB_HLT), .d(MEM_HLT), .wen(1'b1), .clk(clk), .rst(rst));

endmodule

/* Revert default net type after module to be wire. */
// wire

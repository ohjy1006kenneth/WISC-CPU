/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the IF/ID pipeline register.
 */
module IF_ID(
    input wire clk,
    input wire rst,
    input wire [15:0] IF_PCPlus2,
    input wire [15:0] IF_Instruction,
    input wire [15:0] IF_PC,
    input wire IF_PredictedTaken,

    output wire [15:0] ID_PCPlus2,
    output wire [15:0] ID_Instruction,
    output wire [15:0] ID_PC,
    output wire ID_PredictedTaken
);

    /**
     *  Store PCPlus2:  Used as an operand to ALU in EX stage. 
     */
    dff PCPlus2Reg[15:0] (.q(ID_PCPlus2), .d(IF_PCPlus2), .wen(16'hFFFF), .clk({16{clk}}), .rst({16{rst}}));

    /**
     *  Store Instruction:  Instruction is decoded in the ID stage.
     */
    dff InstructionReg[15:0] (.q(ID_Instruction), .d(IF_Instruction), .wen(16'hFFFF), .clk({16{clk}}), .rst({16{rst}}));
    dff PCReg[15:0] (.q(ID_PC), .d(IF_PC), .wen(16'hFFFF), .clk({16{clk}}), .rst({16{rst}}));
    dff PredictionReg (.q(ID_PredictedTaken), .d(IF_PredictedTaken), .wen(1'b1), .clk(clk), .rst(rst));

endmodule

/* Revert default net type after module to be wire. */
// wire

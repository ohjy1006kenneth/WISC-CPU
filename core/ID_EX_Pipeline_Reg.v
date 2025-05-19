/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the ID/EX pipeline register.
 */
module ID_EX(
    input wire clk,
    input wire rst,
    input wire [15:0] ID_PCPlus2,
    input wire [15:0] ID_SrcData1,
    input wire [15:0] ID_SrcData2,
    input wire [15:0] ID_ImmOperand,
    input wire [3:0] ID_SrcReg1,
    input wire [3:0] ID_SrcReg2,
    input wire [3:0] ID_RegDst,
    input wire [3:0] ID_Opcode,
    input wire ID_RegWrite,
    input wire ID_ALUSrcSel1,
    input wire ID_ALUSrcSel2,
    input wire ID_StoreInstr,
    input wire ID_MemToReg,
    input wire WEN, // Write enable signal, enables when not stalled

    output wire [15:0] EX_PCPlus2,
    output wire [15:0] EX_SrcData1,
    output wire [15:0] EX_SrcData2,
    output wire [15:0] EX_ImmOperand,
    output wire [3:0] EX_SrcReg1,
    output wire [3:0] EX_SrcReg2,
    output wire [3:0] EX_RegDst,
    output wire [3:0] EX_Opcode,
    output wire EX_RegWrite,
    output wire EX_ALUSrcSel1,
    output wire EX_ALUSrcSel2,
    output wire EX_StoreInstr,
    output wire EX_MemToReg
);

    /**
     *  Store PCPlus2:  Used as an operand to ALU in EX stage. 
     */
    dff PCPlus2Reg[15:0] (.q(EX_PCPlus2), .d(ID_PCPlus2), .wen({16{WEN}}), .clk({16{clk}}), .rst({16{rst}}));

    /**
     *  Store SrcData1: Used in EX stage in ALU.
     */
    dff SrcData1Reg[15:0] (.q(EX_SrcData1), .d(ID_SrcData1), .wen({16{WEN}}), .clk({16{clk}}), .rst({16{rst}}));

    /**
     *  Store SrcData2: Used in EX stage in ALU.
     */
    dff SrcData2Reg[15:0] (.q(EX_SrcData2), .d(ID_SrcData2), .wen({16{WEN}}), .clk({16{clk}}), .rst({16{rst}}));

    /**
     *  Store ImmOperand:   Immediate operand to be used in EX stage in ALU.
     */
    dff ImmOperandReg[15:0] (.q(EX_ImmOperand), .d(ID_ImmOperand), .wen({16{WEN}}), .clk({16{clk}}), .rst({16{rst}}));

    /**
     *  Store SrcReg1:  Used for forwarding logic in EX.
     */
    dff SrcReg1Reg[3:0] (.q(EX_SrcReg1), .d(ID_SrcReg1), .wen({4{WEN}}), .clk({4{clk}}), .rst({4{rst}}));

    /**
     *  Store SrcReg2:  Used for forwarding logic in EX.
     */
    dff SrcReg2Reg[3:0] (.q(EX_SrcReg2), .d(ID_SrcReg2), .wen({4{WEN}}), .clk({4{clk}}), .rst({4{rst}}));

    /**
     *  Store RegDst:   Used in write back stage for register file destination
     *                  and forwarding logic in EX stage.
     */
    dff RegDstReg[3:0] (.q(EX_RegDst), .d(ID_RegDst), .wen({4{WEN}}), .clk({4{clk}}), .rst({4{rst}}));

    /**
     *  Store Opcode:   Used to determine operation in ALU in EX stage.
     */
    dff OpcodeReg[3:0] (.q(EX_Opcode), .d(ID_Opcode), .wen({4{WEN}}), .clk({4{clk}}), .rst({4{rst}}));

    /**
     *  Store RegWrite: Write enable signal used during write back stage.
     */
    dff RegWriteReg (.q(EX_RegWrite), .d(ID_RegWrite), .wen(WEN), .clk(clk), .rst(rst));

    /**
     *  Store ALUSrcSel1:   Used to pick ALU first operand, either PCPlus2
     *                      or SrcData1 in the EX stage.
     */
    dff ALUSrcSel1Reg (.q(EX_ALUSrcSel1), .d(ID_ALUSrcSel1), .wen(WEN), .clk(clk), .rst(rst));

    /**
     *  Store ALUSrcSel2:   Used to pick ALU second operand, either immediate
     *                      or SrcData2 in the EX stage.
     */
    dff ALUSrcSel2Reg (.q(EX_ALUSrcSel2), .d(ID_ALUSrcSel2), .wen(WEN), .clk(clk), .rst(rst));

    /**
     *  Store StoreInstr:   Data memory read-write signal used in memory
     *                      stage.
     */
    dff StoreInstrReg (.q(EX_StoreInstr), .d(ID_StoreInstr), .wen(WEN), .clk(clk), .rst(rst));

    /**
     *  Store MemToReg: Used to select which data is written to register file
     *                  in the write back stage.
     */
    dff MemToRegReg (.q(EX_MemToReg), .d(ID_MemToReg), .wen(WEN), .clk(clk), .rst(rst));

endmodule

/* Revert default net type after module to be wire. */
// wire

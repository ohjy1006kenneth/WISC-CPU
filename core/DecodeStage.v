/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the ID stage of the processor.
 */
module DecodeStage (
    input wire clk, rst_n,

    input wire [15:0] InstructionD,
    input wire [15:0] PCPlus2D,
    input wire PredictedTaken,

    input wire [3:0] RegDstEX,
    input wire [15:0] ALUResEX,
    input wire RegWriteEX,
    input wire [3:0] OpcodeEX,
    input wire [2:0] NewFlags,
    input wire MemToRegEX,

    input wire [3:0] DstRegWB,
    input wire [15:0] DstDataWB,
    input wire WriteRegWB,

    output wire BranchD,
    output wire [15:0] BranchAddr,
    output wire Stall,


    output wire [3:0] SrcReg1,
    output wire [3:0] SrcReg2,
    output wire [15:0] SrcData1,
    output wire [15:0] SrcData2,
    output wire [3:0] RegDstD,
    output wire [15:0] ImmOperand,
    output wire RegWrite,
    output wire ALUSrcSel1,
    output wire ALUSrcSel2,
    output wire StoreInstr,
    output wire MemToReg,
    output wire [3:0] OpcodeD
);

    /**
     *  Define intermediate signals.
     */
    wire RegWrite_raw;
    wire MemToReg_raw;
    wire StoreInstr_raw;
    wire SrcRegSel1, SrcRegSel2;
    wire [2:0] FlagsRaw;
    wire [15:0] SrcData1_rf;
    wire BranchTmp;
    wire [15:0] Sum;                // Sum of PCPlus2 and Immoperand
    wire carryout_discard;

    /**
     *  Define stall state signals.
     */
    wire StallCondition1;
    wire StallCondition2;
    wire stallstate;
    
    /**
     *  Instantiate instruction decoder.
     */
    InstrDecoder decoder(
        .Instr(InstructionD),
        .ImmOperand(ImmOperand),
        .RegWrite(RegWrite_raw),
        .ALUSrcSel1(ALUSrcSel1),
        .ALUSrcSel2(ALUSrcSel2),
        .StoreInstr(StoreInstr_raw),
        .MemToReg(MemToReg_raw),
        .SrcRegSel1(SrcRegSel1),
        .SrcRegSel2(SrcRegSel2)
    );

    /**
     *  Mux logic to define source registers to RF.
     */
    assign SrcReg1 = SrcRegSel1 ? InstructionD[11:8] : InstructionD[7:4];
    assign SrcReg2 = StoreInstr_raw ? InstructionD[11:8] : (SrcRegSel2 ? 4'b0000 : InstructionD[3:0]);

    /**
     *  Instantiate register file, now with internal bypassing capabilities.
     */
    RegisterFile rf (
        .clk(clk),
        .rst(~rst_n),
        .SrcReg1(SrcReg1),
        .SrcReg2(SrcReg2),
        .DstReg(DstRegWB),
        .WriteReg(WriteRegWB),
        .DstData(DstDataWB),
        .SrcData1(SrcData1_rf),
        .SrcData2(SrcData2)
    );

    /**
     *  It's important to have this to avoid a possible stall situation where 
     *  the branch address is calculated and then immediately used.
     *  
     *  To do this, we check to ensure that:
     *  - ID/EX.RegDst != 0         -- if it's the zero register, disable forwarding
     *  - ID/EX.RegDst == SRCReg1   -- Only forward if we're supposed to write to the 
     *                                 same register that we just read
     *  - ID/EX.RegWrite            -- Only forward if that instruction actually writes a register.
     *
     *  Do note that this does not take into account a load instruction that will resolve later. 
     *  This may falsely replace it, but if such a load is detected (with ID/EX.RegDst == SrcReg1) 
     *  the decode stage needs to stall anyway cause that ain't coming for another two cycles.
     */
    assign SrcData1 = (RegDstEX != 4'b0000 && RegDstEX == SrcReg1 && RegWriteEX) ? ALUResEX : SrcData1_rf;

    /**
     *  Instantiate flag register with internal bypassing.
     */
    flags flags_reg (
        .clk(clk),
        .rst(~rst_n),
        .Opcode(OpcodeEX),
        .NewFlags(NewFlags),
        .Flags(FlagsRaw)
    );

    /**
     *  Instantiate branch logic unit with latest flags.
     */
    Branch branch_unit (
        .instruction(InstructionD),
        .flags_stored(FlagsRaw),
        .branch(BranchTmp)
    );

    /**
     *  Determine if branch is to be taken or not.
     */
    assign BranchD = (BranchTmp!=PredictedTaken) & ~Stall;

    /**
     *  Calculate branch address adding immediate to PC + 2.
     */
    CLA_16bit adder_inst (
        .A(PCPlus2D),
        .B(ImmOperand),
        .CarryIn(1'b0),
        .CarryOut(carryout_discard),
        .Sum(Sum)
    );

    /**
     *  Determine branch address whether taken or not.
     */
    assign BranchAddr = PredictedTaken ? PCPlus2D : InstructionD[12] ? SrcData1 : Sum;

    /**
     *  Assign control signals to 0 if stalling, else stay same.
     */
    assign RegWrite    = Stall ? 1'b0 : RegWrite_raw;
    assign MemToReg    = Stall ? 1'b0 : MemToReg_raw;
    assign StoreInstr  = Stall ? 1'b0 : StoreInstr_raw;

    /**
     *  Assign register destination and opcode accordingly if stalling, else
     *  these remain unchanged.
     */
    assign RegDstD     = Stall ? 4'b0000 : InstructionD[11:8];
    assign OpcodeD     = Stall ? 4'hA : InstructionD[15:12];

    /**
     *  Assign stall condition 1 to stall once if:
     *  - There is a load currently going through EX (MemToRegEX == 1)
     *  - The load doesn't discard the result (RegDstEX != 0)
     *  - Check register dependencies
     *  - Stall if EX stage uses source register 1
     *  - Stall if EX stage uses source register 2
     *
     *  TODO get rid of RegDst here... In the decode stage just force any
     *  instruction that "writes" to register 0 to have regwrite deasserted too
     */
    assign StallCondition1 = MemToRegEX && (RegDstEX != 0) && (
        RegDstEX == SrcReg1 && (~InstructionD[15]|~InstructionD[14]) |
        RegDstEX == SrcReg2 && ~InstructionD[15]
    );

    /**
     *  Assign stall condition 2 to be stall twice if:
     *  - The previous instruction was a load (MemToRegEX == 1)
     *  - Not to register 0 (RegDstEX != 0)
     *  - To the same register we want to read now (RegDstEx == SrcReg1)
     *  - In decode for branch (InstructionD == 4'hD)
     */
    assign StallCondition2 = MemToRegEX && (RegDstEX != 0) && RegDstEX == SrcReg1 &&
                            InstructionD[15:12]==4'hD && BranchTmp;

    /**
     *  Hold the stall state condition.
     */
    dff stateflop(
        .d(~stallstate & StallCondition2),
        .q(stallstate),
        .clk(clk),
        .rst(~rst_n),
        .wen(1'b1)
    );

    /**
     *  Determine if we are stalling or not based on internal stall state.
     */
    assign Stall = StallCondition2 | StallCondition1 | stallstate;

endmodule

/* Revert default net type after module to be wire. */
// wire

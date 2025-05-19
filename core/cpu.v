//////////////////////////////////////////////////
// Phase 3 CPU design
// Five stage pipeline version
//
// none

/**
 *  Top-level module for the processor.
 */
module cpu (clk, rst_n, hlt, pc);

    // STYLE RULES: SIGNALS DECLARED RIGHT ABOVE THE UNIT THAT CREATES THEM
    // DIVIDE UP INTO STAGES AND PIPELINE REGISTERS

    /**
     *  Define module inputs and outputs.
     */
    input wire clk;             // System clock
    input wire rst_n;           // Active low reset, 0 resets machine, executing starts at 0x0000
    output wire hlt;            // 1 once proc finished processing instr before halt instr
    output wire[15:0] pc;         // Program counter

    /**
     *  These live in the fetch stage - pull them out.
     */
    wire MEM_HLT;
    wire WB_HLT;
    assign hlt = MEM_HLT && WB_HLT;

    /**
     *  Cache stall signals.
     */
    wire DMEM_STALL;

    wire[15:0] ID_PC;
    wire[15:0] IF_PC;
    assign pc = IF_PC;
    wire IF_PredictedTaken;
    wire ID_PredictedTaken;

    /**
     *  Signals for interface between memory arbiter and multi-cycle memory
     *  and caches.
     */
    wire [15:0] MEM4_dout;
    wire [15:0] MEM4_din;
    wire MEM4_EN;
    wire MEM4_WR;
    wire MEM4_data_valid;
    wire [15:0] MEM4_addr;
    wire DMEM_RE;
    wire DMEM_WE;
    wire [15:0] DMEM_MEM_addr;
    wire DMEM_rdata_valid;
    wire IMEM_RE;
    wire [15:0] IMEM_MEM_addr;
    wire IMEM_rdata_valid;
    wire DMEM_WDONE;

    /**
     *  IF stage signal definitions.
     */
    wire[15:0] IF_Instruction;  // Instruction fetched this cycle.
    wire[15:0] IF_PCPlus2;      // Already incremented PC
    

    /**
     *  ID stage signal definitions.
     */
    wire ID_Branch;                 // Back to fetch stage
    wire [15:0] ID_BranchAddress;   // Back to fetch stage
    wire STALL;                     // Back to fetch stage
    wire [3:0] ID_SrcReg1;
    wire [3:0] ID_SrcReg2;
    wire [15:0] ID_SrcData1;
    wire [15:0] ID_SrcData2;
    wire [3:0] ID_RegDst;
    wire [15:0] ID_ImmOperand;
    wire ID_RegWrite;
    wire ID_ALUSrcSel1;
    wire ID_ALUSrcSel2;
    wire ID_StoreInstr;
    wire ID_MemToReg;
    wire [3:0] ID_Opcode;
    wire [15:0] ID_PCPlus2;
    wire [15:0] ID_Instruction;     // Note: goes back to fetch stage

    /**
     *  EX stage signal definitions.
     */
    wire [15:0] EX_PCPlus2;
    wire [15:0] EX_SrcData1;
    wire [15:0] EX_SrcData2;
    wire [15:0] EX_ImmOperand;
    wire [15:0] EX_ALUOut;
    wire [15:0] EX_FwdData2;
    wire [3:0] EX_SrcReg1;    
    wire [3:0] EX_SrcReg2;
    wire [3:0] EX_RegDst;
    wire [3:0] EX_Opcode;
    wire [2:0] EX_NewFlags;
    wire EX_RegWrite;
    wire EX_StoreInstr;
    wire EX_MemToReg;
    wire EX_ALUSrcSel1;
    wire EX_ALUSrcSel2;

    /**
     *  MEM stage signal definitions.
     */
    wire [15:0] MEM_MemData;
    wire [15:0] MEM_SrcData2;
    wire [15:0] MEM_ALUOut;
    wire [15:0] MEM_FwdData2;
    wire [3:0] MEM_SrcReg2;
    wire [3:0] MEM_RegDst;
    wire MEM_RegWrite;
    wire MEM_StoreInstr;
    wire MEM_MemToReg;

    /**
     *  WB stage signal definitions.
     */
    wire [15:0] WB_DstData;
    wire [15:0] WB_ALUOut;
    wire [15:0] WB_MemData;
    wire [3:0] WB_RegDst;
    wire WB_RegWrite;
    wire WB_MemToReg;

    /**
     *  Instantiate memory arbiter.
     */
    MemoryArbiter ma(
        .clk(clk), 
        .rst_n(rst_n), 
        .MEM_EN(MEM4_EN), 
        .WR(MEM4_WR), 
        .addr(MEM4_addr), 
        .DMEM_RE(DMEM_RE), 
        .DMEM_WE(DMEM_WE), 
        .IMEM_RE(IMEM_RE), 
        .IMEM_MEM_addr(IMEM_MEM_addr), 
        .DMEM_MEM_addr(DMEM_MEM_addr), 
        .IMEM_rdata_valid(IMEM_rdata_valid), 
        .DMEM_rdata_valid(DMEM_rdata_valid), 
        .IMEM_wdone(),  // not needed?
        .DMEM_wdone(DMEM_WDONE),  // not needed?
        .data_valid(MEM4_data_valid)
    );

    /**
     *  Instantiate multi-cycle memory for instruction and data.
     */
    memory4c MultiCycleMem(
        .data_out(MEM4_dout),
        .data_in(MEM4_din),
        .addr(MEM4_addr),
        .enable(MEM4_EN),
        .wr(MEM4_WR),
        .clk(clk),
        .rst(~rst_n),
        .data_valid(MEM4_data_valid)
    );

    /************************************** START IF STAGE **************************************/
    /**
     *  Instantiate fetch stage.
     */
    Fetch fetchstage(
        .clk(clk),
        .rst_n(rst_n),

        .Mispredict(ID_Branch),
        .BranchAddress(ID_BranchAddress),
        .MispredictPC(ID_PC),
        .Stall(STALL),
        .DMEM_STALL(DMEM_STALL),
        .InstructionD(ID_Instruction),
        .PCPlus2D(ID_PCPlus2),

        .PCPlus2(IF_PCPlus2),
        .Instruction(IF_Instruction),
        .PCOut(IF_PC),
        .PredictedTaken(IF_PredictedTaken),

        .IMEM_RE(IMEM_RE),
        .IMEM_MEM_addr(IMEM_MEM_addr),
        .IMEM_rdata_valid(IMEM_rdata_valid),
        .IMEM_MEM_dout(MEM4_dout)
    );
    
    /*************************************** END IF STAGE ***************************************/

    /**
     *  Instantiate IF/ID pipeline register.
     */
    IF_ID IF_ID_Reg(
        .clk(clk),
        .rst(~rst_n),
        .IF_Instruction(IF_Instruction),
        .ID_Instruction(ID_Instruction),
        .IF_PCPlus2(IF_PCPlus2),
        .ID_PCPlus2(ID_PCPlus2),
        .IF_PC(IF_PC),
        .ID_PC(ID_PC),
        .IF_PredictedTaken(IF_PredictedTaken),
        .ID_PredictedTaken(ID_PredictedTaken)
    );

    /************************************** START ID STAGE **************************************/

    

    /**
     *  Instantiate decode stage.
     */
    DecodeStage decodestage(
        .clk(clk),
        .rst_n(rst_n), // global signals

        .InstructionD(ID_Instruction), // Inputs from pipeline reg
        .PCPlus2D(ID_PCPlus2),

        .RegDstEX(EX_RegDst),  // FW from EX
        .ALUResEX(EX_ALUOut),
        .RegWriteEX(EX_RegWrite),
        .OpcodeEX(EX_Opcode),
        .NewFlags(EX_NewFlags),
        .MemToRegEX(EX_MemToReg),

        .DstRegWB(WB_RegDst),  // Write back to register file
        .DstDataWB(WB_DstData),
        .WriteRegWB(WB_RegWrite),

        .BranchD(ID_Branch),     // Outputs back to fetch
        .BranchAddr(ID_BranchAddress),
        .Stall(STALL),

        .SrcReg1(ID_SrcReg1),
        .SrcReg2(ID_SrcReg2),
        .SrcData1(ID_SrcData1), // Outputs into ID/EX
        .SrcData2(ID_SrcData2),
        .RegDstD(ID_RegDst),
        .ImmOperand(ID_ImmOperand),
        .RegWrite(ID_RegWrite),
        .ALUSrcSel1(ID_ALUSrcSel1),
        .ALUSrcSel2(ID_ALUSrcSel2),
        .StoreInstr(ID_StoreInstr),
        .MemToReg(ID_MemToReg),
        .OpcodeD(ID_Opcode),

        .PredictedTaken(ID_PredictedTaken)
    );

    /*************************************** END ID STAGE ***************************************/

    /**
     *  Instantiate ID/EX pipeline register.
     */
    ID_EX ID_EX_Reg(
        .clk(clk),
        .rst(~rst_n),

        .ID_PCPlus2(ID_PCPlus2),
        .ID_SrcData1(ID_SrcData1),
        .ID_SrcData2(ID_SrcData2),
        .ID_ImmOperand(ID_ImmOperand),
        .ID_SrcReg1(ID_SrcReg1),
        .ID_SrcReg2(ID_SrcReg2),
        .ID_RegDst(ID_RegDst),
        .ID_Opcode(ID_Opcode),
        .ID_RegWrite(ID_RegWrite),
        .ID_ALUSrcSel1(ID_ALUSrcSel1),
        .ID_ALUSrcSel2(ID_ALUSrcSel2),
        .ID_StoreInstr(ID_StoreInstr),
        .ID_MemToReg(ID_MemToReg),
        .WEN(~DMEM_STALL),

        .EX_PCPlus2(EX_PCPlus2),
        .EX_SrcData1(EX_SrcData1),
        .EX_SrcData2(EX_SrcData2),
        .EX_ImmOperand(EX_ImmOperand),
        .EX_SrcReg1(EX_SrcReg1),
        .EX_SrcReg2(EX_SrcReg2),
        .EX_RegDst(EX_RegDst),
        .EX_Opcode(EX_Opcode),
        .EX_RegWrite(EX_RegWrite),
        .EX_ALUSrcSel1(EX_ALUSrcSel1),
        .EX_ALUSrcSel2(EX_ALUSrcSel2),
        .EX_StoreInstr(EX_StoreInstr),
        .EX_MemToReg(EX_MemToReg)
    );
    
    /************************************** START EX STAGE **************************************/

    

    /**
     *  Instantiate execute stage.
     */
    ExecuteStage EX_Stage(
        .Opcode(EX_Opcode),
        .SrcData1(EX_SrcData1),
        .SrcData2(EX_SrcData2),
        .ImmOperand(EX_ImmOperand),
        .PCPlus2(EX_PCPlus2),
        .SrcReg1(EX_SrcReg1),
        .SrcReg2(EX_SrcReg2),
        .EX_MEM_DstData(MEM_ALUOut),
        .MEM_WB_DstData(WB_DstData),
        .EX_MEM_RegDst(MEM_RegDst),
        .MEM_WB_RegDst(WB_RegDst),
        .EX_MEM_RegWrite(MEM_RegWrite),
        .MEM_WB_RegWrite(WB_RegWrite),
        .EX_MEM_MemToReg(MEM_MemToReg),
        .ALUSrcSel1(EX_ALUSrcSel1),
        .ALUSrcSel2(EX_ALUSrcSel2),

        .ALUOut(EX_ALUOut),
        .FwdData2(EX_FwdData2),
        .NewFlags(EX_NewFlags)
    );
    
    /*************************************** END EX STAGE ***************************************/ 

    /**
     *  Instantiate EX/MEM pipeline register.
     */
    EX_MEM EX_MEM_Reg(
        .clk(clk),
        .rst(~rst_n),                       .DMEM_STALL(DMEM_STALL),
        .EX_SrcReg2(EX_SrcReg2),            .MEM_SrcReg2(MEM_SrcReg2),
        .EX_ALUOut(EX_ALUOut),              .MEM_ALUOut(MEM_ALUOut),
        .EX_FwdData2(EX_FwdData2),          .MEM_FwdData2(MEM_FwdData2),
        .EX_RegDst(EX_RegDst),              .MEM_RegDst(MEM_RegDst),
        .EX_RegWrite(EX_RegWrite),          .MEM_RegWrite(MEM_RegWrite),
        .EX_StoreInstr(EX_StoreInstr),      .MEM_StoreInstr(MEM_StoreInstr),
        .EX_MemToReg(EX_MemToReg),          .MEM_MemToReg(MEM_MemToReg),
        .EX_Opcode(EX_Opcode),              .MEM_HLT(MEM_HLT)
    );
    
    /************************************** START MEM STAGE **************************************/

    

    /**
     *  Instantiate memory stage
     */
    MemoryStage memoryStage(
        .clk(clk),
        .rst_n(rst_n),

        .WB_MemData(WB_MemData),
        .WB_RegDst(WB_RegDst),
        .WB_MemToReg(WB_MemToReg),

        .MEM_ALUOut(MEM_ALUOut),
        .MEM_SrcReg2(MEM_SrcReg2),
        .MEM_WMData(MEM_FwdData2),
        .MEM_RegDst(MEM_RegDst),
        .MEM_StoreInstr(MEM_StoreInstr),
        .MEM_MemToReg(MEM_MemToReg),
        .MEM_MemData(MEM_MemData),

        .DMEM_RE(DMEM_RE),
        .DMEM_WE(DMEM_WE),
        .DMEM_MEM_addr(DMEM_MEM_addr),
        .DMEM_rdata_valid(DMEM_rdata_valid),
        .MEM4_dout(MEM4_dout),
        .MEM4_din(MEM4_din),
        .DMEM_WDONE(DMEM_WDONE),
        .DMEM_STALL(DMEM_STALL)
    );

    /*************************************** END MEM STAGE ***************************************/ 

    /**
     *  Instantiate MEM/WB pipeline register.
     */
    MEM_WB MEM_WB_Reg(
        .clk(clk),
        .rst(~rst_n),
        .MEM_ALUOut(MEM_ALUOut),
        .MEM_MemData(MEM_MemData),
        .MEM_RegDst(MEM_RegDst),
        .MEM_RegWrite(MEM_RegWrite),
        .MEM_MemToReg(MEM_MemToReg),
        .WEN(~DMEM_STALL),
        .WB_ALUOut(WB_ALUOut),
        .WB_MemData(WB_MemData),
        .WB_RegDst(WB_RegDst),
        .WB_RegWrite(WB_RegWrite),
        .WB_MemToReg(WB_MemToReg),
        .MEM_HLT(MEM_HLT),
        .WB_HLT(WB_HLT)
    );

    /************************************** START WB STAGE **************************************/

    

    /**
     *  Instantiate write back stage.
     */
    WriteBack writeback(
        .WB_ALURes(WB_ALUOut),
        .WB_MemData(WB_MemData),
        .WB_MemToReg(WB_MemToReg),
        .WB_DstData(WB_DstData)
    );

    /*************************************** END WB STAGE ***************************************/

	// TODO assign outputs and inputs to all stages. Note: may need to
	// reach for internal signals such as the program counter within Fetch
	// IFstage.PC.pc or whatever

endmodule

/* Revert default net type after module to be wire. */
// wire

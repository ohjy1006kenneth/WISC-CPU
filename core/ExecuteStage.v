/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the EX stage of the processor.
 */
module ExecuteStage(
	input wire [3:0] Opcode,
    input wire [15:0] SrcData1,
    input wire [15:0] SrcData2,
    input wire [15:0] ImmOperand,
    input wire [15:0] PCPlus2,
    input wire [3:0] SrcReg1,
    input wire [3:0] SrcReg2,
    input wire [15:0] EX_MEM_DstData,
    input wire [15:0] MEM_WB_DstData,
    input wire [3:0] EX_MEM_RegDst,
    input wire [3:0] MEM_WB_RegDst,
    input wire EX_MEM_RegWrite,
    input wire MEM_WB_RegWrite,
    input wire EX_MEM_MemToReg,
    input wire ALUSrcSel1,
    input wire ALUSrcSel2,

	output wire [15:0] ALUOut,
    output wire [15:0] FwdData2,
	output wire [2:0] NewFlags
);

    wire [15:0] ALUSrc1;
    wire [15:0] ALUSrc2;

    /**
     *  Define intermediate ALU input data signals.
     */
    wire [15:0] FwdData1;  // Either source data 1 from RF, or forwarded data

    /**
     *  Define forwarding logic select signals.
     */
    wire EX_EX_Fwd_Src1;    // EX to EX forwarding select signal for source 1
    wire EX_EX_Fwd_Src2;    // EX to EX forwarding select signal for source 2
    wire MEM_EX_Fwd_Src1;   // MEM to EX forwarding select signal for source 1
    wire MEM_EX_Fwd_Src2;   // MEM to EX forwarding select signal for source 2

    /**
     *  Generate forwarding logic conditional select signals.
     */
    assign EX_EX_Fwd_Src1 = (EX_MEM_RegDst != 4'h0) & (EX_MEM_RegDst == SrcReg1) & (EX_MEM_RegWrite) & (~EX_MEM_MemToReg);
    assign EX_EX_Fwd_Src2 = (EX_MEM_RegDst != 4'h0) & (EX_MEM_RegDst == SrcReg2) & (EX_MEM_RegWrite) & (~EX_MEM_MemToReg); 
    assign MEM_EX_Fwd_Src1 = (MEM_WB_RegDst != 4'h0) & (MEM_WB_RegDst == SrcReg1) & (MEM_WB_RegWrite);
    assign MEM_EX_Fwd_Src2 = (MEM_WB_RegDst != 4'h0) & (MEM_WB_RegDst == SrcReg2) & (MEM_WB_RegWrite);

    /**
     *  Forwarding logic muxes to generate ALU source inputs.
     */
    assign FwdData1 = (EX_EX_Fwd_Src1) ? (EX_MEM_DstData) : ((MEM_EX_Fwd_Src1) ? (MEM_WB_DstData) : (SrcData1));
    assign FwdData2 = (EX_EX_Fwd_Src2) ? (EX_MEM_DstData) : ((MEM_EX_Fwd_Src2) ? (MEM_WB_DstData) : (SrcData2));

     /**
     *  ALU source multiplexers.
     */
    assign ALUSrc1 = ALUSrcSel1 ? PCPlus2 : FwdData1;
    assign ALUSrc2 = ALUSrcSel2 ? ImmOperand : FwdData2;
    
    /**
     *  Instantiate ALU.
     */
    ALU ALUModule(.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ALUOut(ALUOut), .Opcode(Opcode), .flags_out(NewFlags));

endmodule

/* Revert default net type after module to be wire. */
// wire

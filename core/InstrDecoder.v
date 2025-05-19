/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the instruction decoder, which outputs control flags for
 *  the datapath based on opcode.
 */
module InstrDecoder(Instr, ImmOperand, RegWrite, ALUSrcSel1, ALUSrcSel2, 
                    StoreInstr, MemToReg, SrcRegSel1, SrcRegSel2);

    /**
     *  Define module inputs and outputs.
     */
    input [15:0] Instr;             // Instruction to decode
    output [15:0] ImmOperand;       // ALU operand from instruction immediate
    output RegWrite;                // Flag asserted if writing to the reg fie
    output ALUSrcSel1, ALUSrcSel2;  // ALU source select control signals
    output StoreInstr;              // Flag if opcode is store instruction
    output MemToReg;                // Register file write data select control
    output SrcRegSel1, SrcRegSel2;  // RegFile source select control signals

    /**
     *  Intermediate signals.
     */
    wire [15:0] BranchImm;          // Instr[8:0] sign-extended and << 1 branch offset
    wire [15:0] LSOffset;           // Ld/St instruction signed offset << 1 and sign-extended
    wire [15:0] SRImm;              // Shift/Rotate unsigned immediate and sign-extended
    wire [15:0] LoadImmByte;        // LLB/LHB instructions 8-bit immediate and sign-extended

    /**
     *  Check if opcode is a store. If so, flag is set to 1. Flag is used
     *  by both register file source 2 mux and the data memory write enable.
     */
    assign StoreInstr = (Instr[15] & ~Instr[14]) & (~Instr[13] & Instr[12]);

    /**
     *  9-bit immediate offset sign extended and left-shifted by 1 branch 
     *  instruction (Opcode 1100).
     */
    assign BranchImm = {{6{Instr[8]}}, Instr[8:0], 1'b0};

    /**
     *  4-bit signed offset << 1 and then sign extended for use by the ALU
     *  to calculate the load/store address
     */
    assign LSOffset = {{11{Instr[3]}}, Instr[3:0], 1'b0};

    /**
     *  4-bit unsigned immediate used for SLL, SRA, and ROR. Value is
     *  sign extended to be used in the ALU (Imm is unsigned, so pad 0s).
     */
    assign SRImm = {12'h000, Instr[3:0]};

    /**
     *  8-bit immediate used by LLB and LHB. Value is sign extended.
     */
    assign LoadImmByte = Instr[12] ? {Instr[7:0], 8'h00} : {8'h00, Instr[7:0]};

    /**
     *  Calculate the immediate operand that will be one of the ALU sources in
     *  an instruction that requires it.
     */
    assign ImmOperand = Instr[15] ? (Instr[14] ? (BranchImm) : (Instr[13]) ? LoadImmByte : LSOffset) : SRImm;

    /**
     *  Logic to control the register write control signal based on the
     *  instruction opcode.
     */
    assign RegWrite = ~Instr[15] | (~Instr[14] & ~Instr[12]) | (Instr[13] & ~Instr[12]) | (~Instr[14] & Instr[13]);

    /**
     *  Register file SrcReg1 should read in rd for LLB/LHB instructions.
     *  This corresponds to SrcRegSel1 being high. Otherwise (0), SrcReg1
     *  will read rs.
     */
    assign SrcRegSel1 = (Instr[15] & ~Instr[14] & Instr[13]);

    /**
     *  Register file SrcReg2 should read in rt for all instructions except
     *  BR and PCS instructions. In these instructions (SrcRegSel2 = HIGH),
     *  the zero register is read for SrcReg2 for use later in the cpu.
     */
    assign SrcRegSel2 = (Instr[15] & Instr[14] & (Instr[13] ^ Instr[12]));

    /**
     *  Logic to control the source 1 of the ALU. Source 1 is PC + 2 if
     *  instruction is B (1100) or PCS (1110), otherwise it is rs reg.
     */
    assign ALUSrcSel1 = Instr[15] & Instr[14] & ~Instr[12];

    /**
     *  Logic to control the source 2 of the ALU. Source 2 is an immediate
     *  when SLL,SRA,ROR, or LW/SW/LLB/LHB, or B/PCS
     */
    assign ALUSrcSel2 = (~Instr[15] & Instr[14] & (~Instr[13] | ~Instr[12])) | (Instr[15] & ~Instr[14]) | (Instr[15] & ~(Instr[12] ^ Instr[13]));

    /**
     *  Logic to control whether the register file write data is coming from
     *  data memory output, or the alu result. Only storing data memory output
     *  to register file if load instruction.
     */
    assign MemToReg = (Instr[15] & ~Instr[14]) & (~Instr[13] & ~Instr[12]);
    
endmodule

/* Revert default net type after module to be wire. */
// wire

/* Assume no default net types to avoid issues. */
// none

module Fetch(
    input wire clk,                     // Clock signal
    input wire rst_n,                   // Active low reset

    input wire Mispredict,              // Branch signal
    input wire [15:0] BranchAddress,    // Address to branch to
    input wire [15:0] MispredictPC,     // Address of the mispredicted branch
    input wire Stall,
    input wire DMEM_STALL,
    input wire [15:0] InstructionD,
    input wire [15:0] PCPlus2D,

    output wire [15:0] PCPlus2,         // PC + 2 value for fetch stage
    output wire [15:0] PCOut,
    output wire [15:0] Instruction,     // Fetched instruction
    output wire PredictedTaken,

    output wire IMEM_RE,
    output wire [15:0] IMEM_MEM_addr,
    input wire [15:0] IMEM_MEM_dout,
    input wire IMEM_rdata_valid
);

    /**
     *  Define intermediate signals.
     */
    wire[15:0] pc;                      // Current PC
    wire [15:0] NextPCF;                // Next program counter calculated
    wire [15:0] PCPlus2F;               // PC + 2
    wire [15:0] ICache_Instr;           // Instruction output from I Cache
    wire HLT;
    wire PredictedTaken_raw;
    wire[15:0] branchimm;
    wire[15:0] branchtarget;
    wire IMEM_STALL;

    /**
     *  Assign program counter out signal.
     */
    assign PCOut = pc;
    
    /**
     *  Assign halt signal if opcode is 0xF.
     */
    assign HLT = Instruction[15:12] == 4'hF;

    
    assign PredictedTaken = ((Instruction[15:9] == 7'b1100111) | (Instruction[15:12] == 4'hC) & PredictedTaken_raw) & ~IMEM_STALL;

    /**
     *  Instantiate dynamic branch predictor.
     */
    bpcache bp(
        .clk(clk),
        .rst_n(rst_n),

        .addr(pc[3:0]),
        .branch(PredictedTaken_raw),

        .w_addr(MispredictPC[3:0]),
        .we(Mispredict)
    );

    /**
     *  Internal register for the program counter.
     */
    PC ProgCntr (.clk(clk), .rst(~rst_n), .NewPC(NextPCF), .CurrPC(pc));

    /**
     *  Shift branch immediate offset. (1'b1 to save an adder)
     */
    assign branchimm = {{6{Instruction[8]}}, Instruction[8:0], 1'b1};
    
    /**
     *  Adder to calculate branch target address.
     */
    CLA_16bit BranchCalc(.Sum(branchtarget), .CarryOut(), .A(pc), .B(branchimm), .CarryIn(1'b1));

    /**
     *  Generate PC + 2 for new instruction that could be operand or new pc.
     *
     *  NOTE: Can reduce by 1 bit since lowest bit is always 0
     */
    CLA_16bit PCAdder(.Sum(PCPlus2F), .CarryOut(), .A(pc), .B(16'h2) , .CarryIn(1'b0));

    /**
     *  Calculate the next program counter based on branch condition.
     *  If Branch is true, use BranchAddress; otherwise, use PC + 2.
     */
    assign NextPCF = Mispredict & ~IMEM_STALL? BranchAddress :
                    (Stall | HLT | IMEM_STALL | DMEM_STALL) ? (pc) :
                    (PredictedTaken) ? branchtarget :
                     PCPlus2F;

    /**
     *  Flush the Instruction with NOP if a branch is taken.
     *  NOP = LLB r0, 0 = 16'hA000
     */
    assign Instruction = Mispredict ? (16'hA000) : (DMEM_STALL | Stall) ? InstructionD : IMEM_STALL ? 16'hA000 : ICache_Instr;
    assign PCPlus2 = (Stall | HLT | IMEM_STALL) ? PCPlus2D : PCPlus2F;

    /**
     *  Instantiate instruction cache module. No data is ever written to this
     *  cache, so data in is all 0s and write enable is always 0.
     */
    cache Icache(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(16'h0000),
        .addr(pc),
        .wen(1'b0), 
        .ren(1'b1), // We read every cycle
        .data_out(ICache_Instr),
        .stall(IMEM_STALL),
        .MEM_din(IMEM_MEM_dout),
        .memory_data_valid(IMEM_rdata_valid),
        .MEM_addr(IMEM_MEM_addr),
        .MEM_RE(IMEM_RE),
        .MEM_WE(),
        .memory_wdone(1'b1)
    );

endmodule

/* Revert default net type after module to be wire. */
// wire

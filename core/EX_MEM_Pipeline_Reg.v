/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the EX/MEM pipeline register.
 */
module EX_MEM(
    input wire clk,
    input wire rst,
    input wire [15:0] EX_FwdData2,
    input wire [15:0] EX_ALUOut,
    input wire [3:0] EX_SrcReg2,
    input wire [3:0] EX_RegDst,
    input wire EX_RegWrite,
    input wire EX_StoreInstr,
    input wire EX_MemToReg,
    input wire [3:0] EX_Opcode,
    input wire DMEM_STALL,

    output wire [15:0] MEM_FwdData2,
    output wire [15:0] MEM_ALUOut,
    output wire [3:0] MEM_SrcReg2,
    output wire [3:0] MEM_RegDst,
    output wire MEM_RegWrite,
    output wire MEM_StoreInstr,
    output wire MEM_MemToReg,
    output wire MEM_HLT
);
    /**
     *  Enable signal for the pipeline register. If processor is stalling
     *  due to data cache miss, pipeline register should stall (hold state).
     */
    wire wen;
    assign wen = ~DMEM_STALL;

    /**
     *  Store FwdData2: Used in memory stage for store operations.
     */
    dff FwdData2[15:0] (.q(MEM_FwdData2), .d(EX_FwdData2), .wen({16{wen}}), .clk({16{clk}}), .rst({16{rst}}));

    /**
     *  Store ALUOut:   ALU result used as memory address in memory stage or
     *                  written to register file.
     */
    dff ALUOutReg[15:0] (.q(MEM_ALUOut), .d(EX_ALUOut), .wen({16{wen}}), .clk({16{clk}}), .rst({16{rst}}));

    /**
     *  Store SrcReg2:  Used for forwarding to memory stage condition check.
     */
    dff SrcReg2Reg[3:0] (.q(MEM_SrcReg2), .d(EX_SrcReg2), .wen({4{wen}}), .clk({4{clk}}), .rst({4{rst}}));

    /**
     *  Store RegDst:   Used in write back stage for register file destination.
     */
    dff RegDstReg[3:0] (.q(MEM_RegDst), .d(EX_RegDst), .wen({4{wen}}), .clk({4{clk}}), .rst({4{rst}}));

    /**
     *  Store RegWrite: Write enable signal used during write back stage.
     */
    dff RegWriteReg (.q(MEM_RegWrite), .d(EX_RegWrite), .wen(wen), .clk(clk), .rst(rst));

    /**
     *  Store StoreInstr:   Data memory read-write signal used in memory
     *                      stage.
     */
    dff StoreInstrReg (.q(MEM_StoreInstr), .d(EX_StoreInstr), .wen(wen), .clk(clk), .rst(rst));

    /**
     *  Store MemToReg: Used to select which data is written to register file
     *                  in the write back stage.
     */
    dff MemToRegReg (.q(MEM_MemToReg), .d(EX_MemToReg), .wen(wen), .clk(clk), .rst(rst));

    /**
     *  Store MemHalt:  Checks if opcode in execute stage is a halt and
     *                  propagates the halt signal to the memory stage.
     */
    dff MemHaltReg (.q(MEM_HLT), .d(EX_Opcode==4'hF), .wen(wen), .clk(clk), .rst(rst));

endmodule

/* Revert default net type after module to be wire. */
// wire

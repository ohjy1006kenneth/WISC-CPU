/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the MEM stage of the processor.
 */
module MemoryStage(
    input wire clk,
    input wire rst_n,

    input wire [15:0] WB_MemData,
    input wire [3:0] WB_RegDst,
    input wire WB_MemToReg,

    input wire [15:0] MEM_ALUOut,
    input wire [3:0] MEM_SrcReg2,
    input wire [15:0] MEM_WMData,
    input wire [3:0] MEM_RegDst,
    input wire MEM_StoreInstr,
    input wire MEM_MemToReg,

    output wire [15:0] MEM_MemData,
    output wire DMEM_RE,
    output wire DMEM_WE,
    output wire [15:0] DMEM_MEM_addr,
    input wire DMEM_rdata_valid,
    input wire [15:0] MEM4_dout,
    output wire [15:0] MEM4_din,
    input wire DMEM_WDONE,

    output wire DMEM_STALL
);  

    wire[15:0] WriteData_final;

    assign WriteData_final = WB_RegDst == MEM_SrcReg2 && WB_RegDst != 0 && WB_MemToReg ? WB_MemData : MEM_WMData;

    assign MEM4_din = WriteData_final;

    /**
     *  Instantiate data cache module.
     */
    cache Dcache(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(WriteData_final),
        .addr(MEM_ALUOut),
        .wen(MEM_StoreInstr), 
        .ren(MEM_MemToReg),
        .data_out(MEM_MemData),
        .stall(DMEM_STALL),
        .MEM_din(MEM4_dout),
        .memory_data_valid(DMEM_rdata_valid),
        .MEM_addr(DMEM_MEM_addr),
        .MEM_RE(DMEM_RE),
        .MEM_WE(DMEM_WE),
        .memory_wdone(DMEM_WDONE)
    );

endmodule

/* Revert default net type after module to be wire. */
// wire

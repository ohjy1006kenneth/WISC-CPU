// none
// 1 bit counter
module bpcache(
    input wire clk,
    input wire rst_n,

    input wire[3:0] addr,
    output wire branch,

    input wire[3:0] w_addr,
    input wire we
);
// Track up to 16 branches
wire[15:0] WriteEnable;
wire[15:0] BranchStates;

wire [7:0] stage1;
wire [3:0] stage2;
wire [1:0] stage3;
WriteDecoder_4_16 WriteDecoder(.RegId(w_addr), .WriteReg(we), .Wordline(WriteEnable));
dff BranchRegs[15:0] (.d(~BranchStates), .q(BranchStates), .wen(WriteEnable), .clk(clk), .rst(~rst_n));


assign stage1 = addr[3] ? BranchStates[15:8] : BranchStates[7:0];
assign stage2 = addr[2] ? stage1[7:4] : stage1[3:0];
assign stage3 = addr[1] ? stage2[3:2] : stage2[1:0];

assign branch = addr[0] ? stage3[1] : stage3[0];

endmodule
// wire

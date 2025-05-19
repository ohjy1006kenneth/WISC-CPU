// none
module WriteBack(
	input wire [15:0] WB_ALURes,
	input wire [15:0] WB_MemData,
	input wire WB_MemToReg,
	output wire [15:0] WB_DstData
);
assign WB_DstData = WB_MemToReg ? WB_MemData : WB_ALURes;
endmodule
// wire

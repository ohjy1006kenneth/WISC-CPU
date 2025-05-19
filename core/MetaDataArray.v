/**
 *	Module is a meta-data tag array consisting of 64 sets. Each block will
 *	have 1 byte. Block enable signal will be one-hot. Also, Write enable signal
 *	is one on wirtes and zero on reads.
 */
module MetaDataArray(
	input clk,
	input rst,
	input [7:0] DataIn,
	input Write,
	input [63:0] BlockEnable,
	output [7:0] DataOut
);
	// Store 64 meta-data blocks (1 byte each)
	MBlock Mblk[63:0]( .clk(clk), .rst(rst), .Din(DataIn), .WriteEnable(Write), .Enable(BlockEnable), .Dout(DataOut));

endmodule

/**
 *	Module stores a full meta-data byte. 
 *	
 *	1 valid bit (V) + 1 LRU bit (L) + 6 tag bits (T).
 *
 *	MBlock = VLTT_TTTT
 */
module MBlock(
	input clk,
	input rst,
	input [7:0] Din,
	input WriteEnable,
	input Enable,
	output [7:0] Dout
);
	// Store a meta-data byte
	MCell mc[7:0]( .clk(clk), .rst(rst), .Din(Din[7:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout[7:0]));

endmodule

/**
 *	Module stores one meta-data bit and controls reads and writes. When 
 *	meta-data cell is being written, the output is high-z. Otherwise, the 
 *	stored meta-data bit is driven out.
 */
module MCell(
	input clk,
	input rst,
	input Din,
	input WriteEnable,
	input Enable,
	output Dout
);
	// Hold meta-data bit flop output
	wire q;

	// When enabled, q goes to output, otherwise high-z
	assign Dout = Enable ? q : 1'bz;

	// Store meta-data bit in DFF
	dff dffm(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));

endmodule


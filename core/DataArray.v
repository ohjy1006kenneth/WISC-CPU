/**
 *	Module is a data array that consists of 64 cache blocks. Each block has
 *	8 words. The inputs to enable blocks and words are one-hot, meaning only
 *	one enabled at a time. Also, write enable is one on writes and zero on
 *	reads.
 */
module DataArray(
	input clk,
	input rst, 
	input [15:0] DataIn,
	input Write,
	input [63:0] BlockEnable, 
	input [7:0] WordEnable,
	output [15:0] DataOut
);
	// Store 64 data cache blocks, each consisting of 64 bytes 
	Block blk[63:0](.clk(clk), .rst(rst), .Din(DataIn), .WriteEnable(Write), .Enable(BlockEnable), .WordEnable(WordEnable), .Dout(DataOut));

endmodule

/**
 *	Module stores one data cache block that consists of 8 words (64 bytes).
 */
module Block(
	input clk,
	input rst,
	input [15:0] Din,
	input WriteEnable,
	input Enable,
	input [7:0] WordEnable,
	output [15:0] Dout
);
	// Mask to get enabled word in enabled cache block
	wire [7:0] WordEnable_real;

	// Only for the enabled cache block, you enable the specific word
	assign WordEnable_real = {8{Enable}} & WordEnable;

	// Store 8 data words
	DWord dw[7:0](.clk(clk), .rst(rst), .Din(Din), .WriteEnable(WriteEnable), .Enable(WordEnable_real), .Dout(Dout));

endmodule

/**
 *	Module stores a full data word (16 bits / 2 bytes).
 */
module DWord(
	input clk,
	input rst,
	input [15:0] Din,
	input WriteEnable,
	input Enable,
	output [15:0] Dout
);
	// Store a data word in DFF
	DCell dc[15:0](.clk(clk), .rst(rst), .Din(Din[15:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout[15:0]));

endmodule

/**
 *	Module stores one data bit and controls reads and writes. When data cell
 *	is being written, the output is high-z. Otherwise, the stored data bit is
 *	driven out.
 */
module DCell(
	input clk,
	input rst,
	input Din,
	input WriteEnable,
	input Enable,
	output Dout
);
	// Hold data bit flop output
	wire q;

	// When enabled, q goes to output, otherwise high-z
	assign Dout = Enable ? q : 1'bz;

	// Store data bit in DFF
	dff dffd(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));

endmodule


/* Assume no default net types to avoid issues. */
// none

/**
 * Flag/Condition code register module.
 */
module flags(clk, rst, Opcode, NewFlags, Flags);

	/**
	 *	Define module inputs and outputs.
	 */
	input wire clk;				// System clock
	input wire rst;				// Reset signal
	input wire[3:0] Opcode;		// Opcode of instruction
	input wire[2:0] NewFlags;	// Incoming flags to store
	output wire[2:0] Flags;		// Flags stored currently

	/**
	 *	Hold the flag mask that determines which flag will be written.
	 */
	wire[2:0] FlagsMask;		// Controls when flags are set

	/**
	 *	Hold flags.
	 */
	wire [2:0] Flags_stored;

	/**
	 *	Logic to determine flag mask for which flag to write based on the 
	 *	instruction opcode.
	 *
	 *	FlagsMask[2] for N, written when operation is ADD/SUB
	 *	FlagsMask[1] for Z, written when instruction is arithmetic
	 *	FlagsMask[0] for V, written when operation is ADD/SUB
	 */
	assign FlagsMask[2] = (~|Opcode[3:1]);
	assign FlagsMask[1] = ~Opcode[3] && (Opcode != 4'h3 && Opcode != 4'h6);
	assign FlagsMask[0] = FlagsMask[2];
	
	
	/**
	 *	Instantiate 3 DFFs to serve as the flag register. Write enable for
	 *	each flag is controlled by the calculated flag mask.
	 */
	dff fl[2:0] (.q(Flags_stored), .d(NewFlags), .wen(FlagsMask), .clk(clk), .rst(rst));

	/**
	 *	Internally bypass flags.
	 */
	assign Flags = (FlagsMask & NewFlags) | (~FlagsMask & Flags_stored);
	
endmodule

/* Revert default net type after module to be wire. */
// wire

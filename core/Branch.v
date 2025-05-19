/* Assume no default net types to avoid issues. */
// none

/**
 *	Module is the branch logic that controls whether the current
 *	instruction branches or not based on the condition codes and
 *	instruction.
 */
module Branch(instruction, flags_stored, branch);

	/**
	 *	Define module inputs and outputs.
	 */
	input wire[15:0] instruction;	// Current instruction
	input wire[2:0] flags_stored;	// Current flag values (NZV)
	output wire branch;				// Branch flag, asserted if taken

	/**
	 *	Intermediate signals.
	 */
	wire branchmatch;		// Asserted when condition is met for branching
	wire[2:0] cc_instr;		// Condition code from instruction

	/**
	 *	Break out flag values from the flag vector.
	 */
	wire N = flags_stored[2];
	wire Z = flags_stored[1];
	wire V = flags_stored[0];
	
	/**
	 *	Pull condition code from instruction.
	 */
	assign cc_instr = instruction[11:9];

	/**
	 *	Check whether each condition code is met based
	 *	on the flags.
	 */
	assign branchmatch = 
		cc_instr == 3'b000 ? (~Z) :
		cc_instr == 3'b001 ? (Z) :
		cc_instr == 3'b010 ? (~Z & ~N) :
		cc_instr == 3'b011 ? (N) :
		cc_instr == 3'b100 ? (Z|(~Z&~N)) :
		cc_instr == 3'b101 ? (N|Z) :
		cc_instr == 3'b110 ? (V) : 1'b1;

	/**
	 *	Assert branch flag is instruction is a branch and the condition
	 *	code is met in the specified branch instruction.
	 */
	assign branch = (instruction[15:13] == 4'b110) & branchmatch;

endmodule

/* Revert default net type after module to be wire. */
// wire

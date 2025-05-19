/* Assume no default net types to avoid issues. */
// none

/**
 *  Module performs 4-bit addition, checks for overflow, and saturates
 *  the sum if overflow occurred.
 */
module addsb_4bit(Sum, A, B);

    /**
	 *	Define module inputs and outputs.
	 */
    input wire[3:0] A, B;   // Input values
    output wire[3:0] Sum;   // Output sum

    /**
     *  Define intermediate signals.
     */
	wire[3:0] Sum_tmp;      // Temp sum before checking overflow
	wire Ovfl;              // Overflow flag
    wire[3:0] carry;        // Carry outs during addition

    /**
     *  Instantiate 4 full adders to form 4-bit RCA.
     */
    full_adder_1bit FA[3:0] (.A(A), .B(B), .CarryIn({carry[2:0], 1'b0}), .CarryOut(carry), .Sum(Sum_tmp));

    /**
     *  Signed overflow happens when carry out flips two 1s
     *  to 0, unless there's also a carry in to preserve it.
     *  Can also happen when there's just a carry in.
     *
     *  This is equivalent to ~(A[3] ^ B[3]) & (A[3] ^ C[3])
     */
    assign Ovfl = (carry[3] ^ carry[2]);

    /**
     *  Assign the resulting sum of the 4-bit addition to be either the sum
     *  directly, or saturated answer based on if overflow occurred.
     */
	assign Sum = Ovfl ? ({4{A[3]}} ^ 4'h7) : Sum_tmp;

endmodule

/* Revert default net type after module to be wire. */
// wire
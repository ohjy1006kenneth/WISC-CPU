/* Assume no default net types to avoid issues. */
// none

/**
 *	Module performs four half-byte additions in parallel to realize
 *	sub-word parallelism. Specifically, each of the four half bytes
 *	(4 bits) will be treated as separate numbers stored in a single
 *	word as a byte vector. When PADDSB is performed, the four numbers
 *	will be added separately. The four half-bytes of the result should
 *	be saturated separately, meaning if a result exceeds the most
 *	positive number 2^3 - 1, then the result is saturated to 2^3 - 1.
 *	And if the result were to drop below the most negative number -2^3,
 *	then the result is saturated to -2^3.
 */
module PADD_16bit (Sum, A, B);

	/**
	 * 	Define module inputs and outputs.
	 */
	input [15:0] A, B;      // Input data values
	output [15:0] Sum;      // PADDSB output

	/**
	 *	Instantiate 4 4-bit adders and concatenate the sums to form
	 *	the output word.
	 */
	addsb_4bit components[3:0] (.Sum(Sum), .A(A), .B(B));

endmodule

/* Revert default net type after module to be wire. */
// wire
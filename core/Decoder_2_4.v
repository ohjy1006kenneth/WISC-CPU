/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is a 2 to 4 decoder with enable.
 */
module Decoder_2_4(A, Y, En);

    /**
     *  Define module inputs and outputs.
     */
    input [1:0] A;      // Input vector
    input En;           // Active high enable
    output [3:0] Y;     // Decoded output

    /**
     *  Decode input into output.
     */
    assign Y[0] = En & (~A[1] & ~A[0]);
    assign Y[1] = En & (~A[1] & A[0]);
    assign Y[2] = En & (A[1] & ~A[0]);
    assign Y[3] = En & (A[1] & A[0]);

endmodule

/* Revert default net type after module to be wire. */
// wire
/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is a 3 to 8 decoder.
 */
module Decoder_3_8(
    input wire[2:0] in,
    output wire[7:0] out
);

    /**
     *  Intermediate shifted values.
     */
    wire[1:0] ss1;
    wire[3:0] ss2;

    /**
     *  Perform decoding by shifting by each bit positions value.
     */
    assign ss1 = in[0] ? 2'b10 : 2'b01;
    assign ss2 = in[1] ? {ss1, 2'b00} : {2'b00, ss1};
    assign out = in[2] ? {ss2, 4'h0} : {4'h0, ss2};

endmodule

/* Revert default net type after module to be wire. */
// wire
/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is a 6 to 64 decoder.
 */
module Decoder_6_64(
    input wire[5:0] in,
    output wire[63:0] out
);

    /**
     *  Intermediate shifted values.
     */
    wire[1:0] ss1;
    wire[3:0] ss2;
    wire[7:0] ss3;
    wire[15:0] ss4;
    wire[31:0] ss5;

    /**
     *  Perform decoding by shifting by each bit positions value.
     */
    assign ss1 = in[0] ? 2'b10 : 2'b01;
    assign ss2 = in[1] ? {ss1, 2'b00} : {2'b00, ss1};
    assign ss3 = in[2] ? {ss2, 4'h0} : {4'h0, ss2};
    assign ss4 = in[3] ? {ss3, 8'h00} : {8'h00 , ss3};
    assign ss5 = in[4] ? {ss4, 16'h00} : {16'h00 , ss4};
    assign out = in[5] ? {ss5, 32'h00} : {32'h00 , ss5};

endmodule

/* Revert default net type after module to be wire. */
// wire
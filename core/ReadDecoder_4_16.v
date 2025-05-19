/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is a 4 to 16 decoder used for the read registers on the
 *  register file.
 */
module ReadDecoder_4_16(RegId, Wordline);

    /**
     *  Define module inputs and outputs.
     */
    input [3:0] RegId;          // Register to be read
    output [15:0] Wordline;     // Word line to be read

    /**
     *  Intermediate enable signal. Selects which bit range depending
     *  on MSB 2 bits.
     */
    wire [3:0] enables;

    /**
     *  Instantiate 2x4 decoders. First decodes the the 2 MSB. the 
     *  last 4 decode the 2 LSB. Read decoders always enabled.
     */
    Decoder_2_4 dec2to4_MSB(.A(RegId[3:2]), .Y(enables), .En(1'b1));
    Decoder_2_4 dec2to4_LSB0(.A(RegId[1:0]), .Y(Wordline[3:0]), .En(enables[0]));
    Decoder_2_4 dec2to4_LSB1(.A(RegId[1:0]), .Y(Wordline[7:4]), .En(enables[1]));
    Decoder_2_4 dec2to4_LSB2(.A(RegId[1:0]), .Y(Wordline[11:8]), .En(enables[2]));
    Decoder_2_4 dec2to4_LSB3(.A(RegId[1:0]), .Y(Wordline[15:12]), .En(enables[3]));

endmodule

/* Revert default net type after module to be wire. */
// wire
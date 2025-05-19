/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is a 4-bit CLA.
 */
module CLA_5bit(Sum, A, B);

    /**
     *  Define module inputs and outputs.
     */
    input [4:0] A, B;       // Two 4-bit input values
    output [5:0] Sum;       // Resulting 4-bit sum

    /**
     *  Hold internal propagate and generate signals.
     */
    wire [4:0] p;         // Hold propagate signals from 1-bit CLAs
    wire [4:0] g;         // Hold generate signals from 1-bit CLAs

    /**
     *  Hold carryout and all intermediate carries.
     */
    wire [4:0] Carries;

    /**
     *  Carry lookahead block that calculates intermediate carries.
     */
    assign Carries[0] = 1'b0;
    assign Carries[1] = g[0] | (p[0] & Carries[0]);
    assign Carries[2] = g[1] | (p[1] & Carries[1]);
    assign Carries[3] = g[2] | (p[2] & Carries[2]);
    assign Carries[4] = g[3] | (p[3] & Carries[3]);

    /**
     *  Calculate whether 4-bit sum will propagate or generate carry.
     */
    assign Sum[5] = g[4]| (p[4] & g[3]) | (p[4] & p[3] & g[2]) | (p[4] & p[3] & p[2] & g[1]) | (p[4] & p[3] & p[2] & p[1] & g[0]);

    /**
     *  Instantiate 4 1-bit CLAs.
     */
    CLA_1bit CLAs_1bit[4:0] (.Sum(Sum[4:0]), .p(p), .g(g), .A(A), .B(B) ,.CarryIn(Carries));

endmodule

/* Revert default net type after module to be wire. */
// wire
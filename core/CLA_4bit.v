/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is a 4-bit CLA.
 */
module CLA_4bit(Sum, P, G, A, B ,CarryIn);

    /**
     *  Define module inputs and outputs.
     */
    input wire [3:0] A, B;       // Two 4-bit input values
    input wire CarryIn;          // Carry in bit that is added in
    output wire [3:0] Sum;       // Resulting 4-bit sum
    output wire P;               // Whether sum will propagate carry
    output wire G;               // Whether sum will generate carry
    
    /**
     *  Hold internal propagate and generate signals.
     */
    wire [3:0] p;         // Hold propagate signals from 1-bit CLAs
    wire [3:0] g;         // Hold generate signals from 1-bit CLAs

    /**
     *  Hold carryout and all intermediate carries.
     */
    wire [3:0] Carries;

    /**
     *  Carry lookahead block that calculates intermediate carries.
     */
    assign Carries[0] = CarryIn;
    assign Carries[1] = g[0] | (p[0] & Carries[0]);
    assign Carries[2] = g[1] | (p[1] & Carries[1]);
    assign Carries[3] = g[2] | (p[2] & Carries[2]);

    /**
     *  Calculate whether 4-bit sum will propagate or generate carry.
     */
    assign P = &p[3:0];
    assign G = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);

    /**
     *  Instantiate 4 1-bit CLAs.
     */
    CLA_1bit CLAs_1bit[3:0] (.Sum(Sum), .p(p), .g(g), .A(A), .B(B) ,.CarryIn(Carries));

endmodule

/* Revert default net type after module to be wire. */
// wire
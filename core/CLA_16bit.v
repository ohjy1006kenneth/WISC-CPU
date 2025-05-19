/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is a 16-bit CLA.
 */
module CLA_16bit(Sum, CarryOut, A, B ,CarryIn);

    /**
     *  Define module inputs and outputs.
     */
    input [15:0] A, B;      // Two 4-bit input values
    input CarryIn;          // Carry in bit that is added in
    output CarryOut;        // Carry out bit
    output [15:0] Sum;      // Resulting 4-bit sum

    /**
     *  Hold internal propagate and generate signals.
     */
    wire [3:0] P;           // Hold propagate signals from 4-bit CLAs
    wire [3:0] G;           // Hold generate signals from 4-bit CLAs

    /**
     *  Hold carryout and all intermediate carries.
     */
    wire [3:0] Carries;

    /**
     *  Carry lookahead block that calculates intermediate carries.
     */
    assign Carries[0] = CarryIn;
    assign Carries[1] = G[0] | (P[0] & Carries[0]);
    assign Carries[2] = G[1] | (P[1] & Carries[1]);
    assign Carries[3] = G[2] | (P[2] & Carries[2]);
    assign CarryOut = G[3] | (P[3] & Carries[3]);

    /**
     *  Instantiate 4 4-bit CLAs.
     */
    CLA_4bit CLA_4bit0(.Sum(Sum[3:0]), .P(P[0]), .G(G[0]), .A(A[3:0]), .B(B[3:0]) ,.CarryIn(Carries[0]));
    CLA_4bit CLA_4bit1(.Sum(Sum[7:4]), .P(P[1]), .G(G[1]), .A(A[7:4]), .B(B[7:4]) ,.CarryIn(Carries[1]));
    CLA_4bit CLA_4bit2(.Sum(Sum[11:8]), .P(P[2]), .G(G[2]), .A(A[11:8]), .B(B[11:8]) ,.CarryIn(Carries[2]));
    CLA_4bit CLA_4bit3(.Sum(Sum[15:12]), .P(P[3]), .G(G[3]), .A(A[15:12]), .B(B[15:12]) ,.CarryIn(Carries[3]));

endmodule

/* Revert default net type after module to be wire. */
// wire
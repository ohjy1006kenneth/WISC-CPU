/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is a 1-bit CLA.
 */
module CLA_1bit(Sum, p, g, A, B ,CarryIn);

    /**
     *  Define module inputs and outputs.
     */
    input A, B;         // Two 1-bit input values
    input CarryIn;      // Carry in bit that is added in
    output Sum;         // Resulting bit
    output p;           // Whether sum will propagate carry
    output g;           // Whether sum will generate carry

    /**
     *  Compute the sum bit.
     */
    assign Sum = A ^ B ^ CarryIn;
    
    /**
     *  Compute generate and propagate signals.
     */
    assign p = A | B;
    assign g = A & B;

endmodule

/* Revert default net type after module to be wire. */
// wire
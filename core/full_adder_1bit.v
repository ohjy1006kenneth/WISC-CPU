// none
/**
 *  Module is a full adder, which computes the addition of two
 *  1-bit values and outputs a sum and carry out bit. The adder
 *  also takes in a carry in bit that is added.
 */
module full_adder_1bit(Sum, CarryOut, A, B ,CarryIn);

    /**
     *  Define module inputs and outputs.
     */
    input wire A, B;         // Two 1-bit input values
    input wire CarryIn;      // Carry in bit that is added in
    output wire Sum;         // Resulting bit
    output wire CarryOut;    // Extra carry out bit that ripples

    /**
     *  Compute the sum bit.
     */
    assign Sum = A ^ B ^ CarryIn;
    
    /** 
     *  Compute the carry out bit.
     */ 
    assign CarryOut = ((A ^ B) & CarryIn) | (A & B);

endmodule
// wire

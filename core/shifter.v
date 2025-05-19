/* Assume no default net types to avoid issues. */
// none

/**
 *  Module performs a shift left logical operation. It shifts
 *  the input by the bit position values that have a 1 in them.
 */
module cs_left(out, in, amt);
    
    /**
	 * 	Define module inputs and outputs.
	 */
    input[15:0] in;     // Input value to SLL
    input [3:0] amt;    // Amount to shift input left
    output[15:0] out;   // Output of SLL
    
    /**
     *  Define intermediate shift results.
     */
    wire[15:0] ss1;     // amt[3] shift result (8-bits)
    wire[15:0] ss2;     // amt[2] shift result (4-bits)
    wire[15:0] ss3;     // amt[1] shift result (2-bits)
    
    /**
     *  Compute shifts based on the bits set in the amount. Fill
     *  in zeros to the right as input is shifted left.
     */
    assign ss1 = amt[3] ? {in[7:0], 8'b0} : in;
    assign ss2 = amt[2] ? {ss1[11:0], 4'b0} : ss1;
    assign ss3 = amt[1] ? {ss2[13:0], 2'b0} : ss2;
    assign out = amt[0] ? {ss3[14:0], 1'b0} : ss3;

endmodule

/**
 *  Module performs a shift right arithmetic, maintaining sign.
 */
module cs_righta(out, in, amt);

    /**
	 * 	Define module inputs and outputs.
	 */
    input[15:0] in;     // Input value to SRA  
    input [3:0] amt;    // Amount to shift input right
    output[15:0] out;   // Output of SRA
    
    /**
     *  Define intermediate shift results.
     */
    wire[15:0] ss1;     // amt[3] shift result (8-bits)
    wire[15:0] ss2;     // amt[2] shift result (4-bits)
    wire[15:0] ss3;     // amt[1] shift result (2-bits)
    
    /**
     *  Compute shifts based on the bits set in the amount. Fill
     *  in sign bits when shifting right to preserve sign.
     */
    assign ss1 = amt[3] ? {{8{in[15]}}, in[15:8]} : in;
    assign ss2 = amt[2] ? {{4{ss1[15]}}, ss1[15:4]} : ss1;
    assign ss3 = amt[1] ? {{2{ss2[15]}}, ss2[15:2]} : ss2;
    assign out = amt[0] ? {{1{ss3[15]}}, ss3[15:1]} : ss3;

endmodule

/**
 *  Module performs a rotate right operation.
 */
module rotate_right(out, in, amt);

    /**
	 * 	Define module inputs and outputs.
	 */
    input [15:0] in;    // Input value to ROR
    input [3:0] amt;    // Amount to rotate input right
    output [15:0] out;  // Output of ROR
    
    /**
     *  Define intermediate rotate results.
     */
    wire [15:0] ss1;        // amt[3] rotate result (8-bits)
    wire [15:0] ss2;        // amt[2] rotate result (4-bits)
    wire [15:0] ss3;        // amt[1] rotate result (2-bits)

    /**
     *  Compute rotates based on the bits set in the amount.
     */
    assign ss1 = amt[3] ? {in[7:0], in[15:8]} : in;
    assign ss2 = amt[2] ? {ss1[3:0], ss1[15:4]} : ss1;
    assign ss3 = amt[1] ? {ss2[1:0], ss2[15:2]} : ss2;
    assign out = amt[0] ? {ss3[0], ss3[15:1]} : ss3;

endmodule

/**
 *  Module is a top-level shifter that performs different shift
 *  operations depending on the mode. The modes are as follows:
 *
 *  00 = Shift Left Logical
 *  01 = Shift Right Arithmetic
 *  10 = Rotate Right
 */
module Shifter (Shift_Out, Shift_In, Shift_Val, Mode);

    /**
	 * 	Define module inputs and outputs.
	 */
    input [15:0] Shift_In;          // Input data to perform shift on
    input [3:0] Shift_Val;          // Shift amount to shift input
    input [1:0] Mode;               // Indicate which shift mode to use
    output [15:0] Shift_Out;        // Shifted output data

    /**
     *  Define all shift operation output signals.
     */
    wire [15:0] Shift_Outa;     // SLL output
    wire [15:0] Shift_Outb;     // SRA output
    wire [15:0] Shift_Outc;     // ROR output

    /**
     *  Compute shift logical left operation.
     */
    cs_left l(.out(Shift_Outa), .in(Shift_In), .amt(Shift_Val));

    /**
     *  Compute shift arithmetic right operation.
     */
    cs_righta r(.out(Shift_Outb), .in(Shift_In), .amt(Shift_Val));
    
    /**
     *  Compute rotate right operation.
     */
    rotate_right ror(.out(Shift_Outc), .in(Shift_In), .amt(Shift_Val));

    /**
     *  Correctly assign the shift operation output based on 
     *  the input mode.
     */
    assign Shift_Out = Mode[1] ? Shift_Outc : (Mode[0] ? Shift_Outb : Shift_Outa);

endmodule

/* Revert default net type after module to be wire. */
// wire
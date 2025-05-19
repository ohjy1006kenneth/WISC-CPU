/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the ALU. See the spreadsheet for info about instructions.
 */
module ALU(ALUSrc1, ALUSrc2, ALUOut, Opcode, flags_out);

	/**
	 * 	Define module inputs and outputs.
	 */
	input [15:0] ALUSrc1, ALUSrc2;  // ALU source inputs
	input [3:0] Opcode;             // ALU operation code
	output [15:0] ALUOut;           // ALU result output
	output [2:0] flags_out;			// Output flags

	/**
	 *	Define ALU opcodes.
	 */
	parameter ALU_OP_ADD = 4'b0000;
	parameter ALU_OP_SUB = 4'b0001;
	parameter ALU_OP_XOR = 4'b0010;
	parameter ALU_OP_RED = 4'b0011;
	parameter ALU_OP_SLL = 4'b0100;
	parameter ALU_OP_SRA = 4'b0101;
	parameter ALU_OP_ROR = 4'b0110;
	parameter ALU_OP_PAS = 4'b0111;

	/**
	 *	Define intermediate operation result signals.
	 */
    wire [15:0] AdderBSign;			// Signed B operand (Normal or 1's comp)
    wire[15:0] addsub_raw;			// Raw 16-bit add/sub result
	wire addsub_ovfl;				// ADD/SUB overflow flag
    wire addsub_carry;				// ADD/SUB carry out signal
	wire[15:0] addsub_saturated;	// Final ADD/SUB output, saturated or raw
    wire[15:0] xor_res;				// XOR operation result
    wire[15:0] red_res;				// RED operation result
    wire[15:0] ror_res;				// Rotate right result
    wire[15:0] shift_res;			// SLL/SRA result
    wire[15:0] paddsb_res;			// PADDSB result

	/**
	 *	If the opcode is SUB, flip the second operand (1's complement).
	 *	This will become 2's complement later when the carry in is 
	 *	assigned a '1' for subtract instructions.
     */
	assign AdderBSign = ALUSrc2 ^ {16{Opcode == 4'h1}};

    /**
     *  Perform raw 16-bit add or subtract operation. Computes subtraction if 
	 *	opcode is SUB (4'h1).
     */
    CLA_16bit Adder(.Sum(addsub_raw), .CarryOut(addsub_carry), .A(ALUSrc1), .B(AdderBSign) ,.CarryIn(Opcode == 4'h1));

    /**
     *  Check if ALU operation produced overflow and generate add/sub overflow flag.
     */
	assign addsub_ovfl = ((~(ALUSrc1[15] ^ AdderBSign[15])) && (ALUSrc1[15] ^ addsub_raw[15]));

    /**
     *  Saturate the output of ADD/SUM operation if overflow occurred.
     */
	assign addsub_saturated = addsub_ovfl ? ({16{ALUSrc1[15]}} ^ 16'h7FFF) : addsub_raw;

	/**
     *  Perform XOR operation.
     */
	assign xor_res = ALUSrc1 ^ ALUSrc2;

	/**
     *  Perform reduce operation.
     */
	ReductionUnit red(.rs(ALUSrc1), .rt(ALUSrc2), .rd(red_res));

	/**
     *  Perform shift operation (Either SLL or SRA).
     */
	Shifter shft1(.Shift_Out(shift_res), .Shift_In(ALUSrc1), .Shift_Val(ALUSrc2[3:0]), .Mode({1'b0, Opcode[0]}));

    /**
     *  Perform rotate operation.
     */
	Shifter shft2(.Shift_Out(ror_res), .Shift_In(ALUSrc1), .Shift_Val(ALUSrc2[3:0]), .Mode({Opcode[1], 1'b0}));

	/**
     *  Perform parallel add subtract operation.
     */
	PADD_16bit padd(.Sum(paddsb_res), .A(ALUSrc1), .B(ALUSrc2));

	/**
	 *  Mux logic for selecting proper ALU output depending on
     *  the opcode.
     */
	assign ALUOut =	(Opcode == 4'hA) ? {ALUSrc1[15:8], ALUSrc2[7:0]} :
					(Opcode == 4'hB) ? {ALUSrc2[15:8], ALUSrc1[7:0]} :
					(Opcode == ALU_OP_XOR) ? xor_res :
					(Opcode == ALU_OP_RED) ? red_res :
					(Opcode == ALU_OP_ROR) ? ror_res :
					(Opcode == ALU_OP_PAS) ? paddsb_res:
					(Opcode == ALU_OP_SLL | Opcode == ALU_OP_SRA) ? shift_res : 
					addsub_saturated;	// Opcode 4'b1xxx = ADD

    /**
     *  Logic for assigning the flags {N, Z, V}.
	 *
	 *	N set if ALUOut[15] == 1 (negative).
	 *	Z set if ALUOut is zero
	 *	V set if overflow occurred in ADD/SUB
     */
	assign flags_out = {ALUOut[15], ~|ALUOut, addsub_ovfl};

endmodule

/* Revert default net type after module to be wire. */
// wire
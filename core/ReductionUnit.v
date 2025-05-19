/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is the logic for the reduction operation. The operation performs on
 *  8 half-byte sized operands (4 half bytes each from 2 registers). Result
 *  will be sign extended reduction sum. An example is shown below.
 *
 *  Let rs = aaaa_bbbb_cccc_dddd;
 *  Let rt = eeee_ffff_gggg_hhhh; 
 *  
 *  Result = ((aaaa + eeee) + (bbbb + ffff) + (cccc + gggg) + (dddd + hhhh));
 */
module ReductionUnit (rs, rt, rd);
   
    /**
	 *  Define module inputs and outputs.
	 */
    input [15:0] rs, rt;    // Two input registers (4 half bytes from each)
    output wire [15:0] rd;  // Sign extended reduction sum
    
    /**
     *  Define intermediate sums.
     */
    wire [4:0] sumae;               // Sum of aaaa + eeee
    wire [4:0] sumbf;               // Sum of bbbb + ffff
    wire [4:0] sumcg;               // Sum of cccc + gggg
    wire [4:0] sumdh;               // Sum of dddd + hhhh
    wire [5:0] sum1;                // Sum of aaaa + eeee + bbbb + ffff
    wire [5:0] sum2;                // Sum of cccc + gggg + dddd + hhhh
    wire [3:0] final_sum_lower;     // Lower half of final reduction sum
    wire [3:0] final_sum_upper;     // Upper half of final reduction sum
    
    /**
     *  Define intermediate propagate and generate signals used for carries.
     */
    wire [3:0] P1;          // 1st level propagate signals, unused
    wire [3:0] G1;          // 1st level generate signals, carry outs
    wire [1:0] P3;          // 3rd level propagate signals, unused
    wire [1:0] G3;          // 3rd level generate signals, carry outs

    /**
     *  Perform first level half-byte additions in the following order:
     *  aaaa + eeee -> bbbb + ffff -> cccc + gggg -> dddd + hhhh
     */
    CLA_4bit CLAae (.Sum(sumae[3:0]), .P(P1[0]), .G(G1[0]), .A(rs[15:12]), .B(rt[15:12]), .CarryIn(1'b0));
    CLA_4bit CLAbf (.Sum(sumbf[3:0]), .P(P1[1]), .G(G1[1]), .A(rs[11:8]),  .B(rt[11:8]),  .CarryIn(1'b0));
    CLA_4bit CLAcg (.Sum(sumcg[3:0]), .P(P1[2]), .G(G1[2]), .A(rs[7:4]),   .B(rt[7:4]),   .CarryIn(1'b0));
    CLA_4bit CLAdh (.Sum(sumdh[3:0]), .P(P1[3]), .G(G1[3]), .A(rs[3:0]),   .B(rt[3:0]),   .CarryIn(1'b0));

    /**
     *  Add carry out bit to the sum first level half-byte sum.
     */
    assign sumae[4] = G1[0];
    assign sumbf[4] = G1[1];
    assign sumcg[4] = G1[2];
    assign sumdh[4] = G1[3];

    /**
     *  Perform second level addition of the first bytes of rs and rt, and
     *  the second bytes of rs and rt.
     */
    CLA_5bit CLA1 (.Sum(sum1), .A(sumae), .B(sumbf));
    CLA_5bit CLA2 (.Sum(sum2), .A(sumcg), .B(sumdh));
    
    /**
     *  Third level adds 6 bit results using 2 4-bit adders. Computes
     *  final reduction sum.
     */
    CLA_4bit CLA7_Lower (.Sum(final_sum_lower), .P(P3[0]), .G(G3[0]), .A(sum1[3:0]), .B(sum2[3:0]), .CarryIn(1'b0));
    CLA_4bit CLA7_Upper (.Sum(final_sum_upper), .P(P3[1]), .G(G3[1]), .A({{{2{sum1[5]}}, sum1[5:4]}}), .B({{2{sum2[5]}}, sum2[5:4]}), .CarryIn(G3[0]));

    /**
     *  Sign-extend final sum to be 16 bits.
     */
    assign rd = {{8{G3[1]}}, final_sum_upper, final_sum_lower};

endmodule

/* Revert default net type after module to be wire. */
// wire
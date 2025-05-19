/**
 *  Gokul's D-Flip-Flop module. Implemented as active high
 *  reset, but will be fed a ~rst signal to make it active
 *  low according to project specs.
 */
module dff (q, d, wen, clk, rst);

    /**
     *  Define module inputs and outputs.
     */
    input d;        // DFF input
    input wen;      // Write Enable
    input clk;      // Clock
    input rst;      // Reset (used synchronously)
    output q;       // DFF output

    /**
     *  Intermediate signal holds output state.
     */
    reg state;

    /**
     *  Always connect state to the DFF output.
     */
    assign q = state;

    /**
     *  At rising clock edge, set state to 0 if in reset, otherwise
     *  if write enable is asserted set state to the d input, and if
     *  write enable is not asserted, hold state.
     */
    always @(posedge clk) begin
        state <= rst ? 0 : (wen ? d : state);
    end

endmodule

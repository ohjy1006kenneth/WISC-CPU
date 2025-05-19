module ReadDecoder_7_128(input wire[6:0] RegId, output wire[127:0] Wordline);

wire[1:0] ss1;
wire[3:0] ss2;
wire[7:0] ss3;
wire[15:0] ss4;
wire[31:0] ss5;
wire[63:0] ss6;

assign ss1 = RegId[0] ? 2'b10 : 2'b01;
assign ss2 = RegId[1] ? {ss1, 2'b00} : {2'b00, ss1};
assign ss3 = RegId[2] ? {ss2, 4'h0} : {4'h0, ss2};
assign ss4 = RegId[3] ? {ss3, 8'h00} : {8'h00 , ss3};
assign ss5 = RegId[3] ? {ss4, 16'h00} : {16'h00 , ss4};
assign ss6 = RegId[3] ? {ss5, 32'h00} : {32'h00 , ss5};
assign Wordline = RegId[3] ? {ss6, 64'h00} : {64'h00 , ss6};

endmodule

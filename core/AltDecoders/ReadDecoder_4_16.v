module ReadDecoder_4_16(input wire[3:0] RegId, output wire[15:0] Wordline);

wire[1:0] ss1;
wire[3:0] ss2;
wire[7:0] ss3;

assign ss1 = RegId[0] ? 2'b10 : 2'b01;
assign ss2 = RegId[1] ? {ss1, 2'b00} : {2'b00, ss1};
assign ss3 = RegId[2] ? {ss2, 4'h0} : {4'h0, ss2};
assign Wordline = RegId[3] ? {ss3, 8'h00} : {8'h00 , ss3};

endmodule

/* Assume no default net types to avoid issues. */
// none

/**
 *  Module is a register file. The register file is made up of 16
 *  registers. The register file supports internal write-before-read
 *  bypassing. This means that the design can read the written value
 *  to a register in the same cycle as a write.
 */
module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);

    /**
     *  Define module inputs and outputs.
     */
    input wire clk;                          // global clock
    input wire rst;                          // Active high rest
    input wire [3:0] SrcReg1, SrcReg2;       // Source register inputs
    input wire [3:0] DstReg;                 // Register to write to
    input wire WriteReg;                     // Write register enable signal
    inout wire [15:0] SrcData1, SrcData2;    // Source register read output lines
    input wire [15:0] DstData;               // Data to write to DstReg

    /**
     *  Intermediate signals to hold the wordlines for both source
     *  registers that are to be read, and the write register if write
     *  enabled.
     */
    wire [15:0] ReadEnable1, ReadEnable2, WriteEnable;

    /**
     *  Intermediate signals to hold register file 16-bit output.
     */
    wire [15:0] Bitline1, Bitline2;

    /**
     *  Instantiate both source register decoders and write register decoder.
     */
    ReadDecoder_4_16 ReadDecoder1(.RegId(SrcReg1), .Wordline(ReadEnable1));
    ReadDecoder_4_16 ReadDecoder2(.RegId(SrcReg2), .Wordline(ReadEnable2));
    WriteDecoder_4_16 WriteDecoder(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(WriteEnable));

    /**
     *  Implement register file internal bypassing (PHASE 2).
     */
    assign SrcData1 = (WriteReg & (DstReg == SrcReg1)) ? DstData : Bitline1;
    assign SrcData2 = (WriteReg & (DstReg == SrcReg2)) ? DstData : Bitline2;

    /**
     *  Instantiate 16 registers to make up the register file. Register 0 is
     *  the zero register that eats all writes, and always output 0.
     */
    Register Reg0  (.clk(clk), .rst(rst), .D(DstData), .WriteReg(1'b0),            .ReadEnable1(ReadEnable1[0]),  .ReadEnable2(ReadEnable2[0]),  .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg1  (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[1]),  .ReadEnable1(ReadEnable1[1]),  .ReadEnable2(ReadEnable2[1]),  .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg2  (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[2]),  .ReadEnable1(ReadEnable1[2]),  .ReadEnable2(ReadEnable2[2]),  .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg3  (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[3]),  .ReadEnable1(ReadEnable1[3]),  .ReadEnable2(ReadEnable2[3]),  .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg4  (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[4]),  .ReadEnable1(ReadEnable1[4]),  .ReadEnable2(ReadEnable2[4]),  .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg5  (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[5]),  .ReadEnable1(ReadEnable1[5]),  .ReadEnable2(ReadEnable2[5]),  .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg6  (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[6]),  .ReadEnable1(ReadEnable1[6]),  .ReadEnable2(ReadEnable2[6]),  .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg7  (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[7]),  .ReadEnable1(ReadEnable1[7]),  .ReadEnable2(ReadEnable2[7]),  .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg8  (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[8]),  .ReadEnable1(ReadEnable1[8]),  .ReadEnable2(ReadEnable2[8]),  .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg9  (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[9]),  .ReadEnable1(ReadEnable1[9]),  .ReadEnable2(ReadEnable2[9]),  .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg10 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[10]), .ReadEnable1(ReadEnable1[10]), .ReadEnable2(ReadEnable2[10]), .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg11 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[11]), .ReadEnable1(ReadEnable1[11]), .ReadEnable2(ReadEnable2[11]), .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg12 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[12]), .ReadEnable1(ReadEnable1[12]), .ReadEnable2(ReadEnable2[12]), .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg13 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[13]), .ReadEnable1(ReadEnable1[13]), .ReadEnable2(ReadEnable2[13]), .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg14 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[14]), .ReadEnable1(ReadEnable1[14]), .ReadEnable2(ReadEnable2[14]), .Bitline1(Bitline1), .Bitline2(Bitline2));
    Register Reg15 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteEnable[15]), .ReadEnable1(ReadEnable1[15]), .ReadEnable2(ReadEnable2[15]), .Bitline1(Bitline1), .Bitline2(Bitline2));

endmodule

/* Revert default net type after module to be wire. */
// wire
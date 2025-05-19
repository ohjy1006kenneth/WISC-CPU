/**
 *  Test bench for the top-level cpu. Custom test bench used to help
 *  development.
 */
module cpu_tb();

    /**
     *  Define CPU module inputs and outputs.
     */
    logic clk;                          // global clock
    logic rst_n;                          // Active high rest
    wire [15:0] PC;                     // Program counter
    wire Halt;                          // Halt signal

    /**
     *  Instantiate CPU module.
     */
    cpu DUT(.clk(clk), .rst_n(rst_n), .pc(PC), .hlt(Halt));

    /**
     *  Start test bench.
     */
    initial begin
        // Welcome display
        $display("Hello world...simulation starting");
        
        // Default signals and assert reset
        clk = 0;
        rst_n = 0;

        // Deassert reset on clock cycle after negative edge
        @(posedge clk);
        @(negedge clk) rst_n = 1;

        // Wait for posedge
        @(posedge clk);

        // printInstrMem();
        $display("ALUSrc1: 0x%x, ALUSrc2: 0x%x", DUT.ALUSrc1, DUT.ALUSrc2);

        // Finished test bench and exit
        $display("YAHOO! All tests passed!");
        $finish();
    end

    /**
     *  Clock period has period of 100 time units
     */
    always
        #5 clk = ~clk;

    task printInstrMem();
        begin
            for (integer i = 0 ; i < 10; i++) begin
                $display("ADDR 0x%x: 0x%x", i, DUT.InstrMem.mem[i]);
            end
        end
    endtask

endmodule
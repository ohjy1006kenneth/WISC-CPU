// none
module MemoryArbiter(
    input wire clk,
    input wire rst_n,

    // Interface with memory
    input wire data_valid, // Data valid signal from memory
    
    output wire MEM_EN, // Memory enable
    output wire WR, // Write/Read (1: Write, 0: Read)
    output wire [15:0] addr, // Address to memory

    // Interface with cache
    input wire DMEM_RE, // Read enable from data cache
    input wire DMEM_WE, // Write enable from data cache
    input wire IMEM_RE, // Read enable from instruction cache
    input wire [15:0] IMEM_MEM_addr, // Address from instruction cache
    input wire [15:0] DMEM_MEM_addr, // Address from data cache
    
    output wire IMEM_rdata_valid, 
    output wire DMEM_rdata_valid,
    output wire IMEM_wdone,
    output wire DMEM_wdone
);

    /**
     *  Define intermediate signals.
     */
    wire [1:0] curr_state;                // Current state (0: IDLE, 1: DMEM_READ, 2: IMEM_READ, 3: DMEM_WRITE)
    wire [1:0] next_state;                // Next State

    localparam IDLE = 2'b00;
    localparam DMEM_READ = 2'b01;
    localparam IMEM_READ = 2'b10;
    localparam DMEM_WRITE = 2'b11;

    // State Machine Register
    dff state [1:0] (.q(curr_state), .d(next_state), .wen(1'b1), .clk(clk), .rst(~rst_n));

    // State Transition Logic
    assign next_state = (curr_state==IDLE & data_valid) ? IDLE : 

                        ((curr_state == IDLE) & DMEM_RE) ? DMEM_READ :
                        ((curr_state == IDLE) & IMEM_RE & ~DMEM_RE) ? IMEM_READ :
                        ((curr_state == IDLE) & DMEM_WE & ~DMEM_RE & ~IMEM_RE) ? DMEM_WRITE :
                        ((curr_state == DMEM_READ) & ~DMEM_RE) ? IDLE :
                        ((curr_state == IMEM_READ) & ~IMEM_RE) ? IDLE :
                        (curr_state == DMEM_WRITE) ? IDLE : // Always take DMEM_WRITE to IDLE because writes take one cycle
                        curr_state; // Stay in current state otherwise
    

    // Memory Outputs
    assign MEM_EN = ~(curr_state == IDLE);
    assign WR = (curr_state == DMEM_WRITE) ? 1'b1 : 1'b0; // Write only in DMEM_WRITE state
    assign addr = (curr_state == DMEM_READ) ? DMEM_MEM_addr :
                  (curr_state == IMEM_READ) ? IMEM_MEM_addr :
                  (curr_state == DMEM_WRITE) ? DMEM_MEM_addr :
                  16'b0; // Default to 0 in IDLE state

    // Cache Outputs
    assign DMEM_rdata_valid = (curr_state == DMEM_READ) ? data_valid : 1'b0;
    assign IMEM_rdata_valid = (curr_state == IMEM_READ) ? data_valid : 1'b0;
    assign DMEM_wdone = (curr_state == DMEM_WRITE); // DMEM.wdone is high only in DMEM_WRITE state
    assign IMEM_wdone = 1'b0; // IMEM.wdone is not used in this design

endmodule

// wire

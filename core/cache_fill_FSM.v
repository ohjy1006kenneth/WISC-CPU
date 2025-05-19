// none
module cache_fill_FSM (
    input wire clk,
    input wire rst_n,

    input wire miss_detected,
    input wire[15:0] miss_address,

    output wire fsm_busy,
    output wire write_data_array,
    output wire write_tag_array,
    output wire[15:0] memory_address,
    output wire[2:0] write_block,
    output wire state,

    input wire[15:0] memory_data,
    input wire memory_data_valid,
    output wire[2:0] curblock
);

wire nextstate;
// 1 if the counter should tick up as needed
// 0 if the counter should hold at zero
wire counter_release;

wire[2:0] nxtblock;
wire[2:0] cb1, cb2, cb3, cb4;

wire sdl1, sdl2, sdl3, sdl4;

wire mdv1;
wire mdv2;
wire mdv3;

wire wda1, wda2, wda3, wda4;

wire write_data_array_old;
wire write_tag_array_old;
wire wta1, wta2, wta3, wta4;

// Store the state of the FSM
// 0 -> idle
// 1 -> wait
dff stateflop(
    .d(nextstate),
    .q(state),
    .wen(1'b1),
    .clk(clk),
    .rst(~rst_n)
);

dff sdlf1(.d(state),.q(sdl1),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff sdlf2(.d(sdl1),.q(sdl2),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff sdlf3(.d(sdl2),.q(sdl3),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff sdlf4(.d(sdl3),.q(sdl4),.wen(1'b1),.clk(clk),.rst(~rst_n));


// Pipeline to match memory

dff ff1(.d(memory_data_valid),.q(mdv1),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff ff2(.d(mdv1),.q(mdv2),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff ff3(.d(mdv2),.q(mdv3),.wen(1'b1),.clk(clk),.rst(~rst_n));


dff ff4(.d(write_data_array_old),.q(wda1),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff ff5(.d(wda1),.q(wda2),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff ff6(.d(wda2),.q(wda3),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff ff7(.d(wda3),.q(write_data_array),.wen(1'b1),.clk(clk),.rst(~rst_n));




// TODO rectify this
assign write_block = cb4;
//dff ff4(.d(mdv3),.q(mdv),.wen(1'b1),.clk(clk),.rst_n(rst_n));

// State transition logic
assign nextstate =
    ~state & miss_detected & ~sdl4 ? 1'b1 :                         // If in IDLE and miss detected, go to wait
    state & (curblock==7 && mdv3) ? 1'b0 :     // If in WAIT and we're done here, go to IDLE
    state;                                                  // Else remain
// Hold the block counter at zero when not in use.
// This means we're always ready to go
assign counter_release =
    write_data_array_old;                       // Miss or we're in wait


// We're busy if we are either trying to stall next cycle, or if we're
// currently stalled fetching stuff from memory
assign fsm_busy = miss_detected | state;
// Write to cache when we have received valid data, and we're in the WAIT
// state. Don't need to care about the original transition cause we're
// guaranteed to have four cycle latency. Meaning it'll come when we're
// waiting, and not a moment before
assign write_data_array_old = memory_data_valid & state;
// Write tag when we're moving back to the IDLE state. This means we're right
// about done writing all the blocks. Just one left, and it's being written
// now.
// Gotta pipeline this too

assign write_tag_array_old = state & ~nextstate;

dff ff9(.d(write_tag_array_old),.q(wta1),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff ffa(.d(wta1),.q(wta2),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff ffb(.d(wta2),.q(wta3),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff ffc(.d(wta3),.q(wta4),.wen(1'b1),.clk(clk),.rst(~rst_n));
assign write_tag_array = wta4;
wire[12:0] ___;
// Increments 0, 1, 2, 3, 4, 5, 6, 7 when mdv3 asserts
CLA_16bit rxcalc(.Sum({___,nxtblock}), .CarryOut(), .A({13'b0, curblock}), .B(16'b0), .CarryIn(memory_data_valid));
// Produces the address of the two byte block referred to by miss_address and
// curblock.
assign memory_address = {miss_address[15:4], curblock, 1'b0};
// Holds block that is being sent over
dff rxcnt[2:0] (
    .d(curblock == 3'h7 ? 3'h7 : nxtblock),
    .q(curblock),
    .wen(3'h7),
    .clk({3{clk}}),
    .rst({3{(~state & nextstate) | ~rst_n}})
);


dff rxcnta0[2:0] (
    .d(curblock),
    .q(cb1),
    .wen(3'h7),
    .clk({3{clk}}),
    .rst({3{~rst_n}})
);
dff rxcnt1[2:0] (
    .d(cb1),
    .q(cb2),
    .wen(3'h7),
    .clk({3{clk}}),
    .rst({3{~rst_n}})
);
dff rxcnt2[2:0] (
    .d(cb2),
    .q(cb3),
    .wen(3'h7),
    .clk({3{clk}}),
    .rst({3{~rst_n}})
);
dff rxcnt3[2:0] (
    .d(cb3),
    .q(cb4),
    .wen(3'h7),
    .clk({3{clk}}),
    .rst({3{~rst_n}})
);

endmodule
// wire

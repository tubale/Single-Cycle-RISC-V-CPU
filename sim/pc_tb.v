`timescale 1ns/1ps

module pc_tb;

reg clk;
reg rst;
reg [31:0] next_pc;

wire [31:0] pc;

// Instantiate DUT
pc dut (
    .clk(clk),
    .rst(rst),
    .next_pc(next_pc),
    .pc(pc)
);

// Clock Generation (10 ns period)
always #5 clk = ~clk;

initial begin
    // Generate waveform
    $dumpfile("wave.vcd");
    $dumpvars(0, pc_tb);

    // Print values whenever they change
    $monitor("Time=%0t | rst=%b | next_pc=%d | pc=%d",
             $time, rst, next_pc, pc);

    // Initialization
    clk = 0;
    rst = 1;
    next_pc = 32'd0;

    // Hold reset for one clock edge
    #10;

    // Release reset-
    rst = 0;

    // Test 1
    next_pc = 32'd4;
    #10;

    // Test 2
    next_pc = 32'd8;
    #10;

    // Test 3
    next_pc = 32'd12;
    #10;

    // Verify PC doesn't change between clock edges
    next_pc = 32'd100;
    #2;     // Before rising edge

    // At this point, pc should still be 12

    #8;     // Wait until next rising edge

    // Now pc should become 100

    // Test reset again
    rst = 1;
    #10;

    rst = 0;

    // Last test
    next_pc = 32'd20;
    #10;

    $finish;
end

endmodule
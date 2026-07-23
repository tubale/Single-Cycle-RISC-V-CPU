`timescale 1ns/1ps

module cpu_tb;

reg clk;
reg reset;

// Instantiate CPU
cpu dut(
    .clk(clk),
    .reset(reset)
);

// Clock generation
always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    $dumpfile("wave.vcd");
    $dumpvars(0, cpu_tb);

    // Hold reset
    #10;
    reset = 0;

    // Run long enough to execute every instruction
    #100;

    $finish;

end

endmodule
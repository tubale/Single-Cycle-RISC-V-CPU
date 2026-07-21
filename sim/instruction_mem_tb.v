`timescale 1ns/1ps

module instruction_mem_tb;

reg [31:0] address;
wire [31:0] instruction;

instruction_mem dut (
    .address(address),
    .instruction(instruction)
);

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, instruction_mem_tb);

    $monitor("Time=%0t | Address=%0d | Instruction=%h",
              $time, address, instruction);

    // Read instruction 0
    address = 32'd0;
    #10;

    // Read instruction 1
    address = 32'd4;
    #10;

    // Read instruction 2
    address = 32'd8;
    #10;

    // Read instruction 3
    address = 32'd12;
    #10;

    // Read instruction 4
    address = 32'd16;
    #10;

    // Read the last valid instruction
    address = 32'd252;
    #10;

    // Read outside initialized program
    address = 32'd256;
    #10;

    $finish;
end

endmodule
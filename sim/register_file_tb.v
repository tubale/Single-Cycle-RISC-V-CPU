`timescale 1ns/1ps

module register_file_tb;

reg clk;
reg reg_write;
reg [4:0] rs1;
reg [4:0] rs2;
reg [4:0] rd;
reg [31:0] write_data;

wire [31:0] read_data1;
wire [31:0] read_data2;

register_file dut (
    .clk(clk),
    .reg_write(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

// Clock generation
always #5 clk = ~clk;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, register_file_tb);

    clk = 0;
    reg_write = 0;
    rs1 = 0;
    rs2 = 0;
    rd = 0;
    write_data = 0;

    $monitor("Time=%0t | rs1=%0d data1=%0d | rs2=%0d data2=%0d | rd=%0d write=%0d reg_write=%b",
              $time, rs1, read_data1, rs2, read_data2,
              rd, write_data, reg_write);

    // -----------------------------
    // Test 1: Read x0
    // -----------------------------
    #10;
    rs1 = 0;
    rs2 = 0;

    // -----------------------------
    // Test 2: Write 42 to x5
    // -----------------------------
    #10;
    reg_write = 1;
    rd = 5;
    write_data = 32'd42;

    #10;
    reg_write = 0;

    // Read x5
    rs1 = 5;

    // -----------------------------
    // Test 3: Write 100 to x10
    // -----------------------------
    #10;
    reg_write = 1;
    rd = 10;
    write_data = 32'd100;

    #10;
    reg_write = 0;

    // Read x5 and x10 together
    rs1 = 5;
    rs2 = 10;

    // -----------------------------
    // Test 4: Attempt to write x0
    // -----------------------------
    #10;
    reg_write = 1;
    rd = 0;
    write_data = 32'd999;

    #10;
    reg_write = 0;

    rs1 = 0;

    // -----------------------------
    // Finish
    // -----------------------------
    #20;
    $finish;
end

endmodule
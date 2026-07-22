`timescale 1ns/1ps

module alu_tb;

reg  [31:0] a;
reg  [31:0] b;
reg  [3:0]  alu_control;

wire [31:0] result;
wire zero;

alu dut (
    .a(a),
    .b(b),
    .alu_control(alu_control),
    .result(result),
    .zero(zero)
);

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, alu_tb);


    // ---------------------------------
    // Test 1 : ADD (5 + 7 = 12)
    // ---------------------------------
    a = 32'd5;
    b = 32'd7;
    alu_control = 4'b0000;
    #10;

    // ---------------------------------
    // Test 2 : SUB (10 - 4 = 6)
    // ---------------------------------
    a = 32'd10;
    b = 32'd4;
    alu_control = 4'b0001;
    #10;

    // ---------------------------------
    // Test 3 : SUB (5 - 5 = 0)
    // Zero flag should be 1
    // ---------------------------------
    a = 32'd5;
    b = 32'd5;
    alu_control = 4'b0001;
    #10;

    // ---------------------------------
    // Test 4 : AND
    // 12 & 10 = 8
    // ---------------------------------
    a = 32'd12;
    b = 32'd10;
    alu_control = 4'b0010;
    #10;

    // ---------------------------------
    // Test 5 : OR
    // 12 | 10 = 14
    // ---------------------------------
    a = 32'd12;
    b = 32'd10;
    alu_control = 4'b0011;
    #10;

    // ---------------------------------
    // Test 6 : Default case
    // ---------------------------------
    a = 32'd100;
    b = 32'd50;
    alu_control = 4'b1111;
    #10;

    $finish;
end

endmodule
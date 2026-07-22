`timescale 1ns/1ps

module immediate_gen_tb;

reg  [31:0] instruction;
wire [31:0] immediate;

immediate_gen dut (
    .instruction(instruction),
    .immediate(immediate)
);

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, immediate_gen_tb);

    // -----------------------------
    // Test 1: addi x1, x0, 5
    // Expected immediate = 5
    // -----------------------------
    instruction = 32'h00500093;
    #10;

    // -----------------------------
    // Test 2: addi x2, x0, 7
    // Expected immediate = 7
    // -----------------------------
    instruction = 32'h00700113;
    #10;

    // -----------------------------
    // Test 3: addi x3, x0, -8
    // Expected immediate = -8
    // -----------------------------
    instruction = 32'hFF800193;
    #10;

    // -----------------------------
    // Test 4: addi x4, x0, -1
    // Expected immediate = -1
    // -----------------------------
    instruction = 32'hFFF00213;
    #10;

    // -----------------------------
    // Test 5: lw x5, 12(x2)
    // Expected immediate = 12
    // -----------------------------
    instruction = 32'h00C12283;
    #10;

    $finish;
end

endmodule
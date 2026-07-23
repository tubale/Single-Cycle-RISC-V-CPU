`timescale 1ns/1ps

module control_unit_tb;

reg [6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;

wire reg_write;
wire alu_src;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire branch;
wire [3:0] alu_control;

control_unit dut(
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),

    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .alu_control(alu_control)
);

initial begin

    $dumpfile("wave.vcd");
    $dumpvars(0, control_unit_tb);

    //=========================
    // ADD
    //=========================
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;

    //=========================
    // SUB
    //=========================
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0100000;
    #10;

    //=========================
    // AND
    //=========================
    opcode = 7'b0110011;
    funct3 = 3'b111;
    funct7 = 7'b0000000;
    #10;

    //=========================
    // OR
    //=========================
    opcode = 7'b0110011;
    funct3 = 3'b110;
    funct7 = 7'b0000000;
    #10;

    //=========================
    // ADDI
    //=========================
    opcode = 7'b0010011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;

    //=========================
    // LW
    //=========================
    opcode = 7'b0000011;
    funct3 = 3'b010;
    funct7 = 7'b0000000;
    #10;

    //=========================
    // SW
    //=========================
    opcode = 7'b0100011;
    funct3 = 3'b010;
    funct7 = 7'b0000000;
    #10;

    //=========================
    // BEQ
    //=========================
    opcode = 7'b1100011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;

    //=========================
    // Invalid Opcode
    //=========================
    opcode = 7'b1111111;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;

    $finish;

end

endmodule
module cpu(

    input clk,
    input reset

);
// Wires
// Program Counter
wire [31:0] pc;
wire [31:0] next_pc;

// Instruction Memory
wire [31:0] instruction;

// Register File
wire [31:0] read_data1;
wire [31:0] read_data2;
wire [31:0] write_back_data;

// Immediate Generator
wire [31:0] immediate;

// ALU
wire [31:0] alu_result;
wire zero;
wire [31:0] alu_input2;

// Data Memory
wire [31:0] memory_read_data;

// Control Signals
wire reg_write;
wire alu_src;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire branch;
wire [3:0] alu_control;
// Program Counter

pc pc_inst(
    .clk(clk),
    .rst(reset),
    .next_pc(next_pc),
    .pc(pc)
);

// Instruction Memory
instruction_mem imem(
    .address(pc),
    .instruction(instruction)
);

// Register File
register_file rf(
    .clk(clk),
    .reg_write(reg_write),
    .rs1(instruction[19:15]),
    .rs2(instruction[24:20]),
    .rd(instruction[11:7]),
    .write_data(write_back_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

// Immediate Generator
immediate_gen imm_gen(
    .instruction(instruction),
    .immediate(immediate)
);

// Control Unit
control_unit cu(
    .opcode(instruction[6:0]),
    .funct3(instruction[14:12]),
    .funct7(instruction[31:25]),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .alu_control(alu_control)
);

// ALU
alu alu_inst(
    .a(read_data1),
    .b(alu_input2),
    .alu_control(alu_control),
    .result(alu_result),
    .zero(zero)
);

// Data Memory
data_memory dmem(
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .address(alu_result),
    .write_data(read_data2),
    .read_data(memory_read_data)
);

assign alu_input2 = alu_src ? immediate : read_data2;
assign write_back_data = mem_to_reg ? memory_read_data : alu_result;
assign next_pc = pc + 32'd4;


endmodule
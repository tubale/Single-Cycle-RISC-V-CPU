module instruction_mem (
    input  [31:0] address,
    output [31:0] instruction
);

reg [31:0] memory [0:63];
wire [5:0] index;

assign index = address[7:2];
assign instruction = memory[index];

initial begin
    // Program:
    // addi x1, x0, 5
    // addi x2, x0, 7
    // add  x3, x1, x2
    // sw   x3, 0(x4)
    // lw   x5, 0(x4)

    memory[0] = 32'h00500093;
    memory[1] = 32'h00700113;
    memory[2] = 32'h002081B3;
    memory[3] = 32'h00322023;
    memory[4] = 32'h00022283;
end

endmodule
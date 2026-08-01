module instruction_mem (
    input  [31:0] address,
    output [31:0] instruction
);

reg [31:0] memory [0:255];
assign instruction = memory[address[9:2]];
integer i;

initial begin
    for(i = 0; i < 256; i = i + 1)
        memory[i] = 32'h00000013;   // NOP

    $readmemh("program.mem", memory);
    /* Sample adding things

    // Program:
    // addi x1, x0, 5
    // addi x2, x0, 7
    // add  x3, x1, x2
    // sw   x3, 0(x4)
    // lw   x5, 0(x4)

    // Testing R-Type instructions
    memory[0] = 32'h00500093;
    memory[1] = 32'h00700113;
    memory[2] = 32'h002081B3;
    memory[3] = 32'h00322023;
    memory[4] = 32'h00022283;
    memory[5] = 32'h00A00213; // addi x4, x0, 10
    memory[6] = 32'h00C00293; // addi x5, x0, 12
    memory[7] = 32'h00520333; // add  x6, x4, x5    
    memory[8] = 32'h003303B3; // add x7, x6, x3 


    // Testing I-Type instructions
    memory[0] = 32'h00A00093; // addi x1, x0, 10
    memory[1] = 32'h00C00113; // addi x2, x0, 12

    memory[2] = 32'h00A17193; // andi x3, x2, 10
    memory[3] = 32'h0040E213; // ori  x4, x1, 4
    memory[4] = 32'h0030C293; // xori x5, x1, 3
    memory[5] = 32'h0140A313; // slti x6, x1, 20

    // NOPs (No Operations)
    for (i = 6; i < 256; i = i + 1)
        memory[i] = 32'h00000013; // addi x0, x0, 0 

    //Testing BEQs
    memory[0] = 32'h00500093;   // addi x1, x0, 5
    memory[1] = 32'h00500113;   // addi x2, x0, 5
    memory[2] = 32'h00208463;   // beq  x1, x2, +8
    memory[3] = 32'h06300193;   // addi x3, x0, 99
    memory[4] = 32'h00100213;   // done: addi x4, x0, 1

    for (i = 5; i < 256; i = i + 1)
        memory[i] = 32'h00000013; // addi x0, x0, 0 

    // Testing BNE
    // addi x1, x0, 5
    memory[0] = 32'h00500093;
    // addi x2, x0, 6
    memory[1] = 32'h00600113;
    // bne x1, x2, done
    memory[2] = 32'h00209463;
    // addi x3, x0, 99 -> (should be skipped)
    memory[3] = 32'h06300193;
    // done:
    // addi x4, x0, 1
    memory[4] = 32'h00100213; 

    // Testing JAL
    // jal x1, target (+8 bytes)
    memory[0] = 32'h008000EF;
    // addi x2, x0, 99   (should be skipped)
    memory[1] = 32'h06300113;
    // target:
    // addi x3, x0, 5
    memory[2] = 32'h00500193; 

    // Testing JALR
    // addi x5, x0, 12
    memory[0] = 32'h00C00293;

    // jalr x1, x5, 0
    memory[1] = 32'h000280E7;

    // addi x2, x0, 99
    // (should be skipped)
    memory[2] = 32'h06300113;

    // target:
    // addi x3, x0, 5
    memory[3] = 32'h00500193; */
end

endmodule
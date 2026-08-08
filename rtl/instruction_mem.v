module instruction_mem (
    input  [31:0] address,
    output [31:0] instruction
);

    reg [31:0] memory [0:16383];

    assign instruction = memory[address[15:2]];
    

endmodule
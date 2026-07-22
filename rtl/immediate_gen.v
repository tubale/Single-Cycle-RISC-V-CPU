module immediate_gen(
    input  [31:0] instruction,
    output [31:0] immediate
);

assign immediate = {{20{instruction[31]}}, instruction[31:20]};

endmodule
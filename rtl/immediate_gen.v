module immediate_gen(
    input [31:0] instruction,
    output reg [31:0] immediate
);

wire [6:0] opcode = instruction[6:0];

always @(*) begin
    case (opcode)

        // I-Type
        7'b0010011,
        //Load (LW)
        7'b0000011:
            immediate = {{20{instruction[31]}}, instruction[31:20]};

        // S-Type
        7'b0100011:
            immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

        // B-Type
        7'b1100011:
            immediate = {{19{instruction[31]}},
                        instruction[31],      // imm[12]
                        instruction[7],       // imm[11]
                        instruction[30:25],   // imm[10:5]
                        instruction[11:8],    // imm[4:1]
                        1'b0};                // imm[0]
        // J-Type
        7'b1101111:
            immediate = {{11{instruction[31]}},
                 instruction[31],      // imm[20]
                 instruction[19:12],   // imm[19:12]
                 instruction[20],      // imm[11]
                 instruction[30:21],   // imm[10:1]
                 1'b0};                // imm[0]
        default:
            immediate = 32'd0;

    endcase
end

endmodule
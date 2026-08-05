module immediate_gen(
    input [31:0] instruction,
    output reg [31:0] immediate
);

wire [6:0] opcode = instruction[6:0];

always @(*) begin

    case (opcode)

        // I-Type Arithmetic / LW / JALR
        7'b0010011,
        7'b0000011,
        7'b1100111:
            immediate = {
                {20{instruction[31]}},
                instruction[31:20]
            };


        // S-Type (SW)
        7'b0100011:
            immediate = {
                {20{instruction[31]}},
                instruction[31:25],
                instruction[11:7]
            };


        // B-Type (BEQ / BNE)
        7'b1100011:
            immediate = {
                {19{instruction[31]}},
                instruction[31],
                instruction[7],
                instruction[30:25],
                instruction[11:8],
                1'b0
            };


        // J-Type (JAL)
        7'b1101111:
            immediate = {
                {11{instruction[31]}},
                instruction[31],
                instruction[19:12],
                instruction[20],
                instruction[30:21],
                1'b0
            };


        default:
            immediate = 32'd0;

    endcase

end

endmodule
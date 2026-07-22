module alu(
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0] alu_control,

    output reg [31:0] result,
    output zero
);

always @(*) begin 
    case(alu_control)
    4'b0000: result = a + b;
    4'b0001: result = a - b;
    4'b0010: result = a & b;
    4'b0011: result = a | b;
    default: result = 32'd0;
    endcase

end

assign zero = (result == 32'd0);

endmodule
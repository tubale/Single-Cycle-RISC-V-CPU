module register_file(
    input clk,

    input reg_write,

    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,

    input [31:0] write_data,

    output [31:0] read_data1,
    output [31:0] read_data2
);

reg [31:0] registers [0:31];

integer i;

initial begin
    for (i = 0; i < 32; i = i + 1)
        registers[i] = 32'd0;
end

always @(posedge clk) begin
    if (reg_write && (rd != 5'd0)) begin
        registers[rd] <= write_data;
    end
end

// Reading port 1 and 2
assign read_data1 = registers[rs1];
assign read_data2 = registers[rs2];

endmodule


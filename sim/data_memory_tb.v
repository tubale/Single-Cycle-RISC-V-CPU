`timescale 1ns/1ps

module data_memory_tb;

reg clk;

reg mem_read;
reg mem_write;

reg [31:0] address;
reg [31:0] write_data;

wire [31:0] read_data;

data_memory dut(
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .address(address),
    .write_data(write_data),
    .read_data(read_data)
);

// Clock generation
always #5 clk = ~clk;

initial begin

    clk = 0;

    mem_read = 0;
    mem_write = 0;
    address = 0;
    write_data = 0;

    $dumpfile("wave.vcd");
    $dumpvars(0, data_memory_tb);
    // Write 55 to address 0
    //=================================
    address = 32'd0;
    write_data = 32'd55;
    mem_write = 1;
    #10;

    mem_write = 0;

    // Read address 0
    mem_read = 1;
    #10;

    //=================================
    // Write 1234 to address 4
    //=================================
    mem_read = 0;

    address = 32'd4;
    write_data = 32'd1234;
    mem_write = 1;
    #10;

    mem_write = 0;

    // Read address 4
    mem_read = 1;
    #10;

    //=================================
    // Overwrite address 0 with 999
    //=================================
    mem_read = 0;

    address = 32'd0;
    write_data = 32'd999;
    mem_write = 1;
    #10;

    mem_write = 0;

    // Read address 0 again
    mem_read = 1;
    #10;

    //=================================
    // Disable reading
    //=================================
    mem_read = 0;
    #10;

    $finish;

end

endmodule
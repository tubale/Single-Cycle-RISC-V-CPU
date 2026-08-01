`timescale 1ns / 1ps

module cpu_tb;

    reg clk;
    reg reset;

    // Instantiate CPU
    cpu dut (
        .clk(clk),
        .reset(reset)
    );

    //----------------------------------------
    // Clock Generation (100 MHz)
    //----------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //----------------------------------------
    // Helper Task: Run N Clock Cycles
    //----------------------------------------
    task run_cycles;
        input integer cycles;
        integer i;
        begin
            for(i = 0; i < cycles; i = i + 1)
                @(posedge clk);
        end
    endtask

    //----------------------------------------
    // Helper Task: Check Register
    //----------------------------------------
    task check_register;
        input integer reg_num;
        input [31:0] expected;

        begin
            if(dut.rf.registers[reg_num] === expected)
                $display("PASS : x%0d = %h", reg_num, expected);
            else begin
                $display("--------------------------------");
                $display("FAIL : x%0d", reg_num);
                $display("Expected : %h", expected);
                $display("Actual   : %h",
                         dut.rf.registers[reg_num]);
                $display("--------------------------------");
                $finish;
            end
        end
    endtask

    //----------------------------------------
    // Main Test
    //----------------------------------------
    initial begin

        $display("");
        $display("==============================");
        $display("Starting CPU Test");
        $display("==============================");

        // Reset CPU
        reset = 1;
        run_cycles(2);
        reset = 0;

        // Give program time to execute
        run_cycles(10);

        //------------------------------------
        // Expected Register Values
        //------------------------------------

        check_register(1, 32'd5);
        check_register(2, 32'd7);
        check_register(3, 32'd12);

        $display("");
        $display("==============================");
        $display("TEST PASSED");
        $display("==============================");

        $finish;

    end

endmodule
`timescale 1ns / 1ps

module cpu_tb;

    reg clk;
    reg reset;

    integer i;


    // =========================================================
    // DUT
    // =========================================================

    cpu dut (
        .clk(clk),
        .reset(reset)
    );


    // =========================================================
    // Clock
    // 10 ns period = 100 MHz
    // =========================================================

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // =========================================================
    // Run N Cycles
    // =========================================================

    task run_cycles;

        input integer cycles;
        integer j;

        begin
            for (j = 0; j < cycles; j = j + 1)
                @(posedge clk);
        end

    endtask


    // =========================================================
    // Main Regression Simulation
    // =========================================================

    initial begin

        $display("");
        $display("========================================");
        $display("      RISC-V CPU Simulation");
        $display("========================================");


        // -----------------------------------------------------
        // Reset
        // -----------------------------------------------------

        reset = 1;


        // -----------------------------------------------------
        // Load regression program
        //
        // regression.py / runner.py creates program.mem
        // before each simulation.
        // -----------------------------------------------------

        $readmemh(
            "program.mem",
            dut.imem.memory
        );


        // -----------------------------------------------------
        // Hold reset for two cycles
        // -----------------------------------------------------

        run_cycles(2);

        reset = 0;


        // -----------------------------------------------------
        // Execute regression program
        // -----------------------------------------------------

        run_cycles(1000);


        // =====================================================
        // Register Dump
        // =====================================================

        $display("REGISTER_DUMP_BEGIN");

        for (i = 0; i < 32; i = i + 1)
            $display(
                "REG[%0d]=%08h",
                i,
                dut.rf.registers[i]
            );

        $display("REGISTER_DUMP_END");


        // =====================================================
        // Memory Dump
        // =====================================================

        $display("MEMORY_DUMP_BEGIN");

        for (i = 0; i < 256; i = i + 1)
            $display(
                "MEM[%0d]=%08h",
                i,
                dut.dmem.memory[i]
            );

        $display("MEMORY_DUMP_END");


        // =====================================================
        // Finish
        // =====================================================

        $display("SIMULATION_COMPLETE");

        $finish;

    end

endmodule
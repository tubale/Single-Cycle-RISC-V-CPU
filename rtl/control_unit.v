module control_unit(

    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg reg_write,
    output reg alu_src,
    output reg mem_read,
    output reg mem_write,
    output reg [1:0] wb_select,
    output reg [1:0] branch_type,
    output reg jump,
    output reg [3:0] alu_control,
    output reg jalr

);

always @(*) begin

    // Default values
    reg_write   = 0;
    alu_src     = 0;
    mem_read    = 0;
    mem_write   = 0;
    wb_select   = 2'b00;    // ALU
    branch_type = 2'b00;
    jump        = 1'b0;
    jalr        = 1'b0;
    alu_control = 4'b0000;

    case(opcode)

        // R-Type Instructions
        7'b0110011: begin

            reg_write  = 1;
            alu_src    = 0;
            wb_select  = 2'b00;

            case(funct3)

                // ADD / SUB
                3'b000: begin
                    if(funct7 == 7'b0000000)
                        alu_control = 4'b0000;   // ADD
                    else if(funct7 == 7'b0100000)
                        alu_control = 4'b0001;   // SUB
                end

                // AND
                3'b111:
                    alu_control = 4'b0010;

                // OR
                3'b110:
                    alu_control = 4'b0011;

                // XOR
                3'b100:
                    alu_control = 4'b0100;

                // SLT
                3'b010:
                    alu_control = 4'b0101;

                default:
                    alu_control = 4'b0000;

            endcase

        end

        // I-Type Arithmetic
        7'b0010011: begin

            reg_write   = 1;
            alu_src     = 1;
            wb_select   = 2'b00;

            case(funct3)

                3'b000:
                    alu_control = 4'b0000; // ADDI

                3'b010:
                    alu_control = 4'b0101; // SLTI

                3'b100:
                    alu_control = 4'b0100; // XORI

                3'b110:
                    alu_control = 4'b0011; // ORI

                3'b111:
                    alu_control = 4'b0010; // ANDI

                default:
                    alu_control = 4'b0000;

            endcase

        end

        // LW
        7'b0000011: begin

            reg_write   = 1;
            alu_src     = 1;
            mem_read    = 1;
            wb_select   = 2'b01;    // Memory
            alu_control = 4'b0000;

        end

        // SW
        7'b0100011: begin

            alu_src     = 1;
            mem_write   = 1;
            wb_select   = 2'b00;    // Doesn't matter
            alu_control = 4'b0000;

        end

        // BEQ / BNE
        7'b1100011: begin

            alu_src     = 0;
            wb_select   = 2'b00;    // Doesn't matter
            alu_control = 4'b0001;  // SUB

            case(funct3)

                3'b000:
                    branch_type = 2'b01; // BEQ

                3'b001:
                    branch_type = 2'b10; // BNE

                default:
                    branch_type = 2'b00;

            endcase

        end
        // J type
        // JAL
        7'b1101111: begin
            jump       = 1'b1;
            reg_write  = 1'b1;
            wb_select  = 2'b10;   // Write PC+4
            jalr       = 1'b0;
        end

        // I-Type
        // JALR
        7'b1100111: begin
            reg_write   = 1'b1;
            jump        = 1'b1;
            alu_src     = 1'b1;
            wb_select   = 2'b10;
            jalr        = 1'b1;
        end

    endcase

end

endmodule
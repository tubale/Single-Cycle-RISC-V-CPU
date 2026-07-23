module control_unit(

    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg reg_write,
    output reg alu_src,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg branch,
    output reg [3:0] alu_control

);

always @(*) begin

    // Default values
    reg_write   = 0;
    alu_src     = 0;
    mem_read    = 0;
    mem_write   = 0;
    mem_to_reg  = 0;
    branch      = 0;
    alu_control = 4'b0000;

    case(opcode)

        //=========================
        // R-Type Instructions
        //=========================
        7'b0110011: begin

            reg_write  = 1;
            alu_src    = 0;
            mem_to_reg = 0;

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

                default:
                    alu_control = 4'b0000;

            endcase
        end

        //=========================
        // ADDI
        //=========================
        7'b0010011: begin

            reg_write   = 1;
            alu_src     = 1;
            alu_control = 4'b0000;

        end

        //=========================
        // LW
        //=========================
        7'b0000011: begin

            reg_write   = 1;
            alu_src     = 1;
            mem_read    = 1;
            mem_to_reg  = 1;
            alu_control = 4'b0000;

        end

        //=========================
        // SW
        //=========================
        7'b0100011: begin

            reg_write   = 0;
            alu_src     = 1;
            mem_write   = 1;
            alu_control = 4'b0000;

        end

        //=========================
        // BEQ
        //=========================
        7'b1100011: begin

            branch      = 1;
            alu_src     = 0;
            alu_control = 4'b0001;   // SUB

        end

    endcase

end

endmodule
"""
encoder.py

RV32I Instruction Encoder
Supports:
R-Type
I-Type
LW
SW
BEQ
BNE
JAL
JALR
"""

# ==========================================================
# Opcodes
# ==========================================================

R_TYPE = 0b0110011
I_TYPE = 0b0010011
LOAD   = 0b0000011
STORE  = 0b0100011
BRANCH = 0b1100011
JAL    = 0b1101111
JALR   = 0b1100111


# ==========================================================
# Helper
# ==========================================================

def hex32(value):
    return f"{value & 0xFFFFFFFF:08X}"


# ==========================================================
# Generic Encoders
# ==========================================================

def encode_r_type(funct7, rs2, rs1, funct3, rd, opcode=R_TYPE):

    instruction = (
        (funct7 << 25) |
        (rs2    << 20) |
        (rs1    << 15) |
        (funct3 << 12) |
        (rd     << 7 ) |
        opcode
    )

    return hex32(instruction)


def encode_i_type(imm, rs1, funct3, rd, opcode):

    imm &= 0xFFF

    instruction = (
        (imm    << 20) |
        (rs1    << 15) |
        (funct3 << 12) |
        (rd     << 7 ) |
        opcode
    )

    return hex32(instruction)


def encode_s_type(imm, rs2, rs1, funct3):

    imm &= 0xFFF

    imm_11_5 = (imm >> 5) & 0x7F
    imm_4_0  = imm & 0x1F

    instruction = (
        (imm_11_5 << 25) |
        (rs2      << 20) |
        (rs1      << 15) |
        (funct3   << 12) |
        (imm_4_0  << 7 ) |
        STORE
    )

    return hex32(instruction)


def encode_b_type(offset, rs2, rs1, funct3):

    offset &= 0x1FFF

    imm12   = (offset >> 12) & 1
    imm11   = (offset >> 11) & 1
    imm10_5 = (offset >> 5) & 0x3F
    imm4_1  = (offset >> 1) & 0xF

    instruction = (
        (imm12   << 31) |
        (imm10_5 << 25) |
        (rs2     << 20) |
        (rs1     << 15) |
        (funct3  << 12) |
        (imm4_1  << 8 ) |
        (imm11   << 7 ) |
        BRANCH
    )

    return hex32(instruction)


def encode_j_type(offset, rd):

    offset &= 0x1FFFFF

    imm20    = (offset >> 20) & 1
    imm10_1  = (offset >> 1) & 0x3FF
    imm11    = (offset >> 11) & 1
    imm19_12 = (offset >> 12) & 0xFF

    instruction = (
        (imm20    << 31) |
        (imm19_12 << 12) |
        (imm11    << 20) |
        (imm10_1  << 21) |
        (rd        << 7) |
        JAL
    )

    return hex32(instruction)


# ==========================================================
# R-Type
# ==========================================================

def encode_add(rd, rs1, rs2):
    return encode_r_type(0b0000000, rs2, rs1, 0b000, rd)


def encode_sub(rd, rs1, rs2):
    return encode_r_type(0b0100000, rs2, rs1, 0b000, rd)


def encode_and(rd, rs1, rs2):
    return encode_r_type(0b0000000, rs2, rs1, 0b111, rd)


def encode_or(rd, rs1, rs2):
    return encode_r_type(0b0000000, rs2, rs1, 0b110, rd)


def encode_xor(rd, rs1, rs2):
    return encode_r_type(0b0000000, rs2, rs1, 0b100, rd)


def encode_slt(rd, rs1, rs2):
    return encode_r_type(0b0000000, rs2, rs1, 0b010, rd)


# ==========================================================
# I-Type Arithmetic
# ==========================================================

def encode_addi(rd, rs1, imm):
    return encode_i_type(imm, rs1, 0b000, rd, I_TYPE)


def encode_slti(rd, rs1, imm):
    return encode_i_type(imm, rs1, 0b010, rd, I_TYPE)


def encode_xori(rd, rs1, imm):
    return encode_i_type(imm, rs1, 0b100, rd, I_TYPE)


def encode_ori(rd, rs1, imm):
    return encode_i_type(imm, rs1, 0b110, rd, I_TYPE)


def encode_andi(rd, rs1, imm):
    return encode_i_type(imm, rs1, 0b111, rd, I_TYPE)


# ==========================================================
# Memory
# ==========================================================

def encode_lw(rd, rs1, imm):
    return encode_i_type(imm, rs1, 0b010, rd, LOAD)


def encode_sw(rs2, rs1, imm):
    return encode_s_type(imm, rs2, rs1, 0b010)


# ==========================================================
# Branches
# ==========================================================

def encode_beq(rs1, rs2, offset):
    return encode_b_type(offset, rs2, rs1, 0b000)


def encode_bne(rs1, rs2, offset):
    return encode_b_type(offset, rs2, rs1, 0b001)


# ==========================================================
# Jumps
# ==========================================================

def encode_jal(rd, offset):
    return encode_j_type(offset, rd)


def encode_jalr(rd, rs1, imm):
    return encode_i_type(imm, rs1, 0b000, rd, JALR)


# ==========================================================
# Write Program
# ==========================================================

def write_program(instructions, filename="program.mem"):

    with open(filename, "w") as f:
        for inst in instructions:
            f.write(inst + "\n")


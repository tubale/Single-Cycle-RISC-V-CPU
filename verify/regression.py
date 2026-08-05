from encoder import *
from runner import *

import random
import time

NUM_TESTS = 100


############################################################
# Generic R-Type Regression
############################################################

def run_rtype_regression(name, encoder, operation):

    print()
    print("=" * 70)
    print(f"Running {name} Regression")
    print("=" * 70)

    compile_cpu()

    program = []
    expected = []

    # x31 = base pointer
    program.append(encode_addi(31, 0, 0))

    offset = 0

    for _ in range(NUM_TESTS):

        a = random.randint(-2048, 2047)
        b = random.randint(-2048, 2047)

        expected.append(operation(a, b) & 0xFFFFFFFF)

        program.extend([

            encode_addi(1, 0, a),
            encode_addi(2, 0, b),

            encoder(3, 1, 2),

            encode_sw(3, 31, offset)

        ])

        offset += 4

    # NOPs
    for _ in range(20):
        program.append(encode_addi(0, 0, 0))

    start = time.perf_counter()

    registers, memory = run_cpu(program)

    runtime = time.perf_counter() - start

    passed = 0

    for i in range(NUM_TESTS):

        if memory[i] == expected[i]:

            passed += 1

        else:

            print()
            print(f"{name} FAILED")

            print(f"Test #{i+1}")

            print(f"Expected : {expected[i]:08X}")
            print(f"Actual   : {memory[i]:08X}")

            break

    print()

    print(f"{name}: {passed}/{NUM_TESTS} PASS")

    print(f"Runtime : {runtime:.3f} sec")

    return passed == NUM_TESTS


############################################################
# ADD
############################################################

def run_add():

    return run_rtype_regression(

        "ADD",

        encode_add,

        lambda a, b: a + b

    )


############################################################
# SUB
############################################################

def run_sub():

    return run_rtype_regression(

        "SUB",

        encode_sub,

        lambda a, b: a - b

    )


############################################################
# AND
############################################################

def run_and():

    return run_rtype_regression(

        "AND",

        encode_and,

        lambda a, b: a & b

    )
############################################################
# OR
############################################################

def run_or():

    return run_rtype_regression(

        "OR",

        encode_or,

        lambda a, b: a | b

    )


############################################################
# XOR
############################################################

def run_xor():

    return run_rtype_regression(

        "XOR",

        encode_xor,

        lambda a, b: a ^ b

    )


############################################################
# SLT
############################################################

def run_slt():

    def slt(a, b):

        # Signed comparison
        return 1 if a < b else 0

    return run_rtype_regression(

        "SLT",

        encode_slt,

        slt

    )
############################################################
# Generic I-Type Regression
############################################################

def run_itype_regression(name, encoder, operation):

    print()
    print("=" * 70)
    print(f"Running {name} Regression")
    print("=" * 70)

    program = []
    expected = []

    # x31 = base address for storing results
    program.append(encode_addi(31, 0, 0))

    offset = 0

    for _ in range(NUM_TESTS):

        # rs1 must be loadable with ADDI
        a = random.randint(-2048, 2047)

        # immediate is 12-bit signed
        imm = random.randint(-2048, 2047)

        expected.append(operation(a, imm) & 0xFFFFFFFF)

        program.extend([
            encode_addi(1, 0, a),
            encoder(3, 1, imm),
            encode_sw(3, 31, offset)
        ])

        offset += 4

    for _ in range(20):
        program.append(encode_addi(0, 0, 0))

    start = time.perf_counter()

    registers, memory = run_cpu(program)

    runtime = time.perf_counter() - start

    passed = 0

    for i in range(NUM_TESTS):

        if memory[i] == expected[i]:
            passed += 1

        else:
            print()
            print(f"{name} FAILED")
            print(f"Test #{i + 1}")
            print(f"Expected : {expected[i]:08X}")
            print(f"Actual   : {memory[i]:08X}")
            break

    print()
    print(f"{name}: {passed}/{NUM_TESTS} PASS")
    print(f"Runtime : {runtime:.3f} sec")

    return passed == NUM_TESTS


############################################################
# I-Type Instructions
############################################################

def run_addi():

    return run_itype_regression(
        "ADDI",
        encode_addi,
        lambda a, imm: a + imm
    )


def run_andi():

    return run_itype_regression(
        "ANDI",
        encode_andi,
        lambda a, imm: a & imm
    )


def run_ori():

    return run_itype_regression(
        "ORI",
        encode_ori,
        lambda a, imm: a | imm
    )


def run_xori():

    return run_itype_regression(
        "XORI",
        encode_xori,
        lambda a, imm: a ^ imm
    )


def run_slti():

    return run_itype_regression(
        "SLTI",
        encode_slti,
        lambda a, imm: 1 if a < imm else 0
    )


############################################################
# SW Regression
############################################################

def run_sw():

    print()
    print("=" * 70)
    print("Running SW Regression")
    print("=" * 70)

    program = []
    expected = []

    # Base address = 0
    program.append(encode_addi(31, 0, 0))

    offset = 0

    for _ in range(NUM_TESTS):

        value = random.randint(-2048, 2047)

        expected.append(value & 0xFFFFFFFF)

        program.extend([
            encode_addi(1, 0, value),
            encode_sw(1, 31, offset)
        ])

        offset += 4

    for _ in range(20):
        program.append(encode_addi(0, 0, 0))

    start = time.perf_counter()

    registers, memory = run_cpu(program)

    runtime = time.perf_counter() - start

    passed = 0

    for i in range(NUM_TESTS):

        if memory[i] == expected[i]:
            passed += 1
        else:
            print()
            print("SW FAILED")
            print(f"Test #{i + 1}")
            print(f"Expected : {expected[i]:08X}")
            print(f"Actual   : {memory[i]:08X}")
            break

    print()
    print(f"SW: {passed}/{NUM_TESTS} PASS")
    print(f"Runtime : {runtime:.3f} sec")

    return passed == NUM_TESTS


############################################################
# LW Regression
############################################################

def run_lw():

    print()
    print("=" * 70)
    print("Running LW Regression")
    print("=" * 70)

    program = []
    expected = []

    # x31 = base address 0
    program.append(encode_addi(31, 0, 0))

    # ------------------------------------------------------
    # Step 1: Store random values into memory[0..9]
    # ------------------------------------------------------

    for i in range(NUM_TESTS):

        value = random.randint(-2048, 2047)

        expected.append(value & 0xFFFFFFFF)

        program.extend([
            encode_addi(1, 0, value),
            encode_sw(1, 31, i * 4)
        ])

    # ------------------------------------------------------
    # Step 2: Load values back
    #
    # Store loaded results into memory[16..25]
    # ------------------------------------------------------

    result_base = 512

    for i in range(NUM_TESTS):

        program.extend([

            # Load original value
            encode_lw(2, 31, i * 4),

            # NOP
            encode_addi(0, 0, 0),

            # Store loaded value
            encode_sw(
                2,
                31,
                result_base + (i * 4)
            )

        ])

    # ------------------------------------------------------
    # NOP padding
    # ------------------------------------------------------

    for _ in range(20):

        program.append(
            encode_addi(0, 0, 0)
        )

    # ------------------------------------------------------
    # Run CPU
    # ------------------------------------------------------

    start = time.perf_counter()

    registers, memory = run_cpu(program)

    runtime = time.perf_counter() - start

    # ------------------------------------------------------
    # Verify
    # ------------------------------------------------------

    passed = 0

    result_index = result_base // 4

    for i in range(NUM_TESTS):

        actual = memory[result_index + i]

        if actual == expected[i]:

            passed += 1

        else:

            print()
            print("LW FAILED")
            print("-" * 50)

            print(f"Test #{i + 1}")

            print()
            print(f"Expected : {expected[i]:08X}")
            print(f"Actual   : {actual:08X}")

            print()
            print(
                f"Original memory[{i}] = "
                f"{memory[i]:08X}"
            )

            print(
                f"Result memory[{result_index + i}] = "
                f"{actual:08X}"
            )

            break

    print()
    print(f"LW: {passed}/{NUM_TESTS} PASS")
    print(f"Runtime : {runtime:.3f} sec")

    return passed == NUM_TESTS

############################################################
# BEQ Regression
############################################################

def run_beq():

    print()
    print("=" * 70)
    print("Running BEQ Regression")
    print("=" * 70)

    program = []

    # x31 = data-memory base
    program.append(encode_addi(31, 0, 0))

    expected = []

    for i in range(NUM_TESTS):

        value = random.randint(-1000, 1000)

        # Alternate taken / not taken
        taken = (i % 2 == 0)

        if taken:
            a = value
            b = value
        else:
            a = value
            b = value + 1

        expected.append(1 if taken else 0)

        # Layout:
        #
        # addi x1,a
        # addi x2,b
        # addi x3,0
        # beq x1,x2,+8
        # jal x0,+8
        # addi x3,x0,1
        # sw x3,...
        #
        # If taken -> x3 becomes 1
        # If not -> JAL skips setting x3

        program.extend([
            encode_addi(1, 0, a),
            encode_addi(2, 0, b),
            encode_addi(3, 0, 0),

            encode_beq(1, 2, 8),

            encode_jal(0, 8),

            encode_addi(3, 0, 1),

            encode_sw(3, 31, i * 4)
        ])

    # Branch programs are longer than ALU tests.
    # cpu_tb must run enough cycles for this regression.

    for _ in range(20):
        program.append(encode_addi(0, 0, 0))

    start = time.perf_counter()

    registers, memory = run_cpu(program)

    runtime = time.perf_counter() - start

    passed = 0

    for i in range(NUM_TESTS):

        if memory[i] == expected[i]:
            passed += 1
        else:
            print()
            print("BEQ FAILED")
            print(f"Test #{i + 1}")
            print(f"Expected : {expected[i]:08X}")
            print(f"Actual   : {memory[i]:08X}")
            break

    print()
    print(f"BEQ: {passed}/{NUM_TESTS} PASS")
    print(f"Runtime : {runtime:.3f} sec")

    return passed == NUM_TESTS


############################################################
# BNE Regression
############################################################

def run_bne():

    print()
    print("=" * 70)
    print("Running BNE Regression")
    print("=" * 70)

    program = []

    program.append(encode_addi(31, 0, 0))

    expected = []

    for i in range(NUM_TESTS):

        value = random.randint(-1000, 1000)

        taken = (i % 2 == 0)

        if taken:
            a = value
            b = value + 1
        else:
            a = value
            b = value

        expected.append(1 if taken else 0)

        program.extend([
            encode_addi(1, 0, a),
            encode_addi(2, 0, b),
            encode_addi(3, 0, 0),

            encode_bne(1, 2, 8),

            encode_jal(0, 8),

            encode_addi(3, 0, 1),

            encode_sw(3, 31, i * 4)
        ])

    for _ in range(20):
        program.append(encode_addi(0, 0, 0))

    start = time.perf_counter()

    registers, memory = run_cpu(program)

    runtime = time.perf_counter() - start

    passed = 0

    for i in range(NUM_TESTS):

        if memory[i] == expected[i]:
            passed += 1
        else:
            print()
            print("BNE FAILED")
            print(f"Test #{i + 1}")
            print(f"Expected : {expected[i]:08X}")
            print(f"Actual   : {memory[i]:08X}")
            break

    print()
    print(f"BNE: {passed}/{NUM_TESTS} PASS")
    print(f"Runtime : {runtime:.3f} sec")

    return passed == NUM_TESTS


############################################################
# JAL Regression
############################################################

def run_jal():

    print()
    print("=" * 70)
    print("Running JAL Regression")
    print("=" * 70)

    program = []

    program.append(encode_addi(31, 0, 0))

    expected = []

    for i in range(NUM_TESTS):

        # Every test uses:
        #
        # jal x1,+8
        # addi x3,x0,99       <- skipped
        # addi x3,x0,1
        # sw x3,...
        #
        # We verify the jump happened.
        #
        # Link-register checking is handled separately below.

        program.extend([
            encode_jal(1, 8),
            encode_addi(3, 0, 99),
            encode_addi(3, 0, 1),
            encode_sw(3, 31, i * 4)
        ])

        expected.append(1)

    for _ in range(20):
        program.append(encode_addi(0, 0, 0))

    start = time.perf_counter()

    registers, memory = run_cpu(program)

    runtime = time.perf_counter() - start

    passed = 0

    for i in range(NUM_TESTS):

        if memory[i] == expected[i]:
            passed += 1
        else:
            print()
            print("JAL FAILED")
            print(f"Test #{i + 1}")
            print("Expected jump result : 00000001")
            print(f"Actual               : {memory[i]:08X}")
            break

    print()
    print(f"JAL: {passed}/{NUM_TESTS} PASS")
    print(f"Runtime : {runtime:.3f} sec")

    return passed == NUM_TESTS


############################################################
# JALR Regression
############################################################

def run_jalr():

    print()
    print("=" * 70)
    print("Running JALR Regression")
    print("=" * 70)

    program = []

    program.append(encode_addi(31, 0, 0))

    expected = []

    #
    # JALR is easier to verify with one controlled jump chain.
    #
    # PC values:
    #
    # 0  : addi x31
    # 4  : addi x5, x0, 16
    # 8  : jalr x1, x5, 0
    # 12 : addi x3, x0, 99   <- skipped
    # 16 : addi x3, x0, 1
    # 20 : sw x3, 0(x31)
    #

    program.extend([
        encode_addi(5, 0, 16),
        encode_jalr(1, 5, 0),
        encode_addi(3, 0, 99),
        encode_addi(3, 0, 1),
        encode_sw(3, 31, 0)
    ])

    for _ in range(20):
        program.append(encode_addi(0, 0, 0))

    start = time.perf_counter()

    registers, memory = run_cpu(program)

    runtime = time.perf_counter() - start

    # JALR is at PC = 8
    # Therefore x1 should receive PC + 4 = 12.

    jump_ok = memory[0] == 1
    link_ok = registers[1] == 12

    passed = jump_ok and link_ok

    if not jump_ok:
        print()
        print("JALR jump target FAILED")
        print("Expected memory[0] : 00000001")
        print(f"Actual             : {memory[0]:08X}")

    if not link_ok:
        print()
        print("JALR link register FAILED")
        print("Expected x1 : 0000000C")
        print(f"Actual x1   : {registers[1]:08X}")

    print()

    if passed:
        print("JALR: PASS")
    else:
        print("JALR: FAIL")

    print(f"Runtime : {runtime:.3f} sec")

    return passed
############################################################
# Main
############################################################

def main():

    print()
    print("=" * 70)
    print("RV32I CPU REGRESSION")
    print("=" * 70)

    compile_cpu()

    total_start = time.perf_counter()

    results = []

    # R-Type
    results.append(("ADD",  run_add(),  NUM_TESTS))
    results.append(("SUB",  run_sub(),  NUM_TESTS))
    results.append(("AND",  run_and(),  NUM_TESTS))
    results.append(("OR",   run_or(),   NUM_TESTS))
    results.append(("XOR",  run_xor(),  NUM_TESTS))
    results.append(("SLT",  run_slt(),  NUM_TESTS))

    # I-Type
    results.append(("ADDI", run_addi(), NUM_TESTS))
    results.append(("ANDI", run_andi(), NUM_TESTS))
    results.append(("ORI",  run_ori(),  NUM_TESTS))
    results.append(("XORI", run_xori(), NUM_TESTS))
    results.append(("SLTI", run_slti(), NUM_TESTS))

    # Memory
    results.append(("SW", run_sw(), NUM_TESTS))
    results.append(("LW", run_lw(), NUM_TESTS))

    # Branch
    results.append(("BEQ", run_beq(), NUM_TESTS))
    results.append(("BNE", run_bne(), NUM_TESTS))

    # Jump
    results.append(("JAL",  run_jal(),  NUM_TESTS))

    # Current JALR regression is one controlled test
    results.append(("JALR", run_jalr(), 1))

    total_runtime = time.perf_counter() - total_start


    ########################################################
    # Summary
    ########################################################

    print()
    print("=" * 70)
    print("FINAL REGRESSION SUMMARY")
    print("=" * 70)

    instructions_passed = 0
    tests_passed = 0
    total_tests = 0

    for name, result, test_count in results:

        total_tests += test_count

        if result:

            print(f"{name:<5} : PASS")

            instructions_passed += 1
            tests_passed += test_count

        else:

            print(f"{name:<5} : FAIL")

    print()
    print("-" * 70)

    print(
        f"Instructions Passed : "
        f"{instructions_passed}/{len(results)}"
    )

    print(
        f"Tests Passed        : "
        f"{tests_passed}/{total_tests}"
    )

    print(
        f"Total Runtime       : "
        f"{total_runtime:.3f} sec"
    )

    print("-" * 70)

    if instructions_passed == len(results):

        print()
        print(
            f"ALL TESTS PASSED "
            f"({tests_passed}/{total_tests})"
        )

    else:

        print()
        print("REGRESSION FAILED")

    print("=" * 70)


if __name__ == "__main__":
    main()
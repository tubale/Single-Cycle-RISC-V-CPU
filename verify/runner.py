# runner.py

import subprocess
import re


# ==========================================================
# Compile CPU
# ==========================================================

def compile_cpu():

    print("Compiling CPU...")

    result = subprocess.run(
        ["make"],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:

        print(result.stdout)
        print(result.stderr)

        raise RuntimeError("Compilation failed.")


# ==========================================================
# Write program.mem
# ==========================================================

def write_program(program):

    with open("program.mem", "w") as f:

        for instruction in program:
            f.write(instruction + "\n")


# ==========================================================
# Parse Register Dump
# ==========================================================

def parse_registers(output):

    registers = [0] * 32

    inside = False

    for line in output.splitlines():

        line = line.strip()

        if line == "REGISTER_DUMP_BEGIN":
            inside = True
            continue

        if line == "REGISTER_DUMP_END":
            break

        if inside:

            match = re.match(
                r"REG\[(\d+)\]=([0-9A-Fa-f]{8})",
                line
            )

            if match:

                reg = int(match.group(1))
                value = int(match.group(2), 16)

                registers[reg] = value

    return registers


# ==========================================================
# Parse Memory Dump
# ==========================================================

def parse_memory(output):

    # 256 words to match data_memory.v
    memory = [0] * 256

    inside = False

    for line in output.splitlines():

        line = line.strip()

        if line == "MEMORY_DUMP_BEGIN":
            inside = True
            continue

        if line == "MEMORY_DUMP_END":
            break

        if inside:

            match = re.match(
                r"MEM\[(\d+)\]=([0-9A-Fa-fxX]{8})",
                line
            )

            if match:

                index = int(match.group(1))
                value_string = match.group(2)

                # Unknown/uninitialized memory
                if "x" in value_string.lower():
                    memory[index] = 0

                else:
                    memory[index] = int(
                        value_string,
                        16
                    )

    return memory


# ==========================================================
# Run CPU
# ==========================================================

def run_cpu(program):

    write_program(program)

    result = subprocess.run(
        ["vvp", "sim.out"],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:

        print(result.stdout)
        print(result.stderr)

        raise RuntimeError("Simulation failed.")

    registers = parse_registers(result.stdout)
    memory = parse_memory(result.stdout)

    return registers, memory


# ==========================================================
# Run CPU (Verbose)
# ==========================================================

def run_cpu_verbose(program):

    write_program(program)

    result = subprocess.run(
        ["vvp", "sim.out"],
        capture_output=True,
        text=True
    )
    if result.returncode != 0:

        raise RuntimeError("Simulation failed.")

    registers = parse_registers(result.stdout)
    memory = parse_memory(result.stdout)

    return registers, memory

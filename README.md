# 32-bit Single-Cycle RISC-V (RV32I) CPU

A 32-bit **single-cycle RISC-V processor** designed from scratch in **Verilog HDL**. The CPU implements 17 RV32I instructions spanning arithmetic, logical, memory, branch, and jump operations.

The processor was developed as a complete RTL design project: individual hardware modules were implemented and integrated into a single-cycle datapath, verified through automated randomized regression testing and GTKWave waveform analysis, and synthesized using Yosys to inspect the resulting hardware structures.

---

## Overview

The processor executes each instruction in a single clock cycle through the complete:

**Fetch → Decode → Execute → Memory → Write-Back**

datapath.

The design includes:

- 32-bit Program Counter
- Instruction Memory
- 32 × 32-bit Register File
- Immediate Generator
- Control Unit
- Arithmetic Logic Unit
- Data Memory
- Branch Decision Logic
- Jump / Jump-Register Logic
- ALU Input Multiplexer
- Write-Back Multiplexer
- Next-PC Selection Logic

The CPU supports register-register operations, immediate arithmetic, memory access, conditional branches, and control-flow instructions.

---

## Processor Architecture

```text
                         ┌──────────────────┐
                         │ Program Counter  │
                         └────────┬─────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │Instruction Memory│
                         └────────┬─────────┘
                                  │
                             Instruction
                                  │
                  ┌───────────────┴───────────────┐
                  │                               │
                  ▼                               ▼
          ┌──────────────┐                ┌───────────────┐
          │ Control Unit │                │ Register File │
          └──────┬───────┘                └───────┬───────┘
                 │                                │
                 │                       ┌────────┴────────┐
                 │                       │ Immediate Gen. │
                 │                       └────────┬────────┘
                 │                                │
                 └────────────────┬───────────────┘
                                  │
                                  ▼
                          ┌───────────────┐
                          │ ALU Input MUX │
                          └───────┬───────┘
                                  │
                                  ▼
                             ┌─────────┐
                             │   ALU   │
                             └────┬────┘
                                  │
                 ┌────────────────┼────────────────┐
                 │                │                │
                 ▼                ▼                ▼
          Branch Logic      Data Memory       ALU Result
                 │                │                │
                 └────────┐       │       ┌────────┘
                          │       ▼       │
                          │  ┌──────────┐ │
                          │  │Write-Back│ │
                          │  │   MUX    │ │
                          │  └────┬─────┘ │
                          │       │       │
                          │       ▼       │
                          │ Register File │
                          │               │
                          ▼               │
                     Next-PC Logic ◄──────┘
                          │
                          └──────► PC
```

---

## Supported RV32I Instructions

The current processor implements **17 instructions**.

| Type | Instructions | Function |
|---|---|---|
| R-Type | `ADD` | Register addition |
| | `SUB` | Register subtraction |
| | `AND` | Bitwise AND |
| | `OR` | Bitwise OR |
| | `XOR` | Bitwise XOR |
| | `SLT` | Signed set-less-than |
| I-Type | `ADDI` | Immediate addition |
| | `ANDI` | Immediate bitwise AND |
| | `ORI` | Immediate bitwise OR |
| | `XORI` | Immediate bitwise XOR |
| | `SLTI` | Signed immediate set-less-than |
| Memory | `LW` | Load 32-bit word |
| | `SW` | Store 32-bit word |
| Branch | `BEQ` | Branch if equal |
| | `BNE` | Branch if not equal |
| Jump | `JAL` | Jump and link |
| | `JALR` | Jump and link register |

---

# How the CPU Works

## 1. Instruction Fetch

The Program Counter contains the address of the current instruction.

```text
PC → Instruction Memory → 32-bit Instruction
```

Under normal execution:

```text
next_pc = pc + 4
```

Branch and jump instructions can instead select a calculated target address.

---

## 2. Instruction Decode

The instruction is separated into RISC-V fields:

```text
31                    25 24      20 19      15 14   12 11       7 6       0
┌───────────────────────┬──────────┬──────────┬───────┬──────────┬─────────┐
│        funct7         │   rs2    │   rs1    │funct3 │    rd    │ opcode  │
└───────────────────────┴──────────┴──────────┴───────┴──────────┴─────────┘
```

The Control Unit uses `opcode`, `funct3`, and `funct7` to generate signals controlling the datapath.

These include:

```text
reg_write
alu_src
mem_read
mem_write
wb_select
branch_type
jump
jalr
alu_control
```

---

## 3. Register Read

The register file contains 32 general-purpose 32-bit registers.

It provides two asynchronous read ports:

```text
rs1 → read_data1
rs2 → read_data2
```

and one synchronous write port:

```text
rd ← write_back_data
```

Register `x0` remains hardwired to zero.

---

## 4. Immediate Generation

The Immediate Generator reconstructs and sign-extends immediate values for the supported RISC-V instruction formats.

Supported immediate formats include:

```text
I-Type
S-Type
B-Type
J-Type
```

The generated 32-bit immediate can be used by the ALU or by branch/jump target calculations.

---

## 5. Execute

The ALU performs arithmetic, logical, and comparison operations.

```text
                ┌──────────────┐
read_data1 ────►│              │
                │     ALU      ├────► alu_result
alu_input2 ────►│              │
                └──────────────┘
                       ▲
                       │
                  alu_control
```

The second ALU operand is selected between:

```text
read_data2
     OR
immediate
```

depending on `alu_src`.

---

## 6. Memory Access

`LW` and `SW` use the ALU result as the data-memory address.

For a store:

```text
Register File → Data Memory
```

For a load:

```text
Data Memory → Write-Back MUX → Register File
```

---

## 7. Branch and Jump Control

For `BEQ` and `BNE`, the ALU compares the source registers and produces the `zero` flag.

Branch logic determines whether:

```text
next_pc = pc + 4
```

or:

```text
next_pc = pc + immediate
```

`JAL` redirects execution to a PC-relative target while writing `PC + 4` into `rd`.

`JALR` calculates its target using:

```text
(rs1 + immediate) & 0xFFFFFFFE
```

and also writes `PC + 4` into `rd`.

---

# Verification

The CPU was verified at both the **module level** and **processor level**.

### Module-Level Verification

Each major hardware block was first tested independently using custom Verilog testbenches, including the Program Counter, Instruction Memory, Register File, Immediate Generator, Control Unit, ALU, and Data Memory.

GTKWave was used throughout development to inspect the behavior of each module and verify signals, timing, control logic, and data flow before integrating the complete CPU.

Waveforms from these tests can be found in the [`GTKWaves/`](GTKWaves/) directory.

### Automated CPU Regression Testing

After integration, the complete CPU was verified using a **Python-driven randomized regression framework**.

For each supported instruction, the framework:

1. Generates randomized input values.
2. Encodes them into RV32I machine instructions.
3. Loads the generated program into instruction memory.
4. Runs the CPU using Icarus Verilog.
5. Reads the resulting register and memory state.
6. Compares the hardware result against the expected result.

This provides repeatable processor-level verification across many different operand combinations rather than relying only on hand-written test programs.

The regression suite covers all **17 implemented instructions**:

`ADD` `SUB` `AND` `OR` `XOR` `SLT`  
`ADDI` `ANDI` `ORI` `XORI` `SLTI`  
`LW` `SW` `BEQ` `BNE` `JAL` `JALR`

![RV32I Regression Results](GTKWaves/all_test_past.PNG)


---

### Full CPU Waveform Verification

In addition to automated testing, the complete processor was inspected in GTKWave using a demonstration program that exercises the datapath.

Signals such as the **PC, instruction, register operands, immediate, ALU result, memory controls, write-back data, branch decisions, and jump targets** were monitored to verify instruction execution through the single-cycle datapath.

This makes it possible to visually follow instructions through the complete single-cycle datapath.

![CPU GTKWave Verification](GTKWaves/cpu_gtkwave.PNG)

A more detailed example of CPU execution and the corresponding waveform is shown below.

# RTL Synthesis

The processor RTL was synthesized using **Yosys** to verify that the behavioral Verilog could be translated into hardware structures.

During synthesis, RTL operations were converted into hardware elements including:

- Adders
- Subtractors
- Comparators
- Multiplexers
- Flip-flops
- Boolean logic
- Register and memory control logic

For example, the ALU RTL:

```verilog
result = a + b;
result = a - b;
result = a & b;
result = a | b;
result = a ^ b;
```

was synthesized into corresponding `$add`, `$sub`, `$and`, `$or`, and `$xor` hardware cells.

## Synthesized ALU

The following schematic was generated directly from the Verilog RTL using Yosys and Graphviz:

![Synthesized ALU](rtl/alu_synth.svg)

The schematic shows the arithmetic/logic hardware and control-selection network inferred from the ALU RTL.

## Full CPU Synthesis

The complete processor was also passed through the Yosys synthesis flow to inspect the combined datapath and control implementation.

[View Full CPU Synthesis Schematic](rtl/cpu_synth.svg)

The full schematic is linked rather than embedded because the processor contains significantly more logic than the individual ALU.

---

## Example CPU Execution
### Program

```assembly
addi x1, x0, 10       # x1 = 10
addi x2, x0, 4        # x2 = 4

add  x3, x1, x2       # x3 = 14
sub  x4, x1, x2       # x4 = 6

sw   x3, 0(x0)        # memory[0] = 14
lw   x14, 0(x0)       # x14 = 14

beq  x3, x14, equal   # Branch taken because 14 == 14

addi x15, x0, 99      # Skipped

equal:
addi x15, x0, 1       # x15 = 1
```

### Expected Execution

| PC | Instruction | Result |
|---:|---|---|
| `0x00` | `addi x1, x0, 10` | `x1 = 10` |
| `0x04` | `addi x2, x0, 4` | `x2 = 4` |
| `0x08` | `add x3, x1, x2` | `x3 = 14` |
| `0x0C` | `sub x4, x1, x2` | `x4 = 6` |
| `0x10` | `sw x3, 0(x0)` | `memory[0] = 14` |
| `0x14` | `lw x14, 0(x0)` | `x14 = 14` |
| `0x18` | `beq x3, x14, +8` | Branch taken |
| `0x1C` | `addi x15, x0, 99` | **Skipped** |
| `0x20` | `addi x15, x0, 1` | `x15 = 1` |

### Waveform

![CPU Waveform](GTKWaves/CPU_waveform.PNG)

## Compile the CPU

```bash
make
```

## Run the Simulation

```bash
vvp sim.out
```

## Run Automated Regression

```bash
python verify/regression.py
```

## Generate the Waveform Demo

```bash
make wave
```

Then open the generated VCD in GTKWave if it is not opened automatically.

---

# Tools

| Tool | Purpose |
|---|---|
| Verilog HDL | RTL processor implementation |
| Icarus Verilog | RTL simulation |
| GTKWave | Waveform analysis |
| Python | Automated verification framework |
| Yosys | RTL synthesis |
| Graphviz | Synthesized schematic visualization |
| Git | Version control |

---

# Skills Demonstrated

- RTL Design
- RISC-V ISA
- Computer Architecture
- Processor Datapath Design
- Control Logic Design
- Verilog HDL
- Instruction Encoding
- Register File Design
- ALU Design
- Memory Interfaces
- Branch and Jump Logic
- Hardware Verification
- Randomized Regression Testing
- Waveform Analysis
- RTL Synthesis
- Debugging

---

# Author

## Tanay Ubale

Electrical and Computer Engineering  
Purdue University

**GitHub:** [https://github.com/tubale](https://github.com/tubale) 

**LinkedIn:** https://www.linkedin.com/in/tanayubale/

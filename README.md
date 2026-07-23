# Single-Cycle RISC-V (RV32I) CPU in Verilog

A custom **single-cycle RISC-V (RV32I)** processor designed and implemented entirely in **Verilog HDL**. This project was built from the ground up to develop a deeper understanding of **computer architecture, digital logic, RTL design, and hardware verification**.

The processor implements the complete **fetch–decode–execute** cycle using a modular hardware architecture. Every hardware block was individually designed, tested, and verified before being integrated into the complete CPU.

---

## Features

- Custom Single-Cycle RV32I Processor
- Modular RTL design in Verilog HDL
- Program Counter (PC)
- Instruction Memory
- Register File (32 × 32-bit)
- Immediate Generator
- Arithmetic Logic Unit (ALU)
- Control Unit
- Data Memory
- ALU Input Multiplexer
- Write-Back Multiplexer
- Complete CPU Datapath Integration
- Individual module verification using custom Verilog testbenches
- GTKWave waveform debugging and verification

---

## Supported Instructions

| Instruction | Description |
|------------|-------------|
| ADD | Register Addition |
| SUB | Register Subtraction |
| AND | Bitwise AND |
| OR | Bitwise OR |
| ADDI | Immediate Addition |
| LW | Load Word |
| SW | Store Word |

> Branch instructions (BEQ) and additional RV32I instructions are currently under development.

---

## Processor Architecture

```
                   +----------------+
                   | Program Counter|
                   +-------+--------+
                           |
                           v
                +----------------------+
                | Instruction Memory   |
                +----------+-----------+
                           |
                     Instruction
                           |
          +----------------+----------------+
          |                                 |
          v                                 v
   +---------------+               +----------------+
   | Control Unit  |               | Register File  |
   +-------+-------+               +--------+-------+
           |                                |
           |                                |
           |                        +-------+-------+
           |                        | Immediate Gen |
           |                        +-------+-------+
           |                                |
           +---------------+----------------+
                           |
                    ALU Input MUX
                           |
                           v
                     +-----------+
                     |    ALU    |
                     +-----+-----+
                           |
                           v
                    +--------------+
                    | Data Memory  |
                    +------+-------+
                           |
                    Write-Back MUX
                           |
                           v
                    Register File
```

---

## Project Structure

```
Single-Cycle-RISC-V-CPU/
│
├── rtl/
│   ├── cpu.v
│   ├── pc.v
│   ├── instruction_mem.v
│   ├── register_file.v
│   ├── immediate_gen.v
│   ├── control_unit.v
│   ├── alu.v
│   └── data_memory.v
│
├── sim/
│   ├── cpu_tb.v
│   ├── pc_tb.v
│   ├── instruction_mem_tb.v
│   ├── register_file_tb.v
│   ├── immediate_gen_tb.v
│   ├── control_unit_tb.v
│   ├── alu_tb.v
│   └── data_memory_tb.v
│
├── GTKWaves/
├── README.md
└── Makefile
```

---

## CPU Components

### Program Counter (PC)
Maintains the address of the current instruction and updates the instruction address every clock cycle.

### Instruction Memory
Stores the program instructions executed by the processor.

### Register File
Implements thirty-two 32-bit general-purpose registers with two asynchronous read ports and one synchronous write port.

### Immediate Generator
Extracts and sign-extends immediate values from RISC-V instructions.

### Control Unit
Decodes the instruction opcode, funct3, and funct7 fields to generate all processor control signals.

### Arithmetic Logic Unit (ALU)
Performs arithmetic and logical operations including addition, subtraction, AND, and OR while generating the Zero flag.

### Data Memory
Handles load and store operations for program data using synchronous writes and combinational reads.

---

## Verification

Each hardware module was verified independently before integrating the complete processor.

Verified Modules:

- ✅ Program Counter
- ✅ Instruction Memory
- ✅ Register File
- ✅ Immediate Generator
- ✅ Control Unit
- ✅ Arithmetic Logic Unit
- ✅ Data Memory
- ✅ Full CPU Datapath

Simulation and debugging were performed using **GTKWave**, verifying:

- Instruction Fetch
- Instruction Decode
- Register Reads/Writes
- ALU Operations
- Memory Accesses
- Control Signal Generation
- Datapath Functionality
- Write-Back Operations

---

## Example Program

```assembly
addi x1, x0, 5
addi x2, x0, 7
add  x3, x1, x2
sw   x3, 0(x4)
lw   x5, 0(x4)
```

Expected Results

```
x1 = 5
x2 = 7
x3 = 12
memory[0] = 12
x5 = 12
```

---

## Example CPU Execution

| Clock Cycle | Instruction | Result |
|-------------|------------|--------|
| 1 | `addi x1, x0, 5` | x1 = 5 |
| 2 | `addi x2, x0, 7` | x2 = 7 |
| 3 | `add x3, x1, x2` | x3 = 12 |
| 4 | `sw x3, 0(x4)` | Memory[0] = 12 |
| 5 | `lw x5, 0(x4)` | x5 = 12 |

---

## Running the Simulation

Compile the project:

```bash
make
```

Run the simulation:

```bash
vvp sim.out
```

Open the waveform:

```bash
gtkwave wave.vcd
```

---

## Future Improvements

- Implement BEQ branch instructions
- Add remaining RV32I instruction support
- Jump instructions (JAL/JALR)
- Branch comparator
- Pipelined processor implementation
- Hazard detection and forwarding
- Instruction and data caches
- FPGA implementation on Xilinx or Intel development boards

---

## Skills Demonstrated

- Verilog HDL
- RTL Design
- Computer Architecture
- RISC-V ISA
- Digital Logic Design
- Datapath Design
- Control Logic Design
- Hardware Verification
- Testbench Development
- GTKWave Debugging
- Modular Hardware Design
- Simulation and Verification

---

## Author

### Tanay Ubale

Electrical Engineering Student  
Purdue University

This project was developed as part of a personal hardware engineering initiative to strengthen my understanding of computer architecture, RTL design, digital logic, and hardware verification by implementing a complete single-cycle RISC-V processor from scratch in Verilog.

**GitHub:** https://github.com/<your-github-username>

**LinkedIn:** https://www.linkedin.com/in/<your-linkedin>

---

## License

This project is licensed under the MIT License.

Feel free to use, modify, and learn from this project.

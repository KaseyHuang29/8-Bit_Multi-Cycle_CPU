# 8-Bit Multi-Cycle CPU
A custom 8-bit multi-cycle CPU implemented in Verilog with 16-bit instructions. This CPU uses a Harvard-style architecture and includes a four-register Register File, an Arithmetic Logic Unit, a control unit, and automated simulation testbenches.

![Custom 8-bit multi-cycle CPU block diagram](docs/CPU_block_diagram.svg)

## Main Modules
* Instruction memory
* Data memory
* Program Counter (PC) Adder
* Arithmetic Logic Unit (ALU)
* Register File (RF)
* Control Unit (FSM)

## Architecture
### Memory Organization
The processor uses a Harvard-style architecture with separate instruction and data memories, each with 256 address locations. 

* 16-bit wide instruction memory is read-only; programs can be loaded from a testbench directly or with a memory initialization file 
* 8-bit wide data memory supports reads and writes

### PC Adder
The PC uses a dedicated adder instead of the ALU. It selects either a constant increment or the encoded 8-bit immediate of the instruction, and supports relative addressing. 

## Register file (RF)
The RF has four 8-bit general-purpose registers (`r0-r3`). 
* Has two read ports `ra` and `rb` for the encoded destination and source register
* Has one write port for register-write; the destination register is encoded by the `ra` field of the instruction 

## Arithmetic Logic Unit (ALU)
The ALU supports:

* Arithmetic: addition (ADD), subtraction (SUB)
* Bitwise logic operations: AND, OR, XOR, NOT
* SHIFT, which handles:
    * Logical left (SLLI)
    * Logical right (SLRI)
    * Arithmetic right (SARI)

and outputs an 8-bit result.

The ALU also generates four condition flags:

* `Z`: Zero 
* `N`: Negative
* `V`: Signed overflow
* `C`: Carry out

used for branching instructions.

## Control Unit
The processor uses a finite state machine (FSM) to control the multi-cycle execution of instructions.

* Cycle 0: Fetch instruction and store current program counter value 
* Cycle 1: Load registers and increment program counter
* Cycle 2: Decode and execute instruction
* Cycle 3: Some instructions require an extra clock cycle to complete

## Instruction Set
The processor uses a custom 18-instruction ISA, encoded by 16 4-bit opcodes (0000-1111). 

Note: the SHIFT instruction uses additional bits in its encoding to support left/right and logical/arithmetic shifts.

| Instruction | Opcode | Syntax | Operation |
|----|----|----|----|
| load | 0000 |  `load ra, (rb)` | ra <-- DMEM[rb] |
| store | 0001 |  `store ra, (rb)` | DMEM[rb] <-- ra |
| mov | 0010 |  `mov ra, rb` | ra <-- rb |
| ldi | 0011 |  `ldi ra, imm8` | ra <-- imm8 |
| add | 0100 |  `add ra, rb` | ra <-- ra + rb |
| addi | 0101 |  `addi ra, imm8` | ra <-- ra + imm8 |
| sub | 0110 |  `sub ra, rb` | ra <-- ra - rb |
| slli | 0111 |  `slli ra, imm3` | ra <-- ra << imm3 |
| slri | 0111 |  `slri ra, imm3` | ra <-- ra >> imm3 |
| sari | 0111 |  `sari ra, imm3` | ra <-- ra >>> imm3 |
| and | 1000 |  `and ra, rb` | ra <-- ra & rb |
| or | 1001 |  `or ra, rb` | ra <-- ra \| rb |
| xor | 1010 |  `xor ra, rb` | ra <-- ra ^ rb |
| not | 1011 |  `not ra` | ra <-- ~ra |
| jmp | 1100 |  `jmp imm8` | PC <-- PC + imm8 |
| bne | 1101 |  `bne ra, rb, imm8` | PC <-- PC + imm8 if ra != rb |
| bgt | 1110 |  `bgt ra, rb, imm8` | PC <-- PC + imm8 if signed ra > rb |
| bgtu | 1111 |  `bgtu ra, rb, imm8` | PC <-- PC + imm8 if unsigned ra > rb |

## Running Programs
The processor currently does not include an assembler; programs must be written as 16-bit machine-code instructions and loaded into the instruction memory prior to simulation.

Programs can be loaded in two ways:
1. Assign instructions directly to the memory from the testbench

    Example: 

    `CPU.IMEM.ROM[0] = 16'h0503; // ldi r0, 5`

2. Load instructions to the memory from a hexadecimal memory initialization file using `$readmemh`

    Example: 

    `$readmemh("programs/example_program.hex", CPU.IMEM.ROM);`

    and inside `example_program.hex`:

    `0503 // ldi r0, 5`

## Testbench and Verification
The processor is tested using both manual and self-checking Verilog testbenches against several programs designed to verify the functionality of all instructions. Each program is tested in its own separate task, and each type of check (ie. checking RF register values, data memory contents, current clock cycle, etc) is also written as its own task.

### Manual Verification
The waveform viewer, Surfer, was used to inspect the multi-cycle execution of instructions as well as relevant control signals and register or memory values. 

Example:

`surfer tb/cpu_top_tb.vcd`

### Automated Verification
To verify correctness, expected register or data memory values are compared against the actual values. An N-bit wide `tests_pass` vector is used, where N is the total number of tests. Each bit represents the passing state of one test, with a pass indicated by a `1`, and a fail indicated by a `0`. The vector is then used to display a pass/fail summary at the end of the simulation. 

## Example Program
The following is a program that calculates and stores Fibonacci numbers, and stops at the largest 8-bit Fibonacci number.

```
ldi r0, 0
ldi r1, 1
ldi r3, 0
store r0, (r3)
addi r3, 1
store r1, (r3)
addi r3, 1
mov r2, r0
add r2, r1
bgtu r1, r2, 6
store r2, (r3)
addi r3, 1
mov r0, r1
mov r1, r2
jmp -7
jmp 0
```

Assigning the program directly to the instruction memory:
```
CPU.IMEM.ROM[0] = 16'h0003; // ldi r0, 0
CPU.IMEM.ROM[1] = 16'h0143; // ldi r1, 1
CPU.IMEM.ROM[2] = 16'h00c3; // ldi r3, 0
CPU.IMEM.ROM[3] = 16'h0031; // store r0, (r3)
CPU.IMEM.ROM[4] = 16'h01c5; // addi r3, 1
CPU.IMEM.ROM[5] = 16'h0071; // store r1, (r3)
CPU.IMEM.ROM[6] = 16'h01c5; // addi r3, 1
CPU.IMEM.ROM[7] = 16'h0082; // mov r2, r0
CPU.IMEM.ROM[8] = 16'h0094; // add r2, r1
CPU.IMEM.ROM[9] = 16'h066f; // bgtu r1, r2, 6
CPU.IMEM.ROM[10] = 16'h00b1; // store r2, (r3)
CPU.IMEM.ROM[11] = 16'h01c5; // addi r3, 1
CPU.IMEM.ROM[12] = 16'h0012; // mov r0, r1
CPU.IMEM.ROM[13] = 16'h0062; // mov r1, r2
CPU.IMEM.ROM[14] = 16'hf90c; // jmp -7
CPU.IMEM.ROM[15] = 16'h000c; // jmp 0
```

Or by using a memory initialization hex file:
```
0003
0143
00c3
0031
01c5
0071
01c5
0082
0094
066f
00b1
01c5
0012
0062
f90c
000c
```

The results can be verified using the task, `disp_verify_dmem`, which displays to the terminal both the expected and actual data memory contents, as well as its pass/fail state:
```
Expected: RAM @ 0x00 holds 00000000
Actual: RAM @ 0x00 holds 00000000
PASS

Expected: RAM @ 0x01 holds 00000001
Actual: RAM @ 0x01 holds 00000001
PASS

Expected: RAM @ 0x02 holds 00000001
Actual: RAM @ 0x02 holds 00000001
PASS

Expected: RAM @ 0x03 holds 00000010
Actual: RAM @ 0x03 holds 00000010
PASS

Expected: RAM @ 0x04 holds 00000011
Actual: RAM @ 0x04 holds 00000011
PASS

Expected: RAM @ 0x05 holds 00000101
Actual: RAM @ 0x05 holds 00000101
PASS

Expected: RAM @ 0x06 holds 00001000
Actual: RAM @ 0x06 holds 00001000
PASS

Expected: RAM @ 0x07 holds 00001101
Actual: RAM @ 0x07 holds 00001101
PASS

Expected: RAM @ 0x08 holds 00010101
Actual: RAM @ 0x08 holds 00010101
PASS

Expected: RAM @ 0x09 holds 00100010
Actual: RAM @ 0x09 holds 00100010
PASS

Expected: RAM @ 0x0a holds 00110111
Actual: RAM @ 0x0a holds 00110111
PASS

Expected: RAM @ 0x0b holds 01011001
Actual: RAM @ 0x0b holds 01011001
PASS

Expected: RAM @ 0x0c holds 10010000
Actual: RAM @ 0x0c holds 10010000
PASS

Expected: RAM @ 0x0d holds 11101001
Actual: RAM @ 0x0d holds 11101001
PASS
```
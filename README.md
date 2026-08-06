# 8-Bit Multi-Cycle CPU
A custom 8-bit multi-cycle CPU implemented in Verilog with 16-bit instructions. This CPU uses a Harvard-style architecture and includes a four-register Register File, an Arithmetic Logic Unit, a control unit, and automated simulation testbenches.

![Custom 8-bit multi-cycle CPU block diagram](docs/CPU_block_diagram.svg)

## Main Features
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
The PC uses a dedicated adder instead of the ALU. It selects either a constant increment or the encoded 8-bit immediate of the instruction, which supports relative addressing. 

## Register file (RF)
The RF has four 8-bit general-purpose registers (r0-r3). 
* Has two read ports 'ra' and 'rb' for the encoded destination and source register
* Has one write port for instructions that write back to a register; the destination register is encoded by the 'ra' field of the instruction 

## Arithmetic Logic Unit (ALU)
The ALU supports:
* Arithmetic: addition (ADD), subtraction (SUB)
* Bitwise logic operations: AND, OR, XOR, NOT
* Shifts: logical left (SLLI), logical right (SLRI), arithmetic right (SARI)
and outputs an 8-bit result.

The ALU also generates four condition flags:
* Z: Zero 
* N: Negative
* V: Signed overflow
* C: Carry out
used for branching instructions.

## Control Unit
The processor uses a finite state machine (FSM) to control the multi-cycle execution of instructions. 
* Cycle 0: Fetch instruction and store current program counter value 
* Cycle 1: Load registers and increment program counter
* Cycle 2: Decode and execute instruction
* Cycle 3: Some instructions require an extra clock cycle to complete

## Instruction Set
The processor uses a custom 18-instruction ISA, encoded by 16 4-bit opcodes (0000-1111). Note: the SHIFT instruction uses additional bits in its encoding to support left/right and logical/arithmetic shifts.

| Instruction | Opcode | Syntax | Operation |
|----|----|----|----|
| LOAD | 0000 | LOAD ra, (rb) | ra <- DMEM[rb] |
| STORE | 0001 | STORE ra, (rb) | DMEM[rb] <- ra |
| MOV | 0010 | MOV ra, rb | ra <- rb |
| LDI | 0011 | LDI ra, imm8 | ra <- imm8 |
| ADD | 0100 | ADD ra, rb | ra <- ra + rb |
| ADDI | 0101 | ADDI ra, imm8 | ra <- ra + imm8 |
| SUB | 0110 | SUB ra, rb | ra <- ra - rb |
| SLLI | 0111 | SLLI ra, imm3 | ra <- ra << imm3 |
| SLRI | 0111 | SRLI ra, imm3 | ra <- ra >> imm3 |
| SARI | 0111 | SRAI ra, imm3 | ra <- ra >>> imm3 |
| AND | 1000 | AND ra, rb | ra <- ra & rb |
| OR | 1001 | OR ra, rb | ra <- ra \| rb |
| XOR | 1010 | XOR ra, rb | ra <- ra ^ rb |
| NOT | 1011 | NOT ra | ra <- ~ra |
| JMP | 1100 | JMP imm8 | PC <- PCold + imm8 |
| BNE | 1101 | BNE ra, rb, imm8 | Branch if ra != rb |
| BGT | 1110 | BGT ra, rb, imm8 | Branch if signed ra > rb |
| BGTU | 1111 | BGTU ra, rb imm8 | Branch if unsigned ra > rb |
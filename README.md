# WISC-CPU
This project is for ECE 552 at University of Wisconsin-Madison. We designed and implemented a fully functional 16-bit pipelined CPU using Verilog. We developed a 5-stage pipeline processor and integrated support for control hazards, data hazard, as well as cache memory systems.

# WISC-S25 ISA
We used a cutom ISA called WISC-S25. WISC-S25 contains a set of 16 instructions specified for a 16-bit data-path with load/store architecture. 

The WISC-S25 memory is byte addressable, even though all accesses (instruction fetches, loads, stores) are restricted to half-word (2-byte), naturally-aligned accesses.

WISC-S25 has a register file, and a 3-bit FLAG register. The register file comprises sixteen 16-bit registers and has 2 read ports and 1 write port. Register $0 is hardwired to 0x0000. The FLAG register contains three bits: Zero (Z), Overflow (V), and Sign (N).

| Mnemonic | Opcode | Description                             |
|----------|--------|-----------------------------------------|
| ADD      | 0x0000 | Addition                                |
| SUB      | 0x0001 | Subtraction                             |
| XOR      | 0x0010 | Bitwise XOR                             |
| RED      | 0x0011 | Reduction on 8 half-byte-size operands  |
| SLL      | 0x0100 | Logical Left Shift                      |
| SRA      | 0x0101 | Arithmetic Right Shift                  |
| ROR      | 0x0110 | Right Rotation                          |
| PADDSB   | 0x0111 | Four half-byte additions in parallel    |
| LW       | 0x1000 | Load Word                               |
| SW       | 0x1001 | Store Word                              |
| LLB      | 0x1010 | Load Lower Byte                         |
| LHB      | 0x1011 | Load Higher Byte                        |
| B        | 0x1100 | Branch                                  |
| BR       | 0x1101 | Branch Register                         |
| PCS      | 0x1110 | Save contents of next PC                |
| HLT      | 0x1111 | HALT                                    |

# Caches
The processor has separate instruction and data caches (I-cache and D-cache), which are byte-addressable. The caches are 2KB in size, 2-way set-associative, with cache blocks of 16B each. 

The cache write policy is write-through and write-allocate. The cache read policy is to read from the cache for a hit; on a miss, the data is brought back from main memory to the cache and then the required word (from the block) is read out.

# Pipelined Design
The processor is using a five-stage pipeline (IF, ID, EX, MEM, WB). 

We implemented hazard detection to corretly handle all dependences. The processor has register bypassing, EX-to-EX forwarding, MEM-to-EX forwarding, and MEM-to-MEM forwarding.

Our processor uses dynamic branch predictor with support for conditional and unconditional branches. The branch predictor is a 1-bit counter capable of tracking up to 16 branches, and provides early decode of branch targets to allow for predict-taken branches at full speed. 

# Extra
- Stall and flush logic for handling control and structural hazard
- Full testbench coverage for ISA-defined instruction functionality, and multiple test cases
- Synthesis script supporting 3 stage incremental compile
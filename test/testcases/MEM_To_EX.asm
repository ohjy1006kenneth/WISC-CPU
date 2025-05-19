    ADD     r3, r0, r0     # $t1 = 0 (base address)
    LLB     r1, 21         # r1 = 0x0015
    LHB     r1, 1          # r1 = 0x0115 no change
    LLB     r2, 20         # r2 = 0x0014
    LHB     r2, 2          # r2 = 0x0214 no change
    SW      r1, r3, 4      # r1 -> MEM[4]
    SW      r2, r3, 16     # r2 -> MEM[16]
    LW      r4, r3, 4      # MEM[4] -> r4
    ADD     r2, r4, r2     # MEM - EX forwarding r2 + r4 = 0x0329
    LW      r4, r3, 4      # MEM[4] -> r4
    ADD     r2, r4, r4     # r2 = 0x0015 + 0x0015 = 0x002A Checks for chain load use on ALU
    SUB     r0, r4, r2
    LW      r4, r3, 16     # MEM[16] -> r4
    BR      001, r4        # MEM dependent Branch relative
    LW      r4, r3, 4      # MEM[4] -> r4
    SW      r4, r3, 16     # Sets MEM[16] to MEM[4] MEM to MEM check
    ADD     r4, r2, r2     # If executed something is wrong
JMP: 
    HLT                    # Finish execution
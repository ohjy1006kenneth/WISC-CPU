        LLB     r1, 0x2A        # r1 = 0x002A
        SW      r1, r0, 0       # MEM[0] = 0x002A
        LW      r2, r0, 0       # r2 = MEM[0] = 0x002A goes to MEM
        ADD     r3, r1, r1      # r3 = r1 + r1 = 0x002B x 2 no dependences. should not stall
        ADD     r1, r3, r3      # r3 = r1 + r1 = 0x002B x 2 EX stage needs r2. should not stall since 1 cycle after
        
        

        HLT                     # End

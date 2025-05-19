// Test EX-to-EX Forwarding

// Basic EX-to-EX test
LLB R2, 0x1
LLB R3, 0X2
LLB R5, 0X3
ADD R1, R2, R3
SUB R4, R1, R5  // R4 should be 0

// Back to back instructions
LLB R1, 0x1
LLB R2, 0X2
LLB R3, 0X3

ADD R1, R2, R3 // R1 = 5
ADD R2, R1, R3 // R2 = 8
ADD R3, R2, R1 // R3 = 13

// Check WAW. It should forward the newest R1
LLB R1, 0x1
LLB R2, 0X2
LLB R3, 0X3

ADD R1, R2, R3 // R1 = 5
ADD R1, R2, R0 // R1 = 2
ADD R4, R1, R2 // R4 = 4 (Should use the latest R1)

HLT
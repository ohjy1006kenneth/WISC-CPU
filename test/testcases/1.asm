// Compute first few fibonacci numbers
// V 1.0
// PASS
	ADD R1, R0, R0
	LLB R2, 0X1
	LLB R3, 0X9
	LLB R4, 0X1
Ltop:
	ADD R1, R1, R2
	XOR R1, R2, R1
	XOR R2, R1, R2
	XOR R1, R2, R1
	// DBG point -> R1 and r2 have fib numbers
	SUB R3, R3, R4
	B 000, Ltop
	HLT

# Test double stall
# First, try to trick it
# Save a halt instruction for later....
	B 111, pass
GOOD1:	B 111, OTHER
# Set the condition codes, and make R1 0
pass:	ADD R1, R0, R0
# R2 is an address to store
	LLB R2, 56
# R3 is addr of halt instruction
	LLB R3, 2
# R4 gets some nonsense value
	LLB R4, 72
# Store R3 and load to R4 to create a dependent load
	SW R3, R2, 2
	LW R4, R2, 2
# Got R4? Let's go there
# This shouldn't actually need any stalls
	BR 000, R4
# Now let's do this
	SW R4, R2, 3
	LW R5, R2, 3
	BR 001, R5
# Should halt after that
# If it doesn't, flag updating is probably fucked
	B 111, BAD
	HLT	# This should never execute
	HLT
	HLT
	HLT
OTHER:
	# Test single stall
	LW R5, R2, 3
	ADD R0, R5, R5
	# This should have stalled once
	LW R5, R2, 2
	ADD R0, R0, R0
	ADD R0, R5, R5
	# This shouldn't stall
	HLT

BAD:	XOR R0, R0, R0

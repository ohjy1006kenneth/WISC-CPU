#include<stdio.h>
#include<stdlib.h>

int main(void) {
	asm("movq $0, %rax");
	asm("movq $1, %rbx");
	asm("top:");
	asm("addq %rbx, %rax");
	asm("xchg %rbx, %rax");
	asm("jmp top");
}

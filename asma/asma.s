	.ident "Lorenz Leutgeb <lorenz.leutgeb@student.tuwien.ac.at>"
	.data
	.section .rodata
asma_mask:
	.align 16
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
	.text
	.globl asma
	.type asma, @function
asma:
	movdqa		asma_mask, %xmm8
	movdqu		(%rdi), %xmm9
	pcmpeqb		%xmm8, %xmm9
	pmovmskb	%xmm9, %rax
	popcnt		%rax, %rax
	ret

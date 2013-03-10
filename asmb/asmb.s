	.ident "Lorenz Leutgeb <lorenz.leutgeb@student.tuwien.ac.at>"

	.data
	.section .rodata
	.align 16

asma_mask:
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20

	.text
	.globl asma
	.type asma, @function

asma:
	movdqa		asma_mask, %xmm8	# Initialize xmm8
	movdqu		(%rdi), %xmm9		# Load target string from memory
	movq		$0, %r10
	movq		$0, %rax

	pcmpeqb		%xmm8, %xmm9		# Replace all spaces with 0xff
	pmovmskb	%xmm9, %r11		# Collapse XMM to a mask of MSBs
	popcnt		%r11, %r11		# Count number of ones in %rcx and store it to %rcx
	leaq		(%rax, %r11), %rax
	incw		$

	ret

	.file "asma.s"

	.data
	.section .rodata
	.align 16
asma_mask:
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20

	.text
	.globl asma
	.type asma, @function
asma:
	movdqa asma_mask, %xmm1		# Initialize xmm1
	movdqu (%rdi), %xmm0		# Load target string from memory
	pcmpeqb %xmm1, %xmm0		# Replace all spaces with 0xff
	pmovmskb %xmm0, %rcx		# Collapse XMM to a mask of MSBs
	popcnt %rcx, %rcx		# Count number of ones in %rcx and store it to %rcx
	leave
	ret

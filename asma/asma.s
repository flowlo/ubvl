	.file "asma.s"
	.text
	.globl asma
	.type asma, @function
asma:
	# Initialize xmm1
	movdqu (%rdi), %xmm0		# Load target string from memory
	pcmpeqb %xmm1, %xmm0		# Replace all spaces with 0xff
	pmovmskb %xmm0, %rcx
	popcnt %rcx, %rcx		# Count number of ones in %rcx and store it to %rcx
	ret

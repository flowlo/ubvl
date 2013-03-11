	.ident "Lorenz Leutgeb <lorenz.leutgeb@student.tuwien.ac.at>"

	.data
	.section .rodata
	.align 16

asmb_mask:
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20

	.text
	.globl asmb
	.type asmb, @function

asmb:
	movdqa		asmb_mask, %xmm8
	leaq		0, %rax
	leaq		(%rsi), %rcx
	shrq		$4, %rcx
	jrcxz		last
loop:
	movdqu		(%rdi), %xmm9
	leaq		16 (%rdi), %rdi
	pcmpeqb		%xmm8, %xmm9
	pmovmskb	%xmm9, %r11
	popcnt		%r11, %r11
	leaq		(%rax, %r11), %rax
	loop		loop
last:
	andq		$15, %rsi
	jz		end
	xorq		$63, %rsi
	leaq		1 (%rsi), %rcx
	movdqu		(%rdi), %xmm9
	pcmpeqb		%xmm8, %xmm9
	pmovmskb	%xmm9, %r11
	shlq		%cl, %r11
	popcnt		%r11, %r11
	leaq		(%rax, %r11), %rax
end:
	ret

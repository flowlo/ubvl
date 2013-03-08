	.file	"main.c"
	.text
	.p2align 4,,15
	.globl	asma
	.type	asma, @function
asma:
.LFB22:
	.cfi_startproc
	xorl	%edx, %edx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L3:
	xorl	%ecx, %ecx
	cmpb	$32, (%rdi,%rdx)
	sete	%cl
	addq	$1, %rdx
	addl	%ecx, %eax
	cmpq	$16, %rdx
	jne	.L3
	rep
	ret
	.cfi_endproc
.LFE22:
	.size	asma, .-asma
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Das sind 3 Abstaende."
.LC1:
	.string	"%d\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4,,15
	.globl	main
	.type	main, @function
main:
.LFB23:
	.cfi_startproc
	movl	$.LC0, %eax
	xorl	%edx, %edx
	.p2align 4,,10
	.p2align 3
.L8:
	xorl	%ecx, %ecx
	cmpb	$32, (%rax)
	sete	%cl
	addq	$1, %rax
	addl	%ecx, %edx
	cmpq	$.LC0+16, %rax
	jne	.L8
	movl	$.LC1, %esi
	movl	$1, %edi
	xorl	%eax, %eax
	jmp	__printf_chk
	.cfi_endproc
.LFE23:
	.size	main, .-main
	.ident	"GCC: (Ubuntu/Linaro 4.7.2-2ubuntu1) 4.7.2"
	.section	.note.GNU-stack,"",@progbits

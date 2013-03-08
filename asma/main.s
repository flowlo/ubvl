	.file	"main.c"
	.text
	.globl	asma
	.type	asma, @function
asma:
.LFB22:
	.cfi_startproc
	movl	$0, %edx
	movl	$0, %eax
.L3:
	cmpb	$32, (%rdi,%rdx)
	sete	%cl
	movzbl	%cl, %ecx
	addl	%ecx, %eax
	addq	$1, %rdx
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
	.text
	.globl	main
	.type	main, @function
main:
.LFB23:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$.LC0, %edi
	call	asma
	movl	%eax, %edx
	movl	$.LC1, %esi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE23:
	.size	main, .-main
	.ident	"GCC: (Ubuntu/Linaro 4.7.2-2ubuntu1) 4.7.2"
	.section	.note.GNU-stack,"",@progbits

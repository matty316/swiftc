	.globl	_main
_main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	movl	$10, -4(%rbp)
	negl	-4(%rbp)
	movl	-4(%rbp), %eax
	movq	%rbp, %rsp
	popq	%rbp
	ret

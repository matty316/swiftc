	.globl	_main
_main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$12, %rsp
	movl	$4, -4(%rbp)
	addl	$12, -4(%rbp)
	movl	$40, -8(%rbp)
	movl	-4(%rbp), %r10d
	shll	%r10d, -8(%rbp)
	movl	-8(%rbp), %r10d
	movl	%r10d, -12(%rbp)
	shrl	$1, -12(%rbp)
	movl	-12(%rbp), %eax
	movq	%rbp, %rsp
	popq	%rbp
	ret

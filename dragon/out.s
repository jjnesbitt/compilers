	.section	.rodata
.LC0:
	.string "%d\n"
.LC1:
	.string "%f\n"
.LC2:
	.string "%d"
	.text
	.globl	main
	.type	main, @function
gcd:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	%ecx, -4(%ebp)
	movl	%ebp, %ecx
	movl	8(%ecx), %eax
	movl	%eax, -16(%ecx)
	movl	%ebp, %ecx
	movl	12(%ecx), %eax
	movl	%eax, -20(%ecx)
	movl	%ebp, %ecx
	pushl	-16(%ecx)
	pushl	$.LC0
	call	printf
	addl	$8, %esp
	movl	%ebp, %ecx
	pushl	-20(%ecx)
	pushl	$.LC0
	call	printf
	addl	$8, %esp
	movl	$1, %edi
	movl	%ebp, %ecx
	movl	-4(%ecx), %ecx
	movl	%edi, -32(%ecx)
	addl	$24, %esp
	popl	%ebp
	ret
boo:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$40, %esp
	movl	%ecx, -4(%ebp)
	movl	%ebp, %ecx
	movl	8(%ecx), %eax
	movl	%eax, -12(%ecx)
	movl	%ebp, %ecx
	movl	12(%ecx), %eax
	movl	%eax, -12(%ecx)
	movl	%ebp, %ecx
	leal	-24(%ecx), %edi
	pushl	%edi
	pushl	$.LC2
	call	scanf
	addl	$8, %esp
	movl	%ebp, %ecx
	leal	-28(%ecx), %edi
	pushl	%edi
	pushl	$.LC2
	call	scanf
	addl	$8, %esp
	movl	%ebp, %ecx
	pushl	-28(%ecx)
	movl	%ebp, %ecx
	pushl	-24(%ecx)
	movl	%ebp, %ecx
	call	gcd
	addl	$8, %esp
	movl	%ebp, %ecx
	movl	-32(%ecx), %edi
	movl	%ebp, %ecx
	movl	%edi, -24(%ecx)
	movl	%ebp, %ecx
	pushl	-24(%ecx)
	pushl	$.LC0
	call	printf
	addl	$8, %esp
	addl	$40, %esp
	popl	%ebp
	ret
main:
	pushl	%ebp
	movl	%esp, %ebp
	call	boo
	popl	%ebp
	ret
	.size   main, .-main
	.section    .text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl  __x86.get_pc_thunk.ax
	.hidden __x86.get_pc_thunk.ax
	.type   __x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
	movl    (%esp), %eax
	ret
	.ident  "GCC: (Ubuntu 7.3.0-27ubuntu1~18.04) 7.3.0"
	.section    .note.GNU-stack,"",@progbits

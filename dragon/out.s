	.section	.rodata
.LC0:
	.string "%d\n"
.LC1:
	.string "%f\n"
	.text
	.globl	main
	.type	main, @function
boo:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$36, %esp
	movl	$3, %esi
	movl	$4, %edi
	addl	$5, %edi
	subl	%edi, %esi
	movl	$1, %edi
	addl	$2, %edi
	subl	%esi, %edi
	movl	%edi, -12(%ebp)
	movl	$5, %edi
	addl	$1, %edi
	movl	%edi, -8(%ebp)
	pushl	-8(%ebp)
	pushl	$.LC0
	call	printf
	addl	$8, %esp
	pushl	-12(%ebp)
	pushl	$.LC0
	call	printf
	addl	$8, %esp
	movl	%edi, %eax
	addl	$36, %esp
	popl	%ebp
	ret
main:
	pushl	%ebp
	movl	%esp, %ebp
	call	boo
	movl	$0, %eax
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

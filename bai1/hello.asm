section .data
	text db "Hello World",10

section .text
	global _start

_start:
	mov eax, 1
	mov edi, 1
	mov esi, text
	mov edx, 12
	syscall

	mov eax, 60
	mov edi, 0
	syscall


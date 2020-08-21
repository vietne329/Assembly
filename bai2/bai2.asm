
section .data
	text1 db "Input somthing please:"
	text2 db "You just typing:"

section .bss
	input resb 32

section .text
	global _start

_start:
	call _printText1
	call _getInput
	call _printText2
	call _printInput

	mov eax,60
	mov edi,0
	syscall

_printText1:
	mov eax, 1
	mov edi, 1
	mov esi, text1
	mov edx, 22
	syscall
	ret

_printText2:
	mov eax, 1
	mov edi, 1
	mov esi, text2
	mov edx, 18
	syscall
	ret

_printInput:
	mov eax, 1
	mov edi, 1
	mov esi, input
	mov edx, 32
	syscall
	ret
_getInput:
	mov eax,0
	mov edi,0
	mov esi,input
	mov edx,32
	syscall
	ret

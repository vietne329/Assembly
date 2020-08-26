section .data
	msg db "hello guy!",0xA
	len equ $-msg

section .bss
	res resb 20

section .text
	global _start

_start:
	mov ecx,len
	mov esi,msg
	mov edi,res
	cld
	rep movsb

	mov eax,4
	mov ebx,1
	mov ecx,res
	mov edx,20
	int 0x80

	mov eax,1
	int 0x80

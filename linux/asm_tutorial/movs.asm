section .text
	global _start

_start:
	mov ecx,len
	mov esi,s1
	mov edi,s2

l1:
	mov al,[esi]
	mov [edi],al
	inc esi
	inc edi
	loop l1

	mov eax,4
	mov ebx,1
	mov ecx,s2
	mov edx,20
	int 0x80

	mov eax,1
	int 0x80

section .data
	s1 db "Long time no see!"
	len equ $-s1

section .bss
	s2 resb 20


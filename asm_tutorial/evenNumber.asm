section .data
	even_msg db "Event Number!"
	len1 equ $ - even_msg

	odd_msg db "Odd Number!"
	len2 equ $ - odd_msg

section .text
	global _start

_start:
	mov ax, 08h
	and ax, 1
	jz evenn
	mov eax, 4
	mov ebx,1
	mov ecx, odd_msg
	mov edx,len2
	jmp outprog

evenn:
	mov ah, 09h
	mov eax,4
	mov ebx,1
	mov ecx,even_msg
	mov edx,len1
	int 0x80


outprog:
	mov eax,1
	int 0x80

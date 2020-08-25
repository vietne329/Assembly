section .data		;Data segment
	userMsg db "Please enter the number: "
	lenUserMsg equ $-userMsg
	disMsg db "You have entered: "
	lenDisMsg equ $-disMsg

section .bss
	num resb 5	;Uninitialized data

section .text		;Code segment
	global _start

_start:
	mov eax,4
	mov ebx,1
	mov ecx,userMsg
	mov edx,lenUserMsg
	int 0x80

	;Read and store the user input
	mov eax,3
	mov ebx,2
	mov ecx,num
	mov edx,5
	int 0x80

	;Output the message
	mov eax,4
	mov ebx,1
	mov ecx,disMsg
	mov edx,lenDisMsg
	int 0x80

        ;Output the number entered
        mov eax, 4
        mov ebx, 1
        mov ecx, num
        mov edx, 5
        int 0x80

        ; Exit code
        mov eax, 1
        mov ebx, 0
        int 0x80

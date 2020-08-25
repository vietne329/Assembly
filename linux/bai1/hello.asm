section .data
	text db "hello world",10
	len equ $ - text

section .text
	global _start
_start:

	mov eax, 4     ; systemcall for write : 4
	mov ebx, 1     ; fd is file descriptor
		       ; 1 is stdout, 0 is sdtin, stderr=2
	mov ecx, text  ; pointer to char buffer
	mov edx, len   ; total size of text
	int 0x80       ; system call

	;exit program
	mov eax,1      ;system call  exit : 1
	int 0x80

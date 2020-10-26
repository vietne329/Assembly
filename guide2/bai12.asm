;Make file
;nasm -f elf64 bai12.asm -o bai12.o
;gcc -o bai12 bai12.o -no-pie	

bits 64
; calling some C functions
extern printf
extern puts
extern open
extern read
extern lseek
extern free
extern malloc

section .bss
elfFd: resb 4	; elf file descriptor

section .data

	addrType: dd 0	
	namesSectionIdx: dd 0	; index of the names section
	pheaderInfo: dd 0, 0, 0	; struct pheaderInfo {dword entrySize, dword numOfEntries, dword offset_to}
	sheaderInfo: dd 0, 0, 0	; struct sheaderInfo {dword entrySize, dword numOfEntries, dword offset_to}

section .rodata

	error_no_file: db "Usage: %s <elf-file>", 0Ah, 0
	error_open_fail: db "ERROR: cannot open file", 0Ah, 0
	hex_fmt: db "%x ", 0		;format hex
test: db "test", 0
	newline: db 0Ah, 0

; elf_header
	elf_header: 	db 	"ELF Header:"	, 0Ah, 0
	magic_str : 	db	 9, "Magic: "	,  0
	class_str : 	db 	0Ah,9,"Class: %d	(1- 32 bit, 2- 64 bit)"	, 0Ah, 0
	data_str : 		db 	9,"Data: %d	(1 or 2 to signify little or big endianness)"	, 0Ah, 0
	type_str : 		db 		9,"Object file type: %d (1- relocatable file, 2- executable object, 3- shared object)", 0Ah, 0 
	entrypoint_str: db 	9,"Entry point address: 0x%lx"	, 0Ah, 0
	pheader_offset_str: db 	9,"Offset to program headers: 0x%lx"	, 0Ah, 0
	sheader_offset_str: db	 9,"Offset to section headers: 0x%lx"	, 0Ah, 0

	elf_header_size_str: db	 9,"ELF's header size: 0x%x"			, 0Ah, 0
	pheader_size_str: 	db	 9,"Size of a program header entry: 0x%x"	, 0Ah, 0
	pheader_num_str: 	db	 9,"Num of program header entries: 0x%x"	, 0Ah, 0

	psection_size_str: 	db 		9,"Size of a section header entry: 0x%x"	, 0Ah, 0
	psection_num_str: 	db 		9,"Num of section header entries: 0x%x"		, 0Ah, 0
	section_name_idx_str: db 	9,"Index of the names section in the table: 0x%d", 0Ah, 0


; program header
	pheader_str: db "Program Headers: ",0Ah,  0
	pheader_i_str: db "[02%x]", 0Ah, 0
	pheader_type_ref_str: db "type ref: 1-LOAD, 2-DYNAMIC, 3-INTERP, 4-NOTE, 6-PHDR, 0x6474e551-GNU_STACK", 0Ah, 0
	pheader_header_str: db `index | type |  physical address  |  virtual address   |   size on file   | size in memory | flags | align\n`, 0
	pheader_fmt_str: db `[%02d] 0x%08lx 0x%016lx 0x%016lx 0x%016lx 0x%016lx %04s 0x%016lx`, 0Ah, 0
	
; pheader_fmt32_str:
	pheader_fmt32_str: db `[%02d] 0x%08x 0x%08x 0x%08x 0x%08x 0x%08x %04s 0x%08x`, 0Ah, 0
	pheader_align_str: db "alignment: 0x%lx", 0Ah, 0
	str_fmt: db "%s", 0

; section header
	sheader_str: db "Section headers: ", 0
	sheader_header_str: db `index |         name       | type   | flags  |      vaddress    |     paddress    | size (on file)\n`, 0
	sheader_fmt_str: db `[%02d] %-20s  0x%08x  %04x  0x%016lx  0x%016lx  0x%016lx`, 0Ah, 0
	sheader_fmt32_str: db `[%02d] %-20s  0x%08x  %04x  0x%08x  0x%08x  0x%08x`, 0Ah, 0

section .text

global main
	main:
		push rbp
		mov rbp, rsp
		cmp edi, 1	;1 parament
		mov r12, rsi	; save r12
		jg argc_p	; check argc
		mov rsi, qword [r12]
		mov rdi, error_no_file
		call printf
		mov edi, 0
		leave
		ret
	argc_p:
		mov esi, 0	; readOnly
		mov rdi, qword[r12 + 0x8]
		call open
		cmp eax, -1	; check open fail
		jnz open_file
		mov rdi, error_open_fail
		call printf
		mov edi, 1
		leave
		ret	
	open_file:
		mov dword [elfFd], eax	
		call readElfHeader
		call readPheader
		call readSheader
		leave
		ret

;Convert String to Hex
global Convert2Hex	
	Convert2Hex:
		push rbp
		mov rbp, rsp

		mov r12, rsi
		mov r13d, edx
		call printf
		xor ebx, ebx
	dh_loop:
		cmp ebx, r13d
		jge dh_leave
		movsxd rbx, ebx
		mov al, byte[r12 + rbx]
		movzx eax, al
		mov esi, eax
		mov rdi, hex_fmt
		call printf
		inc ebx
		jmp dh_loop
	dh_leave:

		leave
		ret

global lseekStart	;seek from start
lseekStart:
	mov edx, 0		;seek_set   offset bytes into the file
	mov esi, edi	;offset
	mov edi, dword[elfFd];file_descriptor
	call lseek
	ret

global readElfHeader
readElfHeader:
	;
	;	rbp - 0xC: elf_header*
	;	rbp - 0x10: sizeOfHeader Elf32 or Elf64
	;		
	push rbp
	mov rbp, rsp
	sub rsp, 0x100

	mov rdi, elf_header
	call printf

	; determine 32bit or 64bit
	
	mov byte[rbp - 0x4], 0	; rbp - 0x4 = addrType
	mov edi, 0x4
	call lseekStart			; seek to 0x4
	
	mov edx, 0x1		;transfer_size
	lea rsi, [rbp - 0x4];buffer_pointer
	mov edi, dword[elfFd];file_descriptor
	call read
	movzx eax, byte[rbp - 0x4]
	mov dword[addrType], eax
	cmp eax, 2		; 2 -> 64bit, 1 -> 32bit
	jz h_for_64
		
	mov dword[rbp - 0x10], 0x34	; for 32 bit	
	mov edi, dword[rbp - 0x10]	;edi= size of header
	call malloc					; create a buffer with that size
	mov qword[rbp - 0xC], rax
	xor edi, edi
	call lseekStart
	
	mov edx, dword[rbp - 0x10];sizeOfHeader
	mov rsi, qword[rbp - 0xC] ;elf_header*
	mov rdi, qword[elfFd]
	call read


	mov edx, 0x4			; dump magic 
	mov rsi, qword[rbp - 0xC]
	mov rdi, magic_str
	call Convert2Hex

	mov r12, qword[rbp - 0xC]	; class
	movzx esi, byte[r12 + 0x4]	
	mov rdi, class_str
	call printf
	
	movzx esi, byte[r12 + 0x5]	; data
	mov rdi, data_str
	call printf
	
	movzx esi, word[r12 + 0x10]	; type
	mov rdi, type_str
	call printf
	
	movsxd rsi, dword[r12 + 0x18]	; entrypoint addr
	mov rdi, entrypoint_str
	call printf
	
	movsxd rsi, dword[r12 + 0x1C]	; offset to program header
	mov dword[pheaderInfo + 8], esi	
	mov rdi, pheader_offset_str
	call printf
	
	movsxd rsi, dword[r12 + 0x20]	; offset to section header
	mov dword[sheaderInfo + 8], esi	
	mov rdi, sheader_offset_str
	call printf
	
	movzx esi, word[r12 + 0x28]	; size of ELF header
	mov rdi, elf_header_size_str
	call printf
	
	movzx esi, word[r12 + 0x2A]	; size of a program header
	mov dword[pheaderInfo], esi	
	mov rdi, pheader_size_str
	call printf
	
	movzx esi, word[r12 + 0x2C]	; num of program headers
	mov dword[pheaderInfo + 4], esi	
	mov rdi, pheader_num_str
	call printf

	movzx esi, word[r12 + 0x2E]	; size of a section header
	mov dword[sheaderInfo], esi
	mov rdi, psection_size_str
	call printf
	
	movzx esi, word[r12 + 0x30]	; num of section headers
	mov dword[sheaderInfo + 4], esi
	mov rdi, psection_num_str
	call printf
	
	movzx esi, word[r12 + 0x32]	; name section index
	mov dword[namesSectionIdx], esi
	mov rdi, section_name_idx_str
	call printf
	jmp done
	
h_for_64:
	mov dword[rbp - 0x10], 0x40	; for 64bit	
	mov edi, dword[rbp - 0x10]
	call malloc
	mov qword[rbp - 0xC], rax
	xor edi, edi
	call lseekStart	; seek to its offset
	
	mov edx, dword[rbp - 0x10]
	mov rsi, qword[rbp - 0xC]
	mov rdi, qword[elfFd]
	call read

	mov edx, 0x4		; dump magic 
	mov rsi, qword[rbp - 0xC]
	mov rdi, magic_str
	call Convert2Hex

	mov r12, qword[rbp - 0xC]	; class
	movzx esi, byte[r12 + 0x4]	
	mov rdi, class_str
	call printf
	
	movzx esi, byte[r12 + 0x5]	; data
	mov rdi, data_str
	call printf
	
	movzx esi, word[r12 + 0x10]	; type
	mov rdi, type_str
	call printf
	
	mov rsi, qword[r12 + 0x18]	; entrypoint addr
	mov rdi, entrypoint_str
	call printf
	
	mov rsi, qword[r12 + 0x20]	; offset to program header
	mov dword[pheaderInfo + 8], esi	
	mov rdi, pheader_offset_str
	call printf
	
	mov rsi, qword[r12 + 0x28]	; offset to section header
	mov dword[sheaderInfo + 8], esi
	mov rdi, sheader_offset_str
	call printf
	
	movzx esi, word[r12 + 0x34]	; size of ELF header
	mov rdi, elf_header_size_str
	call printf
	
	movzx esi, word[r12 + 0x36]	; size of a program header entry
	mov dword[pheaderInfo], esi	
	mov rdi, pheader_size_str
	call printf
	
	movzx esi, word[r12 + 0x38]	; num of program headers
	mov dword[pheaderInfo + 4], esi	
	mov rdi, pheader_num_str
	call printf

	movzx esi, word[r12 + 0x3A]	; size of section header entry
	mov dword[sheaderInfo], esi
	mov rdi, psection_size_str
	call printf
	
	movzx esi, word[r12 + 0x3C]	; num of section headers
	mov dword[sheaderInfo + 4], esi
	mov rdi, psection_num_str
	call printf
	
	movzx esi, word[r12 + 0x3E]	; name section idx
	mov dword[namesSectionIdx], esi
	mov rdi, section_name_idx_str
	call printf

done:
	mov rdi, qword[rbp - 0xC]
	call free
	leave
	ret

global printNewline
	printNewline:
		sub rsp, 0x1
		mov byte[rsp], 0	; enter charecter
		mov rdi, rsp
		call puts	
		add rsp, 0x1
		ret
	
global setPheaderFlags	
	setPheaderFlags:
		push r12	; save r12
		push r13
		push rbp
		mov rbp, rsp

		mov r12, rdi	; flag
		mov r13d, esi	; intFlag

		test r13d, 0x4	; check  read
		jz r_done
		mov byte[r12], 0x52	; 'R'
	r_done:
		test r13d, 0x2	; check  write
		jz w_done
		mov byte[r12 + 1], 0x57	; 'W'
	w_done:
		test r13d, 0x1	; check  execute
		jz e_done
		mov byte[r12 + 2], 0x45	; 'E'
	e_done:

		leave
		pop r13
		pop r12
		ret


global readPheader
	readPheader:
		;	rbp - 0x10 -> pheader	
		;	rbp - 0x14 -> pheaderSize
		;
		push rbp
		mov rbp, rsp
		sub rsp, 0x100
		
		call printNewline
		mov rdi, pheader_str
		call puts
		mov rdi, pheader_type_ref_str
		call puts

		mov r12d, dword[pheaderInfo]		; size
		mov r13d, dword[pheaderInfo + 4]	; num
		mov r14d, dword[pheaderInfo + 8]	; offset
		mov eax, r12d
		imul r13d	
		mov dword[rbp - 0x14], eax 
		mov edi, eax
		call malloc		
		mov qword[rbp - 0x10], rax
		
		mov edi, r14d
		call lseekStart		
		mov edx, dword[rbp - 0x14]
		mov rsi, qword[rbp - 0x10]
		mov rdi, qword[elfFd]
		call read		; read pheader

		mov rdi, pheader_header_str
		call printf
		xor ebx, ebx	; index i = 0
pheader_loop:
		cmp ebx, r13d
		jge pheader_done
		
		mov eax, r12d
		imul ebx
		movsxd rax, eax
		mov r15, qword[rbp - 0x10]	; (byte*) buffer
		lea r15, [r15 + rax]		; buffer[entrySize*i]
		
		; consider 32bit or 64bit
		cmp dword[addrType], 2
		jnz pheader_32	

		push qword[r15 + 0x30]		; alignment

		mov esi, dword[r15 + 0x4]	; flags
		lea rdi, [rbp - 0x20]
		push rdi
		call setPheaderFlags
		
		push qword[r15 + 0x28]		; size in memory
		mov r9,	qword[r15 + 0x20]	; size on file
		mov r8,	qword[r15 + 0x10]	; virtual address
		mov rcx, qword[r15 + 0x8]	; physical address (file offset)
		mov edx, dword[r15 + 0]		; type
		mov esi, ebx				; index
		mov rdi, pheader_fmt_str
		xor rax, rax
		call printf
		inc ebx
		jmp pheader_loop
	pheader_32:
		mov eax, dword[r15 + 0x1c]	; alignment
		movsxd rax, eax
		push rax

		mov esi, dword[r15 + 0x18]	; flags
		lea rdi, [rbp - 0x20]
		push rdi 
		call setPheaderFlags
		
		mov eax, dword[r15 + 0x14]	; size in memory
		movsxd rax, eax
		push rax
		mov r9d, dword[r15 + 0x10]	; size on file
		mov r8d, dword[r15 + 0x8]	; virtual address
		mov ecx, dword[r15 + 0x4]	; physical address (file offset)
		mov edx, dword[r15 + 0]		; type
		mov esi, ebx				;index
		mov rdi, pheader_fmt32_str
		xor rax, rax
		call printf

	pheader_done:
		
		mov rdi, qword[rbp - 0x10]
		call free
		leave
		ret

	global readSheader
	readSheader:
		;	rbp - 0x10	sheaderBuffer
		;	rbp - 0x14	sheaderSize	
		;	rbp - 0x1c  names section
		push rbp
		mov rbp, rsp
		sub rsp, 0x100
		
		mov r12d, dword[sheaderInfo]		; entry size
		mov r13d, dword[sheaderInfo + 4]	; num
		mov r14d, dword[sheaderInfo + 8]	; offset
		mov eax, r12d
		imul r13d
		mov dword[rbp - 0x14], eax	; eax =  size of sections header
		mov edi, eax
		call malloc	
		mov qword[rbp - 0x10], rax
		mov edi, r14d
		call lseekStart	
		
		mov edx, dword[rbp - 0x14]
		mov rsi, qword[rbp - 0x10]		
		mov rdi, qword[elfFd]
		call read	; read all section headers
		
		; read names section to reference later
		mov eax, r12d
		imul eax, dword[namesSectionIdx]
		movsxd r15, eax
		add r15, qword[rbp - 0x10]	; r15 -> names section header
		cmp dword[addrType], 0x1
		jz sheader_names_section_32
		
		; for 64bit
		mov rdi, qword[r15 + 0x18]	
		call lseekStart
		mov rdi, qword[r15 + 0x20]	; size
		call malloc
		mov qword[rbp - 0x1c], rax
		mov rdx, qword[r15 + 0x20]
		mov rsi, qword[rbp - 0x1c]
		mov rdi, qword[elfFd]
		call read
		jmp sheader_names_section_done
		
	sheader_names_section_32:
		mov edi, dword[r15 + 0x10]	; seek to its offset
		call lseekStart
		mov edi, dword[r15 + 0x14]	; size
		call malloc
		mov qword[rbp - 0x1c], rax
		mov edx, dword[r15 + 0x14]
		mov rsi, qword[rbp - 0x1c]
		mov rdi, qword[elfFd]
		call read	; done

	sheader_names_section_done:
		call printNewline
		mov rdi, sheader_str
		call puts
		mov rdi, sheader_header_str
		call puts

		xor ebx, ebx	; index = 0
	sheader_loop:
		cmp ebx, r13d
		jge sheader_loop_done
		mov eax, r12d
		imul ebx
		movsxd rax, eax				
		mov rcx, qword[rbp - 0x10]	; 
		lea r15, [rcx + rax]	; r15 = (byte*)buffer[i*size] 
		mov eax, dword[addrType]
		cmp eax, 0x2	; 32bit or 64
		jnz sheader_32
	sheader_64:

		mov edx, dword[r15 + 0]
		movsxd rdx, edx
		add rdx, qword[rbp - 0x1c]	; section name

		push qword[r15 + 0x20]		; size in bytes
		push qword[r15 + 0x18]		; file offset
		mov r9, qword[r15 + 0x10]	; vaddr
		mov r8, qword[r15 + 0x8]	; flags
		mov ecx, dword[r15 + 0x4]	; type
		mov esi, ebx				; index
		mov rdi, sheader_fmt_str
		xor eax, eax
		call printf
		inc ebx
		jmp sheader_loop
		
	sheader_32:

		mov edx, dword[r15 + 0]
		movsxd rdx, edx				;mov data form string to string
		add rdx, qword[rbp - 0x1c]	; section name

		mov eax, dword[r15 + 0x14]
		mov dword[rsp+0x8], eax		; size in bytes, although use dword but must push qword
		mov eax, dword[r15 + 0x10]

		mov dword[rsp], eax			; paddr
		mov r9d, dword[r15 + 0xC]	; vaddr
		mov esi, dword[r15 + 0x8]	; flags
		mov ecx, dword[r15 + 0x4]	; type
		mov esi, ebx				; index
		mov rdi, sheader_fmt32_str
		xor eax, eax
		call printf

	sheader_loop_done:
		mov rdi, qword[rbp - 0x10]
		call free
		leave
		ret

global setSectionheaderFlags64	
setSectionheaderFlags64:
	push r12	; save r12
	push r13
	push rbp
	mov rbp, rsp

	mov r12, rdi	; flag
	mov r13, r8	; intFlag
	test r13d, 0x1	; check  write
	jz sw_done64
	mov byte[r12], 0x57	; 'W'

sw_done64:
	test r13d, 0x2	; check  alloc
	jz sa_done64
	mov byte[r12 + 1], 0x41	; 'A'

sa_done64:
	test r13d, 0x4	; check  execute
	jz sX_done64
	mov byte[r12 + 2], 0x58	; 'X'
sX_done64:
	test r13d, 0x0000000010	; check  merge
	jz sm_done64
	mov byte[r12 + 3], 0x4D	; 'M'
sm_done64:
	test r13d, 0x20	; check  strings
	jz ss_done64
	mov byte[r12 + 4], 0x53	; 'S'
ss_done64:
	test r13d, 0x40	; check  info
	jz si_done64
	mov byte[r12 + 5], 0x49	; 'I'
si_done64:
	test r13d, 0x80	; check  link order
	jz sL_done64
	mov byte[r12 + 6], 0x4C	; 'L '
sL_done64:
	test r13d, 0x100	; check  extra OS processing required
	jz sO_done64
	mov byte[r12 + 7], 0x4F	; 'O '
 
sO_done64:
	test r13d, 0x200	; check  group
	jz sg_done64
	mov byte[r12 + 8], 0x47	; 'G'
sg_done64:
	test r13d, 0x400	; check  TLS
	jz st_done64
	mov byte[r12 + 9], 0x54	; 'T'
st_done64:
	test r13d, 0x0ff00000; check  compressed
	jz sc_done64
	mov byte[r12 + 10], 0x43	; ' C'
sc_done64:
	test r13d, 0x40000000; check  OS specific
	jz so_done64
	mov byte[r12 + 11], 0x6F	; 'o'
so_done64:
	test r13d, 0x80000000; E (exclude)
	jz sE_done64
	mov byte[r12 + 12], 0x45	
sE_done64:
	test r13d,0x10000000; l (large)
	jz sl_done64
	mov byte[r12 + 13], 0x6C	;
sl_done64:
	test r13d, 0xf0000000	; p (processor specific)
	jz sp_done64
	mov byte[r12 + 14], 0x70	
sp_done64:
	mov byte[r12 + 15], 0x58	; 'x' unknown
	leave
	pop r13
	pop r12
	ret




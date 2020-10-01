bits 32
global _start
%include "read_write.asm"

SECTION .data
	msg						db		"Nhap vao ten file: ", 0
	msg_len					equ		$-msg
	title_ELF_Header		db		"ELF Header:", 10, 0
	title_ELF_Header_len	equ		$-title_ELF_Header
	Magik_print				db		"Magic: ", 0
	Magik_len				equ		$-Magik_print

	CLASS					db		"Class: "
	CLASS_len				equ		$-CLASS
	ELF32					db		"ELF32"
	ELF32_len				equ		$-ELF32
	ELF64					db		"ELF64"
	ELF64_len				equ		$-ELF64

	endian_data				db		"Data: "
	endian_data_len			equ		$-endian_data
	little_endian			db		"Little endian"
	little_endian_len		equ		$-little_endian
	big_endian				db		"Big endian"
	big_endian_len			equ		$-big_endian
	version					db		"Version: "
	version_len				equ		$-version
	osabielf				db		"OS/ABI: "
	osabi_len				equ		$-osabielf
	typeelf					db		"Type: "
	type_len				equ		$-typeelf
	abi_version				db		"Abi Version: "
	abi_version_len			equ		$-abi_version
	machine_print			db		"Machine: "
	machine_len				equ		$-machine_print
	machine_version			db		"Version: "
	machine_version_len		equ		$-machine_version
	entry_point_addr		db		"entry point address: "
	entry_point_len			equ		$-entry_point_addr
	start_of_prog_head		db		"Start of program header: "
	start_prog_head_len		equ		$-start_of_prog_head
	start_of_section		db		"Start of section header: "
	start_section_len		equ		$-start_of_section
	flag_header				db		"The flag header: "
	flag_header_len			equ		$-flag_header
	size_header				db		"Size of this header: "
	size_header_len			equ		$-size_header
	size_prog				db		"Size of program header: "
	size_prog_len			equ		$-size_prog
	num_prog				db		"Number of program header: "
	num_prog_len			equ		$-num_prog
	size_section			db		"The size of section header: "
	size_section_len		equ		$-size_section
	num_section				db		"Number of section header: "
	num_section_len			equ		$-num_section

	section_string			db		"Section header string table index: "
	section_string_len		equ		$-section_string

	prog_header				db		"Program Headers: "
	prog_header_len			equ		$-prog_header
	offset_header			db		"Offset: "
	offset_header_len		equ		$-offset_header
	virtual_addr_header		db		"Virtual addr: "
	virtual_addr_len		equ		$-virtual_addr_header
	physical_addr_head		db		"Physical addr: "
	physical_addr_len		equ		$-physical_addr_head
	file_size_head			db		"File size: "
	file_size_len			equ		$-file_size_head
	mem_size_head			db		"Mem size: "
	mem_size_len			equ		$-mem_size_head
	flags_head				db		"Flg: "
	flags_head_len			equ		$-flags_head
	Align_head				db		"Align head: "
	Align_head_len			equ		$-Align_head

	sec_head				db		"Section Headers: "
	section_head_len		equ		$-sec_head
	Name					db		"Name: "
	Name_len				equ		$-Name
	Addr					db		"Addr: "
	Addr_len				equ		$-Addr
	sec_size				db		"Size: "
	sec_size_len			equ		$-sec_size
	ES_size					db		"ES: "
	ES_size_len				equ		$-ES_size
	LK_sec					db		"LK: "
	LK_sec_len				equ		$-LK_sec
	Inf_sec					db		"Inf: "
	Inf_sec_len				equ		$-Inf_sec
	Al_sec					db		"Al: "
	Al_sec_len				equ		$-Al_sec

	Segment_header			db		"Section to segment:"
	Segment_header_len		equ		$-Segment_header

SECTION .bss
	file_name			resb	300
	file_size			resd	1
	fd					resd	1

	string_table_addr	resd	1
	section_addr		resd	1
	process_addr		resd	1
	base_addr			resd	1

	; struct cho elf_header
	elf_header:
		EI_MAG			resb	4
		EI_CLASS		resb	1
		EI_DATA			resb	1 
		EI_VERSION		resb	1
		EI_OSABI		resb	1
		EI_ABIVERSION	resb	1
		EI_PAD			resb	7
		e_type			resw	1
		e_machine		resw	1
		e_version		resd	1
		e_entry			resd	1
		e_phoff			resd	1
		e_shoff			resd	1
		e_flags			resd	1
		e_ehsize		resw	1
		e_phentsize		resw	1
		e_phnum			resw	1
		e_shentsize		resw	1
		e_shnum			resw	1
		e_shstrndx		resw	1
	
	section_header:
		sh_name			resd	1
		sh_type			resd	1
		sh_flags		resd	1
		sh_addr			resd	1
		sh_offset		resd	1
		sh_size			resd	1
		sh_link			resd	1
		sh_info			resd	1
		sh_addralign	resd	1
		sh_entsize		resd	1
	
	process_header:
		p_type			resd	1
		p_offset		resd	1
		p_vaddr			resd	1
		p_paddr			resd	1
		p_filesz		resd	1
		p_memz			resd	1
		p_flags			resd	1
		p_algin			resd	1

	elf_process_header	resd	80
	elf_section_header	resd	200


SECTION .text
_start:
	push	msg_len
	push	msg
	call	print

	push	300
	push	file_name
	call	get

	push	file_name
	call	str_len

	mov		byte [file_name+eax], 0		; cho null terminate thay cho \n
	push	file_name
	call	open_file_read
	mov		dword [fd], eax

	push	dword [fd]
	call	GetFileSize
	mov		dword [file_size], eax

	push	dword [fd]
	call	mmap_file
	mov		dword [base_addr], eax

	lea		ebx, elf_header
	push	ebx
	push	eax
	call	GetELFHeader
	call	printELFHeader
	call	print_nl

	mov		ebx, dword [base_addr]
	add		ebx, dword [e_phoff]
	mov		dword [process_addr], ebx	; luu dia chi bat dau process vao process_addr

	movzx	eax, word [e_phnum]
	push	eax
	push	ebx
	call	PrintProgHeader 
	mov		ebx, dword [base_addr]
	add		ebx, dword [e_shoff]
	mov		dword [section_addr], ebx	; luu dia chi bat dau section vao section_addr
	movzx	eax, word [e_shnum]
	push	eax
	push	ebx
	call	PrintSectionHeader

	call	PrintSegmentHeader

	mov		eax, dword [fd]
	push	eax
	call	close_file

	mov		eax, dword [base_addr]
	push	eax
	push	dword [file_size]
	call	munmap_file

	; ket thuc chuong trinh
	mov		eax, 0x1		; Su dung ham sys_exit
	mov		ebx, 0			; Tra ve khong co loi
	push	print			; Khong quan trong do sau khi sysenter thi chuong trinh thoat
	push	ecx				; Luu ecx, edx va ebp
	push	edx
	push	ebp
	mov		ebp, esp		; dat mot base pointer moi cho sysenter
	sysenter				; Dung sysenter de goi system goi sys_exit

; tuong duong voi: GetDOSHeader(void *addr, void *save_addr)
GetELFHeader:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	mov		esi, dword [ebp+8]
	mov		edi, dword [ebp+12]
	mov		ecx, 0x34
	rep		movsb

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret		8


; tuong duong voi: void PrintProgHeader(void *addr, int num_prog_head)
PrintProgHeader:
	push	ebp
	mov		ebp, esp
	sub		esp, 4
	push	ebx
	push	esi
	push	edi

	push	prog_header_len
	push	prog_header
	call	print
	call	print_nl

	.print_process_header:
		push	dword [ebp+8]
		call	GetProcessHeader
		mov		dword [ebp-4], eax

		call	print_tab
		push	type_len
		push	typeelf
		call	print
		push	dword [p_type]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	offset_header_len
		push	offset_header
		call	print
		push	dword [p_offset]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	virtual_addr_len
		push	virtual_addr_header
		call	print
		push	dword [p_vaddr]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	physical_addr_len
		push	physical_addr_head
		call	print
		push	dword [p_paddr]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	file_size_len
		push	file_size_head
		call	print
		push	dword [p_filesz]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	mem_size_len
		push	mem_size_head
		call	print
		push	dword [p_memz]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	mem_size_len
		push	mem_size_head
		call	print
		push	dword [p_memz]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	flags_head_len
		push	flags_head
		call	print
		push	dword [p_flags]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	Align_head_len
		push	Align_head
		call	print
		push	dword [p_algin]
		call	print_hex_prefix
		call	print_nl

		call	print_nl
		call	print_nl

		mov		eax, dword [ebp-4]
		mov		dword [ebp+8], eax
		dec		dword [ebp+12]
		mov		ecx, dword [ebp+12]
		test	ecx, ecx
		jnz		.print_process_header

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret		

; tuong duong voi: int GetProcessHeader(void *addr)
; tra ve vi tri tiep theo process header
GetProcessHeader:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	lea		edi, process_header
	mov		esi, dword [ebp+8]
	mov		ecx, 8
	rep		movsd
	mov		eax, esi

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret		4

; tuong duong voi: void PrintSectionHeader(void *addr, int number_of_section)
PrintSectionHeader:
	push	ebp
	mov		ebp, esp
	sub		esp, 8
	push	ebx
	push	esi
	push	edi

	push	section_head_len
	push	sec_head
	call	print
	call	print_nl

	; lay vi tri cua string data header
	movzx	ebx, word [e_shstrndx]
	movzx	ecx, word [e_shentsize]
	mov		edx, dword [e_shoff]
	imul	ebx, ecx
	add		edx, ebx
	mov		eax, [base_addr]
	add		eax, edx
	push	eax
	call	GetSectionHeader
	; lay offset cho string data header
	mov		eax, dword [sh_offset]
	mov		ebx, [base_addr]
	add		ebx, eax
	mov		dword [string_table_addr], ebx
	mov		dword [ebp-8], ebx

	.print_section_header:
		push	dword [ebp+8]
		call	GetSectionHeader
		mov		dword [ebp-4], eax

		call	print_tab
		push	Name_len
		push	Name
		call	print
		mov		ebx, dword [ebp-8]
		add		ebx, dword [sh_name]
		push	ebx
		call	print_without_len
		call	print_nl

		call	print_tab
		push	type_len
		push	typeelf
		call	print
		push	dword [sh_type]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	Addr_len
		push	Addr
		call	print
		push	dword [sh_addr]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	offset_header_len
		push	offset_header
		call	print
		push	dword [sh_offset]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	sec_size_len
		push	sec_size
		call	print
		push	dword [sh_size]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	ES_size_len
		push	ES_size
		call	print
		push	dword [sh_entsize]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	flags_head_len
		push	flags_head
		call	print
		push	dword [sh_flags]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	LK_sec_len
		push	LK_sec
		call	print
		push	dword [sh_link]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	Inf_sec_len
		push	Inf_sec
		call	print
		push	dword [sh_info]
		call	print_hex_prefix
		call	print_nl

		call	print_tab
		push	Al_sec_len
		push	Al_sec
		call	print
		push	dword [sh_addralign]
		call	print_hex_prefix
		call	print_nl

		mov		eax, dword [ebp-4]
		mov		dword [ebp+8], eax
		dec		dword [ebp+12]
		mov		ecx, dword [ebp+12]
		call	print_nl
		call	print_nl
		test	ecx, ecx
		jnz		.print_section_header


	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret		

; tung duong voi: void GetSectionHeader(void *addr)
GetSectionHeader:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	lea		edi, section_header
	mov		esi, dword [ebp+8]
	mov		ecx, 10
	rep		movsd
	mov		eax, esi

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret		4

; tuong duong voi: void printELFHeader()
printELFHeader:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	push	title_ELF_Header_len
	push	title_ELF_Header
	call	print

	call	print_tab
	push	Magik_len
	push	Magik_print
	call	print

	mov		ebx, EI_MAG
	mov		ecx, 16
	.print_magik:
		movzx	eax, byte [ebx]
		push	eax
		call	print_hex
		call	print_space
		inc		ebx
	LOOP	.print_magik
	call	print_nl
	
	call	print_class
	call	print_data
	call	print_version
	call	printOS

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret	

; tuong duong voi: void print_class()
print_class:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	call	print_tab
	push	CLASS_len
	push	CLASS
	call	print
	movzx	eax, byte [EI_CLASS]
	sub		eax, 1
	test	eax, eax
	jz		.print_32
	push	ELF64_len
	push	ELF64
	call	print

	.print_32:
		push	ELF32_len
		push	ELF32
		call	print

	call	print_nl

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret	

print_data:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	call	print_tab
	push	endian_data_len
	push	endian_data
	call	print
	movzx	eax, byte [EI_CLASS]
	sub		eax, 1
	test	eax, eax
	jz		.print_little
	push	big_endian_len
	push	big_endian
	call	print

	.print_little:
		push	little_endian_len
		push	little_endian
		call	print

	call	print_nl

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret	

print_version:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	call	print_tab
	push	version_len
	push	version
	call	print
	movzx	eax, byte [EI_CLASS]
	push	eax
	call	print_num

	call	print_nl

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret	

printOS:
	push	ebp
	mov		ebp, esp
	push	ebx
	push	esi
	push	edi

	call	print_tab
	push	osabi_len
	push	osabielf
	call	print
	
	movzx	eax, byte [EI_OSABI]
	push	eax
	call	print_hex_prefix
	call	print_nl

	call	print_tab
	push	abi_version_len
	push	abi_version
	call	print

	movzx	eax, byte [EI_ABIVERSION]
	push	eax
	call	print_hex_prefix
	call	print_nl

	; type
	call	print_tab
	push	type_len
	push	typeelf
	call	print

	movzx	eax, word [e_type]
	push	eax
	call	print_hex_prefix
	call	print_nl

	; machine
	call	print_tab
	push	machine_len
	push	machine_print
	call	print

	movzx	eax, word [e_machine]
	push	eax
	call	print_hex_prefix
	call	print_nl

	; machine version
	call	print_tab
	push	machine_version_len
	push	machine_version
	call	print

	mov		eax, dword [e_version]
	push	eax
	call	print_hex_prefix
	call	print_nl

	; entry
	call	print_tab
	push	entry_point_len
	push	entry_point_addr
	call	print

	mov		eax, dword [e_entry]
	push	eax
	call	print_hex_prefix
	call	print_nl

	; program header
	call	print_tab
	push	start_prog_head_len
	push	start_of_prog_head
	call	print

	mov		eax, dword [e_phoff]
	push	eax
	call	print_num
	call	print_nl

	; section header
	call	print_tab
	push	start_section_len
	push	start_of_section
	call	print

	mov		eax, dword [e_shoff]
	push	eax
	call	print_num
	call	print_nl

	; flags
	call	print_tab
	push	flag_header_len
	push	flag_header
	call	print

	mov		eax, dword [e_flags]
	push	eax
	call	print_hex_prefix
	call	print_nl

	; size of header
	call	print_tab
	push	size_header_len
	push	size_header
	call	print

	movzx	eax, word [e_ehsize]
	push	eax
	call	print_num
	call	print_nl

	; size of program header
	call	print_tab
	push	size_prog_len
	push	size_prog
	call	print

	movzx	eax, word [e_phentsize]
	push	eax
	call	print_num
	call	print_nl

	; number of program header
	call	print_tab
	push	num_prog_len
	push	num_prog
	call	print

	movzx	eax, word [e_phnum]
	push	eax
	call	print_num
	call	print_nl

	; size of section header
	call	print_tab
	push	size_section_len
	push	size_section
	call	print

	movzx	eax, word [e_shnum]
	push	eax
	call	print_num
	call	print_nl

	; number of section header
	call	print_tab
	push	num_section_len
	push	num_section
	call	print

	movzx	eax, word [e_shnum]
	push	eax
	call	print_num
	call	print_nl

	; section header string table
	call	print_tab
	push	section_string_len
	push	section_string
	call	print

	mov		eax, dword [e_shstrndx]
	push	eax
	call	print_num
	call	print_nl

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret

; tuong duong voi: void PrintSegmentHeader()
PrintSegmentHeader:
	push	ebp
	mov		ebp, esp
	sub		esp, 8
	push	ebx
	push	esi
	push	edi

	push	Segment_header_len
	push	Segment_header
	call	print
	call	print_nl
	
	mov		eax, dword [process_addr]
	mov		dword [ebp-4], eax
	movzx	eax, word [e_phnum]
	mov		ecx, eax
	.next_process_header:
		mov		dword [ebp-8], ecx
		mov		eax, dword [ebp-4]
		push	eax
		call	GetProcessHeader
		mov		dword [ebp-4], eax

		call	print_section_segment
		call	print_nl
		mov		ecx, dword [ebp-8]
		LOOP	.next_process_header

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret

; tuong duong voi: void print_section_segment()
print_section_segment:
	push	ebp
	mov		ebp, esp
	sub		esp, 12		; ebp-4: next_section_header
						; ebp-8: last_section_header
						; ebp-12: i
	push	ebx
	push	esi
	push	edi

	; get the section offset that is equal to process offset
	mov		eax, dword [section_addr]
	mov		dword [ebp-4], eax
	movzx	eax, word [e_shnum]
	mov		dword [ebp-12], eax

	.find_sectin_offset:
		mov		ecx, dword [ebp-12]
		test	ecx, ecx
		jz		.DONE_print_section_segment

		mov		eax, dword [ebp-4]
		mov		dword [ebp-8], eax
		push	eax
		call	GetSectionHeader
		mov		dword [ebp-4], eax

		dec		dword [ebp-12]
		mov		eax, dword [p_offset]
		cmp		eax, dword [sh_offset]
		jne		.find_sectin_offset

		push	dword [ebp-8]
		call	print_all_name

	.DONE_print_section_segment:
		pop		edi
		pop		esi
		pop		ebx
		mov		esp, ebp
		pop		ebp
		ret		

; tuong duong voi: void print_all_name(void *addr)
print_all_name:
	push	ebp
	mov		ebp, esp
	sub		esp, 4
	push	ebx
	push	esi
	push	edi

	mov		eax, dword [sh_size]
	mov		dword [ebp-4], 0
	mov		esi, dword [ebp+8]

	; lay header dau tien
	push	esi
	call	GetSectionHeader
	mov		esi, eax
	mov		eax, dword [sh_size]
	add		[ebp-4], eax
	.loop_print_segment:
		mov		ebx, dword [string_table_addr]
		add		ebx, dword [sh_name]
		push	ebx
		call	print_without_len
		call	print_space

		push	esi
		call	GetSectionHeader
		mov		esi, eax
		mov		eax, dword [sh_size]
		add		dword [ebp-4], eax

		mov		eax, dword [ebp-4]
		cmp		eax, dword [p_filesz]
		jb		.loop_print_segment

	pop		edi
	pop		esi
	pop		ebx
	mov		esp, ebp
	pop		ebp
	ret		4

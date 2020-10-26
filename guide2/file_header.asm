.386
.model flat, stdcall
option casemap : none

include D:\viettel\tuan_4\read_write.asm
include D:\masm32\include\windows.inc
include D:\masm32\include\user32.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\user32.lib
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib


.data
	; file_name 			db 	'D:\viettel\tuan_4\test.exe', 0
	; file_name_len 		equ 	$-file_name
	
	insert_file 		db 	'Nhap vao day du dia chi den file (vi du: D:\thuc_tap\test.exe): '
	insert_file_len		equ  $-insert_file
	Warning 			db 	'file nhap vao phai la 32 bit'
	Warning_len 		equ  $-Warning

	PE_signature 		db 	'PE', 0, 0
	e_magic_word 		db 	'DOS magic: ', 0
	e_magic_len_word 	equ 	$-e_magic_word
	e_lfanew_word 		db 	'file address new exe file: ', 0
	e_lfanew_word_len 	equ 	$-e_lfanew_word
	DOS_header_print 	db 	'The DOS header', 13, 10
	DOS_header_len 		equ 	$-DOS_header_print
	file_header_print 	db 	'The PE file header: ', 13, 10
	file_header_len 	equ 	$-file_header_print
	pe_signature 		db 	'PE signature: 	', 0
	pe_signature_len 	equ  	$-pe_signature
	pe_machine_print 	db  	'The machine signature: ', 0
	pe_machine_len 		equ 	$-pe_machine_print
	pe_charac_print 	db  	'The characteristics signature: ', 0
	pe_charac_len 		equ 	$-pe_charac_print
	optional_header		db 	'The PE optional header: ', 13, 10, 0
	opetional_head_len 	equ 	$-optional_header
	optional_magic 		db 	'The optional header magic: ', 0
	optional_magic_len 	equ 	$-optional_magic
	optional_codesize 	db 	'The size of code: ', 0
	optional_codesize_len equ 	$-optional_codesize
	optional_init 		db 	'The size of initilise data: ', 0
	optional_init_len 	equ 	$-optional_init
	optional_major 		db 	'The major version linker: ', 0
	optional_major_len 	equ 	$-optional_major
	optional_minor 		db 	'The minor version linker: ', 0
	optional_minor_len 	equ 	$-optional_minor
	optional_uninit 	db 	'The size of uninitialise data: ', 0
	optional_uninit_len equ 	$-optional_uninit
	entry_point 		db 	'The address entry point: ' , 0
	entry_point_len 	equ 	$-entry_point
	optional_basecode 	db 	'The size of base code: ', 0
	optional_basecode_len equ 	$-optional_basecode
	
	import_header_print db 		'The import section header: ', 0
	import_header_len 	equ 	$-import_header_print
	export_header_print db 		'The export section header:', 0
	export_header_len 	equ 	$-export_header_print
	
    section_header          db      'Section header: ', 0
    section_header_len      equ     $-section_header
	Name_section_header     db      'Name: ', 0
    Name_section_len        equ     $-Name_section_header
	virtual_addr_print 	db 	'Virtual size: ', 0
	virtual_addr_len 	equ 	$-virtual_addr_print
	virtual_size_print 	db 	'Virtual addr: ', 0
	virtual_size_len 	equ 	$-virtual_size_print
    raw_data_print 		db 	'Raw size: ', 0
	raw_data_len 		equ 	$-raw_data_print
	raw_size_print		db 	'Raw addr: ', 0
	raw_size_len 		equ 	$-raw_size_print
	section_print_ptr 	dd 	raw_data_print, raw_size_print, virtual_addr_print, virtual_size_print
	section_len_ptr 	dd 	raw_data_len, raw_size_len, virtual_addr_len, virtual_size_len
	
.data?
	rva_name_table 	DWORd 	40 		DUP(?)
	hex_str 		BYTE 	16 		DUP(?)
	stdInHandle 	HANDLE 	?
	stdOutHandle 	HANDLE 	?
	hFile 			HANDLE 	?
	hMapping 		HANDLE 	?
	file_size 		DWORD 	?
	lpFile 			LPBYTE 	?
	file_name 		BYTE 	1024  	DUP(?)
	file_name_len 	DWORD 	?
	DosHeaderOffset DWORD 	?
	
	; struct cho dos header
	e_magic           WORD      ?
	e_lfanew          DWORD     ?
	
	; struct cho pe header
	Signature         	 	DWORD   ? 	; signature
	
	; file_header
	Machine               	WORD    ?
	NumberOfSections      	WORD    ?
	TimeDateStamp         	DWORD   ?
	PointerToSymbolTable  	DWORD   ?
	NumberOfSymbols       	DWORD   ?
	SizeOfOptionalHeader  	WORD    ?
	Characteristics       	WORD    ?
	
	; optional header
	Magic                         WORD       ?
	MajorLinkerVersion            BYTE       ?
	MinorLinkerVersion            BYTE       ?
	SizeOfCode                    DWORD      ?
	SizeOfInitializedData         DWORD      ?
	SizeOfUninitializedData       DWORD      ?
	AddressOfEntryPoint           DWORD      ?
	BaseOfCode                    DWORD      ?
	BaseOfData                    DWORD      ?
	ImageBase                     DWORD      ?
	SectionAlignment              DWORD      ?
	FileAlignment                 DWORD      ?
	MajorOperatingSystemVersion   WORD       ?
	MinorOperatingSystemVersion   WORD       ?
	MajorImageVersion             WORD       ?
	MinorImageVersion             WORD       ?
	MajorSubsystemVersion         WORD       ?
	MinorSubsystemVersion         WORD       ?
	Win32VersionValue             DWORD      ?
	SizeOfImage                   DWORD      ?
	SizeOfHeaders                 DWORD      ?
	CheckSum                      DWORD      ?
	Subsystem                     WORD       ?
	DllCharacteristics            WORD       ?
	SizeOfStackReserve            DWORD      ?
	SizeOfStackCommit             DWORD      ?
	SizeOfHeapReserve             DWORD      ?
	SizeOfHeapCommit              DWORD      ?
	LoaderFlags                   DWORD      ?
	NumberOfRvaAndSizes           DWORD      ?
	
	export_director    		  	  DWORD      ?
	size_export             	  DWORD      ?
	import_director    			  DWORD      ?
	size_import             	  DWORD      ?
	VirtualAddress3    			  DWORD      ?
	isize3             			  DWORD      ?
	VirtualAddress4    			  DWORD      ?
	isize4             			  DWORD      ?
	VirtualAddress5    			  DWORD      ?
	isize5             			  DWORD      ?
	VirtualAddress6    			  DWORD      ?
	isize6             			  DWORD      ?
	VirtualAddress7    			  DWORD      ?
	isize7             			  DWORD      ?
	VirtualAddress8    			  DWORD      ?
	isize8             			  DWORD      ?
	VirtualAddress9    			  DWORD      ?
	isize9            			  DWORD      ?
	VirtualAddress10    	      DWORD      ?
	isize10             		  DWORD      ?
	VirtualAddress11    		  DWORD      ?
	isize11             		  DWORD      ?
	VirtualAddress12    		  DWORD      ?
	isize12             		  DWORD      ?
	VirtualAddress13    		  DWORD      ?
	isize13             		  DWORD      ?
	VirtualAddress14    		  DWORD      ?
	isize14             		  DWORD      ?
	VirtualAddress15    		  DWORD      ?
	isize15             		  DWORD      ?
	VirtualAddress16    		  DWORD      ?
	isize16             		  DWORD      ?
	
	; section header struct
    Name1 						BYTE 	8 dup(?)
    VirtualSize 				DWORD   ?
    VirtualAddress 				DWORD   ?
    SizeOfRawData 				DWORD   ?
    PointerToRawData 			DWORD   ?
    PointerToRelocations 		DWORD  	?
    PointerToLinenumbers 		DWORD 	?
    NumberOfRelocations 		WORD  	?
    NumberOfLinenumbers 		WORD  	?
    Characteristics_section 	DWORD   ?
	
	; name import struct
	Hint_import 				WORD   ?
    Name_import 				BYTE    80 dup(?)
	
	; struct cho import_description
    Characteristics_import 		DWORD   ?
    TimeDate_import				DWORD   ?
    ForwarderChain 				DWORD   ?
    Name_import_description 	DWORD   ?
    FirstThunk 					DWORD   ?
    
    ; struct cho export directory
    Characteristics_export    DWORD      ?
    TimeDateStamp_export      DWORD      ?
    MajorVersion_export       WORD       ?
    MinorVersion_export       WORD       ?
    nName                     DWORD      ?
    nBase                     DWORD      ?
    NumberOfFunctions         DWORD      ?
    NumberOfNames             DWORD      ?
    AddressOfFunctions        DWORD      ?
    AddressOfNames            DWORD      ?
    AddressOfNameOrdinals     DWORD      ?
	
.code
start:
    push    STD_INPUT_HANDLE
    call    GetStdHandle                    ; lay stdin handle va luu vao eax
    mov     stdInHandle, eax                ; Luu stdin handle vao stdInHandle
    
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle
    mov     stdOutHandle, eax

	push 	stdOutHandle
	push 	dword ptr [Warning_len]
	push 	offset Warning
	call 	print
	call 	print_nl
	
	push 	stdOutHandle
	push 	dword ptr [insert_file_len]
	push 	offset insert_file
	call 	print
	
	lea 	eax, file_name
	push 	stdInHandle
	push 	1024
	push 	eax
	call 	get
	
	lea 	eax, file_name
	push 	eax
	call 	str_len
	mov 	file_name_len, eax
	
	lea 	eax, file_name
	mov 	ebx, file_name_len
	mov 	word ptr [eax+ebx], 0
	
	lea 	eax, file_name
	push 	NULL
	push 	FILE_ATTRIBUTE_NORMAL
	push 	OPEN_ALWAYS
	push 	NULL
	push 	0
	push 	FILE_READ_ACCESS OR FILE_WRITE_ACCESS
	push 	eax
	call 	CreateFile
	mov 	hFile, eax
	call 	GetLastError

	mov 	eax, hFile
	push 	NULL
	push 	eax
	call 	GetFileSize
	mov 	file_size, eax
	
	mov 	eax, hFile
	mov 	ebx, file_size
	push	NULL
	push 	ebx
	push 	0
	push 	PAGE_READWRITE
	push 	NULL
	push 	eax
	call 	CreateFileMapping
	mov 	hMapping, eax

	mov 	eax, hMapping
	mov 	ebx, file_size
	push 	file_size
	push 	0
	push 	0
	push 	FILE_MAP_READ OR FILE_MAP_WRITE
	push 	eax
	call 	MapViewOfFile
	mov 	lpFile, eax
	
	mov 	eax, lpFile
	push 	eax
	call 	GetDosHeader
	
	; dua den PE header
	mov 	DosHeaderOffset, eax
	mov 	ebx, lpFile
	add 	ebx, eax 
	push 	ebx
	call 	GetPeHeader
	
	; in ra dos header
	call 	print_dos_header
	call 	print_nl
	call 	print_nl
	
	; in ra pe header
	call 	print_file_header
	call 	print_nl
	call 	print_nl
	
	; in ra optional header
	call 	print_optional_header
	call 	print_nl
	call 	print_nl
	
	; in ra ten section header
	mov 	eax, lpFile
	add 	eax, dword ptr [DosHeaderOffset]
	add 	eax, 248
	movzx 	ebx, word ptr [NumberOfSections]
	push 	ebx
	push 	eax
	call 	print_section_header
	call 	print_nl
	call 	print_nl
	
	; in ra cac ten cua import header
	mov 	eax, lpFile
	add 	eax, dword ptr [DosHeaderOffset]
	add 	eax, 248                          ; do dai cua pe32 header
	movzx 	ebx, word ptr [NumberOfSections]
	push 	ebx
	push 	eax
	push 	dword ptr [import_director]
	call 	print_import_header
    call    print_nl
    call    print_nl
        
    ; in ra ten cua export header
    mov     eax, lpFile
    add     eax, dword ptr [DosHeaderOffset]
	add     eax, 248
	movzx   ebx, word ptr [NumberOfSections]
	push    ebx
	push    eax
	push    dword ptr [export_director]
	call    print_export_header
	call    print_nl
	call    print_nl
        

	
	mov 	eax, lpFile
	push 	eax
	call 	UnmapViewOfFile
	
	mov 	eax, hMapping
	push 	eax
	call 	UnmapViewOfFile
	
	mov 	eax, hFile
	push 	eax
	call 	CloseHandle

	; ket thuc chuong trinh
	xor 	eax, eax
	ret

; tuong duong voi: int GetDosHeader(void *lpFile)
; tra ve 
GetDosHeader:
	push 	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	mov 	edi, dword ptr [ebp+8]
	
	; kiem tra xem co phai dos header
	cmp 	byte ptr [edi], 'M'
	jne 	DONE_getDos
	cmp 	byte ptr [edi+1], 'Z'
	jne 	DONE_getDos
	
	mov 	word ptr [e_magic] , 'ZM'
	; lay offset cua pe header
	mov 	eax, dword ptr [edi+3Ch]
	mov 	dword ptr [e_lfanew], eax
	jmp 	DONE_getDos
	ERROR_notDos:
		mov 	eax , -1
	
	DONE_getDos:
		pop 	edi
		pop 	esi
		pop 	ebx
		mov 	esp, ebp
		pop 	ebp
		ret 	4
		
; tuong duong voi: int GetPeHeader(void *lpFile)
GetPeHeader:
	push 	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	; kiem tra xem co pe_signature khong
	mov 	edi, dword ptr [ebp+8]
	lea 	esi, dword ptr [PE_signature]
	mov 	ecx, 4
	repe 	cmpsb
	jne 	mismatch_pe_header
	
	; luu vao pe header struct
	mov  	esi,dword ptr [ebp+8]
	lea 	edi, dword ptr [Signature]
	mov 	ecx, 57
	rep 	movsd
	
	mov  	eax, 0
	jmp 	DONE_GetPeHeader
	
	mismatch_pe_header:
		mov eax, -1
	
	DONE_GetPeHeader:
		pop 	edi
		pop 	esi
		pop 	ebx
		mov 	esp, ebp
		pop 	ebp
		ret 	4
		
; tuong duong voi: void print_dos_header()
print_dos_header:
	push 	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	push 	stdOutHandle
	push 	dword ptr [DOS_header_len]
	push 	OFFSET DOS_header_print
	call 	print
	
	push 	stdOutHandle
	push 	dword ptr [e_magic_len_word]
	push 	OFFSET e_magic_word
	call 	print
	
	push 	stdOutHandle
	push 	2
	push 	OFFSET e_magic
	call 	print
	
	push 	stdOutHandle
	push 	2
	push 	OFFSET nl
	call 	print
	
	push 	stdOutHandle
	push 	dword ptr [e_lfanew_word_len]
	push 	OFFSET e_lfanew_word
	call 	print
	
	push 	dword ptr [e_lfanew]
	call 	print_hex
	
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	
	
; tuong duong voi: void print_file_header()
print_file_header:
	push 	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	push 	stdOutHandle
	push 	dword ptr [file_header_len]
	push 	OFFSET 	file_header_print
	call 	print
	
	; in ra pe signature
	push 	stdOutHandle
	push 	dword ptr [pe_signature_len]
	push 	OFFSET pe_signature
	call 	print
	
	push 	dword ptr [Signature]
	call 	print_hex
	
	call 	print_nl
	
	; in ra pe machine
	push 	stdOutHandle
	push 	dword ptr [pe_machine_len]
	push 	OFFSET pe_machine_print
	call 	print
	
	movzx 	eax, word ptr [Machine]
	push 	eax
	call 	print_hex
	
	call 	print_nl
	
	; in ra pe characteristics
	push 	stdOutHandle
	push 	dword ptr [pe_charac_len]
	push 	OFFSET 	pe_charac_print
	call 	print
	
	movzx 	eax, word ptr [Characteristics]
	push 	eax
	call 	print_hex
	
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	
	
; tuong duong voi: void print_optional_header()
print_optional_header:
	push 	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	; in ra tieu de
	push 	stdOutHandle
	push 	dword ptr [opetional_head_len]
	push 	OFFSET optional_header
	call 	print
	
	; in ra magic
	push 	stdOutHandle
	push 	dword ptr [optional_magic_len]
	push 	OFFSET optional_magic
	call 	print
	
	movzx 	eax, word ptr [Magic]
	push 	eax
	call 	print_hex
	call 	print_nl
	
	
	; in ra major version
	push 	stdOutHandle
	push 	dword ptr [optional_major_len]
	push 	OFFSET optional_major
	call 	print
	
	movzx 	eax, byte ptr [MajorLinkerVersion]
	push 	eax
	call 	print_hex
	call 	print_nl
	
	; in ra minor version
	push 	stdOutHandle
	push 	dword ptr [optional_minor_len]
	push 	OFFSET optional_minor
	call 	print
	
	movzx 	eax, byte ptr [MinorLinkerVersion]
	push 	eax
	call 	print_hex
	call 	print_nl
	
	; in ra size of code
	push 	stdOutHandle
	push 	dword ptr [optional_codesize_len]
	push 	OFFSET optional_codesize
	call 	print
	
	push 	dword ptr [SizeOfCode]
	call 	print_hex
	call 	print_nl
	
	; in ra size of initialise data
	push 	stdOutHandle
	push 	dword ptr [optional_init_len]
	push 	OFFSET optional_init
	call 	print
	
	push 	dword ptr [SizeOfInitializedData]
	call 	print_hex
	call 	print_nl
	
	; in ra size of uninitialise data
	push 	stdOutHandle
	push 	dword ptr [optional_uninit_len]
	push 	OFFSET optional_uninit
	call 	print
	
	push 	dword ptr [SizeOfUninitializedData]
	call 	print_hex
	call 	print_nl
	
	; in ra size of uninitialise data
	push 	stdOutHandle
	push 	dword ptr [entry_point_len]
	push 	OFFSET entry_point
	call 	print
	
	push 	dword ptr [AddressOfEntryPoint]
	call 	print_hex
	call 	print_nl
	
	; in ra size of uninitialise data
	push 	stdOutHandle
	push 	dword ptr [optional_basecode_len]
	push 	OFFSET optional_basecode
	call 	print
	
	push 	dword ptr [BaseOfCode]
	call 	print_hex
	call 	print_nl
	
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	
	
; tuong duong vo: void print_section_header(void *section_addr, int number_of_section)
print_section_header:
	push 	ebp
	mov 	ebp, esp
	sub 	esp, 4		; ebp-4: temp_num
                                ; ebp-8: i
	push 	ebx
	push 	esi
	push 	edi
		
        mov     dword ptr [ebp-8], 0
        
        push    stdOutHandle
        push    dword ptr [section_header_len]
        push    OFFSET section_header
        call    print
        call    print_nl
	next_section:
        	mov  	esi, dword ptr [ebp+8]
        	lea  	edi, [Name1]
        	mov  	ecx, 10
        	rep 	movsd
                mov     dword ptr [ebp+8], esi
        
                call    print_tab
        	push 	stdOutHandle
        	push 	dword ptr [Name_section_len]
        	push 	OFFSET Name_section_header
        	call 	print
	
        	push 	OFFSET Name1
        	call 	str_len
        	push 	stdOutHandle
        	push 	eax
        	push 	OFFSET Name1
        	call 	print
        	call 	print_nl
	
	       mov  	ecx, 4

	L1_section_header:
                ; lay vi tri con tro cua section_print_ptr
		mov 	dword ptr [ebp-4],ecx
		mov 	edx, 4
		sub 	edx, ecx

                call    print_tab
		mov 	ebx, dword ptr [section_print_ptr+4*edx]
		mov 	esi, dword ptr [section_len_ptr+4*edx]
		push 	stdOutHandle
		push 	esi
		push 	ebx
		call 	print
		
		mov 	ecx, dword ptr [ebp-4]
		mov 	edx, 4
		sub 	edx, ecx
		
		lea 	eax, Name1
		add 	eax, 8
		mov 	eax, dword ptr [eax+edx*4]
		push 	eax
		call 	print_hex
		call 	print_nl
		mov 	ecx, dword ptr [ebp-4]
		LOOP	L1_section_header

        call    print_nl
        inc     dword ptr [ebp-8]
        mov     ecx, dword ptr [ebp-8]
        cmp     ecx, dword ptr [ebp+12]
        jl      next_section
	
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop  	ebp
	ret	8
	
; tuong duong voi: void print_import_header(int rva, void *import_address, int number_of_section)
print_import_header:
	push 	ebp
	mov 	ebp, esp
	sub 	esp, 8 		; ebp-4: pointer_to_import_section
						; ebp-8: base_address
	push 	ebx
	push 	esi
	push 	edi
	
	push 	stdOutHandle
	push 	dword ptr [import_header_len]
	push 	OFFSET import_header_print
	call 	print
	call 	print_nl

	push 	dword ptr [ebp+16]
	push 	dword ptr [ebp+12]
	push 	dword ptr [ebp+8]
	call 	getOffSet
	
	; lay vi tri dau tien
	mov 	esi, lpFile
	add 	esi, eax
	
    ; lay vi tri tiep theo import_description
    next_import_description:
	push 	esi
	call 	GetImportDescription
	add 	esi, 20
	; lay physical header tu rva header
	mov 	ebx, dword ptr [Characteristics_import]
	
	; kiem traxem  no da null chua
	test 	ebx,ebx
	jz 		DONE_import_header
	
	mov 	ecx, dword ptr [Name_import_description]
	push 	ecx
	call 	getRvaOffset_after
	mov 	ecx, eax
	
	mov 	edi, ecx
	push 	edi
	call 	str_len
	
	push 	stdOutHandle
	push 	eax
	push 	edi
	call 	print
	call 	print_nl
	
	push 	ebx
	call 	getRvaOffset_after
	mov 	ebx, eax
	next_header:

		mov 	eax, ebx
		mov 	edx, dword ptr [eax]
		test 	edx, edx
		jz 		next_import_description
		call 	print_tab
		push 	dword ptr [eax]
		call 	getRvaOffset_after
		push 	eax
		call 	LoadHintAndName
		
		push 	OFFSET Name_import
		call 	str_len
		
		push 	stdOutHandle
		push 	eax
		push 	OFFSET Name_import
		call 	print
		
		call 	print_nl

		
		add 	ebx, 4
		loop 	next_header
	
	DONE_import_header:
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	12
	
; tuong duong voi: void print_import_header(int rva, void *addr_section, int number_of_section)
print_export_header:
	push 	ebp
	mov 	ebp, esp
	sub 	esp, 12 	; ebp-4: temp_string
						; ebp-8: i
						; ebp-12: number of names
	push 	ebx
	push 	esi
	push 	edi
	
	push 	stdOutHandle
	push 	dword ptr [export_header_len]
	push 	OFFSET export_header_print
	call 	print
	call 	print_nl

	mov 	eax, dword ptr [export_director]
	test 	eax, eax
	jz 		DONE_export_header
	push 	dword ptr [ebp+16]
	push 	dword ptr [ebp+12]
	push 	dword ptr [ebp+8]
	call 	GetOffSetExport
	
	; lay vi tri dau tien
	mov 	esi, lpFile
	add 	esi, eax
	
    ; lay vi tri tiep theo import_description
	push 	esi
	call 	GetExportDescription
	; lay so luong ten 
	mov 	eax, dword ptr [NumberOfNames]
	mov 	dword ptr [ebp-12], eax
	
	; lay offset cho name section
	push 	dword ptr [AddressOfNames]
	call 	getRvaOffset_after
	mov 	esi, eax
	
	mov 	ecx, dword ptr [ebp-12]
	; in ra cac ten cua export
	next_name_export:
		mov 	dword ptr [ebp-12], ecx
		lea 	edi, [ebp-4]
		movsd
		
		push 	dword ptr [ebp-4]
		call 	getRvaOffset_after
	
		push 	eax
		call 	print_without_len
		
		mov 	ecx, dword ptr [ebp-12]
		LOOP 	next_name_export
	
	DONE_export_header:
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	12

; tuong duong voi: getOffSet(int rva, void *addr, int number_of_section)
GetOffSetExport:
	push 	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	mov	 	eax, dword ptr [ebp+12]
	mov 	ebx, dword ptr [ebp+16]
	mov 	esi, eax
	mov 	ecx, ebx
	next_section_export:
		mov 	ebx, ecx
		lea 	edi, Name1
		mov 	ecx, 10
		rep 	movsd
		
		mov 	ecx, ebx
		mov 	eax, dword ptr [export_director]
		sub 	eax, dword ptr [VirtualAddress]
		cmp 	eax, dword ptr [VirtualSize]
		jl 		BREAK_found_section
		
		LOOP 	next_section_export
	
	BREAK_found_section:
		mov 	eax, dword ptr [ebp+8]
		sub 	eax, dword ptr [VirtualAddress]
		add 	eax, dword ptr [PointerToRawData]
	
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	12

; tuong duong voi: getOffSet(int rva, void *addr, int number_of_section)
getOffSet:
	push 	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	mov	 	eax, dword ptr [ebp+12]
	mov 	ebx, dword ptr [ebp+16]
	mov 	esi, eax
	mov 	ecx, ebx
	Get_section_offset:
		mov 	ebx, ecx
		lea 	edi, Name1
		mov 	ecx, 10
		rep 	movsd
		
		mov 	ecx, ebx
		mov 	eax, dword ptr [import_director]
		sub 	eax, dword ptr [VirtualAddress]
		cmp 	eax, dword ptr [VirtualSize]
		jl 		BREAK_get_section_offset
		
		LOOP 	Get_section_offset
	
	BREAK_get_section_offset:
		mov 	eax, dword ptr [ebp+8]
		sub 	eax, dword ptr [VirtualAddress]
		add 	eax, dword ptr [PointerToRawData]
	
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	12
	
; tuong duong voi: void *getRvaOffset_after(int rva)
; goi sau khi da goi getOffSet hoac GetOffSetExport
getRvaOffset_after:
	push 	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	mov 	eax, dword ptr [ebp+8]
	sub 	eax, dword ptr [VirtualAddress]
	add 	eax, dword ptr [PointerToRawData]
	mov 	ebx, lpFile
	add 	ebx, eax
	
	mov 	eax, ebx
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	4
	
; tuong duong voi: void LoadHintAndName(void *addr)
LoadHintAndName:
	push 	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	mov 	edi, offset Hint_import
	mov 	esi, dword ptr [ebp+8]
	mov 	ecx, 1
	rep 	movsw
	
	push 	OFFSET 	Name_import
	push 	esi
	call 	copy_string
	
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	4
	
; tuong duong voi: void GetImportDescription(void *addr)
GetImportDescription:
	push 	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	mov 	edi, offset Characteristics_import
	mov 	esi, dword ptr [ebp+8]
	mov 	ecx, 5
	rep 	movsd

	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	4
	
; tuong duong voi: void GetExportDescription(void *addr)
GetExportDescription:
    push    ebp
    mov     ebp, esp
    push    ebx
    push    esi
    push    edi
    
    mov     edi, offset Characteristics_export
    mov     esi, dword ptr [ebp+8]
    mov     ecx, 10
    rep     movsd
	
    pop 	edi
    pop 	esi
    pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	4
end start
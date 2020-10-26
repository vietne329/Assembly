.386
.model flat, stdcall
option casemap : none

include D:\masm32-wine-master\libs\windows.inc
include D:\masm32-wine-master\libs\user32.inc
include D:\masm32-wine-master\libs\kernel32.inc
include D:\masm32-wine-master\libs\gdi32.inc
includelib D:\masm32-wine-master\libs\user32.lib
includelib D:\masm32-wine-master\libs\kernel32.lib
includelib D:\masm32-wine-master\libs\gdi32.lib

.data
	IDB_BALL 	db 	"Red Circle", 0
	ClassName 	db 	"Bouncy Ball Class", 0
	AppName 	db 	"Bouncy Ball", 0
	
	error_title 			db "~Error:", 0
	error_registerClassEx	db "Register class error", 0
	error_createWindowEx 	db "Create window error", 0
	error_LoadBitMap		db "Fail to load bit map", 0
	error_invalidRec		db "Fail to call invalid Rec", 0
	
.data?
	hInstance 				HINSTANCE ?
	commandHandle 			LPSTR ?
	
	wc 						WNDCLASSA 1 dup(<>)
	mainMessageStruct 		dword 7 dup(?)
	
	hdc 					HDC ?
	windowHandle 			HWND ?
	msg 					MSG  1 dup(<>)
	g_hbmBall				HBITMAP ?
	ball_info_x 			dword ?
	ball_info_y				dword ?
	ball_info_dx			dword ?
	ball_info_dy			dword ?
	seed 					dword ?
	
	LPSYSTEMTIME  			dword 4 dup(?)
.code
start:
	push 	offset LPSYSTEMTIME
	call 	GetSystemTime
	
	mov 	eax, dword ptr [LPSYSTEMTIME+12]
	mov 	dword ptr [seed], eax
	push 	10000
	call 	GenerateRandom
	mov 	dword ptr [seed], eax
	; Get instance, once and for all
	push 	NULL
	call 	GetModuleHandle
	mov 	hInstance, eax
	
	call 	GetCommandLine
	mov 	commandHandle, eax

	push 	SW_SHOWDEFAULT
	push 	commandHandle
	push 	NULL
	push 	hInstance
	call 	WinMain
	
	ret
	
; tuong duong voi: int GenerateRandom(int max)
GenerateRandom:
	push 	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	mov 	ebx, dword ptr [seed]
	; (1729*seed+2020) % max
	imul 	ebx, 1729
	add 	ebx, 2020
	
	mov 	eax, ebx
	xor 	edx, edx
	mov 	ebx, dword ptr [ebp+8]
	div 	ebx
	
	; tra ve remainder
	mov 	eax, edx
	
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	4

; tuong duogn voi: void UpdateBall(RECT* prc)
UpdateBall:
	push  	ebp
	mov 	ebp, esp
	push 	ebx
	push 	esi
	push 	edi
	
	mov 	eax, dword ptr [ball_info_dx]
	add 	dword ptr [ball_info_x], eax
	mov 	eax, dword ptr [ball_info_dy]
	add 	dword ptr [ball_info_y], eax
	
	mov 	eax, dword ptr [ball_info_x]
	test 	eax, eax
	jl 		ball_out_of_range_x_left
	add 	eax, 100
	mov 	edx, dword ptr [ebp+8]; edx = &prc
	mov 	edx, dword ptr [edx+8] ; edx = *prc.right
	; tuong duong voi: ball_info_x + ball_info_width > prc->right
	cmp 	eax, edx
	jg 		ball_out_of_range_x_right
	check_y_coordinate:
		mov 	eax, dword ptr [ball_info_y]
		test 	eax, eax
		jl 		ball_out_of_range_y_above
		add 	eax, 100
		mov 	edx, dword ptr [ebp+8]; edx = &prc
		mov 	edx, dword ptr [edx+12] ; edx = *prc.bottom
		cmp 	eax, edx
		jg 		ball_out_of_range_y_below
		jmp 	DONE_UpdateBall
		
	ball_out_of_range_x_left:
		mov 	dword ptr [ball_info_x], 0
		mov 	dword ptr [ball_info_dx], 6
		jmp 	check_y_coordinate
	ball_out_of_range_x_right:
		mov 	edx, dword ptr [ebp+8]
		mov 	edx, dword ptr [edx+8]
		sub 	edx, 100
		mov 	dword ptr [ball_info_x], edx
		mov 	dword ptr [ball_info_dx], -6
		jmp 	check_y_coordinate
	ball_out_of_range_y_above:
		mov 	dword ptr [ball_info_y], 0
		mov 	dword ptr [ball_info_dy], 6
		jmp 	DONE_UpdateBall
	ball_out_of_range_y_below:
		mov 	edx, dword ptr [ebp+8]
		mov 	edx, dword ptr [edx+12] ; edx = prc->bottom
		sub 	edx, 100
		mov 	dword ptr [ball_info_y], edx
		mov 	dword ptr [ball_info_dy], -6
		jmp 	check_y_coordinate

	DONE_UpdateBall:
		pop 	edi
		pop 	esi
		pop 	ebx
		mov 	esp, ebp
		pop 	ebp
		ret 	4
		
; tuong duong voi: DrawBall(HDC hdc, RECT *rect)
DrawBall:
	push 	ebp
	mov 	ebp, esp
	sub 	esp, 16		; ebp-4: HPEN hPen
						; ebp-8: HDC hdcBuffer
						; ebp-12: int right
						; ebp-16: int bottom
						; ebp-20: HBITMAP hbmBuffer
						; ebp-24: HBRUSH hBrush
	push 	ebx
	push 	esi
	push 	edi
	
	mov 	eax, dword ptr [ebp+12]
	mov 	eax, dword ptr [eax+8]
	mov 	dword ptr [ebp-12], eax
	mov 	eax, dword ptr [ebp+12]
	mov 	eax, dword ptr [eax+12]
	mov 	dword ptr [ebp-16], eax
	
	push 	dword ptr [ebp+8]
	call 	CreateCompatibleDC
	mov 	dword ptr [ebp-8], eax
	
	push 	dword ptr [ebp-16]
	push 	dword ptr [ebp-12]
	push 	dword ptr [ebp+8]
	call 	CreateCompatibleBitmap
	mov 	dword ptr [ebp-20], eax
	
	push 	dword ptr [ebp-20]
	push 	dword ptr [ebp-8]
	call 	SelectObject
	
	push 	0fbf1c7h
	call 	CreateSolidBrush
	mov 	dword ptr [ebp-24], eax
	push 	eax
	push 	dword ptr [ebp+12]
	push 	dword ptr [ebp-8]
	call 	FillRect
	
	push 	dword ptr [ebp-24]
	call 	DeleteObject
	
	push 	0ffh
	push 	0
	push 	PS_SOLID
	call 	CreatePen
	mov 	dword ptr [ebp-4], eax
	
	push 	0ffh
	call 	CreateSolidBrush
	mov 	dword ptr [ebp-24], eax
		
	push 	eax
	push 	dword ptr [ebp-8]
	call 	SelectObject
		
	push 	dword ptr [ebp-4]
	push 	dword ptr [ebp-8]
	call 	SelectObject
	
	mov 	eax, dword ptr [ball_info_x]
	mov 	ebx, dword ptr [ball_info_y]
	mov 	ecx, dword ptr [ball_info_x]
	add 	ecx, 100
	mov 	edx, dword ptr [ball_info_y]
	add 	edx, 100
	push 	edx
	push 	ecx
	push 	ebx
	push 	eax
	push 	dword ptr [ebp-8]
	call 	Ellipse
	
	push 	SRCCOPY
	push 	0
	push 	0
	push 	dword ptr [ebp-8]
	push 	dword ptr [ebp-16]
	push 	dword ptr [ebp-12]
	push 	0
	push 	0
	push 	dword ptr [ebp+8]
	call 	BitBlt
	
	; Clean Up
	; Delete hPen
	push 	dword ptr [ebp-4]
	call 	DeleteObject
		
	; delete hdcBuffer
	push 	dword ptr [ebp-24]
	push 	dword ptr [ebp-8]
	call 	SelectObject
	
	push 	dword ptr [ebp-8]
	call 	DeleteDC
	
	; delete hbmBuffer
	push 	dword ptr [ebp-20]
	call 	DeleteObject
	
	; delete hBursh
	push 	dword ptr [ebp-24]
	call 	DeleteObject
	
	pop 	edi
	pop 	esi
	pop 	ebx
	mov 	esp, ebp
	pop 	ebp
	ret 	8
WinMain:
	push 	ebp
	mov 	ebp, esp
	
	; setup wc
    mov   	wc.lpfnWndProc, OFFSET WindowProcedure
    push  	hInstance
    pop   	wc.hInstance
    mov   	wc.lpszClassName,OFFSET ClassName
	mov 	wc.hbrBackground , COLOR_WINDOW+1
	
	lea 	eax, wc
	push 	eax
    call 	RegisterClassA                       ; register our window class
	mov 	windowHandle, eax
	
	push  	NULL
	push 	hInstance
	push 	NULL
	push 	NULL
	push 	CW_USEDEFAULT
	push 	CW_USEDEFAULT
	push 	CW_USEDEFAULT
	push 	CW_USEDEFAULT
	push 	WS_OVERLAPPEDWINDOW 
	push 	offset AppName
	push 	offset ClassName
	push 	NULL
	call 	CreateWindowEx
    mov   	windowHandle, eax
	
	push 	SW_SHOWDEFAULT
	push 	windowHandle
	call 	ShowWindow               					; display our window on desktop
	
	push 	windowHandle
	call 	UpdateWindow                               	; refresh the client area

; Enter message loop
	INFINITE_LOOP:
		lea 	eax, msg
		push 	eax
		push 	0
		push 	0
		push 	NULL
		push 	eax
		call 	GetMessage
		
        test 	eax, eax
		jz 		BREAK_INFINITE_LOOP
		
		lea 	eax, msg
		push 	eax
		call 	TranslateMessage
		
		lea 	eax, msg
		push 	eax
		call 	DispatchMessage
		jmp 	INFINITE_LOOP
	BREAK_INFINITE_LOOP:
		mov     eax, msg.wParam                                            ; return exit code in eax
		mov 	esp, ebp
		pop 	ebp	
		ret  	16

; tuong duong voi: WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
WindowProcedure:
    ;; We don't really need any local variables, for now, besides the function arguments.
    push 	ebp
	mov 	ebp, esp
	sub 	esp, 16*4 	; ebp - 16*4: PAINTSTRUCT 
	sub 	esp, 16		; ebp - 16*4-4: HDC hdcMem
						; ebp - 16*4-8: HPEN hpen
						; ebp - 16*4-12: HBRUSH hBrush
						; ebp - 16*4-16: HRGN bgRgn
	sub 	esp, 4*4 	; ebp - 16*4-16-4*4: RECT clientRect
	sub 	esp, 4		; ebp - 16*4-16-4*4-4: uint_t timer
	push 	esi
	push 	edi
	


    ;; We need to retrieve the uMsg value.
    mov eax, dword ptr [ebp+12]           ;; We get the value of the second argument.

	cmp 	eax, WM_CREATE
	je 		window_creation
	cmp 	eax, WM_PAINT
	je 		window_paint
	cmp 	eax, WM_TIMER
	je 		window_timer
    cmp 	eax, WM_DESTROY
    je 		window_destroy   
	cmp 	eax, WM_CLOSE
	je 		window_close
    jmp 	window_default
	
	window_creation:
		lea 	eax, [ebp-16*4-16-4*4]
		push 	eax
		push 	dword ptr [ebp+8]
		call 	GetClientRect
		lea 	eax, [ebp-16*4-16-4*4]
		mov 	ebx, dword ptr [eax+8]
		mov 	eax, dword ptr [eax+12]
		
		push 	eax
		call 	GenerateRandom
		mov 	dword ptr [ball_info_y], eax
		
		push 	ebx
		call 	GenerateRandom
		mov 	dword ptr [ball_info_x], eax
		
		mov 	dword ptr [ball_info_dx], 6
		mov 	dword ptr [ball_info_dy], 6
		push 	offset IDB_BALL
		push 	NULL
		call 	GetModuleHandle
		push 	eax
		call 	LoadBitmap
		mov 	HBITMAP ptr [g_hbmBall], eax

		
		push 	NULL
		push 	30
		push 	1729
		push 	dword ptr [ebp+8]
		call 	SetTimer
		mov 	dword ptr [ebp - 16*4-16-4*4-4], eax
		
	window_timer:
		lea 	eax, [ebp-16*4-16-4*4]
		push 	eax
		push 	dword ptr [ebp+8]
		call 	GetClientRect
		
		lea 	eax, [ebp-16*4-16-4*4]
		push 	eax
		call 	UpdateBall
		
		push 	dword ptr [ebp+8]
		call 	GetDC
		mov 	dword ptr [hdc], eax
		
		lea 	ebx, [ebp-16*4-16-4*4]
		push 	ebx
		push 	eax
		call 	DrawBall
		
		push 	dword ptr [hdc]
		push 	dword ptr [ebp+8]
		call 	ReleaseDC
		
		jmp 	window_finish
	
	window_paint:
		; tuong duong voi: g_hbmBall = LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_BALL))
		lea 	edi, [ebp-16*4]
		ASSUME 	edi: ptr PAINTSTRUCT
		
		push 	edi
		push 	dword ptr [ebp+8]
		call 	BeginPaint
		mov 	dword ptr [ebp-16*4-4], eax
		
		; Draw a circle
		lea 	eax, [ebp-16*4-16-4*4]
		push 	eax
		push 	dword ptr [ebp+8]
		call 	GetClientRect
		
		lea 	ebx, [ebp-16*4-16-4*4]
		push 	ebx
		push 	dword ptr [ebp-16*4-4]
		call 	DrawBall
		
		; Clean Up
		push 	WHITE_BRUSH
		call 	GetStockObject
		
		push 	DC_PEN
		call 	GetStockObject
		
		push 	edi
		push 	dword ptr [ebp+8]
		call 	EndPaint
		
		jmp 	window_finish
	window_close:
		push 	dword ptr [ebp+8]
		call 	DestroyWindow
		jmp  	window_finish
    ;; We need to define the .window_destroy label, now.
    window_destroy:
	
		; DeleteObject(g_hbmBall);
		push 	g_hbmBall
		call 	DeleteObject
		
        ;; If uMsg is equal to WM_DESTROY (2), then the processor will execute this
        ;; code next.

        ;; We pass 0 as an argument to the PostQuitMessage() function, to tell it
        ;; to pass 0 as the value of wParam for the next message. At that point,
        ;; GetMessage() will return 0, and the message loop will terminate.
        push 	0
        ;; Now we call the PostQuitMessage() function.
        call 	PostQuitMessage

        ;; When we're done doing what we need to upon the WM_DESTROY condition,
        ;; we need to jump over to the end of this area, or else we'd end up
        ;; in the .window_default code, which won't be very good.
        jmp 	window_finish
    ;; And we define the .window_default label.
    window_default:
        ;; Right now we don't care about what uMsg is; we just use the default
        ;; window procedure.
		push 	1729	
		call 	KillTimer

        ;; In order for use to call the DefWindowProc() function, we need to
        ;; pass the arguments to it.
        ;; It's arguments are the same as WindowProcedure()'s arguments.
        ;; We push the arguments to the stack, in backwards order.
        push 	dword ptr [ebp+20]
        push 	dword ptr [ebp+16]
        push 	dword ptr [ebp+12]
        push 	dword ptr [ebp+08]
        ;; And we call the DefWindowProc() function.
        call 	DefWindowProcA

        ;; At this point, we need to return. The return value must
        ;; be equal to whatever DefWindowProc() returned, so we
        ;; can't change EAX.

        ;; But we need to leave before we return.
        mov 	esp, ebp
		pop  	ebp
        ret 	16
    ;; This is where the we want to jump to after doing everything we need to.
    window_finish:
		xor 	eax, eax
		pop 	edi
		pop 	esi
		pop 	ebx
		mov 	esp, ebp
		pop 	ebp
		ret 	16
		
	fail_LoadBitMap:
		; MessageBox(hwnd, "Could not load IDB_BALL!", "Error", MB_OK | MB_ICONEXCLAMATION);
		push 	MB_OK or MB_ICONEXCLAMATION
		push 	offset error_title
		push 	offset error_LoadBitMap
		push 	windowHandle
		call 	MessageBox
		
		jmp 	window_finish
		
	fail_invalidRec:
		; MessageBox(hwnd, "Could not load IDB_BALL!", "Error", MB_OK | MB_ICONEXCLAMATION);
		push 	MB_OK or MB_ICONEXCLAMATION
		push 	offset error_title
		push 	offset error_invalidRec
		push 	windowHandle
		call 	MessageBox
		
		jmp 	window_finish
end start
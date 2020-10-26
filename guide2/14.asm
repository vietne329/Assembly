.386
.model flat, stdcall
option casemap:none

include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\gdi32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\gdi32.lib



BALL struct
	x1 dd 0
	y1 dd 0
	x2 dd 0
	y2 dd 0
	mx dd 0
	my dd 0
 BALL ends



.const
	id_timer equ 1
	dia     equ 30								;diameter
	speed   equ 20 								;speed of ball
	uElapse equ 20								;time elapse

.data?

	hInstance  dd ?
    hwnd       dd ?
	wc         WNDCLASSEX <?>
	msg        MSG <?>

.data

	class_name db "ball",0
	win_name db "Bouncing ball",0

	myBall BALL <>
.code

main:
	invoke GetModuleHandle, 0
	mov  hInstance, eax
	call WinMain
 
	invoke ExitProcess, eax



WinMain proc

	mov   wc.cbSize, SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra, 0
	mov   wc.cbWndExtra, 0
	
	push  hInstance
	pop   wc.hInstance
	
	mov   wc.hbrBackground, COLOR_WINDOW + 1
	mov   wc.lpszMenuName, 0
	mov   wc.lpszClassName, OFFSET class_name
	
	push IDI_APPLICATION
	push 0
	call LoadIcon

	
	mov   wc.hIcon, eax
	mov   wc.hIconSm, eax
	
	push IDC_ARROW
	push 0
	call LoadCursor
	mov  wc.hCursor, eax

	lea ecx, wc
	push ecx
	call RegisterClassEx
    or eax,eax
    jz @endE


    push 0                          ;lpParam
    push hInstance                      ;handle instance of the module to be associated with the window.
	push 0                                ;hMenu: hande to a menu  -> child-window indentifier
    push 0                                 ;handle to the parent or owner window
    push 600    
    push 800                                ; nwith  
    push 200                                ;y upper-left conner
    push 300                                ;x upper-left conner
    push WS_OVERLAPPEDWINDOW or WS_THICKFRAME           ;win style
    push offset win_name
    push offset class_name
    push WS_EX_CLIENTEDGE                              ;extend window style
    call CreateWindowEx

    mov hwnd, eax
    or eax,eax
    jz @endL
	

	push SW_SHOWDEFAULT
	push hwnd
	call ShowWindow
	
	push hwnd
	call UpdateWindow

;loop message

@L1:
		
		push 0
		push 0
		push 0
		push offset msg
		call GetMessage
		
		or eax,eax
		jz @endL
		
		
		push offset msg
		call TranslateMessage
		
		push offset msg
		call DispatchMessage
		
		jmp @L1
				
@endL:	
		mov eax, msg.wParam
		ret
@endE:
        push MB_OK
        push 0
        push 0
        push 0
        call MessageBox
        ret
		
WinMain endp


;call back function
WndProc proc hWnd:HWND, uMsg: UINT,wParam: WPARAM, lParam: LPARAM
		local rectWin:RECT	;window rectangle (left, top, right, bottom) -(dd 4)
		local hdc: dword	;handle device context                
		local hbr: dword 	;handle brush								(sub esp,24)

		cmp uMsg,WM_DESTROY									
		je  @quit							;if user closes windows

        cmp uMsg,WM_CREATE
        je @WM_CREATE

        cmp uMsg,WM_TIMER
        je @WM_TIMER

        push lParam
		push wParam
		push uMsg
		push hWnd
		call DefWindowProc					;default message processing
		
		ret
@WM_CREATE:

		push 0
		push uElapse							;milliseconds
		push id_timer						;nonzero timer identifier ->declare time id to refer to it later and set the timer in WM_CREATE handle each time elapses, it will send a WM_TIMER msg to win and pass us back the ID in wParam, then we only have 1 timer, no need ID more but it's useful if set more 1 timer
		push hWnd
		call SetTimer

		lea ecx, rectWin
		push ecx
		push hWnd
		call GetClientRect					;get size window

		mov eax, rectWin.right
		mov ebx, rectWin.bottom
		call ballCreate

		jmp @return

@WM_TIMER:

		push hWnd
		call GetDC
		mov hdc, eax

		push WHITE_BRUSH
		call GetStockObject
		mov hbr, eax 						;handle brush

		lea ecx, rectWin
		push ecx
		push hWnd
		call GetClientRect					;get size window

		push hbr
		lea ecx, rectWin
		push ecx
		push hdc
		call FillRect						;paint white to background (cover old screen)

		push 000000ffh
		call CreateSolidBrush
		push eax
		push hdc
		call SelectObject

		push myBall.y2
		push myBall.x2
		push myBall.y1
		push myBall.x1
		push hdc
		call Ellipse

		push rectWin.bottom
		push rectWin.right
		call updateBall

		push hdc
		push hWnd
		call ReleaseDC
		jmp @return

		
@quit:
		push 0
		call PostQuitMessage				;quit application
		xor eax,eax

@return:
		ret 

WndProc endp





ballCreate proc 
		LOCAL time: SYSTEMTIME						;sub esp,16   (8 * word)
		LOCAL w: dword
		LOCAL h: DWORD 

; random pos
		mov w, eax
		mov h, ebx

		lea ecx, time
		push ecx
		call GetSystemTime
		xor eax,eax

		movzx eax, time.wMilliseconds				;0-999

		push eax

		xor edx ,edx
		mov ebx, w
		sub ebx,dia

		div ebx 
		mov myBall.x1,edx

		pop eax
		xor edx,edx
		mov ebx,h
		sub ebx,dia

		div ebx
		mov myBall.y1,edx


; end random pos

		mov eax, myBall.x1
		add eax, dia
		mov myBall.x2, eax

		mov eax, myBall.y1
		add eax, dia
		mov myBall.y2, eax

;random direction
		
		lea ecx, time
		push ecx
		call GetSystemTime
		xor eax,eax

		movzx eax, time.wSecond					;0-59
		xor edx,edx
		mov ebx,4
		div ebx

		cmp edx,0
		je @case1

		cmp edx,1
		je @case2

		cmp edx,2
		je @case3

		jmp @case4
		
@case1:
		mov eax,speed
		mov myBall.mx,eax
		mov myBall.my,eax
		ret
@case2:
		mov eax,speed
		mov myBall.mx,eax
		neg eax
		mov myBall.my,eax
		ret
@case3:
		mov eax,speed
		mov myBall.my,eax
		neg eax
		mov myBall.mx,eax
		ret

@case4:
		mov eax,speed
		neg eax
		mov myBall.mx,eax
		mov myBall.my,eax
		ret

;end random dir
		
ballCreate endp
		


updateBall proc
		push ebp
		mov ebp,esp
		;[ebp+8] stores rectWin.right
		;[ebp+12] stores rectWin.bottom

		mov eax, myBall.x1
		add eax, myBall.mx
		;check left
		cmp eax,0
		jg @C1
		
		mov myBall.x1,0
		jmp changeX

@C1:	;check right
		add eax, dia
		cmp eax,[ebp+8]
		jl @C2

		mov eax, [ebp+8]
		sub eax,dia
		mov myBall.x1,eax
		jmp changeX

@C2:	;check top
		mov eax, myBall.y1
		add eax, myBall.my
			
		cmp eax,0
		jg @C3

		mov myBall.y1,0
		jmp changeY

@C3:	;check bottom
		add eax, dia
		cmp eax,[ebp+12]
		jl @update

		mov eax, [ebp+12]
		sub eax,dia
		mov myBall.y1,eax
		jmp changeY

changeX:

		mov eax, myBall.mx
		neg eax
		mov myBall.mx,eax

		;check bottom and top
		jmp @C2

changeY:

		mov eax, myBall.my
		neg eax
		mov myBall.my,eax

@update:
		mov eax, myBall.x1
		add eax, myBall.mx
		mov myBall.x1,eax

		add eax, dia
		mov myBall.x2, eax

		mov eax, myBall.y1
		add eax, myBall.my
		mov myBall.y1,eax

		add eax, dia
		mov myBall.y2, eax


		mov esp,ebp
		pop ebp
		ret

updateBall endp
end main
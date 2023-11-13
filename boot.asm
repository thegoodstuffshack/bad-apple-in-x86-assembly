[bits 16]
[org 0x7c00]
jmp start
;	Prints Frames to the screen

;; DATA
foreground db 35	; 219
background db 32	; ascii space
BOOT_DRIVE db 0     ; init variable

;; TEXT
start:
    mov [BOOT_DRIVE], dl
	
	call load_memory
	
	call video
	; push 0x7e00	; word [bp+6] ; frame address
	; ;push 120	; word [bp+4] ; no.
	; call frame	; print 1.darta
	
	; call delay
	
	; push 0x7f00
	; ;push 120; word [bp+4] ; no.
	; call frame	; print 1.darta
	
	; call delay
	
	; push 0x8000	; word [bp+6] ; frame address
	; ;push 120	; word [bp+4] ; no.
	; call frame	; print 1.darta
	
	; call delay
	
	; push 0x8100
	; ;push 120; word [bp+4] ; no.
	; call frame	; print 1.darta
	
cli
hlt

delay:
	mov ah, 0x86
	mov cx, 0x0002
	mov dx, 0x0000
	int 0x15
ret

print_test:
	mov ah, 0x0e
	mov al, 58
	int 0x10
ret

load_memory:
	push bp
	mov bp, sp
	
	mov cx, 0
	.loop:
	cmp cx, 20		; how much data to load					;;;;
	je .end
	push cx		; preserve count
	
	mov ax, 0x0200			; 0b0000 0010 0000 0000
	mul cx
	add ax, 0x7e00
	push ax ; [bp+6] ;push 0x7e00 + bx * 0x0200
	mov bx, 0x0002
	add bx, cx
	push bx ; [bp+4] ;push 0x0002 + bx
	
	call read_this
	
	pop cx		; restore count
	inc cx		; increment count
	jmp .loop
	
	.end:
	mov ah, 0x0e
	mov al, 50
	int 0x10
	pop bp
ret

video:
	push bp
	mov bp, sp
	
	mov cx, 0
	.loop:
	cmp cx, 120
	je .end
	
	push cx
	mov ax, 0x0100
	mul cx
	mov bx, 0x7e00
	add bx, ax
	push bx
	call frame
	call delay
	
	pop cx
	inc cx
	mov ah, 0x0e
	mov al, 52
	int 0x10
	jmp .loop
	
	.end:
	pop bp
ret	

read_this:
	push bp
	mov bp, sp
	
	mov bx, word [bp+6]	;;
	mov cx, word [bp+4]	;;
	
	mov ah, 0x02
	mov al, 1
	xor dx, dx
	mov es, dx
	mov dl, [BOOT_DRIVE]
	int 0x13

	pop bp
ret 4

frame:
	push bp
	mov bp, sp

	xor cx, cx
	mov si, cx
	mov cx, 120			 ; replace if want different amount
	;mov cx, word [bp+4] ; than 120 then need to implement push
	mov bx, word [bp+4]	 ; change pointer if above is changed (1) [bp+6]

	.loop:
	cmp cx, 0
	je .end
	dec cx
	push cx
	push si

	push word [bx+si]
	call shift_print

	pop si
	pop cx
	mov bx, word [bp+4]	 ; change pointer if above is changed (1) [bp+6]
	add si, 2
	jmp .loop

	.end:
	pop bp
ret 2		; change to 4 if above is changed (1)

shift_print:
	push bp
	mov bp, sp
	mov cl, 0
	.loop:
	cmp cl, 16
	je .shift_print_end

	mov bx, word [bp+4]
	shl bx, cl
	push bx
	call print
	pop bx
	inc cl
	jmp .loop

	.shift_print_end:
	; mov ax, 0x0e00
	; int 0x10
	pop bp
ret 2

print:
	push bp
	mov bp, sp

	mov ah, 0x0e
	mov bx, word [bp+4]
	cmp bh, 0x80	; 1000 0000 ; 128
	jb .zero
	.one:
		mov al, byte [foreground]
		int 0x10
		jmp .end_print
	.zero:
		mov al, byte [background]
		int 0x10
	.end_print:
	pop bp
ret

times 510 -($-$$) db 0
dw 0xAA55

;; test
; %include "1.data"
; times 3 * 256 -($-$$) db 0
; %include "2.data"
; times 4 * 256 -($-$$) db 0
; %include "3.data"
; times 5 * 256 -($-$$) db 0
; %include "4.data"
; times 6 * 256 -($-$$) db 0

%include "frames.asm"

; %include "data0.asm"
; times 2 * 512 -($-$$) db 0

; %include "data1.asm"
; times 4 * 512 -($-$$) db 0
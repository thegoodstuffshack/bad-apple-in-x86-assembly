[bits 16]
[org 0x7c00]
jmp start
;	Prints Frames to the screen

;; DATA
foreground db 35	; 219
background db 32	; ascii space
;BOOT_DRIVE db 0     ; init variable

;; TEXT
start:
    ;mov [BOOT_DRIVE], dl

	;load data.bin
	call read_data_to_memory
	
	push 0x7e00	; word [bp+6] ; first addr
	push 135; word [bp+4] ; no.
	call frame
	push 0x8000	; word [bp+6] ; first addr
	push 125; word [bp+4] ; no.
	;call frame
cli
hlt

read_data_to_memory:
	push bp
	mov bp, sp

	mov ah, 0x02
	mov al, 1
	mov ch, 0
	mov cl, 2
	mov dh, 0
    ;mov dl, [BOOT_DRIVE]
	;xor bx, bx
	;mov es, bx
	mov bx, 0x7e00
	int 0x13

	mov ah, 0x02
	mov al, 1
	mov ch, 0
	mov cl, 3
	mov dh, 0
    ;mov dl, [BOOT_DRIVE]
	;xor bx, bx
	;mov es, bx
	mov bx, 0x8000
	int 0x13

	; mov al, ah
	; mov ah, 0x0e
	; int 0x10

	pop bp
ret

frame:
	push bp
	mov bp, sp

	xor cx, cx
	mov si, cx
	mov cx, word [bp+4]
	mov bx, word [bp+6]

	.loop:
	cmp cx, 0
	je .end
	dec cx
	push cx
	push si

	push word [bx+si]	; 0x7e00
	call shift_print

	pop si
	pop cx
	mov bx, word [bp+6]
	add si, 2
	jmp .loop

	.end:
	pop bp
ret 2

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

;; 

%include "data0.asm"
times 2 * 512 -($-$$) db 0

%include "data1.asm"
times 3 * 512 -($-$$) db 0
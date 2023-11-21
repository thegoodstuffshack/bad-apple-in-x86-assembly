;; print.asm

; sets up a word of a frame
shift_print:
	push bp
	mov bp, sp
	xor cx, cx
	mov es, cx
	.loop:
	cmp cl, 16
	je .shift_print_end

	; word to print
	mov bx, word [bp+4]
	shl bx, cl
	push bx
	call print
	inc cl
	jmp .loop

	.shift_print_end:
	pop bp
ret 2

; prints the bits in the word
; foreground	db	35	; character of 1, ascii hashtag
; background 	db 	32	; character of 0, ascii space
print:
	push bp
	mov bp, sp

	mov ah, 0x0e
	mov bx, word [bp+4]
	cmp bh, 0x80	; 1000 0000 ; 128
	jb .zero
	.one:
		mov al, 35;[foreground]
		int 0x10
		jmp .end_print
	.zero:
		mov al, 32;[background]
		int 0x10
	.end_print:
	pop bp
ret 2
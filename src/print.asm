;; print.asm

frame:		; get frame, sends word to shiftprint
	push bp
	mov bp, sp

	xor cx, cx
	mov si, cx
	mov cx, 122	; words per frame
	
	mov bx, [frame_address]

	.loop:
	cmp cx, 0
	je .end
	dec cx
	push cx
	push si

	; push the word in the address
	push word [bx+si] ; [ES * 16 + BX + SI]
	call shift_print

	pop si
	pop cx
	mov bx, [frame_address]
	add si, 2	;next word (2 bytes)
	jmp .loop

	.end:
	xor bx, bx
	mov es, bx
	pop bp
ret

; sets up a word of a frame
shift_print:	; receives words, sends bits to print
	push bp
	mov bp, sp
	
	;call test_print
	
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

print:	; prints bits
	push bp
	mov bp, sp

	mov ah, 0x0e
	mov bx, word [bp+4]
	cmp bh, 0x80	; 1000 0000 ; 128
	jb .zero
	.one:
		mov al, FOREGROUND
		int 0x10
		jmp .end_print
	.zero:
		mov al, BACKGROUND
		int 0x10
	.end_print:
	pop bp
ret 2

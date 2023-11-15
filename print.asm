frame:
	push bp
	mov bp, sp

	xor cx, cx
	mov si, cx
	mov cx, 120			 ; replace if want different amount
	;mov cx, word [bp+4] ; than 120 then need to implement push
	
	mov bx, word [bp+6]
	mov es, bx
	mov bx, word [bp+4]	 ; change pointer if above is changed (1) [bp+6]

	.loop:
	cmp cx, 0
	je .end
	dec cx
	push cx
	push si

	push word [es:bx+si] ; [ES * 16 + BX + SI] i hope
	call shift_print

	pop si
	pop cx
	mov bx, word [bp+6]
	mov es, bx
	mov bx, word [bp+4]	 ; change pointer if above is changed (1) [bp+6]
	add si, 2
	jmp .loop

	.end:
	xor bx, bx
	mov es, bx
	pop bp
ret 4		; change to 4 (6) if above is changed (1)

shift_print:
	push bp
	mov bp, sp
	xor cx, cx
	mov es, cx
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
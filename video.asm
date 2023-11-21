;; video.asm

video:
	push bp
	mov bp, sp
	
	mov cx, 0
	.loop:
	cmp cx, 256 ;[FRAME_NUMBER]		;; frames ;;
	je .end
	push cx
	
	; should replace
	mov bx, [bp+4]	; value
	push bx		; immediately push for call frame

	mov ax, 0x0100	; next frame (256 bytes)
	mul cx
	mov bx, 0x0000	;0x7e00
	add bx, ax
	push bx
	
;;	WAIT for next tick to print frame
	call PIT_timer
	
	call frame
	call reset_cursor
	;call delay
	
	pop cx
	inc cx
	; mov ah, 0x0e
	; mov al, 52
	; int 0x10
	jmp .loop
	
	.end:
	pop bp
ret	2

frame:
	push bp
	mov bp, sp

	xor cx, cx
	mov si, cx
	mov cx, 122	; words per frame	 ; replace if want different amount
	;mov cx, word [bp+4] ; than 120 then need to implement push
	
	mov bx, word [bp+6]
	mov es, bx
	mov bx, word [bp+4]

	.loop:
	cmp cx, 0
	je .end
	dec cx
	push cx
	push si

	; push the word in the address
	push word [es:bx+si] ; [ES * 16 + BX + SI]
	call shift_print

	pop si
	pop cx
	mov bx, word [bp+6]
	mov es, bx
	mov bx, word [bp+4]
	add si, 2	;next word (2 bytes)
	jmp .loop

	.end:
	xor bx, bx
	mov es, bx
	pop bp
ret 4
;; pit.asm

PIT_init:
	cli
	mov al, 0b00110100	; channel 0, lobyte/hibyte, mode 2, binary
	out 0x43, al		; send to PIT controller
	
	mov ax, RELOAD_VALUE
	out 0x40, al
	mov al, ah
	out 0x40, al
	sti
ret

PIT_timer:			; works on its own in normal_mode
				; not the 'proper way' to implement pit
	.timer:
	mov ax, [TIMER_ADDRESS]
	mov bx, ax
	inc bx
	
	.loop:
	cmp ax, bx
	jae .tick		; wait til PIT ticks
	
	mov ax, [TIMER_ADDRESS]
	jmp .loop

	.tick:
ret

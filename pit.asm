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
	
	mov ah, 0x0e
	mov al, 'p'
	int 0x10
ret

PIT_timer:
	mov si, TIMER_ADDRESS
	.timer:
	mov ax, [si]
	mov bx, ax
	inc bx
	
	.loop:
	cmp ax, bx
	jae .tick		; wait til PIT ticks
	;jmp .tick
	
	mov ax, [si]
	; mov ah, 0x0e
	; mov al, 'l'
	; int 0x10
	jmp .loop
	
	.tick:
	mov ah, 0x0e
	mov al, 't'
	int 0x10
ret

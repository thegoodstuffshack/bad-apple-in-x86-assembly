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

PIT_timer:			; works on its own in normal_mode
				; not the 'proper way' to implement pit
	;mov ah, 0x86
	;mov al, 0
	;mov cx, 0x0000		; CX:DX interval in microseconds
	;mov dx, 0x3000		; roughly 29.54fps on qemu 
	;int 0x15			; delay between frames
	
	.timer:
	mov ax, [TIMER_ADDRESS]
	mov bx, ax
	inc bx
	
	.loop:		; real hardware gets stuck in this loop
	cmp ax, bx
	jae .tick		; wait til PIT ticks
	
	mov ax, [TIMER_ADDRESS]
	; mov ah, 0x0e
	; mov al, 'l'
	; int 0x10
	jmp .loop

	.tick:
	mov ah, 0x0e
	mov al, 't'		; fails to get here???
	int 0x10
ret

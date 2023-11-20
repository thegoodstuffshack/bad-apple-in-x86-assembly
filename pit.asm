; setup_pit:
	SETUP PIT
	; cli	; disable interrupts
	
	; mov al, 0b00110100 ; channel 0, hibyte/lowbyte, square wave (mode 3), 16 bit binary
	; out 0x43, al	; send setup to PIT
	
	; mov ax, 0x9b84	;9b89	; only even values in mode 3
	send PIT Reload Value (divisor from 1.193182 MHz)
	; out 0x40, al	
	; mov al, ah
	; out 0x40, al
	
	; sti ; reenable interrupts
; ret

pit_delay:
	;PIT
	cli	; disable interrupts

	; .init:
	; in al, 0x40	; read current PIT count
	; mov ah, al	; al = x, ah = x + 1
	; inc ah		; when equal, trigger next frame
	; add ah, 255

	; .loop:
	; cmp ah, al
	; je .end
	
	; in al, 0x40
	; jmp .loop
	
	; .end:
	
	;mov 
	
	
	sti ; reenable interrupts
	
ret
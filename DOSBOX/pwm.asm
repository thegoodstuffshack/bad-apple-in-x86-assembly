;; DOSBOX .com
;; modified from https://www.youtube.com/watch?v=4SBUrv7fXqI
;; and https://github.com/leonardo-ono/Assembly8086PlayPcmDigitizedSoundOnPCSpeakerTest
	bits 16
	org 100h	; 0x0100
	
start:
	;; SETUP
	xor ax, ax
	mov es, ax

	mov bl, 4ah ; 16000 Hz sampling rate
	call change_timer_0
	
	; speaker on
	in al, 61h
	or al, 3
	out 61h, al
	
	;; MUSIC LOOP
.loop:
	;push word 
	push word 0x0000
	call music_segment
	
	mov ah, 0x0e
	mov al, 1
	int 0x10
	
	push word 0x1000
	call music_segment
	
	mov ah, 0x0e
	mov al, 1
	int 0x10
	
	push word 0x2000
	call music_segment
	
	jmp exit
	
;; ======================================
music_segment:
	push bp
	mov bp, sp

next_sample:
	mov dx, [es:046ch]
delay:
	cmp dx, [es:046ch]
	jz delay

	; play 1 byte sample
	mov al, 090h	; 0000 1001 0000
	out 43h, al
	mov si, [sound_byte_index]

	mov bx, word [bp+4]
	mov es, bx
	mov bx, 0x0300
	
	; es * 16 (data offset) + 0x7e00 + si (byte offset)
	mov al, byte [es:bx + si]
	shr al, 1
	out 42h, al	; send freq to speaker (essentially)

	xor ax, ax
	mov es, ax	; zero es for next PIT check

	; if keypress exit
	mov ah, 1
	int 16h
	jnz exit
	
	; increment index
	inc si
	cmp si, [sound_size]
	mov [sound_byte_index], si
	jb next_sample
	mov word [sound_byte_index], 0
	pop bp
ret 2
;; ======================================
exit:
	; speaker off
	in al, 61h
	and al, 11111100b
	out 61h, al
	
	; restore original 18.2Hz timer
	mov bl, 0
	call change_timer_0
	
	; exit to DOS
	mov ah, 4ch
	int 21h
;; ======================================
; bl = timer divider
change_timer_0:
	cli
	mov al, 16h
	out 43h, al
	mov al, bl
	out 40h, al
	sti
	ret
;; ======================================

sound_byte_index dw 0
sound_data_index dw 0

sound_size dw 0xFFFF	;65535

times 512 -($-$$) db 0

sound_data1: incbin "raw/ba_0001.raw"
sound_data2: incbin "raw/ba_0002.raw"
sound_data3: incbin "raw/ba_0003.raw"
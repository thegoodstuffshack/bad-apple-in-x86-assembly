[bits 16]
[org 0x7c00]	; remove when adding to full program
jmp start		; desired frequency = 1193181.666... / input value
				; round to nearest even value (maybe idfk)

;; CONSTANTS
%include "note_defs.data"

;; VARIABLES

; nasm -f bin audio.asm -o test.bin
; qemu-system-x86_64 -audiodev dsound,id=id -machine pcspk-audiodev=id test.bin

start:
	call test
	call speaker_init

	mov si, LOW_A
	call music_player
cli
hlt

music_player:
	call on

	.loop:
	cmp si, HIGH_B
	ja .end

	mov ax, [si]
	call hz_change
	call delay

	add si, 2
	jmp .loop

	.end:
	call off
ret

delay:	; make from PIT instead
	mov ah, 0x86
	mov al, 0
	mov cx, 0x0002
	mov dx, 0xf000
	int 0x15
ret

hz_change:	; needs ax input
	cli
	out 0x42, al
	mov al, ah
	out 0x42, al
	sti
ret

on:	; enable speaker
	in al, 0x61
	or al, 0b00000011
	out 0x61, al
ret

off:		; disable speaker
	in al, 0x61
	and al, 0b11111100
	out 0x61, al
ret

speaker_init:
	cli
	mov al, 0b10110110 ; channel 2, hi/lo, mode 3
	out 0x43, al
	sti
ret

test:
	mov ah, 0x0e
	mov al, 1
	int 0x10
ret

jmp $
times 510-($-$$) db 0
dw 0xaa55
[bits 16]
[org 0x7c00]
jmp start

;; CONSTANTS

;; VARIABLES

; nasm -f bin audio.asm -o test.bin
; qemu-system-x86_64 -audiodev dsound,id=id -machine pcspk-audiodev=id test.bin

start:
	call test
	
	call pc_speaker_init
	
	jump:
	call sound
	;call delay
	;call stop
 
	call test
	jmp $
cli
hlt

test:
	mov ah, 0x0e
	mov al, 1
	int 0x10
ret

sound:
	in al, 0x61
	or al, 0b00000011
	out 0x61, al
ret

stop:
	in al, 0x61
	and al, 0b11111100
	out 0x61, al
ret

delay:
	mov ah, 0x86
	mov al, 0
	mov cx, 0x0000
	mov dx, 0xf000
	int 0x15
ret


; 1.1931816666 MHz, 1193182Hz / value = freq

pc_speaker_init:
	cli
	mov al, 0b10110110 ; channel 2, hi/lo, mode 3
	out 0x43, al

	mov ax, 0x1128
	out 0x42, al
	mov al, ah
	out 0x42, al
	sti
ret

jmp $
times 510-($-$$) db 0
dw 0xaa55

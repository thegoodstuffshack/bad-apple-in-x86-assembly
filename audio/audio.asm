[bits 16]
[org 0x7c00]
jmp start

;; CONSTANTS

MIDDLE_C equ 0x11d0
MIDDLE_D equ 0x0fe0
MIDDLE_E equ 0x0e24
MIDDLE_F equ 0x0d58
MIDDLE_G equ 0x0be4

;; VARIABLES

; nasm -f bin audio.asm -o test.bin
; qemu-system-x86_64 -audiodev dsound,id=id -machine pcspk-audiodev=id test.bin

start:
	call test
	call pc_speaker_init ; starting spk here causes lengthened first note
	
	.loop:
	mov ax, MIDDLE_C
	call hz_change
	call sound
	call delay
	
	mov ax, MIDDLE_D
	call sound
	call delay
	
	mov ax, MIDDLE_E
	call hz_change
	call sound
	call delay
	
	mov ax, MIDDLE_F
	call hz_change
	call sound
	call delay
	
	mov ax, MIDDLE_G
	call hz_change
	call sound
	call delay
	
	call stop
	call delay
	
	jmp start
cli
hlt

hz_change:
	cli
	out 0x42, al
	mov al, ah
	out 0x42, al
	sti
ret

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
	mov cx, 0x0002
	mov dx, 0xf000
	int 0x15
ret

; desired frequency = 1193181.666... / input value
; round to nearest even value (maybe idfk)

pc_speaker_init:
	cli
	mov al, 0b10110110 ; channel 2, hi/lo, mode 3
	out 0x43, al

	mov ax, 0x11D0	; input value
	out 0x42, al
	mov al, ah
	out 0x42, al
	sti
ret

jmp $
times 510-($-$$) db 0
dw 0xaa55

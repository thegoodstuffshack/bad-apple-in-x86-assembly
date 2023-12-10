[bits 16]
[org 0x7c00]	; remove when adding to full program
jmp start		; desired frequency = 1193181.666... / input value

;; CONSTANTS
RELOAD_VALUE	equ 0xA8F4	; music timings
TIMER_ADDRESS	equ 0x046c	; PIT 0 count address
MAX_BARS		equ 80

;; VARIABLES
BOOT_DRIVE	db 0
BAR_COUNT	dw 0
note_count	dw 0

; nasm -f bin audio.asm -o test.bin
; qemu-system-x86_64 -audiodev dsound,id=id -machine pcspk-audiodev=id test.bin

start:
	xor ax, ax
	mov ds, ax
	mov si, ax
	mov es, ax
	mov di, ax
	
	mov ax, 0x9000
	mov ss, ax
	mov sp, 0x0000

	mov [BOOT_DRIVE], dl

	mov al, 1
	call print
	
	call speaker_init
	call PIT_INIT
	call load_frame
	
	mov al, 2
	call print
	
	mov cx, 1
	call PIT_timer
	
	mov al, 3
	call print

.loop:
	mov cx, [BAR_COUNT]
	cmp cl, MAX_BARS
	jz .end_audio
	mov bx, cx
	inc byte [BAR_COUNT]
	
	add bx, song	; addr of song offset by bar_count
	mov bl, [bx]
	
	mov al, 2
	mul bl
	
	mov di, bar_addresses
	add di, ax
	mov di, [di]

	call bar_player
	jmp .loop

.end_audio:
	mov al, 14
	call print
	call off
cli
hlt

bar_player:	; di is address of bar to play
	mov word [note_count], 0
.loop:
	mov bx, [note_count]
	mov al, [di+bx]
	cmp al, 255
	je .end
	
	mov cl, al
	
	and al, 0b00011111	; offset of note Hz
	mov si, BASS
	
	xor ah, ah
	add si, ax
	mov ax, [si]
	call hz_change
	call on
	
	mov al, bl
	call print
	
	shr cl, 5
	xor ch, ch
	mov si, SEMIQUAVER
	add si, cx
	mov cl, [si]
	mov al, cl
	call print
	call PIT_timer
	; call off
	; call PIT_timer
	inc word [note_count]
	jmp .loop

.end:
	mov ax, di
	mov al, ah
	call print
	mov ax, di
	call print
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

speaker_init:	; program PIT 2 for pcspk
	cli
	mov al, 0b10110110 ; channel 2, hi/lo, mode 3
	out 0x43, al
	sti
ret

PIT_INIT:
	cli
	mov al, 0b00110100	; channel 0, hi/lo, mode 2
	out 0x43, al
	mov ax, RELOAD_VALUE
	out 0x40, al
	mov al, ah
	out 0x40, al
	sti
ret

PIT_timer:	; not the 'proper way' to implement pit
			; needs cx input for cycle delay
	
	.timer:
	mov ax, [TIMER_ADDRESS]
	mov bx, ax
	; inc bx
	add bx, cx
	
	.loop:
	cmp ax, bx
	jae .tick		; wait til PIT ticks
	
	mov ax, [TIMER_ADDRESS]
	jmp .loop

	.tick:
ret

print:	; al as input
	mov ah, 0x0e
	int 0x10
ret

load_frame:
	mov ah, 0x02	; read data to memory
	mov al, 1	; no. of sectors
	mov ch, 0 ; cylinder_count 
	mov cl, 2	; sector in head
	mov dh, 0 ;[si+5]	; head_count
	mov dl, [BOOT_DRIVE]	;[si]	; boot_drive
	xor bx, bx
	mov es, bx
	mov bx, 0x7e00;[si+7]	; frame_address
	int 0x13
	jc disk_error
ret

disk_error:
	mov al, 48
	call print
	jmp $


jmp $
times 510-($-$$) db 0
dw 0xaa55

;; SONG
%include "song.data"
%include "note_defs.data"

times 512*2-($-$$) db 0
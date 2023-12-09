[bits 16]
[org 0x7c00]
jmp start

;; CONSTANTS
TIMER_ADDRESS 		equ	0x046c	; location of PIT timer count
RELOAD_VALUE 		equ	0x9b84  ; determines tick speed of PIT
number_of_frames 	equ	3281	; divide frames by 2
FOREGROUND 		equ 	35
BACKGROUND		equ 	32

; default values set in case of failed parameter check
BOOT_DRIVE	db 0 	; si 		; init variable
max_sectors	db 15 	; si+1
max_heads	db 255	; si+2
max_cylinders 	db 255 	; si+3

;; EDIT THESE VALUES FOR BOOTING USING BARE-METAL
sector_count	db 1		; si+4
head_count		db 0	 	; si+5
cylinder_count	db 0		; si+6
frame_address	dw 0x7e00	; si+7

;; CODE
start:
	xor ax, ax
	mov ds, ax
	mov si, ax
	mov es, ax
	
	mov ax, 0x9000
	mov ss, ax
	mov sp, 0x0000
	
	mov byte [BOOT_DRIVE], dl
	mov al, dl
	mov ah, 0x0e
	int 0x10
	
	call PIT_init
	call check_disk_parameters
	;call print_disk_parameters
	call PIT_timer

	; sets cursor to invisible to remove flickering
	mov ah, 0x01
	mov ch, 0b0010
	mov cl, 0b0000
	int 0x10
	
	mov cx, number_of_frames
run:
	cmp cx, 0
	je .end
	dec cx
	push cx
	
	call PIT_timer
	call frame_handler
	call load_frame
	call reset_cursor

	call frame
	call PIT_timer
	call reset_cursor
	
	mov word [frame_address], 0x7f00
	call frame
	mov word [frame_address], 0x7e00
	; assuming 2 frames per sector
	
	pop cx
	jmp run
	
	.end:
cli
hlt

reset_cursor:
	mov ah, 0x02
	mov bh, 0
	xor dx, dx
	int 0x10			; move cursor to 0,0
ret

disk_reset:
	mov ah, 0x00
	mov dl, [BOOT_DRIVE]
	int 0x13
ret


%include "src/disk_functions.asm"
%include "src/pit.asm"
%include "src/print.asm"
%include "src/load.asm"

jmp $ ; catch in case code decides to run away
times 510 -($-$$) db 0
dw 0xAA55

%include "src/frames.asm"	; append frame data to .bin and compile

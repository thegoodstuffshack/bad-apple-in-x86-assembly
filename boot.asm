[bits 16]
[org 0x7c00]
jmp start

;; CONSTANTS
foreground		db	35		; character of 1, ascii hashtag
background 		db 	32		; character of 0, ascii space
FRAME_NUMBER	dw	256		; 0x0000 + 0x0100 * x, max of x before cf
TIMER_ADDRESS 	equ	0x046c	; location of PIT timer count
RELOAD_VALUE 	dw	0x9b84  ; determines tick speed of PIT

; default values set in case of failed parameter check
BOOT_DRIVE		db 0  ; si 		; init variable
max_sectors		db 15 ; si+1	; 0-based from earlier dec
max_heads		db 15 ; si+2	; not used yet
max_cylinders 	db 0  ; si+3	; not used yet

head_count		db 0  ; si+4	; live head count
cylinder_count	db 0  ; si+5

;; CODE
start:
    
	xor ax, ax
	mov ss, ax
	mov ds, ax
	mov es, ax
	
	mov byte [BOOT_DRIVE], dl
	mov al, dl
	mov ah, 0x0e
	int 0x10
	
	call PIT_init
	call check_disk_parameters
	;call print_disk_parameters
	call load_memory
	;call PIT_timer

	; sets cursor to invisible to remove flickering
	mov ah, 0x01
	mov ch, 0b0010
	mov cl, 0b0000
	int 0x10
	
	; print each frame_number segment
	push 0x07e0
	call video
	push 0x17e0
	call video
	push 0x27e0
	call video
	push 0x37e0
	call video
	push 0x47e0
	call video
	push 0x57e0
	call video
	push 0x67e0
	call video
	; push 0x77e0
	; call video
	
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
	mov dl, [si]
	int 0x13
ret

load_memory:
	mov si, BOOT_DRIVE ; si equ BOOT_DRIVE address
	call disk_reset

; special load for first
	mov ah, 0x02
	mov al, [si+1]
	dec al
	mov ch, [si+5]
	mov cl, 2
	mov dh, [si+4]
	mov dl, [si]
	xor bx, bx
	mov es, bx
	mov bx, 0x7e00	; ntc
	int 0x13		; 0000:7c00
	jc disk_error
	
	inc byte [si+4]
	
	.start_loop:
	xor cx, cx
	.loop:
	cmp cl, 15;[max_heads]
	je .cylinder_increment
	push cx
	
	call disk_reset
	
	; addresses
	mov ax, 0x07c0
	mul cx
	mov es, ax
	mov bx, 0xfa00

	;int
	mov ah, 0x02
	mov al, [si+1]
	mov ch, [si+5]
	mov cl, 1 ; sector on track
	mov dh, [si+4]
	mov dl, [si]
	int 0x13
	jc disk_error
	
	inc byte [si+4]
	pop cx
	inc cx
	jmp .loop
	
	.cylinder_increment:
	; mov cl, [si+3]
	; cmp byte [si+5], cl
	; je .end
	; inc byte [si+5]
	; jmp .start_loop
	
	.end:
ret

%include "disk_functions.asm"
%include "video.asm"
%include "pit.asm"
%include "print.asm"



times 510 -($-$$) db 0
dw 0xAA55

%include "frames.asm"
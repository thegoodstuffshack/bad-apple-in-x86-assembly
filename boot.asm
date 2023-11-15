[bits 16]
[org 0x7c00]
jmp start
;	Prints Frames to the screen

;; DATA
foreground		db 35	; 219
background 		db 32	; ascii space
BOOT_DRIVE		db 0     ; init variable

max_sectors		dw 0	; gives 61+2 as 63 is max
max_cylinders 	dw 0	; not used yet
max_heads		dw 0

sector_count 	db 0
head_count		db 0
cylinder_count 	db 0

;; CODE
start:
    mov [BOOT_DRIVE], dl

	;call check_disk_parameters
	call load_memory
	call video
cli
hlt

delay:
	mov ah, 0x02
	mov bh, 0
	xor dx, dx
	int 0x10			; move cursor to 0,0
	mov ah, 0x86
	mov cx, 0x0000		; CX:DX interval in microseconds
	mov dx, 0x4000		;
	int 0x15			; delay between frames
ret

print_test:
	mov ah, 0x0e
	mov al, 58
	int 0x10
ret

;extended_load_memory

load_memory:
	push bp
	mov bp, sp
	
	mov cx, 0
	.loop:
	cmp cx, 62;[max_sectors]		; how much data to load				;;;;
	je .end
	push cx		; preserve count
	
	;push byte 1		;[bp+7]
	mov ax, 0x0200			; 0b0000 0010 0000 0000
	mul cx
	add ax, 0x7e00
	push ax ; [bp+6] ;push 0x7e00 + bx * 0x0200
	mov bx, 0x0002
	add bx, cx
	push bx ; [bp+4] ;push 0x0002 + bx		; 2+61
	
	call read_this
	
	pop cx		; restore count
	inc cx		; increment count
	inc byte [sector_count]
	jmp .loop
	
	.inc_cylinder:
	mov ah, 0x0e
	mov al, ch
	int 0x10
	cmp ch, 0x10
	je .end
	add ch, 0x10
	mov cl, 0
	jmp .loop
	
	.end:
	; mov ah, 0x0e
	; mov al, 50
	; int 0x10
	pop bp
ret

video:
	push bp
	mov bp, sp
	
	mov cx, 0
	.loop:
	cmp cx, 124									;; frames ;;
	je .end
	
	push cx
	mov ax, 0x0100
	mul cx
	mov bx, 0x7e00
	add bx, ax
	push bx
	call frame
	call delay
	
	pop cx
	inc cx
	; mov ah, 0x0e
	; mov al, 52
	; int 0x10
	jmp .loop
	
	.end:
	pop bp
ret	

%include "print.asm"
%include "disk_functions.asm"

times 510 -($-$$) db 0
dw 0xAA55

;; test
; %include "1.data"
; times 3 * 256 -($-$$) db 0
; %include "2.data"
; times 4 * 256 -($-$$) db 0
; %include "3.data"
; times 5 * 256 -($-$$) db 0
; %include "4.data"
; times 6 * 256 -($-$$) db 0

%include "frames.asm"

; %include "data0.asm"
; times 2 * 512 -($-$$) db 0

; %include "data1.asm"
; times 4 * 512 -($-$$) db 0
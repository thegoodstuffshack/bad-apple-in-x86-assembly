[bits 16]
[org 0x7c00]
jmp start
;	Prints Frames to the screen

;; VARIABLES
foreground		db 35	; 219
background 		db 32	; ascii space
BOOT_DRIVE		db 0     ; init variable

FRAME_NUMBER	dw 256	; 0x0000 + 0x0100 * x, max of x bfor cf

max_sectors		db 15	; 0-based from earlier dec
max_heads		db 20
max_cylinders 	db 0	; not really necessary

head_count		db 0	; live head count

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
	
	call check_disk_parameters
	;call print_disk_parameters
	call load_memory

	mov ah, 0x01
	mov ch, 0b0010
	mov cl, 0b0000
	int 0x10

	push 0x07e0
	call video
	push 0x17e0
	call video
	push 0x27e0
	call video
	;push 0x37e0
	;call video
	
cli
hlt

delay:
	mov ah, 0x02
	mov bh, 0
	xor dx, dx
	int 0x10			; move cursor to 0,0
	mov ah, 0x86
	mov al, 0
	mov cx, 0x0000		; CX:DX interval in microseconds
	mov dx, 0x1000		; roughly 29.54fps on qemu 
	int 0x15			; delay between frames
ret

load_memory:
; special load for first
	mov ah, 0x02
	mov al, [max_sectors]
	dec al
	mov ch, 0
	mov cl, 2
	mov dh, [head_count]
	mov dl, [BOOT_DRIVE]
	xor bx, bx		; need to change
	mov es, bx
	mov bx, 0x7e00	; ntc
	int 0x13		; 0000:7c00
	;jc disk_error
	
	inc byte [head_count]
	
	mov cx, 0
	.loop:
	cmp cx, 7
	je .end
	push cx
	
	; addresses
	mov ax, 0x07c0
	mul cx
	mov bx, ax
	mov es, bx
	mov bx, 0xfa00

	;int
	mov ah, 0x02
	mov al, [max_sectors]
	mov ch, 0 ; cylinder
	mov cl, 1 ; sector on track
	mov dh, [head_count]
	mov dl, [BOOT_DRIVE]
	int 0x13
	;jc disk_error
	
	inc byte [head_count]
	pop cx
	inc cx
	jmp .loop
	
	.end:
	; mov byte [head_count], 0
	; mov ax, 0x07c0
	; mul cx
	; mov bx, ax
	; mov es, bx
	; mov bx, 0xfa00
	; mov ah, 0x02
	; mov al, [max_sectors]
	; mov ch, 1 ; cylinder
	; mov cl, 1 ; sector on track
	; mov dh, [head_count]
	; mov dl, [BOOT_DRIVE]
	; int 0x13
	; jc disk_error
ret

%include "print.asm"
%include "video.asm"
%include "disk_functions.asm"

times 510 -($-$$) db 0
dw 0xAA55

%include "frames.asm"
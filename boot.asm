[bits 16]
[org 0x7c00]
jmp start
;	Prints Frames to the screen

;; VARIABLES
foreground		db 35	; 219
background 		db 32	; ascii space
BOOT_DRIVE		db 0     ; init variable

FRAME_NUMBER	dw 130	; 130 is max for 0x7c00 to 0xFF00
ES_READ_EXTRA	db 0

max_sectors		db 0	; 0-based from earlier dec
max_heads		db 0
max_cylinders 	db 0	; not really necessary

sector_count 	db 1	; live sector count, 1-based
head_count		db 0	; live head count
cylinder_count 	db 0	; live cylinder count

;; CODE
start:
    
	xor ax, ax
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov ax, 0x7c00
	;mov sp, ax
	
	mov bx, 0x1000
	mov es, bx
	xor bx, bx
	mov bx, word [es:bx]
	
	
	mov byte [BOOT_DRIVE], dl
	mov al, dl
	mov ah, 0x0e
	int 0x10
	
	call check_disk_parameters
	;call print_disk_parameters
	call load_memory_test


	push 0x0000
	call video
	
	push 0x1000
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

; print_test:
	; mov ah, 0x0e
	; mov al, 58
	; int 0x10
; ret

load_memory_test:
	mov ah, 0x00
	mov dl, [BOOT_DRIVE]
	int 0x13
	jc disk_error1
	
	mov ah, 0x02
	mov al, [max_sectors]
	mov ch, [cylinder_count]
	mov cl, 2
	mov dh, [head_count]
	mov dl, [BOOT_DRIVE]
	xor bx, bx		; need to change
	mov es, bx
	mov bx, 0x7e00	; ntc
	int 0x13		; 0000:7c00
	jc disk_error1
	
	;inc byte [cylinder_count]
	inc byte [head_count]
	mov ah, 0x00
	mov dl, [BOOT_DRIVE]
	int 0x13
	jc disk_error1
	
	mov ah, 0x86
	mov cx, 0x0008		; CX:DX interval in microseconds
	mov dx, 0x4000		;
	int 0x15			; delay between frames
	
	mov ah, 0x02
	mov al, [max_sectors]
	;add al, [max_sectors]
	mov ch, [cylinder_count]
	mov cl, 1
	mov dh, [head_count]
	mov dl, [BOOT_DRIVE]
	xor bx, bx		; need to change
	mov es, bx
	mov bx, 0x7c00;0xFa00	; ntc
	add bx, 0x7c00
	add bx, 0x0200
	int 0x13		; 0000:7c00
	jc disk_error2

ret

video:
	push bp
	mov bp, sp
	
	mov cx, 0
	.loop:
	cmp cx, [FRAME_NUMBER]			;; frames ;;
	je .end
	push cx
	
	mov bx, [bp+4]
	mov es, bx
	push bx
	
	mov ax, 0x0100
	mul cx
	mov bx, 0x7e00	;0x7e00
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
ret	2

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
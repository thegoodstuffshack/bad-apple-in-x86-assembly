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

memory_sector_count 	db 1
memory_cylinder_count 	db 0

;; CODE
start:
    mov [BOOT_DRIVE], dl

	call check_CHS
	;call load_memory
	
	;call video
	
cli
hlt

delay:
	mov ah, 0x02
	mov bh, 0
	xor dx, dx
	int 0x10			; move cursor to 0,0
	mov ah, 0x86
	mov cx, 0x0000
	mov dx, 0x4000
	int 0x15			; delay between frames
ret

print_test:
	mov ah, 0x0e
	mov al, 58
	int 0x10
ret

;extended_load_memory

check_CHS:
	push bp
	mov bp, sp
	mov cx, 0
	clc
	
	.loop:
	jc .carry
	
	push cx
	push byte 0			;[bp+7]
	push word 0x7c00	;[bp+6]
	
	mov bx, 0x0001
	add bx, cx
	push bx				;[bp+4]
	call read_this
	
	pop cx
	inc cx
	jmp .loop
	
	.carry:
	mov word [max_sectors], cx
	mov al, cl
	mov ah, 0x0e
	int 0x10
	jmp $

load_memory:
	push bp
	mov bp, sp
	
	mov cx, 0
	.loop:
	cmp cx, [max_sectors]		; how much data to load					;;;;
	je .end
	push cx		; preserve count
	
	push byte 1		;[bp+7]
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
	inc byte [memory_sector_count]
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
	cmp cx, 30									;; frames ;;
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

read_this:
	push bp
	mov bp, sp
	
	mov bx, word [bp+6]	;;
	mov cx, word [bp+4]	;;
	
	mov ah, 0x02
	mov al, 1
	xor dx, dx
	mov es, dx
	mov dl, [BOOT_DRIVE]
	int 0x13
	jc test_if_want_to_end
	
	read_this_continue:
	pop bp
ret 5

test_if_want_to_end:
	;mov bl, byte [bp+7]
	;cmp bl, 0
	;jne disk_error
	stc ; sets carry flag
	jmp read_this_continue

disk_error:
	mov al, ah
	add al, 40
	mov ah, 0x0e
	int 0x10
	
	mov al, [memory_sector_count]
	int 0x10
	jmp $

frame:
	push bp
	mov bp, sp

	xor cx, cx
	mov si, cx
	mov cx, 120			 ; replace if want different amount
	;mov cx, word [bp+4] ; than 120 then need to implement push
	mov bx, word [bp+4]	 ; change pointer if above is changed (1) [bp+6]

	.loop:
	cmp cx, 0
	je .end
	dec cx
	push cx
	push si

	push word [bx+si]
	call shift_print

	pop si
	pop cx
	mov bx, word [bp+4]	 ; change pointer if above is changed (1) [bp+6]
	add si, 2
	jmp .loop

	.end:
	pop bp
ret 2		; change to 4 if above is changed (1)

shift_print:
	push bp
	mov bp, sp
	mov cl, 0
	.loop:
	cmp cl, 16
	je .shift_print_end

	mov bx, word [bp+4]
	shl bx, cl
	push bx
	call print
	pop bx
	inc cl
	jmp .loop

	.shift_print_end:
	; mov ax, 0x0e00
	; int 0x10
	pop bp
ret 2

print:
	push bp
	mov bp, sp

	mov ah, 0x0e
	mov bx, word [bp+4]
	cmp bh, 0x80	; 1000 0000 ; 128
	jb .zero
	.one:
		mov al, byte [foreground]
		int 0x10
		jmp .end_print
	.zero:
		mov al, byte [background]
		int 0x10
	.end_print:
	pop bp
ret

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
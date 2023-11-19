check_disk_parameters:
	push bp
	mov bp, sp
	xor ax, ax
	mov es, ax
	mov di, ax
	mov ah, 0x08
	mov dl, [BOOT_DRIVE]
	int 0x13
	;jc disk_error
	
	mov al, ch	; preserve low 8 bits of cylinder max for later
	
	; bits 0-5 of cl is max sector no.
	; starts at 1
	and cx, 63 ; 0b00111111
	mov [max_sectors], cl
	
	; dh has max no. of heads, starts at 0
	mov dl, dh
	mov [max_heads], dl
	
	; max cylinder no., starts at 0
	mov cl, al
	mov [max_cylinders], cl
	pop bp
ret

; print_disk_parameters:	;; change registers to 8 bit
	; mov ah, 0x0e
	
	; mov al, [max_sectors]
	; ;mov al, cl
	; add al, 48
	; int 0x10	; o is 63
	
	; mov al, [max_cylinders]
	; ;mov al, cl
	; add al, 48
	; int 0x10	; 0 means 1 cylinder
	
	; mov al, [max_heads]
	; ;mov al, cl
	; add al, 48
	; int 0x10	; ? means 16 heads
; ret

disk_error:
	mov cl, al
	mov al, ah
	;add al, 40
	mov ah, 0x0e
	int 0x10
	
	mov al, cl
	int 0x10
	
	mov al, 1
	int 0x10
cli
hlt
check_disk_parameters:
	push bp
	mov bp, sp
	xor ax, ax
	mov es, ax
	mov di, ax
	mov ah, 0x08
	mov dl, [BOOT_DRIVE]
	int 0x13
	jc disk_error5
	
	mov al, ch	; preserve low 8 bits of 
				; cylinder max for later
	
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

read_this:
	push bp
	mov bp, sp
	
	mov bx, word [bp+4]	;; address
	;mov cx, word [bp+4];; sector no. 1-63
	mov cl, [sector_count]
	mov ch, [cylinder_count]
	
	mov ah, 0x02
	mov al, 1
	xor dx, dx
	mov es, dx
	mov dx, [head_count]
	mov dh, dl
	mov dl, [BOOT_DRIVE]
	int 0x13
	jc disk_error4
	
	read_this_continue:
	pop bp
ret 4

disk_error1:
	mov al, ah
	;add al, 40
	mov ah, 0x0e
	int 0x10
	
	mov al, 49
	int 0x10
	
	;mov al, [sector_count]
	;int 0x10disk_error:
cli
hlt

disk_error2:
	mov al, ah
	;add al, 50
	mov ah, 0x0e
	int 0x10
	
	mov al, 50
	int 0x10
	
	; mov al, [sector_count]
	; int 0x10
disk_error4:
	mov al, ah
	;add al, 50
	mov ah, 0x0e
	int 0x10
	
	mov al, 52
	int 0x10
	
	; mov al, [sector_count]
	; int 0x10
disk_error5:
	mov al, ah
	;add al, 50
	mov ah, 0x0e
	int 0x10
	
	mov al, 53
	int 0x10
	
	; mov al, [sector_count]
	; int 0x10
cli
hlt
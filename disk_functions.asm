check_disk_parameters:
	push bp
	mov bp, sp
	
	xor ax, ax
	mov es, ax
	mov di, ax
	mov ah, 0x08
	mov dl, [BOOT_DRIVE]
	int 0x13
	
	mov al, ch
	
	; bits 0-5 of cl is max sector no.
	and cx, 63 ; 0b00111111
	mov [max_sectors], cx
	
	; max cylinder no.
	mov cl, al
	mov [max_cylinders], cx
	
	; dh has max no. of heads
	mov dl, dh
	xor dh, dh
	mov [max_head], dx
	
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
	jc disk_error
	
	read_this_continue:
	pop bp
ret 4

disk_error:
	mov al, ah
	add al, 40
	mov ah, 0x0e
	int 0x10
	
	mov al, [sector_count]
	int 0x10
cli
hlt
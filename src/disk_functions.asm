check_disk_parameters:
	mov si, BOOT_DRIVE
	
	xor ax, ax
	mov es, ax
	mov di, ax
	mov ah, 0x08
	mov dl, [si]
	int 0x13
	jc .end	; if read fails, dont overwrite default values
	
	mov al, ch	; preserve low 8 bits of cylinder max for later
	
	; bits 0-5 of cl is max sector no.
	; starts at 1
	and cx, 63 ; 0b00111111
	mov [si+1], cl
	
	; dh has max no. of heads, starts at 0
	mov dl, dh
	mov [si+2], dl
	
	; max cylinder no., starts at 0
	mov cl, al
	mov [si+3], cl
	
.end:
ret

disk_error:	; status, head, sector
	mov cl, al
	mov al, ah
	mov ah, 0x0e
	int 0x10
	
	mov al, [head_count]
	int 0x10
	
	mov al, cl
	int 0x10
hlt

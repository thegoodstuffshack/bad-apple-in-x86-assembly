load_memory_test:
	push bp
	mov bp, sp

	mov ah, 0x00
	mov dl, byte [BOOT_DRIVE]
	int 0x13
	jc disk_error
	
	mov ah, 0x02
	mov al, [max_sectors]
	mov ch, [cylinder_count]
	mov cl, 1	;sector track starting no.
	mov dh, [head_count]
	mov dl, byte [BOOT_DRIVE]
	xor bx, bx		; need to change
	mov es, bx
	mov bx, 0x7c00	; doesnt break as loads code on itself
	int 0x13		; 0000:7c00
	jc disk_error


	pop bp
ret
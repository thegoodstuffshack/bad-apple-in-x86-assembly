new_load_memory:
	push bp
	mov bp, sp
	
	mov cx, 0
	mov bx, 0x7e00
	
	.loop_cylinder:
	mov cx, [memory_cylinder_count]
	cmp cx, [max_cylinders]
	je .end:
	inc [memory_cylinder_count]
	
	
	
	.loop:
	mov cx, [memory_sector_count]
	cmp cx, [max_sectors]
	je .loop_cylinder
	push cx
	
	mov ax, 0x0200
	mul cx
	add ax, 0x7e00
	
	push ax	;[bp+4]
	call load_this_cylinder
	
	
	
	
	
	.end:
	pop bp
ret


load_this_cylinder:
	push bp
	mov bp, sp
	
	
	.end:
	pop bp
ret
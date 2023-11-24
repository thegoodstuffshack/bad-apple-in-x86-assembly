;; load.asm

frame_handler:
	mov si, BOOT_DRIVE
	
	inc byte [si+4]	; inc sector_count
	mov al, [si+4]
	cmp al, [si+1]	; cmp sector_count to max_sectors
	jbe .end		; if below or equal, end
	
	mov byte [si+4], 1	; zero sector_count
	inc byte [si+5]		; inc head_count
	mov al, [si+5]
	cmp al, [si+2]	; cmp head_count to max_heads
	jbe .end		; if below or equal, end
	
	mov byte [si+4], 1	; zero sector_count
	mov byte [si+5], 0	; zero head_count
	inc byte [si+6]		; inc cylinder_count
	mov al, [si+6]
	;cmp al, [si+3]	; cmp cyl_count to max_cylinders
	;ja load_overflow
	
	
	.end:
	mov ah, 0x0e
	mov al, 'h'
	int 0x10
ret

load_overflow:
	mov ah, 0x0e
	mov al, 2
	int 0x10
hlt

retry_count db 0

load_frame:
	mov si, BOOT_DRIVE
	call disk_reset
	
	mov ah, 2;0x02	; read data to memory
	mov al, 1	; no. of sectors
	mov ch, [cylinder_count];[si+6]	; cylinder_count 
	mov cl, [sector_count];[si+4]	; sector in head
	mov dh, [head_count];[si+5]	; head_count
	mov dl, [BOOT_DRIVE];[si]	; boot_drive
	xor bx, bx
	mov es, bx
	mov bx, 0x7e00;[si+7]	; frame_address
	int 0x13
	jc disk_error;retry
	
	mov ah, 0x0e
	mov al, 'f'
	int 0x10
ret

retry:	; if used need to reset counter
	mov cl, [retry_count]
	cmp cl, 5
	je disk_error
	inc byte [retry_count]
	jmp load_frame
hlt
	
;; DOSBOX .com
;; modified from https://www.youtube.com/watch?v=4SBUrv7fXqI
;; and https://github.com/leonardo-ono/Assembly8086PlayPcmDigitizedSoundOnPCSpeakerTest
[bits 16]
[org 0x7c00]
jmp start

;; ======================================
; nasm -f bin pwm.asm -o pwm.bin
; qemu-system-x86_64 -audiodev dsound,id=id -machine pcspk-audiodev=id pwm.bin
;; ======================================

start:
	;; SETUP
	mov [BOOT_DRIVE], dl
	
	xor ax, ax
	mov es, ax

	call load_audio	; 126 sectors
	
	mov al, 12
	call print
	
	mov bl, 0x01;0x4a; 16000 Hz sampling rate
	call change_timer_0
	
	;; MUSIC LOOP
.loop:
	;push word 
	push word 0x0000
	call music_segment
	
	mov al, 1
	call print
	
	push word 0x1000
	call music_segment
	
	mov al, 1
	call print
	
	push word 0x2000
	call music_segment
	
	jmp exit
	
;; ======================================
music_segment:
	push bp
	mov bp, sp
	mov si, 0

next_sample:
	mov dx, [es:046ch] ; int 8 counter address
delay:
	cmp dx, [es:046ch]
	jz delay

	mov dl, [sound_data + si]
	shr dl, 2 ; convert to 6-bit sound
	          ; by dividing it by 4
	
	mov cx, 0
next_amplitude:

	cmp cl, dl
	jb on
	ja off
equal:
	mov al, 219 ; white filled square char
	call print
on:
	call speaker_on
	mov al, ' '
	call print
	jmp short continue
off:
	call speaker_off
	mov al, ' '
	call print
continue:
	inc cx
	cmp cx, 75
	jb next_amplitude

	; exit if keypress
	mov ah, 1
	int 16h
	jnz exit
	
	inc si
	cmp si, [sound_size]
	jae restart_sound
	
	; print cr & ln
	mov al, 0dh
	call print
	mov al, 0ah
	call print
	
	jmp next_sample
	
restart_sound:
	;mov si, 0
	;jmp next_sample
	
	pop bp
ret 2
;; ======================================
exit:
	call speaker_off
	
	; restore original 18.2Hz timer
	mov bl, 0
	call change_timer_0
	
	jmp $
;; ======================================
change_timer_0:	; bl = timer divider
	cli
	mov al, 0b00010110	; 0001 0110
	out 43h, al
	mov al, bl
	out 40h, al
	sti
ret
;; ======================================
speaker_on:
	in al, 0x61
	or al, 2	; 0000 0011
	out 0x61, al
ret
speaker_off:
	in al, 0x61
	and al, 0b11111100
	out 0x61, al
ret
;; ======================================
print:	; al = printed character
	mov ah, 0x0e
	int 0x10
ret
;; ======================================
load_audio:
	mov ah, 0x02
	mov al, 63
	mov ch, 65
	mov cl, 38
	mov dh, 101
	mov dl, [BOOT_DRIVE]
	mov bx, 0x7e00
	int 0x13
	mov dl, 1
	jc disk_error
	mov ah, 0x02
	mov al, 63
	mov ch, 65
	mov cl, 37
	mov dh, 102
	mov dl, [BOOT_DRIVE]
	mov bx, 0xfc00
	int 0x13
	mov dl, 2
	jc disk_error
ret

disk_error:
	mov al, ah
	call print
	mov al, dl
	call print
	jmp $
;; ======================================

BOOT_DRIVE db 0

sound_size dw 0xFFFF	;65535
;; ======================================

times 510 -($-$$) db 0
dw 0xAA55
;; ======================================

;; data segment size: 128 sectors
sound_data: incbin "raw/ba_0001.raw"
times 512 * 128 -($-sound_data) db 0
sound_data2: incbin "raw/ba_0002.raw"
times 512 * 256 -($-sound_data) db 0
sound_data3: incbin "raw/ba_0003.raw"
times 512 * 384 -($-sound_data) db 0
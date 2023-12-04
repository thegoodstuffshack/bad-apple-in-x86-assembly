; ;; DOSBOX .com
; ;; modified from https://www.youtube.com/watch?v=4SBUrv7fXqI
; ;; and https://github.com/leonardo-ono/Assembly8086PlayPcmDigitizedSoundOnPCSpeakerTest

; ;; ======================================
; ; nasm -f bin pwm.asm -o pwm.bin
; ; qemu-system-x86_64 -audiodev dsound,id=id -machine pcspk-audiodev=id pwm.bin
; ;; ======================================
	
	bits 16
	org 100h
jmp start

start:

	; SETUP
	mov [BOOT_DRIVE], dl
	
	; setup es to get the system
	; timer count correctly
	mov ax, 0
	mov es, ax

	;call load_audio	; 126 sectors

	; change timer 0 to 1193180Hz
	mov bl, 1
	call change_timer_0
	
	mov si, 0 ; sound index

;; ======================================
next_sample:

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

	; wait 0.8381us
	call delay

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
	mov si, 0
	jmp next_sample
;; ======================================	
exit:
	; restore timer 0 to the original 18.2Hz
	mov bl, 0
	call change_timer_0

	; return to DOS
	mov ax, 4c00h
	int 21h
;; ======================================
; al = ascii code
print:
	mov ah, 0eh
	int 10h
	ret
;; ======================================	
speaker_on:
	in al, 61h
	or al, 2
	out 61h, al
	ret
	
speaker_off:
	in al, 61h
	and al, 11111100b
	out 61h, al
	ret
;; ======================================
; with the timer 0 set at 1193180Hz, this will
; delay for 0.8381us
; for every timer 0 tick, the irq 0 (int 8)
; will update the system timer count at 
; memory location 0000:046ch	
delay:
	mov di, [es:046ch]
_wait:
	cmp di, [es:046ch]
	jz _wait
	ret
;; ======================================
; bl = 0 -> restore original 18.2Hz timer 0
;      1 -> change timer 0 to 1193180Hz
change_timer_0:
	cli
	mov al, 16h
	out 43h, al
	mov al, bl
	out 40h, al
	sti
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
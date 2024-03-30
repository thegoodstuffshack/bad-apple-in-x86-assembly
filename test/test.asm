; Copyright (c) 2015 Michael C. Martin
;https://github.com/michaelcmartin/bumbershoot/blob/master/dos/sound/pcs_pwm.asm
;;; PC Speaker Pulse Width Modulation technique
;;;
;;; This routine demonstrates producing extremely high quality digital
;;; sound with the PC speaker by means of the Pulse Width Modulation
;;; technique.
;;;
;;; Despite the "cpu 8086" marker here, the fact that this code is
;;; firing timing interrupts at 16 kHz does mean that you will
;;; probably want a reasonably fast (12MHz+) machine. DOSBox's default
;;; 3000-cycles speed is fine.
        cpu     8086
        [bits 16]
        [org 0x7c00]	;100h
jmp start

counter equ     (0x1234DC / 16000) & 0xfffe             ; 0000 0000 0100 1001
                                                        ; 1111 1111 1111 1110
        ;segment .bss
biostick: resb  4
dataptr: resb   4
BOOT_DRIVE db   0

        ;segment .text
start:
        mov [BOOT_DRIVE], dl
        ;mov dx, dx
        ;mov es, dx
        ;mov ds, dx
        ;mov ss, dx
        
        ;; Record the original BIOS timing routine
        mov     ax, 0x3508
        int     21h
        mov     [biostick], bx
        mov     bx, es
        mov     [biostick+2], bx

;; ========================================================
        ;; Load data to memory
        mov ah, 0x02
        mov al, 62
        mov ch, 0
        mov cl, 1
        mov dh, 0
        mov dl, [BOOT_DRIVE]
        xor bx, bx
        mov es, bx
        mov bx, 0x7c00
        int 0x13
        jc .halt
        jmp .end
        .halt:
        mov al, 53
        mov ah, 0x0e
        ;mov al, 1
        int 0x10
        cli
        hlt
        .end:
;         ;; Load data to memory
;         mov ah, 0x02
;         mov al, 63
;         mov ch, 0
;         mov cl, 1
;         mov dh, 1
;         mov dl, [BOOT_DRIVE]
;        ;mov bx, 0x07e0
;         xor bx, bx
;         mov es, bx
;         mov bx, 0x7e00
;         int 0x13
;         jc .halt2
;         jmp .end2
;         .halt2:
;         mov al, ah
;         mov ah, 0x0e
;         ;mov al, 2
;         int 0x10
;         cli
;         hlt
;         .end2:
;; ========================================================

        ;; Load the data pointer for use by our sound code
        mov     ax, data
        mov     [dataptr], ax
        mov     ax, ds
        mov     [dataptr+2], ax

        ;; Replace IRQ0 with our sound code
        ;xor     dx, dx
        ;mov     ds, dx

        mov     dx, tick
        mov     ax, 0x2508
        int     21h

        ;; Attach the PC Speaker to PIT Channel 2
        in      al, 0x61
        or      al, 3
        out     0x61, al

        ;; Reprogram PIT Channel 0 to fire IRQ0 at 16kHz
        cli
        mov     al, 0b00110110;0x36                ; 0011 0110
        out     0x43, al
        mov     ax, counter
        out     0x40, al
        mov     al, ah
        out     0x40, al
        sti
        jmp mainlp
delay:
        mov ah, 0x86
        mov cx, 0x0000
        mov dx, 0x0001
        int 0x15
ret

        ;; Keep processing interrupts until it says we're done
mainlp: hlt
        ; mov ah, 0x0e
        ; mov al, 48
        ; int 0x10
        ;call delay
        call tick

        mov     ax, [done]
        or      ax, ax
        int 8
        jz      mainlp

        ;; Restore original IRQ0
        lds     dx, [biostick]
        mov     ax, 0x2508
        int     21h
        ;; Turn off the PC speaker
        in      al, 0x61
        and     al, 0xfc
        out     0x61, al

        ;; And quit with success
        cli
        hlt
        ;mov     ax, 0x4c00
        ;int     21h

        ;; *** IRQ0 TICK ROUTINE ***
tick:   push    ds              ; Save flags
        push    ax
        push    bx
        push    si

        mov ah, 0x0e
        mov al, 48
        int 0x10

        lds     bx, [dataptr]   ; Load our data pointers
        mov     si, [offset]
        cmp     si, datasize    ; past the end?
        jae     .nosnd
        mov     ah, [bx+si]  ; If not, load up the value
        shr     ah, 1           ; Make it a 7-bit value
        mov     al, 0xb6        ; And program PIT Channel 2 to          ; 1011 0110
        out     0x43, al        ; deliver a pulse that many
        mov     al, ah          ; microseconds long
        out     0x42, al
        xor     al, al
        out     0x42, al
        inc     si              ; Update pointer
        mov     [offset], si
        jmp     .intend         ; ... and jump to end of interrupt
        ;; If we get here, we're past the end of the sound.
.nosnd: mov     ax, [done]      ; Have we already marked it done?
        jnz     .intend         ; If so, nothing left to do
        mov     ax, 1           ; Otherwise, mark it done...
        mov     [done], ax
        mov     al, 0x36        ; ... and slow the timer back down
        out     0x43, al        ; to 18.2 Hz
        xor     al, al
        out     0x40, al
        out     0x40, al
.intend:
        mov     ax, [subtick]   ; Add microsecond count to the counter
        add     ax, counter
        mov     [subtick], ax
        jnc     .nobios         ; If carry, it's time for a BIOS call
        ;mov     bx, biostick    ; Point DS:BX at our saved address...
        ;pushf                   ; and PUSHF/CALL FAR to simulate an
        ;call    far [bx]     ; interrupt
        jmp     .fin
.nobios:
        mov     al, 0x20        ; If not, then acknowledge the IRQ
        out     0x20, al
.fin:
        pop     si              ; Restore stack and get out
        pop     bx
        pop     ax
        pop     ds
        ret;iret

        ;segment .data
done:   dw      0
offset: dw      0
subtick: dw     0
;data:   incbin "wow.raw"        ; Up to 64KB of 16 kHz 8-bit unsigned LPCM
; dataend:
; datasize equ dataend - data

times 510-($-$$) db 0
dw 0xaa55

data: incbin "music.bin" ; 16 kHz 8-bit unsigned LPCM
dataend:
datasize equ dataend - data
times 512 * 63 - ($-$$) db 0

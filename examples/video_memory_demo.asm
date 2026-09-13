; =============================================================
; FILE:        examples/video_memory_demo.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     Small, self-contained demo of writing directly to
;              text-mode video memory at segment B800h, with NO
;              DOS/BIOS text calls at all. Independent of the
;              main project.
; =============================================================
org 100h

VIDEO_SEG equ 0B800h
ATTR      equ 0Eh          ; yellow text on black background

start:
    jmp MAIN

msg db 'DIRECT VIDEO MEMORY WRITE (B800h) - NO INT 21h/10h USED$'

MAIN:
    ; --- clear the screen directly in video memory ---
    mov ax, VIDEO_SEG
    mov es, ax
    mov di, 0
    mov cx, 80*25
    mov ax, (07h * 256) + ' '   ; attribute 07h, character space
CLEAR_LOOP:
    mov es:[di], ax
    add di, 2
    loop CLEAR_LOOP

    ; --- compute offset for row 5, column 10: row*160 + col*2 ---
    mov ax, 5
    mov bx, 160
    mul bx                      ; AX = 5*160 = 800
    mov di, ax
    mov ax, 10
    mov bx, 2
    mul bx                      ; AX = 10*2 = 20
    add di, ax                  ; DI = 820 = offset for (row 5, col 10)

    ; --- write the message directly, one cell (char+attribute) at a time ---
    lea si, msg
WRITE_LOOP:
    mov al, [si]
    cmp al, '$'
    je WRITE_DONE
    mov es:[di], al
    mov byte ptr es:[di+1], ATTR
    inc si
    add di, 2
    jmp WRITE_LOOP
WRITE_DONE:

    ; wait for a keypress before exiting (still via DOS - reading input
    ; is unrelated to the video-memory concept this file demonstrates)
    mov ah, 01h
    int 21h
    mov ah, 4Ch
    int 21h

end start

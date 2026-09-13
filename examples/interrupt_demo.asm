; =============================================================
; FILE:        examples/interrupt_demo.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     Small, self-contained demo of real DOS/BIOS
;              software interrupts: INT 21h (DOS) string/char
;              output and keyboard input, and INT 10h (BIOS)
;              teletype output. Independent of the main project.
; =============================================================
org 100h

start:
    jmp MAIN

msg1 db 'INT 21h, AH=09h  -> prints this whole string',13,10,'$'
msg2 db 'INT 21h, AH=02h  -> prints one character: $'
msg3 db 13,10,'INT 10h, AH=0Eh -> BIOS teletype prints:  $'
msg4 db 13,10,'INT 21h, AH=01h -> press any key to read it back: $'
msg5 db 13,10,13,10,'Every INT number indexes a 4-byte entry (offset:segment)',13,10
     db 'in the Interrupt Vector Table at physical address (N*4).',13,10
     db 'INT pushes FLAGS/CS/IP and jumps there; IRET reverses it.',13,10,'$'

MAIN:
    lea dx, msg1
    mov ah, 09h
    int 21h                    ; DOS service: print '$'-terminated string

    lea dx, msg2
    mov ah, 09h
    int 21h
    mov dl, '*'
    mov ah, 02h
    int 21h                    ; DOS service: print single character in DL

    lea dx, msg3
    mov ah, 09h
    int 21h
    mov al, '#'
    mov ah, 0Eh
    int 10h                    ; BIOS service: teletype output, no DOS involved

    lea dx, msg4
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h                    ; DOS service: read one key, echoed automatically

    lea dx, msg5
    mov ah, 09h
    int 21h

    mov ah, 4Ch
    int 21h

end start

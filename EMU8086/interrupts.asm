; =============================================================
; FILE:        EMU8086/interrupts.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     (A) A REAL software-interrupt demo using genuine
;                  DOS/BIOS services (INT 21h, INT 10h) - nothing
;                  invented.
;              (B) A clearly-labeled EDUCATIONAL SIMULATION of a
;                  hardware interrupt / PIC sequence. This does
;                  NOT touch real hardware IRQ lines - EMU8086
;                  runs as a DOS-emulated program and does not
;                  give safe, guaranteed access to the physical
;                  8259 PIC. We simulate the IRQ->PIC->ISR->EOI
;                  flow on screen instead of pretending to hook it.
;              INCLUDEd by main.asm - no segment directives here.
; =============================================================

; -------------------------------------------------------------
; DemoSoftwareInterrupts
; Purpose : Show three real DOS/BIOS interrupt services in action.
;   INT 21h, AH=09h  -> display a '$'-terminated string
;   INT 21h, AH=02h  -> display a single character in DL
;   INT 21h, AH=01h  -> read one keystroke with echo
;   INT 10h, AH=0Eh  -> BIOS teletype output (writes a char AND
;                        advances the cursor, without going
;                        through DOS at all)
; -------------------------------------------------------------
msgSoftHead db 13,10,'--- SOFTWARE INTERRUPT DEMO ---',13,10,'$'
msgSoft1    db 'INT 21h / AH=09h  (DOS: print string)      -> $'
msgSoft1b   db 'this line$'
msgSoft2    db 13,10,'INT 21h / AH=02h  (DOS: print char)        -> $'
msgSoft3    db 13,10,'INT 10h / AH=0Eh  (BIOS: teletype char)    -> $'
msgSoft4    db 13,10,'INT 21h / AH=01h  (DOS: read key, echoed)  -> press any key: $'
msgSoftDone db 13,10,'Interrupt Vector Table (IVT) note:',13,10
            db 'Each interrupt number indexes a 4-byte entry at',13,10
            db 'physical address (number*4) in segment 0000h,',13,10
            db 'holding the handler''s CS:IP. INT pushes FLAGS,',13,10
            db 'CS, IP, then jumps there; IRET reverses that.',13,10,'$'

DemoSoftwareInterrupts proc
    lea dx, msgSoftHead
    mov ah, 09h
    int 21h

    lea dx, msgSoft1
    mov ah, 09h
    int 21h
    lea dx, msgSoft1b
    mov ah, 09h
    int 21h

    lea dx, msgSoft2
    mov ah, 09h
    int 21h
    mov dl, '*'
    mov ah, 02h
    int 21h

    lea dx, msgSoft3
    mov ah, 09h
    int 21h
    mov al, '#'
    mov ah, 0Eh
    int 10h

    lea dx, msgSoft4
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h

    lea dx, msgSoftDone
    mov ah, 09h
    int 21h
    ret
DemoSoftwareInterrupts endp

; -------------------------------------------------------------
; SimulatedHardwareInterrupt
; Purpose : EDUCATIONAL SIMULATION ONLY of an IRQ arriving,
;           the PIC prioritizing/acknowledging it, the CPU
;           vectoring to an ISR, and End-Of-Interrupt (EOI)
;           being sent back to the PIC. Nothing here touches
;           real hardware - it is text output describing the
;           sequence a real IRQ0 (timer) or IRQ1 (keyboard)
;           would follow on real hardware.
; -------------------------------------------------------------
msgHWHead db 13,10,'===============================================',13,10
          db '     SIMULATED HARDWARE INTERRUPT (PIC) DEMO',13,10
          db '  (educational simulation - no real IRQ access)',13,10
          db '===============================================',13,10,'$'
msgHW1 db 13,10,'[1] Device raises IRQ1 (keyboard) line to the PIC',13,10,'$'
msgHW2 db '[2] 8259 PIC checks mask/priority, forwards to CPU',13,10,'$'
msgHW3 db '[3] CPU finishes current instruction, saves FLAGS/CS/IP',13,10,'$'
msgHW4 db '[4] CPU vectors to the IRQ1 handler via the IVT entry',13,10,'$'
msgHW5 db '[5] ISR services the device, then sends EOI (20h) to PIC port 20h',13,10,'$'
msgHW6 db '[6] IRET restores FLAGS/CS/IP - interrupted code resumes',13,10,'$'

SimulatedHardwareInterrupt proc
    lea dx, msgHWHead
    mov ah, 09h
    int 21h
    lea dx, msgHW1
    mov ah, 09h
    int 21h
    lea dx, msgHW2
    mov ah, 09h
    int 21h
    lea dx, msgHW3
    mov ah, 09h
    int 21h
    lea dx, msgHW4
    mov ah, 09h
    int 21h
    lea dx, msgHW5
    mov ah, 09h
    int 21h
    lea dx, msgHW6
    mov ah, 09h
    int 21h
    ret
SimulatedHardwareInterrupt endp

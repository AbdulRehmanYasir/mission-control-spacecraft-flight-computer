; =============================================================
; FILE:        EMU8086/exception_demo.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     A REAL divide-by-zero exception demo. This hooks
;              the actual IVT entry for INT 0 (divide error) with
;              our own handler, then deliberately executes DIV
;              with a zero divisor to trigger it for real -
;              nothing here is faked text.
;
; WHY THE HANDLER DOES NOT SIMPLY "IRET":
;   On the 8086, the return address pushed for a divide-error
;   interrupt points at the DIV instruction itself (there is no
;   way to "skip past" it automatically). If our handler just
;   executed IRET, control would return straight to the same
;   DIV and fault again immediately - an infinite loop. The
;   correct, honest technique (used in real DOS-era recovery
;   code) is for the handler to discard the interrupt's saved
;   FLAGS/CS/IP from the stack itself and JMP to a safe recovery
;   label instead of executing IRET.
;
; INCLUDEd by main.asm - no segment directives here.
; =============================================================

oldInt0Off2 dw 0
oldInt0Seg dw 0

msgExcSetup     db 13,10,'Installing custom INT 0 (divide-error) handler into the IVT...',13,10,'$'
msgExcHeader    db 13,10,'===============================================',13,10
                db '                SYSTEM EXCEPTION',13,10
                db '===============================================',13,10,13,10
                db 'EXCEPTION : DIVIDE BY ZERO',13,10,13,10
                db 'CPU detected invalid arithmetic (INT 0 fired).',13,10
                db 'Interrupt Service Routine activated.',13,10
                db 'Saving registers...',13,10
                db 'Executing recovery protocol...',13,10
                db 'Restoring registers...',13,10,'$'
msgExcRecovered db 13,10,'SYSTEM STATUS: RECOVERED',13,10
                db '===============================================',13,10
                db 'Original INT 0 vector restored.',13,10,'$'

; -------------------------------------------------------------
; DivideByZeroDemo
; Purpose : Save the real INT 0 vector, install our handler,
;           deliberately fault, recover, then restore the
;           original vector so DOS/EMU8086 behaves normally
;           afterwards.
; -------------------------------------------------------------
DivideByZeroDemo proc
    push ax
    push bx
    push cx
    push dx
    push es

    ; --- save the current INT 0 vector (lives at physical 0000h) ---
    mov ax, 0
    mov es, ax
    mov bx, es:[0]            ; offset half of the vector (INT 0 = entry 0)
    mov oldInt0Off2, bx
    mov bx, es:[2]            ; segment half of the vector
    mov oldInt0Seg, bx

    ; --- install our own handler ---
    cli
    mov ax, 0
    mov es, ax
    mov word ptr es:[0], offset MyDivideHandler
    mov word ptr es:[2], cs
    sti

    lea dx, msgExcSetup
    mov ah, 09h
    int 21h

    mov ax, 10
    mov cx, 0
    div cx                    ; deliberately triggers INT 0 for real

RECOVER_POINT:
    lea dx, msgExcRecovered
    mov ah, 09h
    int 21h

    ; --- restore the original vector so the rest of the program
    ;     (and DOS/EMU8086 itself) keeps working normally ---
    cli
    mov ax, 0
    mov es, ax
    mov bx, oldInt0Off2
    mov word ptr es:[0], bx
    mov bx, oldInt0Seg
    mov word ptr es:[2], bx
    sti

    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DivideByZeroDemo endp

; -------------------------------------------------------------
; MyDivideHandler
; Purpose : Our custom ISR for INT 0. Prints the exception
;           banner, then discards the interrupt's saved
;           FLAGS/CS/IP and jumps to RECOVER_POINT instead of
;           IRETing back into the faulting DIV instruction.
; -------------------------------------------------------------
MyDivideHandler proc
    push ax
    push dx

    lea dx, msgExcHeader
    mov ah, 09h
    int 21h

    pop dx
    pop ax

    add sp, 6                  ; discard IP(2) + CS(2) + FLAGS(2) that
                                ; INT pushed - we are NOT going to IRET
    jmp RECOVER_POINT
MyDivideHandler endp

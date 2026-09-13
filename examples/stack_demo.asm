; =============================================================
; FILE:        examples/stack_demo.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     Small, self-contained demo of PUSH/POP/CALL/RET
;              and a parameter passed to a procedure via the
;              stack. Independent of the main project.
; =============================================================
org 100h

start:
    jmp MAIN

msgBefore db 'Before CALL: AX = 0005h (about to be doubled)',13,10,'$'
msgAfter  db 'After  CALL: AX = $'
msgStack  db 13,10,13,10,'Stack demo: pushed 0007h as a parameter,',13,10
          db 'DoubleValue popped it, doubled it, pushed the',13,10
          db 'result back, caller popped the result.',13,10,'$'
hexDigits db '0123456789ABCDEF'

MAIN:
    lea dx, msgBefore
    mov ah, 09h
    int 21h

    mov ax, 0005h
    call DoubleValueSimple    ; simple version: value stays in AX

    lea dx, msgAfter
    mov ah, 09h
    int 21h
    mov bx, ax
    call PrintHexBX

    ; --- now the explicit stack-parameter-passing version ---
    mov ax, 0007h
    push ax                   ; push the parameter for DoubleValueStack
    call DoubleValueStack
    pop bx                    ; DoubleValueStack pushed its result; retrieve it

    lea dx, msgStack
    mov ah, 09h
    int 21h
    call PrintHexBX

    mov ah, 4Ch
    int 21h

; -------------------------------------------------------------
; DoubleValueSimple
; Purpose : Simplest CALL/RET example - value passed and
;           returned through AX (register convention).
; -------------------------------------------------------------
DoubleValueSimple proc
    add ax, ax                ; AX = AX * 2
    ret
DoubleValueSimple endp

; -------------------------------------------------------------
; DoubleValueStack
; Purpose : Demonstrates a parameter passed on the STACK rather
;           than in a register. On entry, the caller has already
;           pushed one word parameter, then executed CALL (which
;           itself pushes the return address). So on entry:
;               [BP+0] = old BP (after we push it below)
;               [BP+2] = return address (pushed by CALL)
;               [BP+4] = the caller's parameter
;           We set up BP as a stack frame pointer to reach it.
; -------------------------------------------------------------
DoubleValueStack proc
    push bp
    mov bp, sp
    push ax                    ; save AX (we're about to use it)

    mov ax, [bp+4]             ; fetch the caller's pushed parameter
    add ax, ax                 ; double it

    ; Overwrite the parameter slot on the stack with the result,
    ; so that after we return, the caller's "pop bx" retrieves it.
    mov [bp+4], ax

    pop ax                     ; restore AX
    pop bp
    ret
DoubleValueStack endp

; -------------------------------------------------------------
; PrintHexBX: print BX as 4 hex digits
; -------------------------------------------------------------
PrintHexBX proc
    push ax
    push bx
    push cx
    push dx
    push si
    mov cx, 4
PH_LOOP:
    rol bx, 1
    rol bx, 1
    rol bx, 1
    rol bx, 1
    mov ax, bx
    and al, 0Fh
    mov ah, 0
    mov si, ax
    mov dl, hexDigits[si]
    mov ah, 02h
    int 21h
    dec cx
    jnz PH_LOOP
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintHexBX endp

end start

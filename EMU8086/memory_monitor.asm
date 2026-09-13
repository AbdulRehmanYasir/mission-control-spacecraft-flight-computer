; =============================================================
; FILE:        EMU8086/memory_monitor.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     Segmented memory demonstration - shows the real
;              DS/SS/ES/SP/BP register values captured by
;              RegisterSnapshot, then computes a real physical
;              address using the 8086 formula:
;                  Physical Address = Segment * 16 + Offset
;              INCLUDEd by main.asm - no segment directives here.
; -------------------------------------------------------------
; ShowMemoryMonitor
; In      : snapDS/snapSS/snapES/snapSP/snapBP (filled earlier
;           by RegisterSnapshot - call that first)
; Out     : text showing the physical-address calculation for
;           DS:0010h as a worked example
; Modifies: none visible to caller
;
; NOTE ON PRECISION: segment*16 can exceed 16 bits (a full
; physical address needs 20 bits), so we compute it as a real
; 32-bit product using MUL (DX:AX), then add the offset with
; carry propagation - the DX:AX pair is printed as two hex
; words, which together hold the true physical address.
; -------------------------------------------------------------
msgMemHead  db 13,10,'===============================================',13,10
            db '                MEMORY MONITOR',13,10
            db '===============================================',13,10,13,10,'$'
lblDSr  db 'DS : $'
lblSSr  db 'SS : $'
lblESr  db 'ES : $'
lblSPr  db 'SP : $'
lblBPr  db 'BP : $'
msgCalcHead db 13,10,'Worked example - physical address of DS:0010h',13,10,'$'
msgFormula  db 'Formula: Physical = Segment * 16 + Offset',13,10,'$'
lblSeg      db 'Segment  (DS)   = $'
lblOff      db 'Offset          = 0010$'
lblPhysHi   db 13,10,'Physical (hi word:lo word) = $'
physSep     db ':$'
DEMO_OFFSET equ 0010h
physHi      dw 0
physLo      dw 0

ShowMemoryMonitor proc
    push ax
    push bx
    push cx
    push dx

    lea dx, msgMemHead
    mov ah, 09h
    int 21h

    lea dx, lblDSr
    mov ah, 09h
    int 21h
    mov ax, snapDS
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblSSr
    mov ah, 09h
    int 21h
    mov ax, snapSS
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblESr
    mov ah, 09h
    int 21h
    mov ax, snapES
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblSPr
    mov ah, 09h
    int 21h
    mov ax, snapSP
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblBPr
    mov ah, 09h
    int 21h
    mov ax, snapBP
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, msgCalcHead
    mov ah, 09h
    int 21h
    lea dx, msgFormula
    mov ah, 09h
    int 21h

    lea dx, lblSeg
    mov ah, 09h
    int 21h
    mov ax, snapDS
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblOff
    mov ah, 09h
    int 21h

    ; --- the actual physical-address computation ---
    mov ax, snapDS
    mov cx, 16
    mul cx                      ; DX:AX = DS * 16  (32-bit product)
    add ax, DEMO_OFFSET         ; add the offset into the low word
    adc dx, 0                   ; propagate carry into the high word
    mov physHi, dx
    mov physLo, ax

    lea dx, lblPhysHi
    mov ah, 09h
    int 21h
    mov ax, physHi
    call PrintHexWord
    lea dx, physSep
    mov ah, 09h
    int 21h
    mov ax, physLo
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
ShowMemoryMonitor endp

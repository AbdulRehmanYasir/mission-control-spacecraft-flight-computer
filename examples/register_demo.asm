; =============================================================
; FILE:        examples/register_demo.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     Small, self-contained demo of general-purpose
;              registers + one representative ALU operation +
;              the flags it sets. Independent of the main
;              project - open this file directly in EMU8086 to
;              show just this concept in a viva.
; =============================================================
org 100h

start:
    jmp MAIN

msgAX    db 'AX (1234h + 0010h) = $'
msgBX    db 13,10,'BX = $'
msgCX    db 13,10,'CX = $'
msgDX    db 13,10,'DX = $'
msgSI    db 13,10,'SI = $'
msgDI    db 13,10,'DI = $'
msgFlags db 13,10,13,10,'FLAGS (from the ADD above):',13,10,'$'
lblCF    db 'CF = $'
lblZF    db 13,10,'ZF = $'
lblSF    db 13,10,'SF = $'
lblOF    db 13,10,'OF = $'
hexDigits db '0123456789ABCDEF'
savedFlags dw 0

MAIN:
    mov ax, 1234h
    mov bx, 0010h
    add ax, bx              ; representative ALU op - AX = 1244h
    pushf
    pop word ptr savedFlags  ; capture the flags this ADD produced

    mov cx, 000Ah
    mov dx, 0042h
    mov si, 1200h
    mov di, 1300h

    lea dx, msgAX
    mov ah, 09h
    int 21h
    mov bx, ax
    call PrintHexBX

    lea dx, msgBX
    mov ah, 09h
    int 21h
    mov bx, 0010h
    call PrintHexBX

    lea dx, msgCX
    mov ah, 09h
    int 21h
    mov bx, cx
    call PrintHexBX

    lea dx, msgDX
    mov ah, 09h
    int 21h
    mov bx, dx
    call PrintHexBX

    lea dx, msgSI
    mov ah, 09h
    int 21h
    mov bx, si
    call PrintHexBX

    lea dx, msgDI
    mov ah, 09h
    int 21h
    mov bx, di
    call PrintHexBX

    lea dx, msgFlags
    mov ah, 09h
    int 21h

    mov ax, savedFlags

    lea dx, lblCF
    mov ah, 09h
    int 21h
    mov bl, al
    and bl, 1
    add bl, '0'
    mov dl, bl
    mov ah, 02h
    int 21h

    lea dx, lblZF
    mov ah, 09h
    int 21h
    mov bl, al
    shr bl, 6
    and bl, 1
    add bl, '0'
    mov dl, bl
    mov ah, 02h
    int 21h

    lea dx, lblSF
    mov ah, 09h
    int 21h
    mov bl, al
    shr bl, 7
    and bl, 1
    add bl, '0'
    mov dl, bl
    mov ah, 02h
    int 21h

    lea dx, lblOF
    mov ah, 09h
    int 21h
    mov bl, ah
    shr bl, 3
    and bl, 1
    add bl, '0'
    mov dl, bl
    mov ah, 02h
    int 21h

    mov ah, 4Ch
    int 21h

; -------------------------------------------------------------
; PrintHexBX: print BX as 4 hex digits, most-significant first
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

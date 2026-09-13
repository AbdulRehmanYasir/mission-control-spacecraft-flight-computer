; =============================================================
; FILE:        EMU8086/input.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     ASCII <-> integer conversion. This is the file
;              that satisfies the "Number Systems / ASCII" and
;              "ASCII input" syllabus topics.
;              INCLUDEd by main.asm - no segment directives here.
; =============================================================

; -------------------------------------------------------------
; ReadNumber
; Purpose : Read a multi-digit decimal number typed by the user,
;           terminated by Enter (CR), and convert it to a binary
;           integer using the classic "value = value*10 + digit"
;           algorithm. Each keystroke is echoed as it's typed.
; In      : keyboard (INT 21h, AH=01h)
; Out     : AX = the number entered
; Modifies: BX, DX (restored via push/pop); AX is the result
; Example : user types '3' '8' '2' <Enter>
;           pass 1: value = 0*10 + 3 = 3
;           pass 2: value = 3*10 + 8 = 38
;           pass 3: value = 38*10 + 2 = 382
; -------------------------------------------------------------
ReadNumber proc
    push bx
    push dx
    mov bx, 0                 ; BX = accumulator (the number so far)

READ_DIGIT_LOOP:
    mov ah, 01h
    int 21h                    ; AL = ASCII character typed
    cmp al, 13                 ; 13 = Carriage Return (Enter)
    je READ_DONE
    cmp al, '0'
    jb READ_DIGIT_LOOP         ; ignore anything below '0'
    cmp al, '9'
    ja READ_DIGIT_LOOP         ; ignore anything above '9'

    sub al, '0'                 ; ASCII digit -> numeric value 0-9
    mov ah, 0
    push ax                     ; save the digit value

    mov ax, bx
    mov dx, 10
    mul dx                      ; DX:AX = accumulator * 10
    mov bx, ax                  ; keep the low word (values stay small)

    pop ax                      ; restore digit value
    add bx, ax                  ; accumulator += digit
    jmp READ_DIGIT_LOOP

READ_DONE:
    mov ax, bx
    pop dx
    pop bx
    ret
ReadNumber endp

; -------------------------------------------------------------
; PrintNumber
; Purpose : Convert an unsigned 16-bit integer in AX to decimal
;           ASCII and print it. Uses the stack to reverse the
;           digit order (remainders come out least-significant
;           first from repeated division by 10).
; In      : AX = number to print (0-65535)
; Modifies: none visible to caller (all registers preserved)
; -------------------------------------------------------------
PrintNumber proc
    push ax
    push bx
    push cx
    push dx

    mov cx, 0                   ; CX = count of digits pushed
    mov bx, 10

    cmp ax, 0
    jne PN_SPLIT
    push ax                     ; special case: value is exactly 0
    inc cx
    jmp PN_PRINT

PN_SPLIT:
    xor dx, dx
PN_SPLIT_LOOP:
    cmp ax, 0
    je PN_PRINT
    xor dx, dx
    div bx                      ; AX = AX/10, DX = AX mod 10 (the digit)
    push dx                     ; save this digit for later (reverses order)
    inc cx
    jmp PN_SPLIT_LOOP

PN_PRINT:
    cmp cx, 0
    je PN_DONE
    pop dx
    add dl, '0'                  ; digit -> ASCII
    mov ah, 02h
    int 21h                      ; DOS: print one character in DL
    dec cx
    jmp PN_PRINT

PN_DONE:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintNumber endp

; -------------------------------------------------------------
; PrintHexWord
; Purpose : Print AX as a 4-digit hexadecimal number (used by the
;           register monitor to show raw register contents).
; In      : AX = value to print
; Modifies: none visible to caller
; -------------------------------------------------------------
hexDigits db '0123456789ABCDEF'

PrintHexWord proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov bx, ax                   ; BX = working copy we rotate
    mov cx, 4                    ; 4 hex nibbles in a word, MSB first

PH_LOOP:
    rol bx, 1
    rol bx, 1
    rol bx, 1
    rol bx, 1                    ; rotate 4 bits = one hex nibble into bits 0-3
    mov ax, bx
    and al, 0Fh                  ; isolate that nibble
    mov ah, 0
    mov si, ax
    mov dl, hexDigits[si]        ; hexDigits[nibble] = its ASCII character
    mov ah, 02h
    int 21h                      ; DOS: print one character in DL
    dec cx
    jnz PH_LOOP

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintHexWord endp

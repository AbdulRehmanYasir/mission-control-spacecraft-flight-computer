; =============================================================
; FILE:        EMU8086/sensors.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     Array processing over the sensor sample arrays
;              declared in main.asm's .data segment. Demonstrates
;              register-indirect / indexed addressing and a
;              min/max/average scan driven by CMP+Jcc (not LOOP,
;              since LOOP alone can't branch on a comparison —
;              LOOP is used purely for the counter in each pass).
;              INCLUDEd by main.asm - no segment directives here.
; -------------------------------------------------------------
; ScanTemperatureArray / ScanFuelArray / ScanOxygenArray
; In      : the corresponding sample array + SAMPLE_COUNT
; Out     : <name>Min, <name>Max, <name>Avg  (words)
; Modifies: AX, BX, CX, DX, SI - all saved/restored on the stack
; Registers preserved: everything (push on entry, pop on exit)
; -------------------------------------------------------------

ScanTemperatureArray proc
    push ax
    push bx
    push cx
    push dx
    push si

    lea si, tempSamples        ; SI = base address (indexed addressing base)
    mov ax, [si]                ; first element seeds min/max/sum
    mov bx, ax                  ; BX = running minimum
    mov dx, ax                  ; DX = running maximum
    mov tempSum, ax
    add si, 2                   ; advance index by one word (2 bytes)
    mov cx, SAMPLE_COUNT - 1     ; one element already consumed

TEMP_SCAN_LOOP:
    cmp cx, 0
    je TEMP_SCAN_DONE
    mov ax, [si]                 ; [SI] = register-indirect addressing
    add tempSum, ax
    cmp ax, bx
    jge TEMP_CHECK_MAX
    mov bx, ax                   ; new minimum found
TEMP_CHECK_MAX:
    cmp ax, dx
    jle TEMP_NEXT
    mov dx, ax                   ; new maximum found
TEMP_NEXT:
    add si, 2
    dec cx
    jmp TEMP_SCAN_LOOP

TEMP_SCAN_DONE:
    mov tempMin, bx
    mov tempMax, dx
    mov ax, tempSum
    xor dx, dx                   ; clear DX:AX high half before DIV
    mov cx, SAMPLE_COUNT
    div cx                       ; AX = tempSum / SAMPLE_COUNT
    mov tempAvg, ax

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ScanTemperatureArray endp

ScanFuelArray proc
    push ax
    push bx
    push cx
    push dx
    push si

    lea si, fuelSamples
    mov ax, [si]
    mov bx, ax
    mov dx, ax
    mov fuelSum, ax
    add si, 2
    mov cx, SAMPLE_COUNT - 1

FUEL_SCAN_LOOP:
    cmp cx, 0
    je FUEL_SCAN_DONE
    mov ax, [si]
    add fuelSum, ax
    cmp ax, bx
    jge FUEL_CHECK_MAX
    mov bx, ax
FUEL_CHECK_MAX:
    cmp ax, dx
    jle FUEL_NEXT
    mov dx, ax
FUEL_NEXT:
    add si, 2
    dec cx
    jmp FUEL_SCAN_LOOP

FUEL_SCAN_DONE:
    mov fuelMin, bx
    mov fuelMax, dx
    mov ax, fuelSum
    xor dx, dx
    mov cx, SAMPLE_COUNT
    div cx
    mov fuelAvg, ax

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ScanFuelArray endp

ScanOxygenArray proc
    push ax
    push bx
    push cx
    push dx
    push si

    lea si, oxygenSamples
    mov ax, [si]
    mov bx, ax
    mov dx, ax
    mov oxySum, ax
    add si, 2
    mov cx, SAMPLE_COUNT - 1

OXY_SCAN_LOOP:
    cmp cx, 0
    je OXY_SCAN_DONE
    mov ax, [si]
    add oxySum, ax
    cmp ax, bx
    jge OXY_CHECK_MAX
    mov bx, ax
OXY_CHECK_MAX:
    cmp ax, dx
    jle OXY_NEXT
    mov dx, ax
OXY_NEXT:
    add si, 2
    dec cx
    jmp OXY_SCAN_LOOP

OXY_SCAN_DONE:
    mov oxyMin, bx
    mov oxyMax, dx
    mov ax, oxySum
    xor dx, dx
    mov cx, SAMPLE_COUNT
    div cx
    mov oxyAvg, ax

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ScanOxygenArray endp

; -------------------------------------------------------------
; PrintSensorReport
; Purpose : Show min/max/avg for all three scanned arrays.
; -------------------------------------------------------------
msgSensorHead db 13,10,'--- SENSOR DATA (8-sample history) ---',13,10,'$'
lblTempMMA db 'TEMP   min/max/avg : $'
lblFuelMMA db 'FUEL   min/max/avg : $'
lblOxyMMA  db 'OXYGEN min/max/avg : $'
sep        db ' / $'

PrintSensorReport proc
    lea dx, msgSensorHead
    mov ah, 09h
    int 21h

    lea dx, lblTempMMA
    mov ah, 09h
    int 21h
    mov ax, tempMin
    call PrintNumber
    lea dx, sep
    mov ah, 09h
    int 21h
    mov ax, tempMax
    call PrintNumber
    lea dx, sep
    mov ah, 09h
    int 21h
    mov ax, tempAvg
    call PrintNumber
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblFuelMMA
    mov ah, 09h
    int 21h
    mov ax, fuelMin
    call PrintNumber
    lea dx, sep
    mov ah, 09h
    int 21h
    mov ax, fuelMax
    call PrintNumber
    lea dx, sep
    mov ah, 09h
    int 21h
    mov ax, fuelAvg
    call PrintNumber
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblOxyMMA
    mov ah, 09h
    int 21h
    mov ax, oxyMin
    call PrintNumber
    lea dx, sep
    mov ah, 09h
    int 21h
    mov ax, oxyMax
    call PrintNumber
    lea dx, sep
    mov ah, 09h
    int 21h
    mov ax, oxyAvg
    call PrintNumber
    lea dx, msgNewline
    mov ah, 09h
    int 21h
    ret
PrintSensorReport endp

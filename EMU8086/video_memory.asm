; =============================================================
; FILE:        EMU8086/video_memory.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     Direct text-mode video memory access at segment
;              B800h - no DOS/BIOS text output is used anywhere
;              in this file. This satisfies the "video memory"
;              syllabus topic for real (not through INT 21h/10h).
;
; Video memory layout (color text mode 80x25):
;   Each screen cell is 2 bytes at offset = row*160 + col*2
;     byte 0 (even offset) = ASCII character
;     byte 1 (odd  offset) = attribute (bg<<4 | fg)
;   160 = 80 columns * 2 bytes per column.
;
; INCLUDEd by main.asm - no segment directives here.
; =============================================================

VIDEO_SEG equ 0B800h
SCREEN_ATTR equ 0Ah          ; light green text (0Ah) on black background

; -------------------------------------------------------------
; ClearScreen
; Purpose : Fill all 80x25 cells with spaces using SCREEN_ATTR.
; Modifies: none visible to caller
; -------------------------------------------------------------
ClearScreen proc
    push ax
    push cx
    push di
    push es

    mov ax, VIDEO_SEG
    mov es, ax
    mov di, 0
    mov cx, 80*25
    mov ax, (SCREEN_ATTR * 256) + ' '   ; AH=attribute, AL=' '

CLR_LOOP:
    mov es:[di], ax
    add di, 2
    loop CLR_LOOP

    pop es
    pop di
    pop cx
    pop ax
    ret
ClearScreen endp

; -------------------------------------------------------------
; PrintAt
; Purpose : Write ONE character+attribute cell directly to video
;           memory.
; In      : DH = row (0-24), DL = col (0-79)
;           CL = ASCII character, CH = attribute
; Modifies: none visible to caller
; -------------------------------------------------------------
PrintAt proc
    push ax
    push bx
    push dx
    push di
    push es

    mov al, dh
    mov ah, 0
    mov bx, 160
    mul bx                    ; AX = row * 160
    mov di, ax

    mov al, dl
    mov ah, 0
    mov bx, 2
    mul bx                    ; AX = col * 2
    add di, ax                ; DI = row*160 + col*2

    mov ax, VIDEO_SEG
    mov es, ax
    mov es:[di], cl           ; character byte
    mov es:[di+1], ch         ; attribute byte

    pop es
    pop di
    pop dx
    pop bx
    pop ax
    ret
PrintAt endp

; -------------------------------------------------------------
; PrintStrAt
; Purpose : Write a '$'-terminated string directly to video
;           memory, one cell per character, advancing column.
; In      : DH=row, DL=col, SI=offset of the '$'-terminated
;           string, BL=attribute
; Modifies: none visible to caller
; -------------------------------------------------------------
PrintStrAt proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov al, dh
    mov ah, 0
    mov cx, 160
    mul cx
    mov di, ax
    mov al, dl
    mov ah, 0
    mov cx, 2
    mul cx
    add di, ax                ; DI = starting offset

    mov ax, VIDEO_SEG
    mov es, ax

PSA_LOOP:
    mov al, [si]
    cmp al, '$'
    je PSA_DONE
    mov es:[di], al
    mov es:[di+1], bl
    inc si
    add di, 2
    jmp PSA_LOOP

PSA_DONE:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintStrAt endp

; -------------------------------------------------------------
; PrintNumberAt
; Purpose : Write a decimal number directly to video memory at
;           a fixed position (reuses PrintNumber's digit-split
;           logic but writes to B800h instead of DOS output).
; In      : DH=row, DL=col, AX=number, BL=attribute
; Modifies: none visible to caller
; -------------------------------------------------------------
PrintNumberAt proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    ; --- split AX into decimal digits on the stack (reuse trick) ---
    push dx                   ; save row/col (DH/DL) before we clobber DX
    mov cx, 0
    mov bx, 10
    cmp ax, 0
    jne PNA_SPLIT
    push ax
    inc cx
    jmp PNA_WRITE_SETUP
PNA_SPLIT:
    xor dx, dx
PNA_SPLIT_LOOP:
    cmp ax, 0
    je PNA_WRITE_SETUP
    xor dx, dx
    div bx
    push dx
    inc cx
    jmp PNA_SPLIT_LOOP

PNA_WRITE_SETUP:
    pop dx                    ; restore row(DH)/col(DL)
    mov al, dh
    mov ah, 0
    mov si, 160
    mul si
    mov di, ax
    mov al, dl
    mov ah, 0
    mov si, 2
    mul si
    add di, ax                ; DI = starting screen offset

    mov ax, VIDEO_SEG
    mov es, ax

PNA_WRITE_LOOP:
    cmp cx, 0
    je PNA_DONE
    pop ax                    ; AX = next digit value 0-9 (low byte used)
    add al, '0'
    mov es:[di], al
    mov es:[di+1], bl
    add di, 2
    dec cx
    jmp PNA_WRITE_LOOP

PNA_DONE:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintNumberAt endp

; -------------------------------------------------------------
; DrawDashboardBorder
; Purpose : Draw a fixed-size single-line border (rows 1-12,
;           columns 2-77) directly into video memory using
;           CP437 box-drawing characters. Kept as a fixed
;           rectangle (rather than a fully generic parameterized
;           box) so the row/column arithmetic stays simple and
;           reliable: every edge is walked with a plain byte
;           loop counter (CL is free here since PrintAt takes
;           its char/attr through CX only during the call
;           itself - between calls we're free to reuse it).
; -------------------------------------------------------------
BOX_TOP    equ 1
BOX_LEFT   equ 2
BOX_BOTTOM equ 12
BOX_RIGHT  equ 77

DrawDashboardBorder proc
    push ax
    push bx
    push cx
    push dx

    ; --- four corners ---
    mov dh, BOX_TOP
    mov dl, BOX_LEFT
    mov cl, 218                ; top-left (CP437 0xDA)
    mov ch, SCREEN_ATTR
    call PrintAt

    mov dh, BOX_TOP
    mov dl, BOX_RIGHT
    mov cl, 191                ; top-right (0xBF)
    mov ch, SCREEN_ATTR
    call PrintAt

    mov dh, BOX_BOTTOM
    mov dl, BOX_LEFT
    mov cl, 192                ; bottom-left (0xC0)
    mov ch, SCREEN_ATTR
    call PrintAt

    mov dh, BOX_BOTTOM
    mov dl, BOX_RIGHT
    mov cl, 217                ; bottom-right (0xD9)
    mov ch, SCREEN_ATTR
    call PrintAt

    ; --- top and bottom horizontal edges ---
    mov bl, BOX_LEFT + 1        ; BL = current column being drawn
TOP_EDGE_LOOP:
    cmp bl, BOX_RIGHT
    jge TOP_EDGE_DONE
    mov dh, BOX_TOP
    mov dl, bl
    mov cl, 196                 ; horizontal line (0xC4)
    mov ch, SCREEN_ATTR
    call PrintAt
    inc bl
    jmp TOP_EDGE_LOOP
TOP_EDGE_DONE:

    mov bl, BOX_LEFT + 1
BOT_EDGE_LOOP:
    cmp bl, BOX_RIGHT
    jge BOT_EDGE_DONE
    mov dh, BOX_BOTTOM
    mov dl, bl
    mov cl, 196
    mov ch, SCREEN_ATTR
    call PrintAt
    inc bl
    jmp BOT_EDGE_LOOP
BOT_EDGE_DONE:

    ; --- left and right vertical edges ---
    mov bh, BOX_TOP + 1          ; BH = current row being drawn
LEFT_EDGE_LOOP:
    cmp bh, BOX_BOTTOM
    jge LEFT_EDGE_DONE
    mov dh, bh
    mov dl, BOX_LEFT
    mov cl, 179                  ; vertical line (0xB3)
    mov ch, SCREEN_ATTR
    call PrintAt
    inc bh
    jmp LEFT_EDGE_LOOP
LEFT_EDGE_DONE:

    mov bh, BOX_TOP + 1
RIGHT_EDGE_LOOP:
    cmp bh, BOX_BOTTOM
    jge RIGHT_EDGE_DONE
    mov dh, bh
    mov dl, BOX_RIGHT
    mov cl, 179
    mov ch, SCREEN_ATTR
    call PrintAt
    inc bh
    jmp RIGHT_EDGE_LOOP
RIGHT_EDGE_DONE:

    pop dx
    pop cx
    pop bx
    pop ax
    ret
DrawDashboardBorder endp

; -------------------------------------------------------------
; DrawDashboard
; Purpose : Render the full Mission Control dashboard directly
;           into video memory (no DOS/BIOS text calls at all).
; -------------------------------------------------------------
dTitle    db 'MISSION CONTROL - LIVE TELEMETRY (B800h DIRECT)$'
dCpu      db 'CPU TEMP   :$'
dEng      db 'ENGINE TEMP:$'
dOxy      db 'OXYGEN     :$'
dFuel     db 'FUEL       :$'
dBatt     db 'BATTERY    :$'
dHint     db 'Press any key to return to the text menu...$'

DrawDashboard proc
    call ClearScreen
    call DrawDashboardBorder

    mov dh, 2
    mov dl, 4
    mov si, offset dTitle
    mov bl, SCREEN_ATTR
    call PrintStrAt

    mov dh, 4
    mov dl, 4
    mov si, offset dCpu
    mov bl, SCREEN_ATTR
    call PrintStrAt
    mov dh, 4
    mov dl, 18
    mov ax, cpuTemp
    mov bl, SCREEN_ATTR
    call PrintNumberAt

    mov dh, 5
    mov dl, 4
    mov si, offset dEng
    mov bl, SCREEN_ATTR
    call PrintStrAt
    mov dh, 5
    mov dl, 18
    mov ax, engineTemp
    mov bl, SCREEN_ATTR
    call PrintNumberAt

    mov dh, 6
    mov dl, 4
    mov si, offset dOxy
    mov bl, SCREEN_ATTR
    call PrintStrAt
    mov dh, 6
    mov dl, 18
    mov ax, oxygenLevel
    mov bl, SCREEN_ATTR
    call PrintNumberAt

    mov dh, 7
    mov dl, 4
    mov si, offset dFuel
    mov bl, SCREEN_ATTR
    call PrintStrAt
    mov dh, 7
    mov dl, 18
    mov ax, fuelLevel
    mov bl, SCREEN_ATTR
    call PrintNumberAt

    mov dh, 8
    mov dl, 4
    mov si, offset dBatt
    mov bl, SCREEN_ATTR
    call PrintStrAt
    mov dh, 8
    mov dl, 18
    mov ax, batteryLevel
    mov bl, SCREEN_ATTR
    call PrintNumberAt

    mov dh, 11
    mov dl, 4
    mov si, offset dHint
    mov bl, SCREEN_ATTR
    call PrintStrAt
    ret
DrawDashboard endp

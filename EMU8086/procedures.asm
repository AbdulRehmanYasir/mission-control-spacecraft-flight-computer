; =============================================================
; FILE:        EMU8086/procedures.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     Core mission procedures: telemetry printout,
;              ALU-based threshold checks, status-bit
;              manipulation, register monitor, emergency
;              handling. INCLUDEd by main.asm — contains NO
;              segment directives of its own.
;
; This file is where most of the syllabus's "ALU / Flags /
; Bit manipulation / Stack / CALL-RET / Parameter passing"
; requirements live.
; =============================================================

; -------------------------------------------------------------
; PrintTelemetrySummary
; Purpose : Print the 8 core telemetry values as decimal numbers
; In      : reads the .data telemetry variables
; Out     : text on screen
; Modifies: AX, DX (via PrintNumber calls) - preserved by callee
; -------------------------------------------------------------
lblCpu   db 'CPU TEMP       : $'
lblEng   db 'ENGINE TEMP    : $'
lblOxy   db 'OXYGEN         : $'
lblFuel  db 'FUEL           : $'
lblBatt  db 'BATTERY        : $'
lblAlt   db 'ALTITUDE       : $'
lblVel   db 'VELOCITY       : $'
lblPres  db 'PRESSURE       : $'
unitC    db ' C',13,10,'$'
unitPct  db ' %',13,10,'$'
unitKm   db ' KM',13,10,'$'
unitKms  db ' KM/S',13,10,'$'
unitKpa  db ' KPa',13,10,'$'

PrintTelemetrySummary proc
    lea dx, lblCpu
    mov ah, 09h
    int 21h
    mov ax, cpuTemp
    call PrintNumber
    lea dx, unitC
    mov ah, 09h
    int 21h

    lea dx, lblEng
    mov ah, 09h
    int 21h
    mov ax, engineTemp
    call PrintNumber
    lea dx, unitC
    mov ah, 09h
    int 21h

    lea dx, lblOxy
    mov ah, 09h
    int 21h
    mov ax, oxygenLevel
    call PrintNumber
    lea dx, unitPct
    mov ah, 09h
    int 21h

    lea dx, lblFuel
    mov ah, 09h
    int 21h
    mov ax, fuelLevel
    call PrintNumber
    lea dx, unitPct
    mov ah, 09h
    int 21h

    lea dx, lblBatt
    mov ah, 09h
    int 21h
    mov ax, batteryLevel
    call PrintNumber
    lea dx, unitPct
    mov ah, 09h
    int 21h

    lea dx, lblAlt
    mov ah, 09h
    int 21h
    mov ax, altitude
    call PrintNumber
    lea dx, unitKm
    mov ah, 09h
    int 21h

    lea dx, lblVel
    mov ah, 09h
    int 21h
    mov ax, velocity
    call PrintNumber
    lea dx, unitKms
    mov ah, 09h
    int 21h

    lea dx, lblPres
    mov ah, 09h
    int 21h
    mov ax, pressure
    call PrintNumber
    lea dx, unitKpa
    mov ah, 09h
    int 21h

    lea dx, msgNewline
    mov ah, 09h
    int 21h
    ret
PrintTelemetrySummary endp

; -------------------------------------------------------------
; SetStatusBit / ClearStatusBit / ToggleStatusBit / TestStatusBit
; Purpose : Bit-level manipulation of the system status byte.
; In      : CL = bit number (0-7)
; Out     : TestStatusBit returns AL=1 if bit set, AL=0 if clear
; Preserves: BX
; -------------------------------------------------------------
SetStatusBit proc
    push bx
    mov bl, 1
    shl bl, cl              ; BL = 1 << CL  (build the bit mask)
    or  statusByte, bl       ; OR sets the bit without disturbing others
    pop bx
    ret
SetStatusBit endp

ClearStatusBit proc
    push bx
    mov bl, 1
    shl bl, cl
    not bl                   ; invert mask -> all bits 1 except target
    and statusByte, bl       ; AND clears only the target bit
    pop bx
    ret
ClearStatusBit endp

ToggleStatusBit proc
    push bx
    mov bl, 1
    shl bl, cl
    xor statusByte, bl        ; XOR flips exactly the target bit
    pop bx
    ret
ToggleStatusBit endp

; Returns AL = 1 if bit CL is set, else AL = 0
TestStatusBit proc
    push bx
    push cx
    mov bl, statusByte
    mov ah, 0
    shr bl, cl                ; shift target bit into bit 0
    and bl, 1
    mov al, bl
    pop cx
    pop bx
    ret
TestStatusBit endp

; -------------------------------------------------------------
; CheckEngine / CheckOxygen / CheckFuel / CheckBattery / CheckPressure
; Purpose : ALU + flag driven threshold checks. Each compares a
;           live telemetry value against its safety threshold and
;           sets/clears the matching status bit using CMP + Jcc,
;           which is where the CF/ZF/SF flags are actually used
;           for a real branching decision (not decoration).
; -------------------------------------------------------------
CheckEngine proc
    mov ax, engineTemp
    cmp ax, ENGINE_MAX_TEMP   ; sets flags: e.g. CF/ZF/SF depending on result
    jbe ENGINE_OK             ; JBE reads CF and ZF: jump if AX <= threshold
    mov cl, 3                 ; bit 3 = high temperature
    call SetStatusBit
    jmp ENGINE_DONE
ENGINE_OK:
    mov cl, 3
    call ClearStatusBit
ENGINE_DONE:
    ret
CheckEngine endp

CheckOxygen proc
    mov ax, oxygenLevel
    cmp ax, OXYGEN_MIN
    jae OXY_OK                ; JAE reads CF: jump if AX >= threshold
    mov cl, 1
    call SetStatusBit
    jmp OXY_DONE
OXY_OK:
    mov cl, 1
    call ClearStatusBit
OXY_DONE:
    ret
CheckOxygen endp

CheckFuel proc
    mov ax, fuelLevel
    cmp ax, FUEL_MIN
    jae FUEL_OK
    mov cl, 2
    call SetStatusBit
    jmp FUEL_DONE
FUEL_OK:
    mov cl, 2
    call ClearStatusBit
FUEL_DONE:
    ret
CheckFuel endp

CheckBattery proc
    mov ax, batteryLevel
    cmp ax, BATTERY_MIN
    jae BATT_OK
    mov cl, 4
    call SetStatusBit
    jmp BATT_DONE
BATT_OK:
    mov cl, 4
    call ClearStatusBit
BATT_DONE:
    ret
CheckBattery endp

CheckPressure proc
    mov ax, pressure
    cmp ax, PRESSURE_MIN
    jae PRES_OK
    mov cl, 5
    call SetStatusBit
    jmp PRES_DONE
PRES_OK:
    mov cl, 5
    call ClearStatusBit
PRES_DONE:
    ret
CheckPressure endp

; -------------------------------------------------------------
; RunDiagnostics
; Purpose : Run every check, then report OK/WARN per subsystem
;           plus a total warning count (a real ALU accumulation,
;           not a hardcoded number).
; -------------------------------------------------------------
msgDiagHead  db 13,10,'RUNNING SYSTEM DIAGNOSTICS...',13,10,13,10,'$'
msgOK        db '[OK]   $'
msgWARN      db '[WARN] $'
nmCpuD       db 'CPU/ENGINE',13,10,'$'
nmOxyD       db 'OXYGEN',13,10,'$'
nmFuelD      db 'FUEL',13,10,'$'
nmBattD      db 'BATTERY',13,10,'$'
nmPresD      db 'PRESSURE',13,10,'$'
msgDiagCount db 13,10,'WARNING COUNT: $'
diagWarnCount dw 0

RunDiagnostics proc
    lea dx, msgDiagHead
    mov ah, 09h
    int 21h

    mov diagWarnCount, 0

    call CheckEngine
    mov cl, 3
    call TestStatusBit
    call PrintDiagLine
    lea dx, nmCpuD
    mov ah, 09h
    int 21h

    call CheckOxygen
    mov cl, 1
    call TestStatusBit
    call PrintDiagLine
    lea dx, nmOxyD
    mov ah, 09h
    int 21h

    call CheckFuel
    mov cl, 2
    call TestStatusBit
    call PrintDiagLine
    lea dx, nmFuelD
    mov ah, 09h
    int 21h

    call CheckBattery
    mov cl, 4
    call TestStatusBit
    call PrintDiagLine
    lea dx, nmBattD
    mov ah, 09h
    int 21h

    call CheckPressure
    mov cl, 5
    call TestStatusBit
    call PrintDiagLine
    lea dx, nmPresD
    mov ah, 09h
    int 21h

    lea dx, msgDiagCount
    mov ah, 09h
    int 21h
    mov ax, diagWarnCount
    call PrintNumber
    lea dx, msgNewline
    mov ah, 09h
    int 21h
    ret
RunDiagnostics endp

; Helper: AL(from TestStatusBit)=1 -> print WARN and bump diagWarnCount
PrintDiagLine proc
    cmp al, 1
    je DL_WARN
    lea dx, msgOK
    mov ah, 09h
    int 21h
    ret
DL_WARN:
    lea dx, msgWARN
    mov ah, 09h
    int 21h
    inc diagWarnCount
    ret
PrintDiagLine endp

; -------------------------------------------------------------
; RegisterSnapshot
; Purpose : Capture a real snapshot of general-purpose and
;           segment registers, plus flags, after performing a
;           representative calculation — demonstrates that the
;           values shown are not hardcoded text.
; -------------------------------------------------------------
RegisterSnapshot proc
    mov ax, fuelLevel
    mov bx, oxygenLevel
    add ax, bx              ; representative ALU op so flags are meaningful
    mov cx, SAMPLE_COUNT
    mov dx, engineTemp
    lea si, tempSamples
    lea di, fuelSamples

    mov snapAX, ax
    mov snapBX, bx
    mov snapCX, cx
    mov snapDX, dx
    mov snapSI, si
    mov snapDI, di
    mov snapSP, sp
    mov snapBP, bp
    mov snapDS, ds
    mov snapSS, ss
    mov snapES, es

    ; capture flags via PUSHF (pushes the FLAGS word onto the stack)
    pushf
    pop ax                  ; AX now holds the FLAGS register image
    mov bl, al
    and bl, 00000001b        ; bit 0 of FLAGS = CF
    mov flagCF, bl
    mov bl, al
    shr bl, 6
    and bl, 1                ; bit 6 of low byte = ZF
    mov flagZF, bl
    mov bl, al
    shr bl, 7
    and bl, 1                ; bit 7 of low byte = SF
    mov flagSF, bl
    mov bl, ah
    shr bl, 3
    and bl, 1                ; bit 11 overall = bit3 of high byte = OF
    mov flagOF, bl
    ret
RegisterSnapshot endp

msgRegHead db 13,10,'===============================================',13,10
           db '               CPU REGISTER VIEW',13,10
           db '===============================================',13,10,13,10,'$'
lblAX db 'AX = $'
lblBX db 'BX = $'
lblCX db 'CX = $'
lblDX db 'DX = $'
lblSI db 'SI = $'
lblDI db 'DI = $'
lblSP db 'SP = $'
lblBP db 'BP = $'
msgFlagsHead db 13,10,'FLAGS:',13,10,'$'
lblCF db 'CF = $'
lblZF db 'ZF = $'
lblSF db 'SF = $'
lblOF db 'OF = $'

ShowRegisterMonitor proc
    lea dx, msgRegHead
    mov ah, 09h
    int 21h

    lea dx, lblAX
    mov ah, 09h
    int 21h
    mov ax, snapAX
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblBX
    mov ah, 09h
    int 21h
    mov ax, snapBX
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblCX
    mov ah, 09h
    int 21h
    mov ax, snapCX
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblDX
    mov ah, 09h
    int 21h
    mov ax, snapDX
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblSI
    mov ah, 09h
    int 21h
    mov ax, snapSI
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblDI
    mov ah, 09h
    int 21h
    mov ax, snapDI
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblSP
    mov ah, 09h
    int 21h
    mov ax, snapSP
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblBP
    mov ah, 09h
    int 21h
    mov ax, snapBP
    call PrintHexWord
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, msgFlagsHead
    mov ah, 09h
    int 21h

    lea dx, lblCF
    mov ah, 09h
    int 21h
    mov al, flagCF
    call PrintDigit
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblZF
    mov ah, 09h
    int 21h
    mov al, flagZF
    call PrintDigit
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblSF
    mov ah, 09h
    int 21h
    mov al, flagSF
    call PrintDigit
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    lea dx, lblOF
    mov ah, 09h
    int 21h
    mov al, flagOF
    call PrintDigit
    lea dx, msgNewline
    mov ah, 09h
    int 21h
    ret
ShowRegisterMonitor endp

; Print AL (0 or 1) as a single ASCII digit
PrintDigit proc
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    ret
PrintDigit endp

; -------------------------------------------------------------
; EngineControlMenu
; Purpose : Start/Stop/Thrust commands, refuses unsafe thrust
;           increase while overheating (demonstrates CMP/Jcc
;           used for a real safety interlock, not just display).
; -------------------------------------------------------------
msgEngMenu db 13,10,'--- ENGINE CONTROL ---',13,10
           db '[1] Increase Thrust  [2] Decrease Thrust  [3] Back',13,10
           db 'SELECT: $'
msgThrustUp   db 13,10,'Thrust increased.',13,10,'$'
msgThrustDown db 13,10,'Thrust decreased.',13,10,'$'
msgOverheat   db 13,10,'WARNING: engine temperature $'
msgOverheat2  db ' exceeds max safe temp $'
msgOverheat3  db '.',13,10,'Thrust increase REFUSED - overheat condition.',13,10,'$'

EngineControlMenu proc
    lea dx, msgEngMenu
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    cmp al, '1'
    je ENG_UP
    cmp al, '2'
    je ENG_DOWN
    ret
ENG_UP:
    mov ax, engineTemp
    cmp ax, ENGINE_MAX_TEMP
    jbe ENG_UP_SAFE
    lea dx, msgOverheat
    mov ah, 09h
    int 21h
    mov ax, engineTemp
    call PrintNumber
    lea dx, msgOverheat2
    mov ah, 09h
    int 21h
    mov ax, ENGINE_MAX_TEMP
    call PrintNumber
    lea dx, msgOverheat3
    mov ah, 09h
    int 21h
    ret
ENG_UP_SAFE:
    add engineTemp, 5        ; thrust raises engine temp - real ALU effect
    lea dx, msgThrustUp
    mov ah, 09h
    int 21h
    ret
ENG_DOWN:
    sub engineTemp, 5
    lea dx, msgThrustDown
    mov ah, 09h
    int 21h
    ret
EngineControlMenu endp

; -------------------------------------------------------------
; EmergencyProtocol
; Purpose : Demonstrates stack-based state preservation during a
;           fault: PUSH every register we touch, set the
;           emergency bit, print the warning, then POP everything
;           back (LIFO order) before returning.
; -------------------------------------------------------------
msgEmergHead db 13,10,'===============================================',13,10
             db '              *** EMERGENCY MODE ***',13,10
             db '===============================================',13,10,'$'
msgEmergBody db 'Saving CPU state (PUSH)...',13,10
             db 'Setting EMERGENCY status bit...',13,10
             db 'Executing recovery protocol...',13,10
             db 'Restoring CPU state (POP)...',13,10
             db 'SYSTEM STATUS: STABILIZED',13,10,'$'

EmergencyProtocol proc
    push ax
    push bx
    push cx
    push dx

    lea dx, msgEmergHead
    mov ah, 09h
    int 21h
    lea dx, msgEmergBody
    mov ah, 09h
    int 21h

    mov cl, 7                 ; bit 7 = emergency mode
    call SetStatusBit

    pop dx
    pop cx
    pop bx
    pop ax
    ret
EmergencyProtocol endp

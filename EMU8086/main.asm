; =============================================================
; FILE:        EMU8086/main.asm
; ENVIRONMENT: [EMU8086]  Intel 8086 real mode
; PURPOSE:     Mission Control entry point, shared data, main
;              menu loop and dispatch to all subsystems.
;
; HOW TO ASSEMBLE (IMPORTANT):
;   This is written as a .COM-style program (ORG 100h), where
;   CS, DS, ES and SS all point to the SAME 64KB segment. That
;   deliberately avoids a real segment-mismatch bug that a
;   .model small (.EXE-style) program would hit here: this
;   project spans several files joined with INCLUDE, and
;   INCLUDE just pastes text - it does NOT respect .data/.code
;   boundaries. If message strings ended up physically inside
;   the code segment while DS pointed at a separate data
;   segment, "INT 21h, AH=09h" (DS:DX) would read garbage.
;   With everything in one segment this problem cannot occur:
;   DS:offset is correct for every label, wherever it sits.
;
;   EMU8086 has no multi-file linker, so this project is
;   assembled as ONE file: open THIS file (main.asm) in
;   EMU8086, Compile, then Emulate/Run. The other .asm files
;   in this folder are pulled in below via INCLUDE and contain
;   only procedures/data, no directives of their own.
; =============================================================

org 100h

start:
    jmp MAIN_ENTRY

    ; ---------- Telemetry (current values) ----------
    cpuTemp         dw 42
    engineTemp      dw 71
    oxygenLevel     dw 76
    fuelLevel       dw 61
    batteryLevel    dw 87
    altitude        dw 382
    velocity        dw 7
    pressure        dw 101

    ; ---------- Safety thresholds ----------
    ENGINE_MAX_TEMP  dw 90
    OXYGEN_MIN       dw 20
    FUEL_MIN         dw 15
    BATTERY_MIN      dw 10
    PRESSURE_MIN     dw 90

    ; ---------- Sensor sample arrays (8 samples each) ----------
    tempSamples     dw 42,44,43,45,47,46,48,50
    fuelSamples     dw 100,92,84,76,68,61,55,49
    oxygenSamples   dw 100,96,91,87,83,79,76,72
    SAMPLE_COUNT    equ 8

    ; ---------- Array scan results (filled by sensors.asm) ----------
    tempMin dw 0
    tempMax dw 0
    tempAvg dw 0
    tempSum dw 0
    fuelMin dw 0
    fuelMax dw 0
    fuelAvg dw 0
    fuelSum dw 0
    oxyMin  dw 0
    oxyMax  dw 0
    oxyAvg  dw 0
    oxySum  dw 0

    ; ---------- System status bit field ----------
    ; bit0=engine fail bit1=low O2 bit2=low fuel bit3=high temp
    ; bit4=low battery bit5=low pressure bit6=nav error bit7=emergency
    statusByte      db 00000000b

    ; ---------- Register-monitor snapshot storage ----------
    snapAX dw 0
    snapBX dw 0
    snapCX dw 0
    snapDX dw 0
    snapSI dw 0
    snapDI dw 0
    snapSP dw 0
    snapBP dw 0
    snapDS dw 0
    snapSS dw 0
    snapES dw 0
    flagCF db 0
    flagZF db 0
    flagSF db 0
    flagOF db 0

    ; ---------- Menu / message text ----------
    msgTitle       db 13,10,'===============================================',13,10
                   db '            MISSION CONTROL v1.0',13,10
                   db '         SPACECRAFT FLIGHT COMPUTER',13,10
                   db '===============================================',13,10,'$'
    msgTagline     db '        MONITOR. CONTROL. SURVIVE.',13,10,13,10,'$'

    msgMenu        db '[1] SYSTEM DIAGNOSTICS',13,10
                   db '[2] SENSOR DATA',13,10
                   db '[3] ENGINE CONTROL',13,10
                   db '[4] REGISTER / MEMORY MONITOR',13,10
                   db '[5] EMERGENCY MODE (force-trigger demo)',13,10
                   db '[6] SOFTWARE INTERRUPT DEMO',13,10
                   db '[7] SIMULATED HARDWARE INTERRUPT (PIC) DEMO',13,10
                   db '[8] DIVIDE-BY-ZERO EXCEPTION DEMO',13,10
                   db '[9] VIDEO MEMORY DASHBOARD (B800h)',13,10
                   db '[0] EXIT',13,10,13,10
                   db 'SELECT: $'

    msgInvalid     db 13,10,'*** INVALID SELECTION ***',13,10,'$'
    msgNewline     db 13,10,'$'
    msgExit        db 13,10,'Mission Control shutting down. Godspeed.',13,10,'$'

; =============================================================
; Program entry / top-level menu loop
; (No DS/ES setup needed - a .COM program already starts with
;  CS=DS=ES=SS, so every label above is already correctly
;  addressable through DS.)
; =============================================================
MAIN_ENTRY:

MENU_LOOP:
    call PrintTitle
    call PrintTelemetrySummary
    lea dx, msgMenu
    mov ah, 09h
    int 21h

    ; --- read a single character (no Enter needed) ---
    mov ah, 01h
    int 21h                     ; AL = ASCII of key pressed
    lea dx, msgNewline
    mov ah, 09h
    int 21h

    cmp al, '1'
    je DO_DIAGNOSTICS
    cmp al, '2'
    je DO_SENSORS
    cmp al, '3'
    je DO_ENGINE
    cmp al, '4'
    je DO_REGISTERS
    cmp al, '5'
    je DO_EMERGENCY
    cmp al, '6'
    je DO_SOFTINT
    cmp al, '7'
    je DO_HARDINT
    cmp al, '8'
    je DO_EXCEPTION
    cmp al, '9'
    je DO_VIDEO
    cmp al, '0'
    je DO_EXIT

    lea dx, msgInvalid
    mov ah, 09h
    int 21h
    jmp MENU_LOOP

DO_DIAGNOSTICS:
    call RunDiagnostics
    jmp MENU_LOOP
DO_SENSORS:
    call ScanTemperatureArray
    call ScanFuelArray
    call ScanOxygenArray
    call PrintSensorReport
    jmp MENU_LOOP
DO_ENGINE:
    call EngineControlMenu
    jmp MENU_LOOP
DO_REGISTERS:
    call RegisterSnapshot
    call ShowRegisterMonitor
    call ShowMemoryMonitor
    jmp MENU_LOOP
DO_EMERGENCY:
    call EmergencyProtocol
    jmp MENU_LOOP
DO_SOFTINT:
    call DemoSoftwareInterrupts
    jmp MENU_LOOP
DO_HARDINT:
    call SimulatedHardwareInterrupt
    jmp MENU_LOOP
DO_EXCEPTION:
    call DivideByZeroDemo
    jmp MENU_LOOP
DO_VIDEO:
    call DrawDashboard
    ; wait for a key before returning to DOS-text menu
    mov ah, 01h
    int 21h
    jmp MENU_LOOP

DO_EXIT:
    lea dx, msgExit
    mov ah, 09h
    int 21h
    mov ah, 4Ch
    int 21h                    ; DOS: terminate program

; =============================================================
; PROCEDURE: PrintTitle
; PURPOSE  : Prints the banner + tagline
; =============================================================
PrintTitle proc
    lea dx, msgTitle
    mov ah, 09h
    int 21h
    lea dx, msgTagline
    mov ah, 09h
    int 21h
    ret
PrintTitle endp

    include procedures.asm
    include sensors.asm
    include input.asm
    include interrupts.asm
    include exception_demo.asm
    include video_memory.asm
    include memory_monitor.asm

end start

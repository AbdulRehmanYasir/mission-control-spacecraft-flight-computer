; =============================================================
; FILE:        VisualStudio2019/AssemblyLibrary.asm
; ENVIRONMENT: MASM / Visual Studio / WIN32 x86
; PURPOSE:     Standalone MASM library linked into the C++ project.
; =============================================================

.386
.model flat, C
option casemap :none

.code

; -------------------------------------------------------------
; AssemblyCalculateMissionScore
; Returns average of fuel + oxygen + battery.
; -------------------------------------------------------------

PUBLIC AssemblyCalculateMissionScore

AssemblyCalculateMissionScore PROC C fuel:DWORD, oxygen:DWORD, battery:DWORD
    mov eax, fuel
    add eax, oxygen
    add eax, battery
    cdq
    mov ecx, 3
    idiv ecx
    ret
AssemblyCalculateMissionScore ENDP


; -------------------------------------------------------------
; AssemblySensorCheck
; Returns 1 if value > threshold, otherwise 0.
; -------------------------------------------------------------

PUBLIC AssemblySensorCheck

AssemblySensorCheck PROC C value:DWORD, threshold:DWORD
    mov eax, value
    cmp eax, threshold
    jle SC_NOT_EXCEEDED

    mov eax, 1
    ret

SC_NOT_EXCEEDED:
    mov eax, 0
    ret
AssemblySensorCheck ENDP


; -------------------------------------------------------------
; AssemblyRunWithCallback
; Assembly calls a C++ function: LogFromAssembly.
; -------------------------------------------------------------

EXTERN LogFromAssembly:PROC

PUBLIC AssemblyRunWithCallback

AssemblyRunWithCallback PROC C value:DWORD
    push value
    call LogFromAssembly
    add esp, 4
    mov eax, 1
    ret
AssemblyRunWithCallback ENDP


END
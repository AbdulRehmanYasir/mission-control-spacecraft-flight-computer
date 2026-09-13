; =============================================================
; FILE:        VisualStudio2019/AssemblyLibrary.asm
; ENVIRONMENT: [MASM LIBRARY FOR VISUAL STUDIO 2019+ / WIN32 x86]
; PURPOSE:     A genuinely SEPARATE assembly source file, hand
;              -written for MASM, assembled to its own .obj and
;              linked into the Win32/x86 project - this is
;              different from the inline __asm in AssemblyCore.cpp
;              and demonstrates the real project-configuration
;              path (Build Customizations -> masm) for mixing a
;              standalone .asm file into an MSVC C++ project.
;
; CALLING CONVENTION: __cdecl ("C" language type below), which
; on 32-bit x86 means:
;   - arguments pushed right-to-left by the caller
;   - the CALLER cleans the stack afterward (not the callee)
;   - the return value comes back in EAX
;   - MASM's "PROC C" + ".model flat, C" automatically prepends
;     the leading underscore that MSVC's 32-bit C/C++ compiler
;     expects on cdecl symbol names, so linking matches up
;     without any extra decoration work on our part.
;
; BUILD SETUP REQUIRED (see docs or VisualStudio2019/README.md):
;   1. Right-click the project -> Build Dependencies -> Build
;      Customizations -> check "masm(.targets, .props)".
;   2. Add this file to the project.
;   3. Right-click AssemblyLibrary.asm -> Properties -> Item Type
;      -> "Microsoft Macro Assembler".
;   4. Ensure the project Platform is Win32 (x86), not x64.
; =============================================================

.386
.model flat, C
option casemap :none

.code

; -------------------------------------------------------------
; AssemblyCalculateMissionScore
; Purpose : C++ calls INTO this real linked Assembly function.
;           Returns the average of fuel/oxygen/battery as a
;           simple composite "mission score".
; -------------------------------------------------------------
AssemblyCalculateMissionScore PROC C fuel:DWORD, oxygen:DWORD, battery:DWORD
    mov eax, fuel
    add eax, oxygen
    add eax, battery
    cdq
    mov ecx, 3
    idiv ecx                    ; EAX = (fuel+oxygen+battery) / 3
    ret
AssemblyCalculateMissionScore ENDP

; -------------------------------------------------------------
; AssemblySensorCheck
; Purpose : Returns 1 if value > threshold, else 0.
; -------------------------------------------------------------
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
; Purpose : Demonstrates the REVERSE direction - Assembly calling
;           a function that is DEFINED IN C++ (LogFromAssembly,
;           implemented in AssemblyLibrary.cpp). We push the
;           single cdecl argument ourselves and clean the stack
;           ourselves afterward, exactly as __cdecl requires.
; -------------------------------------------------------------
EXTERN LogFromAssembly:PROC

AssemblyRunWithCallback PROC C value:DWORD
    push value
    call LogFromAssembly
    add esp, 4                  ; caller cleans the stack (cdecl)
    mov eax, 1
    ret
AssemblyRunWithCallback ENDP

END

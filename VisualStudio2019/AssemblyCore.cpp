// =============================================================
// FILE:        VisualStudio2019/AssemblyCore.cpp
// ENVIRONMENT: [VISUAL STUDIO 2019+ / WIN32 x86 ONLY]
// PURPOSE:     Real MSVC inline __asm implementations of ALU
//              math, bit manipulation, threshold checks, array
//              scanning, and a register/flags snapshot.
//
// IMPORTANT: This file will NOT compile in an x64 configuration.
// MSVC removed __asm support for x64 entirely - the project
// must be built as Win32 (x86). See docs/Architecture.md.
//
// DESIGN NOTE: struct-member and pointer-offset addressing modes
// inside __asm blocks are compiler-version-fragile in practice,
// so every routine here copies the C++-side struct fields it
// needs into plain local variables (or writes results into plain
; locals) BEFORE/AFTER the __asm block, and does only register-
// and-plain-variable work inside the block itself. That keeps
// every instruction here a real, unambiguous 32-bit x86
// instruction rather than a compiler-specific member-access
// trick.
// =============================================================
#include "AssemblyCore.h"

// -------------------------------------------------------------
// ALU demonstrations
// -------------------------------------------------------------
int Asm_AddFuelDelta(int currentFuel, int delta) {
    int result;
    __asm {
        mov eax, currentFuel
        add eax, delta          ; ADD
        mov result, eax
    }
    return result;
}

int Asm_TempDifference(int a, int b) {
    int result;
    __asm {
        mov eax, a
        sub eax, b               ; SUB
        mov result, eax
    }
    return result;
}

int Asm_ScaleByFactor(int value, int factor) {
    int result;
    __asm {
        mov eax, value
        imul eax, factor         ; signed MUL
        mov result, eax
    }
    return result;
}

int Asm_AverageOfTwo(int a, int b) {
    int result;
    __asm {
        mov eax, a
        add eax, b
        cdq                      ; sign-extend EAX into EDX:EAX for IDIV
        mov ecx, 2
        idiv ecx                 ; signed DIV
        mov result, eax
    }
    return result;
}

// -------------------------------------------------------------
// Bit manipulation on a byte pointed to by byteVar
// -------------------------------------------------------------
void Asm_SetBit(unsigned char* byteVar, int bitNumber) {
    __asm {
        mov ebx, byteVar
        mov cl, byte ptr bitNumber
        mov al, 1
        shl al, cl               ; build the bit mask
        or  byte ptr [ebx], al   ; OR sets the bit, leaves others alone
    }
}

void Asm_ClearBit(unsigned char* byteVar, int bitNumber) {
    __asm {
        mov ebx, byteVar
        mov cl, byte ptr bitNumber
        mov al, 1
        shl al, cl
        not al                   ; invert mask
        and byte ptr [ebx], al   ; AND clears only the target bit
    }
}

void Asm_ToggleBit(unsigned char* byteVar, int bitNumber) {
    __asm {
        mov ebx, byteVar
        mov cl, byte ptr bitNumber
        mov al, 1
        shl al, cl
        xor byte ptr [ebx], al   ; XOR flips exactly the target bit
    }
}

int Asm_TestBit(unsigned char* byteVar, int bitNumber) {
    int result;
    __asm {
        mov ebx, byteVar
        mov al, byte ptr [ebx]
        mov cl, byte ptr bitNumber
        shr al, cl
        and al, 1
        movzx eax, al
        mov result, eax
    }
    return result;
}

// -------------------------------------------------------------
// Threshold checks - each reads one telemetry field (copied to a
// local by C++), compares it in __asm with CMP/Jcc, then updates
// g_statusByte through the bit-manipulation routines above.
// -------------------------------------------------------------
void Asm_CheckEngine(const Telemetry* t) {
    int engineTemp = t->engineTemp;
    int limit = ENGINE_MAX_TEMP;
    int isOver;
    __asm {
        mov eax, engineTemp
        cmp eax, limit           ; sets flags used by JLE
        jle ENGINE_SAFE
        mov isOver, 1
        jmp ENGINE_DONE
    ENGINE_SAFE:
        mov isOver, 0
    ENGINE_DONE:
    }
    if (isOver) Asm_SetBit(&g_statusByte, 3);
    else        Asm_ClearBit(&g_statusByte, 3);
}

void Asm_CheckOxygen(const Telemetry* t) {
    int oxygen = t->oxygenLevel;
    int limit = OXYGEN_MIN;
    int isLow;
    __asm {
        mov eax, oxygen
        cmp eax, limit
        jge OXY_SAFE
        mov isLow, 1
        jmp OXY_DONE
    OXY_SAFE:
        mov isLow, 0
    OXY_DONE:
    }
    if (isLow) Asm_SetBit(&g_statusByte, 1);
    else       Asm_ClearBit(&g_statusByte, 1);
}

void Asm_CheckFuel(const Telemetry* t) {
    int fuel = t->fuelLevel;
    int limit = FUEL_MIN;
    int isLow;
    __asm {
        mov eax, fuel
        cmp eax, limit
        jge FUEL_SAFE
        mov isLow, 1
        jmp FUEL_DONE
    FUEL_SAFE:
        mov isLow, 0
    FUEL_DONE:
    }
    if (isLow) Asm_SetBit(&g_statusByte, 2);
    else       Asm_ClearBit(&g_statusByte, 2);
}

void Asm_CheckBattery(const Telemetry* t) {
    int battery = t->batteryLevel;
    int limit = BATTERY_MIN;
    int isLow;
    __asm {
        mov eax, battery
        cmp eax, limit
        jge BATT_SAFE
        mov isLow, 1
        jmp BATT_DONE
    BATT_SAFE:
        mov isLow, 0
    BATT_DONE:
    }
    if (isLow) Asm_SetBit(&g_statusByte, 4);
    else       Asm_ClearBit(&g_statusByte, 4);
}

// -------------------------------------------------------------
// Asm_ScanArray
// Purpose : Walk a short[] using a pointer register (ESI) and
//           base+index-style addressing ([esi]), tracking
//           min/max with CMP/Jcc and accumulating a sum for the
//           average - the 32-bit-x86 analogue of the EMU8086
//           sensor-scan routine.
// -------------------------------------------------------------
void Asm_ScanArray(short* arr, int count, short* outMin, short* outMax, int* outAvg) {
    short minVal, maxVal;
    int avgVal;

    __asm {
        mov esi, arr
        mov ecx, count
        mov ax, [esi]            ; first element
        movsx ebx, ax             ; EBX = running min
        movsx edx, ax             ; EDX = running max
        movsx edi, ax             ; EDI = running sum accumulator
        add esi, 2
        dec ecx

    SCAN_LOOP:
        cmp ecx, 0
        je SCAN_DONE
        mov ax, [esi]             ; register-indirect load
        movsx eax, ax
        add edi, eax
        cmp eax, ebx
        jge CHECK_MAX
        mov ebx, eax              ; new minimum
    CHECK_MAX:
        cmp eax, edx
        jle NEXT_ITER
        mov edx, eax              ; new maximum
    NEXT_ITER:
        add esi, 2
        dec ecx
        jmp SCAN_LOOP

    SCAN_DONE:
        mov minVal, bx
        mov maxVal, dx
        mov eax, edi
        cdq
        mov ecx, count
        idiv ecx
        mov avgVal, eax
    }

    *outMin = minVal;
    *outMax = maxVal;
    *outAvg = avgVal;
}

// -------------------------------------------------------------
// Asm_CaptureRegisters
// Purpose : Perform a representative computation, then capture
//           real EAX/EBX/ECX/EDX/ESI/EDI/ESP/EBP and the CF/ZF/
//           SF/OF flag bits (via PUSHFD) into a snapshot struct.
// EFLAGS bit positions used: CF=bit0, ZF=bit6, SF=bit7, OF=bit11
// -------------------------------------------------------------
void Asm_CaptureRegisters(RegisterSnapshot* snap) {
    unsigned int r_eax, r_ebx, r_ecx, r_edx, r_esi, r_edi, r_esp, r_ebp;
    int f_cf, f_zf, f_sf, f_of;

    __asm {
        mov eax, 01234h
        mov ebx, 05678h
        mov ecx, 09ABCh
        mov edx, 0DEF0h
        add eax, ebx              ; representative ALU op so flags mean something
        mov esi, offset g_tempSamples
        mov edi, offset g_fuelSamples

        mov r_eax, eax
        mov r_ebx, ebx
        mov r_ecx, ecx
        mov r_edx, edx
        mov r_esi, esi
        mov r_edi, edi
        mov r_esp, esp
        mov r_ebp, ebp

        pushfd
        pop eax                   ; EAX now holds an image of EFLAGS

        mov ebx, eax
        and ebx, 1
        mov f_cf, ebx

        mov ebx, eax
        shr ebx, 6
        and ebx, 1
        mov f_zf, ebx

        mov ebx, eax
        shr ebx, 7
        and ebx, 1
        mov f_sf, ebx

        mov ebx, eax
        shr ebx, 11
        and ebx, 1
        mov f_of, ebx
    }

    snap->eax = r_eax; snap->ebx = r_ebx; snap->ecx = r_ecx; snap->edx = r_edx;
    snap->esi = r_esi; snap->edi = r_edi; snap->esp = r_esp; snap->ebp = r_ebp;
    snap->cf = f_cf; snap->zf = f_zf; snap->sf = f_sf; snap->of = f_of;
}

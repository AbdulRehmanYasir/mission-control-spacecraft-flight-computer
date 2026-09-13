// =============================================================
// FILE:        VisualStudio2019/AssemblyCore.h
// ENVIRONMENT: [VISUAL STUDIO 2019+ / WIN32]
// PURPOSE:     Declarations for the inline-__asm routines. Every
//              function implemented in AssemblyCore.cpp uses
//              real MSVC x86 inline Assembly - this header is
//              plain C++ so it can be included anywhere.
//
// BUILD REQUIREMENT: Project must target Win32 (x86), NOT x64.
// MSVC does not support __asm blocks in x64 builds at all.
// =============================================================
#pragma once
#include "MissionControl.h"
#include "SensorEngine.h"

struct RegisterSnapshot {
    unsigned int eax, ebx, ecx, edx, esi, edi, esp, ebp;
    int cf, zf, sf, of;   // 0 or 1
};

// ALU + flags: representative telemetry math done in __asm
int  Asm_AddFuelDelta(int currentFuel, int delta);      // ADD
int  Asm_TempDifference(int a, int b);                  // SUB
int  Asm_ScaleByFactor(int value, int factor);          // MUL
int  Asm_AverageOfTwo(int a, int b);                    // DIV

// Bit manipulation on the shared status byte (g_statusByte)
void Asm_SetBit(unsigned char* byteVar, int bitNumber);     // OR
void Asm_ClearBit(unsigned char* byteVar, int bitNumber);   // AND + NOT
void Asm_ToggleBit(unsigned char* byteVar, int bitNumber);  // XOR
int  Asm_TestBit(unsigned char* byteVar, int bitNumber);    // AND/SHR -> 0 or 1

// Threshold checks (CMP + Jcc) that maintain g_statusByte
void Asm_CheckEngine(const Telemetry* t);
void Asm_CheckOxygen(const Telemetry* t);
void Asm_CheckFuel(const Telemetry* t);
void Asm_CheckBattery(const Telemetry* t);

// Array scan: base+index addressing over a C++ array via a
// pointer register, using CMP/Jcc for min/max tracking
void Asm_ScanArray(short* arr, int count, short* outMin, short* outMax, int* outAvg);

// Live register/flags capture (from inside a real computation)
void Asm_CaptureRegisters(RegisterSnapshot* snap);

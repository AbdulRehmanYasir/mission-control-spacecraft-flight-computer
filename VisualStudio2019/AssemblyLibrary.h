// =============================================================
// FILE:        VisualStudio2019/AssemblyLibrary.h
// ENVIRONMENT: [VISUAL STUDIO 2019+ / WIN32]
// PURPOSE:     C++-visible declarations for the functions
//              implemented in the separate AssemblyLibrary.asm
//              MASM source file, plus the C++ callback that
//              Assembly calls back into.
// =============================================================
#pragma once

extern "C" {
    // Implemented in AssemblyLibrary.asm (real linked MASM code)
    int AssemblyCalculateMissionScore(int fuel, int oxygen, int battery);
    int AssemblySensorCheck(int value, int threshold);
    int AssemblyRunWithCallback(int value);

    // Implemented in AssemblyLibrary.cpp - called FROM AssemblyLibrary.asm
    void LogFromAssembly(int code);
}

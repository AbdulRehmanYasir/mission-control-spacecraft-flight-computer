// =============================================================
// FILE:        VisualStudio2019/SensorEngine.h
// ENVIRONMENT: [VISUAL STUDIO 2019+ / WIN32]
// PURPOSE:     C++-side sensor sample storage. These are the
//              arrays that AssemblyCore.cpp (inline __asm) and
//              MMXEngine.cpp (MMX) both operate on, demonstrating
//              Assembly accessing real C++ arrays/pointers.
// =============================================================
#pragma once

const int SAMPLE_COUNT = 8;

// short (2 bytes) so 4 samples pack into one 64-bit MM register
extern short g_tempSamples[SAMPLE_COUNT];
extern short g_fuelSamples[SAMPLE_COUNT];
extern short g_oxygenSamples[SAMPLE_COUNT];

void PrintSensorArray(const char* label, short* arr, int count);

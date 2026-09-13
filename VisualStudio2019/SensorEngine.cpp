// =============================================================
// FILE:        VisualStudio2019/SensorEngine.cpp
// ENVIRONMENT: [VISUAL STUDIO 2019+ / WIN32]
// PURPOSE:     Definitions for the sensor arrays and a plain
//              C++ helper to print them (no assembly here - this
//              module's job is simply to own the data that the
//              assembly modules will process).
// =============================================================
#include <iostream>
#include "SensorEngine.h"

short g_tempSamples[SAMPLE_COUNT]   = { 42, 44, 43, 45, 47, 46, 48, 50 };
short g_fuelSamples[SAMPLE_COUNT]   = { 100, 92, 84, 76, 68, 61, 55, 49 };
short g_oxygenSamples[SAMPLE_COUNT] = { 100, 96, 91, 87, 83, 79, 76, 72 };

void PrintSensorArray(const char* label, short* arr, int count) {
    std::cout << label << ": ";
    for (int i = 0; i < count; i++) {
        std::cout << arr[i];
        if (i != count - 1) std::cout << ", ";
    }
    std::cout << "\n";
}

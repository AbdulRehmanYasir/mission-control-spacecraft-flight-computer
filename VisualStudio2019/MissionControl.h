// =============================================================
// FILE:        VisualStudio2019/MissionControl.h
// ENVIRONMENT: [VISUAL STUDIO 2019+ / WIN32]
// PURPOSE:     Shared telemetry data structure and top-level
//              declarations used across MissionControl.cpp,
//              SensorEngine, AssemblyCore and MMXEngine.
//
// DATA TYPE SIZES USED IN THIS PROJECT (x86, MSVC):
//   char   = 1 byte   (used for raw status/bit-field bytes)
//   short  = 2 bytes  (used for compact packed-integer sensor
//                        samples so 4 of them fit in one 64-bit
//                        MMX register)
//   int    = 4 bytes  (used for ordinary telemetry values)
//   double = 8 bytes  (NOT used inside any MMX routine - MMX in
//                        this project only ever processes packed
//                        integers, never IEEE-754 floats/doubles)
// =============================================================
#pragma once

struct Telemetry {
    int cpuTemp;
    int engineTemp;
    int oxygenLevel;
    int fuelLevel;
    int batteryLevel;
    int altitude;
    int velocity;
    int pressure;
};

// Status bit field (same bit layout as the EMU8086 side, kept
// consistent on purpose even though the two programs don't link):
//   bit0 = engine failure     bit4 = low battery
//   bit1 = low oxygen         bit5 = pressure warning
//   bit2 = low fuel           bit6 = navigation error
//   bit3 = high temperature   bit7 = emergency mode
extern unsigned char g_statusByte;

// Safety thresholds
const int ENGINE_MAX_TEMP = 90;
const int OXYGEN_MIN = 20;
const int FUEL_MIN = 15;
const int BATTERY_MIN = 10;

void RunMissionControlMenu();

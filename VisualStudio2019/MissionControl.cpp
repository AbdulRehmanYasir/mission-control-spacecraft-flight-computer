// =============================================================
// FILE:        VisualStudio2019/MissionControl.cpp
// ENVIRONMENT: [VISUAL STUDIO 2019+ / WIN32 x86 ONLY]
// PURPOSE:     Main console application. Coordinates
//              SensorEngine (C++ data), AssemblyCore (inline
//              __asm), MMXEngine (MMX), and AssemblyLibrary
//              (linked MASM .asm) - each module stays
//              independently testable; this file just wires
//              them together behind a menu.
//
// BUILD: Win32 (x86) configuration. See VisualStudio2019/README.md
// for exact project setup steps, including the MASM build
// customization needed for AssemblyLibrary.asm.
// =============================================================
#include <iostream>
#include "MissionControl.h"
#include "SensorEngine.h"
#include "AssemblyCore.h"
#include "MMXEngine.h"
#include "AssemblyLibrary.h"

unsigned char g_statusByte = 0;

static Telemetry g_telemetry = { 42, 71, 76, 61, 87, 382, 7, 101 };

static void PrintTelemetry() {
    std::cout << "\n===============================================\n";
    std::cout << "             MISSION CONTROL v1.0\n";
    std::cout << "        (Visual Studio / Win32 x86 build)\n";
    std::cout << "===============================================\n";
    std::cout << "CPU TEMP    : " << g_telemetry.cpuTemp << " C\n";
    std::cout << "ENGINE TEMP : " << g_telemetry.engineTemp << " C\n";
    std::cout << "OXYGEN      : " << g_telemetry.oxygenLevel << " %\n";
    std::cout << "FUEL        : " << g_telemetry.fuelLevel << " %\n";
    std::cout << "BATTERY     : " << g_telemetry.batteryLevel << " %\n";
    std::cout << "ALTITUDE    : " << g_telemetry.altitude << " KM\n";
    std::cout << "VELOCITY    : " << g_telemetry.velocity << " KM/S\n";
    std::cout << "PRESSURE    : " << g_telemetry.pressure << " KPa\n";
    std::cout << "-----------------------------------------------\n";
}

static void PrintMenu() {
    std::cout << "[1] SYSTEM DIAGNOSTICS (ALU threshold checks)\n";
    std::cout << "[2] SENSOR DATA (array scan via inline asm)\n";
    std::cout << "[3] ENGINE CONTROL (thrust +/- with safety interlock)\n";
    std::cout << "[4] REGISTER / FLAGS VIEW (live capture)\n";
    std::cout << "[5] BIT MANIPULATION DEMO (status byte)\n";
    std::cout << "[6] MMX SENSOR ANALYSIS (packed integer ops)\n";
    std::cout << "[7] ASSEMBLY LIBRARY DEMO (linked MASM + callback)\n";
    std::cout << "[0] EXIT\n";
    std::cout << "SELECT: ";
}

static void PrintStatusByte() {
    std::cout << "STATUS BYTE = ";
    for (int bit = 7; bit >= 0; bit--) {
        std::cout << Asm_TestBit(&g_statusByte, bit);
    }
    std::cout << "\n";
    static const char* names[8] = {
        "engine failure", "low oxygen", "low fuel", "high temperature",
        "low battery", "pressure warning", "navigation error", "emergency mode"
    };
    for (int bit = 0; bit < 8; bit++) {
        if (Asm_TestBit(&g_statusByte, bit)) {
            std::cout << "  [ACTIVE] bit " << bit << " - " << names[bit] << "\n";
        }
    }
}

static void RunDiagnostics() {
    Asm_CheckEngine(&g_telemetry);
    Asm_CheckOxygen(&g_telemetry);
    Asm_CheckFuel(&g_telemetry);
    Asm_CheckBattery(&g_telemetry);
    std::cout << "\n--- DIAGNOSTICS COMPLETE ---\n";
    PrintStatusByte();
}

static void RunSensorScan() {
    short tMin, tMax, fMin, fMax, oMin, oMax;
    int tAvg, fAvg, oAvg;

    Asm_ScanArray(g_tempSamples, SAMPLE_COUNT, &tMin, &tMax, &tAvg);
    Asm_ScanArray(g_fuelSamples, SAMPLE_COUNT, &fMin, &fMax, &fAvg);
    Asm_ScanArray(g_oxygenSamples, SAMPLE_COUNT, &oMin, &oMax, &oAvg);

    std::cout << "\n--- SENSOR DATA (8-sample history) ---\n";
    PrintSensorArray("TEMP  ", g_tempSamples, SAMPLE_COUNT);
    std::cout << "  min/max/avg: " << tMin << "/" << tMax << "/" << tAvg << "\n";
    PrintSensorArray("FUEL  ", g_fuelSamples, SAMPLE_COUNT);
    std::cout << "  min/max/avg: " << fMin << "/" << fMax << "/" << fAvg << "\n";
    PrintSensorArray("OXYGEN", g_oxygenSamples, SAMPLE_COUNT);
    std::cout << "  min/max/avg: " << oMin << "/" << oMax << "/" << oAvg << "\n";
}

static void RunEngineControl() {
    std::cout << "\n--- ENGINE CONTROL ---\n[1] Increase thrust  [2] Decrease thrust\nSELECT: ";
    int choice; std::cin >> choice;
    if (choice == 1) {
        if (g_telemetry.engineTemp > ENGINE_MAX_TEMP) {
            std::cout << "WARNING: engine temperature " << g_telemetry.engineTemp
                      << " exceeds max safe temp " << ENGINE_MAX_TEMP
                      << ".\nThrust increase REFUSED - overheat condition.\n";
        } else {
            g_telemetry.engineTemp = Asm_AddFuelDelta(g_telemetry.engineTemp, 5);
            std::cout << "Thrust increased. Engine temp now " << g_telemetry.engineTemp << " C\n";
        }
    } else if (choice == 2) {
        g_telemetry.engineTemp = Asm_TempDifference(g_telemetry.engineTemp, 5);
        std::cout << "Thrust decreased. Engine temp now " << g_telemetry.engineTemp << " C\n";
    }
}

static void RunRegisterView() {
    RegisterSnapshot snap;
    Asm_CaptureRegisters(&snap);
    std::cout << "\n--- CPU REGISTER VIEW (captured live) ---\n";
    printf("EAX = %08Xh   EBX = %08Xh\n", snap.eax, snap.ebx);
    printf("ECX = %08Xh   EDX = %08Xh\n", snap.ecx, snap.edx);
    printf("ESI = %08Xh   EDI = %08Xh\n", snap.esi, snap.edi);
    printf("ESP = %08Xh   EBP = %08Xh\n", snap.esp, snap.ebp);
    std::cout << "FLAGS: CF=" << snap.cf << " ZF=" << snap.zf
               << " SF=" << snap.sf << " OF=" << snap.of << "\n";
}

static void RunBitDemo() {
    std::cout << "\n--- BIT MANIPULATION DEMO ---\n";
    std::cout << "Before: "; PrintStatusByte();
    Asm_SetBit(&g_statusByte, 6);      // set "navigation error"
    std::cout << "After SetBit(6): "; PrintStatusByte();
    Asm_ToggleBit(&g_statusByte, 6);
    std::cout << "After ToggleBit(6): "; PrintStatusByte();
    Asm_ClearBit(&g_statusByte, 6);
    std::cout << "After ClearBit(6): "; PrintStatusByte();
}

static void RunMMXDemo() {
    std::cout << "\n--- MMX SENSOR ANALYSIS ---\n";
    std::cout << "Before adjustment: ";
    PrintSensorArray("TEMP", g_tempSamples, SAMPLE_COUNT);

    MMX_BatchAdjustSamples(g_tempSamples, SAMPLE_COUNT, 2);   // +2C recalibration
    std::cout << "After +2 MMX packed adjustment: ";
    PrintSensorArray("TEMP", g_tempSamples, SAMPLE_COUNT);

    int exceedCount = 0;
    MMX_BatchThresholdCheck(g_tempSamples, SAMPLE_COUNT, 47, &exceedCount);
    std::cout << exceedCount << " of " << SAMPLE_COUNT
              << " temperature samples exceed 47 (checked via packed PCMPGTW)\n";
}

static void RunAssemblyLibraryDemo() {
    std::cout << "\n--- ASSEMBLY LIBRARY DEMO (linked MASM .asm) ---\n";
    int score = AssemblyCalculateMissionScore(g_telemetry.fuelLevel,
                                               g_telemetry.oxygenLevel,
                                               g_telemetry.batteryLevel);
    std::cout << "AssemblyCalculateMissionScore(fuel,oxygen,battery) = " << score << "\n";

    int exceeded = AssemblySensorCheck(g_telemetry.engineTemp, ENGINE_MAX_TEMP);
    std::cout << "AssemblySensorCheck(engineTemp, ENGINE_MAX_TEMP) = " << exceeded << "\n";

    std::cout << "Calling AssemblyRunWithCallback(99) - Assembly will call back into C++:\n";
    AssemblyRunWithCallback(99);
}

void RunMissionControlMenu() {
    int choice = -1;
    while (choice != 0) {
        PrintTelemetry();
        PrintMenu();
        std::cin >> choice;
        switch (choice) {
            case 1: RunDiagnostics(); break;
            case 2: RunSensorScan(); break;
            case 3: RunEngineControl(); break;
            case 4: RunRegisterView(); break;
            case 5: RunBitDemo(); break;
            case 6: RunMMXDemo(); break;
            case 7: RunAssemblyLibraryDemo(); break;
            case 0: std::cout << "\nMission Control shutting down. Godspeed.\n"; break;
            default: std::cout << "\n*** INVALID SELECTION ***\n"; break;
        }
    }
}

int main() {
    RunMissionControlMenu();
    return 0;
}

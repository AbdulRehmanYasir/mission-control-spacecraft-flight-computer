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

using namespace std;

unsigned char g_statusByte = 0;

static Telemetry g_telemetry = { 42, 71, 76, 61, 87, 382, 7, 101 };

static void PrintTelemetry() {
    cout << "\n===============================================\n";
    cout << "             MISSION CONTROL v1.0.1\n";
    cout << "        (Visual Studio / Win32 x86 build)\n";
    cout << "===============================================\n";
    cout << "CPU TEMP    : " << g_telemetry.cpuTemp << " C\n";
    cout << "ENGINE TEMP : " << g_telemetry.engineTemp << " C\n";
    cout << "OXYGEN      : " << g_telemetry.oxygenLevel << " %\n";
    cout << "FUEL        : " << g_telemetry.fuelLevel << " %\n";
    cout << "BATTERY     : " << g_telemetry.batteryLevel << " %\n";
    cout << "ALTITUDE    : " << g_telemetry.altitude << " KM\n";
    cout << "VELOCITY    : " << g_telemetry.velocity << " KM/S\n";
    cout << "PRESSURE    : " << g_telemetry.pressure << " KPa\n";
    cout << "-----------------------------------------------\n";
    cout << "      Built with \xE2\x9D\xA4 by Abdul Rehman Yasir\n";
    cout << "-----------------------------------------------\n";
}

static void PrintMenu() {
    cout << "[1] SYSTEM DIAGNOSTICS (ALU threshold checks)\n";
    cout << "[2] SENSOR DATA (array scan via inline asm)\n";
    cout << "[3] ENGINE CONTROL (thrust +/- with safety interlock)\n";
    cout << "[4] REGISTER / FLAGS VIEW (live capture)\n";
    cout << "[5] BIT MANIPULATION DEMO (status byte)\n";
    cout << "[6] MMX SENSOR ANALYSIS (packed integer ops)\n";
    cout << "[7] ASSEMBLY LIBRARY DEMO (linked MASM + callback)\n";
    cout << "[0] EXIT\n";
    cout << "SELECT: ";
}

static void PrintStatusByte() {
    cout << "STATUS BYTE = ";
    for (int bit = 7; bit >= 0; bit--) {
        cout << Asm_TestBit(&g_statusByte, bit);
    }
    cout << "\n";

    static const char* names[8] = {
        "engine failure",
        "low oxygen",
        "low fuel",
        "high temperature",
        "low battery",
        "pressure warning",
        "navigation error",
        "emergency mode"
    };

    for (int bit = 0; bit < 8; bit++) {
        if (Asm_TestBit(&g_statusByte, bit)) {
            cout << "  [ACTIVE] bit " << bit << " - " << names[bit] << "\n";
        }
    }
}

static void RunDiagnostics() {
    Asm_CheckEngine(&g_telemetry);
    Asm_CheckOxygen(&g_telemetry);
    Asm_CheckFuel(&g_telemetry);
    Asm_CheckBattery(&g_telemetry);

    cout << "\n--- DIAGNOSTICS COMPLETE ---\n";
    PrintStatusByte();
}

static void RunSensorScan() {
    short tMin, tMax, fMin, fMax, oMin, oMax;
    int tAvg, fAvg, oAvg;

    Asm_ScanArray(g_tempSamples, SAMPLE_COUNT, &tMin, &tMax, &tAvg);
    Asm_ScanArray(g_fuelSamples, SAMPLE_COUNT, &fMin, &fMax, &fAvg);
    Asm_ScanArray(g_oxygenSamples, SAMPLE_COUNT, &oMin, &oMax, &oAvg);

    cout << "\n--- SENSOR DATA (8-sample history) ---\n";

    PrintSensorArray("TEMP  ", g_tempSamples, SAMPLE_COUNT);
    cout << "  min/max/avg: " << tMin << "/" << tMax << "/" << tAvg << "\n";

    PrintSensorArray("FUEL  ", g_fuelSamples, SAMPLE_COUNT);
    cout << "  min/max/avg: " << fMin << "/" << fMax << "/" << fAvg << "\n";

    PrintSensorArray("OXYGEN", g_oxygenSamples, SAMPLE_COUNT);
    cout << "  min/max/avg: " << oMin << "/" << oMax << "/" << oAvg << "\n";
}

static void RunEngineControl() {
    cout << "\n--- ENGINE CONTROL ---\n";
    cout << "[1] Increase thrust  [2] Decrease thrust\n";
    cout << "SELECT: ";

    int choice;
    cin >> choice;

    if (choice == 1) {
        if (g_telemetry.engineTemp > ENGINE_MAX_TEMP) {
            cout << "WARNING: engine temperature "
                 << g_telemetry.engineTemp
                 << " exceeds max safe temp "
                 << ENGINE_MAX_TEMP
                 << ".\nThrust increase REFUSED - overheat condition.\n";
        } else {
            g_telemetry.engineTemp =
                Asm_AddFuelDelta(g_telemetry.engineTemp, 5);

            cout << "Thrust increased. Engine temp now "
                 << g_telemetry.engineTemp
                 << " C\n";
        }
    }
    else if (choice == 2) {
        g_telemetry.engineTemp =
            Asm_TempDifference(g_telemetry.engineTemp, 5);

        cout << "Thrust decreased. Engine temp now "
             << g_telemetry.engineTemp
             << " C\n";
    }
}

static void RunRegisterView() {
    RegisterSnapshot snap;
    Asm_CaptureRegisters(&snap);

    cout << "\n--- CPU REGISTER VIEW (captured live) ---\n";

    printf("EAX = %08Xh   EBX = %08Xh\n", snap.eax, snap.ebx);
    printf("ECX = %08Xh   EDX = %08Xh\n", snap.ecx, snap.edx);
    printf("ESI = %08Xh   EDI = %08Xh\n", snap.esi, snap.edi);
    printf("ESP = %08Xh   EBP = %08Xh\n", snap.esp, snap.ebp);

    cout << "FLAGS: CF=" << snap.cf
         << " ZF=" << snap.zf
         << " SF=" << snap.sf
         << " OF=" << snap.of
         << "\n";
}

static void RunBitDemo() {
    cout << "\n--- BIT MANIPULATION DEMO ---\n";

    cout << "Before: ";
    PrintStatusByte();

    Asm_SetBit(&g_statusByte, 6);
    cout << "After SetBit(6): ";
    PrintStatusByte();

    Asm_ToggleBit(&g_statusByte, 6);
    cout << "After ToggleBit(6): ";
    PrintStatusByte();

    Asm_ClearBit(&g_statusByte, 6);
    cout << "After ClearBit(6): ";
    PrintStatusByte();
}

static void RunMMXDemo() {
    cout << "\n--- MMX SENSOR ANALYSIS ---\n";

    cout << "Before adjustment: ";
    PrintSensorArray("TEMP", g_tempSamples, SAMPLE_COUNT);

    MMX_BatchAdjustSamples(g_tempSamples, SAMPLE_COUNT, 2);

    cout << "After +2 MMX packed adjustment: ";
    PrintSensorArray("TEMP", g_tempSamples, SAMPLE_COUNT);

    int exceedCount = 0;

    MMX_BatchThresholdCheck(
        g_tempSamples,
        SAMPLE_COUNT,
        47,
        &exceedCount
    );

    cout << exceedCount << " of "
         << SAMPLE_COUNT
         << " temperature samples exceed 47 "
         << "(checked via packed PCMPGTW)\n";
}

static void RunAssemblyLibraryDemo() {
    cout << "\n--- ASSEMBLY LIBRARY DEMO (linked MASM .asm) ---\n";

    int score = AssemblyCalculateMissionScore(
        g_telemetry.fuelLevel,
        g_telemetry.oxygenLevel,
        g_telemetry.batteryLevel
    );

    cout << "AssemblyCalculateMissionScore(fuel,oxygen,battery) = "
         << score << "\n";

    int exceeded = AssemblySensorCheck(
        g_telemetry.engineTemp,
        ENGINE_MAX_TEMP
    );

    cout << "AssemblySensorCheck(engineTemp, ENGINE_MAX_TEMP) = "
         << exceeded << "\n";

    cout << "Calling AssemblyRunWithCallback(99) - "
         << "Assembly will call back into C++:\n";

    AssemblyRunWithCallback(99);
}

void RunMissionControlMenu() {
    int choice = -1;

    while (choice != 0) {
        PrintTelemetry();
        PrintMenu();

        cin >> choice;

        switch (choice) {
            case 1:
                RunDiagnostics();
                break;

            case 2:
                RunSensorScan();
                break;

            case 3:
                RunEngineControl();
                break;

            case 4:
                RunRegisterView();
                break;

            case 5:
                RunBitDemo();
                break;

            case 6:
                RunMMXDemo();
                break;

            case 7:
                RunAssemblyLibraryDemo();
                break;

            case 0:
                cout << "\nMission Control shutting down. Godspeed.\n";
                break;

            default:
                cout << "\n*** INVALID SELECTION ***\n";
                break;
        }
    }
}

int main() {
    RunMissionControlMenu();
    return 0;
}
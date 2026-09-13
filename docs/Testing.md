# Testing

Technical honesty note: none of these have been executed on a real EMU8086 or
Visual Studio installation yet (neither was available while building this
project). Every row is marked **NOT YET EXECUTED**. Run them in order on a
lab machine and fill in "Actual Result" and "Status" yourself - the "Expected
Result" column tells you what to look for.

## EMU8086

| Test ID | Feature | Input | Expected Result | Actual Result | Status |
|---|---|---|---|---|---|
| TC01 | Main menu | Launch main.asm | Banner + telemetry + 10-item menu shown | | NOT YET EXECUTED |
| TC02 | Invalid input | Press a key not in 0-9 | "*** INVALID SELECTION ***", menu redisplays | | NOT YET EXECUTED |
| TC03 | Diagnostics | Select [1] | OK/WARN per subsystem + a warning count | | NOT YET EXECUTED |
| TC04 | Sensor scan | Select [2] | min/max/avg printed for temp/fuel/oxygen arrays | | NOT YET EXECUTED |
| TC05 | Engine overheat refusal | Set engineTemp>90 (edit .data), select [3]->[1] | Thrust increase refused, warning shown | | NOT YET EXECUTED |
| TC06 | Register monitor | Select [4] | AX/BX/CX/DX/SI/DI/SP/BP in hex + CF/ZF/SF/OF | | NOT YET EXECUTED |
| TC07 | Memory monitor | Select [4] (same screen) | DS/SS/ES + Segment*16+Offset worked example | | NOT YET EXECUTED |
| TC08 | Emergency mode | Select [5] | Emergency banner, bit 7 set in status byte | | NOT YET EXECUTED |
| TC09 | Software interrupts | Select [6] | INT21h/INT10h demo text + a keypress echoed | | NOT YET EXECUTED |
| TC10 | Simulated hardware interrupt | Select [7] | 6-step IRQ->PIC->ISR->EOI text sequence, clearly labeled simulation | | NOT YET EXECUTED |
| TC11 | Divide-by-zero exception | Select [8] | Exception banner, "SYSTEM STATUS: RECOVERED", program keeps running afterward | | NOT YET EXECUTED |
| TC12 | Video memory dashboard | Select [9] | Bordered dashboard drawn directly via B800h, any key returns to text menu | | NOT YET EXECUTED |
| TC13 | Exit | Select [0] | Farewell message, clean DOS return (AH=4Ch) | | NOT YET EXECUTED |

## Visual Studio (Win32/x86)

| Test ID | Feature | Input | Expected Result | Actual Result | Status |
|---|---|---|---|---|---|
| TC14 | Diagnostics | Menu [1] | Status byte printed with active-warning names listed | | NOT YET EXECUTED |
| TC15 | Sensor scan | Menu [2] | Arrays printed + min/max/avg from Asm_ScanArray | | NOT YET EXECUTED |
| TC16 | Engine overheat refusal | Menu [3], engineTemp>90 | Thrust increase refused | | NOT YET EXECUTED |
| TC17 | Register/flags capture | Menu [4] | EAX..EBP in hex + CF/ZF/SF/OF | | NOT YET EXECUTED |
| TC18 | Bit manipulation | Menu [5] | Set/Toggle/Clear on bit 6 shown step by step | | NOT YET EXECUTED |
| TC19 | MMX batch adjust | Menu [6] | All 8 temp samples show +2 after one call | | NOT YET EXECUTED |
| TC20 | MMX threshold check | Menu [6] | Correct count of samples >47 via PCMPGTW | | NOT YET EXECUTED |
| TC21 | Assembly library (C++->ASM) | Menu [7] | AssemblyCalculateMissionScore / AssemblySensorCheck return correct values | | NOT YET EXECUTED |
| TC22 | Assembly library (ASM->C++) | Menu [7] | "[C++ CALLBACK] Assembly called back into C++ with value: 99" printed | | NOT YET EXECUTED |
| TC23 | Build config | Project properties | Platform = Win32 confirmed, x64 build fails to compile AssemblyCore.cpp (expected) | | NOT YET EXECUTED |

## Cross-cutting

| Test ID | Feature | Input | Expected Result | Actual Result | Status |
|---|---|---|---|---|---|
| TC24 | ASCII input | Type "382" into ReadNumber (input.asm) | AX = 382 | | NOT YET EXECUTED |
| TC25 | Divide by zero recovery loop | Trigger TC11 twice in the same run | Both times recover cleanly (vector restored after first run) | | NOT YET EXECUTED |

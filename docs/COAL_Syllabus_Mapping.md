# COAL Syllabus Mapping

Each row: course topic → where it lives in this project → why it's there (not decorative).

| Syllabus Topic | Project Feature | File(s) | Notes |
|---|---|---|---|
| Number systems (bin/dec/hex/ASCII) | ASCII-to-integer telemetry input (e.g. "382" → 382) | `EMU8086/input.asm` | Real conversion loop using `AAM`/multiply-by-10 accumulation, not a library call |
| 8086 registers | CPU/Register Monitor menu option | `EMU8086/procedures.asm`, `examples/register_demo.asm` | Displays AX/BX/CX/DX/SI/DI/SP/BP/flags after a real computation, not hardcoded text |
| Data movement / addressing modes | Sensor array access, direct/indirect/indexed `MOV` | `EMU8086/sensors.asm` | Register, immediate, direct, register-indirect, indexed addressing all used on sensor arrays |
| Segmented memory | Memory Monitor (Segment×16+Offset) | `EMU8086/memory_monitor.asm` | Shows DS/SS/ES and computed physical address |
| ALU operations | Fuel %, temp delta, battery drain calculations | `EMU8086/procedures.asm`, `VisualStudio2019/AssemblyCore.cpp` | ADD/SUB/MUL/DIV/AND/OR/XOR used for actual telemetry math, both environments |
| Flags | Threshold branching (CMP/JA → overheat) | `EMU8086/procedures.asm` | CF/ZF/SF/OF explained inline where the branch depends on them |
| Arrays | Temperature/fuel/oxygen/pressure/altitude/velocity arrays | `EMU8086/sensors.asm` | Base+index addressing, LOOP-driven scanning |
| Loops & branching | Sensor scan loop, diagnostics scan | `EMU8086/sensors.asm`, `procedures.asm` | LOOP, JE/JNE/JA/JB used for real threshold decisions |
| Bit manipulation | System-status bit field (8 fault bits) | `EMU8086/procedures.asm`, `VisualStudio2019/AssemblyCore.cpp` | SET/CLEAR/TEST bit via AND/OR/XOR; SHL/SHR/ROL/ROR demoed on the same field |
| Stack | Parameter passing into procedures | `EMU8086/procedures.asm` | PUSH/POP around CALL boundaries, explicit stack-frame note |
| CALL/RET, subroutines | ReadSensor/CalculateFuel/CheckEngine/etc. | `EMU8086/procedures.asm` | Each procedure documented: purpose/inputs/outputs/registers modified & preserved |
| Software interrupts | INT 21h keyboard/output demo | `EMU8086/interrupts.asm` | Real DOS/BIOS interrupts only — no invented interrupt numbers |
| Exception handling / IVT | Divide-by-zero demo with recovery message | `EMU8086/exception_demo.asm` | Explains the IVT entry used and ISR behavior for INT 0 |
| Hardware interrupts / PIC | Labeled educational simulation | `EMU8086/interrupts.asm` (clearly separated section) | Explicitly marked "SIMULATED HARDWARE INTERRUPT", never claims real IRQ access |
| Video memory | Mission Control dashboard via B800h | `EMU8086/video_memory.asm` | offset = row*160 + col*2, ClearScreen/SetCursor/PrintAt/DrawDashboard |
| 32-bit x86 / inline Assembly | Telemetry math inside C++ | `VisualStudio2019/AssemblyCore.cpp` | `__asm { }` blocks, Win32 only (MSVC disallows this in x64) |
| MMX | Parallel sensor batch analysis | `VisualStudio2019/MMXEngine.cpp` | MOVQ + packed integer ops across 4 sensor samples at once, EMMS before returning |
| Assembly library integration | C++ calling a MASM `.asm` function | `VisualStudio2019/AssemblyLibrary.asm` | Real MASM file added to the Win32 project with build-setting instructions, not a fabricated API |
| C++ called from Assembly | Assembly invoking a C++ logging/display callback | `VisualStudio2019/AssemblyLibrary.asm` + `AssemblyCore.cpp` | Calling convention explicitly documented (`__cdecl`) |

This table will be expanded with exact line references once source files are written in later phases.

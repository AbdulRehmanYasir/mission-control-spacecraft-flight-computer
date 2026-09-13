# MISSION CONTROL — Spacecraft Flight Computer
## Architecture Document (Phase 1)

Tagline: "Monitor. Control. Survive."

---

## 1. What This Project Actually Is

A COAL lab project split across **two independent, non-interoperating environments**
that share one theme (a simulated spacecraft flight computer) and one design language
(a text-mode Mission Control terminal). They are NOT linked at build or runtime — you
will demo them separately.

| Environment | Purpose | Real toolchain |
|---|---|---|
| **EMU8086** | 8086 real-mode concepts: registers, segmentation, video memory (B800h), software interrupts, IVT/exception demo, ASCII conversion, arrays/loops on 16-bit data | EMU8086 emulator |
| **Visual Studio 2019+ (Win32/x86)** | 32-bit inline `__asm`, C++ ↔ Assembly calling in both directions, MMX packed-integer sensor engine | MSVC, Win32 (x86) configuration |

There is no attempt to make one binary run in both places — that would be dishonest,
since 8086 real-mode code and 32-bit protected-mode Win32 code are fundamentally
different targets. Every file is labeled with its environment.

---

## 2. Module Responsibilities

### EMU8086 side (`/EMU8086`)
| File | Responsibility |
|---|---|
| `main.asm` | Program entry, main menu loop, dispatch to procedures |
| `procedures.asm` | Core CALL/RET procedures: CheckEngine, CheckOxygen, CalculateFuel, EmergencyProtocol, DisplayStatus |
| `sensors.asm` | Sensor arrays (temperature/fuel/oxygen/pressure/altitude/velocity) + array-scanning loops |
| `input.asm` | ASCII digit input → integer conversion (multi-digit numeric input routine) |
| `interrupts.asm` | DOS/BIOS interrupt demos (INT 21h keyboard/output), IVT explanation |
| `exception_demo.asm` | Divide-by-zero / overflow exception demonstration, ISR-style recovery |
| `video_memory.asm` | Direct B800h text-mode writes: ClearScreen, SetCursor, PrintAt, DrawBox, DrawDashboard |
| `memory_monitor.asm` | Segment:offset → physical address demo (Segment×16+Offset) |

### Visual Studio side (`/VisualStudio2019`)
| File | Responsibility |
|---|---|
| `MissionControl.cpp/.h` | Main console app, menu, telemetry struct, calls into other modules |
| `SensorEngine.cpp/.h` | C++ sensor arrays (`int[]`, `short[]`, `char[]`) fed to inline-asm routines |
| `AssemblyCore.cpp/.h` | Inline `__asm` blocks: ALU ops on telemetry, bit-field status flags, register-monitor snapshot |
| `MMXEngine.cpp/.h` | MMX packed-integer sensor batch processing (MOVQ, packed add/sub, PCMPGT for threshold checks), EMMS discipline |
| `AssemblyLibrary.asm` + linkage | Separate MASM `.asm` file assembled by MASM and linked into the Win32 project — demonstrates a real C++-calls-Assembly-function link, plus one Assembly-calls-C++-callback example |

### Docs (`/docs`)
`Project_Report.md`, `COAL_Syllabus_Mapping.md` (this phase), `Architecture.md` (this file), `Algorithms.md`, `Testing.md`, `Viva_Questions.md`.

### Examples (`/examples`)
Small standalone demo files (`register_demo.asm`, `stack_demo.asm`, `interrupt_demo.asm`, `video_memory_demo.asm`, `mmx_demo.cpp`) — used for isolated viva walkthroughs when you don't want to run the whole program.

---

## 3. Data Flow (per environment)

**EMU8086:**
`main.asm menu → sensors.asm (arrays) → procedures.asm (CALL, ALU, CMP/Jcc) → video_memory.asm (DrawDashboard) → interrupts.asm/exception_demo.asm (on trigger)`

**Visual Studio:**
`MissionControl.cpp menu → SensorEngine (C++ arrays) → AssemblyCore.cpp (__asm on those arrays) → MMXEngine.cpp (batch packed ops) → AssemblyLibrary.asm (linked MASM function) → back to C++ for display`

---

## 4. Honesty Notes (binding for the whole project)

- No real spacecraft hardware, telemetry, or physical IRQ access — everything is simulated data, clearly labeled.
- 8086 code never uses 32/64-bit register names; Win32 code never uses `__asm` in an x64 config (MSVC forbids it — we target Win32/x86 only).
- "Hardware interrupt/PIC" content is an **educational simulation**, explicitly labeled as such, not real IRQ hooking.
- MMX section keeps floating point out of MMX; packed **integer** sensor samples only, `EMMS` used before returning to any FPU/double-precision code.

---

## 5. Status

Phase 1 (this document + folder structure + syllabus mapping + roadmap) — done.
Phases 2–12 build actual source files incrementally, each followed by a compatibility check against the rules above.

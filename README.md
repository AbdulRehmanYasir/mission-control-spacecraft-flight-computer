# MISSION CONTROL — Spacecraft Flight Computer
### Computer Organization & Assembly Language (COAL) Lab Project
**"Monitor. Control. Survive."**

## Overview
A simulated spacecraft flight computer built in two deliberately separate
environments to cover the COAL syllabus honestly:

- **EMU8086** (`EMU8086/`) — real-mode 8086 assembly: registers, segmented
  memory, ALU/flags, arrays/loops, bit manipulation, the stack, software
  interrupts, a real divide-by-zero exception demo (with genuine IVT
  hooking), a simulated hardware-interrupt/PIC walkthrough, and a
  direct-to-video-memory (B800h) dashboard.
- **Visual Studio 2019+ / Win32 (x86)** (`VisualStudio2019/`) — C++ with
  MSVC inline `__asm`, an MMX packed-integer sensor engine, and a
  separately-assembled MASM library demonstrating both C++→Assembly and
  Assembly→C++ calls.

These two programs are **not linked together** — 8086 real mode and 32-bit
Win32 protected mode are different execution environments, and pretending
otherwise would be dishonest. They share a theme, a status-bit layout, and a
design language, not a binary.

## Technologies
C++ (MSVC), 8086/x86 Assembly (EMU8086 + MASM), Win32, MMX. No web
technologies, no TypeScript, no React are used anywhere in this project.

## Architecture
See [`docs/Architecture.md`](docs/Architecture.md) for the full module
breakdown and [`docs/COAL_Syllabus_Mapping.md`](docs/COAL_Syllabus_Mapping.md)
for exactly which file/function covers which syllabus topic.

## Folder structure
```
MISSION-CONTROL/
├── README.md
├── EMU8086/                 8086 real-mode source (open main.asm in EMU8086)
├── VisualStudio2019/        Win32/x86 C++ + MASM source (see its README.md)
├── examples/                small standalone files for isolated viva demos
└── docs/                    Architecture, syllabus mapping, algorithms,
                              testing, viva questions, project report, roadmap
```

## Requirements
- **EMU8086** emulator, any recent version.
- **Visual Studio 2019 or newer**, "Desktop development with C++" workload
  (includes the MASM component), targeting **Win32 (x86)** — not x64.

## Build instructions

### EMU8086
1. Open `EMU8086/main.asm` in EMU8086 (the other `.asm` files are pulled in
   automatically via `INCLUDE` — don't open them separately).
2. Compile, then Emulate/Run.

### Visual Studio 2019+
See [`VisualStudio2019/README.md`](VisualStudio2019/README.md) for exact
steps, including the MASM build-customization required for
`AssemblyLibrary.asm`. Platform must be **Win32/x86**.

## Run / demo instructions
EMU8086: use the numbered menu (0–9) to walk through diagnostics, sensors,
engine control, the register/memory monitor, emergency mode, interrupt/
exception demos, and the video-memory dashboard.

Visual Studio: use the numbered menu (0–7) to walk through diagnostics,
sensors, engine control, the register/flags view, bit manipulation, MMX
analysis, and the Assembly-library demo.

A recommended 10–15 minute demo order is in `docs/Roadmap.md`.

## Known limitations
- **Nothing here has been assembled or compiled yet** — neither EMU8086 nor
  Visual Studio was available while building this project. The code has
  been hand-reviewed for correctness (and one real segment-model bug was
  caught and fixed during that review — see `docs/Project_Report.md`
  section 13), but build it module by module on a lab machine and expect to
  fix small, version-specific syntax issues as they come up.
- The hardware-interrupt/PIC section is an explicitly-labeled educational
  **simulation** — it does not touch real hardware IRQ lines.
- This is a simulation of a flight computer for a 10%-weight COAL lab
  project, not real spacecraft software.

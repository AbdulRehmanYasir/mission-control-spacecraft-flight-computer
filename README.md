<div align="center">

# MISSION CONTROL — Spacecraft Flight Computer

### Computer Organization & Assembly Language (COAL) Lab Project

A simulated spacecraft flight computer demonstrating core COAL concepts across 8086 Assembly, x86 Assembly, C++, MASM, Win32, and MMX.

**"Monitor. Control. Survive."**

</div>

---

## Overview

**MISSION CONTROL** is an educational spacecraft flight-computer simulation built to demonstrate and integrate concepts from the **Computer Organization & Assembly Language (COAL)** syllabus.

The project is deliberately divided into two independent environments:

* **EMU8086** — real-mode 8086 Assembly covering registers, segmented memory, ALU/FLAGS, arrays and loops, bit manipulation, stack operations, software interrupts, exception handling, interrupt vector table (IVT) hooking, a simulated PIC/hardware-interrupt walkthrough, and direct video-memory output through `B800h`.

* **Visual Studio 2019+ / Win32 x86** — C++ with MSVC inline `__asm`, an MMX packed-integer sensor engine, and a separately assembled MASM library demonstrating both C++ → Assembly and Assembly → C++ calls.

These environments are **not linked together**. They run in different execution environments and share only the spacecraft theme, status-bit layout, and design language.

---

## Core Features

* 🧠 **8086 Assembly** — Registers, segmented memory, ALU operations, FLAGS, arrays, loops, bit manipulation, and stack operations.
* ⚡ **Software Interrupts** — Interrupt-based demonstrations and exception handling.
* 🚨 **Divide-by-Zero Exception** — Genuine exception demonstration with IVT hooking.
* 🔌 **PIC / Hardware Interrupt Walkthrough** — Educational simulation of hardware-interrupt concepts without accessing real hardware IRQ lines.
* 🖥️ **Video Memory Dashboard** — Direct output through the `B800h` video-memory segment.
* ⚙️ **C++ + Inline Assembly** — MSVC C++ integrated with x86 inline `__asm`.
* 📊 **MMX Sensor Engine** — Packed-integer operations for sensor processing.
* 🔧 **MASM Assembly Library** — Separately assembled Assembly functions linked with the Win32 application.
* 🔗 **C++ ↔ Assembly Integration** — Demonstrates both C++ → Assembly and Assembly → C++ calls.
* 🛰️ **Spacecraft Systems Simulation** — Diagnostics, sensor monitoring, engine control, status monitoring, and system demonstrations.

---

## Environments

| Environment                         | Purpose                                             |
| ----------------------------------- | --------------------------------------------------- |
| **EMU8086**                         | 8086 real-mode Assembly and COAL demonstrations     |
| **Visual Studio 2019+ / Win32 x86** | C++, inline x86 Assembly, MMX, and MASM integration |

The two environments are intentionally separate because **8086 real mode** and **32-bit Win32 protected mode** are different execution environments.

---

## EMU8086 Modules

The EMU8086 environment demonstrates:

* CPU registers
* Segmented memory
* ALU operations
* FLAGS
* Arrays and loops
* Bit manipulation
* Stack operations
* Software interrupts
* Divide-by-zero exception handling
* IVT hooking
* Simulated PIC / hardware interrupts
* Direct `B800h` video-memory output
* Spacecraft diagnostic and monitoring demonstrations

Open `EMU8086/main.asm` in EMU8086 to run the main demonstration.

---

## Visual Studio Modules

The Visual Studio environment includes:

* System diagnostics
* Sensor data processing
* Engine control
* Register and FLAGS inspection
* Bit manipulation
* MMX sensor analysis
* Linked MASM Assembly library
* C++ → Assembly function calls
* Assembly → C++ callbacks

The application uses a numbered console menu to access each demonstration.

---

## Technology Stack

* **Language:** C++
* **Assembly:** 8086 / x86 Assembly
* **Assembler:** MASM
* **8086 Environment:** EMU8086
* **Platform:** Win32 / x86
* **Instruction Set:** MMX
* **Compiler:** MSVC

---

## Project Structure

```text
MISSION-CONTROL/
├── README.md
├── EMU8086/
│   └── 8086 real-mode Assembly source
├── VisualStudio2019/
│   └── Win32/x86 C++ + MASM source
├── examples/
│   └── Standalone COAL demonstration files
└── docs/
    ├── Architecture.md
    ├── COAL_Syllabus_Mapping.md
    ├── Algorithms.md
    ├── Testing.md
    ├── Viva_Questions.md
    ├── Project_Report.md
    └── Roadmap.md
```

---

## Requirements

### EMU8086

* EMU8086 emulator
* Any recent version

### Visual Studio

* Visual Studio 2019 or newer
* Desktop development with C++ workload
* MASM component
* Win32 / x86 target
* **Do not use x64**

---

## Running EMU8086

1. Open `EMU8086/main.asm` in EMU8086.
2. Compile the project.
3. Start Emulate / Run.
4. Use the numbered menu to explore the available demonstrations.

The other Assembly files are included automatically through `INCLUDE`.

---

## Running Visual Studio

Open the Visual Studio project from:

```text
VisualStudio2019/
```

Configure the project for:

```text
Platform: Win32 / x86
Configuration: Debug or Release
```

The MASM build customization is required for `AssemblyLibrary.asm`.

See the Visual Studio README for the complete project configuration and build instructions.

---

## Demonstrations

The project provides demonstrations covering:

* System diagnostics
* Sensor monitoring
* Engine control
* CPU registers
* FLAGS
* Bit manipulation
* MMX packed-integer processing
* Assembly library integration
* C++ → Assembly calls
* Assembly → C++ callbacks
* Interrupt and exception concepts
* Video-memory output

A recommended **10–15 minute demonstration order** is available in:

`docs/Roadmap.md`

---

## COAL Concepts Covered

| Concept                           | Environment             |
| --------------------------------- | ----------------------- |
| Registers                         | EMU8086 + Visual Studio |
| Segmented Memory                  | EMU8086                 |
| ALU / FLAGS                       | EMU8086                 |
| Arrays / Loops                    | EMU8086                 |
| Bit Manipulation                  | EMU8086 + Visual Studio |
| Stack                             | EMU8086                 |
| Software Interrupts               | EMU8086                 |
| Exception Handling                | EMU8086                 |
| IVT Hooking                       | EMU8086                 |
| PIC / Hardware Interrupt Concepts | EMU8086                 |
| Video Memory                      | EMU8086                 |
| Inline Assembly                   | Visual Studio           |
| MMX                               | Visual Studio           |
| MASM                              | Visual Studio           |
| C++ / Assembly Integration        | Visual Studio           |

---

## Architecture

The project intentionally maintains two separate execution environments:

```text
                    MISSION CONTROL
                          │
             ┌────────────┴────────────┐
             │                         │
          EMU8086                Visual Studio
             │                         │
       8086 Real Mode            Win32 / x86
             │                         │
     ┌───────┴───────┐        ┌────────┴────────┐
     │               │        │        │       │
 Registers       Interrupts   C++     MMX     MASM
 Memory          Exceptions   │        │       │
 ALU / FLAGS     Video RAM    │        │       │
 Bit Operations               └────────┴───────┘
```

The programs are **not binary-linked**. They share a common theme, status-bit layout, and design language while remaining technically independent.

---

## Known Limitations

* The hardware-interrupt/PIC section is an explicitly labeled educational simulation and does not access real hardware IRQ lines.
* The project is intended as a COAL laboratory and educational demonstration.
* The 8086 and Win32 environments are intentionally independent.
* MMX is a legacy instruction-set technology.
* Visual Studio builds require a **Win32/x86** target because the project uses MSVC inline `__asm`.

---

## Educational Purpose

This project is designed for a **Computer Organization & Assembly Language laboratory project**.

It demonstrates how low-level concepts such as:

**Registers → Memory → ALU → FLAGS → Bits → Interrupts → Assembly → C++**

can be combined into a single themed system while keeping the underlying execution environments technically accurate.

---

## License

This project is currently maintained as a personal development and academic project.

---

<div align="center">

**MISSION CONTROL — Monitor. Control. Survive.**

Made with ❤️ by **Abdul Rehman Yasir**

</div>

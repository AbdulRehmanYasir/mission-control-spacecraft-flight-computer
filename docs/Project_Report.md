# Project Report — Mission Control: Spacecraft Flight Computer

## 1. Introduction
Mission Control is a two-part Computer Organization and Assembly Language
(COAL) laboratory project simulating a spacecraft flight computer. It pairs
a real-mode 8086 program (EMU8086) with a 32-bit Win32 C++/Assembly program
(Visual Studio 2019+) to cover the course syllabus using one coherent theme.

## 2. Problem Statement
Course concepts (registers, addressing modes, segmentation, ALU operations,
flags, arrays, loops, bit manipulation, the stack, procedures, interrupts,
the IVT, exceptions, hardware-interrupt concepts, video memory, 32-bit
inline assembly, MMX, and C++/Assembly interoperability) are usually
practiced as disconnected exercises. This project gives them a single,
motivating, testable context: monitoring and controlling a simulated
spacecraft.

## 3. Objectives
- Demonstrate the majority of the COAL syllabus with working, commented code.
- Keep the EMU8086 and Visual Studio implementations honestly separate,
  since 8086 real mode and 32-bit Win32 protected mode are not compatible
  execution environments.
- Avoid any fabricated API, invented instruction, or unsupported claim about
  real hardware access.

## 4. System Overview
The user interacts with a text menu (EMU8086, DOS-style) or a console menu
(Visual Studio) offering diagnostics, sensor data, engine control, a
register/memory monitor, an emergency mode, interrupt/exception demos, a
video-memory dashboard (EMU8086 side), bit manipulation and MMX sensor
analysis (Visual Studio side), and an Assembly-library demo (Visual Studio
side). See `docs/Architecture.md` for the full module breakdown.

## 5. System Architecture
Two independent programs share a theme and a status-bit layout but not a
binary or a build:
- **EMU8086/** - a single assembled `.COM`-style file (`main.asm` plus
  seven `INCLUDE`d modules) targeting real-mode 8086.
- **VisualStudio2019/** - a Win32 (x86) C++ console application with one
  linked MASM `.asm` file, targeting 32-bit protected mode.

## 6. Hardware/CPU Concepts
Both programs work directly with general-purpose registers (AX-DX, SI/DI,
SP/BP on the 8086 side; EAX-EDX, ESI/EDI, ESP/EBP on the Win32 side),
segment registers (8086 side), and the FLAGS/EFLAGS bits CF/ZF/SF/OF,
captured live rather than hardcoded for display.

## 7. Assembly Concepts
Addressing modes (immediate, register, direct, register-indirect, indexed),
ALU instructions (ADD/SUB/MUL/DIV/AND/OR/XOR/NOT), bit manipulation
(SET/CLEAR/TOGGLE/TEST via SHL/AND/OR/XOR), the stack (PUSH/POP/CALL/RET,
a manual stack-frame parameter-passing example), and LOOP-driven array
scanning are all implemented against real telemetry data rather than as
throwaway snippets.

## 8. C++ Integration
`AssemblyCore.cpp` uses MSVC inline `__asm` (Win32/x86 only) for ALU math,
bit manipulation, threshold checks, an array scan, and a register/flags
snapshot - all operating on real C++ variables, arrays, and pointers.

## 9. Interrupt System
The EMU8086 side demonstrates real DOS/BIOS software interrupts (INT 21h,
INT 10h), a real IVT hook-and-recovery for a genuine divide-by-zero
exception, and a clearly-labeled educational simulation of the hardware
IRQ/PIC/EOI sequence (explicitly not claiming real hardware access, since
EMU8086 cannot safely guarantee that).

## 10. Memory Management
`memory_monitor.asm` computes a real physical address from a segment and
offset using `Physical = Segment * 16 + Offset`, implemented with `MUL` and
carry-propagating `ADC` since the true result can exceed 16 bits.

## 11. MMX Processing
`MMXEngine.cpp` processes sensor samples in packed groups of four 16-bit
integers using MOVQ/PADDW/PCMPGTW, with EMMS executed before returning -
demonstrating data-level parallelism while explicitly keeping floating-point
data out of the MMX registers.

## 12. Testing
See `docs/Testing.md` for the full test table (25 cases). None have been
executed yet, since neither EMU8086 nor Visual Studio was available while
building this project - every row is marked NOT YET EXECUTED pending a run
on a lab machine.

## 13. Results
All source files described in `docs/Architecture.md` and
`docs/COAL_Syllabus_Mapping.md` have been written and hand-reviewed for
instruction-level correctness. One real design bug (a segment-mismatch
between `.model small`'s separate CODE/DATA segments and the multi-file
`INCLUDE` structure) was caught during review and fixed by switching the
EMU8086 program to a single-segment `.COM`-style layout - documented here
so the reasoning is visible, not hidden.

## 14. Limitations
- Nothing in this project has been assembled or compiled yet - see the
  "Known Limitations" sections in `EMU8086/main.asm`'s header comment and
  `VisualStudio2019/README.md`. Build incrementally, module by module.
- The hardware-interrupt/PIC section is a simulation, not real IRQ access.
- MMX is a legacy instruction set; modern debuggers may show it with
  limited register-inspection support (does not affect correctness).

## 15. Future Improvements
- Extend the sensor arrays to more samples and add a rolling-history buffer.
- Add an SSE2 comparison implementation alongside MMX to show the
  generational difference.
- Add a simple radar/navigation subsystem module to exercise more array and
  addressing-mode variety.

## 16. Conclusion
Mission Control demonstrates the full CPU-to-application stack the COAL
syllabus covers - registers, memory, the ALU, the stack, interrupts, video
hardware, and the C++/Assembly boundary - inside one spacecraft-themed
project, split honestly across the two environments the syllabus actually
targets.

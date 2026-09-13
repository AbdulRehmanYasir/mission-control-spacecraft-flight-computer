# Implementation Roadmap

Building phase-by-phase, per the plan. Each phase ends with a compatibility check
(no 8086/32-bit register mixing, no x64 inline asm, no invented APIs).

- [x] **Phase 1** — Architecture, folder structure, module responsibilities, syllabus mapping (this delivery)
- [ ] **Phase 2** — EMU8086 core: `main.asm` menu skeleton + dashboard text layout
- [ ] **Phase 3** — Registers + addressing modes + ALU: `procedures.asm` (fuel/temp/battery math, register monitor)
- [ ] **Phase 4** — Arrays + loops + sensors: `sensors.asm`
- [ ] **Phase 5** — Stack + procedures: parameter passing, CALL/RET conventions
- [ ] **Phase 6** — Interrupts + exceptions: `interrupts.asm`, `exception_demo.asm`
- [ ] **Phase 7** — Video memory interface: `video_memory.asm`, full dashboard render
- [ ] **Phase 8** — Visual Studio Win32/x86 setup + `MissionControl.cpp`, `SensorEngine.cpp`, `AssemblyCore.cpp` (inline asm)
- [ ] **Phase 9** — MMX engine: `MMXEngine.cpp`
- [ ] **Phase 10** — Assembly library integration: `AssemblyLibrary.asm` + VS project config (MASM build customization)
- [ ] **Phase 11** — Testing: test table + 5 demo scenarios
- [ ] **Phase 12** — Documentation: README, Project_Report, Viva_Questions (40+), Algorithms, Testing

## Folder structure created so far

```
MISSION-CONTROL/
├── docs/
│   ├── Architecture.md         (done)
│   ├── COAL_Syllabus_Mapping.md (done)
│   └── Roadmap.md               (this file)
├── EMU8086/          (empty — Phase 2+)
├── VisualStudio2019/ (empty — Phase 8+)
└── examples/         (empty — populated alongside relevant phases)
```

## How we'll proceed

Tell me to continue and I'll do **Phase 2** next: the EMU8086 `main.asm` menu skeleton
and the text dashboard layout, fully commented, ready to paste into EMU8086. I'll keep
going phase by phase (not all 12 in one dump) so each piece can be reviewed/tested before
the next depends on it — same approach you outlined.

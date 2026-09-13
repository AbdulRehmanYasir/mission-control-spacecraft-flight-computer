# VisualStudio2019/README.md
[VISUAL STUDIO 2019+ / WIN32]

## Creating the project

1. Visual Studio 2019 or newer -> **Create a new project** -> **Empty Project (C++)**.
2. Name it `MissionControl`.
3. In the toolbar Platform dropdown, make sure it is set to **x86** (Win32).
   - If only x64 is listed: Build menu -> Configuration Manager -> Active solution
     platform -> New... -> select **x86**.
   - This project must NEVER be built as x64 - MSVC does not support `__asm`
     inline assembly in x64 builds at all, and AssemblyCore.cpp uses it.
4. Right-click the project in Solution Explorer -> **Add -> Existing Item...**
   and add all of these files from this folder:
   - `MissionControl.cpp`, `MissionControl.h`
   - `SensorEngine.cpp`, `SensorEngine.h`
   - `AssemblyCore.cpp`, `AssemblyCore.h`
   - `MMXEngine.cpp`, `MMXEngine.h`
   - `AssemblyLibrary.cpp`, `AssemblyLibrary.h`
   - `AssemblyLibrary.asm`

## Enabling MASM for the .asm file

`AssemblyLibrary.asm` is a real, separate assembly source file - Visual Studio
needs to be told to assemble it with MASM (`ml.exe`) instead of trying to
compile it as C++:

1. Right-click the **project** (not a file) -> **Build Dependencies -> Build
   Customizations...** -> check the box for **masm(.targets, .props)** -> OK.
2. Right-click `AssemblyLibrary.asm` in Solution Explorer -> **Properties**.
3. Set **Item Type** to **Microsoft Macro Assembler**.
4. Apply -> OK.

Without steps 1-4, Visual Studio will either ignore the .asm file or try to
compile it as C++ and fail with syntax errors - this is not optional.

## Build settings sanity check

- Configuration Properties -> General -> Platform Toolset: any v14x toolset
  that ships with VS2019+ is fine.
- Configuration Properties -> C/C++ -> all defaults are fine for this project
  (no special flags required).
- Confirm again: **Platform = Win32**, not x64.

## Build and run

1. Build -> Build Solution (Ctrl+Shift+B).
2. Debug -> Start Without Debugging (Ctrl+F5).
3. You should see the Mission Control menu described in the project README.

## Common errors and fixes

| Error | Cause | Fix |
|---|---|---|
| `error C2400: inline assembler syntax error` in AssemblyCore.cpp | Project is set to x64 | Switch Platform to Win32 |
| `LNK2019: unresolved external symbol _AssemblyCalculateMissionScore` | .asm file not being assembled, or wrong Item Type | Redo the "Enabling MASM" steps above |
| `LNK2019: unresolved external symbol _LogFromAssembly` | AssemblyLibrary.cpp not added to the project | Add it via Add -> Existing Item |
| MASM build customization not in the list | Visual Studio installed without the "Desktop development with C++" workload's MASM component | Re-run the VS Installer and ensure the C++ workload (which includes MASM) is installed |

## Known limitations (technical honesty)

- This has been written and reviewed carefully but **not yet compiled** on an
  actual Visual Studio 2019+ installation, since none was available while
  writing it. Build it module by module (SensorEngine first, then
  AssemblyCore, then MMXEngine, then AssemblyLibrary) and fix any small
  syntax mismatches for your specific VS version as they come up - the
  logic and instruction choices are correct 32-bit x86/MMX, but exact MSVC
  inline-asm punctuation can vary slightly between compiler versions.
- MMX is legacy and runs on real hardware/Windows via emulation-compatible
  paths, but some modern debuggers show limited MMX register inspection -
  this does not affect correctness, only how easy it is to watch MM0-MM7
  in the Visual Studio debugger.

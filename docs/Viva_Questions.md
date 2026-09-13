# Viva Questions

## 8086 architecture & registers
1. **What are the four general-purpose registers on the 8086, and one typical use of each?**
   AX (accumulator, arithmetic/I-O), BX (base, pointer/base addressing), CX (counter, loop counts), DX (data, I-O/multiply-divide overflow).
2. **What is the difference between AX and AL/AH?**
   AX is the full 16-bit register; AL is its low 8 bits, AH its high 8 bits - they overlap the same physical storage.
3. **What are SI and DI used for?**
   Source Index and Destination Index - typically hold array/string addresses for indexed addressing and string instructions.
4. **What is the difference between SP and BP?**
   SP (Stack Pointer) tracks the top of the stack automatically; BP (Base Pointer) is a general-purpose frame pointer programmers set up manually to address stack parameters/locals.
5. **What does IP hold, and can you access it directly?**
   The Instruction Pointer holds the offset of the next instruction to execute; it cannot be read or written directly with MOV - only indirectly via CALL/RET/JMP.
6. **Name the four segment registers.**
   CS (code), DS (data), SS (stack), ES (extra).

## Flags
7. **What does CF indicate?**
   Carry Flag - set when an arithmetic operation produces a carry out of (or borrow into) the most significant bit.
8. **What does ZF indicate?**
   Zero Flag - set when the result of an operation is exactly zero.
9. **What does SF indicate?**
   Sign Flag - set to the most significant bit of the result (1 = negative in two's-complement).
10. **What does OF indicate, and how does it differ from CF?**
    Overflow Flag - set when a signed arithmetic result doesn't fit in the destination; CF is the equivalent check for UNSIGNED overflow. They can differ on the same instruction.
11. **Why does CMP set flags the same way SUB does?**
    CMP performs a subtraction internally to set the flags but discards the result, leaving the operands unchanged.
12. **Which jump instruction should you use after comparing unsigned values, JA/JB or JG/JL?**
    JA/JB (and JAE/JBE) - they test CF, appropriate for unsigned comparisons. JG/JL test SF/OF, for signed comparisons.

## Segmentation
13. **How is a physical address computed from segment:offset on the 8086?**
    Physical = Segment * 16 + Offset.
14. **Why does the 8086 need segmentation at all?**
    Its registers are 16-bit (max 64KB addressable directly), but its address bus is 20-bit (1MB) - segmentation lets it reach the full 1MB using two 16-bit values together.
15. **Can two different segment:offset pairs point to the same physical address?**
    Yes - segments overlap; e.g. 1000h:0010h and 1001h:0000h both give physical address 10010h.
16. **What does DS:offset addressing depend on?**
    Whatever value is currently loaded in DS - moving a value into DS changes where every subsequent DS-relative memory reference points.

## Addressing modes
17. **What is immediate addressing? Give an example.**
    The operand value itself is encoded in the instruction. Example: `MOV AX, 5`.
18. **What is register indirect addressing? Give an example.**
    A register holds the address of the operand, not the value. Example: `MOV AX, [BX]`.
19. **What is indexed addressing used for in this project?**
    Walking arrays - e.g. `MOV AX, [SI]` then `ADD SI, 2` to step through a word array.
20. **What's the difference between `MOV AX, Value` and `MOV AX, [Value]`?**
    The first loads the address (offset) of Value (with LEA it would be explicit); the second dereferences it and loads the data stored there. (In MASM/TASM, `MOV AX, Value` actually loads the CONTENTS at that label too - `LEA` or `OFFSET` is needed to get the address itself.)

## ALU & data movement
21. **Name three ALU instructions used in this project's telemetry calculations.**
    ADD (fuel/thrust changes), SUB (temperature deltas), MUL/DIV (averages, physical address scaling).
22. **What is the difference between MUL and IMUL?**
    MUL treats operands as unsigned; IMUL treats them as signed.
23. **What happens if you DIV by zero on the 8086?**
    It raises INT 0 (divide error), a real CPU exception - the demo project deliberately triggers this to show exception handling.
24. **Why must DX be cleared (or sign-extended with CWD) before a 16-bit DIV?**
    DIV divides the 32-bit value in DX:AX by the operand; leaving DX with garbage produces a wrong (or invalid) quotient.

## Arrays & loops
25. **What does the LOOP instruction do?**
    Decrements CX and jumps to the target label if CX is not yet zero - a combined "decrement + conditional jump" for counted loops.
26. **Why does this project use CMP+Jcc as well as LOOP in array scanning?**
    LOOP only handles the loop counter; the min/max decision inside each iteration needs its own CMP+Jcc branch.
27. **How do you advance to the next element in a word array using SI?**
    `ADD SI, 2` - each word is 2 bytes.

## Bit manipulation
28. **How do you set bit N of a byte without disturbing other bits?**
    Build a mask with a 1 in position N (`MOV AL,1` then `SHL AL, N`), then `OR` it into the byte.
29. **How do you clear bit N without disturbing other bits?**
    Build the same mask, invert it with NOT, then AND it into the byte.
30. **How do you toggle bit N?**
    XOR the byte with a mask that has a 1 only in position N.
31. **What's the difference between SHL/SHR and SAR?**
    SHL/SHR are logical shifts (fill with 0); SAR is an arithmetic shift that preserves the sign bit when shifting right - important for signed numbers.
32. **What's the difference between ROL and SHL?**
    SHL discards the bit shifted out; ROL feeds it back in at the other end (rotation, no bits lost).

## Stack, procedures, calling conventions
33. **What does PUSH do to SP?**
    Decrements SP by 2 (on 8086, stack grows downward) then stores the value at [SS:SP].
34. **What does CALL actually push onto the stack?**
    The return address (IP, and CS too for a far call) so RET knows where to resume.
35. **Why must PUSHes and POPs be balanced (LIFO) around a procedure call?**
    The stack pointer must return to its original value, or RET will read the wrong return address and crash/misbehave.
36. **How is a stack frame set up with BP, and why?**
    `PUSH BP` / `MOV BP,SP` at procedure entry gives a fixed reference point so parameters and locals can be addressed as `[BP+n]`/`[BP-n]` even while SP moves during the procedure.
37. **In the __cdecl calling convention, who cleans up the stack after a call - caller or callee?**
    The caller.

## Interrupts, IVT, exceptions, PIC
38. **What is the Interrupt Vector Table?**
    A table at physical addresses 0000h-03FFh (256 entries * 4 bytes) holding the CS:IP of each interrupt's handler.
39. **What does IRET do differently from RET?**
    IRET restores IP, CS, AND FLAGS (three items); RET restores only IP (and CS for a far RET).
40. **Why couldn't this project's divide-by-zero handler simply execute IRET?**
    The saved return address for a divide error points back at the faulting DIV itself, so IRET would immediately re-fault; the handler instead discards the saved frame and jumps to a safe recovery label.
41. **What is the PIC and what does EOI mean?**
    The 8259 Programmable Interrupt Controller prioritizes/manages hardware IRQ lines; End-Of-Interrupt is the signal an ISR sends back to the PIC (port 20h) so it will deliver further interrupts.
42. **Why does this project only SIMULATE the hardware interrupt/PIC sequence instead of really hooking it?**
    EMU8086 runs as an emulated DOS program without safe, guaranteed access to the physical 8259 PIC - claiming real IRQ control would be dishonest, so the sequence is shown as clearly-labeled educational text instead.

## Video memory
43. **What segment holds color text-mode video memory, and what does one screen cell consist of?**
    B800h; each cell is 2 bytes - a character byte and an attribute byte (foreground/background color).
44. **How do you compute the offset for row R, column C in text mode?**
    offset = R * 160 + C * 2 (160 = 80 columns * 2 bytes/column).

## 32-bit x86, inline assembly, MMX, C++ integration
45. **Why can't AssemblyCore.cpp's inline assembly be built as x64?**
    MSVC dropped support for `__asm` inline assembly entirely in x64 - only Win32 (x86) builds support it.
46. **What does EMMS do and why is it required after MMX code?**
    Empty MMX State - it marks the FPU/MMX register stack as clean. MMX registers physically alias the x87 FPU registers, so without EMMS, any following floating-point code would see corrupted state.
47. **Why does this project's MMX code only ever process integers, never doubles?**
    MMX registers hold packed INTEGER data; a `double` is an IEEE-754 floating-point value with a completely different bit layout - treating one as the other produces garbage.
48. **What is the practical benefit of MOVQ + PADDW over four separate ADD instructions?**
    Data-level parallelism - one instruction updates four 16-bit values at once instead of four separate instructions.
49. **How does C++ pass an array to an inline `__asm` block in this project?**
    The array's pointer is stored in a register (e.g. `mov esi, arr`), then the assembly dereferences it with `[esi]`, exactly like passing a pointer to any C function.
50. **How does Assembly call back into C++ in this project (AssemblyLibrary.asm)?**
    The C++ function `LogFromAssembly` is declared `extern "C"` (undecorated name, cdecl); the .asm file declares `EXTERN LogFromAssembly:PROC`, pushes its single argument, executes `CALL`, then cleans up the stack itself with `add esp,4` per the cdecl convention.

# Algorithms

## ASCII -> Integer (ReadNumber, EMU8086/input.asm)
- **Purpose**: convert typed decimal digits into a binary integer.
- **Input**: keystrokes terminated by Enter (CR).
- **Output**: AX = the integer value.
- **Steps**: start with accumulator = 0. For each digit typed: subtract '0' to
  get its numeric value (0-9); accumulator = accumulator*10 + digit; repeat
  until CR. Example: "382" -> 0*10+3=3 -> 3*10+8=38 -> 38*10+2=382.
- **Complexity**: O(n) in the number of digits typed.

## Integer -> ASCII (PrintNumber, EMU8086/input.asm)
- **Purpose**: display a binary integer as decimal text.
- **Input**: AX = value (0-65535).
- **Output**: printed decimal digits.
- **Steps**: repeatedly divide AX by 10; each remainder is one decimal digit,
  produced least-significant-first, so each is PUSHed onto the stack as it's
  found. Once AX reaches 0, POP the digits back off (this reverses them into
  correct printing order) and print each with '0' added to make it ASCII.
- **Complexity**: O(log10(n)).

## Sensor array scan: min/max/average (sensors.asm / AssemblyCore.cpp)
- **Purpose**: summarize an 8-sample sensor history.
- **Input**: a word/short array, its length.
- **Output**: minimum, maximum, and integer-truncated average.
- **Steps**: seed min/max/sum with the first element; for each remaining
  element, add it to the running sum, compare against the running min
  (update if smaller) and running max (update if larger); after the loop,
  average = sum / count via DIV/IDIV.
- **Complexity**: O(n), single pass.

## Threshold detection (CheckEngine/CheckOxygen/.../Asm_Check*)
- **Purpose**: decide whether a telemetry value is unsafe.
- **Input**: current value, safety threshold.
- **Output**: the matching status bit is set or cleared.
- **Steps**: CMP value against threshold; a conditional jump (JA/JAE/JBE
  depending on which direction is "unsafe") selects the SetStatusBit or
  ClearStatusBit path.
- **Complexity**: O(1).

## Status-bit set/clear/toggle/test (SetStatusBit family)
- **Purpose**: manipulate one bit of an 8-bit status field without disturbing
  the others.
- **Input**: bit number 0-7.
- **Steps**: build a one-bit mask via `1 SHL bitNumber`; OR to set, AND with
  the inverted mask to clear, XOR to toggle; to test, shift the byte right by
  bitNumber and mask with 1.
- **Complexity**: O(1).

## Logical -> physical address (memory_monitor.asm)
- **Purpose**: demonstrate 8086 segmented addressing.
- **Input**: a segment value and an offset.
- **Output**: a (potentially) 20-bit physical address.
- **Steps**: physical = segment * 16 + offset. Implemented as `MUL` by 16
  (producing a 32-bit DX:AX product) then `ADD`ing the offset into AX with
  `ADC` propagating any carry into DX, since the true result can exceed 16
  bits.
- **Complexity**: O(1).

## Stack-based parameter passing (examples/stack_demo.asm)
- **Purpose**: show a value passed to (and a result returned from) a
  procedure entirely through the stack rather than through a register.
- **Steps**: caller PUSHes the argument, then CALLs; callee sets up a frame
  with `PUSH BP` / `MOV BP,SP`, reads the argument at `[BP+4]` (past the
  saved BP and the CALL-pushed return address), computes a result, and
  overwrites that same stack slot with the result before returning; the
  caller's subsequent POP retrieves it.
- **Complexity**: O(1) - illustrates the mechanism, not a scaling algorithm.

## Divide-by-zero recovery (exception_demo.asm)
- **Purpose**: demonstrate real IVT hooking and recovery from a genuine CPU
  exception (not just displaying text).
- **Steps**: save the current INT 0 vector; install a custom handler at
  IVT entry 0; deliberately execute `DIV` with a zero divisor, which fires
  INT 0 for real; the custom handler prints the exception banner, discards
  the interrupt's saved FLAGS/CS/IP from the stack (since IRET would re-fault
  on the same DIV), and JMPs to a safe recovery label; the original vector is
  restored afterward so the rest of the program/DOS session behaves normally.
- **Complexity**: O(1).

## MMX packed sensor batch processing (MMXEngine.cpp)
- **Purpose**: process 4 packed 16-bit sensor samples per instruction instead
  of one at a time.
- **Steps**: load 4 samples into an MM register with MOVQ; perform one
  PADDW (batch adjustment) or PCMPGTW (batch threshold compare) covering all
  4 lanes simultaneously; store the packed result back with MOVQ; repeat for
  the next group of 4; call EMMS once finished, before any FPU/double code
  runs.
- **Complexity**: O(n/4) MMX instructions instead of O(n) scalar instructions
  for the same n samples (a constant-factor speedup from data-level
  parallelism, not an asymptotic one).

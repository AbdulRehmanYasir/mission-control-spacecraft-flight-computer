// =============================================================
// FILE:        examples/mmx_demo.cpp
// ENVIRONMENT: [VISUAL STUDIO 2019+ / WIN32 x86 ONLY]
// PURPOSE:     Small, self-contained MMX demo you can drop into
//              its own empty Win32 console project (no other
//              project files needed) to show just this concept
//              in a viva: MOVQ, PADDW (packed add), PCMPGTW
//              (packed compare), and EMMS.
// =============================================================
#include <cstdio>

int main() {
    short samples[4] = { 42, 44, 90, 47 };   // 4 packed 16-bit values
    short adjust[4]  = { 2, 2, 2, 2 };
    short threshold[4] = { 47, 47, 47, 47 };
    short mask[4];

    printf("Before: %d %d %d %d\n", samples[0], samples[1], samples[2], samples[3]);

    __asm {
        movq mm0, qword ptr [samples]   ; load all 4 shorts in ONE instruction
        movq mm1, qword ptr [adjust]
        paddw mm0, mm1                  ; 4 parallel 16-bit additions
        movq qword ptr [samples], mm0   ; store all 4 results back at once

        movq mm0, qword ptr [samples]
        movq mm1, qword ptr [threshold]
        pcmpgtw mm0, mm1                ; each lane -> 0xFFFF if sample>47, else 0
        movq qword ptr [mask], mm0

        emms                            ; REQUIRED before any FPU/double code runs
    }

    printf("After +2:  %d %d %d %d\n", samples[0], samples[1], samples[2], samples[3]);
    printf("Exceeds 47 mask: %04X %04X %04X %04X\n",
           (unsigned short)mask[0], (unsigned short)mask[1],
           (unsigned short)mask[2], (unsigned short)mask[3]);

    // Safe to use doubles/FPU here because EMMS already ran above.
    double checkFpuWorks = 3.14159;
    printf("FPU still works after EMMS: %f\n", checkFpuWorks);

    return 0;
}

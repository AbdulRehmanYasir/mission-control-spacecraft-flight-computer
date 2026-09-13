// =============================================================
// FILE:        VisualStudio2019/MMXEngine.cpp
// ENVIRONMENT: [VISUAL STUDIO 2019+ / WIN32 x86 ONLY]
// PURPOSE:     Real MMX instructions (MOVQ / PADDW / PCMPGTW /
//              EMMS) processing packed 16-bit integer sensor
//              samples, 4 lanes at a time.
//
//   Normal (scalar) processing:      MMX (packed) processing:
//     s[0] + adj                       [s0 s1 s2 s3] + [adj adj adj adj]
//     s[1] + adj                                 |
//     s[2] + adj                                 v  (one PADDW instruction)
//     s[3] + adj                       [s0+adj s1+adj s2+adj s3+adj]
//     (4 separate ADDs)
//
// EMMS is executed at the end of every routine - the MMX
// register file physically aliases the x87 FPU stack, so any
// FPU/double-precision code that runs afterward would produce
// garbage results if EMMS were skipped.
// =============================================================
#include "MMXEngine.h"

void MMX_BatchAdjustSamples(short* arr, int count, short adjustment) {
    short adjBroadcast[4] = { adjustment, adjustment, adjustment, adjustment };
    int batches = count / 4;   // caller guarantees count is a multiple of 4

    __asm {
        mov esi, arr
        mov ecx, batches
        movq mm1, qword ptr [adjBroadcast]   ; MM1 = [adj,adj,adj,adj]

    MMX_ADJ_LOOP:
        cmp ecx, 0
        je MMX_ADJ_DONE
        movq mm0, qword ptr [esi]            ; load 4 packed 16-bit samples
        paddw mm0, mm1                       ; 4 parallel 16-bit additions
        movq qword ptr [esi], mm0            ; store the 4 results back
        add esi, 8                           ; advance 4 shorts = 8 bytes
        dec ecx
        jmp MMX_ADJ_LOOP

    MMX_ADJ_DONE:
        emms                                 ; mandatory before FPU/double code
    }
}

void MMX_BatchThresholdCheck(short* arr, int count, short threshold, int* outExceedCount) {
    short threshBroadcast[4] = { threshold, threshold, threshold, threshold };
    short maskResults[64];     // large enough for any realistic sample count
    int batches = count / 4;

    __asm {
        mov esi, arr
        lea edi, maskResults
        mov ecx, batches
        movq mm1, qword ptr [threshBroadcast]

    MMX_CMP_LOOP:
        cmp ecx, 0
        je MMX_CMP_DONE
        movq mm0, qword ptr [esi]
        pcmpgtw mm0, mm1                     ; each lane -> 0xFFFF if sample>threshold, else 0
        movq qword ptr [edi], mm0
        add esi, 8
        add edi, 8
        dec ecx
        jmp MMX_CMP_LOOP

    MMX_CMP_DONE:
        emms
    }

    int exceedCount = 0;
    for (int i = 0; i < count; i++) {
        if (maskResults[i] != 0) exceedCount++;
    }
    *outExceedCount = exceedCount;
}

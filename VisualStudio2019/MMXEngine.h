// =============================================================
// FILE:        VisualStudio2019/MMXEngine.h
// ENVIRONMENT: [VISUAL STUDIO 2019+ / WIN32 x86 ONLY]
// PURPOSE:     Declarations for the MMX packed-integer sensor
//              engine - processes 4 short (16-bit) samples per
//              instruction using MM0-MM7, demonstrating
//              data-level parallelism.
//
// IMPORTANT: MMX here only ever touches packed 16-bit INTEGER
// sensor samples - never IEEE-754 doubles/floats. EMMS is
// executed at the end of every routine before returning, which
// is mandatory before any subsequent x87 floating-point code
// runs (MMX registers alias the FPU's physical register stack).
// =============================================================
#pragma once

// Adds `adjustment` to every sample in arr, 4 samples at a time.
// count MUST be a multiple of 4 (SAMPLE_COUNT = 8 satisfies this).
void MMX_BatchAdjustSamples(short* arr, int count, short adjustment);

// Compares every sample against threshold, 4 at a time, and
// reports how many samples exceeded it.
void MMX_BatchThresholdCheck(short* arr, int count, short threshold, int* outExceedCount);

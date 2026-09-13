// =============================================================
// FILE:        VisualStudio2019/AssemblyLibrary.cpp
// ENVIRONMENT: [VISUAL STUDIO 2019+ / WIN32]
// PURPOSE:     Defines LogFromAssembly, the C++ function that
//              AssemblyLibrary.asm calls into (Assembly -> C++
//              direction). extern "C" linkage keeps the symbol
//              name undecorated (aside from the standard cdecl
//              leading underscore) so the .asm file's
//              "EXTERN LogFromAssembly:PROC" resolves at link time.
// =============================================================
#include <iostream>
#include "AssemblyLibrary.h"

void LogFromAssembly(int code) {
    std::cout << "[C++ CALLBACK] Assembly called back into C++ with value: "
              << code << "\n";
}

if(POLICY CMP0003)
    cmake_policy(SET CMP0003 NEW) # Libraries linked via full path no longer produce linker search paths.
endif()

if(POLICY CMP0022)
    cmake_policy(SET CMP0022 NEW) # INTERFACE_LINK_LIBRARIES defines the link interface.
endif()

if(POLICY CMP0025)
    cmake_policy(SET CMP0025 NEW) # Compiler id for Apple Clang is now AppleClang.
endif()

if(POLICY CMP0042)
    cmake_policy(SET CMP0042 NEW) # MACOSX_RPATH is enabled by default.
endif()

if(POLICY CMP0046)
    cmake_policy(SET CMP0046 NEW) # Error on non-existent dependency in add_dependencies.
endif()

if(POLICY CMP0053)
    cmake_policy(SET CMP0053 NEW) # Simplify variable reference and escape sequence evaluation.
endif()

if(POLICY CMP0068)
    cmake_policy(SET CMP0068 NEW) # RPATH settings on macOS do not affect install_name.
endif()

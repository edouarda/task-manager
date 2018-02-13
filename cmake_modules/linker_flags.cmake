include(add_link_options)

set(CMAKE_EXE_LINKER_FLAGS_SANITIZE    "" CACHE STRING "Flags used by the linker for executables during sanitizer builds." FORCE)
set(CMAKE_MODULE_LINKER_FLAGS_SANITIZE "" CACHE STRING "Flags used by the linker for modules during sanitizer builds." FORCE)
set(CMAKE_SHARED_LINKER_FLAGS_SANITIZE "" CACHE STRING "Flags used by the linker for shared libraries during sanitizer builds." FORCE)
set(CMAKE_STATIC_LINKER_FLAGS_SANITIZE "" CACHE STRING "Flags used by the linker for static libraries during sanitizer builds." FORCE)

if(MSVC)
    add_link_options(WITH_STATIC
        /MACHINE:X64
    )

    add_link_options(
        /NXCOMPAT
        /FUNCTIONPADMIN
        /INCREMENTAL:NO
        /stack:2097152
    )

    add_link_options(CONFIGURATION Debug
        /DEBUG
    )

    add_link_options(CONFIGURATION Release
        /OPT:REF
        /RELEASE
        /DYNAMICBASE
    )

    add_link_options(CONFIGURATION RelWithDebInfo
        /DEBUG
        /PROFILE
        /DYNAMICBASE:NO
        /INCREMENTAL:NO
    )

endif()

if(CLANG)
    if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
        add_link_options(
            -L/usr/local/lib
        )
    endif()

    if(NOT CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
        add_link_options(
            -lc++
            #-lc++abi # We do not need libc++abi on macOS.
        )
    endif()
endif()

if(CLANG AND NOT APPLE)
    add_link_options(
        -Qunused-arguments
        -Wl,--gc-sections
    )
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
    add_link_options(
        # -Wl,-s <-- do not get rid of symbols because we need them to print a decent stacktrace
        -Wl,--gc-sections # remove dead code
    )
endif()

if(APPLE)
    # Prevent ranlib warning
    set(CMAKE_C_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols <TARGET>")
    set(CMAKE_CXX_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols <TARGET>")
endif()

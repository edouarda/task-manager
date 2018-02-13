include(join)

set(COMMON_SANITIZE_FLAGS " -g -fno-omit-frame-pointer -fno-optimize-sibling-calls ")
set(CMAKE_C_FLAGS_SANITIZE "" CACHE STRING "Flags used by the C compiler during sanitizer builds." FORCE)
set(CMAKE_CXX_FLAGS_SANITIZE "" CACHE STRING "Flags used by the C++ compiler during sanitizer builds." FORCE)
set(CMAKE_CXX_FLAGS_SANITIZEVALGRIND "" CACHE STRING "Flags used by the C++ compiler during sanitizer builds using Valgrind." FORCE)

if(WIN32)
    if (CLANG)
        add_compile_options(
            -DBOOST_SP_USE_STD_ATOMIC # HACK for mangling problem in Boost https://llvm.org/bugs/show_bug.cgi?id=25384
            # -Xclang -fms-extensions
            -Xclang -fms-compatibility-version=18
            #-Xclang -Wno-error=inconsistent-dllimport
            -Xclang -Wno-inconsistent-dllimport
            #-Xclang -Wno-error=pedantic
            -Xclang -Wno-pedantic
            -Xclang -Wno-microsoft-enum-value
            #-Xclang -Wno-error=unknown-pragmas
            -Xclang -Wno-unknown-pragmas
            -Xclang -Wno-error=vla-extension
        )
    endif()

    # clang-cl defines _MSC_VER and so MSVC==true
    if(MSVC AND NOT CLANG)
        add_compile_options(
            /bigobj       # increases the number of sections that an object file can contain.
            /MP3          # 3 parallel compilations
            #/permissive-  # set standard-conformance mode
            #/Zc:twoPhase- # turn off two-phase lookup for now, as it's broken on MSVC 2017 Update 3
            /std:c++17
        )
    endif()

    add_compile_options(
        /volatile:iso # use ISO volatile behavior for better performance
        /Gy           # Allows the compiler to package individual functions in the form of packaged functions (COMDATs).
        /Zc:wchar_t   # Parse wchar_t as a built-in type according to the C++ standard
        /EHa          # The exception-handling model that catches both asynchronous (structured) and synchronous (C++) exceptions.
        /GR           # Enable Run-Time Type Information
        /GF           # Eliminate Duplicate Strings

        $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:/Zi> # Produces a program database (PDB) that contains type information and symbolic debugging information for use with the debugger
        $<$<NOT:$<CONFIG:Debug>>:/Ox>  # selects full optimization.
        $<$<NOT:$<CONFIG:Debug>>:/Ob2> # Expands functions marked as inline or __inline and any other function that the compiler chooses
        $<$<NOT:$<CONFIG:Debug>>:/Oi>  # Replaces some function calls with intrinsic or otherwise special forms of the function that help your application run faster.
        $<$<NOT:$<CONFIG:Debug>>:/Ot>  # Maximizes the speed of EXEs and DLLs by instructing the compiler to favor speed over size.
        $<$<NOT:$<CONFIG:Debug>>:/Oy>  # Suppresses creation of frame pointers on the call stack.
        $<$<NOT:$<CONFIG:Debug>>:/GS->  # Suppresses Buffer Security Check
      # Some of our machines don't support AVX, note that by default, SSE2 will be enabled
      #  $<$<NOT:$<CONFIG:Debug>>:/arch:AVX>

        $<$<CONFIG:Debug>:/Ob0>        # Disables inline expansion, which is on by default.
        $<$<CONFIG:Debug>:/Od>         # Turns off all optimizations in the program and speeds compilation.
        $<$<CONFIG:Debug>:/RTC1>       # Enable the run-time error checks feature, in conjunction with the runtime_checks pragma.
        /MT$<$<CONFIG:Debug>:d>        # /MT : Causes the application to use the multithread, static version of the run-time library.
                                       # /MTd: Defines _DEBUG and _MT. This option also causes the compiler to place the library name LIBCMTD.lib into the .obj file so that the linker will use LIBCMTD.lib to resolve external symbols.
    )

    if(NOT CLANG)
        add_compile_options(
            /F2097152    # Sets the program stack size in bytes.
        )
    endif()

    if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS "19")
        add_compile_options(
            /Zc:throwingNew # turn on optimizations due to the conforming new operator
        )
    endif()

endif()

if(CLANG OR CMAKE_COMPILER_IS_GNUCXX)
    set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)
    if (WIN32)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Xclang")
    else()
        add_compile_options(
            -fPIC
        )
    endif()

endif()

if(CLANG)
    if (WIN32)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Xclang -fcxx-exceptions")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++") # tbb will not work under clang with libstdc++
    endif()

    add_compile_options(
        -fcolor-diagnostics # force color output on ninja
        -fmacro-backtrace-limit=0
        $<$<CONFIG:Release>:-O3>
        # already added by CMake:
        #$<$<CONFIG:Debug>:-fno-assume-sane-operator-new>
        #$<$<CONFIG:Debug>:-fno-inline-functions>
        #$<$<CONFIG:Debug>:-fno-omit-frame-pointer>
        #$<$<CONFIG:Debug>:-fno-optimize-sibling-calls>
        #$<$<CONFIG:Debug>:-g>

    )

    if (WIN32)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Xclang -fexceptions")
    else()
        add_compile_options(
            -fexceptions
            -ftemplate-backtrace-limit=0
            -fvisibility-inlines-hidden
            -fvisibility=hidden
        )
    endif()

    if(APPLE)
        set(COMPILE_FLAGS_SANITIZE_FOR_LINKER
            -fsanitize-undefined-trap-on-error
            -fsanitize=alignment,bool,bounds,enum,float-cast-overflow,float-divide-by-zero,integer-divide-by-zero,null,object-size,return,shift,signed-integer-overflow,unreachable,vla-bound,undefined-trap,vla-bound
            #-fsanitize-coverage=edge
        )
    elseif(CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
        set(COMPILE_FLAGS_SANITIZE_FOR_LINKER
            -fsanitize=address,integer
            #-fsanitize-coverage=edge
        )
    endif()
    join(COMPILE_FLAGS_SANITIZE_FOR_LINKER " " ${COMPILE_FLAGS_SANITIZE_FOR_LINKER})
    set(CMAKE_CXX_FLAGS_SANITIZE "${CMAKE_CXX_FLAGS_SANITIZE} ${COMPILE_FLAGS_SANITIZE_FOR_LINKER} -O1 ${COMMON_SANITIZE_FLAGS}")
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
    add_compile_options(
        -fdata-sections
        -ffunction-sections
        -fno-stack-protector
        -fnon-call-exceptions
        -ftrack-macro-expansion=0
        -m64
        $<$<CONFIG:Debug>:-fno-eliminate-unused-debug-types>
        $<$<CONFIG:Debug>:-ggdb>
        $<$<NOT:$<CONFIG:Debug>>:-mfpmath=sse>
    )

    set(COMPILE_FLAGS_SANITIZE_FOR_LINKER
        -fsanitize=address
        -fsanitize=undefined
        # -fsanitize-coverage=edge
    )
endif(CMAKE_COMPILER_IS_GNUCXX)

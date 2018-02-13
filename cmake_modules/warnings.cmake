include(join)

if(MSVC)
    # we get rid of the following warnings as they are most always false positive
    add_compile_options(
        /WX     # Treats all compiler warnings as errors
        /W4
        # Disable warnings:
        /wd4127 # conditional expression is constant
        /wd4244 # 'var': conversion from 'type' to 'type', possible loss of data
        /wd4503 # 'var': decorated name length exceeded, name was truncated
        /wd4505 # unreferenced local function has been removed
        /wd4456 # declaration of 'variable' hides previous local declaration
        /wd4459 # declaration of 'variable' hides global declaration
        /wd4592 # symbol will be dynamically initialized (implementation limitation)
        /wd4316 # object allocated on the heap may not be aligned
        /wd4324 # structure was padded due to alignment specifier
        # Treat the following warnings as errors:
        /we4013 # 'function' undefined; assuming extern returning int
    )
endif()

if(CLANG)
    if(WIN32)
        set(C_CXX_FLAGS
            -Xclang -pedantic
            -Xclang -Wno-language-extension-token
        )
        list(APPEND CMAKE_C_FLAGS ${C_CXX_FLAGS})
        list(APPEND CMAKE_CXX_FLAGS ${C_CXX_FLAGS})
    else()
        add_compile_options(
            -pedantic
        )
    endif()

    add_compile_options(
        -Werror     # Treats all compiler warnings as errors
        -Wall

        -Wconversion
        -Wno-sign-conversion
        -Wno-string-conversion
        -Wno-error=shorten-64-to-32

        -Wno-missing-braces
        -Wmissing-field-initializers

        -Wno-error=char-subscripts # => using char for subscripts can be a problem?
        -Wno-error=delete-non-virtual-dtor # => otherwise we get a lot of error for shared_ptr
        -Wno-error=gnu-zero-variadic-macro-arguments # => RocksDB
        -Wno-nested-anon-types
        -Wno-error=parentheses-equality # => no warning if there are too many parentheses
        -Wno-error=undefined-var-template # instantiation of variable 'var' required here, but no definition is available
        -Wno-error=unknown-warning-option
        -Wno-unused-function
    )

    if(NOT APPLE AND CLANG_35_OR_GREATER)
        add_compile_options(
            -Wno-tautological-undefined-compare # => 'this' can be actually null due to casting
        )
    endif()
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
    add_compile_options(
        -Werror     # Treats all compiler warnings as errors
        -Wall

        -Waddress
        -Warray-bounds
        -Wchar-subscripts
        -Wcomment

        #-Wconversion
        #-Wno-error=sign-conversion # too many warnings

        -Wdouble-promotion
        #-Wduplicated-branches   # GCC 7+
        -Wduplicated-cond       # GCC 6+
        -Wenum-compare
        -Wformat=2
        -Wignored-qualifiers
        -Wlogical-op
        -Wno-missing-braces
        -Wmissing-field-initializers
        -Wmissing-include-dirs
        #-Wnull-dereference      # GCC 6+
        -Wno-error=null-dereference
        #-Wold-style-cast
        -Wparentheses
        -Wrestrict              # GCC 7+
        -Wreturn-type
        -Wsequence-point
        #-Wshadow
        -Wsign-compare
        -Wstrict-aliasing=2
        -Wstrict-overflow=1
        -Wswitch
        -Wtrigraphs
        -Wtype-limits
        -Wuninitialized
        -Wunused-but-set-parameter
        -Wno-unused-function # too many false positives
        -Wunused-label
        -Wvolatile-register-var
    )

    # C++ only warnings
    if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5) # CMake 3.2 accepts does not know VERSION_GREATER_EQUAL
        list(APPEND CMAKE_CXX_FLAGS
            -Wplacement-new
            -Wno-register
            #-Wuseless-cast
        )
    endif()
endif()

join(CMAKE_C_FLAGS " " ${CMAKE_C_FLAGS})
join(CMAKE_CXX_FLAGS " " ${CMAKE_CXX_FLAGS})

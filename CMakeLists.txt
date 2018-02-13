cmake_minimum_required(VERSION 3.4)

project(task_manager)

enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake_modules)
include(policies NO_POLICY_SCOPE)
include(warnings)
include(preprocessor_definitions)
include(compiler_flags)
include(linker_flags)

# don't try to test the compiler
set(CMAKE_CXX_COMPILER_FORCED TRUE)
# for fPIC
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include)

include_directories(SYSTEM
    ${Boost_INCLUDE_DIR})

set(Boost_USE_STATIC_LIBS        ON)
set(Boost_USE_STATIC_RUNTIME     ON)
set(Boost_USE_MULTITHREADED      ON)
set(Boost_ADDITIONAL_VERSIONS "1.66")
find_package(Boost 1.66 REQUIRED COMPONENTS 
    system
    test_exec_monitor
    unit_test_framework)

add_subdirectory(src)
add_subdirectory(test)
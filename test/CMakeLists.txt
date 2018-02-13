add_executable(task_manager_test
    main.cpp

    task_manager_test.cpp
)

target_link_libraries(task_manager_test
    ${Boost_LIBRARIES}
)

add_test(
    NAME task_manager_test
    COMMAND task_manager_test
            --log_level=test_suite
            --report_level=detailed
            --build_info=yes)

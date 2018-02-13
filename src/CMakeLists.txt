
add_library(task_manager STATIC
    scheduler.cpp

    ../include/tsk/scheduler.hpp
    ../include/tsk/task.hpp
    ../include/tsk/thread_pool.hpp
    )

target_link_libraries(task_manager
    boost_system
)

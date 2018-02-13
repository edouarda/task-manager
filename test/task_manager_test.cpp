#include <boost/test/unit_test.hpp>

#include <tsk/scheduler.hpp>

BOOST_AUTO_TEST_CASE(run_simple_task)
{
    volatile bool stop = false;

    tsk::scheduler s{2};

    s.start();

    s.run([&stop]() { stop = true; });

    while (!stop)
    {
        std::this_thread::sleep_for(std::chrono::milliseconds{1});
    }

    s.stop();
}

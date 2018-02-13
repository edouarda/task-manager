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

BOOST_AUTO_TEST_CASE(one_parameter_)
{
    volatile int val = 0;

    tsk::scheduler s{2};

    s.start();

    s.run([&val](int val1, int val2) { val = val1 + val2; }, 31330, 7);

    while (!val)
    {
        std::this_thread::sleep_for(std::chrono::milliseconds{1});
    }

    BOOST_TEST(val == 31337);

    s.stop();
}

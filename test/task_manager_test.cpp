#include <boost/test/unit_test.hpp>

#include <tsk/scheduler.hpp>

struct scheduler_fixture
{
    scheduler_fixture()
    {
        scheduler.start();
    }

    ~scheduler_fixture()
    {
        scheduler.stop();
    }

    template <typename T>
    void wait_for_it(T & var)
    {
        static constexpr size_t max_count = 10'000;

        size_t i = 0;

        for (; !var && (i < max_count); ++i)
        {
            std::this_thread::sleep_for(std::chrono::milliseconds{1});
        }

        BOOST_TEST(i < max_count);
    }

    tsk::scheduler scheduler{2};
};

BOOST_FIXTURE_TEST_CASE(run_simple_task, scheduler_fixture)
{
    volatile bool stop = false;

    scheduler.run([&stop]() { stop = true; });

    wait_for_it(stop);
}

BOOST_FIXTURE_TEST_CASE(one_parameter, scheduler_fixture)
{
    volatile int val = 0;

    scheduler.run([&val](int val1, int val2) { val = val1 + val2; }, 31330, 7);

    wait_for_it(val);

    BOOST_TEST(val == 31337);
}

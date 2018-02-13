#pragma once

#include <thread>

#include <tsk/task.hpp>

namespace tsk
{

template <typename Queue>
class thread_pool
{

public:
    explicit thread_pool(Queue & q, size_t s)
        : _queue{q}
        , _size{s}
    {}

    thread_pool(const thread_pool &) = delete;

public:
    void start()
    {
        if (_run.exchange(true)) return;

        for (size_t i = 0; i < _size; ++i)
        {
            _threads.emplace_back(std::bind(&thread_pool<Queue>::runner, this));
        }
    }

    void stop()
    {
        if (!_run.exchange(false)) return;

        for (auto & t : _threads)
        {
            t.join();
        }

        _threads.clear();
    }

private:
    void runner()
    {
        while (_run)
        {
            tsk::task_ptr to_run = nullptr;

            try
            {
                while (_run && !_queue.pop(to_run))
                {
                    std::this_thread::sleep_for(std::chrono::microseconds{100});
                }

                if (to_run)
                {
                    to_run->run();
                    delete to_run;
                }
            }
            catch (...)
            {
                delete to_run;
            }
        }
    }

private:
    Queue & _queue;
    size_t _size;
    std::atomic<bool> _run{false};
    std::vector<std::thread> _threads;
};

} // namespace tsk

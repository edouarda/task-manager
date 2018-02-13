#pragma once

#include <boost/lockfree/queue.hpp>
#include <tsk/thread_pool.hpp>

namespace tsk
{

class scheduler
{
private:
    using queue_type = boost::lockfree::queue<task_ptr, boost::lockfree::capacity<1024>>;

public:
    explicit scheduler(size_t s)
        : _pool{_queue, s}
    {}

private:
    void empty_queue()
    {
        task_ptr t = nullptr;

        while (_queue.pop(t))
        {
            delete t;
        }
    }

public:
    void start()
    {
        _pool.start();
    }

    void stop()
    {
        _pool.stop();
        empty_queue();
    }

public:
    template <typename Function>
    void run(Function f)
    {
        _queue.push(new task{f});
    }

private:
    queue_type _queue;
    thread_pool<queue_type> _pool;
};

} // namespace tsk

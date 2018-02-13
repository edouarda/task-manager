#pragma once

#include <assert.h>

#include <memory>

namespace tsk
{

class task
{
public:
    using function_type = std::function<void()>;

public:
    explicit task(function_type e)
        : _executor{e}
    {
        assert(_executor);
    }

    template <typename Function>
    task(Function f, void * p)
        : _executor{[f, p]() { f(p); }}
    {}

public:
    void run()
    {
        assert(_executor);
        _executor();
    }

private:
    function_type _executor;
};

using task_ptr = task *;

} // namespace tsk

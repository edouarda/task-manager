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
    template <typename Function, typename... Args>
    explicit task(Function && f, Args &&... args)
        : _executor{[cf = std::forward<Function>(f), cargs = std::make_tuple(std::forward<Args>(args)...)] { std::apply(cf, cargs); }}

    {
        assert(_executor);
    }

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

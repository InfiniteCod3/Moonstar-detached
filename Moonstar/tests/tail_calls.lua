-- tests/tail_calls.lua
-- Tests tail call optimization behavior
-- Critical for VM implementations to handle properly

-- 1. Simple tail call
local function tail_simple(n)
    if n <= 0 then return "done" end
    return tail_simple(n - 1)
end
print("tail_simple(100): " .. tail_simple(100))

-- 2. Tail call with accumulator (tail-recursive factorial)
local function factorial_tail(n, acc)
    acc = acc or 1
    if n <= 1 then return acc end
    return factorial_tail(n - 1, n * acc)
end
print("factorial_tail(10): " .. factorial_tail(10))

-- 3. Mutual tail calls
local function even_tc(n)
    if n == 0 then return true end
    return odd_tc(n - 1)
end

function odd_tc(n)
    if n == 0 then return false end
    return even_tc(n - 1)
end

print("even_tc(100): " .. tostring(even_tc(100)))
print("odd_tc(100): " .. tostring(odd_tc(100)))

-- 4. Non-tail call (for comparison - addition prevents tail call)
local function non_tail(n)
    if n <= 0 then return 0 end
    return 1 + non_tail(n - 1)  -- Not a tail call
end
print("non_tail(50): " .. non_tail(50))

-- 5. Tail call through variable
local function dispatch(action, n)
    if action == "double" then
        if n <= 0 then return 0 end
        return dispatch("double", n - 1)
    elseif action == "triple" then
        if n <= 0 then return 0 end
        return dispatch("triple", n - 1)
    end
    return n
end
print("dispatch double 50: " .. dispatch("double", 50))

-- 6. Tail call with multiple return values
local function multi_return_tail(n, a, b)
    a = a or 0
    b = b or 1
    if n <= 0 then return a, b end
    return multi_return_tail(n - 1, a + 1, b * 2)
end

local x, y = multi_return_tail(10)
print("multi_return_tail(10): " .. x .. ", " .. y)

-- 7. Tail call in conditional
local function conditional_tail(n, path)
    path = path or ""
    if n <= 0 then return path end
    if n % 2 == 0 then
        return conditional_tail(n - 1, path .. "E")
    else
        return conditional_tail(n - 1, path .. "O")
    end
end
print("conditional_tail(10) length: " .. #conditional_tail(10))

-- 8. Tail call with table argument
local function table_tail(t, n)
    if n <= 0 then return t end
    t[#t + 1] = n
    return table_tail(t, n - 1)
end

local result_table = table_tail({}, 10)
print("table_tail result: " .. table.concat(result_table, ","))

-- 9. Tail call with closure
local function make_tail_closure()
    local counter = 0
    local function inner(n)
        counter = counter + 1
        if n <= 0 then return counter end
        return inner(n - 1)
    end
    return inner
end

local tc = make_tail_closure()
print("closure tail(50): " .. tc(50))

-- 10. Tail call vs regular call comparison
local call_depth = 0
local max_depth = 0

local function track_depth_tail(n)
    call_depth = call_depth + 1
    if call_depth > max_depth then max_depth = call_depth end
    if n <= 0 then
        local result = max_depth
        call_depth = call_depth - 1
        return result
    end
    local result = track_depth_tail(n - 1)
    call_depth = call_depth - 1
    return result
end

print("depth tracking(20): " .. track_depth_tail(20))

-- 11. Tail call with varargs
local function vararg_tail(n, ...)
    if n <= 0 then return ... end
    return vararg_tail(n - 1, ...)
end

local a, b, c = vararg_tail(10, 1, 2, 3)
print("vararg_tail: " .. a .. ", " .. b .. ", " .. c)

-- 12. Tail call in pcall (not a true tail call)
local function pcall_wrapped(n)
    if n <= 0 then return "done" end
    local ok, result = pcall(pcall_wrapped, n - 1)
    return result
end
print("pcall_wrapped(10): " .. pcall_wrapped(10))

-- 13. State machine with tail calls
local state_a, state_b, state_c  -- Forward declarations

state_a = function(n, log)
    log = log or ""
    if n <= 0 then return log end
    return state_b(n - 1, log .. "A")
end

state_b = function(n, log)
    if n <= 0 then return log end
    return state_c(n - 1, log .. "B")
end

state_c = function(n, log)
    if n <= 0 then return log end
    return state_a(n - 1, log .. "C")
end

print("state machine(9): " .. state_a(9))

-- 14. Tail call with method syntax
local obj = {}
function obj:process(n, acc)
    acc = acc or 0
    if n <= 0 then return acc end
    return self:process(n - 1, acc + n)
end
print("method tail call: " .. obj:process(10))

-- 15. Fibonacci with tail call (using continuation)
local function fib_tail(n, a, b)
    a = a or 0
    b = b or 1
    if n == 0 then return a end
    if n == 1 then return b end
    return fib_tail(n - 1, b, a + b)
end
print("fib_tail(20): " .. fib_tail(20))
print("fib_tail(30): " .. fib_tail(30))

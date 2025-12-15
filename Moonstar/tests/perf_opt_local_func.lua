-- tests/perf_opt_local_func.lua
-- PERF-OPT #11: Local Function Declaration Optimization Test
-- Tests the optimized local function declaration (skip redundant copy)
--
-- This test verifies that:
-- 1. Local functions work correctly
-- 2. Local functions as non-upvalues work
-- 3. Local functions as upvalues work
-- 4. Multiple local functions in same scope work
-- 5. Recursive local functions work
-- 6. Local functions with captured variables work

-- Test 1: Simple local function
local function simple_add(a, b)
    return a + b
end
print("Test 1 - Simple add: " .. simple_add(3, 4))
assert(simple_add(3, 4) == 7, "Simple add failed")

-- Test 2: Local function with no args
local function no_args()
    return 42
end
print("Test 2 - No args: " .. no_args())
assert(no_args() == 42, "No args failed")

-- Test 3: Multiple local functions
local function func_a()
    return "A"
end

local function func_b()
    return "B"
end

local function func_c()
    return "C"
end

print("Test 3 - Multiple: " .. func_a() .. func_b() .. func_c())
assert(func_a() .. func_b() .. func_c() == "ABC", "Multiple funcs failed")

-- Test 4: Local function calling local function
local function double(n)
    return n * 2
end

local function quadruple(n)
    return double(double(n))
end

print("Test 4 - Quadruple 3: " .. quadruple(3))
assert(quadruple(3) == 12, "Calling local func failed")

-- Test 5: Recursive local function
local function fibonacci(n)
    if n <= 1 then return n end
    return fibonacci(n - 1) + fibonacci(n - 2)
end

print("Test 5 - Fib(10): " .. fibonacci(10))
assert(fibonacci(10) == 55, "Recursive failed")

-- Test 6: Local function with varargs
local function vararg_test(...)
    local sum = 0
    local args = {...}
    for i, v in ipairs(args) do
        sum = sum + v
    end
    return sum
end

print("Test 6 - Varargs: " .. vararg_test(1, 2, 3, 4, 5))
assert(vararg_test(1, 2, 3, 4, 5) == 15, "Varargs failed")

-- Test 7: Local function returned immediately
local function get_adder(n)
    local function adder(x)
        return x + n
    end
    return adder
end

local add_5 = get_adder(5)
print("Test 7 - Add 5 to 10: " .. add_5(10))
assert(add_5(10) == 15, "Returned func failed")

-- Test 8: Local function used as callback
local function with_callback(items, cb)
    local result = {}
    for i, v in ipairs(items) do
        result[i] = cb(v)
    end
    return result
end

local function square(x)
    return x * x
end

local squared = with_callback({1, 2, 3, 4}, square)
print("Test 8 - Squared: " .. squared[1] .. "," .. squared[2] .. "," .. squared[3] .. "," .. squared[4])
assert(squared[4] == 16, "Callback failed")

-- Test 9: Local function in table
local function make_ops()
    local function add(a, b) return a + b end
    local function sub(a, b) return a - b end
    local function mul(a, b) return a * b end
    
    return {
        add = add,
        sub = sub,
        mul = mul
    }
end

local ops = make_ops()
print("Test 9 - Ops add: " .. ops.add(5, 3))
print("Test 9 - Ops mul: " .. ops.mul(5, 3))
assert(ops.add(5, 3) == 8 and ops.mul(5, 3) == 15, "Table ops failed")

-- Test 10: Nested local functions
local function outer_func()
    local function middle()
        local function inner()
            return "inner"
        end
        return inner() .. "_middle"
    end
    return middle() .. "_outer"
end

print("Test 10 - Nested: " .. outer_func())
assert(outer_func() == "inner_middle_outer", "Nested funcs failed")

-- Test 11: Local function with default-like pattern
local function with_default(val)
    local function get_or_default(v)
        return v or "default"
    end
    return get_or_default(val)
end

print("Test 11 - With value: " .. with_default("value"))
print("Test 11 - With nil: " .. with_default(nil))
assert(with_default("test") == "test", "Default pattern failed")
assert(with_default(nil) == "default", "Default nil failed")

-- Test 12: Local function capturing outer local
local function capture_outer()
    local outer_val = 100
    local function get_outer()
        return outer_val
    end
    return get_outer()
end

print("Test 12 - Capture: " .. capture_outer())
assert(capture_outer() == 100, "Capture outer failed")

-- Test 13: Local function as upvalue (should use full closure machinery)
local function upvalue_function()
    local function helper(x)
        return x + 1
    end
    -- helper is captured as upvalue by inner function
    return function(n)
        return helper(n)
    end
end

local use_upval = upvalue_function()
print("Test 13 - Upvalue func: " .. use_upval(5))
assert(use_upval(5) == 6, "Upvalue function failed")

-- Test 14: Mutually recursive local functions
local function mutual_recursion(n)
    -- Forward declaration required for mutual recursion
    local is_odd
    
    local function is_even(x)
        if x == 0 then return true end
        return is_odd(x - 1)
    end
    
    is_odd = function(x)
        if x == 0 then return false end
        return is_even(x - 1)
    end
    
    return is_even(n)
end

print("Test 14 - Is 10 even: " .. tostring(mutual_recursion(10)))
print("Test 14 - Is 7 even: " .. tostring(mutual_recursion(7)))
assert(mutual_recursion(10) == true, "Mutual even failed")
assert(mutual_recursion(7) == false, "Mutual odd failed")

-- Test 15: Local function with many parameters
local function many_params(a, b, c, d, e, f)
    return a + b + c + d + e + f
end

print("Test 15 - Many params: " .. many_params(1, 2, 3, 4, 5, 6))
assert(many_params(1, 2, 3, 4, 5, 6) == 21, "Many params failed")

print("\n=== All local function tests PASSED ===")

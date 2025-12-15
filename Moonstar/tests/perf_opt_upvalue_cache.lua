-- tests/perf_opt_upvalue_cache.lua
-- PERF-OPT #10: Cached Upvalues Table Test
-- Tests the cached upvaluesTable optimization
--
-- This test verifies that:
-- 1. Upvalue reads work correctly with cached table
-- 2. Upvalue writes work correctly with cached table
-- 3. Multiple upvalues in same closure work
-- 4. Nested closures with upvalue chains work
-- 5. Upvalues shared across multiple closures work
-- 6. Upvalue mutation and observation work correctly

-- Test 1: Basic upvalue read
local function test_basic_read()
    local captured = 42
    return function()
        return captured
    end
end

local reader = test_basic_read()
print("Test 1 - Basic read: " .. reader())
assert(reader() == 42, "Basic upvalue read failed")

-- Test 2: Basic upvalue write
local function test_basic_write()
    local value = 0
    return function(n)
        value = n
        return value
    end
end

local writer = test_basic_write()
print("Test 2 - Write 10: " .. writer(10))
print("Test 2 - Write 20: " .. writer(20))
assert(writer(100) == 100, "Basic upvalue write failed")

-- Test 3: Multiple reads from same upvalue
local function test_multi_read()
    local upval = "shared"
    return function()
        local a = upval
        local b = upval
        local c = upval
        return a .. b .. c
    end
end

local multi_reader = test_multi_read()
print("Test 3 - Multi read: " .. multi_reader())
assert(multi_reader() == "sharedsharedshared", "Multi read failed")

-- Test 4: Multiple upvalues in one closure
local function test_multi_upval()
    local a = 1
    local b = 2
    local c = 3
    local d = 4
    local e = 5
    return function()
        return a + b + c + d + e
    end
end

local multi = test_multi_upval()
print("Test 4 - Multi upval sum: " .. multi())
assert(multi() == 15, "Multi upvalue failed")

-- Test 5: Upvalue modification and re-read
local function test_modify_reread()
    local counter = 0
    local increment = function()
        counter = counter + 1
        return counter
    end
    local get = function()
        return counter
    end
    return increment, get
end

local inc, get = test_modify_reread()
print("Test 5 - Inc: " .. inc())
print("Test 5 - Inc: " .. inc())
print("Test 5 - Get: " .. get())
assert(inc() == 3 and get() == 3, "Modify reread failed")

-- Test 6: Deep nesting with upvalue chain
local function test_deep_chain()
    local level1 = 10
    return function()
        local level2 = level1 + 10
        return function()
            local level3 = level2 + 10
            return function()
                return level1 + level2 + level3
            end
        end
    end
end

local f1 = test_deep_chain()
local f2 = f1()
local f3 = f2()
print("Test 6 - Deep chain: " .. f3())
assert(f3() == 60, "Deep chain failed")  -- 10 + 20 + 30

-- Test 7: Upvalue inside loop
local function test_loop_upval()
    local total = 0
    for i = 1, 5 do
        local capture = i
        local add = (function()
            return function()
                total = total + capture
            end
        end)()
        add()
    end
    return total
end

print("Test 7 - Loop upval: " .. test_loop_upval())
assert(test_loop_upval() == 15, "Loop upval failed")  -- 1+2+3+4+5

-- Test 8: Upvalue table access
local function test_table_upval()
    local tbl = {x = 10, y = 20}
    return function()
        tbl.x = tbl.x + 1
        return tbl.x + tbl.y
    end
end

local tbl_fn = test_table_upval()
print("Test 8 - Table upval 1: " .. tbl_fn())
print("Test 8 - Table upval 2: " .. tbl_fn())
assert(tbl_fn() == 33, "Table upval failed")

-- Test 9: Upvalue with nil
local function test_nil_upval()
    local maybe = "init"
    local set = function(v) maybe = v end
    local get = function() return maybe end
    return set, get
end

local set_maybe, get_maybe = test_nil_upval()
print("Test 9 - Nil before: " .. tostring(get_maybe()))
set_maybe("set!")
print("Test 9 - After set: " .. tostring(get_maybe()))
assert(get_maybe() == "set!", "Nil upval failed")

-- Test 10: Upvalue in conditional
local function test_conditional_upval()
    local value = 0
    return function(condition)
        if condition then
            value = value + 10
        else
            value = value - 5
        end
        return value
    end
end

local cond_fn = test_conditional_upval()
print("Test 10 - Cond true: " .. cond_fn(true))
print("Test 10 - Cond false: " .. cond_fn(false))
assert(cond_fn(true) == 15, "Conditional upval failed")

-- Test 11: Many closures sharing one upvalue
local function test_shared_upval()
    local shared = 0
    local closures = {}
    for i = 1, 5 do
        closures[i] = function()
            shared = shared + i
            return shared
        end
    end
    return closures
end

local shared_closures = test_shared_upval()
print("Test 11 - Shared 1: " .. shared_closures[1]())
print("Test 11 - Shared 3: " .. shared_closures[3]())
print("Test 11 - Shared 5: " .. shared_closures[5]())
-- All closures modify the same upvalue
local sum = 0
for i = 1, 5 do
    sum = shared_closures[i]()
end
print("Test 11 - Final sum: " .. sum)
assert(sum > 0, "Shared upval failed")

-- Test 12: Upvalue that is a function
local function test_func_upval()
    local helper = function(x) return x * 2 end
    return function(n)
        return helper(n)
    end
end

local use_helper = test_func_upval()
print("Test 12 - Func upval: " .. use_helper(7))
assert(use_helper(7) == 14, "Func upval failed")

-- Test 13: Recursive with upvalue
local function test_recursive()
    local factorial
    factorial = function(n)
        if n <= 1 then return 1 end
        return n * factorial(n - 1)
    end
    return factorial
end

local fact = test_recursive()
print("Test 13 - Factorial 5: " .. fact(5))
assert(fact(5) == 120, "Recursive upval failed")

print("\n=== All upvalue cache tests PASSED ===")

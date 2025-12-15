-- tests/closures_advanced.lua
-- Advanced closure and upvalue tests

-- 1. Multiple nested closures sharing upvalues
local function create_family()
    local shared_data = 0
    
    local function increment()
        shared_data = shared_data + 1
        return shared_data
    end
    
    local function decrement()
        shared_data = shared_data - 1
        return shared_data
    end
    
    local function get()
        return shared_data
    end
    
    return increment, decrement, get
end

local inc, dec, get = create_family()
print(inc())  -- 1
print(inc())  -- 2
print(dec())  -- 1
print(get())  -- 1
print(inc())  -- 2

-- 2. Closures returned from loops (classic gotcha)
local function create_closures_in_loop()
    local closures = {}
    for i = 1, 5 do
        local captured = i  -- Important: capture in local
        closures[i] = function()
            return captured
        end
    end
    return closures
end

local loop_closures = create_closures_in_loop()
for i = 1, 5 do
    print("closure " .. i .. " returns: " .. loop_closures[i]())
end

-- 3. Deep nesting with upvalue chains
local function deep_nesting()
    local a = 1
    return function()
        local b = a + 1
        return function()
            local c = b + 1
            return function()
                local d = c + 1
                return function()
                    return a + b + c + d  -- 1 + 2 + 3 + 4 = 10
                end
            end
        end
    end
end

local level1 = deep_nesting()
local level2 = level1()
local level3 = level2()
local level4 = level3()
print("deep nesting result: " .. level4())

-- 4. Upvalue mutation across multiple instances
local function create_mutator()
    local value = 0
    return {
        add = function(n) value = value + n; return value end,
        multiply = function(n) value = value * n; return value end,
        get = function() return value end,
        set = function(n) value = n end
    }
end

local m1 = create_mutator()
local m2 = create_mutator()
print("m1 add 5: " .. m1.add(5))
print("m2 add 10: " .. m2.add(10))
print("m1 multiply 2: " .. m1.multiply(2))
print("m2 get: " .. m2.get())
print("m1 get: " .. m1.get())

-- 5. Closure capturing closure
local function closure_capturing_closure()
    local outer_val = "outer"
    
    local inner_closure = function()
        return outer_val
    end
    
    return function()
        return inner_closure() .. " via nested"
    end
end

local nested = closure_capturing_closure()
print(nested())

-- 6. Recursive closure via upvalue
local function make_recursive()
    local recurse
    recurse = function(n)
        if n <= 0 then return 0 end
        return n + recurse(n - 1)
    end
    return recurse
end

local sum_to_n = make_recursive()
print("sum 1 to 10: " .. sum_to_n(10))

-- 7. Upvalue shadowing
local function upvalue_shadowing()
    local x = "outer"
    
    local function inner()
        local x = "inner"  -- shadows outer x
        return function()
            return x  -- should be "inner"
        end
    end
    
    local get_inner = inner()
    return x .. " and " .. get_inner()
end
print(upvalue_shadowing())

-- 8. Closure with multiple upvalues
local function multi_upvalue_closure()
    local a, b, c, d, e = 1, 2, 3, 4, 5
    return function()
        return a + b + c + d + e
    end
end
print("multi upvalue sum: " .. multi_upvalue_closure()())

-- 9. Upvalue used in different scopes
local function scope_test()
    local results = {}
    local shared = 0
    
    do
        local function inner1()
            shared = shared + 1
            return shared
        end
        table.insert(results, inner1())
    end
    
    do
        local function inner2()
            shared = shared + 10
            return shared
        end
        table.insert(results, inner2())
    end
    
    return table.concat(results, ",")
end
print("scope test: " .. scope_test())

-- 10. Closure that modifies upvalue after return
local function delayed_modification()
    local value = "initial"
    local getter = function() return value end
    local setter = function(v) value = v end
    
    return getter, setter
end

local get_val, set_val = delayed_modification()
print("before: " .. get_val())
set_val("modified")
print("after: " .. get_val())

-- 11. Closure in table values
local function closures_in_table()
    local counter = 0
    return {
        handlers = {
            onClick = function() counter = counter + 1; return counter end,
            onHover = function() return counter * 2 end
        },
        getCounter = function() return counter end
    }
end

local obj = closures_in_table()
print("click 1: " .. obj.handlers.onClick())
print("click 2: " .. obj.handlers.onClick())
print("hover: " .. obj.handlers.onHover())
print("counter: " .. obj.getCounter())

-- 12. Upvalue that is a function
local function upvalue_function()
    local helper = function(x) return x * 2 end
    
    return function(n)
        return helper(n) + 1
    end
end

local with_helper = upvalue_function()
print("helper result: " .. with_helper(5))

-- 13. Closure over loop iterator variable (using do block)
local function safe_loop_closures()
    local results = {}
    for i = 1, 3 do
        do
            local j = i
            results[i] = function() return j * j end
        end
    end
    return results[1]() .. "," .. results[2]() .. "," .. results[3]()
end
print("safe loop: " .. safe_loop_closures())

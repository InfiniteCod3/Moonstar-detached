-- tests/environment_fenv.lua
-- Tests getfenv/setfenv interactions with obfuscation
-- Critical for VM-based obfuscators

-- 1. Basic getfenv/setfenv
local function test_basic_env()
    local func = function()
        return foo
    end

    local env = {foo = "bar"}
    setfenv(func, env)

    return func()
end
print("basic env: " .. test_basic_env())

-- 2. getfenv returns correct environment
local function test_getfenv()
    local env = {x = 42}
    local func = function()
        return getfenv()
    end
    setfenv(func, env)
    local returned_env = func()
    return returned_env.x
end
print("getfenv x: " .. test_getfenv())

-- 3. Nested function environment inheritance
local function test_nested_env()
    local outer_func = function()
        local inner_func = function()
            return inner_var
        end
        return inner_func()
    end

    local env = {inner_var = "from_env"}
    setfenv(outer_func, env)

    return outer_func()
end
print("nested env: " .. test_nested_env())

-- 4. Environment with metatable fallback
local function test_env_metatable()
    local base_env = {base_val = 100}
    local custom_env = setmetatable({custom_val = 50}, {__index = base_env})

    local func = function()
        return base_val + custom_val
    end
    setfenv(func, custom_env)

    return func()
end
print("env metatable: " .. test_env_metatable())

-- 5. Modifying environment from within function
local function test_env_modification()
    local env = {counter = 0}

    local func = function()
        local e = getfenv()
        e.counter = e.counter + 1
        return e.counter
    end
    setfenv(func, env)

    local results = {}
    for i = 1, 5 do
        results[i] = func()
    end
    return table.concat(results, ",")
end
print("env modification: " .. test_env_modification())

-- 6. getfenv with level argument
local function test_getfenv_level()
    local function level1()
        local function level2()
            -- getfenv(1) is level2, getfenv(2) is level1
            local env1 = getfenv(1)
            local env2 = getfenv(2)
            return tostring(env1 == env2)
        end
        return level2()
    end
    return level1()
end
print("getfenv level: " .. test_getfenv_level())

-- 7. setfenv with level argument
local function test_setfenv_level()
    local val_from_env = nil

    local function outer()
        local function inner()
            setfenv(2, {captured = "works", print = print, tostring = tostring})
        end
        inner()
        val_from_env = captured
    end

    outer()
    return tostring(val_from_env)
end
print("setfenv level: " .. test_setfenv_level())

-- 8. Environment isolation between functions
local function test_env_isolation()
    local env1 = {shared = "env1"}
    local env2 = {shared = "env2"}

    local func1 = function() return shared end
    local func2 = function() return shared end

    setfenv(func1, env1)
    setfenv(func2, env2)

    return func1() .. "," .. func2()
end
print("env isolation: " .. test_env_isolation())

-- 9. Environment with _G access
local function test_env_global_access()
    local env = setmetatable({local_val = "local"}, {__index = _G})

    local func = function()
        -- Should access local_val from env and print from _G
        return local_val .. "," .. type(print)
    end
    setfenv(func, env)

    return func()
end
print("env global access: " .. test_env_global_access())

-- 10. Rawset/rawget on environment
local function test_env_raw()
    local mt_called = false
    local env = setmetatable({}, {
        __newindex = function(t, k, v)
            mt_called = true
            rawset(t, k, v)
        end
    })

    local func = function()
        rawset(getfenv(), "direct", "value")
        return direct
    end
    setfenv(func, env)

    local result = func()
    return result .. "," .. tostring(mt_called)
end
print("env raw: " .. test_env_raw())

-- 11. Environment chaining
local function test_env_chain()
    local env3 = {level = "three"}
    local env2 = setmetatable({}, {__index = env3})
    local env1 = setmetatable({}, {__index = env2})

    local func = function()
        return level
    end
    setfenv(func, env1)

    return func()
end
print("env chain: " .. test_env_chain())

-- 12. Function returning new function with different env
local function test_factory_env()
    local function factory(name)
        local env = {name = name, tostring = tostring}
        local inner = function()
            return name
        end
        setfenv(inner, env)
        return inner
    end

    local f1 = factory("Alice")
    local f2 = factory("Bob")

    return f1() .. "," .. f2()
end
print("factory env: " .. test_factory_env())

-- 13. getfenv(0) returns global environment
local function test_getfenv_zero()
    local global_env = getfenv(0)
    return tostring(type(global_env) == "table")
end
print("getfenv(0): " .. test_getfenv_zero())

-- 14. setfenv returns the function
local function test_setfenv_return()
    local func = function() return "test" end
    local returned = setfenv(func, {})
    return tostring(func == returned)
end
print("setfenv return: " .. test_setfenv_return())

-- 15. Closure upvalues vs environment
local function test_upvalue_vs_env()
    local upvalue = "from_upvalue"

    local func = function()
        return upvalue  -- Should use upvalue, not environment
    end

    local env = {upvalue = "from_env"}
    setfenv(func, env)

    return func()
end
print("upvalue vs env: " .. test_upvalue_vs_env())

-- tests/global_metatable.lua
-- Tests _G with metatables, critical for GlobalVirtualization
-- Verifies that obfuscation handles metatable-driven globals correctly

-- 1. Basic __index on _G
local original_G_mt = getmetatable(_G)
local access_log = {}

local proxy_mt = {
    __index = function(t, k)
        access_log[#access_log + 1] = "get:" .. tostring(k)
        return rawget(t, k)
    end,
    __newindex = function(t, k, v)
        access_log[#access_log + 1] = "set:" .. tostring(k)
        rawset(t, k, v)
    end
}

-- Save important functions before setting metatable
local saved_print = print
local saved_tostring = tostring
local saved_type = type
local saved_table = table
local saved_rawget = rawget
local saved_rawset = rawset
local saved_setmetatable = setmetatable
local saved_getmetatable = getmetatable

setmetatable(_G, proxy_mt)

-- 2. Test that accessing undefined globals triggers __index
local undefined_result = some_undefined_global
saved_print("undefined access logged: " .. saved_tostring(#access_log > 0))

-- 3. Test setting new globals triggers __newindex
new_test_global = 42
saved_print("new global set: " .. saved_tostring(new_test_global == 42))

-- 4. Clear log and test function
access_log = {}

local function test_global_access()
    local x = new_test_global
    return x
end

local result = test_global_access()
saved_print("function global access: " .. saved_tostring(result))

-- 5. Fallback chain
local fallback_values = {fallback_key = "fallback_value"}
local chain_mt = {
    __index = function(t, k)
        local fb = fallback_values[k]
        if fb then return fb end
        return saved_rawget(t, k)
    end
}
saved_setmetatable(_G, chain_mt)

saved_print("fallback key: " .. saved_tostring(fallback_key))

-- 6. __newindex that transforms values
local transform_mt = {
    __newindex = function(t, k, v)
        if saved_type(v) == "number" then
            saved_rawset(t, k, v * 2)
        else
            saved_rawset(t, k, v)
        end
    end,
    __index = function(t, k)
        return saved_rawget(t, k)
    end
}
saved_setmetatable(_G, transform_mt)

transformed_number = 50
saved_print("transformed number: " .. saved_tostring(transformed_number))

-- 7. Readonly globals simulation
local readonly_mt = {
    __newindex = function(t, k, v)
        if k == "READONLY_VAR" then
            -- Silently ignore
            return
        end
        saved_rawset(t, k, v)
    end,
    __index = function(t, k)
        return saved_rawget(t, k)
    end
}
saved_rawset(_G, "READONLY_VAR", "initial")
saved_setmetatable(_G, readonly_mt)

READONLY_VAR = "attempted_change"
saved_print("readonly preserved: " .. saved_tostring(READONLY_VAR == "initial"))

-- 8. Default value provider
local default_mt = {
    __index = function(t, k)
        if k:match("^default_") then
            return "default_value"
        end
        return saved_rawget(t, k)
    end
}
saved_setmetatable(_G, default_mt)

saved_print("default_foo: " .. saved_tostring(default_foo))
saved_print("default_bar: " .. saved_tostring(default_bar))

-- 9. Counting access
local access_count = {}
local counting_mt = {
    __index = function(t, k)
        access_count[k] = (access_count[k] or 0) + 1
        return saved_rawget(t, k)
    end
}
saved_setmetatable(_G, counting_mt)

saved_rawset(_G, "counted_var", 123)
local _ = counted_var
local _ = counted_var
local _ = counted_var
saved_print("counted_var accesses: " .. saved_tostring(access_count["counted_var"]))

-- 10. Lazy initialization
local lazy_mt = {
    __index = function(t, k)
        if k == "lazy_computed" then
            local value = 100 + 200  -- Simulated expensive computation
            saved_rawset(t, k, value)
            return value
        end
        return saved_rawget(t, k)
    end
}
saved_setmetatable(_G, lazy_mt)

saved_print("lazy first access: " .. saved_tostring(lazy_computed))
saved_print("lazy second access: " .. saved_tostring(lazy_computed))

-- 11. Namespace isolation
local namespace = {
    module_var = "from_namespace"
}
local namespace_mt = {
    __index = function(t, k)
        local ns_val = namespace[k]
        if ns_val then return ns_val end
        return saved_rawget(t, k)
    end
}
saved_setmetatable(_G, namespace_mt)

saved_print("namespace var: " .. saved_tostring(module_var))

-- 12. Restore original metatable
saved_setmetatable(_G, original_G_mt)
saved_print("restored metatable: " .. saved_tostring(saved_getmetatable(_G) == original_G_mt))

-- Cleanup test globals
_G.new_test_global = nil
_G.transformed_number = nil
_G.READONLY_VAR = nil
_G.counted_var = nil
_G.lazy_computed = nil
_G.some_undefined_global = nil

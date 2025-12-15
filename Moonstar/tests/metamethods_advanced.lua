-- tests/metamethods_advanced.lua
-- Advanced metatable tests for global virtualization

-- 1. __len metamethod
local len_mt = {
    __len = function(t)
        local count = 0
        for _ in pairs(t.data) do count = count + 1 end
        return count
    end
}
local len_test = setmetatable({data = {a=1, b=2, c=3}}, len_mt)
print("custom len: " .. #len_test)

-- 2. __eq metamethod
local eq_mt = {
    __eq = function(a, b)
        return a.value == b.value
    end
}
local eq1 = setmetatable({value = 42}, eq_mt)
local eq2 = setmetatable({value = 42}, eq_mt)
local eq3 = setmetatable({value = 99}, eq_mt)
print("eq1 == eq2: " .. tostring(eq1 == eq2))
print("eq1 == eq3: " .. tostring(eq1 == eq3))

-- 3. __lt and __le metamethods
local compare_mt = {
    __lt = function(a, b)
        return a.value < b.value
    end,
    __le = function(a, b)
        return a.value <= b.value
    end
}
local cmp1 = setmetatable({value = 10}, compare_mt)
local cmp2 = setmetatable({value = 20}, compare_mt)
local cmp3 = setmetatable({value = 10}, compare_mt)
print("cmp1 < cmp2: " .. tostring(cmp1 < cmp2))
print("cmp2 < cmp1: " .. tostring(cmp2 < cmp1))
print("cmp1 <= cmp3: " .. tostring(cmp1 <= cmp3))

-- 4. __concat metamethod
local concat_mt = {
    __concat = function(a, b)
        local av = type(a) == "table" and a.value or a
        local bv = type(b) == "table" and b.value or b
        return setmetatable({value = av .. bv}, concat_mt)
    end,
    __tostring = function(t)
        return "Concat(" .. t.value .. ")"
    end
}
local cat1 = setmetatable({value = "Hello"}, concat_mt)
local cat2 = setmetatable({value = "World"}, concat_mt)
local cat3 = cat1 .. " " .. cat2
print("concat result: " .. tostring(cat3))

-- 5. __unm (unary minus) metamethod
local unm_mt = {
    __unm = function(t)
        return setmetatable({value = -t.value}, unm_mt)
    end
}
local unm_test = setmetatable({value = 42}, unm_mt)
local neg = -unm_test
print("unary minus: " .. neg.value)

-- 6. __sub, __mul, __div, __mod, __pow
local math_mt = {}
math_mt.__sub = function(a, b) return setmetatable({value = a.value - b.value}, math_mt) end
math_mt.__mul = function(a, b) return setmetatable({value = a.value * b.value}, math_mt) end
math_mt.__div = function(a, b) return setmetatable({value = a.value / b.value}, math_mt) end
math_mt.__mod = function(a, b) return setmetatable({value = a.value % b.value}, math_mt) end
math_mt.__pow = function(a, b) return setmetatable({value = a.value ^ b.value}, math_mt) end

local m1 = setmetatable({value = 10}, math_mt)
local m2 = setmetatable({value = 3}, math_mt)
print("sub: " .. (m1 - m2).value)
print("mul: " .. (m1 * m2).value)
print("div: " .. (m1 / m2).value)
print("mod: " .. (m1 % m2).value)
print("pow: " .. (m1 ^ m2).value)

-- 7. Metatable inheritance chain
local base_mt = {
    __index = function(t, k)
        return "base_" .. k
    end
}
local derived_mt = {
    __index = setmetatable({
        specific = "derived_specific"
    }, base_mt)
}
local inherited = setmetatable({}, derived_mt)
print("inherited.specific: " .. inherited.specific)
print("inherited.unknown: " .. inherited.unknown)

-- 8. __index as function with upvalue
local function create_indexed()
    local backing = {x = 100, y = 200}
    local access_count = 0
    
    return setmetatable({}, {
        __index = function(t, k)
            access_count = access_count + 1
            return backing[k]
        end
    }), function() return access_count end
end

local indexed, get_count = create_indexed()
print("indexed.x: " .. tostring(indexed.x))
print("indexed.y: " .. tostring(indexed.y))
print("indexed.z: " .. tostring(indexed.z))
print("access count: " .. get_count())

-- 9. __newindex with validation
local validated = setmetatable({_data = {}}, {
    __newindex = function(t, k, v)
        if type(v) ~= "number" then
            error("Only numbers allowed")
        end
        rawset(t._data, k, v)
    end,
    __index = function(t, k)
        return rawget(t._data, k)
    end
})
validated.a = 10
validated.b = 20
print("validated.a: " .. validated.a)
print("validated.b: " .. validated.b)
local ok = pcall(function() validated.c = "string" end)
print("string assignment blocked: " .. tostring(not ok))

-- 10. rawequal, rawget, rawset
local raw_mt = {
    __eq = function() return true end,
    __index = function() return "metatable" end,
    __newindex = function() end
}
local raw1 = setmetatable({actual = "value1"}, raw_mt)
local raw2 = setmetatable({actual = "value2"}, raw_mt)

print("raw1 == raw2: " .. tostring(raw1 == raw2))  -- true via __eq
print("rawequal: " .. tostring(rawequal(raw1, raw2)))  -- false
print("raw1.missing: " .. raw1.missing)  -- "metatable" via __index
print("rawget actual: " .. rawget(raw1, "actual"))  -- "value1"
rawset(raw1, "new", "rawset value")
print("rawget new: " .. rawget(raw1, "new"))

-- 11. getmetatable / setmetatable
local meta_obj = {}
local my_mt = {secret = "hidden", __metatable = "protected"}
setmetatable(meta_obj, my_mt)
print("getmetatable: " .. tostring(getmetatable(meta_obj)))

-- 12. Weak tables
local weak_keys = setmetatable({}, {__mode = "k"})
local weak_values = setmetatable({}, {__mode = "v"})
local weak_both = setmetatable({}, {__mode = "kv"})

local key = {name = "key"}
local value = {name = "value"}
weak_keys[key] = "test"
weak_values["test"] = value

print("weak_keys[key]: " .. weak_keys[key])
print("weak_values['test']: " .. weak_values["test"].name)

-- 13. Multiple metamethods on same table
local multi_mt = {
    __add = function(a, b) return a.v + b.v end,
    __sub = function(a, b) return a.v - b.v end,
    __tostring = function(t) return "Multi(" .. t.v .. ")" end,
    __call = function(t, x) return t.v * x end
}
local multi = setmetatable({v = 5}, multi_mt)
local multi2 = setmetatable({v = 3}, multi_mt)
print("multi add: " .. (multi + multi2))
print("multi sub: " .. (multi - multi2))
print("multi tostring: " .. tostring(multi))
print("multi call: " .. multi(10))

-- 14. Chained indexing through metatables
local chain1 = {a = 1}
local chain2 = setmetatable({b = 2}, {__index = chain1})
local chain3 = setmetatable({c = 3}, {__index = chain2})
print("chain3.a: " .. chain3.a)
print("chain3.b: " .. chain3.b)
print("chain3.c: " .. chain3.c)

-- 15. Metamethod that returns nil explicitly
local nil_mt = {
    __index = function(t, k)
        if k == "exists" then return "value" end
        return nil
    end
}
local nil_test = setmetatable({}, nil_mt)
print("nil_test.exists: " .. tostring(nil_test.exists))
print("nil_test.missing: " .. tostring(nil_test.missing))

-- 16. Self-referential metatable
local self_mt = {}
self_mt.__index = self_mt
self_mt.method = function(self) return "method called on " .. tostring(self.name) end
local self_obj = setmetatable({name = "test"}, self_mt)
print("self method: " .. self_obj:method())

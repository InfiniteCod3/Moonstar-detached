-- tests/tables_advanced.lua
-- Advanced table tests for constant array and general table handling

-- 1. Sparse arrays with holes
local sparse = {}
sparse[1] = "one"
sparse[3] = "three"
sparse[5] = "five"
sparse[10] = "ten"

print("sparse[1]: " .. tostring(sparse[1]))
print("sparse[2]: " .. tostring(sparse[2]))
print("sparse[3]: " .. tostring(sparse[3]))
print("sparse #: " .. #sparse)  -- undefined behavior, but should be consistent

-- 2. Mixed numeric/string keys
local mixed = {
    [1] = "numeric one",
    ["1"] = "string one",
    foo = "foo value",
    [2.5] = "float key",
    [true] = "bool key"
}
print("mixed[1]: " .. mixed[1])
print("mixed['1']: " .. mixed["1"])
print("mixed.foo: " .. mixed.foo)
print("mixed[2.5]: " .. mixed[2.5])
print("mixed[true]: " .. mixed[true])

-- 3. table.insert/remove in loops
local list = {1, 2, 3, 4, 5}
local removed = {}
for i = #list, 1, -1 do
    if list[i] % 2 == 0 then
        table.insert(removed, table.remove(list, i))
    end
end
print("remaining: " .. table.concat(list, ","))
print("removed: " .. table.concat(removed, ","))

-- 4. table.concat variations
local concat_test = {"a", "b", "c", "d", "e"}
print("concat all: " .. table.concat(concat_test))
print("concat comma: " .. table.concat(concat_test, ","))
print("concat range: " .. table.concat(concat_test, "-", 2, 4))

-- 5. Self-referencing tables
local self_ref = {value = 42}
self_ref.self = self_ref
print("self ref value: " .. self_ref.self.self.self.value)

-- 6. Table as key
local table_key = {}
local key1 = {name = "key1"}
local key2 = {name = "key2"}
table_key[key1] = "value1"
table_key[key2] = "value2"
print("table key 1: " .. table_key[key1])
print("table key 2: " .. table_key[key2])

-- 7. Deep nesting
local deep = {
    level1 = {
        level2 = {
            level3 = {
                level4 = {
                    level5 = {
                        value = "deep value"
                    }
                }
            }
        }
    }
}
print("deep value: " .. deep.level1.level2.level3.level4.level5.value)

-- 8. Array-like operations
local arr = {}
for i = 1, 10 do
    arr[#arr + 1] = i * i
end
print("arr sum: " .. (function()
    local sum = 0
    for _, v in ipairs(arr) do sum = sum + v end
    return sum
end)())

-- 9. Table with function values
local func_table = {
    add = function(a, b) return a + b end,
    mul = function(a, b) return a * b end
}
print("func add: " .. func_table.add(3, 4))
print("func mul: " .. func_table.mul(3, 4))

-- 10. next() iteration
local next_test = {a = 1, b = 2, c = 3}
local keys = {}
local k = nil
repeat
    k = next(next_test, k)
    if k then table.insert(keys, k) end
until k == nil
table.sort(keys)
print("next keys: " .. table.concat(keys, ","))

-- 11. rawget/rawset
local raw_test = setmetatable({}, {
    __index = function() return "metatable" end,
    __newindex = function() error("blocked") end
})
rawset(raw_test, "key", "raw value")
print("rawget: " .. rawget(raw_test, "key"))
print("normal get missing: " .. raw_test.missing)

-- 12. Table cloning (shallow)
local original = {1, 2, 3, nested = {a = 1}}
local clone = {}
for k, v in pairs(original) do
    clone[k] = v
end
original[1] = 999
original.nested.a = 999
print("clone[1]: " .. clone[1])  -- should be 1
print("clone.nested.a: " .. clone.nested.a)  -- shared, so 999

-- 13. Table with nil gaps via explicit assignment
local nil_gaps = {1, 2, 3}
nil_gaps[2] = nil
print("nil_gaps[1]: " .. tostring(nil_gaps[1]))
print("nil_gaps[2]: " .. tostring(nil_gaps[2]))
print("nil_gaps[3]: " .. tostring(nil_gaps[3]))

-- 14. Large table
local large = {}
for i = 1, 1000 do
    large[i] = i
end
print("large[1]: " .. large[1])
print("large[500]: " .. large[500])
print("large[1000]: " .. large[1000])
print("large count: " .. #large)

-- 15. Table modification during pairs iteration (safe pattern)
local modify_test = {a = 1, b = 2, c = 3}
local to_remove = {}
for k, v in pairs(modify_test) do
    if v == 2 then
        table.insert(to_remove, k)
    end
end
for _, k in ipairs(to_remove) do
    modify_test[k] = nil
end
local remaining = {}
for k in pairs(modify_test) do
    table.insert(remaining, k)
end
table.sort(remaining)
print("after removal: " .. table.concat(remaining, ","))

-- 16. Numeric keys around boundary
local boundary = {}
boundary[0] = "zero"  -- 0 is valid but not part of array
boundary[1] = "one"
boundary[-1] = "negative"
print("boundary[0]: " .. boundary[0])
print("boundary[1]: " .. boundary[1])
print("boundary[-1]: " .. boundary[-1])

-- 17. String that looks like number as key
local string_num = {}
string_num["123"] = "string key"
string_num[123] = "number key"
print("string_num['123']: " .. string_num["123"])
print("string_num[123]: " .. string_num[123])

-- 18. Table equality
local t1 = {1, 2, 3}
local t2 = {1, 2, 3}
local t3 = t1
print("t1 == t2: " .. tostring(t1 == t2))  -- false, different tables
print("t1 == t3: " .. tostring(t1 == t3))  -- true, same reference

-- 19. Empty table operations
local empty = {}
print("empty #: " .. #empty)
print("empty next: " .. tostring(next(empty)))
for k, v in pairs(empty) do
    print("should not print")
end
print("empty iteration complete")

-- 20. unpack (table.unpack in 5.2+)
local unpack_test = {10, 20, 30, 40, 50}
local a, b, c = unpack(unpack_test)
print("unpack: " .. a .. "," .. b .. "," .. c)
local d, e = unpack(unpack_test, 2, 3)
print("unpack range: " .. d .. "," .. e)

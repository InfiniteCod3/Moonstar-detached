-- Benchmark: Metamethods
-- Tests metatable and metamethod overhead

local ITERATIONS = 50000

local function index_bench()
    local backing = { a = 1, b = 2, c = 3 }
    local mt = {
        __index = function(t, k)
            return backing[k] or 0
        end
    }
    local proxy = setmetatable({}, mt)
    local sum = 0
    for _ = 1, ITERATIONS do
        sum = sum + proxy.a + proxy.b + proxy.c + proxy.d
    end
    return sum
end

local function newindex_bench()
    local writes = 0
    local mt = {
        __newindex = function(t, k, v)
            writes = writes + 1
            rawset(t, k, v)
        end
    }
    local t = setmetatable({}, mt)
    for i = 1, ITERATIONS do
        t["key_" .. (i % 100)] = i
    end
    return writes
end

local function arithmetic_meta_bench()
    local mt = {
        __add = function(a, b) return setmetatable({ v = a.v + b.v }, mt) end,
        __sub = function(a, b) return setmetatable({ v = a.v - b.v }, mt) end,
        __mul = function(a, b) return setmetatable({ v = a.v * b.v }, mt) end
    }
    local function num(x)
        return setmetatable({ v = x }, mt)
    end
    local result = num(0)
    for i = 1, ITERATIONS do
        result = result + num(i) - num(1)
    end
    return result.v
end

local function call_meta_bench()
    local mt = {
        __call = function(self, x)
            return self.base + x
        end
    }
    local callable = setmetatable({ base = 10 }, mt)
    local sum = 0
    for i = 1, ITERATIONS do
        sum = sum + callable(i)
    end
    return sum
end

local function tostring_meta_bench()
    local mt = {
        __tostring = function(self)
            return "obj:" .. self.id
        end
    }
    local result = ""
    for i = 1, 1000 do
        local obj = setmetatable({ id = i }, mt)
        result = tostring(obj)
    end
    return #result
end

local start = os.clock()
local index_result = index_bench()
local newindex_result = newindex_bench()
local arith_result = arithmetic_meta_bench()
local call_result = call_meta_bench()
local tostring_result = tostring_meta_bench()
local elapsed = os.clock() - start

print("index:", index_result)
print("newindex:", newindex_result)
print("arithmetic:", arith_result)
print("call:", call_result)
print("tostring:", tostring_result)
print(string.format("elapsed: %.4f", elapsed))

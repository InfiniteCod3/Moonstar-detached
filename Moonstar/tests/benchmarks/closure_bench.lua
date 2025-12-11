-- Benchmark: Closures and Upvalues
-- Tests closure creation and upvalue access performance

local ITERATIONS = 50000

local function make_counter()
    local count = 0
    return function()
        count = count + 1
        return count
    end
end

local function make_adder(x)
    return function(y)
        return x + y
    end
end

local function nested_closures(depth)
    local value = 0
    local function nest(d)
        if d <= 0 then
            return function() return value end
        end
        value = value + d
        return nest(d - 1)
    end
    return nest(depth)()
end

local function closure_chain_bench()
    local result = 0
    local function outer(x)
        local function middle(y)
            local function inner(z)
                return x + y + z
            end
            return inner
        end
        return middle
    end
    for i = 1, ITERATIONS do
        result = result + outer(i)(i)(i)
    end
    return result
end

local function multi_upvalue_bench()
    local a, b, c, d, e = 1, 2, 3, 4, 5
    local sum = 0
    local function access_all()
        return a + b + c + d + e
    end
    for _ = 1, ITERATIONS do
        sum = sum + access_all()
    end
    return sum
end

local start = os.clock()

local counter = make_counter()
for _ = 1, ITERATIONS do counter() end
local counter_result = counter()

local adders = {}
for i = 1, 100 do
    adders[i] = make_adder(i)
end
local adder_sum = 0
for i = 1, 100 do
    adder_sum = adder_sum + adders[i](i)
end

local nested_result = nested_closures(10)
local chain_result = closure_chain_bench()
local upvalue_result = multi_upvalue_bench()
local elapsed = os.clock() - start

print("counter:", counter_result)
print("adder_sum:", adder_sum)
print("nested:", nested_result)
print("chain:", chain_result)
print("upvalue:", upvalue_result)
print(string.format("elapsed: %.4f", elapsed))

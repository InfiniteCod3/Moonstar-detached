-- Benchmark: Iterators
-- Tests iterator patterns and generic for loop performance

local SIZE = 10000

local function pairs_bench()
    local t = {}
    for i = 1, SIZE do t["k" .. i] = i end
    local sum = 0
    for k, v in pairs(t) do
        sum = sum + v
    end
    return sum
end

local function ipairs_bench()
    local t = {}
    for i = 1, SIZE do t[i] = i end
    local sum = 0
    for i, v in ipairs(t) do
        sum = sum + v
    end
    return sum
end

local function numeric_for_bench()
    local t = {}
    for i = 1, SIZE do t[i] = i end
    local sum = 0
    for i = 1, #t do
        sum = sum + t[i]
    end
    return sum
end

local function custom_iterator()
    return function(t, index)
        index = index + 1
        if index <= #t then
            return index, t[index]
        end
    end, nil, 0
end

local function custom_iter_bench()
    local t = {}
    for i = 1, SIZE do t[i] = i end
    local sum = 0
    for i, v in custom_iterator(), t, 0 do
        sum = sum + v
    end
    return sum
end

local function stateful_iterator_bench()
    local function counter(limit)
        local i = 0
        return function()
            i = i + 1
            if i <= limit then
                return i, i * 2
            end
        end
    end
    local sum = 0
    for index, value in counter(SIZE) do
        sum = sum + value
    end
    return sum
end

local function nested_iteration_bench()
    local outer = {}
    for i = 1, 100 do
        outer[i] = {}
        for j = 1, 100 do
            outer[i][j] = i * j
        end
    end
    local sum = 0
    for i, row in ipairs(outer) do
        for j, val in ipairs(row) do
            sum = sum + val
        end
    end
    return sum
end

local start = os.clock()
local pairs_result = pairs_bench()
local ipairs_result = ipairs_bench()
local numeric_result = numeric_for_bench()
local custom_result = custom_iter_bench()
local stateful_result = stateful_iterator_bench()
local nested_result = nested_iteration_bench()
local elapsed = os.clock() - start

print("pairs:", pairs_result)
print("ipairs:", ipairs_result)
print("numeric:", numeric_result)
print("custom:", custom_result)
print("stateful:", stateful_result)
print("nested:", nested_result)
print(string.format("elapsed: %.4f", elapsed))

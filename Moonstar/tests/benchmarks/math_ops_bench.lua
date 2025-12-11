-- Benchmark: Math Operations
-- Tests mathematical function call overhead and arithmetic

local ITERATIONS = 50000

local function basic_arithmetic_bench()
    local sum = 0
    for i = 1, ITERATIONS do
        local x = i * 17
        x = x + 31
        x = x - 7
        x = x / 3
        x = x % 100
        sum = sum + x
    end
    return math.floor(sum)
end

local function math_functions_bench()
    local sum = 0
    for i = 1, ITERATIONS do
        local x = i / 100
        sum = sum + math.sin(x)
        sum = sum + math.cos(x)
        sum = sum + math.abs(x - 0.5)
    end
    return math.floor(sum)
end

local function power_bench()
    local sum = 0
    for i = 1, ITERATIONS do
        sum = sum + math.pow(i % 10 + 1, 2)
        sum = sum + math.sqrt(i)
    end
    return math.floor(sum)
end

local function floor_ceil_bench()
    local sum = 0
    for i = 1, ITERATIONS do
        local x = i / 7
        sum = sum + math.floor(x)
        sum = sum + math.ceil(x)
    end
    return sum
end

local function minmax_bench()
    local sum = 0
    for i = 1, ITERATIONS do
        sum = sum + math.min(i, ITERATIONS - i)
        sum = sum + math.max(i % 100, 50)
    end
    return sum
end

local function random_bench()
    math.randomseed(12345)
    local sum = 0
    for _ = 1, ITERATIONS do
        sum = sum + math.random(1, 100)
    end
    return sum
end

local function exp_log_bench()
    local sum = 0
    for i = 1, ITERATIONS do
        local x = (i % 100) + 1
        sum = sum + math.log(x)
    end
    return math.floor(sum)
end

local start = os.clock()
local arith_result = basic_arithmetic_bench()
local func_result = math_functions_bench()
local power_result = power_bench()
local floor_result = floor_ceil_bench()
local minmax_result = minmax_bench()
local random_result = random_bench()
local log_result = exp_log_bench()
local elapsed = os.clock() - start

print("arithmetic:", arith_result)
print("functions:", func_result)
print("power:", power_result)
print("floor_ceil:", floor_result)
print("minmax:", minmax_result)
print("random:", random_result)
print("log:", log_result)
print(string.format("elapsed: %.4f", elapsed))

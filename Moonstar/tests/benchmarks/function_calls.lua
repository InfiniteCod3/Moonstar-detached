-- Benchmark: Function Call Overhead
-- Tests function call performance

local ITERATIONS = 100000

local function add(a, b) return a + b end
local function mul(a, b) return a * b end
local function identity(x) return x end

local function chain(x, n)
    for _ = 1, n do
        x = add(x, 1)
        x = mul(x, 1)
        x = identity(x)
    end
    return x
end

local function closure_bench()
    local counter = 0
    local function inc() counter = counter + 1 end
    for _ = 1, ITERATIONS do
        inc()
    end
    return counter
end

local function vararg_bench(...)
    local sum = 0
    local args = {...}
    for _, v in ipairs(args) do
        sum = sum + v
    end
    return sum
end

local start = os.clock()
local chain_result = chain(0, ITERATIONS)
local closure_result = closure_bench()
local vararg_result = vararg_bench(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
local elapsed = os.clock() - start

print("chain:", chain_result)
print("closure:", closure_result)
print("vararg:", vararg_result)
print(string.format("elapsed: %.4f", elapsed))

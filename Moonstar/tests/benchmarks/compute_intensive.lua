-- Benchmark: Compute Intensive
-- Tests performance of heavy arithmetic operations

local ITERATIONS = 100000

local function fibonacci(n)
    if n <= 1 then return n end
    local a, b = 0, 1
    for _ = 2, n do
        a, b = b, a + b
    end
    return b
end

local function sieve(limit)
    local primes = {}
    for i = 2, limit do primes[i] = true end
    for i = 2, math.sqrt(limit) do
        if primes[i] then
            for j = i * i, limit, i do
                primes[j] = nil
            end
        end
    end
    local count = 0
    for _ in pairs(primes) do count = count + 1 end
    return count
end

local function compute()
    local sum = 0
    for i = 1, ITERATIONS do
        sum = sum + (i * 17 + 31) % 127
    end
    return sum
end

local start = os.clock()
local fib_result = fibonacci(30)
local prime_count = sieve(1000)
local compute_result = compute()
local elapsed = os.clock() - start

print("fib(30):", fib_result)
print("primes<1000:", prime_count)
print("compute:", compute_result)
print(string.format("elapsed: %.4f", elapsed))

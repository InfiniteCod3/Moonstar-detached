-- Benchmark: Recursion
-- Tests recursive function call overhead and stack management

local ITERATIONS = 1000

local function factorial(n)
    if n <= 1 then return 1 end
    return n * factorial(n - 1)
end

local function ackermann(m, n)
    if m == 0 then return n + 1 end
    if n == 0 then return ackermann(m - 1, 1) end
    return ackermann(m - 1, ackermann(m, n - 1))
end

local function sum_recursive(n)
    if n <= 0 then return 0 end
    return n + sum_recursive(n - 1)
end

local function tree_depth(depth)
    if depth <= 0 then return 1 end
    return tree_depth(depth - 1) + tree_depth(depth - 1)
end

local mutual_a, mutual_b

mutual_a = function(n)
    if n <= 0 then return 1 end
    return mutual_b(n - 1)
end

mutual_b = function(n)
    if n <= 0 then return 0 end
    return mutual_a(n - 1)
end

local start = os.clock()
local factorial_result = 0
for _ = 1, ITERATIONS do
    factorial_result = factorial(12)
end
local ackermann_result = ackermann(3, 4)
local sum_result = sum_recursive(500)
local tree_result = tree_depth(15)
local mutual_result = mutual_a(100)
local elapsed = os.clock() - start

print("factorial(12):", factorial_result)
print("ackermann(3,4):", ackermann_result)
print("sum(500):", sum_result)
print("tree(15):", tree_result)
print("mutual(100):", mutual_result)
print(string.format("elapsed: %.4f", elapsed))

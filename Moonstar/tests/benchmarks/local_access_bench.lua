-- Benchmark: Local Variable Access
-- Tests local vs global access and register allocation pressure

local ITERATIONS = 100000

local function local_access_bench()
    local a = 1
    local sum = 0
    for _ = 1, ITERATIONS do
        sum = sum + a
    end
    return sum
end

_G.global_a = 1
local function global_access_bench()
    local sum = 0
    for _ = 1, ITERATIONS do
        sum = sum + _G.global_a
    end
    return sum
end

local function many_locals_bench()
    local a, b, c, d, e, f, g, h = 1, 2, 3, 4, 5, 6, 7, 8
    local i, j, k, l, m, n, o, p = 9, 10, 11, 12, 13, 14, 15, 16
    local sum = 0
    for _ = 1, ITERATIONS do
        sum = sum + a + b + c + d + e + f + g + h
        sum = sum + i + j + k + l + m + n + o + p
    end
    return sum
end

local function assignment_bench()
    local a, b, c, d = 0, 0, 0, 0
    for i = 1, ITERATIONS do
        a = i
        b = a + 1
        c = b + 1
        d = c + 1
    end
    return a + b + c + d
end

local function shadow_bench()
    local x = 100
    local sum = 0
    for i = 1, ITERATIONS do
        local x = i
        sum = sum + x
    end
    return sum + x
end

local function reuse_bench()
    local temp
    local sum = 0
    for i = 1, ITERATIONS do
        temp = i * 2
        sum = sum + temp
        temp = i * 3
        sum = sum + temp
    end
    return sum
end

local start = os.clock()
local local_result = local_access_bench()
local global_result = global_access_bench()
local many_result = many_locals_bench()
local assign_result = assignment_bench()
local shadow_result = shadow_bench()
local reuse_result = reuse_bench()
local elapsed = os.clock() - start

print("local:", local_result)
print("global:", global_result)
print("many_locals:", many_result)
print("assignment:", assign_result)
print("shadow:", shadow_result)
print("reuse:", reuse_result)
print(string.format("elapsed: %.4f", elapsed))

-- Benchmark: Table Operations
-- Tests table insert, lookup, and iteration performance

local SIZE = 50000

local function benchmark_insert()
    local t = {}
    for i = 1, SIZE do
        t[i] = i * 2
    end
    return #t
end

local function benchmark_lookup()
    local t = {}
    for i = 1, SIZE do t[i] = i end
    local sum = 0
    for i = 1, SIZE do
        sum = sum + t[i]
    end
    return sum
end

local function benchmark_hash()
    local t = {}
    for i = 1, SIZE do
        t["key_" .. i] = i
    end
    local sum = 0
    for k, v in pairs(t) do
        sum = sum + v
    end
    return sum
end

local start = os.clock()
local insert_count = benchmark_insert()
local lookup_sum = benchmark_lookup()
local hash_sum = benchmark_hash()
local elapsed = os.clock() - start

print("inserts:", insert_count)
print("lookup_sum:", lookup_sum)
print("hash_sum:", hash_sum)
print(string.format("elapsed: %.4f", elapsed))

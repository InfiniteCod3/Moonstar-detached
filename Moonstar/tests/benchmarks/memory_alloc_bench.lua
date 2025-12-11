-- Benchmark: Memory Allocation
-- Tests table allocation, string creation, and memory pressure

local ITERATIONS = 20000

local function table_alloc_bench()
    local tables = {}
    for i = 1, ITERATIONS do
        tables[i] = { i, i * 2, i * 3 }
    end
    local sum = 0
    for _, t in ipairs(tables) do
        sum = sum + t[1] + t[2] + t[3]
    end
    return sum
end

local function small_table_bench()
    local sum = 0
    for i = 1, ITERATIONS do
        local t = { a = i, b = i * 2 }
        sum = sum + t.a + t.b
    end
    return sum
end

local function large_table_bench()
    local t = {}
    for i = 1, ITERATIONS do
        t[i] = {
            id = i,
            name = "item_" .. i,
            value = i * 3.14,
            nested = { x = i, y = i * 2 }
        }
    end
    local sum = 0
    for _, item in ipairs(t) do
        sum = sum + item.id + item.nested.x
    end
    return sum
end

local function string_alloc_bench()
    local strings = {}
    for i = 1, ITERATIONS do
        strings[i] = "string_" .. i .. "_data"
    end
    local total_len = 0
    for _, s in ipairs(strings) do
        total_len = total_len + #s
    end
    return total_len
end

local function realloc_bench()
    local t = {}
    for i = 1, ITERATIONS do
        t[#t + 1] = i
    end
    return #t
end

local function array_preallocate_bench()
    local SIZE = ITERATIONS
    local t = {}
    -- Pre-fill to encourage pre-allocation behavior
    for i = SIZE, 1, -1 do
        t[i] = 0
    end
    for i = 1, SIZE do
        t[i] = i * 2
    end
    local sum = 0
    for i = 1, SIZE do
        sum = sum + t[i]
    end
    return sum
end

local function gc_pressure_bench()
    local sum = 0
    for outer = 1, 100 do
        local temps = {}
        for inner = 1, 200 do
            temps[inner] = { value = outer * inner }
        end
        for _, t in ipairs(temps) do
            sum = sum + t.value
        end
    end
    return sum
end

local start = os.clock()
local table_result = table_alloc_bench()
local small_result = small_table_bench()
local large_result = large_table_bench()
local string_result = string_alloc_bench()
local realloc_result = realloc_bench()
local prealloc_result = array_preallocate_bench()
local gc_result = gc_pressure_bench()
local elapsed = os.clock() - start

print("tables:", table_result)
print("small_tables:", small_result)
print("large_tables:", large_result)
print("strings:", string_result)
print("realloc:", realloc_result)
print("prealloc:", prealloc_result)
print("gc_pressure:", gc_result)
print(string.format("elapsed: %.4f", elapsed))

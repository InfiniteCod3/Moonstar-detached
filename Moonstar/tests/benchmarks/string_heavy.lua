-- Benchmark: String Heavy Operations
-- Tests string concatenation and pattern matching

local ITERATIONS = 10000

local function benchmark_concat()
    local parts = {}
    for i = 1, ITERATIONS do
        parts[i] = tostring(i)
    end
    return table.concat(parts, ",")
end

local function benchmark_patterns()
    local text = "The quick brown fox jumps over 123 lazy dogs 456 times."
    local count = 0
    for _ = 1, ITERATIONS do
        for _ in text:gmatch("%d+") do
            count = count + 1
        end
    end
    return count
end

local function benchmark_format()
    local result = ""
    for i = 1, ITERATIONS do
        result = string.format("%d: value_%s", i, tostring(i * 2))
    end
    return #result
end

local start = os.clock()
local concat_len = #benchmark_concat()
local pattern_count = benchmark_patterns()
local format_len = benchmark_format()
local elapsed = os.clock() - start

print("concat_len:", concat_len)
print("pattern_count:", pattern_count)
print("format_len:", format_len)
print(string.format("elapsed: %.4f", elapsed))

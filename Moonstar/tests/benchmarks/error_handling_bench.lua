-- Benchmark: Error Handling
-- Tests pcall/xpcall overhead and error propagation

local ITERATIONS = 50000

local function success_func()
    return 42
end

local function error_func()
    error("test error")
end

local function pcall_success_bench()
    local sum = 0
    for _ = 1, ITERATIONS do
        local ok, result = pcall(success_func)
        if ok then sum = sum + result end
    end
    return sum
end

local function pcall_error_bench()
    local count = 0
    for _ = 1, ITERATIONS do
        local ok, _ = pcall(error_func)
        if not ok then count = count + 1 end
    end
    return count
end

local function error_handler(err)
    return "handled: " .. tostring(err)
end

local function xpcall_bench()
    local count = 0
    for _ = 1, ITERATIONS do
        local ok, result = xpcall(success_func, error_handler)
        if ok then count = count + result end
    end
    return count
end

local function xpcall_error_bench()
    local count = 0
    for _ = 1, ITERATIONS do
        local ok, msg = xpcall(error_func, error_handler)
        if not ok and msg then count = count + 1 end
    end
    return count
end

local function nested_pcall_bench()
    local function level3() return 1 end
    local function level2()
        local ok, r = pcall(level3)
        return ok and r or 0
    end
    local function level1()
        local ok, r = pcall(level2)
        return ok and r or 0
    end
    local sum = 0
    for _ = 1, ITERATIONS do
        local ok, r = pcall(level1)
        if ok then sum = sum + r end
    end
    return sum
end

local function assert_bench()
    local count = 0
    for i = 1, ITERATIONS do
        local ok = pcall(function()
            assert(i > 0, "positive required")
        end)
        if ok then count = count + 1 end
    end
    return count
end

local start = os.clock()
local success_result = pcall_success_bench()
local error_result = pcall_error_bench()
local xpcall_result = xpcall_bench()
local xpcall_err_result = xpcall_error_bench()
local nested_result = nested_pcall_bench()
local assert_result = assert_bench()
local elapsed = os.clock() - start

print("pcall_success:", success_result)
print("pcall_error:", error_result)
print("xpcall_success:", xpcall_result)
print("xpcall_error:", xpcall_err_result)
print("nested:", nested_result)
print("assert:", assert_result)
print(string.format("elapsed: %.4f", elapsed))

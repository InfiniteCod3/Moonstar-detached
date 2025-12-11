-- Benchmark: Coroutines
-- Tests coroutine creation, resume/yield overhead

local ITERATIONS = 10000

local function create_bench()
    local count = 0
    for _ = 1, ITERATIONS do
        local co = coroutine.create(function() return 1 end)
        coroutine.resume(co)
        count = count + 1
    end
    return count
end

local function yield_bench()
    local co = coroutine.create(function()
        for i = 1, ITERATIONS do
            coroutine.yield(i)
        end
    end)
    local sum = 0
    while coroutine.status(co) ~= "dead" do
        local ok, val = coroutine.resume(co)
        if ok and val then
            sum = sum + val
        end
    end
    return sum
end

local function producer_consumer_bench()
    local function producer()
        for i = 1, ITERATIONS do
            coroutine.yield(i * 2)
        end
    end
    local co = coroutine.create(producer)
    local sum = 0
    repeat
        local ok, val = coroutine.resume(co)
        if ok and val then
            sum = sum + val
        end
    until coroutine.status(co) == "dead"
    return sum
end

local function nested_coroutine_bench()
    local function inner_work(x)
        local sum = 0
        for i = 1, 100 do
            sum = sum + x + i
        end
        return sum
    end
    
    local function outer()
        local total = 0
        for i = 1, 100 do
            local inner = coroutine.create(function()
                return inner_work(i)
            end)
            local ok, result = coroutine.resume(inner)
            if ok then
                total = total + result
            end
        end
        return total
    end
    
    local co = coroutine.create(outer)
    local ok, result = coroutine.resume(co)
    return ok and result or 0
end

local function wrap_bench()
    local gen = coroutine.wrap(function()
        for i = 1, ITERATIONS do
            coroutine.yield(i)
        end
    end)
    local sum = 0
    for i = 1, ITERATIONS do
        local val = gen()
        if val then sum = sum + val end
    end
    return sum
end

local start = os.clock()
local create_result = create_bench()
local yield_result = yield_bench()
local producer_result = producer_consumer_bench()
local nested_result = nested_coroutine_bench()
local wrap_result = wrap_bench()
local elapsed = os.clock() - start

print("create:", create_result)
print("yield:", yield_result)
print("producer:", producer_result)
print("nested:", nested_result)
print("wrap:", wrap_result)
print(string.format("elapsed: %.4f", elapsed))

-- Benchmark: Control Flow
-- Tests branching and loop performance

local ITERATIONS = 100000

local function branch_bench()
    local count = 0
    for i = 1, ITERATIONS do
        if i % 3 == 0 then
            count = count + 3
        elseif i % 2 == 0 then
            count = count + 2
        else
            count = count + 1
        end
    end
    return count
end

local function nested_loop_bench()
    local sum = 0
    for i = 1, 100 do
        for j = 1, 100 do
            sum = sum + (i * j) % 17
        end
    end
    return sum
end

local function while_bench()
    local i, sum = 0, 0
    while i < ITERATIONS do
        sum = sum + i
        i = i + 1
    end
    return sum
end

local function repeat_bench()
    local i, sum = 0, 0
    repeat
        sum = sum + i
        i = i + 1
    until i >= ITERATIONS
    return sum
end

local start = os.clock()
local branch_result = branch_bench()
local nested_result = nested_loop_bench()
local while_result = while_bench()
local repeat_result = repeat_bench()
local elapsed = os.clock() - start

print("branch:", branch_result)
print("nested:", nested_result)
print("while:", while_result)
print("repeat:", repeat_result)
print(string.format("elapsed: %.4f", elapsed))

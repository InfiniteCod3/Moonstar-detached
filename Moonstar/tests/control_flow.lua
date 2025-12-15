-- tests/control_flow.lua
-- Tests complex control flow patterns to verify CFF doesn't break logic

-- 1. Deeply nested if/elseif/else
local function classify_number(n)
    if n < 0 then
        if n < -100 then
            return "very negative"
        elseif n < -10 then
            return "negative"
        else
            return "slightly negative"
        end
    elseif n == 0 then
        return "zero"
    else
        if n > 100 then
            return "very positive"
        elseif n > 10 then
            return "positive"
        else
            return "slightly positive"
        end
    end
end

print(classify_number(-500))
print(classify_number(-50))
print(classify_number(-5))
print(classify_number(0))
print(classify_number(5))
print(classify_number(50))
print(classify_number(500))

-- 2. Break statements in various loops
local function find_in_nested_loop()
    local found = nil
    for i = 1, 5 do
        for j = 1, 5 do
            if i * j == 12 then
                found = {i, j}
                break
            end
        end
        if found then break end
    end
    return found and (found[1] .. "," .. found[2]) or "not found"
end
print(find_in_nested_loop())

-- 3. Break in while loop
local function while_break_test()
    local i = 0
    local result = {}
    while true do
        i = i + 1
        if i > 10 then break end
        if i % 2 == 0 then
            table.insert(result, i)
        end
    end
    return table.concat(result, ",")
end
print(while_break_test())

-- 4. Break in repeat loop
local function repeat_break_test()
    local i = 0
    repeat
        i = i + 1
        if i == 5 then break end
    until i > 100
    return i
end
print(repeat_break_test())

-- 5. Early returns from nested functions
local function outer_func(x)
    local function inner_func(y)
        if y < 0 then return "negative" end
        if y == 0 then return "zero" end
        return "positive"
    end
    
    if x > 100 then
        return "too big: " .. inner_func(x)
    end
    return "normal: " .. inner_func(x)
end
print(outer_func(-5))
print(outer_func(0))
print(outer_func(50))
print(outer_func(150))

-- 6. Short-circuit evaluation with side effects
local call_count = 0
local function side_effect(val)
    call_count = call_count + 1
    return val
end

-- and short-circuit: second shouldn't be called if first is false
call_count = 0
local result1 = side_effect(false) and side_effect(true)
print("and short-circuit calls: " .. call_count)  -- should be 1

-- or short-circuit: second shouldn't be called if first is true
call_count = 0
local result2 = side_effect(true) or side_effect(false)
print("or short-circuit calls: " .. call_count)  -- should be 1

-- 7. Complex boolean expressions
local function complex_bool(a, b, c, d)
    return (a and b) or (c and not d) or (not a and not b and c)
end
print(complex_bool(true, true, false, false))
print(complex_bool(false, false, true, false))
print(complex_bool(false, false, true, true))
print(complex_bool(false, false, false, false))

-- 8. Ternary-style expressions
local function ternary_test(cond)
    return cond and "yes" or "no"
end
print(ternary_test(true))
print(ternary_test(false))
print(ternary_test(nil))
print(ternary_test(0))  -- 0 is truthy in Lua

-- 9. Multiple conditions in loop
local function multi_condition_loop()
    local sum = 0
    for i = 1, 20 do
        if i % 2 == 0 and i % 3 == 0 then
            sum = sum + i * 2
        elseif i % 2 == 0 or i % 3 == 0 then
            sum = sum + i
        end
    end
    return sum
end
print(multi_condition_loop())

-- 10. Nested loops with complex exit conditions
local function matrix_search()
    local matrix = {
        {1, 2, 3, 4},
        {5, 6, 7, 8},
        {9, 10, 11, 12}
    }
    local target = 7
    local row, col = 0, 0
    local found = false
    
    for i = 1, #matrix do
        for j = 1, #matrix[i] do
            if matrix[i][j] == target then
                row, col = i, j
                found = true
                break
            end
        end
        if found then break end
    end
    
    return found and string.format("Found at [%d][%d]", row, col) or "Not found"
end
print(matrix_search())

-- 11. Switch-like pattern
local function switch_test(val)
    local cases = {
        [1] = function() return "one" end,
        [2] = function() return "two" end,
        [3] = function() return "three" end,
    }
    local handler = cases[val]
    if handler then
        return handler()
    else
        return "default"
    end
end
print(switch_test(1))
print(switch_test(2))
print(switch_test(3))
print(switch_test(99))

-- 12. Numeric for with step
local function stepped_loop()
    local result = {}
    for i = 10, 1, -2 do
        table.insert(result, i)
    end
    return table.concat(result, ",")
end
print(stepped_loop())

-- 13. Conditional in loop variable
local function conditional_bounds()
    local max = 5
    local results = {}
    for i = 1, max > 3 and 10 or 5 do
        table.insert(results, i)
    end
    return #results
end
print(conditional_bounds())

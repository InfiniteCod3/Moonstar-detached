-- tests/perf_opt_scope_reuse.lua
-- PERF-OPT #8: Scope Reuse in Dispatch Tree Test
-- Tests the dispatch tree optimization (reusing scope in BST)
--
-- This test verifies that:
-- 1. Control flow with many blocks works correctly
-- 2. Nested if-else chains work
-- 3. Deep nesting works correctly
-- 4. Complex branching works
-- 5. Switch-like patterns work

-- Test 1: Simple branching
local function test_branch(x)
    if x == 1 then
        return "one"
    elseif x == 2 then
        return "two"
    elseif x == 3 then
        return "three"
    else
        return "other"
    end
end

print("Test 1 - Branch 1: " .. test_branch(1))
print("Test 1 - Branch 2: " .. test_branch(2))
print("Test 1 - Branch 3: " .. test_branch(3))
print("Test 1 - Branch 4: " .. test_branch(4))
assert(test_branch(1) == "one" and test_branch(3) == "three", "Simple branch failed")

-- Test 2: Many elseif (creates large BST)
local function many_branches(n)
    if n == 1 then return 1
    elseif n == 2 then return 2
    elseif n == 3 then return 3
    elseif n == 4 then return 4
    elseif n == 5 then return 5
    elseif n == 6 then return 6
    elseif n == 7 then return 7
    elseif n == 8 then return 8
    elseif n == 9 then return 9
    elseif n == 10 then return 10
    else return 0
    end
end

print("Test 2 - Many 5: " .. many_branches(5))
print("Test 2 - Many 10: " .. many_branches(10))
print("Test 2 - Many 15: " .. many_branches(15))
assert(many_branches(5) == 5 and many_branches(10) == 10 and many_branches(15) == 0, "Many branches failed")

-- Test 3: Nested if statements
local function nested_ifs(a, b, c)
    if a then
        if b then
            if c then
                return "all true"
            else
                return "a,b true"
            end
        else
            if c then
                return "a,c true"
            else
                return "a true"
            end
        end
    else
        if b then
            return "b true"
        else
            return "none true"
        end
    end
end

print("Test 3 - TTT: " .. nested_ifs(true, true, true))
print("Test 3 - TFF: " .. nested_ifs(true, false, false))
print("Test 3 - FFF: " .. nested_ifs(false, false, false))
assert(nested_ifs(true, true, true) == "all true", "Nested TTT failed")
assert(nested_ifs(false, false, false) == "none true", "Nested FFF failed")

-- Test 4: While loop with many iterations (creates many block jumps)
local function while_test(n)
    local count = 0
    local sum = 0
    while count < n do
        sum = sum + count
        count = count + 1
    end
    return sum
end

print("Test 4 - While 100: " .. while_test(100))
assert(while_test(100) == 4950, "While test failed")  -- 0+1+2+...+99

-- Test 5: For loop
local function for_test(n)
    local sum = 0
    for i = 1, n do
        sum = sum + i
    end
    return sum
end

print("Test 5 - For 100: " .. for_test(100))
assert(for_test(100) == 5050, "For test failed")  -- 1+2+...+100

-- Test 6: Complex control flow
local function complex_flow(x)
    local result = ""
    
    if x > 10 then
        result = result .. "A"
        if x > 20 then
            result = result .. "B"
            if x > 30 then
                result = result .. "C"
            end
        end
    end
    
    for i = 1, 3 do
        if i == 2 then
            result = result .. "D"
        end
    end
    
    local j = 0
    while j < 2 do
        result = result .. "E"
        j = j + 1
    end
    
    return result
end

print("Test 6 - Complex 35: " .. complex_flow(35))
print("Test 6 - Complex 5: " .. complex_flow(5))
assert(complex_flow(35) == "ABCDEE", "Complex 35 failed")
assert(complex_flow(5) == "DEE", "Complex 5 failed")

-- Test 7: Early return from nested blocks
local function early_return(n)
    for i = 1, 100 do
        if i == n then
            return "found at " .. i
        end
        
        if i > 50 then
            for j = 1, 10 do
                if i + j == n then
                    return "found nested at " .. i .. "+" .. j
                end
            end
        end
    end
    return "not found"
end

print("Test 7 - Early 10: " .. early_return(10))
print("Test 7 - Early 55: " .. early_return(55))
assert(early_return(10) == "found at 10", "Early 10 failed")

-- Test 8: Continue pattern (using break from inner)
local function skip_evens(n)
    local result = {}
    for i = 1, n do
        repeat
            if i % 2 == 0 then
                break  -- skip even
            end
            table.insert(result, i)
        until true
    end
    return table.concat(result, ",")
end

print("Test 8 - Skip evens 10: " .. skip_evens(10))
assert(skip_evens(10) == "1,3,5,7,9", "Skip evens failed")

-- Test 9: Deeply nested control flow
local function deep_nest(n)
    local sum = 0
    if n > 0 then
        if n > 1 then
            if n > 2 then
                if n > 3 then
                    if n > 4 then
                        if n > 5 then
                            sum = n * 10
                        else
                            sum = n * 5
                        end
                    else
                        sum = n * 4
                    end
                else
                    sum = n * 3
                end
            else
                sum = n * 2
            end
        else
            sum = n * 1
        end
    end
    return sum
end

print("Test 9 - Deep 6: " .. deep_nest(6))
print("Test 9 - Deep 3: " .. deep_nest(3))
assert(deep_nest(6) == 60 and deep_nest(3) == 9, "Deep nest failed")

-- Test 10: Mixed loops and conditionals
local function mixed_flow(items)
    local result = 0
    for i, v in ipairs(items) do
        if v > 0 then
            local j = v
            while j > 0 do
                result = result + 1
                j = j - 1
            end
        else
            result = result - 1
        end
    end
    return result
end

print("Test 10 - Mixed: " .. mixed_flow({1, 2, -1, 3, -2}))
assert(mixed_flow({1, 2, -1, 3, -2}) == 4, "Mixed flow failed")  -- 1+2+3 - 2 = 4

-- Test 11: Repeat-until
local function repeat_test(n)
    local count = 0
    local sum = 0
    repeat
        sum = sum + count
        count = count + 1
    until count >= n
    return sum
end

print("Test 11 - Repeat 10: " .. repeat_test(10))
assert(repeat_test(10) == 45, "Repeat test failed")

-- Test 12: For-in with break
local function find_value(tbl, target)
    for k, v in pairs(tbl) do
        if v == target then
            return k
        end
    end
    return nil
end

local test_tbl = {a = 1, b = 2, c = 3, d = 4}
print("Test 12 - Find 3: " .. tostring(find_value(test_tbl, 3)))
assert(find_value(test_tbl, 3) == "c", "Find value failed")

print("\n=== All scope reuse tests PASSED ===")

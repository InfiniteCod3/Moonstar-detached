-- tests/negated_conditions.lua
-- Test file for negated comparison optimizations in control flow
-- Tests the PERF-OPT #3: emitConditionalJump NotExpression handling

print("=== Testing Negated Condition Optimizations ===")

-- Test 1: not (a < b) should work like a >= b
local function test_not_less_than()
    local a, b = 5, 3
    local result = "failed"
    if not (a < b) then
        result = "passed"
    end
    print("Test 1 - not (a < b) where a=5, b=3: " .. result)
    assert(result == "passed", "not (a < b) failed")
    
    -- Edge case: equal values
    a, b = 5, 5
    result = "failed"
    if not (a < b) then
        result = "passed"
    end
    print("Test 1b - not (a < b) where a=b=5: " .. result)
    assert(result == "passed", "not (a < b) edge case failed")
end

-- Test 2: not (a > b) should work like a <= b
local function test_not_greater_than()
    local a, b = 3, 5
    local result = "failed"
    if not (a > b) then
        result = "passed"
    end
    print("Test 2 - not (a > b) where a=3, b=5: " .. result)
    assert(result == "passed", "not (a > b) failed")
end

-- Test 3: not (a <= b) should work like a > b
local function test_not_less_equal()
    local a, b = 10, 5
    local result = "failed"
    if not (a <= b) then
        result = "passed"
    end
    print("Test 3 - not (a <= b) where a=10, b=5: " .. result)
    assert(result == "passed", "not (a <= b) failed")
end

-- Test 4: not (a >= b) should work like a < b
local function test_not_greater_equal()
    local a, b = 3, 7
    local result = "failed"
    if not (a >= b) then
        result = "passed"
    end
    print("Test 4 - not (a >= b) where a=3, b=7: " .. result)
    assert(result == "passed", "not (a >= b) failed")
end

-- Test 5: not (a == b) should work like a ~= b
local function test_not_equals()
    local a, b = 5, 10
    local result = "failed"
    if not (a == b) then
        result = "passed"
    end
    print("Test 5 - not (a == b) where a=5, b=10: " .. result)
    assert(result == "passed", "not (a == b) failed")
end

-- Test 6: not (a ~= b) should work like a == b
local function test_not_not_equals()
    local a, b = 7, 7
    local result = "failed"
    if not (a ~= b) then
        result = "passed"
    end
    print("Test 6 - not (a ~= b) where a=b=7: " .. result)
    assert(result == "passed", "not (a ~= b) failed")
end

-- Test 7: Complex nested conditions with negation
local function test_complex_nested()
    local x, y, z = 10, 20, 15
    local result = 0
    
    -- Multiple negated conditions
    if not (x > y) then
        result = result + 1  -- Should hit (10 > 20 is false, so not false = true)
    end
    
    if not (z < x) then
        result = result + 2  -- Should hit (15 < 10 is false, so not false = true)
    end
    
    if not (x == y) then
        result = result + 4  -- Should hit (10 == 20 is false)
    end
    
    print("Test 7 - Complex nested negations: result=" .. result)
    assert(result == 7, "Complex nested failed, expected 7 got " .. result)
end

-- Test 8: Negated conditions in elseif chains
local function test_elseif_chain()
    local val = 50
    local result = "none"
    
    if not (val < 25) then
        if not (val < 75) then
            result = "large"
        else
            result = "medium"
        end
    else
        result = "small"
    end
    
    print("Test 8 - Elseif with negation: " .. result)
    assert(result == "medium", "Elseif chain failed, expected medium got " .. result)
end

-- Test 9: Negated conditions with function returns
local function greater_check(a, b)
    return a > b
end

local function test_function_in_negation()
    local result = "failed"
    -- This should NOT use the optimized path (function call)
    if not greater_check(3, 5) then
        result = "passed"
    end
    print("Test 9 - Function in negation: " .. result)
    assert(result == "passed", "Function in negation failed")
end

-- Test 10: Negated conditions in while loops
local function test_while_negated()
    local count = 0
    local limit = 5
    while not (count >= limit) do
        count = count + 1
    end
    print("Test 10 - While with negation: count=" .. count)
    assert(count == 5, "While negation failed, expected 5 got " .. count)
end

-- Test 11: String comparisons with negation
local function test_string_negation()
    local s1, s2 = "apple", "banana"
    local result = "failed"
    if not (s1 == s2) then
        result = "passed"
    end
    print("Test 11 - String negation: " .. result)
    assert(result == "passed", "String negation failed")
end

-- Run all tests
test_not_less_than()
test_not_greater_than()
test_not_less_equal()
test_not_greater_equal()
test_not_equals()
test_not_not_equals()
test_complex_nested()
test_elseif_chain()
test_function_in_negation()
test_while_negated()
test_string_negation()

print("\n=== All Negated Condition Tests PASSED ===")

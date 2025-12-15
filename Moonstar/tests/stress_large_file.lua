-- tests/stress_large_file.lua
-- Stress test with many functions, variables, and nested scopes

-- ============================================================================
-- SECTION 1: Many local variables
-- ============================================================================
local var001, var002, var003, var004, var005 = 1, 2, 3, 4, 5
local var006, var007, var008, var009, var010 = 6, 7, 8, 9, 10
local var011, var012, var013, var014, var015 = 11, 12, 13, 14, 15
local var016, var017, var018, var019, var020 = 16, 17, 18, 19, 20

local function sum_vars_1_to_20()
    return var001 + var002 + var003 + var004 + var005 +
           var006 + var007 + var008 + var009 + var010 +
           var011 + var012 + var013 + var014 + var015 +
           var016 + var017 + var018 + var019 + var020
end
print("sum 1-20: " .. sum_vars_1_to_20())

-- ============================================================================
-- SECTION 2: Many functions
-- ============================================================================
local function func01(x) return x + 1 end
local function func02(x) return x + 2 end
local function func03(x) return x + 3 end
local function func04(x) return x + 4 end
local function func05(x) return x + 5 end
local function func06(x) return x + 6 end
local function func07(x) return x + 7 end
local function func08(x) return x + 8 end
local function func09(x) return x + 9 end
local function func10(x) return x + 10 end

local function chain_functions(start)
    return func10(func09(func08(func07(func06(
           func05(func04(func03(func02(func01(start))))))))))
end
print("chain result: " .. chain_functions(0))

-- ============================================================================
-- SECTION 3: Deep nesting
-- ============================================================================
local function deep_nesting_test()
    local result = 0
    if true then
        if true then
            if true then
                if true then
                    if true then
                        if true then
                            if true then
                                if true then
                                    if true then
                                        if true then
                                            result = 42
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return result
end
print("deep nesting: " .. deep_nesting_test())

-- ============================================================================
-- SECTION 4: Large string literals
-- ============================================================================
local large_string_1 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
local large_string_2 = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
local large_string_3 = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"
print("large strings length: " .. (#large_string_1 + #large_string_2 + #large_string_3))

-- ============================================================================
-- SECTION 5: Large table
-- ============================================================================
local large_table = {}
for i = 1, 200 do
    large_table[i] = {
        index = i,
        value = i * i,
        name = "item_" .. i
    }
end
print("large table item 100: " .. large_table[100].value)
print("large table item 200: " .. large_table[200].name)

-- ============================================================================
-- SECTION 6: Many string operations
-- ============================================================================
local str_ops_result = ""
for i = 1, 50 do
    str_ops_result = str_ops_result .. string.char(64 + (i % 26) + 1)
end
print("string ops length: " .. #str_ops_result)
print("string ops start: " .. string.sub(str_ops_result, 1, 10))

-- ============================================================================
-- SECTION 7: Complex conditionals
-- ============================================================================
local function evaluate_complex(a, b, c, d, e)
    if a > 0 and b > 0 and c > 0 and d > 0 and e > 0 then
        if a < 100 or b < 100 or c < 100 then
            if not (a == b and b == c) then
                if a + b > c or b + c > d or c + d > e then
                    return "complex_true"
                end
            end
        end
    end
    return "complex_false"
end
print("complex cond 1: " .. evaluate_complex(1, 2, 3, 4, 5))
print("complex cond 2: " .. evaluate_complex(-1, 2, 3, 4, 5))
print("complex cond 3: " .. evaluate_complex(5, 5, 5, 4, 5))

-- ============================================================================
-- SECTION 8: Recursive with many parameters
-- ============================================================================
local function recursive_sum(a, b, c, d, e, depth)
    if depth <= 0 then
        return a + b + c + d + e
    end
    return recursive_sum(a+1, b+1, c+1, d+1, e+1, depth - 1)
end
print("recursive sum: " .. recursive_sum(1, 2, 3, 4, 5, 10))

-- ============================================================================
-- SECTION 9: Many upvalues in closure
-- ============================================================================
local function create_many_upvalue_closure()
    local a, b, c, d, e = 1, 2, 3, 4, 5
    local f, g, h, i, j = 6, 7, 8, 9, 10
    local k, l, m, n, o = 11, 12, 13, 14, 15
    local p, q, r, s, t = 16, 17, 18, 19, 20
    
    return function()
        return a + b + c + d + e + f + g + h + i + j +
               k + l + m + n + o + p + q + r + s + t
    end
end
print("many upvalues: " .. create_many_upvalue_closure()())

-- ============================================================================
-- SECTION 10: Mix of all patterns
-- ============================================================================
local function mixed_pattern_test()
    local results = {}
    
    -- Closures in loop
    local closures = {}
    for i = 1, 5 do
        local captured = i
        closures[i] = function() return captured end
    end
    
    -- Table with metatables
    local mt = {
        __index = function(t, k) return "default_" .. k end
    }
    local mt_table = setmetatable({known = "value"}, mt)
    
    -- Multiple returns
    local function multi_return()
        return 1, 2, 3, 4, 5
    end
    local mr1, mr2, mr3, mr4, mr5 = multi_return()
    
    -- Varargs
    local function var_sum(...)
        local s = 0
        for _, v in ipairs({...}) do s = s + v end
        return s
    end
    
    table.insert(results, "closure_3: " .. closures[3]())
    table.insert(results, "mt_known: " .. mt_table.known)
    table.insert(results, "mt_unknown: " .. mt_table.unknown)
    table.insert(results, "multi_sum: " .. (mr1 + mr2 + mr3 + mr4 + mr5))
    table.insert(results, "var_sum: " .. var_sum(10, 20, 30))
    
    return table.concat(results, " | ")
end
print("mixed pattern: " .. mixed_pattern_test())

-- ============================================================================
-- SECTION 11: Error handling in various contexts
-- ============================================================================
local function test_error_handling()
    local results = {}
    
    -- Simple pcall
    local ok1, err1 = pcall(function() error("test error") end)
    table.insert(results, "pcall_err: " .. tostring(not ok1))
    
    -- pcall with return
    local ok2, val2 = pcall(function() return 42 end)
    table.insert(results, "pcall_ok: " .. tostring(ok2 and val2 == 42))
    
    -- Nested pcall
    local ok3, val3 = pcall(function()
        local inner_ok = pcall(function() error("inner") end)
        return not inner_ok
    end)
    table.insert(results, "nested_pcall: " .. tostring(ok3 and val3))
    
    return table.concat(results, " | ")
end
print("error handling: " .. test_error_handling())

-- ============================================================================
-- SECTION 12: Numeric edge cases
-- ============================================================================
print("max_int: " .. tostring(2^31 - 1))
print("negative: " .. tostring(-2^31))
print("float_precision: " .. tostring(0.1 + 0.2 == 0.3))
print("division: " .. tostring(10 / 3))
print("floor_div: " .. tostring(math.floor(10 / 3)))
print("modulo_neg: " .. tostring(-7 % 3))

-- ============================================================================
-- SECTION 13: Coroutine in complex context
-- ============================================================================
local function coroutine_test()
    local results = {}
    
    local co = coroutine.create(function(start)
        local sum = start
        for i = 1, 5 do
            sum = sum + coroutine.yield(sum)
        end
        return sum
    end)
    
    local ok, val = coroutine.resume(co, 0)
    table.insert(results, tostring(val))
    
    for i = 1, 5 do
        ok, val = coroutine.resume(co, i * 10)
        table.insert(results, tostring(val))
    end
    
    return table.concat(results, ",")
end
print("coroutine: " .. coroutine_test())

-- ============================================================================
-- SECTION 14: Pattern matching stress
-- ============================================================================
local function pattern_test()
    local text = "The quick brown fox jumps over the lazy dog 12345"
    local results = {}
    
    table.insert(results, "words: " .. select(2, text:gsub("%w+", "")))
    table.insert(results, "digits: " .. (text:match("%d+") or "none"))
    table.insert(results, "first_word: " .. (text:match("^%w+") or "none"))
    table.insert(results, "last_word: " .. (text:match("%w+$") or "none"))
    
    return table.concat(results, " | ")
end
print("patterns: " .. pattern_test())

-- ============================================================================
-- SECTION 15: Final summary
-- ============================================================================
local function final_summary()
    local total = 0
    total = total + sum_vars_1_to_20()
    total = total + chain_functions(0)
    total = total + deep_nesting_test()
    total = total + #large_string_1
    total = total + large_table[50].value
    total = total + create_many_upvalue_closure()()
    return total
end
print("final_summary: " .. final_summary())

print("stress_test_complete")

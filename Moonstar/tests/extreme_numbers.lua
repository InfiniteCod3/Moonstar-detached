-- tests/extreme_numbers.lua
-- Tests extreme float values and number edge cases
-- Critical for NumberObfuscation correctness

-- 1. Infinity
local pos_inf = 1/0
local neg_inf = -1/0
print("pos_inf: " .. tostring(pos_inf))
print("neg_inf: " .. tostring(neg_inf))
print("inf == inf: " .. tostring(pos_inf == pos_inf))
print("inf > 1e308: " .. tostring(pos_inf > 1e308))
print("-inf < -1e308: " .. tostring(neg_inf < -1e308))

-- 2. NaN (Not a Number)
local nan = 0/0
print("nan tostring: " .. tostring(nan))
print("nan == nan: " .. tostring(nan == nan))  -- Always false
print("nan ~= nan: " .. tostring(nan ~= nan))  -- Always true
print("not (nan < 0): " .. tostring(not (nan < 0)))
print("not (nan > 0): " .. tostring(not (nan > 0)))
print("not (nan == 0): " .. tostring(not (nan == 0)))

-- 3. Negative zero
local neg_zero = -0
local pos_zero = 0
print("neg_zero == pos_zero: " .. tostring(neg_zero == pos_zero))
print("1/neg_zero: " .. tostring(1/neg_zero))  -- -inf
print("1/pos_zero: " .. tostring(1/pos_zero))  -- inf

-- 4. Very large numbers
local large = 1e308
print("large: " .. string.format("%.2e", large))
print("large * 2: " .. tostring(large * 2))  -- inf

-- 5. Very small numbers (subnormal)
local tiny = 1e-308
print("tiny: " .. string.format("%.2e", tiny))
print("tiny / 1e10: " .. string.format("%.2e", tiny / 1e10))

-- 6. Integer limits
local max_safe_int = 9007199254740992  -- 2^53
print("max_safe_int: " .. tostring(max_safe_int))
print("max_safe_int + 1: " .. tostring(max_safe_int + 1))
print("max_safe_int + 2: " .. tostring(max_safe_int + 2))

-- 7. Precision edge cases
print("0.1 + 0.2 == 0.3: " .. tostring(0.1 + 0.2 == 0.3))  -- False due to floating point
print("0.1 + 0.2: " .. tostring(0.1 + 0.2))

-- 8. Math functions with special values
print("math.abs(-inf): " .. tostring(math.abs(neg_inf)))
print("math.floor(inf): " .. tostring(math.floor(pos_inf)))
print("math.ceil(-inf): " .. tostring(math.ceil(neg_inf)))
print("math.max(1, nan): " .. tostring(math.max(1, nan)))
print("math.min(1, nan): " .. tostring(math.min(1, nan)))

-- 9. Power edge cases
print("0^0: " .. tostring(0^0))
print("inf^0: " .. tostring(pos_inf^0))
print("1^inf: " .. tostring(1^pos_inf))
print("(-1)^inf: " .. tostring((-1)^pos_inf))
print("2^1024: " .. tostring(2^1024))  -- inf

-- 10. Square root edge cases
print("math.sqrt(-1): " .. tostring(math.sqrt(-1)))  -- nan
print("math.sqrt(inf): " .. tostring(math.sqrt(pos_inf)))
print("math.sqrt(0): " .. tostring(math.sqrt(0)))

-- 11. Logarithm edge cases
print("math.log(0): " .. tostring(math.log(0)))  -- -inf
print("math.log(-1): " .. tostring(math.log(-1)))  -- nan
print("math.log(inf): " .. tostring(math.log(pos_inf)))  -- inf

-- 12. Trigonometric with infinity
print("math.sin(inf): " .. tostring(math.sin(pos_inf)))  -- nan
print("math.cos(inf): " .. tostring(math.cos(pos_inf)))  -- nan

-- 13. Modulo edge cases
print("5 % 0: " .. tostring(5 % 0))  -- nan (division by zero)
print("inf % 1: " .. tostring(pos_inf % 1))  -- nan
print("5 % inf: " .. tostring(5 % pos_inf))

-- 14. Comparison chains
print("1 < 2 and 2 < 3: " .. tostring(1 < 2 and 2 < 3))
print("nan < 1 or nan > 1 or nan == 1: " .. tostring(nan < 1 or nan > 1 or nan == 1))

-- 15. Floor division behavior (Lua 5.1 doesn't have //, but test math.floor)
print("math.floor(7/3): " .. tostring(math.floor(7/3)))
print("math.floor(-7/3): " .. tostring(math.floor(-7/3)))
print("math.floor(inf): " .. tostring(math.floor(pos_inf)))

-- 16. Number to string conversions
print("tostring(1e100): " .. tostring(1e100))
print("tostring(1e-100): " .. tostring(1e-100))
print("tostring(1234567890123): " .. tostring(1234567890123))

-- 17. String to number with special values
print("tonumber('inf'): " .. tostring(tonumber("inf")))
print("tonumber('-inf'): " .. tostring(tonumber("-inf")))
print("tonumber('nan'): " .. tostring(tonumber("nan")))

-- 18. Hexadecimal floats (Lua 5.2+, may not work in 5.1)
-- Skip if not supported

-- 19. Arithmetic with mixed types
print("inf + 1: " .. tostring(pos_inf + 1))
print("inf - inf: " .. tostring(pos_inf - pos_inf))  -- nan
print("inf * 0: " .. tostring(pos_inf * 0))  -- nan
print("inf / inf: " .. tostring(pos_inf / pos_inf))  -- nan

-- 20. Sign function behavior
local function sign(x)
    if x > 0 then return 1
    elseif x < 0 then return -1
    else return 0
    end
end
print("sign(inf): " .. sign(pos_inf))
print("sign(-inf): " .. sign(neg_inf))
print("sign(0): " .. sign(0))
print("sign(nan): " .. sign(nan))  -- 0 because nan comparisons are false

-- 21. Number as table key
local num_table = {}
num_table[pos_inf] = "positive infinity"
num_table[neg_inf] = "negative infinity"
num_table[0] = "zero"
num_table[-0] = "negative zero"  -- Same key as 0
print("table[inf]: " .. num_table[pos_inf])
print("table[-inf]: " .. num_table[neg_inf])
print("table[0] after -0 set: " .. num_table[0])

-- 22. Frexp and ldexp
local m, e = math.frexp(256)
print("frexp(256): " .. m .. ", " .. e)
print("ldexp(0.5, 9): " .. math.ldexp(0.5, 9))

-- 23. Modf
local int_part, frac_part = math.modf(3.14159)
print("modf(3.14159): " .. int_part .. ", " .. frac_part)
int_part, frac_part = math.modf(-3.14159)
print("modf(-3.14159): " .. int_part .. ", " .. frac_part)

-- 24. Deg and rad with large values
print("math.deg(1e10): " .. string.format("%.2e", math.deg(1e10)))
print("math.rad(1e10): " .. string.format("%.6f", math.rad(1e10)))

-- 25. Atan2 edge cases
print("atan2(0, 0): " .. tostring(math.atan2(0, 0)))
print("atan2(1, 0): " .. tostring(math.atan2(1, 0)))
print("atan2(0, 1): " .. tostring(math.atan2(0, 1)))
print("atan2(inf, inf): " .. tostring(math.atan2(pos_inf, pos_inf)))

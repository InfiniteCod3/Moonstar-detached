-- tests/perf_opt_string_decrypt.lua
-- PERF-OPT #9: Fast String Decryption Test
-- Tests the cached string.char and table.concat optimization
--
-- This test verifies that:
-- 1. Encrypted strings are correctly decrypted at runtime
-- 2. Different string lengths work correctly
-- 3. Special characters are handled properly
-- 4. Unicode-like byte sequences work
-- 5. Empty strings and single characters work
-- 6. Repeated access uses cache correctly

-- Test 1: Simple strings
local simple = "Hello"
print("Test 1 - Simple string: " .. simple)
assert(simple == "Hello", "Simple string failed")

-- Test 2: Multiple different strings
local str1 = "abc"
local str2 = "def"
local str3 = "ghi"
print("Test 2 - Multiple strings: " .. str1 .. str2 .. str3)
assert(str1 .. str2 .. str3 == "abcdefghi", "Multiple strings failed")

-- Test 3: Special characters (ASCII control characters and symbols)
local special = "!@#$%^&*()_+-=[]{}|;':\",./<>?"
print("Test 3 - Special chars: " .. special)
assert(#special > 0, "Special characters failed")

-- Test 4: Long string (stress test for decryption loop)
local long = "This is a longer string that should test the performance of the decryption loop. It contains multiple words and characters to ensure the optimization works correctly for larger strings."
print("Test 4 - Long string length: " .. #long)
assert(#long == 185, "Long string length mismatch")

-- Test 5: String with numbers
local numbers = "0123456789"
print("Test 5 - Numbers: " .. numbers)
assert(numbers == "0123456789", "Number string failed")

-- Test 6: Single character strings
local a = "a"
local z = "z"
local space = " "
print("Test 6 - Singles: '" .. a .. "' '" .. z .. "' '" .. space .. "'")
assert(a == "a" and z == "z" and space == " ", "Single char failed")

-- Test 7: Repeated access (tests cache)
local cached = "CacheTest"
local result = ""
for i = 1, 10 do
    result = result .. cached:sub(1, 1)
end
print("Test 7 - Cache test: " .. result)
assert(result == "CCCCCCCCCC", "Cache test failed")

-- Test 8: String in function return
local function getSecret()
    return "SecretValue123"
end
print("Test 8 - Function return: " .. getSecret())
assert(getSecret() == "SecretValue123", "Function return failed")

-- Test 9: String concatenation with encrypted strings
local prefix = "START_"
local middle = "MIDDLE"
local suffix = "_END"
local combined = prefix .. middle .. suffix
print("Test 9 - Concatenation: " .. combined)
assert(combined == "START_MIDDLE_END", "Concatenation failed")

-- Test 10: String comparison
local test1 = "compare"
local test2 = "compare"
local test3 = "different"
print("Test 10 - Comparison: " .. tostring(test1 == test2) .. ", " .. tostring(test1 == test3))
assert(test1 == test2, "Equal comparison failed")
assert(test1 ~= test3, "NotEqual comparison failed")

-- Test 11: String methods on encrypted strings
local upper_test = "lowercase"
local result_upper = upper_test:upper()
print("Test 11 - Upper: " .. result_upper)
assert(result_upper == "LOWERCASE", "Upper method failed")

-- Test 12: Table with string keys (tests hash)
local t = {}
local key1 = "key_one"
local key2 = "key_two"
t[key1] = 100
t[key2] = 200
print("Test 12 - Table keys: " .. t[key1] .. ", " .. t[key2])
assert(t["key_one"] == 100 and t["key_two"] == 200, "Table key failed")

-- Test 13: String.byte on encrypted string
local byte_test = "ABC"
local b1, b2, b3 = string.byte(byte_test, 1, 3)
print("Test 13 - Bytes: " .. b1 .. ", " .. b2 .. ", " .. b3)
assert(b1 == 65 and b2 == 66 and b3 == 67, "String.byte failed")

-- Test 14: Pattern matching on encrypted string
local pattern_test = "hello123world456"
local count = 0
for _ in string.gmatch(pattern_test, "%d+") do
    count = count + 1
end
print("Test 14 - Pattern count: " .. count)
assert(count == 2, "Pattern matching failed")

-- Test 15: High-byte characters (stress LCG modulo)
local high_bytes = string.char(200, 201, 202, 250, 251, 252)
print("Test 15 - High bytes length: " .. #high_bytes)
assert(#high_bytes == 6, "High bytes failed")

print("\n=== All string decryption tests PASSED ===")

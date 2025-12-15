-- tests/string_edge_cases.lua
-- Edge cases for string encryption and manipulation

-- 1. Empty string
local empty = ""
print("empty length: " .. #empty)
print("empty == '': " .. tostring(empty == ""))

-- 2. Single character strings
print("A byte: " .. string.byte("A"))
print("char 65: " .. string.char(65))

-- 3. String with null bytes (embedded zeros)
local with_null = "hello\0world"
print("null string length: " .. #with_null)
print("null string sub 1-5: " .. string.sub(with_null, 1, 5))
print("null string sub 7-11: " .. string.sub(with_null, 7, 11))

-- 4. Escape sequences
local escapes = "tab:\there\nnewline\r\nwindows"
print("escapes length: " .. #escapes)

-- 5. Quote characters
local quotes = 'single\'quote and "double"'
print("quotes: " .. quotes)

-- 6. Backslash handling
local backslash = "path\\to\\file"
print("backslash: " .. backslash)

-- 7. Very long string (stress test for encryption)
local long_parts = {}
for i = 1, 100 do
    table.insert(long_parts, "segment" .. i)
end
local long_string = table.concat(long_parts, "-")
print("long string length: " .. #long_string)
print("long string start: " .. string.sub(long_string, 1, 30))
print("long string end: " .. string.sub(long_string, -30))

-- 8. Unicode-like multi-byte (actually just bytes > 127)
local high_bytes = string.char(128, 200, 255)
print("high bytes length: " .. #high_bytes)
print("high bytes byte 1: " .. string.byte(high_bytes, 1))
print("high bytes byte 2: " .. string.byte(high_bytes, 2))
print("high bytes byte 3: " .. string.byte(high_bytes, 3))

-- 9. String comparison
print("abc < abd: " .. tostring("abc" < "abd"))
print("abc == abc: " .. tostring("abc" == "abc"))
print("ABC < abc: " .. tostring("ABC" < "abc"))

-- 10. String concatenation edge cases
print("concat empty: " .. ("a" .. "" .. "b"))
print("concat numbers: " .. (1 .. 2 .. 3))

-- 11. String.format with various specifiers
print(string.format("int: %d", 42))
print(string.format("float: %.2f", 3.14159))
print(string.format("string: %s", "hello"))
print(string.format("hex: %x", 255))
print(string.format("octal: %o", 8))
print(string.format("char: %c", 65))
print(string.format("percent: %%"))
print(string.format("padded: %05d", 42))
print(string.format("left-pad: %-10s|", "hi"))

-- 12. String.find with patterns
local test_str = "hello world, hello lua"
local s, e = string.find(test_str, "hello")
print("find hello: " .. s .. "," .. e)
s, e = string.find(test_str, "hello", 10)
print("find hello from 10: " .. s .. "," .. e)
s, e = string.find(test_str, "xyz")
print("find xyz: " .. tostring(s))

-- 13. String.match
print("match word: " .. (string.match("hello world", "%w+") or "nil"))
print("match number: " .. (string.match("price: 42.50", "%d+%.%d+") or "nil"))
print("match capture: " .. (string.match("key=value", "(%w+)=(%w+)")))

-- 14. String.gmatch iterator
local words = {}
for word in string.gmatch("one two three four", "%w+") do
    table.insert(words, word)
end
print("gmatch words: " .. table.concat(words, ","))

-- 15. String.gsub with function
local result = string.gsub("hello world", "%w+", function(w)
    return string.upper(w)
end)
print("gsub upper: " .. result)

-- 16. String.gsub with table
local replacements = {hello = "hi", world = "earth"}
result = string.gsub("hello world", "%w+", replacements)
print("gsub table: " .. result)

-- 17. String.rep
print("rep: " .. string.rep("ab", 5))
print("rep zero: " .. string.rep("x", 0))

-- 18. String.reverse edge cases
print("reverse: " .. string.reverse("hello"))
print("reverse empty: " .. string.reverse(""))
print("reverse one: " .. string.reverse("x"))

-- 19. Numeric strings
print("tonumber: " .. tostring(tonumber("42")))
print("tonumber float: " .. tostring(tonumber("3.14")))
print("tonumber hex: " .. tostring(tonumber("0xff")))
print("tonumber invalid: " .. tostring(tonumber("abc")))

-- 20. String length with special chars
local special = "\a\b\f\n\r\t\v"
print("special chars length: " .. #special)

-- 21. Long bracket strings (if preserved through obfuscation)
local long_bracket = [[
This is a
multi-line
string
]]
print("long bracket lines: " .. select(2, string.gsub(long_bracket, "\n", "\n")))

-- 22. Nested bracket levels
local nested = [==[
Contains [[nested]] brackets
]==]
print("nested contains 'nested': " .. tostring(string.find(nested, "nested") ~= nil))

-- 23. String as table key
local str_key_table = {
    ["hello world"] = 1,
    ["with\nnewline"] = 2,
    ["with\0null"] = 3
}
print("string key 1: " .. str_key_table["hello world"])
print("string key 2: " .. str_key_table["with\nnewline"])
print("string key 3: " .. str_key_table["with\0null"])

-- 24. Binary-like string
local binary = ""
for i = 0, 255 do
    binary = binary .. string.char(i)
end
print("binary string length: " .. #binary)
print("binary byte 0: " .. string.byte(binary, 1))
print("binary byte 255: " .. string.byte(binary, 256))

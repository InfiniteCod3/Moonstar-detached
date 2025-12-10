-- String pattern matching tests
-- Tests Lua pattern matching for obfuscation compatibility

local testString = "Hello, World! The year is 2024 and the time is 12:30:45."

-- Basic pattern matching
print("Find 'World':", string.find(testString, "World"))
print("Match digits:", string.match(testString, "%d+"))
print("Match time:", string.match(testString, "%d+:%d+:%d+"))

-- Pattern captures
local year = string.match(testString, "year is (%d+)")
print("Captured year:", year)

local hour, min, sec = string.match(testString, "(%d+):(%d+):(%d+)")
print("Captured time:", hour, min, sec)

-- gmatch iterator
print("All words:")
for word in string.gmatch(testString, "%a+") do
    print(" ", word)
end

print("All numbers:")
for num in string.gmatch(testString, "%d+") do
    print(" ", num)
end

-- gsub with patterns
local replaced = string.gsub(testString, "%d+", "[NUM]")
print("Replace numbers:", replaced)

-- gsub with capture backreferences
local quoted = string.gsub("foo bar baz", "(%a+)", "'%1'")
print("Quoted words:", quoted)

-- gsub with function
local doubled = string.gsub("1 2 3 4 5", "(%d+)", function(n)
    return tostring(tonumber(n) * 2)
end)
print("Doubled numbers:", doubled)

-- Complex patterns
local email = "contact@example.com, support@test.org, admin@site.io"
print("Email usernames:")
for user in string.gmatch(email, "([%w%.]+)@") do
    print(" ", user)
end

-- Character classes
local classTest = "abc123XYZ!@#"
print("Lowercase:", string.match(classTest, "%l+"))
print("Uppercase:", string.match(classTest, "%u+"))
print("Alphanumeric:", string.match(classTest, "%w+"))
print("Punctuation:", string.match(classTest, "%p+"))

-- Frontier pattern (Lua 5.1+ compatible)
local words = "the cat sat on the mat"
local count = 0
for _ in string.gmatch(words, "the") do
    count = count + 1
end
print("Count 'the':", count)

-- Balanced pattern
local nested = "func(arg1, func2(nested), arg3)"
local inner = string.match(nested, "%((.-)%)")
print("First inner parens:", inner)

-- Split implementation using patterns
local function split(str, sep)
    local result = {}
    local pattern = string.format("([^%s]+)", sep)
    for match in string.gmatch(str, pattern) do
        table.insert(result, match)
    end
    return result
end

local csv = "apple,banana,cherry,date"
local parts = split(csv, ",")
print("Split CSV:")
for i, part in ipairs(parts) do
    print(" ", i, part)
end

-- Format with special characters
local formatted = string.format("Value: %d, String: %q, Float: %.2f", 42, "test", 3.14159)
print("Formatted:", formatted)

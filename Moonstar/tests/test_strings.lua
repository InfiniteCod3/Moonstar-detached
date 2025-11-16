-- String manipulation test
print("=== String Operations Test ===")

-- Basic string operations
local str1 = "Hello"
local str2 = "World"
local combined = str1 .. " " .. str2
print("Concatenation: " .. combined)

-- String methods
local text = "The quick brown fox jumps over the lazy dog"
print("Original: " .. text)
print("Length: " .. #text)
print("Uppercase: " .. string.upper(text))
print("Lowercase: " .. string.lower(text))

-- String find and sub
local sentence = "Lua is awesome!"
local start, finish = string.find(sentence, "awesome")
if start then
    print("Found 'awesome' at position: " .. start .. "-" .. finish)
    print("Extracted: " .. string.sub(sentence, start, finish))
end

-- String patterns
local code = "x = 42; y = 13; z = 7"
print("\nExtracting numbers from: " .. code)
for num in string.gmatch(code, "%d+") do
    print("  Found number: " .. num)
end

-- String formatting
local name = "Player"
local score = 9001
local level = 99
local message = string.format("%s has reached level %d with a score of %d points!", name, level, score)
print("\n" .. message)

-- Multi-line strings
local multiline = [[This is a
multi-line
string]]
print("Multi-line string:")
print(multiline)

-- String byte operations
local char = "A"
local byte = string.byte(char)
print("Character '" .. char .. "' has byte value: " .. byte)
print("Byte " .. byte .. " converts to: " .. string.char(byte))

-- String reverse
local word = "stressed"
local reversed = string.reverse(word)
print("\nReversed '" .. word .. "': " .. reversed)

print("\n=== String test complete ===")

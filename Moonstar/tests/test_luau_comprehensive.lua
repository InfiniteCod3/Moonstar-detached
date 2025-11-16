-- Comprehensive Luau Feature Test
-- Demonstrates all Luau-specific features supported by Moonstar Obfuscator
-- This file tests: type annotations, generics, compound assignments, 
-- string interpolation, if-then-else expressions, continue, and Roblox globals

print("=== Moonstar Luau Compatibility Test ===\n")

-- 1. Type Annotations (stripped during obfuscation)
print("1. Type Annotations:")
local name: string = "Moonstar"
local version: number = 2.4
local isActive: boolean = true
print("  Name:", name)
print("  Version:", version)
print("  Active:", isActive)

-- 2. Generic Functions (types stripped)
print("\n2. Generic Functions:")
function wrap<T>(value: T): T
    return value
end
print("  Wrapped value:", wrap(42))
print("  Wrapped string:", wrap("test"))

-- 3. Compound Assignments
print("\n3. Compound Assignments:")
local counter = 10
counter += 5  -- counter = counter + 5
counter -= 3  -- counter = counter - 3
counter *= 2  -- counter = counter * 2
print("  Counter after +=5, -=3, *=2:", counter) -- Should be 24

-- 4. String Interpolation (converted to concatenation)
print("\n4. String Interpolation:")
local user = "Player1"
local score = 150
local message = `{user} scored {score} points!`
print("  Message:", message)

-- 5. If-Then-Else Expressions (converted to ternary)
print("\n5. If-Then-Else Expressions:")
local level = 25
local difficulty = if level > 20 then "hard" else "easy"
print("  Difficulty:", difficulty)

local rank = if score > 100 then "Gold" else "Silver"
print("  Rank:", rank)

-- 6. Continue Statement (converted to goto)
print("\n6. Continue Statement:")
for i = 1, 10 do
    if i % 2 == 0 then
        continue
    end
    print("  Odd number:", i)
end

-- 7. Type Aliases (stripped during obfuscation)
type Point = {x: number, y: number}
type Vector = {x: number, y: number, z: number}

-- 8. Export Statements (handled)
export local publicValue = 100

-- 9. Combined Features
print("\n9. Combined Features:")
local playerName: string = "TestUser"
local playerScore: number = 200
local playerRank = if playerScore > 150 then "Expert" else "Beginner"
local announcement = `{playerName} achieved {playerRank} rank with {playerScore} points!`
print("  Announcement:", announcement)

-- 10. Roblox/Luau Standard Library Usage
print("\n10. Roblox/Luau Globals (preserved in obfuscation):")
-- These are preserved as-is during obfuscation
print("  typeof function:", type(typeof))
print("  task library:", type(task))

-- Demonstrate that type() function works correctly
print("\n11. Standard Lua Functions:")
print("  type(name):", type(name))
print("  type(counter):", type(counter))
print("  type(print):", type(print))

print("\n=== All Features Tested Successfully ===")

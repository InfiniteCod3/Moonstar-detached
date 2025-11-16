-- Test Luau-specific features

-- Type annotations
local x: number = 10
local y: string = "hello"
local z: boolean = true

-- Function with type annotations
function greet(name: string): string
    return "Hello, " .. name
end

-- Generics
function identity<T>(value: T): T
    return value
end

-- Compound assignments
local counter: number = 0
counter += 5
counter -= 2
counter *= 3

-- Continue statement
for i = 1, 10 do
    if i % 2 == 0 then
        continue
    end
    print("Odd number: " .. i)
end

-- Type alias
type Point = {x: number, y: number}

-- Export
export local myValue = 42

-- Regular Lua code
local result = greet("World")
print(result)
print("Counter: " .. counter)

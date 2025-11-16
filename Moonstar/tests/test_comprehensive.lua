-- Comprehensive test for obfuscation features
local function fibonacci(n)
    if n <= 1 then
        return n
    end
    return fibonacci(n - 1) + fibonacci(n - 2)
end

print("Fibonacci(10) = " .. fibonacci(10))

-- Table operations
local data = {x = 5, y = 10, z = 15}
local sum = data.x + data.y + data.z
print("Sum = " .. sum)

-- String operations
local message = "Hello" .. " " .. "World"
print(message)

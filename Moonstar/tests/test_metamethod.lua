-- Test script for metamethod obfuscation
local x = 10
local y = 20

local result = x + y
print("Addition result: " .. result)

local product = x * y
print("Multiplication result: " .. product)

local difference = y - x
print("Subtraction result: " .. difference)

-- Test table operations
local myTable = {a = 1, b = 2, c = 3}
print("Table value: " .. myTable.a)

-- Test function
local function calculate(a, b)
    return a + b * 2
end

print("Function result: " .. calculate(5, 10))

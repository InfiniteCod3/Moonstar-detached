-- Simple test file for obfuscator
local x = 10
local y = 20

function add(a, b)
    return a + b
end

local result = add(x, y)
print("Result: " .. result)

if result > 25 then
    print("Greater than 25")
else
    print("Less than or equal to 25")
end

for i = 1, 3 do
    print("Loop iteration: " .. i)
end

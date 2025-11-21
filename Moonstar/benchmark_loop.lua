local startTime = os.clock()

local t = {}
for i = 1, 1000000 do
    t[i] = i
end

local sum = 0
local startLoop = os.clock()
for k, v in ipairs(t) do
    sum = sum + v
end
local endLoop = os.clock()

print(string.format("Loop Time: %.4f seconds", endLoop - startLoop))
print(string.format("Total Time: %.4f seconds", endLoop - startTime))
print("Sum: " .. sum)

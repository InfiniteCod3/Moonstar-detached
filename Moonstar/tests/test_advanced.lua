-- Advanced test with closures, tables, and complex logic
print("=== Advanced Lua Features Test ===")

-- Closure test
local function makeCounter()
    local count = 0
    return function()
        count = count + 1
        return count
    end
end

local counter1 = makeCounter()
local counter2 = makeCounter()
print("Counter 1 first call: " .. counter1())
print("Counter 1 second call: " .. counter1())
print("Counter 2 first call: " .. counter2())
print("Counter 1 third call: " .. counter1())

-- Table manipulation
local inventory = {
    sword = 1,
    potion = 5,
    gold = 100
}

local function addItem(inv, item, count)
    if inv[item] then
        inv[item] = inv[item] + count
    else
        inv[item] = count
    end
end

addItem(inventory, "potion", 3)
addItem(inventory, "shield", 1)

print("\nInventory:")
for item, count in pairs(inventory) do
    print("  " .. item .. ": " .. count)
end

-- Metatables
local vector = {x = 3, y = 4}
local mt = {
    __add = function(a, b)
        return {x = a.x + b.x, y = a.y + b.y}
    end,
    __tostring = function(v)
        return "(" .. v.x .. ", " .. v.y .. ")"
    end
}
setmetatable(vector, mt)

local vector2 = {x = 1, y = 2}
setmetatable(vector2, mt)

local result = vector + vector2
setmetatable(result, mt)
print("\nVector addition: " .. tostring(vector) .. " + " .. tostring(vector2) .. " = " .. tostring(result))

-- Complex calculation
local function calculateStats(numbers)
    local sum = 0
    local min = numbers[1]
    local max = numbers[1]
    
    for _, num in ipairs(numbers) do
        sum = sum + num
        if num < min then min = num end
        if num > max then max = num end
    end
    
    return {
        sum = sum,
        average = sum / #numbers,
        min = min,
        max = max,
        count = #numbers
    }
end

local data = {5, 12, 3, 18, 7, 9, 15, 1}
local stats = calculateStats(data)
print("\nStatistics:")
print("  Count: " .. stats.count)
print("  Sum: " .. stats.sum)
print("  Average: " .. stats.average)
print("  Min: " .. stats.min)
print("  Max: " .. stats.max)

print("\n=== All tests passed ===")

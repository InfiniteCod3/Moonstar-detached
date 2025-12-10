-- Custom iterator and generator patterns
-- Tests proper handling of stateful iterators in obfuscated code

-- Simple range iterator
local function range(start, stop, step)
    step = step or 1
    local current = start - step
    
    return function()
        current = current + step
        if (step > 0 and current <= stop) or (step < 0 and current >= stop) then
            return current
        end
    end
end

print("Range 1-5:")
for i in range(1, 5) do
    print(i)
end

print("Range 10-1 step -2:")
for i in range(10, 1, -2) do
    print(i)
end

-- Stateful iterator with closure
local function enumerate(tbl)
    local index = 0
    local len = #tbl
    
    return function()
        index = index + 1
        if index <= len then
            return index, tbl[index]
        end
    end
end

local fruits = {"apple", "banana", "cherry", "date"}
print("Enumerate:")
for i, fruit in enumerate(fruits) do
    print(i, fruit)
end

-- Iterator with transformer
local function map(tbl, transform)
    local index = 0
    local len = #tbl
    
    return function()
        index = index + 1
        if index <= len then
            return transform(tbl[index], index)
        end
    end
end

print("Mapped (doubled):")
local numbers = {1, 2, 3, 4, 5}
for val in map(numbers, function(x) return x * 2 end) do
    print(val)
end

-- Filter iterator
local function filter(tbl, predicate)
    local index = 0
    local len = #tbl
    
    return function()
        while true do
            index = index + 1
            if index > len then
                return nil
            end
            if predicate(tbl[index]) then
                return tbl[index]
            end
        end
    end
end

print("Filtered (evens):")
for val in filter(numbers, function(x) return x % 2 == 0 end) do
    print(val)
end

-- Chained iterators (take pattern)
local function take(iterator, n)
    local count = 0
    return function()
        if count >= n then
            return nil
        end
        count = count + 1
        return iterator()
    end
end

print("Take 3 from infinite counter:")
local function infinity()
    local n = 0
    return function()
        n = n + 1
        return n
    end
end

local counter = infinity()
for v in take(counter, 3) do
    print(v)
end

-- Pairs-style iterator with multiple values
local function sortedPairs(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)
    
    local index = 0
    return function()
        index = index + 1
        local key = keys[index]
        if key then
            return key, tbl[key]
        end
    end
end

local data = {c = 3, a = 1, b = 2, d = 4}
print("Sorted pairs:")
for k, v in sortedPairs(data) do
    print(k, v)
end

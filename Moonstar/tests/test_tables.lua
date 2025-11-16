-- Table operations test
print("=== Table Operations Test ===")

-- Basic table creation
local fruits = {"apple", "banana", "orange", "grape"}
print("Fruits list:")
for i, fruit in ipairs(fruits) do
    print("  " .. i .. ": " .. fruit)
end

-- Table as dictionary
local person = {
    name = "John Doe",
    age = 30,
    city = "New York",
    occupation = "Developer"
}

print("\nPerson info:")
for key, value in pairs(person) do
    print("  " .. key .. ": " .. tostring(value))
end

-- Nested tables
local company = {
    name = "TechCorp",
    employees = {
        {name = "Alice", role = "Manager", salary = 80000},
        {name = "Bob", role = "Developer", salary = 70000},
        {name = "Charlie", role = "Designer", salary = 65000}
    },
    departments = {
        engineering = 15,
        design = 8,
        marketing = 10
    }
}

print("\nCompany: " .. company.name)
print("Employees:")
for _, emp in ipairs(company.employees) do
    print("  " .. emp.name .. " - " .. emp.role .. " ($" .. emp.salary .. ")")
end

print("Departments:")
for dept, count in pairs(company.departments) do
    print("  " .. dept .. ": " .. count .. " people")
end

-- Table manipulation functions
local function insertItem(tbl, item)
    table.insert(tbl, item)
end

local function removeItem(tbl, index)
    return table.remove(tbl, index)
end

local numbers = {10, 20, 30}
print("\nOriginal numbers:")
for i, v in ipairs(numbers) do
    print("  " .. i .. ": " .. v)
end

insertItem(numbers, 40)
insertItem(numbers, 50)
print("After inserting 40 and 50:")
for i, v in ipairs(numbers) do
    print("  " .. i .. ": " .. v)
end

local removed = removeItem(numbers, 2)
print("Removed: " .. removed)
print("After removal:")
for i, v in ipairs(numbers) do
    print("  " .. i .. ": " .. v)
end

-- Table sorting
local unsorted = {15, 3, 42, 8, 23, 4, 16}
print("\nUnsorted: " .. table.concat(unsorted, ", "))
table.sort(unsorted)
print("Sorted: " .. table.concat(unsorted, ", "))

-- Custom sort
local items = {
    {name = "Sword", value = 100},
    {name = "Potion", value = 25},
    {name = "Shield", value = 75},
    {name = "Gem", value = 200}
}

table.sort(items, function(a, b)
    return a.value > b.value
end)

print("\nItems sorted by value (descending):")
for _, item in ipairs(items) do
    print("  " .. item.name .. ": $" .. item.value)
end

-- Table concatenation
local words = {"Lua", "is", "awesome"}
local sentence = table.concat(words, " ")
print("\nConcatenated: " .. sentence)

-- Copying tables (shallow copy)
local original = {a = 1, b = 2, c = 3}
local copy = {}
for k, v in pairs(original) do
    copy[k] = v
end

copy.d = 4
print("\nOriginal table:")
for k, v in pairs(original) do
    print("  " .. k .. " = " .. v)
end
print("Copied table:")
for k, v in pairs(copy) do
    print("  " .. k .. " = " .. v)
end

-- Table length
print("\nArray length: " .. #fruits)
print("After adding items:")
table.insert(fruits, "mango")
table.insert(fruits, "pineapple")
print("New length: " .. #fruits)

-- Mixed keys
local mixed = {
    10, 20, 30,  -- array part
    x = 100,     -- hash part
    y = 200,
    40, 50       -- more array part
}

print("\nArray part:")
for i = 1, #mixed do
    print("  " .. i .. ": " .. mixed[i])
end

print("Hash part:")
print("  x: " .. mixed.x)
print("  y: " .. mixed.y)

print("\n=== Table operations test complete ===")

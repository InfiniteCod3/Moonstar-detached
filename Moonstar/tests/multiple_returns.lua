-- Multiple return values and complex unpacking
-- Tests proper handling of multi-return functions in obfuscated code

local function multiReturn()
    return 1, 2, 3, 4, 5
end

local a, b, c, d, e = multiReturn()
print("Unpacked all:", a, b, c, d, e)

local x, y = multiReturn()
print("Unpacked first two:", x, y)

local first = multiReturn()
print("Unpacked only first:", first)

-- Return value adjustment in expressions
local function sum(...)
    local total = 0
    for _, v in ipairs({...}) do
        total = total + v
    end
    return total
end

print("Sum of multi-return:", sum(multiReturn()))

-- Multi-return in table constructor
local tbl = {multiReturn()}
print("In table:", #tbl, "elements")
for i, v in ipairs(tbl) do
    print(" ", i, v)
end

-- Trailing multi-return
local mixed = {100, multiReturn()}
print("Mixed table:", #mixed, "elements")
for i, v in ipairs(mixed) do
    print(" ", i, v)
end

-- Multi-return only uses first when not trailing
local partial = {multiReturn(), 200}
print("Partial table:", #partial, "elements")
for i, v in ipairs(partial) do
    print(" ", i, v)
end

-- Nested multi-return
local function wrapper()
    return multiReturn()
end

local w1, w2, w3 = wrapper()
print("Wrapped:", w1, w2, w3)

-- Conditional multi-return
local function conditionalReturn(useMulti)
    if useMulti then
        return 10, 20, 30
    else
        return 100
    end
end

local c1, c2, c3 = conditionalReturn(true)
print("Conditional true:", c1, c2, c3)

local c4, c5, c6 = conditionalReturn(false)
print("Conditional false:", c4, c5, c6)

-- Multi-return with select
local function selectTest()
    return "a", "b", "c", "d", "e"
end

print("Select 3:", select(3, selectTest()))
print("Select count:", select("#", selectTest()))

-- Multi-return assignment with extra values
local r1, r2, r3, r4, r5, r6, r7 = multiReturn()
print("Extra variables:", r1, r2, r3, r4, r5, r6, r7)

-- Return from nested call
local function outer()
    local function inner()
        return "inner1", "inner2"
    end
    return inner(), "outer"
end

local o1, o2, o3 = outer()
print("Nested return:", o1, o2, o3)

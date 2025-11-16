-- Function features test
print("=== Function Features Test ===")

-- Simple functions
local function greet(name)
    return "Hello, " .. name .. "!"
end

print(greet("Alice"))
print(greet("Bob"))

-- Multiple return values
local function minMax(a, b, c)
    local min = a
    local max = a
    
    if b < min then min = b end
    if c < min then min = c end
    if b > max then max = b end
    if c > max then max = c end
    
    return min, max
end

local minimum, maximum = minMax(15, 3, 42)
print("\nMin: " .. minimum .. ", Max: " .. maximum)

-- Variable arguments
local function sum(...)
    local args = {...}
    local total = 0
    for _, v in ipairs(args) do
        total = total + v
    end
    return total
end

print("Sum of 1,2,3,4,5: " .. sum(1, 2, 3, 4, 5))
print("Sum of 10,20,30: " .. sum(10, 20, 30))

-- Higher-order functions
local function applyOperation(operation, a, b)
    return operation(a, b)
end

local add = function(x, y) return x + y end
local multiply = function(x, y) return x * y end
local power = function(x, y) return x ^ y end

print("\nHigher-order functions:")
print("5 + 3 = " .. applyOperation(add, 5, 3))
print("5 * 3 = " .. applyOperation(multiply, 5, 3))
print("2 ^ 8 = " .. applyOperation(power, 2, 8))

-- Recursive functions
local function factorial(n)
    if n <= 1 then
        return 1
    end
    return n * factorial(n - 1)
end

print("\nFactorials:")
for i = 1, 7 do
    print("  " .. i .. "! = " .. factorial(i))
end

-- Tail recursion simulation
local function sumRange(n, acc)
    acc = acc or 0
    if n == 0 then
        return acc
    end
    return sumRange(n - 1, acc + n)
end

print("\nSum of 1 to 100: " .. sumRange(100))

-- Anonymous functions
local operations = {
    add = function(a, b) return a + b end,
    sub = function(a, b) return a - b end,
    mul = function(a, b) return a * b end,
    div = function(a, b) return a / b end
}

print("\nAnonymous functions:")
print("10 + 5 = " .. operations.add(10, 5))
print("10 - 5 = " .. operations.sub(10, 5))
print("10 * 5 = " .. operations.mul(10, 5))
print("10 / 5 = " .. operations.div(10, 5))

-- Function as table methods
local calculator = {
    value = 0,
    add = function(self, n)
        self.value = self.value + n
        return self
    end,
    multiply = function(self, n)
        self.value = self.value * n
        return self
    end,
    result = function(self)
        return self.value
    end,
    reset = function(self)
        self.value = 0
        return self
    end
}

calculator.value = 10
calculator:add(5):multiply(3):add(2)
-- Expected: 10 + 5 = 15, 15 * 3 = 45, 45 + 2 = 47
print("\nChained operations: " .. calculator:result())

print("\n=== Function test complete ===")

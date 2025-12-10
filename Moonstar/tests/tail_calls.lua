-- Tail call and recursion tests
-- Tests proper tail call optimization handling in obfuscated code

-- Classic tail-recursive factorial
local function factorialTail(n, acc)
    acc = acc or 1
    if n <= 1 then
        return acc
    end
    return factorialTail(n - 1, n * acc)
end

print("Factorial 10:", factorialTail(10))
print("Factorial 15:", factorialTail(15))

-- Tail-recursive sum
local function sumTail(n, acc)
    acc = acc or 0
    if n <= 0 then
        return acc
    end
    return sumTail(n - 1, acc + n)
end

print("Sum 1-100:", sumTail(100))

-- Mutual recursion with tail calls
local isEven, isOdd

isEven = function(n)
    if n == 0 then return true end
    return isOdd(n - 1)
end

isOdd = function(n)
    if n == 0 then return false end
    return isEven(n - 1)
end

print("10 is even:", isEven(10))
print("10 is odd:", isOdd(10))
print("15 is even:", isEven(15))
print("15 is odd:", isOdd(15))

-- Tail-recursive fibonacci with accumulator
local function fibTail(n, a, b)
    a = a or 0
    b = b or 1
    if n == 0 then
        return a
    elseif n == 1 then
        return b
    end
    return fibTail(n - 1, b, a + b)
end

print("Fibonacci 20:", fibTail(20))
print("Fibonacci 30:", fibTail(30))

-- Continuation passing style
local function cpsFold(list, fn, acc, cont)
    cont = cont or function(x) return x end
    if #list == 0 then
        return cont(acc)
    end
    local first = list[1]
    local rest = {}
    for i = 2, #list do
        table.insert(rest, list[i])
    end
    return cpsFold(rest, fn, fn(acc, first), cont)
end

local nums = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
print("CPS fold sum:", cpsFold(nums, function(a, b) return a + b end, 0))
print("CPS fold product:", cpsFold(nums, function(a, b) return a * b end, 1))

-- Trampoline pattern for deep recursion
local function trampoline(fn)
    local result = fn
    while type(result) == "function" do
        result = result()
    end
    return result
end

local function trampolineFact(n, acc)
    acc = acc or 1
    if n <= 1 then
        return acc
    end
    return function()
        return trampolineFact(n - 1, n * acc)
    end
end

print("Trampoline factorial 10:", trampoline(function() return trampolineFact(10) end))

-- GCD with tail recursion
local function gcd(a, b)
    if b == 0 then
        return a
    end
    return gcd(b, a % b)
end

print("GCD(48, 18):", gcd(48, 18))
print("GCD(100, 35):", gcd(100, 35))

-- Ackermann function (non-tail recursive for stress test)
local function ackermann(m, n)
    if m == 0 then
        return n + 1
    elseif n == 0 then
        return ackermann(m - 1, 1)
    else
        return ackermann(m - 1, ackermann(m, n - 1))
    end
end

print("Ackermann(2, 3):", ackermann(2, 3))
print("Ackermann(3, 3):", ackermann(3, 3))

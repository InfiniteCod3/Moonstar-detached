-- tests/deep_recursion.lua
-- Tests deep recursion to verify VM call stack handling

-- 1. Simple deep recursion (sum to n)
local function sum_recursive(n)
    if n <= 0 then return 0 end
    return n + sum_recursive(n - 1)
end
print("sum 1-100: " .. sum_recursive(100))

-- 2. Fibonacci with memoization (tests upvalues + recursion)
local function make_fib()
    local cache = {}
    local function fib(n)
        if n <= 1 then return n end
        if cache[n] then return cache[n] end
        cache[n] = fib(n - 1) + fib(n - 2)
        return cache[n]
    end
    return fib
end

local fib = make_fib()
print("fib(20): " .. fib(20))
print("fib(25): " .. fib(25))

-- 3. Mutual recursion (even/odd check)
local is_even, is_odd

is_even = function(n)
    if n == 0 then return true end
    return is_odd(n - 1)
end

is_odd = function(n)
    if n == 0 then return false end
    return is_even(n - 1)
end

print("is_even(50): " .. tostring(is_even(50)))
print("is_odd(51): " .. tostring(is_odd(51)))
print("is_even(49): " .. tostring(is_even(49)))

-- 4. Tree traversal simulation
local function build_tree(depth, current)
    current = current or 1
    if depth <= 0 then
        return {value = current, left = nil, right = nil}
    end
    return {
        value = current,
        left = build_tree(depth - 1, current * 2),
        right = build_tree(depth - 1, current * 2 + 1)
    }
end

local function sum_tree(node)
    if not node then return 0 end
    return node.value + sum_tree(node.left) + sum_tree(node.right)
end

local tree = build_tree(6)  -- 127 nodes
print("tree sum depth 6: " .. sum_tree(tree))

-- 5. Ackermann function (limited, tests deep call stacks)
local function ackermann(m, n)
    if m == 0 then return n + 1 end
    if n == 0 then return ackermann(m - 1, 1) end
    return ackermann(m - 1, ackermann(m, n - 1))
end

print("ackermann(2,3): " .. ackermann(2, 3))
print("ackermann(3,3): " .. ackermann(3, 3))

-- 6. Recursive string building
local function build_string(n, acc)
    acc = acc or ""
    if n <= 0 then return acc end
    return build_string(n - 1, acc .. string.char(65 + (n % 26)))
end

local built = build_string(50)
print("built string length: " .. #built)
print("built string start: " .. string.sub(built, 1, 10))

-- 7. Recursive table building
local function build_nested_table(depth)
    if depth <= 0 then
        return {leaf = true}
    end
    return {child = build_nested_table(depth - 1)}
end

local function count_depth(t, current)
    current = current or 0
    if t.leaf then return current end
    return count_depth(t.child, current + 1)
end

local nested = build_nested_table(50)
print("nested table depth: " .. count_depth(nested))

-- 8. Recursive with multiple return values
local function gcd_extended(a, b)
    if b == 0 then
        return a, 1, 0
    end
    local g, x, y = gcd_extended(b, a % b)
    return g, y, x - math.floor(a / b) * y
end

local g, x, y = gcd_extended(35, 15)
print("gcd(35,15): " .. g)
print("coefficients: " .. x .. ", " .. y)

-- 9. Recursive list processing
local function make_list(n)
    if n <= 0 then return nil end
    return {value = n, next = make_list(n - 1)}
end

local function list_sum(node)
    if not node then return 0 end
    return node.value + list_sum(node.next)
end

local function list_length(node)
    if not node then return 0 end
    return 1 + list_length(node.next)
end

local mylist = make_list(100)
print("list length: " .. list_length(mylist))
print("list sum: " .. list_sum(mylist))

-- 10. Quicksort (recursive algorithm)
local function quicksort(arr, low, high)
    low = low or 1
    high = high or #arr

    if low < high then
        -- Partition
        local pivot = arr[high]
        local i = low - 1

        for j = low, high - 1 do
            if arr[j] <= pivot then
                i = i + 1
                arr[i], arr[j] = arr[j], arr[i]
            end
        end
        arr[i + 1], arr[high] = arr[high], arr[i + 1]
        local pi = i + 1

        quicksort(arr, low, pi - 1)
        quicksort(arr, pi + 1, high)
    end
    return arr
end

local test_array = {64, 34, 25, 12, 22, 11, 90, 5, 77, 30}
quicksort(test_array)
print("sorted: " .. table.concat(test_array, ","))

-- 11. Mergesort (another recursive algorithm)
local function mergesort(arr)
    if #arr <= 1 then return arr end

    local mid = math.floor(#arr / 2)
    local left = {}
    local right = {}

    for i = 1, mid do left[#left + 1] = arr[i] end
    for i = mid + 1, #arr do right[#right + 1] = arr[i] end

    left = mergesort(left)
    right = mergesort(right)

    -- Merge
    local result = {}
    local i, j = 1, 1
    while i <= #left and j <= #right do
        if left[i] <= right[j] then
            result[#result + 1] = left[i]
            i = i + 1
        else
            result[#result + 1] = right[j]
            j = j + 1
        end
    end
    while i <= #left do
        result[#result + 1] = left[i]
        i = i + 1
    end
    while j <= #right do
        result[#result + 1] = right[j]
        j = j + 1
    end
    return result
end

local merge_test = {3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5}
local merge_sorted = mergesort(merge_test)
print("mergesorted: " .. table.concat(merge_sorted, ","))

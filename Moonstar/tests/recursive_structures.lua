-- Recursive data structures and deep operations
-- Tests obfuscator handling of recursive/nested data

-- Deep nested table creation
local function createDeepTable(depth, value)
    if depth <= 0 then
        return value
    end
    return {
        value = value,
        depth = depth,
        child = createDeepTable(depth - 1, value + 1)
    }
end

local deep = createDeepTable(5, 0)

-- Deep traversal
local function traverse(node, path)
    path = path or ""
    if type(node) ~= "table" then
        print(path .. " = " .. tostring(node))
        return
    end
    for k, v in pairs(node) do
        traverse(v, path .. "." .. k)
    end
end

print("Deep table traversal:")
traverse(deep)

-- Deep copy function
local function deepCopy(obj, seen)
    if type(obj) ~= "table" then
        return obj
    end
    seen = seen or {}
    if seen[obj] then
        return seen[obj]
    end
    local copy = {}
    seen[obj] = copy
    for k, v in pairs(obj) do
        copy[deepCopy(k, seen)] = deepCopy(v, seen)
    end
    return setmetatable(copy, getmetatable(obj))
end

local copied = deepCopy(deep)
print("Deep copy value:", copied.child.child.value)

-- Circular reference handling
local circular = {name = "parent"}
circular.self = circular
circular.children = {circular, circular}

local function safeToString(obj, seen)
    if type(obj) ~= "table" then
        return tostring(obj)
    end
    seen = seen or {}
    if seen[obj] then
        return "[circular]"
    end
    seen[obj] = true
    local parts = {}
    for k, v in pairs(obj) do
        table.insert(parts, tostring(k) .. "=" .. safeToString(v, seen))
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

print("Circular structure:", safeToString(circular))

-- Tree structure with operations
local function createTree(value, left, right)
    return {value = value, left = left, right = right}
end

local tree = createTree(
    10,
    createTree(5, createTree(2), createTree(7)),
    createTree(15, createTree(12), createTree(20))
)

-- In-order traversal
local function inOrder(node, result)
    result = result or {}
    if node then
        inOrder(node.left, result)
        table.insert(result, node.value)
        inOrder(node.right, result)
    end
    return result
end

print("Tree in-order:", table.concat(inOrder(tree), ", "))

-- Tree height
local function treeHeight(node)
    if not node then
        return 0
    end
    return 1 + math.max(treeHeight(node.left), treeHeight(node.right))
end

print("Tree height:", treeHeight(tree))

-- Linked list
local function createList(values)
    local head = nil
    for i = #values, 1, -1 do
        head = {value = values[i], next = head}
    end
    return head
end

local function listToTable(node)
    local result = {}
    while node do
        table.insert(result, node.value)
        node = node.next
    end
    return result
end

local list = createList({1, 2, 3, 4, 5})
print("Linked list:", table.concat(listToTable(list), " -> "))

-- Reverse linked list
local function reverseList(node)
    local prev = nil
    while node do
        local next = node.next
        node.next = prev
        prev = node
        node = next
    end
    return prev
end

list = reverseList(list)
print("Reversed list:", table.concat(listToTable(list), " -> "))

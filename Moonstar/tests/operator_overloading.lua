-- Operator overloading with metamethods
-- Tests comprehensive metamethod handling in obfuscated code

-- Vector2 class with full operator support
local Vector2 = {}
Vector2.__index = Vector2

function Vector2.new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vector2)
end

function Vector2:__tostring()
    return string.format("Vector2(%.2f, %.2f)", self.x, self.y)
end

function Vector2.__add(a, b)
    return Vector2.new(a.x + b.x, a.y + b.y)
end

function Vector2.__sub(a, b)
    return Vector2.new(a.x - b.x, a.y - b.y)
end

function Vector2.__mul(a, b)
    if type(a) == "number" then
        return Vector2.new(a * b.x, a * b.y)
    elseif type(b) == "number" then
        return Vector2.new(a.x * b, a.y * b)
    else
        return a.x * b.x + a.y * b.y  -- Dot product
    end
end

function Vector2.__div(a, b)
    return Vector2.new(a.x / b, a.y / b)
end

function Vector2.__unm(v)
    return Vector2.new(-v.x, -v.y)
end

function Vector2.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

function Vector2.__lt(a, b)
    return (a.x * a.x + a.y * a.y) < (b.x * b.x + b.y * b.y)
end

function Vector2.__le(a, b)
    return (a.x * a.x + a.y * a.y) <= (b.x * b.x + b.y * b.y)
end

function Vector2.__len(v)
    return math.sqrt(v.x * v.x + v.y * v.y)
end

function Vector2.__concat(a, b)
    return tostring(a) .. " | " .. tostring(b)
end

local v1 = Vector2.new(3, 4)
local v2 = Vector2.new(1, 2)

print("v1:", v1)
print("v2:", v2)
print("v1 + v2:", v1 + v2)
print("v1 - v2:", v1 - v2)
print("v1 * 2:", v1 * 2)
print("3 * v2:", 3 * v2)
print("v1 * v2 (dot):", v1 * v2)
print("v1 / 2:", v1 / 2)
print("-v1:", -v1)
print("v1 == v1:", v1 == Vector2.new(3, 4))
print("v1 == v2:", v1 == v2)
print("v1 < v2:", v1 < v2)
print("v2 < v1:", v2 < v1)
print("v1 .. v2:", v1 .. v2)

-- Proxy table with complete metamethod set
local function createProxy(target)
    local proxy = {}
    local mt = {
        __index = function(_, key)
            print("GET:", key)
            return target[key]
        end,
        __newindex = function(_, key, value)
            print("SET:", key, "=", value)
            target[key] = value
        end,
        __pairs = function()
            return pairs(target)
        end,
        __ipairs = function()
            return ipairs(target)
        end,
        __call = function(_, ...)
            print("CALL with", select("#", ...), "args")
            return target
        end
    }
    return setmetatable(proxy, mt)
end

local data = {a = 1, b = 2, c = 3}
local proxy = createProxy(data)

print("\nProxy operations:")
print("Access a:", proxy.a)
proxy.d = 4
print("New value d:", proxy.d)

print("\nIterating proxy:")
for k, v in pairs(proxy) do
    print(" ", k, v)
end

-- Callable table
local callable = setmetatable({
    name = "Calculator"
}, {
    __call = function(self, op, a, b)
        if op == "add" then return a + b
        elseif op == "sub" then return a - b
        elseif op == "mul" then return a * b
        elseif op == "div" then return a / b
        end
    end
})

print("\nCallable table:")
print("add(5, 3) =", callable("add", 5, 3))
print("mul(4, 7) =", callable("mul", 4, 7))

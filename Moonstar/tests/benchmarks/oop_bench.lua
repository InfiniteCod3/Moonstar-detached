-- Benchmark: OOP Patterns
-- Tests object-oriented programming patterns performance

local ITERATIONS = 10000

-- Simple table-based objects
local function simple_object_bench()
    local sum = 0
    for i = 1, ITERATIONS do
        local obj = {
            value = i,
            get = function(self) return self.value end,
            set = function(self, v) self.value = v end
        }
        obj:set(obj:get() + 1)
        sum = sum + obj:get()
    end
    return sum
end

-- Constructor pattern
local function make_counter(initial)
    local count = initial or 0
    return {
        inc = function() count = count + 1 end,
        dec = function() count = count - 1 end,
        get = function() return count end
    }
end

local function constructor_bench()
    local sum = 0
    for i = 1, ITERATIONS do
        local c = make_counter(i)
        c.inc()
        c.inc()
        c.dec()
        sum = sum + c.get()
    end
    return sum
end

-- Prototype/Class pattern
local Animal = {}
Animal.__index = Animal

function Animal:new(name)
    return setmetatable({ name = name, energy = 100 }, self)
end

function Animal:speak()
    return self.name
end

function Animal:eat()
    self.energy = self.energy + 10
    return self.energy
end

local Dog = setmetatable({}, { __index = Animal })
Dog.__index = Dog

function Dog:new(name)
    local instance = Animal.new(self, name)
    instance.breed = "unknown"
    return setmetatable(instance, self)
end

function Dog:bark()
    self.energy = self.energy - 5
    return "woof"
end

local function inheritance_bench()
    local sum = 0
    for i = 1, ITERATIONS do
        local dog = Dog:new("dog_" .. i)
        dog:eat()
        dog:bark()
        sum = sum + dog.energy
    end
    return sum
end

-- Method chaining
local Builder = {}
Builder.__index = Builder

function Builder:new()
    return setmetatable({ parts = {} }, self)
end

function Builder:add(part)
    self.parts[#self.parts + 1] = part
    return self
end

function Builder:build()
    return table.concat(self.parts, "-")
end

local function chaining_bench()
    local results = {}
    for i = 1, ITERATIONS do
        results[i] = Builder:new()
            :add("a")
            :add("b")
            :add("c")
            :build()
    end
    return #results[ITERATIONS]
end

-- Polymorphism
local Shape = {}
Shape.__index = Shape
function Shape:new() return setmetatable({}, self) end
function Shape:area() return 0 end

local Circle = setmetatable({}, { __index = Shape })
Circle.__index = Circle
function Circle:new(r) 
    local o = Shape.new(self)
    o.radius = r
    return setmetatable(o, self)
end
function Circle:area() return 3.14159 * self.radius * self.radius end

local Rect = setmetatable({}, { __index = Shape })
Rect.__index = Rect
function Rect:new(w, h)
    local o = Shape.new(self)
    o.width, o.height = w, h
    return setmetatable(o, self)
end
function Rect:area() return self.width * self.height end

local function polymorphism_bench()
    local shapes = {}
    for i = 1, 1000 do
        if i % 2 == 0 then
            shapes[i] = Circle:new(i % 10 + 1)
        else
            shapes[i] = Rect:new(i % 10 + 1, i % 5 + 1)
        end
    end
    local total = 0
    for _, shape in ipairs(shapes) do
        total = total + shape:area()
    end
    return math.floor(total)
end

local start = os.clock()
local simple_result = simple_object_bench()
local constructor_result = constructor_bench()
local inherit_result = inheritance_bench()
local chain_result = chaining_bench()
local poly_result = polymorphism_bench()
local elapsed = os.clock() - start

print("simple:", simple_result)
print("constructor:", constructor_result)
print("inheritance:", inherit_result)
print("chaining:", chain_result)
print("polymorphism:", poly_result)
print(string.format("elapsed: %.4f", elapsed))

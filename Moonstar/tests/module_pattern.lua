-- Module pattern tests
-- Tests common Lua module patterns for obfuscation compatibility

-- Classic module pattern with private state
local function createModule()
    local private = {
        counter = 0,
        data = {}
    }
    
    local module = {}
    
    function module.increment()
        private.counter = private.counter + 1
        return private.counter
    end
    
    function module.decrement()
        private.counter = private.counter - 1
        return private.counter
    end
    
    function module.set(key, value)
        private.data[key] = value
    end
    
    function module.get(key)
        return private.data[key]
    end
    
    function module.getCount()
        return private.counter
    end
    
    return module
end

local mod = createModule()
print("Count:", mod.getCount())
print("Increment:", mod.increment())
print("Increment:", mod.increment())
print("Decrement:", mod.decrement())

mod.set("name", "TestModule")
mod.set("version", 1)
print("Name:", mod.get("name"))
print("Version:", mod.get("version"))

-- Prototype-based inheritance pattern
local function createClass(base)
    local class = {}
    class.__index = class
    
    if base then
        setmetatable(class, {__index = base})
    end
    
    function class:new(...)
        local instance = setmetatable({}, class)
        if instance.init then
            instance:init(...)
        end
        return instance
    end
    
    return class
end

local Animal = createClass()

function Animal:init(name)
    self.name = name
end

function Animal:speak()
    return self.name .. " makes a sound"
end

local Dog = createClass(Animal)

function Dog:init(name, breed)
    Animal.init(self, name)
    self.breed = breed
end

function Dog:speak()
    return self.name .. " barks!"
end

function Dog:describe()
    return self.name .. " is a " .. self.breed
end

local animal = Animal:new("Generic")
local dog = Dog:new("Buddy", "Labrador")

print("Animal speaks:", animal:speak())
print("Dog speaks:", dog:speak())
print("Dog description:", dog:describe())

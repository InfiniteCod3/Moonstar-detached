-- Environment and scope manipulation tests  
-- Tests proper _ENV/_G handling in obfuscated code

-- Access global environment
print("_G.print exists:", _G.print ~= nil)
print("_G.math exists:", _G.math ~= nil)

-- Create custom global
_G.customGlobal = "Hello from global"
print("Custom global:", customGlobal)

-- Dynamic global access
local function getGlobal(name)
    return _G[name]
end

local function setGlobal(name, value)
    _G[name] = value
end

setGlobal("dynamicVar", 42)
print("Dynamic var:", getGlobal("dynamicVar"))

-- Sandboxed environment function (Lua 5.1 compatible)
local function createSandbox()
    local env = {
        print = print,
        tostring = tostring,
        tonumber = tonumber,
        type = type,
        pairs = pairs,
        ipairs = ipairs,
        math = math,
        string = string,
        table = table
    }
    env._G = env
    return env
end

-- Simulate sandboxed execution
local sandbox = createSandbox()
sandbox.safeVar = "Safe value"

-- Using setfenv for Lua 5.1 or load with env for 5.2+
local code = [[
    safeVar = safeVar .. " modified"
    return safeVar
]]

local fn, err
if setfenv then
    -- Lua 5.1
    fn = loadstring(code)
    if fn then
        setfenv(fn, sandbox)
    end
else
    -- Lua 5.2+
    fn = load(code, "sandbox", "t", sandbox)
end

if fn then
    local result = fn()
    print("Sandboxed result:", result)
else
    print("Sandbox test skipped (compilation issue)")
end

-- Module-like environment isolation
local function createModule()
    local _ENV = {}
    
    local privateData = {
        counter = 0
    }
    
    function increment()
        privateData.counter = privateData.counter + 1
        return privateData.counter
    end
    
    function getCount()
        return privateData.counter
    end
    
    return {
        increment = increment,
        getCount = getCount
    }
end

local myModule = createModule()
print("Module counter:", myModule.getCount())
print("After increment:", myModule.increment())
print("After increment:", myModule.increment())

-- Upvalue inspection
local function testUpvalues()
    local a = 10
    local b = 20
    local c = 30
    
    local function inner()
        return a + b + c
    end
    
    local function modify()
        a = a * 2
        b = b * 2
        c = c * 2
    end
    
    return inner, modify
end

local getter, modifier = testUpvalues()
print("Initial upvalue sum:", getter())
modifier()
print("After modify:", getter())

-- Cleanup
_G.customGlobal = nil
_G.dynamicVar = nil

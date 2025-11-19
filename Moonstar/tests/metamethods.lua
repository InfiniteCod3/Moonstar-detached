local mt = {}
mt.__add = function(a, b)
    return setmetatable({value = a.value + b.value}, mt)
end
mt.__tostring = function(t)
    return "Value: " .. tostring(t.value)
end
mt.__call = function(t, ...)
    local args = {...}
    return "Called with " .. #args .. " args"
end

local t1 = setmetatable({value = 10}, mt)
local t2 = setmetatable({value = 20}, mt)

local t3 = t1 + t2
print(tostring(t3))
print(t3(1, 2, 3))

local t4 = {
    data = {}
}
local mt2 = {
    __newindex = function(t, k, v)
        print("Setting " .. k .. " to " .. v)
        rawset(t.data, k, v)
    end,
    __index = function(t, k)
        print("Getting " .. k)
        return rawget(t.data, k)
    end
}
setmetatable(t4, mt2)
t4.x = 100
print(t4.x)

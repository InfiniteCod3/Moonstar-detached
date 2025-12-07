-- Aurora typeof Implementation
-- Roblox-style typeof that returns specific type names

local typeRegistry = {}

--- Registers a custom type for typeof detection
---@param metatable table The metatable to register
---@param typeName string The type name to return
local function registerType(metatable, typeName)
    typeRegistry[metatable] = typeName
end

--- Roblox-compatible typeof function
---@param value any The value to get the type of
---@return string The type name
local function typeof(value)
    local luaType = type(value)
    
    if luaType == "table" then
        local mt = getmetatable(value)
        if mt then
            -- Check registered types
            if typeRegistry[mt] then
                return typeRegistry[mt]
            end
            -- Check for __type field
            if mt.__type then
                return mt.__type
            end
        end
        return "table"
    elseif luaType == "userdata" then
        local mt = getmetatable(value)
        if mt and typeRegistry[mt] then
            return typeRegistry[mt]
        end
        return "userdata"
    end
    
    return luaType
end

return {
    typeof = typeof,
    registerType = registerType,
    typeRegistry = typeRegistry
}

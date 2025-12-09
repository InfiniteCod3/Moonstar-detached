-- optimization.lua
-- VMify enhancer and anti-deobfuscation layer for the compiler

local InternalVariableNamer = require("moonstar.internalVariableNamer")

local Optimization = {}

-- Sanitize captured string to prevent code injection (VUL-005 fix)
local function sanitizeCapture(str)
    -- Remove any potential code injection attempts
    if not str then return "" end
    -- Check for dangerous patterns - be more aggressive
    if str:find("os%.") or str:find("io%.") or str:find("load%w*%(") or 
       str:find("%]%]") or str:find("require%(") or str:find("debug%.") or
       str:find("setmetatable") or str:find("getfenv") or str:find("setfenv") then
        -- Return safe placeholder for suspicious patterns
        return "nil"
    end
    -- Additional check: strip any trailing code injections after parentheses
    str = str:gsub("%]%].*", "")
    str = str:gsub("%;.*", "")
    return str
end

-- Generate random variable name with prefix (VUL-004 fix: increased entropy)
-- Updated to use InternalVariableNamer for enhanced obfuscation
local function randomVarName(prefix)
    return InternalVariableNamer.generateVariableWithPrefix(prefix, 11)
end

-- Obfuscate string table patterns to prevent static deobfuscation
-- Targets the vulnerabilities documented in DEOBFUSCATION_DOCUMENTATION.md
local function obfuscateStringTablePatterns(code)
    -- PERFORMANCE: Early return if code is too small to contain these patterns
    if #code < 100 then
        return code
    end
    
    -- Pattern 1: Obfuscate simple accessor functions like k(x) = H[x + offset]
    -- Match: function name(param) return table[param + number] end
    -- Replace with obfuscated conditional logic
    code = code:gsub("function%s+([%w_]+)%s*%(([%w_]+)%)%s+return%s+([%w_]+)%[([%w_]+)%s*%+%s*(%d+)%]%s+end", function(funcName, param, tableName, indexVar, offset)
        -- Verify param matches indexVar (poor man's backreference)
        if param ~= indexVar then
            -- Return original if they don't match
            return string.format("function %s(%s) return %s[%s + %s] end", funcName, param, tableName, indexVar, offset)
        end
        
        -- Create obfuscated accessor with conditional logic (already obfuscated, no "and...or")
        local tmpVar = randomVarName("__idx_")
        local checkVar = randomVarName("__chk_")
        return string.format([[function %s(%s)
    local %s = %s + %s
    local %s
    if %s > 0 then
        %s = %s
    else
        %s = %s
    end
    if %s then
        return %s[%s]
    end
    return %s[%s]
end]], funcName, param, tmpVar, param, offset, checkVar, tmpVar, checkVar, tmpVar, checkVar, tableName, tmpVar, tableName, tmpVar)
    end)
    
    -- Pattern 2: Obfuscate local function accessors
    -- Match: local function name(param) return table[param + offset] end
    code = code:gsub("local%s+function%s+([%w_]+)%s*%(([%w_]+)%)%s+return%s+([%w_]+)%[([%w_]+)%s*%+%s*(%d+)%]%s+end", function(funcName, param, tableName, indexVar, offset)
        -- Verify param matches indexVar
        if param ~= indexVar then
            return string.format("local function %s(%s) return %s[%s + %s] end", funcName, param, tableName, indexVar, offset)
        end
        
        local tmpVar = randomVarName("__loc_")
        local condVar = randomVarName("__cnd_")
        return string.format([[local function %s(%s)
    local %s = (%s + %s) %% 65536
    local %s
    if %s > 0 then
        %s = %s
    else
        %s = 1
    end
    return %s[%s]
end]], funcName, param, tmpVar, param, offset, condVar, tmpVar, condVar, tmpVar, condVar, tableName, condVar)
    end)
    
    -- Pattern 3: Obfuscate array index patterns H[-14275] style accessors
    -- Prevent simple k(-14275) → H[1] mapping detection
    code = code:gsub("([%w_]+)%[([%w_]+)%s*%+%s*(%d+)%]", function(tableName, indexVar, offset)
        if math.random(1, 100) <= 70 then  -- 70% obfuscation rate
            -- Add arithmetic noise to offset calculation
            local noise1 = math.random(1, 1000)
            return string.format("%s[%s + ((%s + %d) - %d)]", tableName, indexVar, offset, noise1, noise1)
        end
        return tableName .. "[" .. indexVar .. " + " .. offset .. "]"
    end)
    
    -- Pattern 4: Obfuscate lookup table declarations
    -- Match: local lookup = {char1=val1, char2=val2, ...}
    -- Split into dynamic initialization to prevent static extraction
    code = code:gsub("local%s+([%w_]+)%s*=%s*(%b{})", function(varName, tableContent)
        if varName:find("lookup") or varName:find("Lookup") or tableContent:find('"%a"%]=%d') then
            -- This looks like a base64 lookup table, split it
            local init = randomVarName("__init_")
            return string.format([[local %s = {}
do
    local %s = %s
    for k, v in pairs(%s) do
        %s[k] = v
    end
end]], varName, init, tableContent, init, varName)
        end
        return "local " .. varName .. " = " .. tableContent
    end)
    
    return code
end

-- Obfuscate VM variable patterns - now minimal since patterns are generated obfuscated
local function obfuscateVMPatterns(code)
    -- PERFORMANCE: Early return if code is too small 
    if #code < 50 then
        return code
    end
    
    -- Most "and...or" patterns are now generated obfuscated during unparsing
    -- This function now only handles edge cases and adds numeric noise
    
    -- VUL-007 fix: Add arithmetic noise to numeric expressions
    code = code:gsub("(%d+)%s*([%+%-%*/])%s*(%d+)", function(a, op, b)
        if math.random(1, 100) <= 55 then  -- 55% noise rate
            -- Add identity operations with random noise
            local noise = math.random(1, 255)
            return string.format("((%s + %d - %d) %s %s)", a, noise, noise, op, b)
        end
        return a .. op .. b
    end)
    
    return code
end

-- Main enhancement function for VMified code
-- This is a module-level function that can be called on compiled string output
function Optimization.enhanceVMCode(code)
    -- Don't enhance empty or invalid code
    if not code or #code < 10 then
        return code
    end
    
    -- PERFORMANCE: Removed redundant RNG seeding
    -- The RNG is already seeded in Compiler:new() with high-quality entropy
    -- Re-seeding here is unnecessary and adds overhead
    -- The original warmup iterations (20) are also removed for the same reason
    
    -- Apply safe enhancement layers that don't break functionality
    code = obfuscateVMPatterns(code)
    -- Apply anti-deobfuscation enhancements for string tables
    code = obfuscateStringTablePatterns(code)
    
    return code
end

-- Export internal functions for testing if needed
Optimization.sanitizeCapture = sanitizeCapture
Optimization.randomVarName = randomVarName
Optimization.obfuscateStringTablePatterns = obfuscateStringTablePatterns
Optimization.obfuscateVMPatterns = obfuscateVMPatterns

return Optimization

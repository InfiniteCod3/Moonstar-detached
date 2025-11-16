-- internalVariableNamer.lua
-- Enhanced random name generation for internal compiler variables
-- Avoids descriptive patterns to resist pattern-based deobfuscation

local InternalVariableNamer = {}

-- Seed RNG for better randomness
math.randomseed(os.time() * 1000 + os.clock() * 1000000)
for i = 1, 10 do math.random() end

-- Character sets for name generation
local CHARS_ALPHA_LOWER = "abcdefghijklmnopqrstuvwxyz"
local CHARS_ALPHA_UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local CHARS_NUMERIC = "0123456789"
local CHARS_ALPHANUMERIC = CHARS_ALPHA_LOWER .. CHARS_ALPHA_UPPER .. CHARS_NUMERIC

-- Pre-defined random prefixes to replace descriptive ones
-- These are fixed mappings from plan.md
local PATTERN_PREFIXES = {
    ["__idx_"] = "X7k_",
    ["__chk_"] = "B2x_",
    ["__tern_"] = "H4m_",
    ["__fcall_"] = "D6q_",
    ["__loc_"] = "nL8_",
    ["__init_"] = "tR5_",
}

-- Pre-defined random names for specific internal variables
-- These are fixed mappings from plan.md (lines 120-126)
local VARIABLE_NAMES = {
    ["tmpReg"] = "a7bX9",
    ["iteratorVar"] = "x9wL4",
    ["valueVar"] = "p5tZ7",
    ["checkVar"] = "c6vN2",
    ["idxVar"] = "f8hK1",
    ["funcVar"] = "m3kQ8",
    ["exprVar"] = "z2pR6",
}

-- Generate a random alphanumeric string of specified length
-- @param length: Length of the string (default: 6-12 random)
-- @return: Random string
function InternalVariableNamer.generateRandomName(length)
    length = length or math.random(6, 12)
    local name = ""
    
    -- First character must be alphabetic
    local firstCharSet = CHARS_ALPHA_LOWER .. CHARS_ALPHA_UPPER
    local idx = math.random(1, #firstCharSet)
    name = firstCharSet:sub(idx, idx)
    
    -- Remaining characters can be alphanumeric
    for i = 2, length do
        local idx = math.random(1, #CHARS_ALPHANUMERIC)
        name = name .. CHARS_ALPHANUMERIC:sub(idx, idx)
    end
    
    return name
end

-- Get the obfuscated prefix for a pattern
-- @param descriptivePrefix: The original descriptive prefix (e.g., "__idx_")
-- @return: Random non-descriptive prefix
function InternalVariableNamer.getObfuscatedPrefix(descriptivePrefix)
    return PATTERN_PREFIXES[descriptivePrefix] or descriptivePrefix
end

-- Get the obfuscated name for an internal variable
-- @param descriptiveName: The original descriptive name (e.g., "tmpReg")
-- @return: Random non-descriptive name
function InternalVariableNamer.getObfuscatedVariableName(descriptiveName)
    return VARIABLE_NAMES[descriptiveName] or descriptiveName
end

-- Generate a random variable name with obfuscated prefix
-- @param prefix: Original prefix (will be obfuscated if in mapping)
-- @param suffixLength: Length of random suffix (default: 11)
-- @return: Complete variable name with obfuscated prefix
function InternalVariableNamer.generateVariableWithPrefix(prefix, suffixLength)
    prefix = prefix or "__var_"
    suffixLength = suffixLength or 11
    
    -- Obfuscate the prefix if it's a known descriptive pattern
    local obfuscatedPrefix = InternalVariableNamer.getObfuscatedPrefix(prefix)
    
    -- Generate random suffix
    local suffix = ""
    for i = 1, suffixLength do
        local idx = math.random(1, #CHARS_ALPHANUMERIC)
        suffix = suffix .. CHARS_ALPHANUMERIC:sub(idx, idx)
    end
    
    return obfuscatedPrefix .. suffix
end

return InternalVariableNamer

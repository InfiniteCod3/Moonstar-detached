//ng-- Simple Luau to Lua51 preprocessor
-- Converts compound assignment operators to their expanded forms

local function preprocess(source)
    -- Convert += to = ... +
    source = source:gsub("([%w_%.%[%]]+)%s*%+=%s*([^\n]+)", "%1 = %1 + (%2)")
    
    -- Convert -= to = ... -
    source = source:gsub("([%w_%.%[%]]+)%s*%-=%s*([^\n]+)", "%1 = %1 - (%2)")
    
    -- Convert *= to = ... *
    source = source:gsub("([%w_%.%[%]]+)%s*%*=%s*([^\n]+)", "%1 = %1 * (%2)")
    
    -- Convert /= to = ... /
    source = source:gsub("([%w_%.%[%]]+)%s*/=%s*([^\n]+)", "%1 = %1 / (%2)")
    
    -- Convert ..= to = ... ..
    source = source:gsub("([%w_%.%[%]]+)%s*%.%.=%s*([^\n]+)", "%1 = %1 .. (%2)")
    
    return source
end

-- Read input file
local inputFile = arg[1]
local outputFile = arg[2] or (inputFile:gsub("%.lua$", ".preprocessed.lua"))

if not inputFile then
    print("Usage: lua preprocess.lua <input.lua> [output.lua]")
    os.exit(1)
end

local f = io.open(inputFile, "r")
if not f then
    print("Error: Cannot open " .. inputFile)
    os.exit(1)
end

local source = f:read("*all")
f:close()

local processed = preprocess(source)

local out = io.open(outputFile, "w")
out:write(processed)
out:close()

print("Preprocessed " .. inputFile .. " -> " .. outputFile)

#!/usr/bin/env lua5.1
--[[
    Moonstar - Advanced Lua/Luau Obfuscator
    Copyright (c) 2025 Moonstar
    All rights reserved.
    
    Features:
    - Advanced obfuscation engine
    - 10+ obfuscation techniques
    - 4 built-in presets (low, mid, high, extreme)
    - VM-based bytecode compilation
    - Anti-tamper protection
    - Instruction randomization
    
    Quick Start:
        lua moonstar.lua input.lua output.lua --preset=mid
]]

-- Setup Moonstar module paths
local function setupMoonstarPath()
    -- PERFORMANCE: Removed unnecessary io.popen("cd") call
    -- The current working directory is already available via relative paths
    -- This eliminates an expensive system call on every invocation
    package.path = "./moonstar/src/?.lua;" ..
                   "./moonstar/src/moonstar/?.lua;" ..
                   "./moonstar/src/moonstar/steps/?.lua;" ..
                   package.path
end

setupMoonstarPath()

-- Load Moonstar core module
local Moonstar = require("moonstar")

-- Config is read-only, we need to update the source config
local ConfigModule = require("config")
ConfigModule.NameUpper = "MOONSTAR"
ConfigModule.Name = "Moonstar"

-- Set logger to Info level
Moonstar.Logger.logLevel = Moonstar.Logger.LogLevel.Info

-- Moonstar Presets (sourced from runtime module)
local MoonstarPresets = Moonstar.Presets

local function deepCopy(value, cache)
    if type(value) ~= "table" then
        return value
    end

    cache = cache or {}
    if cache[value] then
        return cache[value]
    end

    local copy = {}
    cache[value] = copy

    for k, v in pairs(value) do
        copy[deepCopy(k, cache)] = deepCopy(v, cache)
    end

    return copy
end

-- Print usage information
local function printUsage()
    print([[
╔════════════════════════════════════════════════════════════╗
║              Moonstar - Lua/Luau Obfuscator                ║
║                     © 2025 Moonstar                        ║
╚════════════════════════════════════════════════════════════╝

Usage: lua moonstar.lua <input_file> <output_file> [options]

Arguments:
    input_file   - Path to the Lua/Luau file to obfuscate
    output_file  - Path where the obfuscated file will be saved

Options:
    --preset=X          Use preset configuration (default: Medium)
                        Available: Minify, Weak, Medium, Strong
    --LuaU              Target LuaU/Roblox (default: Lua51)
    --Lua51             Target Lua 5.1 (default)
    --pretty            Enable pretty printing (readable output)
    --no-antitamper     Disable anti-tamper (Medium/Strong presets)
    --seed=N            Set random seed for reproducible output
    --detailed          Show detailed build report
    --compress          Enable LZW compression of output

    Presets:
    Minify  - No obfuscation (just minification)
    Weak    - Basic VM protection (Vmify + constant array)
    Medium  - Balanced protection (encryption + VM + all features) [recommended]
    Strong  - Maximum protection (double VM + all features)

Examples:
    # Medium preset (default, recommended)
    lua moonstar.lua script.lua output.lua --preset=Medium
    
    # Minify only (no obfuscation)
    lua moonstar.lua script.lua output.lua --preset=Minify
    
    # Weak preset (basic VM)
    lua moonstar.lua script.lua output.lua --preset=Weak
    
    # Strong preset (maximum protection)
    lua moonstar.lua script.lua output.lua --preset=Strong
    
    # For Roblox/LuaU    lua moonstar.lua script.lua output.lua --preset=Medium --LuaU
    
    # Disable anti-tamper in Medium preset
    lua moonstar.lua script.lua output.lua --preset=Medium --no-antitamper

For more information, visit: https://github.com/InfiniteCod3/Moonstar
]])
end

-- Check if file exists
local function fileExists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

-- Read file contents
local function readFile(file)
    if not fileExists(file) then
        return nil, "File does not exist: " .. file
    end
    local f = io.open(file, "rb")
    if not f then
        return nil, "Cannot open file: " .. file
    end
    local content = f:read("*all")
    f:close()
    return content
end

-- Write file contents
local function writeFile(file, content)
    local f = io.open(file, "wb")
    if not f then
        return false, "Cannot write to file: " .. file
    end
    f:write(content)
    f:close()
    return true
end

-- Strip Luau type annotations to work around parser limitations
local function stripLuauTypeAnnotations(code)
    -- Strip generics from function declarations first: function foo<T>(...)
    code = code:gsub("(function%s+[%w_]+)%s*<%s*[%w_,%s]+%s*>", "%1")
    
    -- Strip type annotations from function parameters
    -- Handle both single and multiple parameters
    code = code:gsub("%(([^%)]+)%)", function(params)
        -- Only process if it contains type annotations (has colon not in string)
        if params:find("[%w_]%s*:") then
            -- Strip type annotations: name: type -> name (excluding newlines from type pattern)
            local stripped = params:gsub("([%w_]+)%s*:%s*[%w_<>{},%[%]%(%)]+", "%1")
            return "(" .. stripped .. ")"
        end
        return "(" .. params .. ")"
    end)
    
    -- Strip return type annotations more carefully
    -- Match ): type followed by newline (type pattern excludes newlines to prevent eating function body)
    code = code:gsub("%)[ \t]*:[ \t]*[%w_<>{},%[%]%(%)]+[ \t]*(\r?\n)", ")%1")
    
    -- Strip type annotations from variable declarations: local x: type = value
    code = code:gsub("(local%s+[%w_]+)[ \t]*:[ \t]*[%w_<>{},%[%]%(%)]+(%s*=)", "%1%2")
    
    -- Strip type declarations: type Name = {...}
    code = code:gsub("type%s+[%w_]+%s*=%s*[^\n]*\n", "-- type declaration stripped\n")
    
    -- Strip export keyword: export local x = 5
    code = code:gsub("export%s+", "")
    
    -- Strip compound assignment operators (convert to long form)
    code = code:gsub("([%w_%.%[%]]+)%s*%+=%s*([^\n]+)", "%1 = %1 + (%2)")
    code = code:gsub("([%w_%.%[%]]+)%s*%-=%s*([^\n]+)", "%1 = %1 - (%2)")
    code = code:gsub("([%w_%.%[%]]+)%s*%*=%s*([^\n]+)", "%1 = %1 * (%2)")
    code = code:gsub("([%w_%.%[%]]+)%s*//=%s*([^\n]+)", "%1 = math.floor(%1 / (%2))")
    code = code:gsub("([%w_%.%[%]]+)%s*/=%s*([^\n]+)", "%1 = %1 / (%2)")
    code = code:gsub("([%w_%.%[%]]+)%s*%%=%s*([^\n]+)", "%1 = %1 %% (%2)")
    code = code:gsub("([%w_%.%[%]]+)%s*%^=%s*([^\n]+)", "%1 = %1 ^ (%2)")
    code = code:gsub("([%w_%.%[%]]+)%s*%.%.=%s*([^\n]+)", "%1 = %1 .. (%2)")
    
    return code
end

-- Parse command line arguments
local function parseArgs(args)
    if #args < 2 then
        return nil, "Missing required arguments"
    end
    
    local config = {
        inputFile = args[1],
        outputFile = args[2],
        preset = "Medium",
        luaVersion = "Lua51",
        prettyPrint = false,
        seed = 0,
        disableAntiTamper = false,
        detailed = false,
        compress = false,
    }
    
    -- Parse options
    for i = 3, #args do
        local arg = args[i]
        if arg:match("^--preset=") then
            config.preset = arg:match("^--preset=(.+)$")
        elseif arg == "--LuaU" then
            config.luaVersion = "LuaU"
        elseif arg == "--Lua51" then
            config.luaVersion = "Lua51"
        elseif arg == "--pretty" then
            config.prettyPrint = true
        elseif arg:match("^--seed=") then
            config.seed = tonumber(arg:match("^--seed=(.+)$")) or 0
        elseif arg == "--no-antitamper" then
            config.disableAntiTamper = true
        elseif arg == "--detailed" then
            config.detailed = true
        elseif arg == "--compress" then
            config.compress = true
        elseif arg == "--help" or arg == "-h" then
            return nil, "help"
        end
    end
    
    return config
end

-- Main function
local function main(args)
    
    if #args == 0 or args[1] == "--help" or args[1] == "-h" then
        printUsage()
        os.exit(0)
    end
    
    -- Parse arguments
    local config, err = parseArgs(args)
    if not config then
        if err == "help" then
            printUsage()
            os.exit(0)
        else
            print("ERROR: " .. err)
            print("")
            printUsage()
            os.exit(1)
        end
    end
    
    -- Validate preset
    if not MoonstarPresets[config.preset] then
        print("ERROR: Unknown preset '" .. config.preset .. "'")
        print("Available presets: Minify, Weak, Medium, Strong")
        os.exit(1)
    end
    
    -- Read input file
    print("")
    print("╔" .. string.rep("═", 60) .. "╗")
    print("║  Moonstar - Lua/Luau Obfuscator                            ║")
    print("╚" .. string.rep("═", 60) .. "╝")
    print("")
    print("Input:  " .. config.inputFile)
    print("Output: " .. config.outputFile)
    print("Preset: " .. config.preset)
    print("Target: " .. config.luaVersion)
    print("")
    
    local source, readErr = readFile(config.inputFile)
    if not source then
        print("ERROR: " .. readErr)
        os.exit(1)
    end
    
    print("Original size: " .. #source .. " bytes")
    print("")
    
    -- Get preset configuration
    local presetConfig = deepCopy(MoonstarPresets[config.preset])
    
    -- Override settings
    presetConfig.LuaVersion = config.luaVersion
    presetConfig.PrettyPrint = config.prettyPrint
    if config.seed > 0 then
        presetConfig.Seed = config.seed
    end
    
    -- Remove AntiTamper if disabled
    if config.disableAntiTamper then
        -- Handle new schema
        if presetConfig.AntiTamper then
            presetConfig.AntiTamper.Enabled = false
        end

        -- Handle legacy schema
        if presetConfig.Steps then
            local newSteps = {}
            for _, step in ipairs(presetConfig.Steps) do
                if step.Name ~= "AntiTamper" then
                    table.insert(newSteps, step)
                end
            end
            presetConfig.Steps = newSteps
        end
    end

    if config.compress then
        presetConfig.Compression = { Enabled = true }
    end

    presetConfig.DetailedReport = config.detailed
    
    -- LUAU FIX: Strip type annotations if targeting LuaU
    if config.luaVersion == "LuaU" then
        source = stripLuauTypeAnnotations(source)
    end
    
    -- Create pipeline from config
    local pipeline = Moonstar.Pipeline:fromConfig(presetConfig)
    
    -- Apply obfuscation pipeline (this handles parsing, steps, and renaming)
    print("Applying obfuscation pipeline...")
    local obfuscated, report = pipeline:apply(source, config.inputFile)
    
    -- Add Moonstar banner (as comment block)
    local banner = ""
    local bannerFile = io.open("banner.txt", "r")
    if bannerFile then
        local bannerContent = bannerFile:read("*all")
        bannerFile:close()
        -- Convert banner to comment block
        banner = "--[[\n" .. bannerContent .. "\n]]\n"
        obfuscated = banner .. obfuscated
    end
    
    -- Write output file
    print("Writing output file...")
    local writeSuccess, writeErr = writeFile(config.outputFile, obfuscated)
    if not writeSuccess then
        print("ERROR: " .. writeErr)
        os.exit(1)
    end
    
    print("")
    print("Obfuscated size: " .. #obfuscated .. " bytes")
    print("Size ratio: " .. string.format("%.2f%%", (#obfuscated / #source) * 100))
    print("")
    print("[✓] Obfuscation complete!")
    print("")

    if report then
        print("Detailed Build Report:")
        print("═" .. string.rep("═", 60))
        print(string.format("%-25s | %-10s | %-10s | %-10s", "Step", "Size", "Entropy", "Time (s)"))
        print(string.rep("-", 65))
        for _, entry in ipairs(report) do
            print(string.format("%-25s | %-10d | %-10.4f | %-10.4f",
                entry.Step, entry.Size, entry.Entropy, entry.Time))
        end
        print("═" .. string.rep("═", 60))
        print("")
    end

    print("═" .. string.rep("═", 60))
end

-- Run main function
local success, err = pcall(function()
    main(arg)
end)

if not success then
    print("")
    print("[!] ERROR: " .. tostring(err))
    print("")
    print("Stack trace:")
    print(debug.traceback())
    os.exit(1)
end

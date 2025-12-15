#!/usr/bin/env lua5.1
--[[
    Moonstar - Advanced Lua/Luau Obfuscator
    Copyright (c) 2025 Moonstar
    All rights reserved.

    This is the consolidated single-file entry point for Moonstar.
    Presets are loaded from the presets/ folder.
]]

-- ============================================================================
-- PATH SETUP
-- ============================================================================

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*[/%\\])")
end

local MOONSTAR_ROOT = script_path() or "./"
local oldPkgPath = package.path
package.path = MOONSTAR_ROOT .. "moonstar/src/?.lua;" ..
               MOONSTAR_ROOT .. "moonstar/src/moonstar/?.lua;" ..
               MOONSTAR_ROOT .. "moonstar/src/moonstar/steps/?.lua;" ..
               package.path

-- ============================================================================
-- LUA 5.1 COMPATIBILITY FIXES
-- ============================================================================

-- Math.random Fix for Lua5.1
if not pcall(function() return math.random(1, 2^40) end) then
    local oldMathRandom = math.random
    math.random = function(a, b)
        if not a and b then
            return oldMathRandom()
        end
        if not b then
            return math.random(1, a)
        end
        if a > b then
            a, b = b, a
        end
        local diff = b - a
        
        if diff < 0 then
            error(string.format("Invalid interval: a=%s, b=%s, diff=%s", tostring(a), tostring(b), tostring(diff)))
        end
        
        if diff == 0 then
            return a
        end
        
        if diff > 2 ^ 31 - 1 or a < 0 or b >= 2^31 then
            return math.floor(oldMathRandom() * diff + a)
        else
            local ia = math.floor(a + 0.5)
            local ib = math.floor(b + 0.5)
            if ia > ib then
                ia, ib = ib, ia
            end
            if ia == ib then
                return ia
            end
            return oldMathRandom(ia, ib)
        end
    end
end

-- newproxy polyfill
_G.newproxy = _G.newproxy or function(arg)
    if arg then
        return setmetatable({}, {})
    end
    return {}
end

-- ============================================================================
-- CORE MODULE LOADING
-- ============================================================================

local Pipeline  = require("moonstar.pipeline")
local highlight = require("highlightlua")
local colors    = require("colors")
local Logger    = require("logger")
local Config    = require("config")
local util      = require("moonstar.util")

-- Update config
Config.NameUpper = "MOONSTAR"
Config.Name = "Moonstar"

-- Set logger to Info level
Logger.logLevel = Logger.LogLevel.Info

-- ============================================================================
-- PRESET LOADING
-- ============================================================================

-- Load a preset from the presets folder
local function loadPresetFromFile(presetName)
    local presetPath = MOONSTAR_ROOT .. "presets/" .. presetName:lower() .. ".lua"
    local f = io.open(presetPath, "r")
    if f then
        f:close()
        local success, preset = pcall(dofile, presetPath)
        if success and preset then
            return preset
        end
    end
    return nil
end

-- Fallback hardcoded presets
local FallbackPresets = {
    ["Minify"] = {
        LuaVersion    = "Lua51";
        VarNamePrefix = "";
        NameGenerator = "MangledShuffled";
        PrettyPrint   = false;
        Seed          = 0;
        WrapInFunction = { Enabled = false };
    };
    ["Weak"] = {
        LuaVersion    = "Lua51";
        VarNamePrefix = "";
        NameGenerator = "MangledShuffled";
        PrettyPrint   = false;
        Seed          = 0;
        WrapInFunction = { Enabled = true };
        EncryptStrings = { Enabled = true; Mode = "light" };
        SplitStrings = { Enabled = true; MaxSegmentLength = 16; Strategy = "random" };
        ConstantArray = { Enabled = true; EncodeStrings = true; IndexObfuscation = false };
        NumbersToExpressions = { Enabled = true; Complexity = "low" };
    };
    ["Medium"] = {
        LuaVersion    = "Lua51";
        VarNamePrefix = "";
        NameGenerator = "MangledShuffled";
        PrettyPrint   = false;
        Seed          = 0;
        WrapInFunction = { Enabled = true };
        EncryptStrings = { Enabled = true; Mode = "standard" };
        SplitStrings = { Enabled = true; MaxSegmentLength = 16; Strategy = "random" };
        ConstantArray = { Enabled = true; EncodeStrings = true; IndexObfuscation = true };
        NumbersToExpressions = { Enabled = true; Complexity = "low" };
        AddVararg = { Enabled = true; Probability = 0.15 };
    };
    ["Strong"] = {
        LuaVersion    = "Lua51";
        VarNamePrefix = "";
        NameGenerator = "MangledShuffled";
        PrettyPrint   = false;
        Seed          = 0;
        GlobalVirtualization = { Enabled = true; VirtualizeEnv = true };
        WrapInFunction = { Enabled = true };
        ConstantFolding = { Enabled = true };
        JitStringDecryptor = { Enabled = false; MaxLength = 30 };
        EncryptStrings = { Enabled = true; Mode = "standard"; DecryptorVariant = "polymorphic"; LayerDepth = 1; InlineThreshold = 16; EnvironmentCheck = true };
        ControlFlowFlattening = { Enabled = true; ChunkSize = 3 };
        ConstantArray = { Enabled = true; EncodeStrings = true; IndexObfuscation = true };
        NumbersToExpressions = { Enabled = true; Complexity = "medium" };
        AddVararg = { Enabled = true; Probability = 0.1 };
        AntiTamper = { Enabled = true };
        Vmify = { Enabled = true; InlineVMState = true; ObfuscateHandlers = true; InstructionRandomization = true; EncryptVmStrings = true };
        VmProfileRandomizer = { Enabled = true; PermuteOpcodes = true; ShuffleHandlers = true; RandomizeNames = true };
        Compression = { Enabled = false; FastMode = true; Preseed = true; BWT = true; RLE = true; Huffman = true; ArithmeticCoding = true; PPM = true; PPMOrder = 2; ParallelTests = 4 };
    };
}

-- Get a preset (file first, then fallback)
local function getPreset(presetName)
    -- Capitalize first letter for consistency
    local normalizedName = presetName:sub(1,1):upper() .. presetName:sub(2):lower()
    
    -- Try loading from presets folder first
    local filePreset = loadPresetFromFile(presetName)
    if filePreset then
        return filePreset
    end
    
    -- Fall back to hardcoded presets
    return FallbackPresets[normalizedName]
end

-- Build Presets table (try files first, then fallback)
local Presets = {}
for name, _ in pairs(FallbackPresets) do
    Presets[name] = getPreset(name)
end

-- Restore package.path
package.path = oldPkgPath

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

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

local function fileExists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

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
    code = code:gsub("(function%s+[%w_]+)%s*<%s*[%w_,%s]+%s*>", "%1")
    
    code = code:gsub("%(([^%)]+)%)", function(params)
        if params:find("[%w_]%s*:") then
            local stripped = params:gsub("([%w_]+)%s*:%s*[%w_<>{},%[%]%(%)]+", "%1")
            return "(" .. stripped .. ")"
        end
        return "(" .. params .. ")"
    end)
    
    code = code:gsub("%)[ \t]*:[ \t]*[%w_<>{},%[%]%(%)]+[ \t]*(\r?\n)", ")%1")
    code = code:gsub("(local%s+[%w_]+)[ \t]*:[ \t]*[%w_<>{},%[%]%(%)]+(%s*=)", "%1%2")
    code = code:gsub("type%s+[%w_]+%s*=%s*[^\n]*\n", "-- type declaration stripped\n")
    code = code:gsub("export%s+", "")
    
    -- Compound assignment operators
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

-- ============================================================================
-- CLI INTERFACE
-- ============================================================================

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
                        Or any custom .lua file in presets/
    --LuaU              Target LuaU/Roblox (default: Lua51)
    --Lua51             Target Lua 5.1 (default)
    --pretty            Enable pretty printing (readable output)
    --no-antitamper     Disable anti-tamper (Medium/Strong presets)
    --seed=N            Set random seed for reproducible output
    --detailed          Show detailed build report
    --compress          Enable compression of output
    --parallel=N        Number of parallel compression tests (default: 4)
    --debug             Enable debug mode (verbose logging, intermediate
                        outputs, fixed seed, pretty printing)

    Presets:
    Minify  - No obfuscation (just minification)
    Weak    - Basic VM protection (Vmify + constant array)
    Medium  - Balanced protection (encryption + VM + all features) [recommended]
    Strong  - Maximum protection (double VM + all features)

Examples:
    lua moonstar.lua script.lua output.lua --preset=Medium
    lua moonstar.lua script.lua output.lua --preset=Strong --LuaU

For more information, visit: https://github.com/InfiniteCod3/Moonstar
]])
end

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
        parallel = 4,
        debug = false,
    }
    
    for i = 3, #args do
        local a = args[i]
        if a:match("^--preset=") then
            config.preset = a:match("^--preset=(.+)$")
        elseif a == "--LuaU" then
            config.luaVersion = "LuaU"
        elseif a == "--Lua51" then
            config.luaVersion = "Lua51"
        elseif a == "--pretty" then
            config.prettyPrint = true
        elseif a:match("^--seed=") then
            config.seed = tonumber(a:match("^--seed=(.+)$")) or 0
        elseif a == "--no-antitamper" then
            config.disableAntiTamper = true
        elseif a == "--detailed" then
            config.detailed = true
        elseif a == "--compress" then
            config.compress = true
        elseif a:match("^--parallel=") then
            config.parallel = tonumber(a:match("^--parallel=(.+)$")) or 4
        elseif a == "--debug" then
            config.debug = true
        elseif a == "--help" or a == "-h" then
            return nil, "help"
        end
    end
    
    return config
end

local function main(args)
    if #args == 0 or args[1] == "--help" or args[1] == "-h" then
        printUsage()
        os.exit(0)
    end
    
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
    local presetToUse = getPreset(config.preset)
    if not presetToUse then
        print("ERROR: Unknown preset '" .. config.preset .. "'")
        print("Available presets: Minify, Weak, Medium, Strong (or custom .lua files in presets/)")
        os.exit(1)
    end
    
    -- Apply debug mode settings
    if config.debug then
        Logger.logLevel = Logger.LogLevel.Debug
        config.detailed = true
        config.prettyPrint = true
        if config.seed == 0 then
            config.seed = 12345
        end
        print("")
        print("╔" .. string.rep("═", 60) .. "╗")
        print("║  Moonstar - DEBUG MODE ENABLED                              ║")
        print("╚" .. string.rep("═", 60) .. "╝")
        print("")
        print("[DEBUG] Log level: Debug")
        print("[DEBUG] Pretty printing: Enabled")
        print("[DEBUG] Detailed report: Enabled")
        print("[DEBUG] Fixed seed: " .. config.seed)
        print("")
    else
        print("")
        print("╔" .. string.rep("═", 60) .. "╗")
        print("║  Moonstar - Lua/Luau Obfuscator                            ║")
        print("╚" .. string.rep("═", 60) .. "╝")
        print("")
    end
    
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
    local presetConfig = deepCopy(getPreset(config.preset))
    
    -- Override settings
    presetConfig.LuaVersion = config.luaVersion
    presetConfig.PrettyPrint = config.prettyPrint
    if config.seed > 0 then
        presetConfig.Seed = config.seed
    end
    
    -- Remove AntiTamper if disabled
    if config.disableAntiTamper then
        if presetConfig.AntiTamper then
            presetConfig.AntiTamper.Enabled = false
        end
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
        presetConfig.Compression = {
            Enabled = true,
            FastMode = true,
            BWT = true,
            RLE = true,
            Huffman = true,
            ArithmeticCoding = true,
            PPM = true,
            PPMOrder = 2,
            Preseed = true,
            ParallelTests = config.parallel
        }
    end

    presetConfig.DetailedReport = config.detailed
    presetConfig.DebugMode = config.debug
    
    -- LUAU FIX: Strip type annotations if targeting LuaU
    if config.luaVersion == "LuaU" then
        source = stripLuauTypeAnnotations(source)
    end
    
    -- Create pipeline from config
    local pipeline = Pipeline:fromConfig(presetConfig)
    
    -- Apply obfuscation pipeline
    print("Applying obfuscation pipeline...")
    local obfuscated, report = pipeline:apply(source, config.inputFile)
    
    -- Add Moonstar banner
    local bannerFile = io.open(MOONSTAR_ROOT .. "banner.txt", "r")
    if bannerFile then
        local bannerContent = bannerFile:read("*all")
        bannerFile:close()
        obfuscated = "--[[\n" .. bannerContent .. "\n]]\n" .. obfuscated
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

-- ============================================================================
-- MODULE EXPORT (for use as library)
-- ============================================================================

-- If this file is being required as a module (not run directly), export the API
if not arg or #arg == 0 or arg[0]:match("moonstar%.lua$") == nil then
    -- Being required as a module
    return {
        Pipeline  = Pipeline;
        colors    = colors;
        Config    = util.readonly(Config);
        Logger    = Logger;
        highlight = highlight;
        Presets   = Presets;
        getPreset = getPreset;
    }
end

-- ============================================================================
-- MAIN ENTRY POINT
-- ============================================================================

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

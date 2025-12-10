#!/usr/bin/env lua5.1
--[[
    Moonstar - Advanced Lua/Luau Obfuscator
    Copyright (c) 2025 Moonstar
    All rights reserved.
]]

--------------------------------------------------------------------------------
-- Constants & Configuration
--------------------------------------------------------------------------------

local VERSION = "2.0.0"
local PROGRAM_NAME = "Moonstar"
local PROGRAM_NAME_UPPER = "MOONSTAR"

--------------------------------------------------------------------------------
-- Package Path Setup
--------------------------------------------------------------------------------

local function setupPackagePath()
    local function getScriptPath()
        local info = debug.getinfo(2, "S")
        if info and info.source then
            local path = info.source:sub(2)
            return path:match("(.*[/%\\])") or "./"
        end
        return "./"
    end

    local scriptDir = getScriptPath()
    package.path = scriptDir .. "moonstar/src/?.lua;" ..
                   scriptDir .. "moonstar/src/presets/?.lua;" ..
                   scriptDir .. "moonstar/src/moonstar/?.lua;" ..
                   scriptDir .. "moonstar/src/moonstar/steps/?.lua;" ..
                   package.path
end

setupPackagePath()

--------------------------------------------------------------------------------
-- Apply Polyfills
--------------------------------------------------------------------------------

local Polyfills = require("polyfills")
Polyfills.apply()

--------------------------------------------------------------------------------
-- Core Module Imports
--------------------------------------------------------------------------------

local Pipeline  = require("moonstar.pipeline")
local highlight = require("highlightlua")
local colors    = require("colors")
local Logger    = require("logger")
local Config    = require("config")
local util      = require("moonstar.util")

-- Load presets from modular preset system
local PresetsModule = require("presets.init")
local Presets = PresetsModule.Presets
local PRESET_NAMES = PresetsModule.PRESET_NAMES
local LUA_VERSIONS = PresetsModule.LUA_VERSIONS
local CompressionConfig = PresetsModule.CompressionConfig
local deepCopy = PresetsModule.deepCopy

-- Configure branding
Config.NameUpper = PROGRAM_NAME_UPPER
Config.Name = PROGRAM_NAME

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

local function fileExists(path)
    local file = io.open(path, "rb")
    if file then
        file:close()
        return true
    end
    return false
end

local function readFile(path)
    if not fileExists(path) then
        return nil, "File does not exist: " .. path
    end

    local file = io.open(path, "rb")
    if not file then
        return nil, "Cannot open file: " .. path
    end

    local content = file:read("*all")
    file:close()
    return content
end

local function writeFile(path, content)
    local file = io.open(path, "wb")
    if not file then
        return false, "Cannot write to file: " .. path
    end

    file:write(content)
    file:close()
    return true
end

local function formatBytes(bytes)
    return string.format("%d bytes", bytes)
end

local function formatPercentage(value)
    return string.format("%.2f%%", value * 100)
end

--------------------------------------------------------------------------------
-- Luau Preprocessing
--------------------------------------------------------------------------------

local function stripLuauTypeAnnotations(code)
    -- Strip generics from function declarations: function foo<T>(...)
    code = code:gsub("(function%s+[%w_]+)%s*<%s*[%w_,%s]+%s*>", "%1")

    -- Strip type annotations from function parameters
    code = code:gsub("%(([^%)]+)%)", function(params)
        if params:find("[%w_]%s*:") then
            local stripped = params:gsub("([%w_]+)%s*:%s*[%w_<>{},%[%]%(%)]+", "%1")
            return "(" .. stripped .. ")"
        end
        return "(" .. params .. ")"
    end)

    -- Strip return type annotations
    code = code:gsub("%)[ \t]*:[ \t]*[%w_<>{},%[%]%(%)]+[ \t]*(\r?\n)", ")%1")

    -- Strip variable type annotations: local x: type = value
    code = code:gsub("(local%s+[%w_]+)[ \t]*:[ \t]*[%w_<>{},%[%]%(%)]+(%s*=)", "%1%2")

    -- Strip type declarations
    code = code:gsub("type%s+[%w_]+%s*=%s*[^\n]*\n", "-- type declaration stripped\n")

    -- Strip export keyword
    code = code:gsub("export%s+", "")

    -- Convert compound assignment operators to long form
    local compoundOps = {
        { "%+=" , "%1 = %1 + (%2)" },
        { "%-=" , "%1 = %1 - (%2)" },
        { "%*=" , "%1 = %1 * (%2)" },
        { "//=" , "%1 = math.floor(%1 / (%2))" },
        { "/="  , "%1 = %1 / (%2)" },
        { "%%=" , "%1 = %1 %% (%2)" },
        { "%^=" , "%1 = %1 ^ (%2)" },
        { "%.%.=", "%1 = %1 .. (%2)" },
    }

    for _, op in ipairs(compoundOps) do
        code = code:gsub("([%w_%.%[%]]+)%s*" .. op[1] .. "%s*([^\n]+)", op[2])
    end

    return code
end

--------------------------------------------------------------------------------
-- CLI Interface
--------------------------------------------------------------------------------

local function printBanner()
    print([[
╔════════════════════════════════════════════════════════════╗
║              Moonstar - Lua/Luau Obfuscator                ║
║                     © 2025 Moonstar                        ║
╚════════════════════════════════════════════════════════════╝
]])
end

local function printUsage()
    printBanner()
    print([[
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
    --compress          Enable compression (default: all algorithms)
    --compress-balanced Enable balanced compression (BWT+RLE+ANS+PPM)
    --compress-fast     Enable fast compression (BWT+RLE+ANS+PPM fast mode)

Presets:
    Minify  - No obfuscation (just minification)
    Weak    - Basic VM protection (Vmify + constant array)
    Medium  - Balanced protection (encryption + VM + all features)
    Strong  - Maximum protection (double VM + all features)

Examples:
    lua moonstar.lua script.lua output.lua --preset=Medium
    lua moonstar.lua script.lua output.lua --preset=Minify
    lua moonstar.lua script.lua output.lua --preset=Strong --LuaU
    lua moonstar.lua script.lua output.lua --preset=Medium --no-antitamper

For more information, visit: https://github.com/InfiniteCod3/Moonstar
]])
end

local function parseArguments(args)
    if #args < 2 then
        return nil, "Missing required arguments"
    end

    local config = {
        inputFile = args[1],
        outputFile = args[2],
        preset = PRESET_NAMES.MEDIUM,
        luaVersion = LUA_VERSIONS.LUA51,
        prettyPrint = false,
        seed = 0,
        disableAntiTamper = false,
        detailed = false,
        compressionMode = nil,  -- nil, "default", "balanced", or "fast"
    }

    local optionHandlers = {
        ["--LuaU"] = function() config.luaVersion = LUA_VERSIONS.LUAU end,
        ["--Lua51"] = function() config.luaVersion = LUA_VERSIONS.LUA51 end,
        ["--pretty"] = function() config.prettyPrint = true end,
        ["--no-antitamper"] = function() config.disableAntiTamper = true end,
        ["--detailed"] = function() config.detailed = true end,
        ["--compress"] = function() config.compressionMode = "default" end,
        ["--compress-balanced"] = function() config.compressionMode = "balanced" end,
        ["--compress-fast"] = function() config.compressionMode = "fast" end,
        ["--help"] = function() return "help" end,
        ["-h"] = function() return "help" end,
    }

    for i = 3, #args do
        local arg = args[i]
        local handled = false

        -- Check for value-based options
        local presetMatch = arg:match("^--preset=(.+)$")
        if presetMatch then
            config.preset = presetMatch
            handled = true
        end

        if not handled then
            local seedMatch = arg:match("^--seed=(.+)$")
            if seedMatch then
                config.seed = tonumber(seedMatch) or 0
                handled = true
            end
        end

        -- Check for flag options
        if not handled then
            local handler = optionHandlers[arg]
            if handler then
                local result = handler()
                if result then return nil, result end
            end
        end
    end

    return config
end

local function applyConfigOverrides(presetConfig, cliConfig)
    presetConfig.LuaVersion = cliConfig.luaVersion
    presetConfig.PrettyPrint = cliConfig.prettyPrint
    presetConfig.DetailedReport = cliConfig.detailed

    if cliConfig.seed > 0 then
        presetConfig.Seed = cliConfig.seed
    end

    -- Disable anti-tamper if requested
    if cliConfig.disableAntiTamper then
        if presetConfig.AntiTamper then
            presetConfig.AntiTamper.Enabled = false
        end

        -- Handle legacy schema with Steps array
        if presetConfig.Steps then
            local filteredSteps = {}
            for _, step in ipairs(presetConfig.Steps) do
                if step.Name ~= "AntiTamper" then
                    table.insert(filteredSteps, step)
                end
            end
            presetConfig.Steps = filteredSteps
        end
    end

    -- Enable compression if requested
    if cliConfig.compressionMode then
        if cliConfig.compressionMode == "default" then
            -- Default (--compress): All algorithms (best ratio, slowest)
            presetConfig.Compression = deepCopy(CompressionConfig.Default)
        elseif cliConfig.compressionMode == "balanced" then
            -- Balanced: BWT + RLE + ANS + PPM (good balance)
            presetConfig.Compression = deepCopy(CompressionConfig.Balanced)
        else
            -- Fast: BWT + RLE + ANS + PPM fast mode (fastest, lower ratio)
            presetConfig.Compression = deepCopy(CompressionConfig.Fast)
        end
    end

    return presetConfig
end

local function loadBanner()
    local bannerFile = io.open("banner.txt", "r")
    if not bannerFile then
        return nil
    end

    local content = bannerFile:read("*all")
    bannerFile:close()
    return "--[[\n" .. content .. "\n]]\n"
end

local function printBuildReport(report)
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

local function printSummary(cliConfig, originalSize, obfuscatedSize)
    print("")
    print("╔" .. string.rep("═", 60) .. "╗")
    print("║  Moonstar - Lua/Luau Obfuscator                            ║")
    print("╚" .. string.rep("═", 60) .. "╝")
    print("")
    print("Input:  " .. cliConfig.inputFile)
    print("Output: " .. cliConfig.outputFile)
    print("Preset: " .. cliConfig.preset)
    print("Target: " .. cliConfig.luaVersion)
    print("")
    print("Original size: " .. formatBytes(originalSize))
end

local function printCompletion(originalSize, obfuscatedSize)
    print("")
    print("Obfuscated size: " .. formatBytes(obfuscatedSize))
    print("Size ratio: " .. formatPercentage(obfuscatedSize / originalSize))
    print("")
    print("[✓] Obfuscation complete!")
    print("")
    print("═" .. string.rep("═", 60))
end

--------------------------------------------------------------------------------
-- Main Entry Point
--------------------------------------------------------------------------------

local function main(args)
    -- Handle help request
    if #args == 0 or args[1] == "--help" or args[1] == "-h" then
        printUsage()
        os.exit(0)
    end

    -- Parse command line arguments
    local cliConfig, err = parseArguments(args)
    if not cliConfig then
        if err == "help" then
            printUsage()
            os.exit(0)
        end
        print("ERROR: " .. err)
        print("")
        printUsage()
        os.exit(1)
    end

    -- Validate preset
    if not Presets[cliConfig.preset] then
        print("ERROR: Unknown preset '" .. cliConfig.preset .. "'")
        print("Available presets: " .. table.concat({
            PRESET_NAMES.MINIFY,
            PRESET_NAMES.WEAK,
            PRESET_NAMES.MEDIUM,
            PRESET_NAMES.STRONG
        }, ", "))
        os.exit(1)
    end

    -- Read input file
    local source, readErr = readFile(cliConfig.inputFile)
    if not source then
        print("ERROR: " .. readErr)
        os.exit(1)
    end

    -- Print initial summary
    printSummary(cliConfig, #source, 0)
    print("")

    -- Prepare preset configuration
    local presetConfig = deepCopy(Presets[cliConfig.preset])
    presetConfig = applyConfigOverrides(presetConfig, cliConfig)

    -- Preprocess LuaU source if needed
    if cliConfig.luaVersion == LUA_VERSIONS.LUAU then
        source = stripLuauTypeAnnotations(source)
    end

    -- Create and run pipeline
    print("Applying obfuscation pipeline...")
    local pipeline = Pipeline:fromConfig(presetConfig)
    local obfuscated, report = pipeline:apply(source, cliConfig.inputFile)

    -- Add banner if available
    local banner = loadBanner()
    if banner then
        obfuscated = banner .. obfuscated
    end

    -- Write output
    print("Writing output file...")
    local writeSuccess, writeErr = writeFile(cliConfig.outputFile, obfuscated)
    if not writeSuccess then
        print("ERROR: " .. writeErr)
        os.exit(1)
    end

    -- Print results
    printCompletion(#source, #obfuscated)

    if report then
        printBuildReport(report)
    end
end

--------------------------------------------------------------------------------
-- Execute with Error Handling
--------------------------------------------------------------------------------

Logger.logLevel = Logger.LogLevel.Info

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

--------------------------------------------------------------------------------
-- Module Export (for require usage)
--------------------------------------------------------------------------------

return {
    Pipeline  = Pipeline,
    colors    = colors,
    Config    = util.readonly(Config),
    Logger    = Logger,
    highlight = highlight,
    Presets   = Presets,
    VERSION   = VERSION,
}

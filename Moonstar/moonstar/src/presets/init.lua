-- This Script is Part of the Moonstar Obfuscator
--
-- presets/init.lua
--
-- Exports all preset configurations for the obfuscator.
-- Each preset is defined in its own file for maintainability.

--------------------------------------------------------------------------------
-- Preset Names (Constants)
--------------------------------------------------------------------------------

local PRESET_NAMES = {
    MINIFY = "Minify",
    WEAK = "Weak",
    MEDIUM = "Medium",
    STRONG = "Strong",
}

--------------------------------------------------------------------------------
-- Lua Version Constants
--------------------------------------------------------------------------------

local LUA_VERSIONS = {
    LUA51 = "Lua51",
    LUAU = "LuaU",
}

--------------------------------------------------------------------------------
-- Shared Compression Configurations
--------------------------------------------------------------------------------

local CompressionConfig = {}

CompressionConfig.Default = {
    Enabled = true,
    FastMode = false,
    BalancedMode = false,
    BWT = true,
    RLE = true,
    ANS = true,
    Huffman = true,
    ArithmeticCoding = true,
    PPM = true,
    PPMOrder = 2,
    Preseed = true,
}

CompressionConfig.Balanced = {
    Enabled = true,
    FastMode = false,
    BalancedMode = true,
    BWT = true,
    RLE = true,
    ANS = true,
    Huffman = false,
    ArithmeticCoding = false,
    PPM = true,
    PPMOrder = 4,
}

CompressionConfig.Fast = {
    Enabled = true,
    FastMode = true,
    BWT = true,
    RLE = true,
    ANS = true,
    Huffman = false,
    ArithmeticCoding = false,
    PPM = true,
    PPMOrder = 4,
}

--------------------------------------------------------------------------------
-- Load Individual Presets
--------------------------------------------------------------------------------

-- Helper for deep copying tables (needed for compression configs)
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

-- Context passed to each preset module
local presetContext = {
    LUA_VERSIONS = LUA_VERSIONS,
    CompressionConfig = CompressionConfig,
    deepCopy = deepCopy,
}

-- Load preset modules
local Minify = require("presets.minify")(presetContext)
local Weak = require("presets.weak")(presetContext)
local Medium = require("presets.medium")(presetContext)
local Strong = require("presets.strong")(presetContext)

--------------------------------------------------------------------------------
-- Presets Table
--------------------------------------------------------------------------------

local Presets = {
    [PRESET_NAMES.MINIFY] = Minify,
    [PRESET_NAMES.WEAK] = Weak,
    [PRESET_NAMES.MEDIUM] = Medium,
    [PRESET_NAMES.STRONG] = Strong,
}

--------------------------------------------------------------------------------
-- Module Export
--------------------------------------------------------------------------------

return {
    Presets = Presets,
    PRESET_NAMES = PRESET_NAMES,
    LUA_VERSIONS = LUA_VERSIONS,
    CompressionConfig = CompressionConfig,
    deepCopy = deepCopy,
}

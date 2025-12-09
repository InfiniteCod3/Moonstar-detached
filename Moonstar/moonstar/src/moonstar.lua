-- This Script is Part of the Moonstar Obfuscator
--
-- moonstar.lua (Library Module)
-- Exports core modules for internal use. Presets are defined in root moonstar.lua only.

--------------------------------------------------------------------------------
-- Package Path Setup
--------------------------------------------------------------------------------

local function getScriptPath()
    local info = debug.getinfo(2, "S")
    if info and info.source then
        local path = info.source:sub(2)
        return path:match("(.*[/%\\])") or "./"
    end
    return "./"
end

local oldPkgPath = package.path
local scriptDir = getScriptPath()
package.path = scriptDir .. "?.lua;" .. package.path

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

--------------------------------------------------------------------------------
-- Restore Package Path & Export
--------------------------------------------------------------------------------

package.path = oldPkgPath

return {
    Pipeline  = Pipeline,
    Presets   = Presets,
    colors    = colors,
    Config    = util.readonly(Config),
    Logger    = Logger,
    highlight = highlight,
}

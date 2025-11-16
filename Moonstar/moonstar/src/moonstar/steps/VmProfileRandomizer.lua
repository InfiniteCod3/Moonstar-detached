-- This Script is Part of the Moonstar Obfuscator
--
-- VmProfileRandomizer.lua
--
-- This step randomizes VM profile layouts to break static signatures

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local visitast = require("moonstar.visitast")
local AstKind = Ast.AstKind

local VmProfileRandomizer = Step:extend()
VmProfileRandomizer.Description = "Randomize VM profiles to break static signatures"
VmProfileRandomizer.Name = "VM Profile Randomizer"

VmProfileRandomizer.SettingsDescriptor = {
    Enabled = {
        type = "boolean",
        default = true,
    },
    PermuteOpcodes = {
        type = "boolean",
        default = true,
    },
    ShuffleHandlers = {
        type = "boolean",
        default = true,
    },
    RandomizeNames = {
        type = "boolean",
        default = true,
    },
}

function VmProfileRandomizer:init(settings)
    -- Initialize randomization seed
    self.randomSeed = math.random(1, 100000)
end

function VmProfileRandomizer:apply(ast, pipeline)
    if not self.Enabled then
        return ast
    end
    
    -- This step works in conjunction with Vmify
    -- It randomizes VM profiles after Vmify has run
    
    -- Store randomization parameters in pipeline for Vmify to use
    if pipeline then
        pipeline.vmProfileSeed = self.randomSeed
        pipeline.vmPermuteOpcodes = self.PermuteOpcodes
        pipeline.vmShuffleHandlers = self.ShuffleHandlers
        pipeline.vmRandomizeNames = self.RandomizeNames
    end
    
    -- The actual VM randomization happens in Vmify step
    -- This step just sets up the configuration
    
    return ast
end

return VmProfileRandomizer

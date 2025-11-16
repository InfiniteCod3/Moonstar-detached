-- This Script is Part of the Moonstar Obfuscator
--
-- PolymorphicLayout.lua
--
-- This step introduces structural polymorphism to obfuscation scaffolds

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local visitast = require("moonstar.visitast")
local AstKind = Ast.AstKind

local PolymorphicLayout = Step:extend()
PolymorphicLayout.Description = "Apply polymorphic layouts to code structures"
PolymorphicLayout.Name = "Polymorphic Layout"

PolymorphicLayout.SettingsDescriptor = {
    Enabled = {
        type = "boolean",
        default = true,
    },
    VaryHelperOrder = {
        type = "boolean",
        default = true,
    },
    VaryJunkPlacement = {
        type = "boolean",
        default = true,
    },
    VaryNamingSchemes = {
        type = "boolean",
        default = true,
    },
}

function PolymorphicLayout:init(settings)
    -- Initialize layout variations
    self.layoutSeed = math.random(1, 10000)
end

function PolymorphicLayout:shuffleStatements(statements)
    -- Shuffle statements that don't depend on each other
    -- We need to be careful to only shuffle independent statements
    
    if not self.VaryHelperOrder then
        return statements
    end
    
    -- Separate local function declarations (helpers) from other statements
    local helpers = {}
    local others = {}
    local helperIndices = {}
    
    for i, stmt in ipairs(statements) do
        if stmt.kind == AstKind.LocalFunctionDeclaration then
            table.insert(helpers, stmt)
            table.insert(helperIndices, i)
        else
            table.insert(others, stmt)
        end
    end
    
    -- Shuffle helpers randomly
    if #helpers > 1 then
        for i = #helpers, 2, -1 do
            local j = math.random(1, i)
            helpers[i], helpers[j] = helpers[j], helpers[i]
        end
    end
    
    -- Reconstruct statements with shuffled helpers
    local result = {}
    local helperIdx = 1
    for i, stmt in ipairs(statements) do
        local isHelper = false
        for _, idx in ipairs(helperIndices) do
            if i == idx then
                isHelper = true
                break
            end
        end
        
        if isHelper then
            if helperIdx <= #helpers then
                table.insert(result, helpers[helperIdx])
                helperIdx = helperIdx + 1
            end
        else
            table.insert(result, stmt)
        end
    end
    
    return result
end

function PolymorphicLayout:apply(ast, pipeline)
    if not self.Enabled then
        return ast
    end
    
    -- Seed RNG with layout seed for deterministic polymorphism
    math.randomseed(self.layoutSeed)
    
    -- Vary the ordering of top-level helpers and declarations
    if self.VaryHelperOrder and ast.body and ast.body.statements then
        ast.body.statements = self:shuffleStatements(ast.body.statements)
    end
    
    -- Visit functions and vary their internal structure
    if self.VaryNamingSchemes then
        visitast(ast, nil, function(node)
            -- Apply naming scheme variations to local variables
            if node.kind == AstKind.LocalVariableDeclaration then
                -- Variables will be renamed later by the pipeline
                -- Just mark them for special handling if needed
            end
        end)
    end
    
    return ast
end

return PolymorphicLayout

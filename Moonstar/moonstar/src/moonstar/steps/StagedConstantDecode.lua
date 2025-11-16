-- This Script is Part of the Moonstar Obfuscator
--
-- StagedConstantDecode.lua
--
-- This step defers and staggers decoding of constants at runtime

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local visitast = require("moonstar.visitast")
local AstKind = Ast.AstKind

local StagedConstantDecode = Step:extend()
StagedConstantDecode.Description = "Defer constant decoding to runtime stages"
StagedConstantDecode.Name = "Staged Constant Decode"

StagedConstantDecode.SettingsDescriptor = {
    Enabled = {
        type = "boolean",
        default = true,
    },
    StageCount = {
        type = "number",
        default = 3,
        min = 2,
        max = 10,
    },
    TieToControlFlow = {
        type = "boolean",
        default = false,
    },
}

function StagedConstantDecode:init(settings)
    -- Initialize staging configuration
    self.stages = {}
end

function StagedConstantDecode:createStageFunction(scope, stageIndex)
    -- Create a function that initializes constants for this stage
    -- This is a simplified version - full implementation would coordinate with ConstantArray
    
    local stageBody = {}
    
    -- Create a simple initialization function
    -- In a full implementation, this would populate constant tables
    local returnStmt = Ast.ReturnStatement({Ast.BooleanExpression(true)})
    table.insert(stageBody, returnStmt)
    
    return Ast.FunctionLiteralExpression({}, Ast.Block(stageBody))
end

function StagedConstantDecode:apply(ast, pipeline)
    if not self.Enabled then
        return ast
    end
    
    -- Create staging functions
    local globalScope = ast.globalScope
    
    for i = 1, self.StageCount do
        local stageScope = Scope:new(globalScope)
        local stageName = "__CONST_STAGE_" .. i .. "_" .. tostring(math.random(1000, 9999))
        
        local stageFunc = self:createStageFunction(stageScope, i)
        stageFunc.body.scope = stageScope
        
        local stageDecl = Ast.LocalVariableDeclaration(
            {Ast.VariableExpression(globalScope, stageName)},
            {stageFunc}
        )
        
        -- Insert stage function
        table.insert(ast.body.statements, stageDecl)
        table.insert(self.stages, stageName)
    end
    
    -- Store stage info in pipeline
    if pipeline then
        pipeline.constantStages = self.stages
        pipeline.tieToControlFlow = self.TieToControlFlow
    end
    
    return ast
end

return StagedConstantDecode

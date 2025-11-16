-- This Script is Part of the Moonstar Obfuscator
--
-- AntiDebug.lua
--
-- This step detects debugging/tracing environments and reacts appropriately

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local visitast = require("moonstar.visitast")
local AstKind = Ast.AstKind

local AntiDebug = Step:extend()
AntiDebug.Description = "Detect and react to debugging environments"
AntiDebug.Name = "Anti Debug"

AntiDebug.SettingsDescriptor = {
    Enabled = {
        type = "boolean",
        default = true,
    },
    CheckDebugHooks = {
        type = "boolean",
        default = true,
    },
    ReactionMode = {
        type = "enum",
        values = {"silent", "exit", "mislead"},
        default = "silent",
    },
}

function AntiDebug:init(settings)
    -- Store settings
end

function AntiDebug:createDebugCheck(scope)
    -- Create a check for debug library
    -- Returns true if debugging is detected
    
    local checkStatements = {}
    
    if self.CheckDebugHooks then
        -- Check if debug library exists
        local debugCheck = Ast.BinaryExpression(
            Ast.IndexExpression(
                Ast.VariableExpression(scope, "_G"),
                Ast.StringExpression("debug")
            ),
            "~=",
            Ast.NilExpression()
        )
        
        -- If debug exists, react based on ReactionMode
        local reactionBlock = Ast.Block({})
        
        if self.ReactionMode == "exit" then
            -- Exit the program
            table.insert(reactionBlock.statements, 
                Ast.FunctionCallStatement(
                    Ast.FunctionCallExpression(
                        Ast.IndexExpression(
                            Ast.VariableExpression(scope, "os"),
                            Ast.StringExpression("exit")
                        ),
                        {Ast.NumberExpression(1)}
                    )
                )
            )
        elseif self.ReactionMode == "mislead" then
            -- Return a misleading value  
            table.insert(reactionBlock.statements,
                Ast.ReturnStatement({Ast.BooleanExpression(false)})
            )
        end
        -- For "silent" mode, we just set a flag but continue
        
        local ifStmt = Ast.IfStatement({
            Ast.IfClause(debugCheck, reactionBlock)
        })
        
        table.insert(checkStatements, ifStmt)
    end
    
    return Ast.Block(checkStatements)
end

function AntiDebug:apply(ast, pipeline)
    if not self.Enabled then
        return ast
    end
    
    -- Insert anti-debug checks at the beginning of the script
    local globalScope = ast.globalScope
    local checkBlock = self:createDebugCheck(globalScope)
    
    -- Insert the debug checks at the beginning
    for i = #checkBlock.statements, 1, -1 do
        table.insert(ast.body.statements, 1, checkBlock.statements[i])
    end
    
    return ast
end

return AntiDebug

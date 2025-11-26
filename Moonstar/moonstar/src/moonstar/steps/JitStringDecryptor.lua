-- This Script is Part of the Moonstar Obfuscator
--
-- JitStringDecryptor.lua
--
-- This Step replaces string literals with unique, JIT-compiled closures 
-- that construct the string at runtime using mathematical operations.
-- This is a form of "Custom Bytecode Encryption" for data, as each string
-- has its own unique "bytecode" (logic) to reconstruct it.

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local visitast = require("moonstar.visitast")
local util = require("moonstar.util")
local AstKind = Ast.AstKind

local JitStringDecryptor = Step:extend()
JitStringDecryptor.Description = "Replaces strings with unique closures that construct them at runtime."
JitStringDecryptor.Name = "JIT String Decryptor"

JitStringDecryptor.SettingsDescriptor = {
    Enabled = {
        type = "boolean",
        default = true,
    },
    MaxLength = {
        type = "number",
        default = 50, -- Only apply to strings shorter than this to avoid code bloat
    },
}

function JitStringDecryptor:init(settings)
end

function JitStringDecryptor:apply(ast, pipeline)
    if not self.Enabled then return ast end

    visitast(ast, function(node, data)
        if node.kind == AstKind.StringExpression then
            if #node.value > 0 and #node.value <= self.MaxLength then
                return self:generateJitClosure(node.value, data.scope), true
            end
        end
    end)

    return ast
end

function JitStringDecryptor:generateJitClosure(str, scope)
    -- Create a unique function that returns the string
    -- (function() return string.char(...) .. ... end)()
    
    local funcScope = Scope:new(scope)
    local charScope, charId = scope:resolve("string")
    
    -- Generate a complex expression for each character
    local parts = {}
    
    for i = 1, #str do
        local byte = string.byte(str, i)
        
        -- Mathematical obfuscation for the byte
        -- e.g. byte = (x * y - z) % 256
        local x = math.random(1, 100)
        local y = math.random(1, 50)
        local target = byte
        
        -- target = (val - offset)
        local offset = math.random(1, 1000)
        local val = target + offset
        
        -- AST: string.char((val - offset))
        local charCall = Ast.FunctionCallExpression(
            Ast.IndexExpression(
                Ast.VariableExpression(charScope, charId),
                Ast.StringExpression("char")
            ),
            {
                Ast.SubExpression(
                    Ast.NumberExpression(val),
                    Ast.NumberExpression(offset)
                )
            }
        )
        
        table.insert(parts, charCall)
    end
    
    -- Combine parts with concatenation
    local bodyExpr
    if #parts == 1 then
        bodyExpr = parts[1]
    else
        bodyExpr = parts[1]
        for i = 2, #parts do
            bodyExpr = Ast.StrCatExpression(bodyExpr, parts[i])
        end
    end
    
    -- Wrap in a closure call
    local closure = Ast.FunctionLiteralExpression(
        {}, -- No args
        Ast.Block({
            Ast.ReturnStatement({ bodyExpr })
        }, funcScope)
    )
    
    return Ast.FunctionCallExpression(closure, {})
end

return JitStringDecryptor

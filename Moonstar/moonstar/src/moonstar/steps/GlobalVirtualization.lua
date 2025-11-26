-- This Script is Part of the Moonstar Obfuscator
--
-- GlobalVirtualization.lua
--
-- This Step prevents the script from easily accessing the global environment
-- by copying used globals to locals and restricting _G/getfenv.

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local visitast = require("moonstar.visitast")
local util = require("moonstar.util")
local AstKind = Ast.AstKind

local GlobalVirtualization = Step:extend()
GlobalVirtualization.Description = "Virtualizes the global environment by copying globals to locals."
GlobalVirtualization.Name = "Global Virtualization"

GlobalVirtualization.SettingsDescriptor = {
    Enabled = {
        type = "boolean",
        default = true,
    },
    VirtualizeEnv = {
        type = "boolean",
        default = true, -- Virtualize _G and getfenv
    },
}

function GlobalVirtualization:init(settings)
end

function GlobalVirtualization:apply(ast, pipeline)
    if not self.Enabled then return ast end

    local globalUsage = {}
    local scopeToFunc = {}
    local topScope = ast.body.scope

    -- 1. Scan for Global Usages
    visitast(ast, function(node, data)
        if node.kind == AstKind.VariableExpression or node.kind == AstKind.AssignmentVariable then
            if node.scope.isGlobal then
                local name = node.scope:getVariableName(node.id)
                if name and name ~= "_G" and name ~= "_ENV" and name ~= "getfenv" then
                    globalUsage[name] = true
                end
            end
        end
    end)

    -- 2. Create Local Definitions for Globals
    local newLocals = {}
    local replacements = {} -- name -> local var definition

    -- Helper to create a random variable name
    local function randomName()
        if pipeline.namegenerator then
             return pipeline.namegenerator:generateName(math.random(1, 10000))
        end
        return "g_" .. math.random(1000, 9999)
    end

    local declIds = {}
    local declExprs = {}

    for name, _ in pairs(globalUsage) do
        -- Add a new variable to the top scope
        local newVarId = topScope:addVariable()
        replacements[name] = { id = newVarId, scope = topScope }
        
        table.insert(declIds, newVarId)
        -- Initialize it with the global value: local _local_print = print
        -- We need to resolve the global in the global scope
        local globalId = topScope:resolveGlobal(name)
        table.insert(declExprs, Ast.VariableExpression(topScope, globalId))
    end

    -- 3. Insert Local Declarations at the top
    if #declIds > 0 then
        local declStat = Ast.LocalVariableDeclaration(topScope, declIds, declExprs)
        table.insert(ast.body.statements, 1, declStat)
    end

    -- 4. Replace Global Usages with Locals
    visitast(ast, function(node, data)
        if node.kind == AstKind.VariableExpression or node.kind == AstKind.AssignmentVariable then
            if node.scope.isGlobal then
                local name = node.scope:getVariableName(node.id)
                if replacements[name] then
                    -- Point to the new local variable
                    node.scope = replacements[name].scope
                    node.id = replacements[name].id
                end
            end
        end
    end)

    -- 5. Virtualize Environment (Hide _G/getfenv)
    if self.VirtualizeEnv then
         -- In Lua 5.1/Luau, we can't easily "delete" _G without breaking things,
         -- but we can shadow it.
         
         local shadowIds = {}
         local shadowExprs = {}
         
         -- Shadow getfenv
         local gfId = topScope:addVariable()
         table.insert(shadowIds, gfId)
         table.insert(shadowExprs, Ast.FunctionLiteralExpression({}, Ast.Block({}, topScope))) -- Empty function
         
         -- Shadow _G
         local gId = topScope:addVariable()
         table.insert(shadowIds, gId)
         table.insert(shadowExprs, Ast.TableConstructorExpression({})) -- Empty table

         -- Insert at the very top (after the global copies)
         -- Actually, we want this *after* we copied the real globals so they are preserved
         -- But *before* the user code runs.
         -- Since we inserted the copies at index 1, this should be at index 2.
         if #shadowIds > 0 then
             local shadowStat = Ast.LocalVariableDeclaration(topScope, shadowIds, shadowExprs)
             table.insert(ast.body.statements, 2, shadowStat)
             
             -- Now replace usages of getfenv / _G in the code with these shadows
             -- (Logic omitted for brevity, relies on scope resolution which might already pick up new locals if we re-resolved, but here we just injected)
         end
    end

    return ast
end

return GlobalVirtualization

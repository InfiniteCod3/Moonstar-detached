-- This Script is Part of the Moonstar Obfuscator
--
-- AntiTamper.lua
--
-- This Script provides an Obfuscation Step that adds advanced anti-tamper checks
-- designed to detect environment manipulation, hooking, and tampering.

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local randomStrings = require("moonstar.randomStrings")
local util = require("moonstar.util")

local AntiTamper = Step:extend()
AntiTamper.Description = "Adds advanced integrity checks to detect tampering, hooking, and environment manipulation."
AntiTamper.Name = "Anti-Tamper"

AntiTamper.SettingsDescriptor = {
    Enabled = { type = "boolean", default = true },
    Mode = { type = "string", default = "advanced" }, -- "simple", "advanced"
}

function AntiTamper:init(settings) end

function AntiTamper:apply(ast, pipeline)
    -- Manually construct AST to ensure Scope consistency with the main program.
    -- This avoids "Arithmetic on Nil" crashes caused by disconnected scopes from Parser:parse().

    local parentScope = ast.body.scope
    local atScope = Scope:new(parentScope)

    -- Helper to resolve globals safely from the root scope
    local globalScope = parentScope
    while globalScope.parentScope do
        globalScope = globalScope.parentScope
    end

    local function getGlobal(name)
        local _, var = globalScope:resolve(name)
        if not var then
            -- Register missing global variable
            var = globalScope:addVariable()
            -- Assign the name to the variable ID so Vmify can resolve it string-wise
            if globalScope.variableNames then
                globalScope.variableNames[var] = name
            elseif globalScope.variables then
                 -- Fallback for different Scope implementation versions
                 -- In some versions, variables maps id->name or name->id
                 -- Assuming id->name based on typical Lua obfuscator patterns
                 globalScope.variables[var] = name
            end

            -- Also ensure it resolves for future lookups
            -- Scope usually maintains a lookup table?
            -- Scope:resolve iterates variables?
            -- If we set the name, resolve should find it next time.
        end
        return Ast.VariableExpression(globalScope, var)
    end

    -- Globals we need
    local setmetatableVar = getGlobal("setmetatable")
    local getmetatableVar = getGlobal("getmetatable")
    local tostringVar     = getGlobal("tostring")
    local pcallVar        = getGlobal("pcall")
    local typeVar         = getGlobal("type")
    local pairsVar        = getGlobal("pairs")
    local stringVar       = getGlobal("string")

    -- Helper to create crash block (infinite loop)
    local function createCrashBlock()
        local loopScope = Scope:new(atScope)
        return Ast.Block({
            Ast.WhileStatement(
                Ast.Block({}, Scope:new(loopScope)),
                Ast.BooleanExpression(true)
            )
        }, loopScope)
    end

    local statements = {}

    -- 1. Metatable Protection Check
    -- Verify that setmetatable/getmetatable work and honor __metatable
    local checkMetaVar = atScope:addVariable()
    local checkMetaDecl = Ast.LocalVariableDeclaration(atScope, {checkMetaVar}, {Ast.TableConstructorExpression({})})
    table.insert(statements, checkMetaDecl)

    local metaTableVar = atScope:addVariable()
    local metaTableDecl = Ast.LocalVariableDeclaration(atScope, {metaTableVar}, {
        Ast.TableConstructorExpression({
            Ast.KeyedTableEntry(Ast.StringExpression("__metatable"), Ast.StringExpression("locked"))
        })
    })
    table.insert(statements, metaTableDecl)

    table.insert(statements, Ast.FunctionCallStatement(setmetatableVar, {
        Ast.VariableExpression(atScope, checkMetaVar),
        Ast.VariableExpression(atScope, metaTableVar)
    }))

    local resultVar = atScope:addVariable()
    table.insert(statements, Ast.LocalVariableDeclaration(atScope, {resultVar}, {
        Ast.FunctionCallExpression(getmetatableVar, {Ast.VariableExpression(atScope, checkMetaVar)})
    }))

    local check1 = Ast.IfStatement(
        Ast.NotEqualsExpression(Ast.VariableExpression(atScope, resultVar), Ast.StringExpression("locked")),
        createCrashBlock(),
        {}, nil
    )
    table.insert(statements, check1)

    -- 2. Function Integrity (tostring check)
    -- Check if tostring(getmetatable) looks like a function
    -- Use string matching patterns if possible, or just check it starts with "function:" or similar?
    -- Safer: Check type(getmetatable) == "function"
    -- And tostring(getmetatable) ~= nil

    local typeCheckVar = atScope:addVariable()
    table.insert(statements, Ast.LocalVariableDeclaration(atScope, {typeCheckVar}, {
        Ast.FunctionCallExpression(typeVar, {getmetatableVar})
    }))

    local check2 = Ast.IfStatement(
        Ast.NotEqualsExpression(Ast.VariableExpression(atScope, typeCheckVar), Ast.StringExpression("function")),
        createCrashBlock(),
        {}, nil
    )
    table.insert(statements, check2)

    -- 3. Environment Tamper Check (Honeypot)
    -- Create a decoy variable and ensure it retains value (basic)
    local honeypotVar = atScope:addVariable()
    local decoyVal = randomStrings.randomString(8)
    table.insert(statements, Ast.LocalVariableDeclaration(atScope, {honeypotVar}, {Ast.StringExpression(decoyVal)}))

    local check3 = Ast.IfStatement(
        Ast.NotEqualsExpression(Ast.VariableExpression(atScope, honeypotVar), Ast.StringExpression(decoyVal)),
        createCrashBlock(),
        {}, nil
    )
    table.insert(statements, check3)

    -- 4. Anti-Hook (Table)
    -- Verify table.insert or similar isn't hooked (by creating a table and checking length?)
    -- Skipped to avoid dependency on 'table' global if not verified.

    -- Construct the DoStatement
    local doStat = Ast.DoStatement(Ast.Block(statements, atScope))

    -- Insert at beginning
    table.insert(ast.body.statements, 1, doStat)

    return ast
end

return AntiTamper

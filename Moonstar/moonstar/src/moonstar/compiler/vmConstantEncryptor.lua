local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local util = require("moonstar.util");

local VmConstantEncryptor = {}

-- LCG Constants
local LCG_A = 1664525
local LCG_C = 1013904223
local LCG_M = 4294967296

-- Cache for unique seeds to avoid collisions
local usedSeeds = {}

local function getUniqueSeed()
    local seed
    repeat
        seed = math.random(1, 2147483647)
    until not usedSeeds[seed]
    usedSeeds[seed] = true
    return seed
end

function VmConstantEncryptor.encrypt(str)
    local seed = getUniqueSeed()
    local state = seed
    local encrypted = {}
    local len = #str

    for i = 1, len do
        local byte = string.byte(str, i)

        -- LCG Step
        state = (LCG_A * state + LCG_C) % LCG_M
        local key = math.floor(state / 65536) % 256

        -- Encryption: (byte + key) % 256
        local encByte = (byte + key) % 256

        table.insert(encrypted, encByte)
    end

    return encrypted, seed
end

-- Inject the decryption function and cache table into the compiler's scope
function VmConstantEncryptor.injectDecoder(compiler)
    local scope = compiler.scope -- The upvalue scope (persistent across VM calls)

    -- define 'decryptCache' var in upvalue scope
    local cacheVar = scope:addVariable()
    compiler:addStatement(Ast.AssignmentStatement(
        {Ast.AssignmentVariable(scope, cacheVar)},
        {Ast.TableConstructorExpression({})}
    ), {}, {}, false)

    -- define 'vmStringDecrypt' var in upvalue scope
    local decryptFuncVar = scope:addVariable()

    -- Create the function body
    local funcScope = Scope:new(scope)
    local seedArg = funcScope:addVariable()
    local bytesArg = funcScope:addVariable()

    -- References
    funcScope:addReferenceToHigherScope(scope, cacheVar)

    local stateVar = funcScope:addVariable()
    local resultVar = funcScope:addVariable()
    local keyVar = funcScope:addVariable()
    
    -- PERF-OPT: Bit library variable for fast key extraction
    -- Uses bit32 (LuaU/Roblox, Lua 5.2+) or bit (LuaJIT), nil for vanilla Lua 5.1
    local bitLibVar = funcScope:addVariable()

    -- For Loop setup
    local forScope = Scope:new(funcScope)
    local iVar = forScope:addVariable()
    forScope:addReferenceToHigherScope(funcScope, stateVar)
    forScope:addReferenceToHigherScope(funcScope, resultVar)
    forScope:addReferenceToHigherScope(funcScope, bytesArg)
    forScope:addReferenceToHigherScope(funcScope, keyVar)
    forScope:addReferenceToHigherScope(funcScope, bitLibVar)

    -- Helper to access globals via compiler env
    local function getGlobal(name)
        return Ast.IndexExpression(Ast.VariableExpression(compiler.scope, compiler.envVar), Ast.StringExpression(name))
    end
    
    -- PERF-OPT: Build bit-based key extraction expression
    -- When bit library available: bit.band(bit.rshift(state, 16), 255)
    -- Fallback: ((state - (state % 65536)) / 65536) % 256
    local function buildKeyExtraction()
        local stateExpr = Ast.VariableExpression(funcScope, stateVar)
        local bitVar = Ast.VariableExpression(funcScope, bitLibVar)
        
        -- Fast path: bit.band(bit.rshift(state, 16), 255)
        local bitRshift = Ast.IndexExpression(bitVar, Ast.StringExpression("rshift"))
        local bitBand = Ast.IndexExpression(bitVar, Ast.StringExpression("band"))
        local fastPath = Ast.FunctionCallExpression(bitBand, {
            Ast.FunctionCallExpression(bitRshift, {stateExpr, Ast.NumberExpression(16)}),
            Ast.NumberExpression(255)
        })
        
        -- Slow path: ((state - (state % 65536)) / 65536) % 256
        local slowPath = Ast.ModExpression(
            Ast.DivExpression(
                Ast.SubExpression(
                    stateExpr,
                    Ast.ModExpression(stateExpr, Ast.NumberExpression(65536))
                ),
                Ast.NumberExpression(65536)
            ),
            Ast.NumberExpression(256)
        )
        
        -- _bit and fastPath or slowPath
        return Ast.OrExpression(
            Ast.AndExpression(bitVar, fastPath),
            slowPath
        )
    end

    -- Function Body AST
    local body = Ast.Block({
        -- if cache[seed] then return cache[seed] end
        Ast.IfStatement(
            Ast.IndexExpression(Ast.VariableExpression(scope, cacheVar), Ast.VariableExpression(funcScope, seedArg)),
            Ast.Block({
                Ast.ReturnStatement({Ast.IndexExpression(Ast.VariableExpression(scope, cacheVar), Ast.VariableExpression(funcScope, seedArg))})
            }, Scope:new(funcScope)),
            {},
            nil
        ),
        
        -- PERF-OPT: local _bit = bit32 or bit (runtime detection for LuaU/LuaJIT/Lua5.1)
        Ast.LocalVariableDeclaration(funcScope, {bitLibVar}, {
            Ast.OrExpression(getGlobal("bit32"), getGlobal("bit"))
        }),

        -- local result = {}
        Ast.LocalVariableDeclaration(funcScope, {resultVar}, {Ast.TableConstructorExpression({})}),

        -- local state = seed
        Ast.LocalVariableDeclaration(funcScope, {stateVar}, {Ast.VariableExpression(funcScope, seedArg)}),

        -- for i = 1, #bytes do
        Ast.ForStatement(
            forScope,
            iVar,
            Ast.NumberExpression(1),
            Ast.LenExpression(Ast.VariableExpression(funcScope, bytesArg)),
            Ast.NumberExpression(1),
            Ast.Block({
                -- state = (1664525 * state + 1013904223) % 4294967296
                Ast.AssignmentStatement(
                    {Ast.AssignmentVariable(funcScope, stateVar)},
                    {Ast.ModExpression(
                        Ast.AddExpression(
                            Ast.MulExpression(Ast.NumberExpression(LCG_A), Ast.VariableExpression(funcScope, stateVar)),
                            Ast.NumberExpression(LCG_C)
                        ),
                        Ast.NumberExpression(LCG_M)
                    )}
                ),

                -- PERF-OPT: local key = _bit and bit.band(bit.rshift(state, 16), 255) or ((state - (state % 65536)) / 65536) % 256
                -- Uses bit operations when available (LuaU/LuaJIT), falls back to math for vanilla Lua 5.1
                Ast.LocalVariableDeclaration(forScope, {keyVar}, {buildKeyExtraction()}),

                -- result[i] = string.char(...)
                 Ast.AssignmentStatement(
                    {Ast.AssignmentIndexing(
                        Ast.VariableExpression(funcScope, resultVar),
                        Ast.VariableExpression(forScope, iVar)
                    )},
                    {
                        Ast.FunctionCallExpression(
                            Ast.IndexExpression(getGlobal("string"), Ast.StringExpression("char")),
                            {
                                Ast.ModExpression(
                                    Ast.SubExpression(
                                        Ast.IndexExpression(Ast.VariableExpression(funcScope, bytesArg), Ast.VariableExpression(forScope, iVar)),
                                        Ast.VariableExpression(forScope, keyVar)
                                    ),
                                    Ast.NumberExpression(256)
                                )
                            }
                        )
                    }
                )
            }, forScope)
        ),

        -- local final = table.concat(result)
        Ast.LocalVariableDeclaration(funcScope, {resultVar}, {
             Ast.FunctionCallExpression(
                Ast.IndexExpression(getGlobal("table"), Ast.StringExpression("concat")),
                {Ast.VariableExpression(funcScope, resultVar)}
            )
        }),

        -- cache[seed] = final
        Ast.AssignmentStatement(
            {Ast.IndexExpression(Ast.VariableExpression(scope, cacheVar), Ast.VariableExpression(funcScope, seedArg))},
            {Ast.VariableExpression(funcScope, resultVar)}
        ),

        -- return final
        Ast.ReturnStatement({Ast.VariableExpression(funcScope, resultVar)})

    }, funcScope)

    -- Assign function
    compiler:addStatement(Ast.AssignmentStatement(
        {Ast.AssignmentVariable(scope, decryptFuncVar)},
        {Ast.FunctionLiteralExpression({Ast.VariableExpression(funcScope, seedArg), Ast.VariableExpression(funcScope, bytesArg)}, body)}
    ), {}, {}, false)

    return decryptFuncVar
end

return VmConstantEncryptor

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

    -- For Loop setup
    local forScope = Scope:new(funcScope)
    local iVar = forScope:addVariable()
    forScope:addReferenceToHigherScope(funcScope, stateVar)
    forScope:addReferenceToHigherScope(funcScope, resultVar)
    forScope:addReferenceToHigherScope(funcScope, bytesArg)
    forScope:addReferenceToHigherScope(funcScope, keyVar)

    -- Helper to access globals via compiler env
    local function getGlobal(name)
        return Ast.IndexExpression(Ast.VariableExpression(compiler.scope, compiler.envVar), Ast.StringExpression(name))
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

                -- local key = math.floor(state / 65536) % 256
                Ast.LocalVariableDeclaration(forScope, {keyVar}, {
                    Ast.ModExpression(
                        Ast.DivExpression(
                            Ast.SubExpression(
                                Ast.VariableExpression(funcScope, stateVar),
                                Ast.ModExpression(Ast.VariableExpression(funcScope, stateVar), Ast.NumberExpression(65536))
                            ),
                            Ast.NumberExpression(65536)
                        ),
                        Ast.NumberExpression(256)
                    )
                }),

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

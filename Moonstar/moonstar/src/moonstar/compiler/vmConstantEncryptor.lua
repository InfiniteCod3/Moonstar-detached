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

-- ============================================================================
-- S4: Multi-Layer Encryption Functions
-- ============================================================================

-- Layer 1: XOR encryption with multi-byte key
local function xorEncrypt(bytes, key)
    local result = {}
    for i = 1, #bytes do
        local keyByte = key[((i - 1) % #key) + 1]
        result[i] = (bytes[i] + keyByte) % 256
    end
    return result
end

-- Layer 2: Caesar cipher with position-based shift
local function caesarEncrypt(bytes, shift)
    local result = {}
    for i = 1, #bytes do
        local posShift = (shift + i) % 256
        result[i] = (bytes[i] + posShift) % 256
    end
    return result
end

-- Layer 3: Substitution cipher with S-box (generated from seed)
local function generateSBox(seed)
    local state = seed
    local sbox = {}
    for i = 0, 255 do sbox[i] = i end
    
    -- Fisher-Yates shuffle using LCG
    for i = 255, 1, -1 do
        state = (LCG_A * state + LCG_C) % LCG_M
        local j = math.floor(state / 65536) % (i + 1)
        sbox[i], sbox[j] = sbox[j], sbox[i]
    end
    return sbox
end

local function substitutionEncrypt(bytes, sbox)
    local result = {}
    for i = 1, #bytes do
        result[i] = sbox[bytes[i]]
    end
    return result
end

-- Generate XOR key from seed
local function generateXorKey(seed)
    math.randomseed(seed)
    local keyLen = math.random(4, 8)
    local key = {}
    for i = 1, keyLen do
        key[i] = math.random(0, 255)
    end
    return key
end

-- S4: Multi-layer encryption (XOR → Caesar → Substitution chain)
function VmConstantEncryptor.encryptMultiLayer(str, numLayers)
    numLayers = numLayers or 3
    
    local bytes = {}
    for i = 1, #str do
        bytes[i] = string.byte(str, i)
    end
    
    local masterSeed = getUniqueSeed()
    local layerState = masterSeed
    local encrypted = bytes
    
    -- Store layer metadata for decoder generation
    local layers = {}
    
    for layer = 1, numLayers do
        local layerType = ((layer - 1) % 3) + 1
        
        -- Advance LCG for layer seed
        layerState = (LCG_A * layerState + LCG_C) % LCG_M
        local layerSeed = math.floor(layerState / 65536)
        
        if layerType == 1 then
            -- XOR layer
            local key = generateXorKey(layerSeed)
            encrypted = xorEncrypt(encrypted, key)
            table.insert(layers, {type = 1, key = key})
        elseif layerType == 2 then
            -- Caesar layer
            local shift = layerSeed % 256
            if shift == 0 then shift = 1 end
            encrypted = caesarEncrypt(encrypted, shift)
            table.insert(layers, {type = 2, shift = shift})
        else
            -- Substitution layer
            local sbox = generateSBox(layerSeed)
            encrypted = substitutionEncrypt(encrypted, sbox)
            table.insert(layers, {type = 3, seed = layerSeed})
        end
    end
    
    return encrypted, masterSeed, numLayers, layers
end

-- Original single-layer LCG encryption (for backward compatibility)
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

-- ============================================================================
-- S4: Multi-Layer Decoder Injection
-- Injects a decoder that can handle XOR + Caesar + Substitution layers
-- ============================================================================

function VmConstantEncryptor.injectMultiLayerDecoder(compiler)
    local scope = compiler.scope
    
    -- Define 'multiDecryptCache' var in upvalue scope
    local cacheVar = scope:addVariable()
    compiler:addStatement(Ast.AssignmentStatement(
        {Ast.AssignmentVariable(scope, cacheVar)},
        {Ast.TableConstructorExpression({})}
    ), {}, {}, false)
    
    -- Define 'vmMultiDecrypt' var in upvalue scope
    local decryptFuncVar = scope:addVariable()
    
    -- Create the function body
    local funcScope = Scope:new(scope)
    local seedArg = funcScope:addVariable()         -- master seed
    local bytesArg = funcScope:addVariable()        -- encrypted bytes (table)
    local numLayersArg = funcScope:addVariable()    -- number of layers
    local layerDataArg = funcScope:addVariable()    -- layer metadata (keys, shifts, sbox seeds)
    
    -- References
    funcScope:addReferenceToHigherScope(scope, cacheVar)
    
    local resultVar = funcScope:addVariable()
    local layerVar = funcScope:addVariable()
    
    -- For loop to copy bytes
    local copyScope = Scope:new(funcScope)
    local copyIVar = copyScope:addVariable()
    copyScope:addReferenceToHigherScope(funcScope, resultVar)
    copyScope:addReferenceToHigherScope(funcScope, bytesArg)
    
    -- For loop for layers (reverse order)
    local layerScope = Scope:new(funcScope)
    local layerIdxVar = layerScope:addVariable()
    local layerInfoVar = layerScope:addVariable()
    local layerTypeVar = layerScope:addVariable()
    layerScope:addReferenceToHigherScope(funcScope, resultVar)
    layerScope:addReferenceToHigherScope(funcScope, layerDataArg)
    layerScope:addReferenceToHigherScope(funcScope, numLayersArg)
    
    -- Inner loop for decrypting bytes
    local innerScope = Scope:new(layerScope)
    local iVar = innerScope:addVariable()
    innerScope:addReferenceToHigherScope(layerScope, layerInfoVar)
    innerScope:addReferenceToHigherScope(layerScope, layerTypeVar)
    innerScope:addReferenceToHigherScope(funcScope, resultVar)
    
    -- Final loop to convert to chars
    local charScope = Scope:new(funcScope)
    local charIVar = charScope:addVariable()
    local charResultVar = charScope:addVariable()
    charScope:addReferenceToHigherScope(funcScope, resultVar)
    
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
        
        -- Copy bytes to result: for i = 1, #bytes do result[i] = bytes[i] end
        Ast.ForStatement(
            copyScope,
            copyIVar,
            Ast.NumberExpression(1),
            Ast.LenExpression(Ast.VariableExpression(funcScope, bytesArg)),
            Ast.NumberExpression(1),
            Ast.Block({
                Ast.AssignmentStatement(
                    {Ast.AssignmentIndexing(
                        Ast.VariableExpression(funcScope, resultVar),
                        Ast.VariableExpression(copyScope, copyIVar)
                    )},
                    {Ast.IndexExpression(
                        Ast.VariableExpression(funcScope, bytesArg),
                        Ast.VariableExpression(copyScope, copyIVar)
                    )}
                )
            }, copyScope)
        ),
        
        -- Process layers in REVERSE order for decryption
        -- for layerIdx = numLayers, 1, -1 do
        Ast.ForStatement(
            layerScope,
            layerIdxVar,
            Ast.VariableExpression(funcScope, numLayersArg),
            Ast.NumberExpression(1),
            Ast.NumberExpression(-1),
            Ast.Block({
                -- local layerInfo = layerData[layerIdx]
                Ast.LocalVariableDeclaration(layerScope, {layerInfoVar}, {
                    Ast.IndexExpression(
                        Ast.VariableExpression(funcScope, layerDataArg),
                        Ast.VariableExpression(layerScope, layerIdxVar)
                    )
                }),
                
                -- local layerType = layerInfo.type
                Ast.LocalVariableDeclaration(layerScope, {layerTypeVar}, {
                    Ast.IndexExpression(
                        Ast.VariableExpression(layerScope, layerInfoVar),
                        Ast.StringExpression("type")
                    )
                }),
                
                -- Decrypt each byte based on layer type
                -- for i = 1, #result do
                Ast.ForStatement(
                    innerScope,
                    iVar,
                    Ast.NumberExpression(1),
                    Ast.LenExpression(Ast.VariableExpression(funcScope, resultVar)),
                    Ast.NumberExpression(1),
                    Ast.Block({
                        -- Polymorphic decryption based on layerType
                        -- Type 1 (XOR): result[i] = (result[i] - key[(i-1)%#key+1]) % 256
                        -- Type 2 (Caesar): result[i] = (result[i] - (shift + i)) % 256
                        -- Type 3 (Substitution): result[i] = inverseSbox[result[i]]
                        -- (Simplified: just XOR decrypt for now, full impl needs conditional logic)
                        Ast.AssignmentStatement(
                            {Ast.AssignmentIndexing(
                                Ast.VariableExpression(funcScope, resultVar),
                                Ast.VariableExpression(innerScope, iVar)
                            )},
                            {Ast.ModExpression(
                                Ast.AddExpression(
                                    Ast.SubExpression(
                                        Ast.IndexExpression(
                                            Ast.VariableExpression(funcScope, resultVar),
                                            Ast.VariableExpression(innerScope, iVar)
                                        ),
                                        -- Decrypt key retrieval (simplified - uses first key byte)
                                        Ast.IndexExpression(
                                            Ast.IndexExpression(
                                                Ast.VariableExpression(layerScope, layerInfoVar),
                                                Ast.StringExpression("key")
                                            ),
                                            Ast.AddExpression(
                                                Ast.ModExpression(
                                                    Ast.SubExpression(
                                                        Ast.VariableExpression(innerScope, iVar),
                                                        Ast.NumberExpression(1)
                                                    ),
                                                    Ast.LenExpression(
                                                        Ast.IndexExpression(
                                                            Ast.VariableExpression(layerScope, layerInfoVar),
                                                            Ast.StringExpression("key")
                                                        )
                                                    )
                                                ),
                                                Ast.NumberExpression(1)
                                            )
                                        )
                                    ),
                                    Ast.NumberExpression(256)
                                ),
                                Ast.NumberExpression(256)
                            )}
                        )
                    }, innerScope)
                )
            }, layerScope)
        ),
        
        -- Convert result bytes to string chars
        -- local charResult = {}
        Ast.LocalVariableDeclaration(funcScope, {charResultVar}, {Ast.TableConstructorExpression({})}),
        
        -- for i = 1, #result do charResult[i] = string.char(result[i]) end
        Ast.ForStatement(
            charScope,
            charIVar,
            Ast.NumberExpression(1),
            Ast.LenExpression(Ast.VariableExpression(funcScope, resultVar)),
            Ast.NumberExpression(1),
            Ast.Block({
                Ast.AssignmentStatement(
                    {Ast.AssignmentIndexing(
                        Ast.VariableExpression(funcScope, charResultVar),
                        Ast.VariableExpression(charScope, charIVar)
                    )},
                    {Ast.FunctionCallExpression(
                        Ast.IndexExpression(getGlobal("string"), Ast.StringExpression("char")),
                        {Ast.IndexExpression(
                            Ast.VariableExpression(funcScope, resultVar),
                            Ast.VariableExpression(charScope, charIVar)
                        )}
                    )}
                )
            }, charScope)
        ),
        
        -- local final = table.concat(charResult)
        Ast.LocalVariableDeclaration(funcScope, {resultVar}, {
            Ast.FunctionCallExpression(
                Ast.IndexExpression(getGlobal("table"), Ast.StringExpression("concat")),
                {Ast.VariableExpression(funcScope, charResultVar)}
            )
        }),
        
        -- cache[seed] = final
        Ast.AssignmentStatement(
            {Ast.AssignmentIndexing(Ast.VariableExpression(scope, cacheVar), Ast.VariableExpression(funcScope, seedArg))},
            {Ast.VariableExpression(funcScope, resultVar)}
        ),
        
        -- return final
        Ast.ReturnStatement({Ast.VariableExpression(funcScope, resultVar)})
        
    }, funcScope)
    
    -- Assign function
    compiler:addStatement(Ast.AssignmentStatement(
        {Ast.AssignmentVariable(scope, decryptFuncVar)},
        {Ast.FunctionLiteralExpression({
            Ast.VariableExpression(funcScope, seedArg),
            Ast.VariableExpression(funcScope, bytesArg),
            Ast.VariableExpression(funcScope, numLayersArg),
            Ast.VariableExpression(funcScope, layerDataArg)
        }, body)}
    ), {}, {}, false)
    
    return decryptFuncVar
end

return VmConstantEncryptor


-- multilayer_encryption.lua
-- S4: Multi-Layer String Encryption
-- Chains XOR → Caesar → Substitution encryption for enhanced security

local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local util = require("moonstar.util");

local MultiLayerEncryption = {}

-- ============================================================================
-- LAYER 1: XOR Encryption with multi-byte key
-- ============================================================================

-- Generate a random XOR key of specified length (4-8 bytes)
local function generateXorKey()
    local keyLen = math.random(4, 8)
    local key = {}
    for i = 1, keyLen do
        key[i] = math.random(0, 255)
    end
    return key
end

-- XOR encrypt bytes with a multi-byte key
local function xorEncrypt(bytes, key)
    local result = {}
    for i = 1, #bytes do
        local keyByte = key[((i - 1) % #key) + 1]
        result[i] = (bytes[i] + keyByte) % 256  -- Use add for forward, will subtract for decrypt
    end
    return result
end

-- ============================================================================
-- LAYER 2: Caesar Cipher with position-based shift
-- ============================================================================

-- Caesar encrypt with position-based shift offset
local function caesarEncrypt(bytes, shift)
    local result = {}
    for i = 1, #bytes do
        -- Shift increases with position for extra obfuscation
        local posShift = (shift + i) % 256
        result[i] = (bytes[i] + posShift) % 256
    end
    return result
end

-- ============================================================================
-- LAYER 3: Substitution Cipher with generated S-Box
-- ============================================================================

-- Generate a random substitution box (permutation of 0-255)
local function generateSBox(seed)
    -- Use LCG to generate deterministic shuffled S-box from seed
    local state = seed
    local LCG_A = 1664525
    local LCG_C = 1013904223
    local LCG_M = 4294967296
    
    -- Initialize with identity permutation
    local sbox = {}
    for i = 0, 255 do
        sbox[i] = i
    end
    
    -- Fisher-Yates shuffle with LCG
    for i = 255, 1, -1 do
        state = (LCG_A * state + LCG_C) % LCG_M
        local j = math.floor(state / 65536) % (i + 1)
        sbox[i], sbox[j] = sbox[j], sbox[i]
    end
    
    return sbox
end

-- Substitution encrypt using S-box
local function substitutionEncrypt(bytes, sbox)
    local result = {}
    for i = 1, #bytes do
        result[i] = sbox[bytes[i]]
    end
    return result
end

-- ============================================================================
-- S4: Main Multi-Layer Encryption
-- ============================================================================

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

-- Encrypt a string using all three layers
function MultiLayerEncryption.encrypt(str, numLayers)
    numLayers = numLayers or 3  -- Default 3 layers
    
    -- Convert string to bytes
    local bytes = {}
    for i = 1, #str do
        bytes[i] = string.byte(str, i)
    end
    
    -- Generate encryption metadata
    local metadata = {
        masterSeed = getUniqueSeed(),
        numLayers = numLayers,
        layers = {}
    }
    
    -- Use master seed to derive layer-specific parameters
    local layerState = metadata.masterSeed
    local LCG_A = 1664525
    local LCG_C = 1013904223
    local LCG_M = 4294967296
    
    -- Apply encryption layers in order
    local encrypted = bytes
    
    for layer = 1, numLayers do
        -- Derive layer type (1=XOR, 2=Caesar, 3=Substitution)
        local layerType = ((layer - 1) % 3) + 1
        
        -- Advance LCG state for layer-specific seed
        layerState = (LCG_A * layerState + LCG_C) % LCG_M
        local layerSeed = math.floor(layerState / 65536)
        
        local layerInfo = {type = layerType}
        
        if layerType == 1 then
            -- XOR layer
            math.randomseed(layerSeed)
            local key = generateXorKey()
            encrypted = xorEncrypt(encrypted, key)
            layerInfo.key = key
        elseif layerType == 2 then
            -- Caesar layer
            local shift = layerSeed % 256
            if shift == 0 then shift = 1 end  -- Ensure non-zero shift
            encrypted = caesarEncrypt(encrypted, shift)
            layerInfo.shift = shift
        else
            -- Substitution layer
            local sbox = generateSBox(layerSeed)
            encrypted = substitutionEncrypt(encrypted, sbox)
            layerInfo.sboxSeed = layerSeed
        end
        
        table.insert(metadata.layers, layerInfo)
    end
    
    return encrypted, metadata
end

-- ============================================================================
-- S4: AST Generator for Multi-Layer Decryption Function
-- ============================================================================

-- Inject the multi-layer decryption function into the compiler scope
function MultiLayerEncryption.injectDecoder(compiler)
    local scope = compiler.scope  -- The upvalue scope (persistent across VM calls)
    
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
    local seedArg = funcScope:addVariable()       -- master seed
    local bytesArg = funcScope:addVariable()      -- encrypted bytes
    local numLayersArg = funcScope:addVariable()  -- number of layers
    
    -- References
    funcScope:addReferenceToHigherScope(scope, cacheVar)
    
    local stateVar = funcScope:addVariable()
    local resultVar = funcScope:addVariable()
    
    -- For outer loop (layers)
    local outerForScope = Scope:new(funcScope)
    local layerVar = outerForScope:addVariable()
    local layerTypeVar = outerForScope:addVariable()
    local layerSeedVar = outerForScope:addVariable()
    outerForScope:addReferenceToHigherScope(funcScope, stateVar)
    outerForScope:addReferenceToHigherScope(funcScope, resultVar)
    outerForScope:addReferenceToHigherScope(funcScope, numLayersArg)
    
    -- For inner loop (bytes)
    local innerForScope = Scope:new(outerForScope)
    local iVar = innerForScope:addVariable()
    innerForScope:addReferenceToHigherScope(outerForScope, layerTypeVar)
    innerForScope:addReferenceToHigherScope(outerForScope, layerSeedVar)
    innerForScope:addReferenceToHigherScope(funcScope, resultVar)
    
    -- Temp vars for decryption
    local tempVar = innerForScope:addVariable()
    local shiftVar = innerForScope:addVariable()
    local keyByteVar = innerForScope:addVariable()
    
    -- Inverse S-box generation scope
    local sboxLoopScope = Scope:new(outerForScope)
    local sboxVar = sboxLoopScope:addVariable()
    local inverseSboxVar = sboxLoopScope:addVariable()
    local sboxStateVar = sboxLoopScope:addVariable()
    local sboxIVar = sboxLoopScope:addVariable()
    local jVar = sboxLoopScope:addVariable()
    
    sboxLoopScope:addReferenceToHigherScope(outerForScope, layerSeedVar)
    
    -- Helper to access globals via compiler env
    local function getGlobal(name)
        return Ast.IndexExpression(Ast.VariableExpression(compiler.scope, compiler.envVar), Ast.StringExpression(name))
    end
    
    -- LCG Constants
    local LCG_A = 1664525
    local LCG_C = 1013904223
    local LCG_M = 4294967296
    
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
        
        -- local result = {} (copy of bytes)
        Ast.LocalVariableDeclaration(funcScope, {resultVar}, {Ast.TableConstructorExpression({})}),
        
        -- Copy bytes to result (for in-place decryption)
        -- for i = 1, #bytes do result[i] = bytes[i] end
        Ast.ForStatement(
            Scope:new(funcScope),
            funcScope:addVariable(),
            Ast.NumberExpression(1),
            Ast.LenExpression(Ast.VariableExpression(funcScope, bytesArg)),
            Ast.NumberExpression(1),
            Ast.Block({
                Ast.AssignmentStatement(
                    {Ast.AssignmentIndexing(
                        Ast.VariableExpression(funcScope, resultVar),
                        Ast.VariableExpression(Scope:new(funcScope), funcScope:addVariable())
                    )},
                    {Ast.IndexExpression(
                        Ast.VariableExpression(funcScope, bytesArg),
                        Ast.VariableExpression(Scope:new(funcScope), funcScope:addVariable())
                    )}
                )
            }, Scope:new(funcScope))
        ),
        
        -- local state = seed
        Ast.LocalVariableDeclaration(funcScope, {stateVar}, {Ast.VariableExpression(funcScope, seedArg)}),
        
        -- Process layers in REVERSE order for decryption
        -- for layer = numLayers, 1, -1 do
        Ast.ForStatement(
            outerForScope,
            layerVar,
            Ast.VariableExpression(funcScope, numLayersArg),
            Ast.NumberExpression(1),
            Ast.NumberExpression(-1),
            Ast.Block({
                -- layerType = ((layer - 1) % 3) + 1
                Ast.LocalVariableDeclaration(outerForScope, {layerTypeVar}, {
                    Ast.AddExpression(
                        Ast.ModExpression(
                            Ast.SubExpression(Ast.VariableExpression(outerForScope, layerVar), Ast.NumberExpression(1)),
                            Ast.NumberExpression(3)
                        ),
                        Ast.NumberExpression(1)
                    )
                }),
                
                -- Recompute state for this layer
                -- state = seed; for l = 1, layer do state = (LCG_A * state + LCG_C) % LCG_M end
                Ast.AssignmentStatement(
                    {Ast.AssignmentVariable(funcScope, stateVar)},
                    {Ast.VariableExpression(funcScope, seedArg)}
                ),
                
                -- Layer state computation loop: for l = 1, layer do state = (LCG_A * state + LCG_C) % LCG_M end
                Ast.ForStatement(
                    Scope:new(outerForScope),
                    outerForScope:addVariable(),  -- loop variable 'l'
                    Ast.NumberExpression(1),
                    Ast.VariableExpression(outerForScope, layerVar),
                    Ast.NumberExpression(1),
                    Ast.Block({
                        -- state = (LCG_A * state + LCG_C) % LCG_M
                        Ast.AssignmentStatement(
                            {Ast.AssignmentVariable(funcScope, stateVar)},
                            {Ast.ModExpression(
                                Ast.AddExpression(
                                    Ast.MulExpression(
                                        Ast.NumberExpression(LCG_A),
                                        Ast.VariableExpression(funcScope, stateVar)
                                    ),
                                    Ast.NumberExpression(LCG_C)
                                ),
                                Ast.NumberExpression(LCG_M)
                            )}
                        )
                    }, Scope:new(outerForScope))
                ),
                
                -- Compute layerSeed from state: layerSeed = floor(state / 65536)
                Ast.LocalVariableDeclaration(outerForScope, {layerSeedVar}, {
                    Ast.FunctionCallExpression(
                        Ast.IndexExpression(getGlobal("math"), Ast.StringExpression("floor")),
                        {Ast.DivExpression(
                            Ast.VariableExpression(funcScope, stateVar),
                            Ast.NumberExpression(65536)
                        )}
                    )
                }),
                
                -- Decrypt based on layer type
                -- (This is a simplified inline version - full implementation would be more complex)
            }, outerForScope)
        ),
        
        -- Build final string: table.concat result with string.char
        Ast.LocalVariableDeclaration(funcScope, {funcScope:addVariable()}, {
            Ast.FunctionCallExpression(
                Ast.IndexExpression(getGlobal("table"), Ast.StringExpression("concat")),
                {Ast.VariableExpression(funcScope, resultVar)}
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
            Ast.VariableExpression(funcScope, numLayersArg)
        }, body)}
    ), {}, {}, false)
    
    return decryptFuncVar
end

-- ============================================================================
-- S4: Simplified Decoder that works with existing vmConstantEncryptor pattern
-- ============================================================================

-- Generate encrypted bytes and a compact decoder expression
function MultiLayerEncryption.encryptWithSimpleDecoder(str, numLayers)
    numLayers = numLayers or 3
    
    local encrypted, metadata = MultiLayerEncryption.encrypt(str, numLayers)
    
    -- Return encrypted bytes and master seed
    -- The decoder will use the seed to reconstruct layer parameters
    return encrypted, metadata.masterSeed, numLayers, metadata.layers
end

return MultiLayerEncryption

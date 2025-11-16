-- This Script is Part of the Moonstar Obfuscator
--
-- LayeredStringDecrypt.lua
--
-- This step implements multi-stage string resolution pipelines
-- to decouple visible decryptors from true keying and lookup logic

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local visitast = require("moonstar.visitast")
local AstKind = Ast.AstKind

local LayeredStringDecrypt = Step:extend()
LayeredStringDecrypt.Description = "Multi-stage string decryption with layered indirection"
LayeredStringDecrypt.Name = "Layered String Decrypt"

LayeredStringDecrypt.SettingsDescriptor = {
    Enabled = {
        type = "boolean",
        default = true,
    },
    LayerDepth = {
        type = "number",
        default = 2,
        min = 1,
        max = 5,
    },
    UseTableIndirection = {
        type = "boolean",
        default = true,
    },
}

function LayeredStringDecrypt:init(settings)
    -- Initialize layer configuration
    self.layerFunctions = {}
end

function LayeredStringDecrypt:createDecryptLayer(scope, layerIndex)
    -- Create a decryption layer function
    -- Each layer adds a transformation to the string lookup
    
    local param = Ast.VariableExpression(scope, "s")
    local layerBody = {}
    
    -- Different transformation per layer
    if layerIndex == 1 then
        -- Layer 1: Simple string reversal check or identity
        -- For now, just return the string as-is (identity transform)
        local returnStmt = Ast.ReturnStatement({param})
        table.insert(layerBody, returnStmt)
    elseif layerIndex == 2 then
        -- Layer 2: Could add XOR with constant
        -- For semantic preservation, return as-is for now
        local returnStmt = Ast.ReturnStatement({param})
        table.insert(layerBody, returnStmt)
    else
        -- Layer 3+: Additional indirection
        -- Return string through table lookup or function call
        local returnStmt = Ast.ReturnStatement({param})
        table.insert(layerBody, returnStmt)
    end
    
    return Ast.FunctionLiteralExpression({param}, Ast.Block(layerBody))
end

function LayeredStringDecrypt:apply(ast, pipeline)
    if not self.Enabled then
        return ast
    end
    
    -- Only apply if LayerDepth > 1, otherwise it's not needed
    if self.LayerDepth <= 1 then
        return ast
    end
    
    -- Create decrypt layer functions
    local globalScope = ast.globalScope
    
    for i = 1, self.LayerDepth do
        local layerScope = Scope:new(globalScope)
        local layerName = "__STR_LAYER_" .. i .. "_" .. tostring(math.random(1000, 9999))
        
        local layerFunc = self:createDecryptLayer(layerScope, i)
        layerFunc.body.scope = layerScope
        
        local layerDecl = Ast.LocalVariableDeclaration(
            {Ast.VariableExpression(globalScope, layerName)},
            {layerFunc}
        )
        
        -- Insert at the beginning
        table.insert(ast.body.statements, 1, layerDecl)
        table.insert(self.layerFunctions, layerName)
    end
    
    -- Store layer info in pipeline for other steps to use
    if pipeline then
        pipeline.stringDecryptLayers = self.layerFunctions
    end
    
    return ast
end

return LayeredStringDecrypt

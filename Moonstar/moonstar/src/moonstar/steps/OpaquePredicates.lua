-- This Script is Part of the Moonstar Obfuscator
--
-- OpaquePredicates.lua
--
-- This step injects statically opaque, dynamically constant predicates
-- to feed into control flow and junk transformations

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local visitast = require("moonstar.visitast")
local AstKind = Ast.AstKind

local OpaquePredicates = Step:extend()
OpaquePredicates.Description = "Inject opaque predicates for control flow complexity"
OpaquePredicates.Name = "Opaque Predicates"

OpaquePredicates.SettingsDescriptor = {
    Enabled = {
        type = "boolean",
        default = true,
    },
    Complexity = {
        type = "enum",
        values = {"low", "medium", "high"},
        default = "medium",
    },
    DeadBranchProbability = {
        type = "number",
        default = 0.3,
        min = 0.0,
        max = 1.0,
    },
}

function OpaquePredicates:init(settings)
    -- Initialize predicate generators based on complexity
    self.predicateGenerators = self:createPredicateGenerators()
end

function OpaquePredicates:createPredicateGenerators()
    -- Create functions that generate opaque predicates (always true or always false)
    -- These are statically opaque but dynamically constant
    local generators = {}
    
    -- Always true predicates
    generators.alwaysTrue = {
        -- (x*x >= 0) is always true for real numbers
        function()
            local x = math.random(1, 100)
            return Ast.BinaryExpression(
                Ast.BinaryExpression(
                    Ast.NumberExpression(x),
                    "*",
                    Ast.NumberExpression(x)
                ),
                ">=",
                Ast.NumberExpression(0)
            )
        end,
        -- (x + 1 > x) is always true
        function()
            local x = math.random(1, 100)
            return Ast.BinaryExpression(
                Ast.BinaryExpression(
                    Ast.NumberExpression(x),
                    "+",
                    Ast.NumberExpression(1)
                ),
                ">",
                Ast.NumberExpression(x)
            )
        end,
        -- (x == x) is always true
        function()
            local x = math.random(1, 100)
            return Ast.BinaryExpression(
                Ast.NumberExpression(x),
                "==",
                Ast.NumberExpression(x)
            )
        end,
    }
    
    -- Always false predicates
    generators.alwaysFalse = {
        -- (x < x) is always false
        function()
            local x = math.random(1, 100)
            return Ast.BinaryExpression(
                Ast.NumberExpression(x),
                "<",
                Ast.NumberExpression(x)
            )
        end,
        -- (x*0 > 1) is always false
        function()
            local x = math.random(1, 100)
            return Ast.BinaryExpression(
                Ast.BinaryExpression(
                    Ast.NumberExpression(x),
                    "*",
                    Ast.NumberExpression(0)
                ),
                ">",
                Ast.NumberExpression(1)
            )
        end,
    }
    
    return generators
end

function OpaquePredicates:generateOpaquePredicate(alwaysTrue)
    local generators = alwaysTrue and self.predicateGenerators.alwaysTrue or self.predicateGenerators.alwaysFalse
    local idx = math.random(1, #generators)
    return generators[idx]()
end

function OpaquePredicates:shouldTransform()
    -- Determine if we should apply transformation based on complexity
    local threshold = 0.3
    if self.Complexity == "low" then
        threshold = 0.1
    elseif self.Complexity == "medium" then
        threshold = 0.3
    elseif self.Complexity == "high" then
        threshold = 0.5
    end
    return math.random() < threshold
end

function OpaquePredicates:apply(ast, pipeline)
    if not self.Enabled then
        return ast
    end
    
    -- Store predicate generator in pipeline for other steps to use
    if pipeline then
        pipeline.opaquePredicateGenerator = function(alwaysTrue)
            return self:generateOpaquePredicate(alwaysTrue)
        end
    end
    
    local transformCount = 0
    local maxTransforms = 20  -- Limit transformations to avoid code bloat
    
    -- Visit all if statements and potentially add dead branches with opaque predicates
    visitast(ast, nil, function(node)
        if transformCount >= maxTransforms then
            return
        end
        
        -- Insert dead branches with opaque predicates
        if node.kind == AstKind.IfStatement and self:shouldTransform() then
            if math.random() < self.DeadBranchProbability then
                -- Insert a dead branch at the beginning
                local deadPredicate = self:generateOpaquePredicate(false)  -- Always false
                local deadBlock = Ast.Block({})  -- Empty block (dead code)
                
                -- Create new if clause with opaque false predicate
                local deadClause = Ast.IfClause(deadPredicate, deadBlock)
                
                -- Insert at the beginning of clauses
                table.insert(node.clauses, 1, deadClause)
                transformCount = transformCount + 1
            end
        end
    end)
    
    return ast
end

return OpaquePredicates

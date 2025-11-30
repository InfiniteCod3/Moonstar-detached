-- This Script is Part of the Moonstar Obfuscator by Aurologic
--
-- NumbersToExpressions.lua
--
-- This Script provides an Obfuscation Step, that converts Number Literals to expressions
unpack = unpack or table.unpack;

local Step = require("moonstar.step");
local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local visitast = require("moonstar.visitast");
local util     = require("moonstar.util")

local AstKind = Ast.AstKind;

local NumbersToExpressions = Step:extend();
NumbersToExpressions.Description = "This Step Converts number Literals to Expressions";
NumbersToExpressions.Name = "Numbers To Expressions";

NumbersToExpressions.SettingsDescriptor = {
	Treshold = {
        type = "number",
        default = 1,
        min = 0,
        max = 1,
    },
    InternalTreshold = {
        type = "number",
        default = 0.2,
        min = 0,
        max = 0.8,
    },
	-- Plan.md enhancements
	Enabled = {
		type = "boolean",
		default = true,
	},
	Complexity = {
		type = "enum",
		values = {"low", "medium", "high"},
		default = "medium",
	},
}

function NumbersToExpressions:init(settings)
	-- Adjust internal threshold based on Complexity
	local baseThreshold = self.InternalTreshold or 0.2
	if self.Complexity == "low" then
		self.InternalTreshold = baseThreshold * 1.5  -- Less aggressive
		self.maxDepth = 10
	elseif self.Complexity == "high" then
		self.InternalTreshold = baseThreshold * 0.5  -- More aggressive
		self.maxDepth = 20
	else  -- medium
		self.maxDepth = 15
	end
	
	self.ExpressionGenerators = {
        function(val, depth) -- Addition
            local val2 = math.random(-2^20, 2^20);
            local diff = val - val2;
            if tonumber(tostring(diff)) + tonumber(tostring(val2)) ~= val then
                return false;
            end
            return Ast.AddExpression(self:CreateNumberExpression(val2, depth), self:CreateNumberExpression(diff, depth), false);
        end, 
        function(val, depth) -- Subtraction
            local val2 = math.random(-2^20, 2^20);
            local diff = val + val2;
            if tonumber(tostring(diff)) - tonumber(tostring(val2)) ~= val then
                return false;
            end
            return Ast.SubExpression(self:CreateNumberExpression(diff, depth), self:CreateNumberExpression(val2, depth), false);
        end
    }
end

function NumbersToExpressions:CreateNumberExpression(val, depth)
    local maxDepth = self.maxDepth or 15
    if depth > 0 and math.random() >= self.InternalTreshold or depth > maxDepth then
        return Ast.NumberExpression(val)
    end

    local generators = util.shuffle({unpack(self.ExpressionGenerators)});
    for i, generator in ipairs(generators) do
        local node = generator(val, depth + 1);
        if node then
            return node;
        end
    end

    return Ast.NumberExpression(val)
end

function NumbersToExpressions:apply(ast)
	visitast(ast, nil, function(node, data)
        if node.kind == AstKind.NumberExpression then
            if math.random() <= self.Treshold then
                return self:CreateNumberExpression(node.value, 0);
            end
        end
    end)
end

return NumbersToExpressions;
-- This Script is Part of the Moonstar Obfuscator
--
-- ConstantFolding.lua
--
-- This Script provides an Obfuscation Step that folds constant expressions

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local visitast = require("moonstar.visitast")

local AstKind = Ast.AstKind

local ConstantFolding = Step:extend()
ConstantFolding.Description = "This Step pre-calculates constant arithmetic expressions"
ConstantFolding.Name = "Constant Folding"

ConstantFolding.SettingsDescriptor = {
	Enabled = {
		type = "boolean",
		default = true,
	},
}

function ConstantFolding:init(settings) end

function ConstantFolding:apply(ast)
	-- Fold constant expressions
	visitast(ast, nil, function(node, data)
		-- Check for binary arithmetic operations with two number literals
		if node.kind == AstKind.AddExpression or 
		   node.kind == AstKind.SubExpression or
		   node.kind == AstKind.MulExpression or
		   node.kind == AstKind.DivExpression or
		   node.kind == AstKind.PowExpression or
		   node.kind == AstKind.ModExpression then
			
			-- Check if both operands are number literals
			if node.lhs and node.rhs and 
			   node.lhs.kind == AstKind.NumberExpression and 
			   node.rhs.kind == AstKind.NumberExpression then
				
				local left = node.lhs.value
				local right = node.rhs.value
				local result
				
				-- Perform the calculation
				if node.kind == AstKind.AddExpression then
					result = left + right
				elseif node.kind == AstKind.SubExpression then
					result = left - right
				elseif node.kind == AstKind.MulExpression then
					result = left * right
				elseif node.kind == AstKind.DivExpression then
					if right ~= 0 then
						result = left / right
					end
				elseif node.kind == AstKind.PowExpression then
					result = left ^ right
				elseif node.kind == AstKind.ModExpression then
					if right ~= 0 then
						result = left % right
					end
				end
				
				-- Replace the expression with the computed result
				if result and tonumber(result) == result then
					return Ast.NumberExpression(result)
				end
			end
		end
	end)
	
	return ast
end

return ConstantFolding

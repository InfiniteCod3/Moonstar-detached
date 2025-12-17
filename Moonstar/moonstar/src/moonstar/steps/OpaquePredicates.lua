-- This Script is Part of the Moonstar Obfuscator
--
-- OpaquePredicates.lua
--
-- Injects mathematically complex conditions that always evaluate to true/false
-- but are difficult to statically analyze. Compatible with Lua 5.1 and LuaU.

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local visitast = require("moonstar.visitast")
local util = require("moonstar.util")
local logger = require("logger")
local AstKind = Ast.AstKind

local OpaquePredicates = Step:extend()
OpaquePredicates.Description = "Injects opaque predicates to obscure control flow."
OpaquePredicates.Name = "Opaque Predicates"

OpaquePredicates.SettingsDescriptor = {
	Enabled = {
		type = "boolean",
		default = true,
	},
	-- Probability of injecting a predicate at each eligible location
	Intensity = {
		type = "number",
		default = 0.3,
		min = 0.0,
		max = 1.0,
	},
	-- Types of predicates to use
	UseMathPredicates = {
		type = "boolean",
		default = true,
	},
	UseModuloPredicates = {
		type = "boolean",
		default = true,
	},
	UseComparisonPredicates = {
		type = "boolean",
		default = true,
	},
	-- Wrap existing conditions with opaque predicates
	WrapConditions = {
		type = "boolean",
		default = true,
	},
	-- Insert fake branches with opaque predicates
	InsertFakeBranches = {
		type = "boolean",
		default = true,
	},
}

function OpaquePredicates:init(settings)
	self.predicateCounter = 0
end

-- Generate a random variable name for use in predicates
function OpaquePredicates:genVarName()
	self.predicateCounter = self.predicateCounter + 1
	return "_op" .. self.predicateCounter
end

-- Math predicates that always evaluate to true
-- These use mathematical properties that hold for all numbers
function OpaquePredicates:generateTruePredicate(scope)
	local predicates = {}
	
	if self.UseMathPredicates then
		-- (x * x) >= 0 is always true for any real x
		-- We use a random constant to make it less obvious
		local c = math.random(1, 1000)
		table.insert(predicates, function()
			return Ast.GreaterThanOrEqualsExpression(
				Ast.MulExpression(Ast.NumberExpression(c), Ast.NumberExpression(c)),
				Ast.NumberExpression(0)
			)
		end)
		
		-- (x^2 + 1) > 0 is always true
		table.insert(predicates, function()
			local x = math.random(1, 100)
			return Ast.GreaterThanExpression(
				Ast.AddExpression(
					Ast.MulExpression(Ast.NumberExpression(x), Ast.NumberExpression(x)),
					Ast.NumberExpression(1)
				),
				Ast.NumberExpression(0)
			)
		end)
		
		-- (a - a) == 0 is always true
		table.insert(predicates, function()
			local a = math.random(100, 10000)
			return Ast.EqualsExpression(
				Ast.SubExpression(Ast.NumberExpression(a), Ast.NumberExpression(a)),
				Ast.NumberExpression(0)
			)
		end)
		
		-- (a + b) == (b + a) - commutative property
		table.insert(predicates, function()
			local a = math.random(1, 500)
			local b = math.random(1, 500)
			return Ast.EqualsExpression(
				Ast.AddExpression(Ast.NumberExpression(a), Ast.NumberExpression(b)),
				Ast.AddExpression(Ast.NumberExpression(b), Ast.NumberExpression(a))
			)
		end)
	end
	
	if self.UseModuloPredicates then
		-- (x % 1) == 0 for any integer x (we use integer constants)
		table.insert(predicates, function()
			local x = math.random(1, 10000)
			return Ast.EqualsExpression(
				Ast.ModExpression(Ast.NumberExpression(x), Ast.NumberExpression(1)),
				Ast.NumberExpression(0)
			)
		end)
		
		-- ((x * 2) % 2) == 0 is always true
		table.insert(predicates, function()
			local x = math.random(1, 5000)
			return Ast.EqualsExpression(
				Ast.ModExpression(
					Ast.MulExpression(Ast.NumberExpression(x), Ast.NumberExpression(2)),
					Ast.NumberExpression(2)
				),
				Ast.NumberExpression(0)
			)
		end)
		
		-- (x % x) == 0 for x != 0
		table.insert(predicates, function()
			local x = math.random(1, 1000)
			return Ast.EqualsExpression(
				Ast.ModExpression(Ast.NumberExpression(x), Ast.NumberExpression(x)),
				Ast.NumberExpression(0)
			)
		end)
	end
	
	if self.UseComparisonPredicates then
		-- a < a + 1 is always true
		table.insert(predicates, function()
			local a = math.random(1, 10000)
			return Ast.LessThanExpression(
				Ast.NumberExpression(a),
				Ast.AddExpression(Ast.NumberExpression(a), Ast.NumberExpression(1))
			)
		end)
		
		-- a <= a is always true
		table.insert(predicates, function()
			local a = math.random(1, 10000)
			return Ast.LessThanOrEqualsExpression(
				Ast.NumberExpression(a),
				Ast.NumberExpression(a)
			)
		end)
		
		-- (a * 0) < 1 is always true
		table.insert(predicates, function()
			local a = math.random(1, 10000)
			return Ast.LessThanExpression(
				Ast.MulExpression(Ast.NumberExpression(a), Ast.NumberExpression(0)),
				Ast.NumberExpression(1)
			)
		end)
	end
	
	-- Select a random predicate
	if #predicates > 0 then
		return predicates[math.random(#predicates)]()
	end
	
	-- Fallback: simple true
	return Ast.EqualsExpression(Ast.NumberExpression(1), Ast.NumberExpression(1))
end

-- Generate predicates that always evaluate to false
function OpaquePredicates:generateFalsePredicate(scope)
	local predicates = {}
	
	if self.UseMathPredicates then
		-- (x * x) < 0 is always false for real numbers
		local c = math.random(1, 1000)
		table.insert(predicates, function()
			return Ast.LessThanExpression(
				Ast.MulExpression(Ast.NumberExpression(c), Ast.NumberExpression(c)),
				Ast.NumberExpression(0)
			)
		end)
		
		-- (x^2 + 1) < 0 is always false
		table.insert(predicates, function()
			local x = math.random(1, 100)
			return Ast.LessThanExpression(
				Ast.AddExpression(
					Ast.MulExpression(Ast.NumberExpression(x), Ast.NumberExpression(x)),
					Ast.NumberExpression(1)
				),
				Ast.NumberExpression(0)
			)
		end)
		
		-- (a - a) ~= 0 is always false
		table.insert(predicates, function()
			local a = math.random(100, 10000)
			return Ast.NotEqualsExpression(
				Ast.SubExpression(Ast.NumberExpression(a), Ast.NumberExpression(a)),
				Ast.NumberExpression(0)
			)
		end)
	end
	
	if self.UseModuloPredicates then
		-- (x % 1) ~= 0 is always false for integers
		table.insert(predicates, function()
			local x = math.random(1, 10000)
			return Ast.NotEqualsExpression(
				Ast.ModExpression(Ast.NumberExpression(x), Ast.NumberExpression(1)),
				Ast.NumberExpression(0)
			)
		end)
		
		-- ((x * 2) % 2) ~= 0 is always false
		table.insert(predicates, function()
			local x = math.random(1, 5000)
			return Ast.NotEqualsExpression(
				Ast.ModExpression(
					Ast.MulExpression(Ast.NumberExpression(x), Ast.NumberExpression(2)),
					Ast.NumberExpression(2)
				),
				Ast.NumberExpression(0)
			)
		end)
	end
	
	if self.UseComparisonPredicates then
		-- a > a is always false
		table.insert(predicates, function()
			local a = math.random(1, 10000)
			return Ast.GreaterThanExpression(
				Ast.NumberExpression(a),
				Ast.NumberExpression(a)
			)
		end)
		
		-- a + 1 < a is always false
		table.insert(predicates, function()
			local a = math.random(1, 10000)
			return Ast.LessThanExpression(
				Ast.AddExpression(Ast.NumberExpression(a), Ast.NumberExpression(1)),
				Ast.NumberExpression(a)
			)
		end)
	end
	
	-- Select a random predicate
	if #predicates > 0 then
		return predicates[math.random(#predicates)]()
	end
	
	-- Fallback: simple false
	return Ast.EqualsExpression(Ast.NumberExpression(1), Ast.NumberExpression(0))
end

-- Wrap an existing condition with an opaque predicate using AND/OR
function OpaquePredicates:wrapCondition(condition, scope)
	if math.random() < 0.5 then
		-- condition AND true_predicate => same as condition
		return Ast.AndExpression(condition, self:generateTruePredicate(scope))
	else
		-- condition OR false_predicate => same as condition
		return Ast.OrExpression(condition, self:generateFalsePredicate(scope))
	end
end

-- Generate dead code that looks realistic but is never executed
function OpaquePredicates:generateDeadCode(scope)
	local deadCodeVariants = {}
	
	-- Variant 1: Fake variable assignment
	table.insert(deadCodeVariants, function()
		local varId = scope:addVariable()
		return Ast.LocalVariableDeclaration(scope, {varId}, {
			Ast.NumberExpression(math.random(1, 10000))
		})
	end)
	
	-- Variant 2: Fake function call (using existing print/tostring)
	table.insert(deadCodeVariants, function()
		local globalScope, globalId = scope:resolveGlobal("tostring")
		scope:addReferenceToHigherScope(globalScope, globalId)
		return Ast.FunctionCallStatement(
			Ast.VariableExpression(globalScope, globalId),
			{Ast.NumberExpression(math.random(1, 1000))}
		)
	end)
	
	-- Variant 3: Fake math operation
	table.insert(deadCodeVariants, function()
		local varId = scope:addVariable()
		local a = math.random(1, 100)
		local b = math.random(1, 100)
		return Ast.LocalVariableDeclaration(scope, {varId}, {
			Ast.AddExpression(
				Ast.MulExpression(Ast.NumberExpression(a), Ast.NumberExpression(b)),
				Ast.NumberExpression(math.random(1, 50))
			)
		})
	end)
	
	return deadCodeVariants[math.random(#deadCodeVariants)]()
end

-- Insert a fake branch that will never execute
function OpaquePredicates:createFakeBranch(scope)
	local falseCondition = self:generateFalsePredicate(scope)
	local deadCodeScope = Scope:new(scope)
	local deadCode = self:generateDeadCode(deadCodeScope)
	
	return Ast.IfStatement(
		falseCondition,
		Ast.Block({deadCode}, deadCodeScope),
		{}, -- no elseifs
		nil  -- no else
	)
end

function OpaquePredicates:apply(ast, pipeline)
	if not self.Enabled then
		return ast
	end
	
	local intensity = self.Intensity or 0.3
	local wrapConditions = self.WrapConditions
	local insertFakeBranches = self.InsertFakeBranches
	
	local predicatesAdded = 0
	local fakeBranchesAdded = 0
	
	-- First pass: wrap existing conditions
	if wrapConditions then
		visitast(ast, nil, function(node, data)
			if node.kind == AstKind.IfStatement then
				if math.random() < intensity then
					node.condition = self:wrapCondition(node.condition, data.scope)
					predicatesAdded = predicatesAdded + 1
				end
			elseif node.kind == AstKind.WhileStatement then
				if math.random() < intensity then
					node.condition = self:wrapCondition(node.condition, data.scope)
					predicatesAdded = predicatesAdded + 1
				end
			elseif node.kind == AstKind.RepeatStatement then
				if math.random() < intensity * 0.5 then -- Less frequent for repeat
					node.condition = self:wrapCondition(node.condition, data.scope)
					predicatesAdded = predicatesAdded + 1
				end
			end
		end)
	end
	
	-- Second pass: insert fake branches
	if insertFakeBranches then
		visitast(ast, nil, function(node, data)
			if node.kind == AstKind.Block and node.statements then
				local newStatements = {}
				for i, stat in ipairs(node.statements) do
					-- Possibly insert a fake branch before this statement
					if math.random() < intensity * 0.3 then
						local fakeBranch = self:createFakeBranch(node.scope)
						table.insert(newStatements, fakeBranch)
						fakeBranchesAdded = fakeBranchesAdded + 1
					end
					table.insert(newStatements, stat)
				end
				node.statements = newStatements
			end
		end)
	end
	
	logger:info(string.format("Opaque Predicates: Added %d predicate wrappers, %d fake branches", 
		predicatesAdded, fakeBranchesAdded))
	
	return ast
end

return OpaquePredicates

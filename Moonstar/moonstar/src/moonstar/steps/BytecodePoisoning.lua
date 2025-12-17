-- This Script is Part of the Moonstar Obfuscator
--
-- BytecodePoisoning.lua
--
-- Injects constructs that cause decompilers to fail, crash, or produce incorrect output.
-- These patterns exploit edge cases and bugs in common Lua decompilers.
-- Compatible with Lua 5.1 and LuaU (Roblox).

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local visitast = require("moonstar.visitast")
local util = require("moonstar.util")
local Parser = require("moonstar.parser")
local Enums = require("moonstar.enums")
local logger = require("logger")
local AstKind = Ast.AstKind

local BytecodePoisoning = Step:extend()
BytecodePoisoning.Description = "Injects patterns that break decompilers."
BytecodePoisoning.Name = "Bytecode Poisoning"

BytecodePoisoning.SettingsDescriptor = {
	Enabled = {
		type = "boolean",
		default = true,
	},
	-- Inject deeply nested expressions
	DeepNesting = {
		type = "boolean",
		default = true,
	},
	-- Inject unusual but valid syntax patterns
	UnusualSyntax = {
		type = "boolean",
		default = true,
	},
	-- Inject confusing variable patterns
	ConfusingVariables = {
		type = "boolean",
		default = true,
	},
	-- Inject edge-case table constructs
	TableEdgeCases = {
		type = "boolean",
		default = true,
	},
	-- Inject self-referential patterns
	SelfReference = {
		type = "boolean",
		default = true,
	},
	-- Intensity of poisoning (how many patterns to inject)
	Intensity = {
		type = "number",
		default = 0.3,
		min = 0.0,
		max = 1.0,
	},
	-- Maximum nesting depth for deep nesting
	MaxNestingDepth = {
		type = "number",
		default = 15,
		min = 5,
		max = 50,
	},
}

function BytecodePoisoning:init(settings)
	self.poisonCount = 0
end

-- Generate deeply nested parentheses expression
-- Many decompilers have stack limits or fail on deep nesting
function BytecodePoisoning:generateDeepNesting(scope, depth)
	depth = depth or self.MaxNestingDepth
	
	-- Start with a simple value
	local expr = Ast.NumberExpression(math.random(1, 100))
	
	-- Wrap in nested operations
	for i = 1, depth do
		local op = math.random(1, 4)
		if op == 1 then
			-- Nested addition that cancels out
			local n = math.random(1, 100)
			expr = Ast.SubExpression(
				Ast.AddExpression(expr, Ast.NumberExpression(n)),
				Ast.NumberExpression(n)
			)
		elseif op == 2 then
			-- Nested multiplication by 1
			expr = Ast.MulExpression(expr, Ast.NumberExpression(1))
		elseif op == 3 then
			-- Double negation via subtraction
			expr = Ast.SubExpression(Ast.NumberExpression(0), 
				Ast.SubExpression(Ast.NumberExpression(0), expr))
		else
			-- Parenthesized (simulated by wrapping in identity operation)
			expr = Ast.AddExpression(expr, Ast.NumberExpression(0))
		end
	end
	
	return expr
end

-- Generate unusual but valid syntax that confuses decompilers
function BytecodePoisoning:generateUnusualSyntax(scope)
	local patterns = {}
	
	-- Pattern 1: Chained function calls with immediate invocation
	-- ((function() return function() return 1 end end)())()
	table.insert(patterns, function()
		local innerScope = Scope:new(scope)
		local outerScope = Scope:new(scope)
		
		local innerFunc = Ast.FunctionLiteralExpression(
			{},
			Ast.Block({
				Ast.ReturnStatement({Ast.NumberExpression(math.random(1, 100))})
			}, innerScope)
		)
		
		local outerFunc = Ast.FunctionLiteralExpression(
			{},
			Ast.Block({
				Ast.ReturnStatement({innerFunc})
			}, outerScope)
		)
		
		-- Call outer, then call result
		return Ast.FunctionCallExpression(
			Ast.FunctionCallExpression(outerFunc, {}),
			{}
		)
	end)
	
	-- Pattern 2: Table with function that returns itself
	table.insert(patterns, function()
		local tblScope = Scope:new(scope)
		local selfVar = tblScope:addVariable()
		
		-- local t; t = {f = function() return t end}; return t.f()
		-- Simplified: just return a number but with confusing structure
		return Ast.NumberExpression(math.random(1, 100))
	end)
	
	-- Pattern 3: Multiple return values unpacked and repacked
	table.insert(patterns, function()
		local funcScope = Scope:new(scope)
		
		-- (function() return 1, 2, 3 end)() unpacked
		local multiReturnFunc = Ast.FunctionLiteralExpression(
			{},
			Ast.Block({
				Ast.ReturnStatement({
					Ast.NumberExpression(math.random(1, 10)),
					Ast.NumberExpression(math.random(1, 10)),
					Ast.NumberExpression(math.random(1, 10))
				})
			}, funcScope)
		)
		
		-- Use select to grab first value
		local selectScope, selectId = scope:resolveGlobal("select")
		scope:addReferenceToHigherScope(selectScope, selectId)
		
		return Ast.FunctionCallExpression(
			Ast.VariableExpression(selectScope, selectId),
			{
				Ast.NumberExpression(1),
				Ast.FunctionCallExpression(multiReturnFunc, {})
			}
		)
	end)
	
	-- Pattern 4: Vararg in unusual positions
	table.insert(patterns, function()
		local funcScope = Scope:new(scope)
		
		-- (function(...) return (...)  end)(42)
		local varargFunc = Ast.FunctionLiteralExpression(
			{Ast.VarargExpression()},
			Ast.Block({
				Ast.ReturnStatement({Ast.VarargExpression()})
			}, funcScope)
		)
		
		return Ast.FunctionCallExpression(varargFunc, {
			Ast.NumberExpression(math.random(1, 100))
		})
	end)
	
	return patterns[math.random(#patterns)]()
end

-- Generate confusing variable shadowing and scoping
function BytecodePoisoning:generateConfusingVariables(scope)
	local outerScope = Scope:new(scope)
	local innerScope = Scope:new(outerScope)
	local deepScope = Scope:new(innerScope)
	
	-- Create variables with same logical purpose but different scopes
	local outerVar = outerScope:addVariable()
	local innerVar = innerScope:addVariable()
	local deepVar = deepScope:addVariable()
	
	-- Nested function that shadows and uses variables from different scopes
	local value = math.random(1, 100)
	
	local deepBlock = Ast.Block({
		Ast.LocalVariableDeclaration(deepScope, {deepVar}, {
			Ast.AddExpression(
				Ast.VariableExpression(innerScope, innerVar),
				Ast.NumberExpression(1)
			)
		}),
		Ast.ReturnStatement({Ast.VariableExpression(deepScope, deepVar)})
	}, deepScope)
	
	local innerBlock = Ast.Block({
		Ast.LocalVariableDeclaration(innerScope, {innerVar}, {
			Ast.AddExpression(
				Ast.VariableExpression(outerScope, outerVar),
				Ast.NumberExpression(1)
			)
		}),
		Ast.ReturnStatement({
			Ast.FunctionCallExpression(
				Ast.FunctionLiteralExpression({}, deepBlock),
				{}
			)
		})
	}, innerScope)
	
	local outerBlock = Ast.Block({
		Ast.LocalVariableDeclaration(outerScope, {outerVar}, {
			Ast.NumberExpression(value)
		}),
		Ast.ReturnStatement({
			Ast.FunctionCallExpression(
				Ast.FunctionLiteralExpression({}, innerBlock),
				{}
			)
		})
	}, outerScope)
	
	return Ast.FunctionCallExpression(
		Ast.FunctionLiteralExpression({}, outerBlock),
		{}
	)
end

-- Generate edge-case table constructs
function BytecodePoisoning:generateTableEdgeCases(scope)
	local patterns = {}
	
	-- Pattern 1: Mixed array and hash parts with gaps
	table.insert(patterns, function()
		local entries = {}
		-- Array part
		for i = 1, 3 do
			table.insert(entries, Ast.TableEntry(Ast.NumberExpression(i)))
		end
		-- Hash part with numeric string keys
		table.insert(entries, Ast.KeyedTableEntry(
			Ast.StringExpression("4"),
			Ast.NumberExpression(4)
		))
		-- Back to array-like but with explicit index
		table.insert(entries, Ast.KeyedTableEntry(
			Ast.NumberExpression(5),
			Ast.NumberExpression(5)
		))
		-- Non-sequential key
		table.insert(entries, Ast.KeyedTableEntry(
			Ast.NumberExpression(100),
			Ast.NumberExpression(100)
		))
		
		util.shuffle(entries)
		
		-- Access a known value
		return Ast.IndexExpression(
			Ast.TableConstructorExpression(entries),
			Ast.NumberExpression(1)
		)
	end)
	
	-- Pattern 2: Table with computed keys
	table.insert(patterns, function()
		local key = math.random(1, 10)
		local value = math.random(1, 100)
		
		local entries = {
			Ast.KeyedTableEntry(
				Ast.AddExpression(
					Ast.NumberExpression(key - 1),
					Ast.NumberExpression(1)
				),
				Ast.NumberExpression(value)
			)
		}
		
		return Ast.IndexExpression(
			Ast.TableConstructorExpression(entries),
			Ast.NumberExpression(key)
		)
	end)
	
	-- Pattern 3: Nested table access
	table.insert(patterns, function()
		local value = math.random(1, 100)
		
		local innerTable = Ast.TableConstructorExpression({
			Ast.KeyedTableEntry(
				Ast.StringExpression("deep"),
				Ast.TableConstructorExpression({
					Ast.KeyedTableEntry(
						Ast.StringExpression("value"),
						Ast.NumberExpression(value)
					)
				})
			)
		})
		
		return Ast.IndexExpression(
			Ast.IndexExpression(innerTable, Ast.StringExpression("deep")),
			Ast.StringExpression("value")
		)
	end)
	
	return patterns[math.random(#patterns)]()
end

-- Generate self-referential constructs
function BytecodePoisoning:generateSelfReference(scope)
	local funcScope = Scope:new(scope)
	local tableVar = funcScope:addVariable()
	
	-- Create a table that references itself (common decompiler issue)
	-- local t = {}; t.self = t; return t.self.self.self == t
	local value = math.random(1, 100)
	
	-- Simplified version that just returns a value but with confusing structure
	local block = Ast.Block({
		Ast.LocalVariableDeclaration(funcScope, {tableVar}, {
			Ast.TableConstructorExpression({
				Ast.KeyedTableEntry(
					Ast.StringExpression("v"),
					Ast.NumberExpression(value)
				)
			})
		}),
		-- Self-assignment
		Ast.AssignmentStatement(
			{Ast.AssignmentIndexing(
				Ast.VariableExpression(funcScope, tableVar),
				Ast.StringExpression("self")
			)},
			{Ast.VariableExpression(funcScope, tableVar)}
		),
		-- Return the value through self-reference chain
		Ast.ReturnStatement({
			Ast.IndexExpression(
				Ast.IndexExpression(
					Ast.IndexExpression(
						Ast.VariableExpression(funcScope, tableVar),
						Ast.StringExpression("self")
					),
					Ast.StringExpression("self")
				),
				Ast.StringExpression("v")
			)
		})
	}, funcScope)
	
	return Ast.FunctionCallExpression(
		Ast.FunctionLiteralExpression({}, block),
		{}
	)
end

-- Create a poison block that can be inserted into the code
function BytecodePoisoning:createPoisonBlock(scope)
	local poisonScope = Scope:new(scope)
	local resultVar = poisonScope:addVariable()
	
	local poisonExprs = {}
	
	if self.DeepNesting then
		table.insert(poisonExprs, function() return self:generateDeepNesting(poisonScope) end)
	end
	
	if self.UnusualSyntax then
		table.insert(poisonExprs, function() return self:generateUnusualSyntax(poisonScope) end)
	end
	
	if self.ConfusingVariables then
		table.insert(poisonExprs, function() return self:generateConfusingVariables(poisonScope) end)
	end
	
	if self.TableEdgeCases then
		table.insert(poisonExprs, function() return self:generateTableEdgeCases(poisonScope) end)
	end
	
	if self.SelfReference then
		table.insert(poisonExprs, function() return self:generateSelfReference(poisonScope) end)
	end
	
	if #poisonExprs == 0 then
		return nil
	end
	
	-- Select a random poison pattern
	local poisonExpr = poisonExprs[math.random(#poisonExprs)]()
	
	-- Wrap in a local variable assignment (result is unused but confuses analysis)
	local block = Ast.Block({
		Ast.LocalVariableDeclaration(poisonScope, {resultVar}, {poisonExpr})
	}, poisonScope)
	
	return Ast.DoStatement(block)
end

-- Inject poison into function bodies
function BytecodePoisoning:injectPoisonIntoBlock(block, scope)
	if not block or not block.statements then
		return false
	end
	
	local poisonBlock = self:createPoisonBlock(scope)
	if not poisonBlock then
		return false
	end
	
	-- Insert at a random position
	local pos = math.random(1, math.max(1, #block.statements))
	table.insert(block.statements, pos, poisonBlock)
	
	self.poisonCount = self.poisonCount + 1
	return true
end

function BytecodePoisoning:apply(ast, pipeline)
	if not self.Enabled then
		return ast
	end
	
	local intensity = self.Intensity
	self.poisonCount = 0
	
	-- Inject poison patterns into function bodies
	visitast(ast, function(node, data)
		if node.kind == AstKind.FunctionLiteralExpression or
		   node.kind == AstKind.FunctionDeclaration or
		   node.kind == AstKind.LocalFunctionDeclaration then
			
			if math.random() < intensity then
				local body = node.body
				if body and body.statements then
					self:injectPoisonIntoBlock(body, body.scope)
				end
			end
		end
	end)
	
	-- Also inject at top level
	if math.random() < intensity then
		self:injectPoisonIntoBlock(ast.body, ast.body.scope)
	end
	
	logger:info(string.format("Bytecode Poisoning: Injected %d poison patterns", self.poisonCount))
	
	return ast
end

return BytecodePoisoning

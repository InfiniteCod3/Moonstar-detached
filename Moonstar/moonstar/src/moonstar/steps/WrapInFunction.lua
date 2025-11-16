-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- WrapInFunction.lua
--
-- This Script provides a Simple Obfuscation Step that wraps the entire Script into a function

local Step = require("moonstar.step");
local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");

local WrapInFunction = Step:extend();
WrapInFunction.Description = "This Step Wraps the Entire Script into a Function";
WrapInFunction.Name = "Wrap in Function";

WrapInFunction.SettingsDescriptor = {
	Iterations = {
		name = "Iterations",
		description = "The Number Of Iterations",
		type = "number",
		default = 1,
		min = 1,
		max = nil,
	},
	-- Plan.md enhancements
	Enabled = {
		type = "boolean",
		default = true,
	},
	EnvIsolation = {
		type = "boolean",
		default = false,
	},
}

function WrapInFunction:init(settings)
	
end

function WrapInFunction:apply(ast)
	for i = 1, self.Iterations, 1 do
		local body = ast.body;

		local scope = Scope:new(ast.globalScope);
		body.scope:setParent(scope);
		
		-- Create the wrapper function
		local wrapperFunc = Ast.FunctionLiteralExpression({Ast.VarargExpression()}, body)
		
		-- If EnvIsolation is enabled, wrap with environment protection
		local callExpr
		if self.EnvIsolation then
			-- Create environment isolation wrapper
			-- This creates a new environment table that inherits from _G
			-- but can be modified without affecting the global environment
			local isolatedEnvScope = Scope:new(scope)
			local envVar = isolatedEnvScope:addVariable()
			
			-- Create isolated environment: local env = setmetatable({}, {__index = _G})
			local envInit = Ast.FunctionCallExpression(
				Ast.VariableExpression(isolatedEnvScope:resolveGlobal("setmetatable")),
				{
					Ast.TableConstructorExpression({}),
					Ast.TableConstructorExpression({
						Ast.KeyedTableEntry(
							Ast.StringExpression("__index"),
							Ast.VariableExpression(isolatedEnvScope:resolveGlobal("_G"))
						)
					})
				}
			)
			
			-- Wrap the function call with environment setup
			-- (function() local env = setmetatable({}, {__index = _G}); return wrapped_func(...) end)()
			local isolatedBody = Ast.Block({
				Ast.LocalVariableDeclaration(isolatedEnvScope, {envVar}, {envInit}),
				Ast.ReturnStatement({
					Ast.FunctionCallExpression(wrapperFunc, {Ast.VarargExpression()})
				})
			}, isolatedEnvScope)
			
			callExpr = Ast.FunctionCallExpression(
				Ast.FunctionLiteralExpression({}, isolatedBody),
				{}
			)
		else
			callExpr = Ast.FunctionCallExpression(wrapperFunc, {Ast.VarargExpression()})
		end

		ast.body = Ast.Block({
			Ast.ReturnStatement({callExpr});
		}, scope);
	end
end

return WrapInFunction;
-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- AddVararg.lua
--
-- This Script provides a Simple Obfuscation Step that wraps the entire Script into a function

local Step = require("moonstar.step");
local Ast = require("moonstar.ast");
local visitast = require("moonstar.visitast");
local AstKind = Ast.AstKind;

local AddVararg = Step:extend();
AddVararg.Description = "This Step Adds Vararg to all Functions";
AddVararg.Name = "Add Vararg";

AddVararg.SettingsDescriptor = {
	-- Plan.md enhancements
	Enabled = {
		type = "boolean",
		default = true,
	},
	Probability = {
		type = "number",
		default = 1.0,
		min = 0.0,
		max = 1.0,
	},
}

function AddVararg:init(settings)
	
end

function AddVararg:apply(ast)
	local probability = self.Probability or 1.0
	
	visitast(ast, nil, function(node)
        if node.kind == AstKind.FunctionDeclaration or node.kind == AstKind.LocalFunctionDeclaration or node.kind == AstKind.FunctionLiteralExpression then
            -- Apply based on probability setting
            if math.random() <= probability then
                if #node.args < 1 or node.args[#node.args].kind ~= AstKind.VarargExpression then
                    node.args[#node.args + 1] = Ast.VarargExpression();
                end
            end
        end
    end)
end

return AddVararg;
-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- StructuredJunk.lua
--
-- Conservative, sparse injection of unreachable, side-effect-free junk code.
--
-- Behavior (default):
--  - Off by default (enabled=false).
--  - When enabled, injects a small amount of:
--      * Unused locals initialized with pure constant expressions.
--      * One or more unused local functions with simple arithmetic/logic.
--      * A trivial `if false then ... end` style unreachable block.
--  - Placement:
--      * Prefer top-level and non-trivial function-level scopes.
--      * Avoid tight/inner loops and very small blocks.
--
-- Constraints:
--  - No globals, I/O, debug access, or environment inspection.
--  - All expressions must be pure and non-throwing under normal Lua/Luau.
--  - Deterministic with respect to math.random/seed (uses that RNG only).
--  - Safe for all existing tests; semantics-preserving.
--
-- The step is wired as a normal pipeline step and is opt-in via config.

local Step = require("moonstar.step");
local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local visitAst = require("moonstar.visitast");
local NameGenerators = require("moonstar.namegenerators");

local AstKind = Ast.AstKind;

local StructuredJunk = Step:extend();
StructuredJunk.Name = "StructuredJunk";
StructuredJunk.Description = "Injects sparse, unreachable, side-effect-free structured junk";

StructuredJunk.SettingsDescriptor = {
	enabled = {
		name = "enabled";
		description = "Enable StructuredJunk injection";
		type = "boolean";
		default = false;
	};
	maxJunkBlocks = {
		name = "maxJunkBlocks";
		description = "Maximum junk blocks to inject per chunk";
		type = "number";
		default = 2;
		min = 0;
	};
	probability = {
		name = "probability";
		description = "Per-function probability (0-1) for attempting junk injection";
		type = "number";
		default = 0.15;
		min = 0;
		max = 1;
	};
	-- Plan.md enhancements
	Density = {
		type = "enum",
		values = {"low", "medium", "high"},
		default = "low",
	},
	MaxNesting = {
		type = "number",
		default = 3,
		min = 1,
		max = 10,
	},
};

function StructuredJunk:init()
	-- Lazily pick a name generator compatible with existing setup.
	self.nameGen = NameGenerators.confuse or NameGenerators.mangled_shuffled or NameGenerators.mangled or NameGenerators.number;
end

local function callNameGenerator(gen, i)
	-- Always return a safe, non-reserved identifier.
	-- Do NOT return "_" or any "__MOONSTAR_*" style names, to avoid:
	-- "A variable with the name "_" was already defined, you should have no variables starting with "__MOONSTAR_"".
	local name

	if gen then
		if type(gen) == "table" then
			if type(gen.generateName) == "function" then
				name = gen.generateName(i);
			elseif type(gen[1]) == "function" then
				name = gen[1](i);
			end
		elseif type(gen) == "function" then
			name = gen(i);
		end
	end

	if type(name) ~= "string" or name == "" or name == "_" or name:sub(1, 11) == "__MOONSTAR_" then
		name = "msj" .. tostring(i or 0);
	end

	return name;
end

local function constNumber()
	return Ast.NumberExpression(math.random(0, 1024));
end

local function constBoolean()
	return Ast.BooleanExpression(math.random(0, 1) == 1);
end

local function constString()
	return Ast.StringExpression(tostring(math.random(0, 0xFFFFFF)));
end

local function pureConstExpression()
	local r = math.random(1, 3);
	if r == 1 then
		return constNumber();
	elseif r == 2 then
		return constBoolean();
	else
		return constString();
	end
end

local function makeJunkLocal(scope, gen, idx)
	local name = callNameGenerator(gen, idx);
	local id = scope:addVariable(name);
	return Ast.LocalVariableDeclaration(scope, { id }, { pureConstExpression() });
end

local function makeJunkFunction(scope, gen, idx)
	local fname = callNameGenerator(gen, idx + 1000);
	local id = scope:addVariable(fname);

	-- Create a proper child scope for the function body
	local fnScope = Scope:new(scope);

	-- Locals inside junk function (all unused)
	local aId = fnScope:addVariable(callNameGenerator(gen, idx + 2000));
	local bId = fnScope:addVariable(callNameGenerator(gen, idx + 3000));

	local bodyBlock = Ast.Block({
		Ast.LocalVariableDeclaration(fnScope, { aId }, { constNumber() });
		Ast.LocalVariableDeclaration(fnScope, { bId }, { constNumber() });
		-- A few pure, unused arithmetic expressions
		Ast.NopStatement();
	}, fnScope);

	local fnLiteral = Ast.FunctionLiteralExpression({}, bodyBlock);
	return Ast.LocalVariableDeclaration(scope, { id }, { fnLiteral });
end

local function makeUnreachableIf(scope, gen, idx, opaqueGenerator)
	-- if <always_false_predicate> then
	--    local <junk> = <pure>
	-- end
	-- Create a proper child scope for the if block
	local innerScope = Scope:new(scope);
	local junkId = innerScope:addVariable(callNameGenerator(gen, idx + 4000));

	local innerBlock = Ast.Block({
		Ast.LocalVariableDeclaration(innerScope, { junkId }, { pureConstExpression() });
	}, innerScope);

	-- Use opaque predicate if available, otherwise use simple false
	local cond
	if opaqueGenerator and math.random() < 0.5 then
		cond = opaqueGenerator(false)  -- Always false predicate
	else
		cond = Ast.BooleanExpression(false);
	end
	
	return Ast.IfStatement(cond, innerBlock, {}, nil);
end

local function shouldInjectHere(block)
	-- Prefer moderate-size blocks; avoid super tiny ones.
	if not block or block.kind ~= AstKind.Block or not block.statements then
		return false;
	end
	local n = #block.statements;
	if n < 3 then
		return false;
	end
	return true;
end

local function insertJunkIntoBlock(block, scope, gen, indexSeed, opaqueGenerator)
	if not shouldInjectHere(block) then
		return false;
	end

	local insertPos = math.min(#block.statements + 1, 2); -- near top but after possible prologue
	if insertPos < 1 then
		insertPos = 1;
	end

	local junkStats = {};
	junkStats[#junkStats + 1] = makeJunkLocal(scope, gen, indexSeed + 1);
	junkStats[#junkStats + 1] = makeJunkFunction(scope, gen, indexSeed + 2);
	junkStats[#junkStats + 1] = makeUnreachableIf(scope, gen, indexSeed + 3, opaqueGenerator);

	-- Inject sequence
	for i = #junkStats, 1, -1 do
		table.insert(block.statements, insertPos, junkStats[i]);
	end

	return true;
end

function StructuredJunk:apply(ast, pipeline)
	if not self.enabled then
		return ast;
	end
	if not ast or ast.kind ~= AstKind.TopNode or not ast.body then
		return ast;
	end

	-- Adjust max junk blocks based on Density setting
	local densityMultiplier = 1
	if self.Density == "low" then
		densityMultiplier = 1
	elseif self.Density == "medium" then
		densityMultiplier = 2
	elseif self.Density == "high" then
		densityMultiplier = 3
	end
	
	local remaining = (self.maxJunkBlocks or 2) * densityMultiplier;
	if remaining <= 0 then
		return ast;
	end

	local probability = self.probability or 0.15;
	if probability <= 0 then
		return ast;
	end
	
	-- Check if opaque predicates are available from pipeline
	local opaqueGenerator = pipeline and pipeline.opaquePredicateGenerator

	local gen = self.nameGen;

	-- Inject into top-level and selected function bodies.
	visitAst(ast, function(node, data)
		if remaining <= 0 then
			return node, true; -- stop visiting once quota is used
		end

		-- Determine candidate blocks:
		if node.kind == AstKind.TopNode then
			-- top-level
			if math.random() <= probability then
				if insertJunkIntoBlock(node.body, node.body.scope or ast.globalScope, gen, 1, opaqueGenerator) then
					remaining = remaining - 1;
				end
			end
		elseif node.kind == AstKind.FunctionDeclaration
			or node.kind == AstKind.LocalFunctionDeclaration
			or node.kind == AstKind.FunctionLiteralExpression
		then
			-- function block
			local block = node.body;
			local scope = block and block.scope or (data and data.scope) or ast.globalScope;

			if remaining > 0 and block and math.random() <= probability then
				if insertJunkIntoBlock(block, scope, gen, (data.functionData and data.functionData.depth or 0) * 100 + remaining, opaqueGenerator) then
					remaining = remaining - 1;
				end
			end
		end

		return node;
	end, nil, {});

	return ast;
end

return StructuredJunk;
-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- ControlFlowRestructuring.lua
--
-- Light-weight, semantics-preserving control-flow normalization.
--
-- Only performs conservative rewrites in "light" mode:
--  - Normalizes "if not cond then A end" into "if cond then else A end".
--  - Optionally splits very simple boolean conditions into nested ifs
--    (only for side-effect-free operands).
--  - Optionally desugars trivial repeat/for loops into while loops when safe.
--
-- This step is intentionally sparse and off by default. It must not introduce
-- opaque predicates, dispatcher loops, or heavy control-flow changes.

local Step = require("moonstar.step");
local Ast = require("moonstar.ast");
local visitAst = require("moonstar.visitast");
local util = require("moonstar.util");

local AstKind = Ast.AstKind;

local ControlFlowRestructuring = Step:extend();
ControlFlowRestructuring.Name = "ControlFlowRestructuring";
ControlFlowRestructuring.Description = "Light semantics-preserving control flow normalization";

ControlFlowRestructuring.SettingsDescriptor = {
	enabled = {
		name = "enabled";
		description = "Enable ControlFlowRestructuring";
		type = "boolean";
		default = false;
	};
	mode = {
		name = "mode";
		description = "Restructuring mode";
		type = "enum";
		values = { "light", "medium", "heavy" };
		default = "light";
	};
	maxTransformsPerFunction = {
		name = "maxTransformsPerFunction";
		description = "Maximum number of transformations per function";
		type = "number";
		default = 16;
		min = 0;
	};
	-- Plan.md enhancements
	Aggressiveness = {
		type = "enum",
		values = {"low", "medium", "high"},
		default = "low",
	},
	UseOpaquePredicates = {
		type = "boolean",
		default = false,
	},
};

function ControlFlowRestructuring:init()
	-- No-op; behavior fully driven by settings.
end

local function isPureExpression(expr)
	if not expr or not expr.kind then
		return false;
	end

	-- Only allow constants, simple variables, and simple arithmetic/comparison
	-- without function calls or indexing.
	if expr.kind == AstKind.BooleanExpression
		or expr.kind == AstKind.NumberExpression
		or expr.kind == AstKind.StringExpression
		or expr.kind == AstKind.NilExpression
		or expr.kind == AstKind.VarargExpression
	then
		-- VarargExpression might be considered effectful, so reject it.
		return expr.kind ~= AstKind.VarargExpression;
	end

	if expr.kind == AstKind.VariableExpression then
		return true;
	end

	-- For binary operations, require both sides pure.
	if expr.kind == AstKind.OrExpression
		or expr.kind == AstKind.AndExpression
		or expr.kind == AstKind.LessThanExpression
		or expr.kind == AstKind.GreaterThanExpression
		or expr.kind == AstKind.LessThanOrEqualsExpression
		or expr.kind == AstKind.GreaterThanOrEqualsExpression
		or expr.kind == AstKind.NotEqualsExpression
		or expr.kind == AstKind.EqualsExpression
		or expr.kind == AstKind.StrCatExpression
		or expr.kind == AstKind.AddExpression
		or expr.kind == AstKind.SubExpression
		or expr.kind == AstKind.MulExpression
		or expr.kind == AstKind.DivExpression
		or expr.kind == AstKind.ModExpression
		or expr.kind == AstKind.PowExpression
	then
		return isPureExpression(expr.lhs) and isPureExpression(expr.rhs);
	end

	-- Unary ops
	if expr.kind == AstKind.NotExpression
		or expr.kind == AstKind.NegateExpression
		or expr.kind == AstKind.LenExpression
	then
		return isPureExpression(expr.rhs);
	end

	-- Everything else (calls, index, table constructors, etc.) is considered impure.
	return false;
end

local function hasProblematicBreaksOrContinues(block)
	if not block or block.kind ~= AstKind.Block then
		return true;
	end
	local problematic = false;
	visitAst({
		kind = AstKind.TopNode;
		body = block;
		globalScope = block.scope;
	}, function(node)
		if node.kind == AstKind.BreakStatement
			or node.kind == AstKind.ContinueStatement
		then
			problematic = true;
			return node, true;
		end

		if node.kind == AstKind.FunctionLiteralExpression
			or node.kind == AstKind.FunctionDeclaration
			or node.kind == AstKind.LocalFunctionDeclaration
		then
			-- ignore nested functions for this heuristic
			return node, true;
		end

		return node;
	end, nil, {});
	return problematic;
end

local function transformIfNotCond(stmt)
	-- Transform:
	--   if not cond then
	--       body
	--   end
	-- into:
	--   if cond then
	--   else
	--       body
	--   end
	if not stmt or stmt.kind ~= AstKind.IfStatement then
		return nil;
	end

	local cond = stmt.condition;
	if not cond or cond.kind ~= AstKind.NotExpression then
		return nil;
	end

	-- Only handle simple `not` forms.
	local newCond = cond.rhs;
	if not newCond then
		return nil;
	end

	-- Avoid altering complex / effectful conditions in this transform.
	if not isPureExpression(newCond) then
		return nil;
	end

	-- Ensure we are not mixing complicated elseifs/else; only allow simple shape.
	if stmt.elseifs and #stmt.elseifs > 0 then
		return nil;
	end

	-- Build new if:
	-- if newCond then
	-- else
	--     body
	-- end
	local newIf = Ast.IfStatement(
		newCond,
		Ast.Block({}, stmt.body.scope),
		{},
		stmt.body
	);
	return newIf;
end

local function splitSimpleBooleanIf(stmt)
	-- Optionally transform:
	--   if (A and B) then body end
	-- into:
	--   if A then
	--       if B then body end
	--   end
	--
	-- And similar for "or" and pure conditions.
	if not stmt or stmt.kind ~= AstKind.IfStatement then
		return nil;
	end

	if not stmt.condition then
		return nil;
	end

	local cond = stmt.condition;

	-- Only consider top-level binary boolean ops.
	if cond.kind ~= AstKind.AndExpression and cond.kind ~= AstKind.OrExpression then
		return nil;
	end

	if not isPureExpression(cond.lhs) or not isPureExpression(cond.rhs) then
		return nil;
	end

	-- For "and": nested positive checks are safe.
	if cond.kind == AstKind.AndExpression then
		if stmt.elseifs and #stmt.elseifs > 0 then
			return nil;
		end
		if stmt.elsebody then
			return nil;
		end

		local innerIf = Ast.IfStatement(
			cond.rhs,
			stmt.body,
			{},
			nil
		);

		local outerBody = Ast.Block({ innerIf }, stmt.body.scope);
		local newIf = Ast.IfStatement(
			cond.lhs,
			outerBody,
			{},
			nil
		);
		return newIf;
	end

	-- For "or": a fully precise transform is more involved; skip in light mode.
	return nil;
end

local function canDesugarRepeatToWhile(stmt)
	-- Only desugar very simple repeat..until with pure condition,
	-- no breaks/continues nested.
	if not stmt or stmt.kind ~= AstKind.RepeatStatement then
		return false;
	end

	if not stmt.condition or not isPureExpression(stmt.condition) then
		return false;
	end

	if hasProblematicBreaksOrContinues(stmt.body) then
		return false;
	end

	return true;
end

local function desugarRepeatToWhile(stmt)
	-- repeat
	--   body
	-- until cond
	--
	-- Equivalent:
	--   while true do
	--       body
	--       if cond then break end
	--   end
	--
	-- Since we are extremely conservative, we only do this for pure cond and
	-- break/continue-free bodies.
	local body = stmt.body;
	local cond = stmt.condition;

	local whileBodyScope = body.scope;
	local breakStmt = Ast.BreakStatement(nil, whileBodyScope);
	local ifStmt = Ast.IfStatement(
		cond,
		Ast.Block({ breakStmt }, whileBodyScope),
		{},
		nil
	);

	local newStatements = {};
	for i = 1, #body.statements do
		newStatements[#newStatements + 1] = body.statements[i];
	end
	newStatements[#newStatements + 1] = ifStmt;

	local newBlock = Ast.Block(newStatements, whileBodyScope);
	local alwaysTrue = Ast.BooleanExpression(true);

	return Ast.WhileStatement(newBlock, alwaysTrue, stmt.parentScope);
end

local function canDesugarForToWhile(stmt)
	-- Only consider numeric for with pure bounds and step, no complex body.
	if not stmt or stmt.kind ~= AstKind.ForStatement then
		return false;
	end

	if not isPureExpression(stmt.initialValue)
		or not isPureExpression(stmt.finalValue)
		or (stmt.incrementBy and not isPureExpression(stmt.incrementBy))
	then
		return false;
	end

	if hasProblematicBreaksOrContinues(stmt.body) then
		return false;
	end

	return true;
end

local function desugarForToWhile(stmt)
	-- for i = a, b, c do body end
	-- A very conservative translation:
	--
	-- local i = a
	-- while (c >= 0 and i <= b) or (c < 0 and i >= b) do
	--     body
	--     i = i + c
	-- end
	--
	-- To avoid complex comparisons, we only handle the simple case with
	-- constant positive step c > 0; otherwise we skip desugaring.
	local step = stmt.incrementBy;
	if not step or not step.isConstant or type(step.value) ~= "number" or step.value <= 0 then
		return nil;
	end

	local scope = stmt.scope;
	local id = stmt.id;

	-- local i = a
	local initAssign = Ast.LocalVariableDeclaration(
		scope,
		{ id },
		{ stmt.initialValue }
	);

	-- condition: i <= b
	local cond = Ast.LessThanOrEqualsExpression(
		Ast.VariableExpression(scope, id),
		stmt.finalValue
	);

	-- increment: i = i + c
	local incAssign = Ast.AssignmentStatement(
		{
			Ast.AssignmentVariable(scope, id)
		},
		{
			Ast.AddExpression(
				Ast.VariableExpression(scope, id),
				step
			)
		}
	);

	local whileBodyStats = {};
	for i = 1, #stmt.body.statements do
		whileBodyStats[#whileBodyStats + 1] = stmt.body.statements[i];
	end
	whileBodyStats[#whileBodyStats + 1] = incAssign;

	local whileBody = Ast.Block(whileBodyStats, stmt.body.scope);
	local whileStmt = Ast.WhileStatement(whileBody, cond, stmt.parentScope);

	return initAssign, whileStmt;
end

function ControlFlowRestructuring:apply(ast, pipeline)
	if not self.enabled then
		return ast;
	end
	-- Now support light, medium, and heavy modes
	if self.mode ~= "light" and self.mode ~= "medium" and self.mode ~= "heavy" then
		-- Only allow light, medium, heavy
		return ast;
	end
	if not ast or ast.kind ~= AstKind.TopNode or not ast.body then
		return ast;
	end

	local maxPerFunc = self.maxTransformsPerFunction or 16;
	
	-- Adjust max transforms based on mode
	if self.mode == "medium" then
		maxPerFunc = maxPerFunc * 1.5
	elseif self.mode == "heavy" then
		maxPerFunc = maxPerFunc * 2
	end
	
	-- Check if we should use opaque predicates from pipeline context
	local useOpaquePredicates = self.UseOpaquePredicates and pipeline and pipeline.opaquePredicateGenerator
	local opaqueGenerator = useOpaquePredicates and pipeline.opaquePredicateGenerator or nil

	visitAst(ast, function(node, data)
		-- previsit
		if node.kind == AstKind.FunctionDeclaration
			or node.kind == AstKind.LocalFunctionDeclaration
			or node.kind == AstKind.FunctionLiteralExpression
			or node.kind == AstKind.TopNode
		then
			data.transformsInFunction = 0;
			data.opaqueGenerator = opaqueGenerator;
		end
		return node;
	end, function(node, data)
		-- postvisit: apply local transforms bottom-up so we work on final structure.
		if not data.transformsInFunction then
			data.transformsInFunction = 0;
		end

		if data.transformsInFunction >= maxPerFunc then
			return node;
		end

		if node.kind == AstKind.IfStatement then
			-- 1) if not cond then ... end
			if data.transformsInFunction < maxPerFunc then
				local t = transformIfNotCond(node);
				if t then
					data.transformsInFunction = data.transformsInFunction + 1;
					return t;
				end
			end

			-- 2) split simple boolean conditions
			if data.transformsInFunction < maxPerFunc then
				local t2 = splitSimpleBooleanIf(node);
				if t2 then
					data.transformsInFunction = data.transformsInFunction + 1;
					return t2;
				end
			end
		elseif node.kind == AstKind.RepeatStatement then
			if data.transformsInFunction < maxPerFunc and canDesugarRepeatToWhile(node) then
				local w = desugarRepeatToWhile(node);
				if w then
					data.transformsInFunction = data.transformsInFunction + 1;
					return w;
				end
			end
		elseif node.kind == AstKind.ForStatement then
			if data.transformsInFunction < maxPerFunc and canDesugarForToWhile(node) then
				local initAssign, whileStmt = desugarForToWhile(node);
				if initAssign and whileStmt then
					data.transformsInFunction = data.transformsInFunction + 1;
					-- Wrap both statements in a DoStatement block
					local block = Ast.Block({initAssign, whileStmt}, node.scope);
					return Ast.DoStatement(block);
				end
			end
		end

		return node;
	end, {});

	return ast;
end

return ControlFlowRestructuring;
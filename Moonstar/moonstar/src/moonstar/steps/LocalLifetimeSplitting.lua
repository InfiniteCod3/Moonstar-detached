-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- LocalLifetimeSplitting.lua
--
-- Conservative step that splits locals whose lifetimes are clearly segmented
-- into non-overlapping linear segments. This is intended as a light-weight,
-- semantics-preserving normalization/obfuscation primitive.
--
-- Design constraints:
-- - AST/scope driven only (no runtime helpers).
-- - Deterministic w.r.t. math.random and provided pipeline.
-- - Only operates on simple patterns; when in doubt, does nothing.

local Step = require("moonstar.step");
local Ast = require("moonstar.ast");
local visitAst = require("moonstar.visitast");
local Scope = require("moonstar.scope");
local util = require("moonstar.util");

local AstKind = Ast.AstKind;

local LocalLifetimeSplitting = Step:extend();
LocalLifetimeSplitting.Name = "LocalLifetimeSplitting";
LocalLifetimeSplitting.Description = "Split clearly segmented local lifetimes into fresh locals (conservative)";

-- Settings:
--  enabled: gate controlled by pipeline config (step is only instantiated when requested)
--  maxSplitsPerFunction: limit work per function
--  allowLoops: if false (default), skip locals heavily used inside loops
LocalLifetimeSplitting.SettingsDescriptor = {
	enabled = {
		name = "enabled";
		description = "Enable LocalLifetimeSplitting";
		type = "boolean";
		default = false;
	};
	maxSplitsPerFunction = {
		name = "maxSplitsPerFunction";
		description = "Maximum split operations per function";
		type = "number";
		default = 8;
		min = 0;
	};
	allowLoops = {
		name = "allowLoops";
		description = "Allow splitting locals that participate in loop-heavy code paths";
		type = "boolean";
		default = false;
	};
};

function LocalLifetimeSplitting:init()
	-- no-op; configuration handled via SettingsDescriptor
end

-- Internal helpers

local function isSimpleBlock(block)
	-- Very conservative: just ensure it's a normal block node.
	return block and block.kind == AstKind.Block;
end

local function computeSegments(uses)
	-- Build linear segments between writes where lifetimes don't overlap.
	-- Pattern: write/read cluster, then later another write/read cluster with no cross dependencies.
	-- For conservative safety, require each new segment to start with a write.
	if not uses or #uses == 0 then
		return nil;
	end

	local segments = {};
	local current = { start = 1; };
	for i = 1, #uses do
		local u = uses[i];
		if u.kind == "write" and i > 1 then
			-- start new potential segment
			current["end"] = i - 1;
			table.insert(segments, current);
			current = { start = i; };
		end
	end
	current["end"] = #uses;
	table.insert(segments, current);

	if #segments <= 1 then
		return nil;
	end

	-- Safety: require that each segment after the first begins with a write.
	for idx = 2, #segments do
		local seg = segments[idx];
		if uses[seg.start].kind ~= "write" then
			return nil;
		end
	end

	return segments;
end

local function buildUseIndex(block)
	-- Map statement/expression nodes in block traversal order to an index.
	-- visitAst already iterates statements in order; we will track in previsit.
	local index = {};
	local counter = 0;

	visitAst({
		kind = AstKind.TopNode;
		body = block;
		globalScope = block.scope;
	}, function(node)
		-- only count expressions and statements that are "real" nodes
		if node.isStatement or node.isExpression then
			counter = counter + 1;
			index[node] = counter;
		end
		return node;
	end, nil, {});

	return index;
end

function LocalLifetimeSplitting:apply(ast, pipeline)
	-- If not enabled in settings, no-op.
	if not self.enabled then
		return ast;
	end

	if not ast or ast.kind ~= AstKind.TopNode or not ast.body then
		return ast;
	end

	-- Visit function-like blocks (including top-level treated as function) and
	-- perform conservative splitting per local variable.
	local maxSplitsPerFunction = self.maxSplitsPerFunction or 8;
	local allowLoops = self.allowLoops and true or false;

	visitAst(ast, function(node, data)
		-- previsit: detect function entry
		if node.kind == AstKind.FunctionLiteralExpression
			or node.kind == AstKind.FunctionDeclaration
			or node.kind == AstKind.LocalFunctionDeclaration
			or node.kind == AstKind.TopNode
		then
			-- function body / top-level block is in node.body
			local block = node.body;
			if not block or block.kind ~= AstKind.Block then
				return node;
			end

			local blockScope = block.scope or data.scope or ast.globalScope;
			if not blockScope then
				return node;
			end

			-- Precompute order index for use classification
			local useIndex = buildUseIndex(block);

			local splitsDone = 0;
			local vars = blockScope:getVariables();
			for varId, _ in pairs(vars) do
				if splitsDone >= maxSplitsPerFunction then
					break;
				end

				-- Only consider locals defined in this scope (skip globalScope etc.)
				if not blockScope.isGlobal then
					local uses = {};
					local inLoopStack = 0;
					local hasUpvalue = false;
					local hasComplex = false;

					visitAst({
						kind = AstKind.TopNode;
						body = block;
						globalScope = blockScope;
					}, function(n)
						if n.kind == AstKind.WhileStatement
							or n.kind == AstKind.RepeatStatement
							or n.kind == AstKind.ForStatement
							or n.kind == AstKind.ForInStatement
						then
							inLoopStack = inLoopStack + 1;
						end

						if n.kind == AstKind.BreakStatement
							or n.kind == AstKind.ContinueStatement
						then
							hasComplex = true;
						end

						if n.kind == AstKind.FunctionLiteralExpression
							or n.kind == AstKind.FunctionDeclaration
							or n.kind == AstKind.LocalFunctionDeclaration
						then
							-- Skip nested functions
							return n, true;
						end

						if n.kind == AstKind.VariableExpression and n.scope and n.id then
							if n.id == varId and n.scope == blockScope then
								local idx = useIndex[n] or 0;
								table.insert(uses, {
									index = idx;
									kind = "read";
									inLoop = inLoopStack > 0;
									node = n;
								});
							end
						elseif n.kind == AstKind.AssignmentVariable and n.scope and n.id then
							if n.id == varId and n.scope == blockScope then
								local idx = useIndex[n] or 0;
								table.insert(uses, {
									index = idx;
									kind = "write";
									inLoop = inLoopStack > 0;
									node = n;
								});
							end
						end

						return n;
					end, function(n)
						if n.kind == AstKind.WhileStatement
							or n.kind == AstKind.RepeatStatement
							or n.kind == AstKind.ForStatement
							or n.kind == AstKind.ForInStatement
						then
							inLoopStack = inLoopStack - 1;
						end
						return n;
					end, {});

					-- Use nested conditions instead of goto for Lua 5.1 compatibility
					if not (hasUpvalue or hasComplex) then
						local skipVar = false;
						
						if not allowLoops then
							for _, u in ipairs(uses) do
								if u.inLoop then
									skipVar = true;
									break;
								end
							end
						end
						
						if not skipVar then
							table.sort(uses, function(a, b)
								return a.index < b.index;
							end);

							if #uses > 0 then
								local segments = computeSegments(uses);
								if segments then
									-- Perform renaming for segments after the first:
									-- For each later segment, create a fresh local id/name in same scope
									-- and rewrite reads/writes in that segment to use it.
									for sIdx = 2, #segments do
										if splitsDone >= maxSplitsPerFunction then
											break;
										end
										local seg = segments[sIdx];

										-- Create new variable in the same scope; let Scope pick a safe name.
										local newVarId = blockScope:addVariable();
										splitsDone = splitsDone + 1;

										for i = seg.start, seg["end"] do
											local u = uses[i];
											local n = u.node;
											if n and (n.kind == AstKind.VariableExpression or n.kind == AstKind.AssignmentVariable) then
												n.id = newVarId;
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end, nil, {});

	return ast;
end

return LocalLifetimeSplitting;
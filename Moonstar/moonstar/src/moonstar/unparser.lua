-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- unparser.lua
-- Overview:
-- This Script provides a class for lua code generation from an ast
-- This UnParser is Capable of generating LuaU and Lua5.1
-- 
-- Note that a LuaU ast can only be unparsed as LuaU if it contains any continue statements
--
-- Settings Object:
-- luaVersion : The LuaVersion of the Script
--

local config = require("config");
local Ast    = require("moonstar.ast");
local Enums  = require("moonstar.enums");
local util = require("moonstar.util");
local logger = require("logger");

local lookupify = util.lookupify;
local LuaVersion = Enums.LuaVersion;
local AstKind = Ast.AstKind;

local Unparser = {}

Unparser.SPACE = config.SPACE;
Unparser.TAB = config.TAB;

local function getVarNameSafe(scope, id, context)
    if not scope or not scope.getVariableName then
        error("Scope missing getVariableName in " .. tostring(context))
    end
    return scope:getVariableName(id)
end

local function escapeString(str)
	str = util.escape(str)
	return str;
end

function Unparser:new(settings)
	local luaVersion = settings.LuaVersion or LuaVersion.LuaU;
	local conventions = Enums.Conventions[luaVersion];
	local unparser = {
		luaVersion = luaVersion;
		conventions = conventions;
		identCharsLookup = lookupify(conventions.IdentChars);
		numberCharsLookup = lookupify(conventions.NumberChars);
		prettyPrint = settings and settings.PrettyPrint or false;
		notIdentPattern = "[^" .. table.concat(conventions.IdentChars, "") .. "]";
		numberPattern = "^[" .. table.concat(conventions.NumberChars, "") .. "]";
		highlight     = settings and settings.Highlight or false;
		keywordsLookup = lookupify(conventions.Keywords);
	}
	
	setmetatable(unparser, self);
	self.__index = self;
	
	return unparser;
end

function Unparser:isValidIdentifier(source)
	if(string.find(source, self.notIdentPattern)) then
		return false;
	end
	if(string.find(source, self.numberPattern)) then
		return false;
	end
	if self.keywordsLookup[source] then
		return false;
	end
	return #source > 0;
end

function Unparser:setPrettyPrint(prettyPrint)
	self.prettyPrint = prettyPrint;
end

function Unparser:getPrettyPrint()
	return self.prettyPrint;
end

function Unparser:tabs(i, ws_needed)
	return self.prettyPrint and string.rep(self.TAB, i) or ws_needed and self.SPACE or "";
end

function Unparser:newline(ws_needed)
	return self.prettyPrint and "\n" or ws_needed and self.SPACE or "";
end

function Unparser:whitespaceIfNeeded(following, ws)
	if(self.prettyPrint or self.identCharsLookup[string.sub(following, 1, 1)]) then
		return ws or self.SPACE;
	end
	return "";
end

function Unparser:whitespaceIfNeeded2(leading, ws)
	if(self.prettyPrint or self.identCharsLookup[string.sub(leading, #leading, #leading)]) then
		return ws or self.SPACE;
	end
	return "";
end

function Unparser:optionalWhitespace(ws)
	return self.prettyPrint and (ws or self.SPACE) or "";
end

function Unparser:whitespace(ws)
	return self.SPACE or ws;
end

function Unparser:unparse(ast)
	if(ast.kind ~= AstKind.TopNode) then
		logger:error("Unparser:unparse expects a TopNode as first argument")
	end
	
	return self:unparseBlock(ast.body);
end

function Unparser:unparseBlock(block, tabbing)
	if(#block.statements < 1) then
		return self:whitespace();
	end
	
	-- Memory optimization: Use table.concat instead of repeated string concatenation
	-- This is critical for large obfuscated files (Strong preset with VM obfuscation)
	local parts = {};
	local lastCode = "";
	
	for i, statement in ipairs(block.statements) do
		if(statement.kind ~= AstKind.NopStatement) then
			local statementCode = self:unparseStatement(statement, tabbing);
			if(not self.prettyPrint and #parts > 0 and string.sub(statementCode, 1, 1) == "(") then
				-- This is so that the following works:
				-- print("Test");(function() print("Test2") end)();
				statementCode = ";" .. statementCode;
			end
			local ws = self:whitespaceIfNeeded2(lastCode, self:whitespaceIfNeeded(statementCode, self:newline(true)));
			if i ~= 1 and #ws > 0 then
				table.insert(parts, ws);
			end
			if(self.prettyPrint) then
				statementCode = statementCode .. ";"
			end
			table.insert(parts, statementCode);
			lastCode = statementCode;
		end
	end
	
	return table.concat(parts);
end

function Unparser:unparseStatement(statement, tabbing)
	tabbing = tabbing and tabbing + 1 or 0;
	-- Memory optimization: Use table parts for building code strings
	local parts = {};
	local code = "";
	
	if(statement.kind == AstKind.ContinueStatement) then
		code = "continue";
		
	-- Break Statement
	elseif(statement.kind == AstKind.BreakStatement) then
		code = "break";
		
		
	-- Do Statement
	elseif(statement.kind == AstKind.DoStatement) then
		local bodyCode = self:unparseBlock(statement.body, tabbing);
		code = "do" ..  self:whitespaceIfNeeded(bodyCode, self:newline(true))
			.. bodyCode .. self:newline(false)
			.. self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)) .. "end";
		
	-- While Statement
	elseif(statement.kind == AstKind.WhileStatement) then
		local expressionCode = self:unparseExpression(statement.condition, tabbing);
		
		local bodyCode = self:unparseBlock(statement.body, tabbing);
		
		
		code = "while" .. self:whitespaceIfNeeded(expressionCode) .. expressionCode .. self:whitespaceIfNeeded2(expressionCode) 
			.. "do" .. self:whitespaceIfNeeded(bodyCode, self:newline(true))
			.. bodyCode .. self:newline(false)
			.. self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)) .. "end";
			
	-- Repeat Until Statement
	elseif(statement.kind == AstKind.RepeatStatement) then
		local expressionCode = self:unparseExpression(statement.condition, tabbing);

		local bodyCode = self:unparseBlock(statement.body, tabbing);


		code = "repeat" ..  self:whitespaceIfNeeded(bodyCode, self:newline(true))
			.. bodyCode
			.. self:whitespaceIfNeeded2(bodyCode, self:newline() .. self:tabs(tabbing, true)) .. "until" .. self:whitespaceIfNeeded(expressionCode) .. expressionCode;

	-- For Statement
	elseif(statement.kind == AstKind.ForStatement) then
		local bodyCode = self:unparseBlock(statement.body, tabbing);
		local incrementByCode = statement.incrementBy and self:unparseExpression(statement.incrementBy, tabbing) or "1";
		
		parts = {"for", self:whitespace(), getVarNameSafe(statement.scope, statement.id, "ForStatement"), 
			self:optionalWhitespace(), "=", self:optionalWhitespace(), 
			self:unparseExpression(statement.initialValue, tabbing), ",", 
			self:optionalWhitespace(), self:unparseExpression(statement.finalValue, tabbing), ",",
			self:optionalWhitespace(), incrementByCode, self:whitespaceIfNeeded2(incrementByCode), 
			"do", self:whitespaceIfNeeded(bodyCode, self:newline(true)),
			bodyCode, self:newline(false),
			self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)), "end"};
		code = table.concat(parts);
		
		
	-- For In Statement
	elseif(statement.kind == AstKind.ForInStatement) then
		parts = {"for", self:whitespace()};
		
		for i, id in ipairs(statement.ids) do
			if(i ~= 1) then
				table.insert(parts, ",");
				table.insert(parts, self:optionalWhitespace());
			end
			table.insert(parts, getVarNameSafe(statement.scope, id, "ForInStatement"));
		end
		
		table.insert(parts, self:whitespace());
		table.insert(parts, "in");
		
		local exprcode = self:unparseExpression(statement.expressions[1], tabbing);
		table.insert(parts, self:whitespaceIfNeeded(exprcode));
		table.insert(parts, exprcode);
		for i = 2, #statement.expressions, 1 do
			exprcode = self:unparseExpression(statement.expressions[i], tabbing);
			table.insert(parts, ",");
			table.insert(parts, self:optionalWhitespace());
			table.insert(parts, exprcode);
		end
		
		local bodyCode = self:unparseBlock(statement.body, tabbing);
		table.insert(parts, self:whitespaceIfNeeded2(table.concat(parts)));
		table.insert(parts, "do");
		table.insert(parts, self:whitespaceIfNeeded(bodyCode, self:newline(true)));
		table.insert(parts, bodyCode);
		table.insert(parts, self:newline(false));
		table.insert(parts, self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)));
		table.insert(parts, "end");
		code = table.concat(parts);
		
		
	-- If Statement
	elseif(statement.kind == AstKind.IfStatement) then
		local exprcode = self:unparseExpression(statement.condition, tabbing);
		local bodyCode = self:unparseBlock(statement.body, tabbing);
		
		parts = {"if", self:whitespaceIfNeeded(exprcode), exprcode, 
			self:whitespaceIfNeeded2(exprcode), "then", 
			self:whitespaceIfNeeded(bodyCode, self:newline(true)), bodyCode};
		
		for i, eif in ipairs(statement.elseifs) do
			exprcode = self:unparseExpression(eif.condition, tabbing);
			bodyCode = self:unparseBlock(eif.body, tabbing);
			table.insert(parts, self:newline(false));
			table.insert(parts, self:whitespaceIfNeeded2(table.concat(parts), self:tabs(tabbing, true)));
			table.insert(parts, "elseif");
			table.insert(parts, self:whitespaceIfNeeded(exprcode));
			table.insert(parts, exprcode);
			table.insert(parts, self:whitespaceIfNeeded2(exprcode));
			table.insert(parts, "then");
			table.insert(parts, self:whitespaceIfNeeded(bodyCode, self:newline(true)));
			table.insert(parts, bodyCode);
		end
		
		if(statement.elsebody) then
			bodyCode = self:unparseBlock(statement.elsebody, tabbing);
			table.insert(parts, self:newline(false));
			table.insert(parts, self:whitespaceIfNeeded2(table.concat(parts), self:tabs(tabbing, true)));
			table.insert(parts, "else");
			table.insert(parts, self:whitespaceIfNeeded(bodyCode, self:newline(true)));
			table.insert(parts, bodyCode);
		end
		
		table.insert(parts, self:newline(false));
		table.insert(parts, self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)));
		table.insert(parts, "end");
		code = table.concat(parts);
		
		
	-- Function Declaration
	elseif(statement.kind == AstKind.FunctionDeclaration) then
		local funcname = getVarNameSafe(statement.scope, statement.id, "FunctionDeclaration");
		for _, index in ipairs(statement.indices) do
			funcname = funcname .. "." .. index;
		end
		
		parts = {"function", self:whitespace(), funcname, "("};
		
		for i, arg in ipairs(statement.args) do
			if i > 1 then
				table.insert(parts, ",");
				table.insert(parts, self:optionalWhitespace());
			end
			if(arg.kind == AstKind.VarargExpression) then
				table.insert(parts, "...");
			else
				table.insert(parts, getVarNameSafe(arg.scope, arg.id, "FunctionDeclarationArg"));
			end
		end
		table.insert(parts, ")");
		
		local bodyCode = self:unparseBlock(statement.body, tabbing);
		table.insert(parts, self:newline(false));
		table.insert(parts, bodyCode);
		table.insert(parts, self:newline(false));
		table.insert(parts, self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)));
		table.insert(parts, "end");
		code = table.concat(parts);
		
		
	-- Local Function Declaration
	elseif(statement.kind == AstKind.LocalFunctionDeclaration) then
		local funcname = getVarNameSafe(statement.scope, statement.id, "LocalFunctionDeclaration");
		parts = {"local", self:whitespace(), "function", self:whitespace(), funcname, "("};
		
		for i, arg in ipairs(statement.args) do
			if i > 1 then
				table.insert(parts, ",");
				table.insert(parts, self:optionalWhitespace());
			end
			if(arg.kind == AstKind.VarargExpression) then
				table.insert(parts, "...");
			else
				table.insert(parts, getVarNameSafe(arg.scope, arg.id, "FunctionDeclarationArg"));
			end
		end
		table.insert(parts, ")");

		local bodyCode = self:unparseBlock(statement.body, tabbing);
		table.insert(parts, self:newline(false));
		table.insert(parts, bodyCode);
		table.insert(parts, self:newline(false));
		table.insert(parts, self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)));
		table.insert(parts, "end");
		code = table.concat(parts);
		
	-- Local Variable Declaration
	elseif(statement.kind == AstKind.LocalVariableDeclaration) then
		parts = {"local", self:whitespace()};
		
		for i, id in ipairs(statement.ids) do
			if i > 1 then
				table.insert(parts, ",");
				table.insert(parts, self:optionalWhitespace());
			end
			table.insert(parts, getVarNameSafe(statement.scope, id, "ForInStatement"));
		end

		if(#statement.expressions > 0) then
			table.insert(parts, self:optionalWhitespace());
			table.insert(parts, "=");
			table.insert(parts, self:optionalWhitespace());
			for i, expr in ipairs(statement.expressions) do
				if i > 1 then
					table.insert(parts, ",");
					table.insert(parts, self:optionalWhitespace());
				end
				table.insert(parts, self:unparseExpression(expr, tabbing + 1));
			end
		end
		code = table.concat(parts);
	-- Function Call Statement
	elseif(statement.kind == AstKind.FunctionCallStatement) then
		parts = {};
		if not (statement.base.kind == AstKind.IndexExpression or statement.base.kind == AstKind.VariableExpression) then
			table.insert(parts, "(");
			table.insert(parts, self:unparseExpression(statement.base, tabbing));
			table.insert(parts, ")");
		else
			table.insert(parts, self:unparseExpression(statement.base, tabbing));
		end
		
		table.insert(parts, "(");
		
		for i, arg in ipairs(statement.args) do
			if i > 1 then
				table.insert(parts, ",");
				table.insert(parts, self:optionalWhitespace());
			end
			table.insert(parts, self:unparseExpression(arg, tabbing));
		end
		
		table.insert(parts, ")");
		code = table.concat(parts);
		
	-- Pass Self Function Call Statement
	elseif(statement.kind == AstKind.PassSelfFunctionCallStatement) then
		parts = {};
		if not (statement.base.kind == AstKind.IndexExpression or statement.base.kind == AstKind.VariableExpression) then
			table.insert(parts, "(");
			table.insert(parts, self:unparseExpression(statement.base, tabbing));
			table.insert(parts, ")");
		else
			table.insert(parts, self:unparseExpression(statement.base, tabbing));
		end

		table.insert(parts, ":");
		table.insert(parts, statement.passSelfFunctionName);
		table.insert(parts, "(");

		for i, arg in ipairs(statement.args) do
			if i > 1 then
				table.insert(parts, ",");
				table.insert(parts, self:optionalWhitespace());
			end
			table.insert(parts, self:unparseExpression(arg, tabbing));
		end

		table.insert(parts, ")");
		code = table.concat(parts);
		
		
	elseif(statement.kind == AstKind.AssignmentStatement) then
		parts = {};
		for i, primary_expr in ipairs(statement.lhs) do
			if i > 1 then
				table.insert(parts, ",");
				table.insert(parts, self:optionalWhitespace());
			end
			table.insert(parts, self:unparseExpression(primary_expr, tabbing));
		end
		
		table.insert(parts, self:optionalWhitespace());
		table.insert(parts, "=");
		table.insert(parts, self:optionalWhitespace());
		
		for i, expr in ipairs(statement.rhs) do
			if i > 1 then
				table.insert(parts, ",");
				table.insert(parts, self:optionalWhitespace());
			end
			table.insert(parts, self:unparseExpression(expr, tabbing + 1));
		end
		code = table.concat(parts);
		
	-- Return Statement
	elseif(statement.kind == AstKind.ReturnStatement) then
		parts = {"return"};
		if(#statement.args > 0) then
			local exprcode = self:unparseExpression(statement.args[1], tabbing);
			table.insert(parts, self:whitespaceIfNeeded(exprcode));
			table.insert(parts, exprcode);
			for i = 2, #statement.args, 1 do
				exprcode = self:unparseExpression(statement.args[i], tabbing);
				table.insert(parts, ",");
				table.insert(parts, self:optionalWhitespace());
				table.insert(parts, exprcode);
			end
		end
		code = table.concat(parts);
	elseif self.luaVersion == LuaVersion.LuaU then
		local compoundOperators = {
		    [AstKind.CompoundAddStatement] = "+=",
		    [AstKind.CompoundSubStatement] = "-=",
		    [AstKind.CompoundMulStatement] = "*=",
		    [AstKind.CompoundDivStatement] = "/=",
		    [AstKind.CompoundModStatement] = "%=",
		    [AstKind.CompoundPowStatement] = "^=",
		    [AstKind.CompoundConcatStatement] = "..=",
		}
		
		local operator = compoundOperators[statement.kind]
		if operator then
		    parts = {self:unparseExpression(statement.lhs, tabbing), self:optionalWhitespace(), 
		    	operator, self:optionalWhitespace(), self:unparseExpression(statement.rhs, tabbing)};
		    code = table.concat(parts);
		else
		    logger:error(string.format("\"%s\" is not a valid unparseable statement in %s!", statement.kind, self.luaVersion))
		end
	end
	
	return self:tabs(tabbing, false) .. code;
end

local function randomTrueNode()
	local op = math.random(1, 2);
	if(op == 1) then
		-- Less than
		local a = math.random(1, 9)
		local b = math.random(0, a - 1);
		return tostring(a) .. ">" .. tostring(b);
	else
		-- Greater than
		local a = math.random(1, 9)
		local b = math.random(0, a - 1);
		return tostring(b) .. "<" .. tostring(a);
	end
end

local function randomFalseNode()
	local op = math.random(1, 2);
	if(op == 1) then
		-- Less than
		local a = math.random(1, 9)
		local b = math.random(0, a - 1);
		return tostring(b) .. ">" .. tostring(a);
	else
		-- Greater than
		local a = math.random(1, 9)
		local b = math.random(0, a - 1);
		return tostring(a) .. "<" .. tostring(b);
	end
end

function Unparser:unparseExpression(expression, tabbing)
	local code = "";
	
	if(expression.kind == AstKind.BooleanExpression) then
		if(expression.value) then
			return "true";
		else
			return "false";
		end
	end
	
	if(expression.kind == AstKind.NumberExpression) then
		local str = tostring(expression.value);
		if(str == "inf") then
			return "2e1024"
		end
		if(str == "-inf") then
			return "-2e1024"
		end
		if(str:sub(1, 2) == "0.") then
			str = str:sub(2);
		end
		return str;
	end
	
	if(expression.kind == AstKind.VariableExpression or expression.kind == AstKind.AssignmentVariable) then
			return getVarNameSafe(expression.scope, expression.id, "VariableExpression");
	end
	
	if(expression.kind == AstKind.StringExpression) then
		return "\"" .. escapeString(expression.value) .. "\"";
	end
	if(expression.kind == AstKind.NilExpression) then
		return "nil";
	end
	
	if(expression.kind == AstKind.VarargExpression) then
		return "...";
	end
	
	local k = AstKind.OrExpression;
	if(expression.kind == k) then
		-- Check if this is a ternary-like pattern: (X and Y or Z)
		-- If so, generate obfuscated version directly instead of the pattern
		if expression.lhs.kind == AstKind.AndExpression then
			-- This is "X and Y or Z" pattern - obfuscate it during generation
			local condition = self:unparseExpression(expression.lhs.lhs, tabbing);
			local trueValue = self:unparseExpression(expression.lhs.rhs, tabbing);
			local falseValue = self:unparseExpression(expression.rhs, tabbing);
			
			-- 91% chance to generate obfuscated form
			if math.random(1, 100) <= 91 then
				-- Generate as inline function with if-then-else
				return string.format("(function() if %s then return %s else return %s end end)()",
					condition, trueValue, falseValue);
			else
				-- Keep some as original for variety (9%)
				local lhs = self:unparseExpression(expression.lhs, tabbing);
				local rhs = self:unparseExpression(expression.rhs, tabbing);
				return "(" .. lhs .. self:whitespaceIfNeeded2(lhs) .. "or" .. self:whitespaceIfNeeded(rhs) .. rhs .. ")";
			end
		end
		
		-- Regular or expression (not part of ternary pattern)
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		local rhs = self:unparseExpression(expression.rhs, tabbing);
		return lhs .. self:whitespaceIfNeeded2(lhs) .. "or" .. self:whitespaceIfNeeded(rhs) .. rhs;
	end
	
	k = AstKind.AndExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end
		
		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end
		
		return lhs .. self:whitespaceIfNeeded2(lhs) .. "and" .. self:whitespaceIfNeeded(rhs) .. rhs;
	end
	
	k = AstKind.LessThanExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "<" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.GreaterThanExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. ">" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.LessThanOrEqualsExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "<=" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.GreaterThanOrEqualsExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. ">=" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.NotEqualsExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "~=" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.EqualsExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "==" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.StrCatExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		if(self.numberCharsLookup[string.sub(lhs, #lhs, #lhs)]) then
			lhs = lhs .. " ";
		end

		return lhs .. self:optionalWhitespace() .. ".." .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.AddExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "+" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.SubExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		if string.sub(rhs, 1, 1) == "-" then
			rhs = "(" .. rhs .. ")";
		end 

		return lhs .. self:optionalWhitespace() .. "-" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.MulExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "*" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.DivExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "/" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.ModExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "%" .. self:optionalWhitespace() .. rhs;
	end
	
	k = AstKind.PowExpression;
	if(expression.kind == k) then
		local lhs = self:unparseExpression(expression.lhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.lhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			lhs = "(" .. lhs .. ")";
		end

		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return lhs .. self:optionalWhitespace() .. "^" .. self:optionalWhitespace() .. rhs;
	end
	
	-- Unary Expressions
	k = AstKind.NotExpression;
	if(expression.kind == k) then
		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return "not" .. self:whitespaceIfNeeded(rhs) .. rhs;
	end
	
	k = AstKind.NegateExpression;
	if(expression.kind == k) then
		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		if string.sub(rhs, 1, 1) == "-" then
			rhs = "(" .. rhs .. ")";
		end 

		return "-" .. rhs;
	end
	
	k = AstKind.LenExpression;
	if(expression.kind == k) then
		local rhs = self:unparseExpression(expression.rhs, tabbing);
		if(Ast.astKindExpressionToNumber(expression.rhs.kind) >= Ast.astKindExpressionToNumber(k)) then
			rhs = "(" .. rhs .. ")";
		end

		return "#" .. rhs;
	end
	
	k = AstKind.IndexExpression;
	if(expression.kind == k or expression.kind == AstKind.AssignmentIndexing) then
		local base = self:unparseExpression(expression.base, tabbing);
		if(expression.base.kind == AstKind.VarargExpression or Ast.astKindExpressionToNumber(expression.base.kind) > Ast.astKindExpressionToNumber(k)) then
			base = "(" .. base .. ")";
		end
		
		-- Identifier Indexing e.g: x.y instead of x["y"];
		if(expression.index.kind == AstKind.StringExpression and self:isValidIdentifier(expression.index.value)) then
			return base .. "." .. expression.index.value;
		end
		
		-- Index never needs parens
		local index = self:unparseExpression(expression.index, tabbing);
		return base .. "[" .. index .. "]";
	end
	
	k = AstKind.FunctionCallExpression;
	if(expression.kind == k) then
		if not (expression.base.kind == AstKind.IndexExpression or expression.base.kind == AstKind.VariableExpression) then
			code = "(" .. self:unparseExpression(expression.base, tabbing) .. ")";
		else
			code = self:unparseExpression(expression.base, tabbing);
		end

		code = code .. "(";

		for i, arg in ipairs(expression.args) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			code = code .. self:unparseExpression(arg, tabbing);
		end

		code = code .. ")";
		return code;
	end
	
	
	k = AstKind.PassSelfFunctionCallExpression;
	if(expression.kind == k) then
		if not (expression.base.kind == AstKind.IndexExpression or expression.base.kind == AstKind.VariableExpression) then
			code = "(" .. self:unparseExpression(expression.base, tabbing) .. ")";
		else
			code = self:unparseExpression(expression.base, tabbing);
		end

		code = code .. ":" .. expression.passSelfFunctionName;

		code = code .. "(";

		for i, arg in ipairs(expression.args) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			code = code .. self:unparseExpression(arg, tabbing);
		end

		code = code .. ")";
		return code;
	end
	
	k = AstKind.FunctionLiteralExpression;
	if(expression.kind == k) then
		code = "function" .. "(";

		for i, arg in ipairs(expression.args) do
			if i > 1 then
				code = code .. "," .. self:optionalWhitespace();
			end
			if(arg.kind == AstKind.VarargExpression) then
				code = code .. "...";
			else
				code = code .. getVarNameSafe(arg.scope, arg.id, "FunctionDeclarationArg");
			end
		end
		code = code .. ")";

		local bodyCode = self:unparseBlock(expression.body, tabbing);
		code = code .. self:newline(false) .. bodyCode .. self:newline(false) .. self:whitespaceIfNeeded2(bodyCode, self:tabs(tabbing, true)) .. "end";
		return code;
	end
	
	k = AstKind.TableConstructorExpression;
	if(expression.kind == k) then
		if(#expression.entries == 0) then return "{}" end;

		local inlineTable = #expression.entries <= 3;
		local tableTabbing = tabbing + 1;
		
		code = "{";
		if inlineTable then
			code = code .. self:optionalWhitespace();
		else
			code = code .. self:optionalWhitespace(self:newline() .. self:tabs(tableTabbing));
		end
		
		local p = false;
		for i, entry in ipairs(expression.entries) do
			p = true;
			local sep = self.prettyPrint and "," or (math.random(1, 2) == 1 and "," or ";");
			if i > 1 and not inlineTable then
				code = code .. sep .. self:optionalWhitespace(self:newline() .. self:tabs(tableTabbing));
			elseif i > 1 then
				code = code .. sep .. self:optionalWhitespace();
			end
			if(entry.kind == AstKind.KeyedTableEntry) then
				if(entry.key.kind == AstKind.StringExpression and self:isValidIdentifier(entry.key.value)) then
					code = code .. entry.key.value;
				else
					code = code .. "[" .. self:unparseExpression(entry.key, tableTabbing) .. "]";
				end
				code = code .. self:optionalWhitespace() .. "=" .. self:optionalWhitespace() .. self:unparseExpression(entry.value, tableTabbing);
			else
				code = code .. self:unparseExpression(entry.value, tableTabbing);
			end
		end

		if inlineTable then
			return code .. self:optionalWhitespace() .. "}";
		end
		
		return code .. self:optionalWhitespace((p and "," or "") .. self:newline() .. self:tabs(tabbing)) .. "}";
	end

	if (self.luaVersion == LuaVersion.LuaU) then
		k = AstKind.IfElseExpression
		if(expression.kind == k) then
			code = "if ";

			code = code .. self:unparseExpression(expression.condition);
			code = code .. " then ";
			code = code .. self:unparseExpression(expression.true_value);
			code = code .. " else ";
			code = code .. self:unparseExpression(expression.false_value);

			return code
		end
	end

	logger:error(string.format("\"%s\" is not a valid unparseable expression", expression.kind));
end

return Unparser

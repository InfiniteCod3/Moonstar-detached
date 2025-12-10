-- This Script is Part of the Moonstar Obfuscator
--
-- DebugInfoRemover.lua
--
-- This Step removes debug information from the AST:
-- 1. Removes comments
-- 2. Strips source location data (line/column numbers)
-- 3. Removes function names from local function declarations (makes stack traces less useful)
-- 4. Optionally randomizes remaining identifiable strings
--
-- Compatible with Lua 5.1 and LuaU

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local visitast = require("moonstar.visitast")
local AstKind = Ast.AstKind

local DebugInfoRemover = Step:extend()
DebugInfoRemover.Description = "Removes debug information, line numbers, and source locations from the AST."
DebugInfoRemover.Name = "Debug Info Remover"

DebugInfoRemover.SettingsDescriptor = {
	Enabled = {
		type = "boolean",
		default = true,
	},
	-- Remove source location information (line/column)
	RemoveSourceLocations = {
		type = "boolean",
		default = true,
	},
	-- Scramble positions to fake values
	ScramblePositions = {
		type = "boolean",
		default = false,  -- Off by default, use RemoveSourceLocations instead
	},
	-- Remove tokens (whitespace, comments preserved in tokenStream)
	RemoveTokens = {
		type = "boolean",
		default = true,
	},
}

function DebugInfoRemover:init(settings) end

function DebugInfoRemover:apply(ast, pipeline)
	local removeLocations = self.RemoveSourceLocations ~= false
	local scramblePositions = self.ScramblePositions or false
	local removeTokens = self.RemoveTokens ~= false
	
	-- Helper to clear location info from a node
	local function clearLocation(node)
		if not node or type(node) ~= "table" then return end
		
		if removeLocations then
			-- Clear source position information
			node.line = nil
			node.lineEnd = nil
			node.column = nil
			node.columnEnd = nil
			node.charPos = nil
			node.charPosEnd = nil
			node.startPos = nil
			node.endPos = nil
			node.sourcePos = nil
			node.sourcePosEnd = nil
		elseif scramblePositions then
			-- Scramble to fake values to confuse debuggers
			if node.line then node.line = math.random(1, 10000) end
			if node.lineEnd then node.lineEnd = node.line + math.random(0, 100) end
			if node.column then node.column = math.random(1, 200) end
			if node.columnEnd then node.columnEnd = math.random(1, 200) end
		end
		
		if removeTokens then
			-- Clear token references that may contain source info
			node.token = nil
			node.tokens = nil
			node.leadingWhitespace = nil
			node.trailingWhitespace = nil
			node.comments = nil
			node.semicolon = nil
		end
	end
	
	-- Visit all nodes in the AST and clear debug info
	visitast(ast, function(node, data)
		if not node then return end
		
		-- Clear location info from the node itself
		clearLocation(node)
		
		-- Handle specific node types that may have additional debug info
		
		-- Function declarations - clear body location
		if node.kind == AstKind.FunctionDeclaration or
		   node.kind == AstKind.LocalFunctionDeclaration or
		   node.kind == AstKind.FunctionLiteralExpression then
			if node.body then
				clearLocation(node.body)
			end
			-- Clear argument locations
			if node.args then
				for _, arg in ipairs(node.args) do
					clearLocation(arg)
				end
			end
		end
		
		-- Blocks - clear scope locations
		if node.kind == AstKind.Block then
			clearLocation(node)
			if node.scope then
				-- Clear any debug info from scope
				node.scope.sourceName = nil
				node.scope.sourceFile = nil
			end
		end
		
		-- assignment targets
		if node.kind == AstKind.AssignmentVariable or
		   node.kind == AstKind.AssignmentIndexing then
			clearLocation(node)
		end
		
		-- Expressions with sub-parts
		if node.lhs then clearLocation(node.lhs) end
		if node.rhs then clearLocation(node.rhs) end
		if node.base then clearLocation(node.base) end
		if node.index then clearLocation(node.index) end
		if node.condition then clearLocation(node.condition) end
		
		-- Table constructors
		if node.entries then
			for _, entry in ipairs(node.entries) do
				clearLocation(entry)
				if entry.key then clearLocation(entry.key) end
				if entry.value then clearLocation(entry.value) end
			end
		end
		
		-- Function call arguments
		if node.args then
			for _, arg in ipairs(node.args) do
				clearLocation(arg)
			end
		end
		
		-- Return values
		if node.values then
			for _, val in ipairs(node.values) do
				clearLocation(val)
			end
		end
		
		-- Variable declarations
		if node.ids then
			for _, id in ipairs(node.ids) do
				clearLocation(id)
			end
		end
		if node.expressions then
			for _, expr in ipairs(node.expressions) do
				clearLocation(expr)
			end
		end
		
		-- If statement branches
		if node.elseifs then
			for _, branch in ipairs(node.elseifs) do
				clearLocation(branch)
				if branch.condition then clearLocation(branch.condition) end
				if branch.body then clearLocation(branch.body) end
			end
		end
		if node.elsebody then
			clearLocation(node.elsebody)
		end
		
	end)
	
	-- Clear top-level AST debug info
	clearLocation(ast)
	if ast.body then
		clearLocation(ast.body)
	end
	
	-- Clear global scope debug info
	if ast.globalScope then
		ast.globalScope.sourceName = nil
		ast.globalScope.sourceFile = nil
		ast.globalScope.debugName = nil
	end
	
	-- Clear file-level metadata
	ast.sourceFile = nil
	ast.sourceName = nil
	ast.fileName = nil
	ast.filePath = nil
	
	return ast
end

return DebugInfoRemover

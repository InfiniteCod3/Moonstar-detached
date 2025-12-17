-- This Script is Part of the Moonstar Obfuscator
--
-- StringSplitting.lua
--
-- Splits strings into multiple chunks that are concatenated at runtime.
-- Compatible with Lua 5.1 and LuaU (Roblox).

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local visitast = require("moonstar.visitast")
local util = require("moonstar.util")
local logger = require("logger")
local AstKind = Ast.AstKind

local StringSplitting = Step:extend()
StringSplitting.Description = "Splits strings into chunks concatenated at runtime."
StringSplitting.Name = "String Splitting"

StringSplitting.SettingsDescriptor = {
	Enabled = {
		type = "boolean",
		default = true,
	},
	-- Minimum string length to split
	MinLength = {
		type = "number",
		default = 4,
		min = 2,
	},
	-- Maximum number of chunks per string
	MaxChunks = {
		type = "number",
		default = 5,
		min = 2,
		max = 20,
	},
	-- Minimum chunk size
	MinChunkSize = {
		type = "number",
		default = 1,
		min = 1,
	},
	-- Probability of splitting each eligible string
	Intensity = {
		type = "number",
		default = 0.7,
		min = 0.0,
		max = 1.0,
	},
	-- Use table.concat method (vs direct concatenation)
	UseTableConcat = {
		type = "boolean",
		default = true,
	},
	-- Shuffle chunk order (requires runtime reordering)
	ShuffleChunks = {
		type = "boolean",
		default = true,
	},
	-- Use string.char for some characters
	UseCharEncoding = {
		type = "boolean",
		default = true,
	},
	-- Reverse some chunks
	ReverseChunks = {
		type = "boolean",
		default = true,
	},
}

function StringSplitting:init(settings)
	self.splitCount = 0
end

-- Split a string into random-sized chunks
function StringSplitting:splitString(str)
	local len = #str
	local chunks = {}
	local pos = 1
	
	local numChunks = math.random(2, math.min(self.MaxChunks, len))
	local avgSize = math.max(self.MinChunkSize, math.floor(len / numChunks))
	
	while pos <= len do
		local remaining = len - pos + 1
		local chunkSize
		
		if remaining <= self.MinChunkSize then
			chunkSize = remaining
		else
			-- Random chunk size with some variation
			local maxSize = math.min(remaining, avgSize * 2)
			chunkSize = math.random(self.MinChunkSize, maxSize)
		end
		
		local chunk = string.sub(str, pos, pos + chunkSize - 1)
		table.insert(chunks, chunk)
		pos = pos + chunkSize
	end
	
	return chunks
end

-- Generate AST for a string literal
function StringSplitting:stringToAst(str)
	return Ast.StringExpression(str)
end

-- Generate AST for string.char call
function StringSplitting:charToAst(byte, scope)
	local stringScope, stringId = scope:resolveGlobal("string")
	scope:addReferenceToHigherScope(stringScope, stringId)
	
	return Ast.FunctionCallExpression(
		Ast.IndexExpression(
			Ast.VariableExpression(stringScope, stringId),
			Ast.StringExpression("char")
		),
		{Ast.NumberExpression(byte)}
	)
end

-- Generate AST for string.reverse call
function StringSplitting:reverseToAst(strExpr, scope)
	local stringScope, stringId = scope:resolveGlobal("string")
	scope:addReferenceToHigherScope(stringScope, stringId)
	
	return Ast.FunctionCallExpression(
		Ast.IndexExpression(
			Ast.VariableExpression(stringScope, stringId),
			Ast.StringExpression("reverse")
		),
		{strExpr}
	)
end

-- Encode a chunk, possibly using string.char for obfuscation
function StringSplitting:encodeChunk(chunk, scope)
	-- Decide encoding method
	if self.UseCharEncoding and #chunk <= 3 and math.random() < 0.5 then
		-- Use string.char for small chunks
		local bytes = {}
		for i = 1, #chunk do
			table.insert(bytes, string.byte(chunk, i))
		end
		
		local stringScope, stringId = scope:resolveGlobal("string")
		scope:addReferenceToHigherScope(stringScope, stringId)
		
		local args = {}
		for _, b in ipairs(bytes) do
			table.insert(args, Ast.NumberExpression(b))
		end
		
		return Ast.FunctionCallExpression(
			Ast.IndexExpression(
				Ast.VariableExpression(stringScope, stringId),
				Ast.StringExpression("char")
			),
			args
		)
	elseif self.ReverseChunks and #chunk >= 2 and math.random() < 0.3 then
		-- Reverse the chunk and add string.reverse call
		local reversed = string.reverse(chunk)
		return self:reverseToAst(Ast.StringExpression(reversed), scope)
	else
		-- Plain string literal
		return Ast.StringExpression(chunk)
	end
end

-- Build concatenation expression from chunks using .. operator
function StringSplitting:buildConcatExpression(chunkExprs)
	if #chunkExprs == 0 then
		return Ast.StringExpression("")
	end
	
	if #chunkExprs == 1 then
		return chunkExprs[1]
	end
	
	local result = chunkExprs[1]
	for i = 2, #chunkExprs do
		result = Ast.StrCatExpression(result, chunkExprs[i])
	end
	
	return result
end

-- Build table.concat expression from chunks
function StringSplitting:buildTableConcatExpression(chunkExprs, scope, shuffleOrder)
	local tableScope, tableId = scope:resolveGlobal("table")
	scope:addReferenceToHigherScope(tableScope, tableId)
	
	local entries = {}
	
	if shuffleOrder and #chunkExprs > 2 then
		-- Create indexed entries that can be reordered
		local indices = {}
		for i = 1, #chunkExprs do
			indices[i] = i
		end
		util.shuffle(indices)
		
		-- Create table with shuffled entries but correct indices
		for i, originalIdx in ipairs(indices) do
			table.insert(entries, Ast.KeyedTableEntry(
				Ast.NumberExpression(originalIdx),
				chunkExprs[i]
			))
		end
	else
		-- Sequential entries
		for i, expr in ipairs(chunkExprs) do
			table.insert(entries, Ast.TableEntry(expr))
		end
	end
	
	local tableExpr = Ast.TableConstructorExpression(entries)
	
	return Ast.FunctionCallExpression(
		Ast.IndexExpression(
			Ast.VariableExpression(tableScope, tableId),
			Ast.StringExpression("concat")
		),
		{tableExpr}
	)
end

-- Main function to obfuscate a string
function StringSplitting:obfuscateString(str, scope)
	if #str < self.MinLength then
		return nil
	end
	
	-- Split into chunks
	local chunks = self:splitString(str)
	
	if #chunks < 2 then
		return nil
	end
	
	-- Encode each chunk
	local chunkExprs = {}
	for _, chunk in ipairs(chunks) do
		table.insert(chunkExprs, self:encodeChunk(chunk, scope))
	end
	
	-- Build the final expression
	if self.UseTableConcat and #chunks >= 3 then
		return self:buildTableConcatExpression(chunkExprs, scope, self.ShuffleChunks)
	else
		return self:buildConcatExpression(chunkExprs)
	end
end

function StringSplitting:apply(ast, pipeline)
	if not self.Enabled then
		return ast
	end
	
	local intensity = self.Intensity
	local stringsSplit = 0
	
	visitast(ast, nil, function(node, data)
		if node.kind == AstKind.StringExpression then
			-- Skip if already processed
			if node.__string_split then
				return nil
			end
			
			-- Skip if intensity check fails
			if math.random() > intensity then
				return nil
			end
			
			local value = node.value
			
			-- Skip empty strings or strings that are too short
			if not value or #value < self.MinLength then
				return nil
			end
			
			-- Skip strings that look like they might be keys/identifiers
			-- (single words without spaces, often used for table indexing)
			if #value < 10 and not value:find("%s") and value:match("^[%w_]+$") then
				if math.random() > 0.3 then -- Still split some of them
					return nil
				end
			end
			
			local obfuscated = self:obfuscateString(value, data.scope)
			if obfuscated then
				obfuscated.__string_split = true
				stringsSplit = stringsSplit + 1
				return obfuscated
			end
		end
		
		return nil
	end)
	
	logger:info(string.format("String Splitting: Split %d strings", stringsSplit))
	
	return ast
end

return StringSplitting

-- This Script is Part of the Moonstar Obfuscator by Aurologic
--
-- ConstantArray.lua
--
-- This Script provides a Simple Obfuscation Step that wraps the entire Script into a function

-- Future Enhancement Ideas:
-- 1. Wrapper Functions - Additional obfuscation layer for array access
-- 2. Proxy Object for indexing - Transform ARR[X] to use arithmetic operations (e.g., ARR + X)

local Step = require("moonstar.step");
local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local visitast = require("moonstar.visitast");
local util     = require("moonstar.util")
local Parser   = require("moonstar.parser");
local enums = require("moonstar.enums")

local LuaVersion = enums.LuaVersion;
local AstKind = Ast.AstKind;

local ConstantArray = Step:extend();
ConstantArray.Description = "This Step will Extract all Constants and put them into an Array at the beginning of the script";
ConstantArray.Name = "Constant Array";

ConstantArray.SettingsDescriptor = {
	Treshold = {
		name = "Treshold",
		description = "The relative amount of nodes that will be affected",
		type = "number",
		default = 1,
		min = 0,
		max = 1,
	},
	StringsOnly = {
		name = "StringsOnly",
		description = "Wether to only Extract Strings",
		type = "boolean",
		default = false,
	},
	Shuffle = {
		name = "Shuffle",
		description = "Wether to shuffle the order of Elements in the Array",
		type = "boolean",
		default = true,
	},
	Rotate = {
		name = "Rotate",
		description = "Wether to rotate the String Array by a specific (random) amount. This will be undone on runtime.",
		type = "boolean",
		default = true,
	},
	LocalWrapperTreshold = {
		name = "LocalWrapperTreshold",
		description = "The relative amount of nodes functions, that will get local wrappers",
		type = "number",
		default = 1,
		min = 0,
		max = 1,
	},
	LocalWrapperCount = {
		name = "LocalWrapperCount",
		description = "The number of Local wrapper Functions per scope. This only applies if LocalWrapperTreshold is greater than 0",
		type = "number",
		min = 0,
		max = 512,
		default = 0,
	},
	LocalWrapperArgCount = {
		name = "LocalWrapperArgCount",
		description = "The number of Arguments to the Local wrapper Functions",
		type = "number",
		min = 1,
		default = 10,
		max = 200,
	};
	MaxWrapperOffset = {
		name = "MaxWrapperOffset",
		description = "The Max Offset for the Wrapper Functions",
		type = "number",
		min = 0,
		default = 65535,
	};
	Encoding = {
		name = "Encoding",
		description = "The Encoding to use for the Strings",
		type = "enum",
		default = "base64",
		values = {
			"none",
			"base64",
		},
	},
	AntiDeobfuscation = {
		name = "AntiDeobfuscation",
		description = "Enable anti-deobfuscation protections (runtime lookup table generation, vmified shuffle, prevents static analysis)",
		type = "boolean",
		default = true,
	},
	-- Plan.md enhancements
	Enabled = {
		type = "boolean",
		default = true,
	},
	EncodeStrings = {
		type = "boolean",
		default = true,
	},
	IndexObfuscation = {
		type = "boolean",
		default = true,
	},
	EncodeNumbers = {
		name = "EncodeNumbers",
		description = "Enable XOR encoding for numeric constants in the array",
		type = "boolean",
		default = false,  -- Disabled by default due to issues with negative numbers
	},
}

local function callNameGenerator(generatorFunction, ...)
	if(type(generatorFunction) == "table") then
		generatorFunction = generatorFunction.generateName;
	end
	return generatorFunction(...);
end

function ConstantArray:init(settings)
	-- Initialize index obfuscation if enabled
	if self.IndexObfuscation then
		-- Generate a random salt for index transformation
		self.indexSalt = math.random(1, 100)
	end
	
	-- Generate XOR key for number encoding if enabled
	if self.EncodeNumbers then
		-- Generate a random XOR key (0-255 for simple XOR)
		self.xorKey = math.random(0, 255)
	end
end

function ConstantArray:createArray()
	local entries = {};
	for i, v in ipairs(self.constants) do
		if type(v) == "string" then
			v = self:encode(v);
		elseif type(v) == "number" and self.EncodeNumbers then
			-- Apply XOR encoding to numeric constants
			-- Load bit library for XOR operation
			local bit = require("moonstar.bit");
			local bxor = bit.bxor;
			-- XOR encode the number with the key
			v = bxor(v, self.xorKey);
		end
		entries[i] = Ast.TableEntry(Ast.ConstantNode(v));
	end
	return Ast.TableConstructorExpression(entries);
end

function ConstantArray:indexing(index, data)
	local baseIndex = index - self.wrapperOffset
	
	-- Apply index obfuscation if enabled
	if self.IndexObfuscation and self.indexSalt then
		-- Add non-linear transformation to the index calculation
		-- The wrapper will need to reverse this transform
		baseIndex = baseIndex * 2 + self.indexSalt
	end
	
	if self.LocalWrapperCount > 0 and data.functionData.local_wrappers then
		local wrappers = data.functionData.local_wrappers;
		local wrapper = wrappers[math.random(#wrappers)];

		local args = {};
		local ofs = baseIndex - wrapper.offset;
		for i = 1, self.LocalWrapperArgCount, 1 do
			if i == wrapper.arg then
				args[i] = Ast.NumberExpression(ofs);
			else
				args[i] = Ast.NumberExpression(math.random(ofs - 1024, ofs + 1024));
			end
		end

		data.scope:addReferenceToHigherScope(wrappers.scope, wrappers.id);
		return Ast.FunctionCallExpression(Ast.IndexExpression(
			Ast.VariableExpression(wrappers.scope, wrappers.id),
			Ast.StringExpression(wrapper.index)
		), args);
	else
		data.scope:addReferenceToHigherScope(self.rootScope,  self.wrapperId);
		return Ast.FunctionCallExpression(Ast.VariableExpression(self.rootScope, self.wrapperId), {
			Ast.NumberExpression(baseIndex);
		});
	end
end

function ConstantArray:getConstant(value, data)
	if(self.lookup[value]) then
		return self:indexing(self.lookup[value], data)
	end
	local idx = #self.constants + 1;
	self.constants[idx] = value;
	self.lookup[value] = idx;
	return self:indexing(idx, data);
end

function ConstantArray:addConstant(value)
	if(self.lookup[value]) then
		return
	end
	local idx = #self.constants + 1;
	self.constants[idx] = value;
	self.lookup[value] = idx;
end

local function reverse(t, i, j)
	while i < j do
	  t[i], t[j] = t[j], t[i]
	  i, j = i+1, j-1
	end
end
  
local function rotate(t, d, n)
	n = n or #t
	d = (d or 1) % n
	reverse(t, 1, n)
	reverse(t, 1, d)
	reverse(t, d+1, n)
end

local rotateCode = [=[
	for i, v in ipairs({{1, LEN}, {1, SHIFT}, {SHIFT + 1, LEN}}) do
		while v[1] < v[2] do
			ARR[v[1]], ARR[v[2]], v[1], v[2] = ARR[v[2]], ARR[v[1]], v[1] + 1, v[2] - 1
		end
	end
]=];

-- Anti-deobfuscation version: obscure the shuffle pattern
local rotateCodeAntiDeobf = [=[
	do
		local ops = {}
		local a, b, c = 1, LEN, SHIFT
		ops[#ops + 1] = {a, b}
		ops[#ops + 1] = {a, c}
		ops[#ops + 1] = {c + 1, b}
		for idx = 1, #ops do
			local range = ops[idx]
			local l, r = range[1], range[2]
			while l < r do
				ARR[l], ARR[r] = ARR[r], ARR[l]
				l = l + 1
				r = r - 1
			end
		end
	end
]=];

function ConstantArray:addRotateCode(ast, shift)
	local parser = Parser:new({
		LuaVersion = LuaVersion.Lua51;
	});

	-- Use anti-deobfuscation version if enabled
	local codeTemplate = self.AntiDeobfuscation and rotateCodeAntiDeobf or rotateCode;
	local code = string.gsub(string.gsub(codeTemplate, "SHIFT", tostring(shift)), "LEN", tostring(#self.constants));
	
	local newAst = parser:parse(code);
	local statement = newAst.body.statements[1];
	statement.body.scope:setParent(ast.body.scope);
	visitast(newAst, nil, function(node, data)
		if(node.kind == AstKind.VariableExpression) then
			if(node.scope:getVariableName(node.id) == "ARR") then
				data.scope:removeReferenceToHigherScope(node.scope, node.id);
				data.scope:addReferenceToHigherScope(self.rootScope, self.arrId);
				node.scope = self.rootScope;
				node.id    = self.arrId;
			end
		end
	end)

	table.insert(ast.body.statements, 1, statement);
end

function ConstantArray:addDecodeCode(ast)
	-- Add XOR number decoding if enabled
	if self.EncodeNumbers then
		local numberDecodeCode = [[
	do
		local arr = ARR;
		local type = type;
		local key = XOR_KEY;
		-- Inline XOR implementation (pure Lua, no dependencies)
		local function bxor(a, b)
			local p, c = 1, 0
			while a > 0 or b > 0 do
				local ra, rb = a % 2, b % 2
				if ra ~= rb then c = c + p end
				a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
			end
			return c
		end
		for i = 1, #arr do
			local data = arr[i];
			if type(data) == "number" then
				arr[i] = bxor(data, key);
			end
		end
	end
]];
		
		local parser = Parser:new({
			LuaVersion = LuaVersion.Lua51;
		});

		local newAst = parser:parse(numberDecodeCode);
		local doStat = newAst.body.statements[1];
		doStat.body.scope:setParent(ast.body.scope);

		visitast(newAst, nil, function(node, data)
			if(node.kind == AstKind.VariableExpression) then
				if(node.scope:getVariableName(node.id) == "ARR") then
					data.scope:removeReferenceToHigherScope(node.scope, node.id);
					data.scope:addReferenceToHigherScope(self.rootScope, self.arrId);
					node.scope = self.rootScope;
					node.id    = self.arrId;
				elseif(node.scope:getVariableName(node.id) == "XOR_KEY") then
					data.scope:removeReferenceToHigherScope(node.scope, node.id);
					return Ast.NumberExpression(self.xorKey);
				end
			end
		end)
	
		table.insert(ast.body.statements, 1, doStat);
	end
	
	if self.Encoding == "base64" then
		local base64DecodeCode = [[
	do ]] .. table.concat(util.shuffle{
		"local lookup = LOOKUP_TABLE;",
		"local len = string.len;",
		"local sub = string.sub;",
		"local floor = math.floor;",
		"local strchar = string.char;",
		"local insert = table.insert;",
		"local concat = table.concat;",
		"local type = type;",
		"local arr = ARR;",
	}) .. [[
		for i = 1, #arr do
			local data = arr[i];
			if type(data) == "string" then
				local length = len(data)
				local parts = {}
				local index = 1
				local value = 0
				local count = 0
				while index <= length do
					local char = sub(data, index, index)
					local code = lookup[char]
					if code then
						value = value + code * (64 ^ (3 - count))
						count = count + 1
						if count == 4 then
							count = 0
							local c1 = floor(value / 65536)
							local c2 = floor(value % 65536 / 256)
							local c3 = value % 256
							insert(parts, strchar(c1, c2, c3))
							value = 0
						end
					elseif char == "=" then
						insert(parts, strchar(floor(value / 65536)));
						if index >= length or sub(data, index + 1, index + 1) ~= "=" then
							insert(parts, strchar(floor(value % 65536 / 256)));
						end
						break
					end
					index = index + 1
				end
				arr[i] = concat(parts)
			end
		end
	end
]];

		local parser = Parser:new({
			LuaVersion = LuaVersion.Lua51;
		});

		local newAst = parser:parse(base64DecodeCode);
		local forStat = newAst.body.statements[1];
		forStat.body.scope:setParent(ast.body.scope);

		visitast(newAst, nil, function(node, data)
			if(node.kind == AstKind.VariableExpression) then
				if(node.scope:getVariableName(node.id) == "ARR") then
					data.scope:removeReferenceToHigherScope(node.scope, node.id);
					data.scope:addReferenceToHigherScope(self.rootScope, self.arrId);
					node.scope = self.rootScope;
					node.id    = self.arrId;
				end

				if(node.scope:getVariableName(node.id) == "LOOKUP_TABLE") then
					data.scope:removeReferenceToHigherScope(node.scope, node.id);
					return self:createBase64Lookup();
				end
			end
		end)
	
		table.insert(ast.body.statements, 1, forStat);
	end
end

function ConstantArray:createBase64Lookup()
	if self.AntiDeobfuscation then
		-- Anti-deobfuscation: Generate lookup table at runtime instead of embedding it
		-- This prevents static extraction of the encoding table
		-- The deobfuscator cannot determine the mapping without execution
		local charString = self.base64chars;
		
		-- Build AST for runtime lookup generation using parser
		local Parser = require("moonstar.parser");
		local parser = Parser:new({LuaVersion = enums.LuaVersion.Lua51});
		
		-- Generate code that builds the lookup table at runtime
		local runtimeCode = string.format([[
			return (function()
				local t = {}
				local s = %q
				for i = 1, #s do
					local c = s:sub(i, i)
					t[c] = i - 1
				end
				return t
			end)()
		]], charString);
		
		local ast = parser:parse(runtimeCode);
		-- Extract the expression from the return statement
		return ast.body.statements[1].args[1];
	else
		-- Original implementation: embed lookup table directly
		local entries = {};
		local i = 0;
		for char in string.gmatch(self.base64chars, ".") do
			table.insert(entries, Ast.KeyedTableEntry(Ast.StringExpression(char), Ast.NumberExpression(i)));
			i = i + 1;
		end
		util.shuffle(entries);
		return Ast.TableConstructorExpression(entries);
	end
end

function ConstantArray:encode(str)
	if self.Encoding == "base64" then
		return ((str:gsub('.', function(x) 
			local r,b='',x:byte()
			for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
			return r;
		end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then return '' end
			local c=0
			for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
			return self.base64chars:sub(c+1,c+1)
		end)..({ '', '==', '=' })[#str%3+1]);
	end
end

function ConstantArray:apply(ast, pipeline)
	self.rootScope = ast.body.scope;
	self.arrId     = self.rootScope:addVariable();

	self.base64chars = table.concat(util.shuffle{
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
		"+", "/",
	});

	self.constants = {};
	self.lookup    = {};

	-- Extract Constants
	visitast(ast, nil, function(node, data)
		-- Apply only to some nodes
		if math.random() <= self.Treshold then
			node.__apply_constant_array = true;
			if node.kind == AstKind.StringExpression then
				self:addConstant(node.value);
			elseif not self.StringsOnly then
				if node.isConstant then
					if node.value ~= nil then
						self:addConstant(node.value);
					end 
				end
			end
		end
	end);

	-- Shuffle Array
	if self.Shuffle then
		self.constants = util.shuffle(self.constants);
		self.lookup    = {};
		for i, v in ipairs(self.constants) do
			self.lookup[v] = i;
		end
	end

	-- Set Wrapper Function Offset
	self.wrapperOffset = math.random(-self.MaxWrapperOffset, self.MaxWrapperOffset);
	self.wrapperId     = self.rootScope:addVariable();

	visitast(ast, function(node, data)
		-- Add Local Wrapper Functions
		if self.LocalWrapperCount > 0 and node.kind == AstKind.Block and node.isFunctionBlock and math.random() <= self.LocalWrapperTreshold then
			local id = node.scope:addVariable()
			data.functionData.local_wrappers = {
				id = id;
				scope = node.scope,
			};
			local nameLookup = {};
			for i = 1, self.LocalWrapperCount, 1 do
				local name;
				repeat
					name = callNameGenerator(pipeline.namegenerator, math.random(1, self.LocalWrapperArgCount * 16));
				until not nameLookup[name];
				nameLookup[name] = true;

				local offset = math.random(-self.MaxWrapperOffset, self.MaxWrapperOffset);
				local argPos = math.random(1, self.LocalWrapperArgCount);

				data.functionData.local_wrappers[i] = {
					arg   = argPos,
					index = name,
					offset =  offset,
				};
				data.functionData.__used = false;
			end
		end
		if node.__apply_constant_array then
			data.functionData.__used = true;
		end
	end, function(node, data)
		-- Actually insert Statements to get the Constant Values
		if node.__apply_constant_array then
			if node.kind == AstKind.StringExpression then
				return self:getConstant(node.value, data);
			elseif not self.StringsOnly then
				if node.isConstant then
					return node.value ~= nil and self:getConstant(node.value, data);
				end
			end
			node.__apply_constant_array = nil;
		end

		-- Insert Local Wrapper Declarations
		if self.LocalWrapperCount > 0 and node.kind == AstKind.Block and node.isFunctionBlock and data.functionData.local_wrappers and data.functionData.__used then
			data.functionData.__used = nil;
			local elems = {};
			local wrappers = data.functionData.local_wrappers;
			for i = 1, self.LocalWrapperCount, 1 do
				local wrapper = wrappers[i];
				local argPos = wrapper.arg;
				local offset = wrapper.offset;
				local name   = wrapper.index;

				local funcScope = Scope:new(node.scope);

				local arg = nil;
				local args = {};

				for i = 1, self.LocalWrapperArgCount, 1 do
					args[i] = funcScope:addVariable();
					if i == argPos then
						arg = args[i];
					end
				end

				local addSubArg;

				-- Create add and Subtract code
				if offset < 0 then
					addSubArg = Ast.SubExpression(Ast.VariableExpression(funcScope, arg), Ast.NumberExpression(-offset));
				else
					addSubArg = Ast.AddExpression(Ast.VariableExpression(funcScope, arg), Ast.NumberExpression(offset));
				end

				funcScope:addReferenceToHigherScope(self.rootScope, self.wrapperId);
				local callArg = Ast.FunctionCallExpression(Ast.VariableExpression(self.rootScope, self.wrapperId), {
					addSubArg
				});

				local fargs = {};
				for i, v in ipairs(args) do
					fargs[i] = Ast.VariableExpression(funcScope, v);
				end

				elems[i] = Ast.KeyedTableEntry(
					Ast.StringExpression(name),
					Ast.FunctionLiteralExpression(fargs, Ast.Block({
						Ast.ReturnStatement({
							callArg
						});
					}, funcScope))
				)
			end
			table.insert(node.statements, 1, Ast.LocalVariableDeclaration(node.scope, {
				wrappers.id
			}, {
				Ast.TableConstructorExpression(elems)
			}));
		end
	end);

	self:addDecodeCode(ast);

	local steps = util.shuffle({
		-- Add Wrapper Function Code
		function() 
			local funcScope = Scope:new(self.rootScope);
			-- Add Reference to Array
			funcScope:addReferenceToHigherScope(self.rootScope, self.arrId);

			local arg = funcScope:addVariable();
			local addSubArg;

			-- Apply index deobfuscation if IndexObfuscation is enabled
			local indexExpr = Ast.VariableExpression(funcScope, arg)
			if self.IndexObfuscation and self.indexSalt then
				-- Reverse the transformation: (x - salt) / 2 + offset
				indexExpr = Ast.DivExpression(
					Ast.SubExpression(indexExpr, Ast.NumberExpression(self.indexSalt)),
					Ast.NumberExpression(2)
				)
			end

			-- Create add and Subtract code
			if self.wrapperOffset < 0 then
				addSubArg = Ast.SubExpression(indexExpr, Ast.NumberExpression(-self.wrapperOffset));
			else
				addSubArg = Ast.AddExpression(indexExpr, Ast.NumberExpression(self.wrapperOffset));
			end

			-- Create and Add the Function Declaration
			table.insert(ast.body.statements, 1, Ast.LocalFunctionDeclaration(self.rootScope, self.wrapperId, {
				Ast.VariableExpression(funcScope, arg)
			}, Ast.Block({
				Ast.ReturnStatement({
					Ast.IndexExpression(
						Ast.VariableExpression(self.rootScope, self.arrId),
						addSubArg
					)
				});
			}, funcScope)));

			-- Resulting Code with IndexObfuscation:
			-- function xy(a)
			-- 		return ARR[(a - salt) / 2 + offset]
			-- end
		end,
		-- Rotate Array and Add unrotate code
		function()
			if self.Rotate and #self.constants > 1 then
				local shift = math.random(1, #self.constants - 1);

				rotate(self.constants, -shift);
				self:addRotateCode(ast, shift);
			end
		end,
	});

	for i, f in ipairs(steps) do
		f();
	end

	-- Add the Array Declaration
	table.insert(ast.body.statements, 1, Ast.LocalVariableDeclaration(self.rootScope, {self.arrId}, {self:createArray()}));

	self.rootScope = nil;
	self.arrId     = nil;

	self.constants = nil;
	self.lookup    = nil;
end

return ConstantArray;
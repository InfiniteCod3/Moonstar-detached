-- This Script is Part of the Moonstar Obfuscator by Aurologic
--
-- EncryptStrings.lua
--
-- This Script provides a Simple Obfuscation Step that encrypts strings

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local RandomStrings = require("moonstar.randomStrings")
local Parser = require("moonstar.parser")
local Enums = require("moonstar.enums")
local logger = require("logger")
local visitast = require("moonstar.visitast");
local util     = require("moonstar.util")
local bit      = require("moonstar.bit")
local AstKind = Ast.AstKind;

local EncryptStrings = Step:extend()
EncryptStrings.Description = "This Step will encrypt strings within your Program."
EncryptStrings.Name = "Encrypt Strings"

EncryptStrings.SettingsDescriptor = {
	-- Plan.md enhancements
	Enabled = {
		type = "boolean",
		default = true,
	},
	Mode = {
		type = "enum",
		values = {"light", "standard", "aggressive"},
		default = "standard",
	},
	DecryptorVariant = {
		type = "enum",
		values = {"arith", "table", "vmcall", "mixed", "xor_byte", "polymorphic"},
		default = "arith",
	},
	LayerDepth = {
		type = "number",
		default = 1,
		min = 1,
		max = 5,
	},
	LocalizeDecryptor = {
		type = "boolean",
		default = false,
	},
	InlineThreshold = {
		type = "number",
		default = 0, -- 0 to disable
	},
	EnvironmentCheck = {
		type = "boolean",
		default = false,
	},
}

function EncryptStrings:init(settings) end


function EncryptStrings:CreateEncrypionService(astScope)
	local usedSeeds = {};
	
	-- Adjust encryption complexity based on Mode
	local mode = self.Mode or "standard"
	local keyComplexity = 1
	if mode == "light" then
		keyComplexity = 0.5
	elseif mode == "aggressive" then
		keyComplexity = 2
	end

	-- LCG Parameters (standard constants)
	local lcg_a = 1664525
	local lcg_c = 1013904223
	local lcg_m = 4294967296 -- 2^32

	local secret_key_8 = math.random(0, 255); -- 8-bit  arbitrary integer (0..255)

	local floor = math.floor

	-- Initial seed state
	local current_seed = 0

	local function set_seed(seed)
		current_seed = seed
	end

	local function gen_seed()
		local seed;
		repeat
			seed = math.random(0, 2147483647); -- Ensure positive 32-bit signed range equivalent
		until not usedSeeds[seed];
		usedSeeds[seed] = true;
		return seed;
	end

	local function lcg_next()
		current_seed = (lcg_a * current_seed + lcg_c) % lcg_m
		return current_seed
	end

	local function get_next_pseudo_random_byte()
		-- Use bits 16-23 of the LCG state for better randomness
		local val = lcg_next()
		return floor(val / 65536) % 256
	end
	
	-- XOR byte encryption - returns byte array table
	local function encrypt_xor(str)
		local bit = require("moonstar.bit")
		local bxor = bit.bxor
		
		local seed = gen_seed();
		set_seed(seed)
		local len = string.len(str)
		local out = {}
		
		for i = 1, len do
			local byte = string.byte(str, i);
			local key = get_next_pseudo_random_byte();
			-- XOR encryption: encrypted = plaintext XOR key
			out[i] = bxor(byte, key);
		end
		return out, seed;  -- Return byte array, not string
	end

	-- Polymorphic operations for the polymorphic variant
	local polyChain = {}
	if self.DecryptorVariant == "polymorphic" then
		-- Generate random polymorphic operations (Restricted to ADD/SUB)
		local opTypes = {"ADD", "SUB"}
		local numOps = math.random(2, 4)
		
		for i = 1, numOps do
			local opType = opTypes[math.random(#opTypes)]
			local constant = math.random(1, 255)
			
			local op = {
				type = opType,
				constant = constant,
				-- Encryption function (applied during encryption)
				encrypt = function(byte)
					if opType == "ADD" then
						return (byte + constant) % 256
					elseif opType == "SUB" then
						return (byte - constant) % 256
					end
				end,
				-- Decryption AST generator (generates AST node for decryption)
				decrypt = function(byteExpr, decryptScope)
					if opType == "ADD" then
						return Ast.ModExpression(
							Ast.SubExpression(byteExpr, Ast.NumberExpression(constant)),
							Ast.NumberExpression(256)
						)
					elseif opType == "SUB" then
						return Ast.ModExpression(
							Ast.AddExpression(byteExpr, Ast.NumberExpression(constant)),
							Ast.NumberExpression(256)
						)
					else
						return byteExpr
					end
				end
			}
			table.insert(polyChain, op)
		end
	end

	-- Update encrypt function for polymorphic
	local function encrypt(str)
		local seed = gen_seed();
		set_seed(seed)
		local len = string.len(str)
		local out = {}
		local prevVal = secret_key_8;
		
		if self.DecryptorVariant == "polymorphic" then
			-- Polymorphic encryption: apply chain, then ARITHMETIC mix with prevVal (Replacing XOR)
			for i = 1, len do
				local byte = string.byte(str, i);
				-- Note: Polymorphic variant does NOT use PRNG stream for encryption key
				-- This ensures sync with decryption which also doesn't use PRNG

				-- Apply Arithmetic with prevVal first (Replaces XOR for speed)
				-- Decryption: (encrypted + constant...) - prevVal
				-- Encryption must align with decryption order.
				-- Let's define decryption chain:
				--   val = reverse_poly(encrypted_byte)
				--   original = (val - prevVal) % 256
				--
				-- So encryption:
				--   val = (original + prevVal) % 256
				--   encrypted = forward_poly(val)

				local encrypted = (byte + prevVal) % 256
				
				-- Apply polymorphic chain
				for _, op in ipairs(polyChain) do
					encrypted = op.encrypt(encrypted)
				end
				
				out[i] = encrypted
				prevVal = byte;
			end
			return out, seed;  -- Return byte array for polymorphic
		else
			-- Original arithmetic encryption
			for i = 1, len do
				local byte = string.byte(str, i);
				out[i] = string.char((byte - (get_next_pseudo_random_byte() + prevVal)) % 256);
				prevVal = byte;
			end
			return table.concat(out), seed;
		end
	end

	local function genCode()
		-- Select decryptor variant based on setting
		local variant = self.DecryptorVariant or "arith"
		
		-- Base setup code (common to all variants)
		local code = [[
do
	local floor = math.floor
	local random = math.random;
	local remove = table.remove;
	local char = string.char;
	-- LCG State
	local state = 0
	local charmap = {};
	local i = 0;

	local nums = {};
	for i = 1, 256 do
		nums[i] = i;
	end

	repeat
		local idx = random(1, #nums);
		local n = remove(nums, idx);
		charmap[n] = char(n - 1);
	until #nums == 0;

	local function get_next_pseudo_random_byte()
		state = (1664525 * state + 1013904223) % 4294967296
		return floor(state / 65536) % 256
	end

	local realStrings = {};
	STRINGS = setmetatable({}, {
		__index = realStrings;
		__metatable = nil;
	});
]]

		-- Add environment key if enabled
		if self.EnvironmentCheck then
			code = code .. [[
	-- Environment-dependent key generation
	local function get_env_key()
		local key = 0
		-- Use properties that are stable but environment-specific
		key = key + #tostring(math.sin)
		key = key + #tostring(string.char)
		key = key + #tostring(table.concat)
		return key % 65536
	end
	local env_key = get_env_key()
]]
		end

		-- Add variant-specific decrypt function
		if variant == "table" then
			-- Table-based decryptor variant
			local seedAdjust = self.EnvironmentCheck and "seed + env_key" or "seed"
			code = code .. [[
	function DECRYPT(str, seed)
		local realStringsLocal = realStrings;
		if(realStringsLocal[seed]) then else
			local chars = charmap;
			local adjusted_seed = ]] .. seedAdjust .. [[
			state = adjusted_seed
			local len = string.len(str);
			realStringsLocal[seed] = "";
			local prevVal = ]] .. tostring(secret_key_8) .. [[;
			for i=1, len do
				prevVal = (string.byte(str, i) + get_next_pseudo_random_byte() + prevVal) % 256
				realStringsLocal[seed] = realStringsLocal[seed] .. chars[prevVal + 1];
			end
		end
		return seed;
	end
]]
		elseif variant == "vmcall" then
			-- VM-call style decryptor (wraps logic in function calls)
			local seedAdjust = self.EnvironmentCheck and " + env_key" or ""
			code = code .. [[
	local function initState(seed)
		return seed
	end
	local function decryptByte(b, r, p)
		return (b + r + p) % 256
	end
	function DECRYPT(str, seed)
		local realStringsLocal = realStrings;
		if(realStringsLocal[seed]) then else
			local chars = charmap;
			state = initState(seed]] .. seedAdjust .. [[)
			local len = string.len(str);
			realStringsLocal[seed] = "";
			local prevVal = ]] .. tostring(secret_key_8) .. [[;
			for i=1, len do
				prevVal = decryptByte(string.byte(str, i), get_next_pseudo_random_byte(), prevVal)
				realStringsLocal[seed] = realStringsLocal[seed] .. chars[prevVal + 1];
			end
		end
		return seed;
	end
]]
		elseif variant == "mixed" then
			-- Mixed: combines arithmetic and table lookups
			local seedAdjust = self.EnvironmentCheck and " + env_key" or ""
			code = code .. [[
	local ops = {
		function(a,b,c) return (a + b + c) % 256 end,
		function(a,b,c) return (a - b + c) % 256 end,
	}
	function DECRYPT(str, seed)
		local realStringsLocal = realStrings;
		if(realStringsLocal[seed]) then else
			local chars = charmap;
			local adjusted_seed = seed]] .. seedAdjust .. [[
			state = adjusted_seed
			local len = string.len(str);
			realStringsLocal[seed] = "";
			local prevVal = ]] .. tostring(secret_key_8) .. [[;
			local op = ops[1]
			for i=1, len do
				prevVal = op(string.byte(str, i), get_next_pseudo_random_byte(), prevVal)
				realStringsLocal[seed] = realStringsLocal[seed] .. chars[prevVal + 1];
			end
		end
		return seed;
	end
]]
		elseif variant == "polymorphic" then
			-- Polymorphic Byte Array Decryptor
			local seedAdjust = self.EnvironmentCheck and " + env_key" or ""
			code = code .. [[

	function DECRYPT(bytes, seed)
		local realStringsLocal = realStrings;
		if(realStringsLocal[seed]) then else
			local chars = charmap;

			local result = {}
			local len = #bytes
			local prevVal = ]] .. tostring(secret_key_8) .. [[;

			for i=1, len do
				local b = bytes[i]

				-- Reverse polymorphic operations
]]
			-- Generate the reverse polymorphic operation chain
			for i = #polyChain, 1, -1 do
				local op = polyChain[i]
				if op.type == "ADD" then
					code = code .. "				b = (b - " .. op.constant .. ") % 256\n"
				elseif op.type == "SUB" then
					code = code .. "				b = (b + " .. op.constant .. ") % 256\n"
				end
			end
			
			code = code .. [[
				-- Reverse Arithmetic with prevVal (Replaces XOR)
				local decrypted = (b - prevVal) % 256
				prevVal = decrypted
				table.insert(result, chars[decrypted + 1])
			end
			realStringsLocal[seed] = table.concat(result)
		end
		return seed;
	end
]]
		elseif variant == "xor_byte" then
			-- XOR Byte Array Decryptor
			local seedAdjust = self.EnvironmentCheck and " + env_key" or ""
			code = code .. [[
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

	function DECRYPT(bytes, seed)
		local realStringsLocal = realStrings;
		if(realStringsLocal[seed]) then else
			local chars = charmap;
			local adjusted_seed = seed]] .. seedAdjust .. [[
			state = adjusted_seed

			local result = {}
			local len = #bytes
			local prevVal = ]] .. tostring(secret_key_8) .. [[;

			for i=1, len do
				local b = bytes[i]
				local r = get_next_pseudo_random_byte()

				local decrypted = bxor(b, r)
				table.insert(result, chars[decrypted + 1])
			end
			realStringsLocal[seed] = table.concat(result)
		end
		return seed;
	end
]]
		else  -- "arith" (default)
			-- Arithmetic-based decryptor (original)
			local seedAdjust = self.EnvironmentCheck and " + env_key" or ""
			code = code .. [[
	function DECRYPT(str, seed)
		local realStringsLocal = realStrings;
		if(realStringsLocal[seed]) then else
			local chars = charmap;
			local adjusted_seed = seed]] .. seedAdjust .. [[
			state = adjusted_seed
			local len = string.len(str);
			realStringsLocal[seed] = "";
			local prevVal = ]] .. tostring(secret_key_8) .. [[;
			for i=1, len do
				prevVal = (string.byte(str, i) + get_next_pseudo_random_byte() + prevVal) % 256
				realStringsLocal[seed] = realStringsLocal[seed] .. chars[prevVal + 1];
			end
		end
		return seed;
	end
]]
		end
		
		code = code .. "end"

		return code;
	end

	return {
		encrypt = encrypt,
		encrypt_xor = encrypt_xor,
		secret_key_8 = secret_key_8,
		genCode = genCode,
		polyChain = polyChain,
	}
end

function EncryptStrings:apply(ast, pipeline)
	local Encryptor = self:CreateEncrypionService(ast.body.scope);

	local code = Encryptor.genCode();
	local newAst = Parser:new({ LuaVersion = Enums.LuaVersion.Lua51 }):parse(code);
	local doStat = newAst.body.statements[1];

	local scope = ast.body.scope;
	local decryptVar = scope:addVariable();
	local stringsVar = scope:addVariable();
	
	doStat.body.scope:setParent(ast.body.scope);

	visitast(newAst, nil, function(node, data)
		if(node.kind == AstKind.FunctionDeclaration) then
			if(node.scope:getVariableName(node.id) == "DECRYPT") then
				data.scope:removeReferenceToHigherScope(node.scope, node.id);
				data.scope:addReferenceToHigherScope(scope, decryptVar);
				node.scope = scope;
				node.id    = decryptVar;
			end
		end
		if(node.kind == AstKind.AssignmentVariable or node.kind == AstKind.VariableExpression) then
			if(node.scope:getVariableName(node.id) == "STRINGS") then
				data.scope:removeReferenceToHigherScope(node.scope, node.id);
				data.scope:addReferenceToHigherScope(scope, stringsVar);
				node.scope = scope;
				node.id    = stringsVar;
			end
		end
	end)

	local variant = self.DecryptorVariant or "arith"
	local inlineThreshold = self.InlineThreshold or 0
	
	visitast(ast, nil, function(node, data)
		if(node.kind == AstKind.StringExpression) then
			-- Check if string should be inlined based on threshold
			if inlineThreshold > 0 and #node.value > 0 and #node.value <= inlineThreshold then
				-- Generate inline string construction
				local chars = {}
				for i = 1, #node.value do
					local byte = string.byte(node.value, i)
					-- Add some obfuscation: use expressions instead of plain numbers
					local offset = math.random(1, 100)
					
					-- Get string global reference
					local stringScope, stringId = data.scope:resolveGlobal("string")
					
					local expr = Ast.FunctionCallExpression(
						Ast.IndexExpression(
							Ast.VariableExpression(stringScope, stringId),
							Ast.StringExpression("char")
						),
						{Ast.ModExpression(
							Ast.AddExpression(
								Ast.NumberExpression(byte + offset),
								Ast.NumberExpression(-offset)
							),
							Ast.NumberExpression(256)
						)}
					)
					table.insert(chars, expr)
				end
				
				-- Concatenate all char expressions
				if #chars == 0 then
					return Ast.StringExpression("")
				elseif #chars == 1 then
					return chars[1]
				else
					local result = chars[1]
					for i = 2, #chars do
						result = Ast.StrCatExpression(result, chars[i])
					end
					return result
				end
			end
			
			data.scope:addReferenceToHigherScope(scope, stringsVar);
			data.scope:addReferenceToHigherScope(scope, decryptVar);
			
			if variant == "xor_byte" then
				-- Use XOR byte encryption
				local encrypted_bytes, seed = Encryptor.encrypt_xor(node.value);
				
				-- Create table constructor with byte entries
				local byte_entries = {}
				for i, byte_val in ipairs(encrypted_bytes) do
					table.insert(byte_entries, Ast.TableEntry(Ast.NumberExpression(byte_val)));
				end
				
				return Ast.IndexExpression(Ast.VariableExpression(scope, stringsVar), Ast.FunctionCallExpression(Ast.VariableExpression(scope, decryptVar), {
					Ast.TableConstructorExpression(byte_entries), Ast.NumberExpression(seed),
				}));
			elseif variant == "polymorphic" then
				-- Use polymorphic byte encryption
				local encrypted_bytes, seed = Encryptor.encrypt(node.value);
				
				-- Create table constructor with byte entries
				local byte_entries = {}
				for i, byte_val in ipairs(encrypted_bytes) do
					table.insert(byte_entries, Ast.TableEntry(Ast.NumberExpression(byte_val)));
				end
				
				return Ast.IndexExpression(Ast.VariableExpression(scope, stringsVar), Ast.FunctionCallExpression(Ast.VariableExpression(scope, decryptVar), {
					Ast.TableConstructorExpression(byte_entries), Ast.NumberExpression(seed),
				}));
			else
				-- Use standard string encryption
				local encrypted, seed = Encryptor.encrypt(node.value);
				return Ast.IndexExpression(Ast.VariableExpression(scope, stringsVar), Ast.FunctionCallExpression(Ast.VariableExpression(scope, decryptVar), {
					Ast.StringExpression(encrypted), Ast.NumberExpression(seed),
				}));
			end
		end
	end)


	-- Insert to Main Ast
	table.insert(ast.body.statements, 1, doStat);
	table.insert(ast.body.statements, 1, Ast.LocalVariableDeclaration(scope, util.shuffle{ decryptVar, stringsVar }, {}));
	return ast
end

return EncryptStrings

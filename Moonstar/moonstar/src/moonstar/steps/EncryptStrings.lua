-- This Script is Part of the Prometheus Obfuscator by Levno_710
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

	local secret_key_6 = math.random(0, 63) -- 6-bit  arbitrary integer (0..63)
	local secret_key_7 = math.random(0, 127) -- 7-bit  arbitrary integer (0..127)
	local secret_key_44 = math.random(0, math.floor(17592186044415 * keyComplexity)) -- 44-bit arbitrary integer
	local secret_key_8 = math.random(0, 255); -- 8-bit  arbitrary integer (0..255)

	local floor = math.floor

	local function primitive_root_257(idx)
		local g, m, d = 1, 128, 2 * idx + 1
		repeat
			g, m, d = g * g * (d >= m and 3 or 1) % 257, m / 2, d % m
		until m < 1
		return g
	end

	local param_mul_8 = primitive_root_257(secret_key_7)
	local param_mul_45 = secret_key_6 * 4 + 1
	local param_add_45 = secret_key_44 * 2 + 1

	local state_45 = 0
	local state_8 = 2

	local prev_values = {}
	local function set_seed(seed_53)
		state_45 = seed_53 % 35184372088832
		state_8 = seed_53 % 255 + 2
		prev_values = {}
	end

	local function gen_seed()
		local seed;
		repeat
			seed = math.random(0, 35184372088832);
		until not usedSeeds[seed];
		usedSeeds[seed] = true;
		return seed;
	end

	local function get_random_32()
		state_45 = (state_45 * param_mul_45 + param_add_45) % 35184372088832
		repeat
			state_8 = state_8 * param_mul_8 % 257
		until state_8 ~= 1
		local r = state_8 % 32
		local n = floor(state_45 / 2 ^ (13 - (state_8 - r) / 32)) % 2 ^ 32 / 2 ^ r
		return floor(n % 1 * 2 ^ 32) + floor(n)
	end

	local function get_next_pseudo_random_byte()
		if #prev_values == 0 then
			local rnd = get_random_32() -- value 0..4294967295
			local low_16 = rnd % 65536
			local high_16 = (rnd - low_16) / 65536
			local b1 = low_16 % 256
			local b2 = (low_16 - b1) / 256
			local b3 = high_16 % 256
			local b4 = (high_16 - b3) / 256
			prev_values = { b1, b2, b3, b4 }
		end
		--print(unpack(prev_values))
		return table.remove(prev_values)
	end

	local function encrypt(str)
		local seed = gen_seed();
		set_seed(seed)
		local len = string.len(str)
		local out = {}
		local prevVal = secret_key_8;
		for i = 1, len do
			local byte = string.byte(str, i);
			out[i] = string.char((byte - (get_next_pseudo_random_byte() + prevVal)) % 256);
			prevVal = byte;
		end
		return table.concat(out), seed;
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
		-- Generate random polymorphic operations
		local opTypes = {"ADD", "SUB", "XOR"}
		local numOps = math.random(2, 4)
		
		for i = 1, numOps do
			local opType = opTypes[math.random(#opTypes)]
			local constant = math.random(1, 255)
			
			local op = {
				type = opType,
				constant = constant,
				-- Encryption function (applied during encryption)
				encrypt = function(byte, key)
					if opType == "ADD" then
						return (byte + constant) % 256
					elseif opType == "SUB" then
						return (byte - constant) % 256
					elseif opType == "XOR" then
						return bit.bxor(byte, constant)
					end
				end,
				-- Decryption AST generator (generates AST node for decryption)
				decrypt = function(byteExpr, keyExpr, bxorVarName, decryptScope)
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
					elseif opType == "XOR" then
						-- Use the bxor variable from PRNG code
						return Ast.FunctionCallExpression(
							Ast.VariableExpression(decryptScope, bxorVarName),
							{byteExpr, Ast.NumberExpression(constant)}
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
			-- Polymorphic encryption: apply chain, then XOR with prevVal
			for i = 1, len do
				local byte = string.byte(str, i);
				local key = get_next_pseudo_random_byte();
				
				-- Apply XOR with prevVal first
				local encrypted = bit.bxor(byte, prevVal)
				
				-- Apply polymorphic chain
				for _, op in ipairs(polyChain) do
					encrypted = op.encrypt(encrypted, key)
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
	local state_45 = 0
	local state_8 = 2
	local digits = {}
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

	local prev_values = {}
	local function get_next_pseudo_random_byte()
		if #prev_values == 0 then
			state_45 = (state_45 * ]] .. tostring(param_mul_45) .. [[ + ]] .. tostring(param_add_45) .. [[) % 35184372088832
			repeat
				state_8 = state_8 * ]] .. tostring(param_mul_8) .. [[ % 257
			until state_8 ~= 1
			local r = state_8 % 32
			local n = floor(state_45 / 2 ^ (13 - (state_8 - r) / 32)) % 2 ^ 32 / 2 ^ r
			local rnd = floor(n % 1 * 2 ^ 32) + floor(n)
			local low_16 = rnd % 65536
			local high_16 = (rnd - low_16) / 65536
			local b1 = low_16 % 256
			local b2 = (low_16 - b1) / 256
			local b3 = high_16 % 256
			local b4 = (high_16 - b3) / 256
			prev_values = { b1, b2, b3, b4 }
		end
		return table.remove(prev_values)
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
			prev_values = {};
			local chars = charmap;
			local adjusted_seed = ]] .. seedAdjust .. [[
			local lookup = {adjusted_seed % 35184372088832, adjusted_seed % 255 + 2}
			state_45 = lookup[1]
			state_8 = lookup[2]
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
		return seed % 35184372088832, seed % 255 + 2
	end
	local function decryptByte(b, r, p)
		return (b + r + p) % 256
	end
  	function DECRYPT(str, seed)
		local realStringsLocal = realStrings;
		if(realStringsLocal[seed]) then else
			prev_values = {};
			local chars = charmap;
			state_45, state_8 = initState(seed]] .. seedAdjust .. [[)
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
			prev_values = {};
			local chars = charmap;
			local adjusted_seed = seed]] .. seedAdjust .. [[
			state_45 = adjusted_seed % 35184372088832
			state_8 = adjusted_seed % 255 + 2
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
			-- Similar to xor_byte but with dynamic operation chain
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
            prev_values = {};
            local chars = charmap;
            local adjusted_seed = seed]] .. seedAdjust .. [[
            state_45 = adjusted_seed % 35184372088832
            state_8 = adjusted_seed % 255 + 2
            
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
					code = code .. "                b = (b - " .. op.constant .. ") % 256\n"
				elseif op.type == "SUB" then
					code = code .. "                b = (b + " .. op.constant .. ") % 256\n"
				elseif op.type == "XOR" then
					code = code .. "                b = bxor(b, " .. op.constant .. ")\n"
				end
			end
			
			code = code .. [[
                -- Reverse XOR with prevVal
                local decrypted = bxor(b, prevVal)
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
            -- Expects 'str' to be a table of bytes {b1, b2, ...} not a string
            -- But the current architecture passes a string literal in the AST.
            -- We need to handle the AST transformation separately.
            -- Here we define the runtime decryptor.
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
            prev_values = {};
            local chars = charmap;
            local adjusted_seed = seed]] .. seedAdjust .. [[
            state_45 = adjusted_seed % 35184372088832
            state_8 = adjusted_seed % 255 + 2
            
            local result = {}
            local len = #bytes
            local prevVal = ]] .. tostring(secret_key_8) .. [[;
            
            for i=1, len do
                local b = bytes[i]
                local r = get_next_pseudo_random_byte()
                -- Decrypt: (b XOR r) - prevVal
                -- Note: The encryption must be: (byte + prevVal) XOR r
                -- Let's stick to the requested XOR logic:
                -- "store strings as byte arrays {12, 244, 21...} and use a runtime XOR function to decrypt them"
                -- We will use a simple XOR chain for this variant to match the user request specifically.
                
                -- Revised Logic for XOR variant:
                -- Encrypted = Byte XOR Key
                -- We will use the pseudo-random stream as the key stream.
                
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
			prev_values = {};
			local chars = charmap;
			local adjusted_seed = seed]] .. seedAdjust .. [[
			state_45 = adjusted_seed % 35184372088832
			state_8 = adjusted_seed % 255 + 2
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
        param_mul_45 = param_mul_45,
        param_mul_8 = param_mul_8,
        param_add_45 = param_add_45,
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

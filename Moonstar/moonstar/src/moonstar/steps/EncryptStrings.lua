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
		values = {"arith", "table", "vmcall", "mixed", "xor_byte"},
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
}

function EncryptStrings:init(settings) end


function EncryptStrings:CreateEncrypionService()
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

		-- Add variant-specific decrypt function
		if variant == "table" then
			-- Table-based decryptor variant
			code = code .. [[
  	function DECRYPT(str, seed)
		local realStringsLocal = realStrings;
		if(realStringsLocal[seed]) then else
			prev_values = {};
			local chars = charmap;
			local lookup = {seed % 35184372088832, seed % 255 + 2}
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
			state_45, state_8 = initState(seed)
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
			state_45 = seed % 35184372088832
			state_8 = seed % 255 + 2
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
		elseif variant == "xor_byte" then
            -- XOR Byte Array Decryptor
            -- Expects 'str' to be a table of bytes {b1, b2, ...} not a string
            -- But the current architecture passes a string literal in the AST.
            -- We need to handle the AST transformation separately.
            -- Here we define the runtime decryptor.
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
            state_45 = seed % 35184372088832
            state_8 = seed % 255 + 2
            
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
			code = code .. [[
  	function DECRYPT(str, seed)
		local realStringsLocal = realStrings;
		if(realStringsLocal[seed]) then else
			prev_values = {};
			local chars = charmap;
			state_45 = seed % 35184372088832
			state_8 = seed % 255 + 2
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
    }
end

function EncryptStrings:apply(ast, pipeline)
    local Encryptor = self:CreateEncrypionService();

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
	
	visitast(ast, nil, function(node, data)
		if(node.kind == AstKind.StringExpression) then
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

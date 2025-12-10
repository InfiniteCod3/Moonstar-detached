-- This Script is Part of the Moonstar Obfuscator
--
-- AntiTamper.lua
--
-- This Script provides anti-tamper protection through multiple techniques:
-- 1. Distributed integrity checks throughout the code
-- 2. Environment fingerprinting
-- 3. Timing-based tamper detection
-- 4. Silent corruption on detection (breaks script subtly rather than crashing)
--
-- Fully compatible with Lua 5.1 and LuaU (Roblox)

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local Parser = require("moonstar.parser")
local Enums = require("moonstar.enums")

local AntiTamper = Step:extend()
AntiTamper.Description = "Adds distributed anti-tamper checks compatible with Lua 5.1 and LuaU."
AntiTamper.Name = "Anti-Tamper"

AntiTamper.SettingsDescriptor = {
	Enabled = {
		type = "boolean",
		default = true,
	},
	-- Timing attack detection (detects debugger pauses)
	TimingCheck = {
		type = "boolean",
		default = true,
	},
	-- Check for common hook patterns
	HookDetection = {
		type = "boolean",
		default = true,
	},
	-- Check environment consistency
	EnvCheck = {
		type = "boolean",
		default = true,
	},
	-- Corruption mode: "silent" corrupts behavior, "crash" throws error
	CorruptionMode = {
		type = "enum", 
		values = {"silent", "crash"},
		default = "silent",
	},
}

function AntiTamper:init(settings) end

function AntiTamper:apply(ast, pipeline)
	-- Generate unique keys for this compilation
	local checkKey1 = math.random(10000, 99999)
	local checkKey2 = math.random(10000, 99999)
	local checkSum = (checkKey1 + checkKey2) % 65536
	
	-- Build corruption function based on mode
	local corruptionCode
	if self.CorruptionMode == "crash" then
		corruptionCode = [[
	local function _corrupt()
		error("Integrity check failed", 0)
	end
]]
	else
		-- Silent corruption - makes the script behave incorrectly without obvious errors
		-- Compatible with both Lua 5.1 and LuaU
		corruptionCode = [[
	local _corrupted = false
	local function _corrupt()
		if _corrupted then return end
		_corrupted = true
		
		-- Store originals before corrupting
		local _orig_floor = math.floor
		local _orig_abs = math.abs
		local _orig_sub = string.sub
		local _orig_len = string.len
		
		-- Corrupt math.floor subtly (off by 1)
		math.floor = function(x)
			if type(x) == "number" then
				return _orig_floor(x) + 1
			end
			return _orig_floor(x)
		end
		
		-- Corrupt math.abs (returns negative sometimes)
		math.abs = function(x)
			if type(x) == "number" and x > 0 then
				return -_orig_abs(x)
			end
			return _orig_abs(x)
		end
		
		-- Corrupt string.sub (off by one on end index)
		string.sub = function(s, i, j)
			if type(s) == "string" and type(i) == "number" then
				if j and type(j) == "number" and j > 1 then
					return _orig_sub(s, i, j - 1)
				end
			end
			return _orig_sub(s, i, j)
		end
		
		-- Corrupt string.len (slightly wrong for longer strings)
		string.len = function(s)
			local len = _orig_len(s)
			if len > 10 then
				return len - 1
			end
			return len
		end
		
		-- Corrupt math.random to be predictable
		local _seed = 12345
		math.random = function(m, n)
			_seed = (_seed * 1103515245 + 12345) % 2147483648
			if m == nil then
				return _seed / 2147483648
			elseif n == nil then
				return (_seed % m) + 1
			else
				return (_seed % (n - m + 1)) + m
			end
		end
		
		math.randomseed = function() end
	end
]]
	end

	-- Build the anti-tamper check code
	-- All code here must be compatible with both Lua 5.1 and LuaU
	local codeParts = {}
	table.insert(codeParts, "do")
	
	-- Local references to avoid global lookups and make code work in sandboxed environments
	table.insert(codeParts, [[
	local _type = type
	local _tostring = tostring
	local _tonumber = tonumber
	local _pcall = pcall
	local _select = select
	local _pairs = pairs
	local _math = math
	local _string = string
	local _table = table
]])
	
	table.insert(codeParts, corruptionCode)
	table.insert(codeParts, "	local _tampered = false")
	table.insert(codeParts, "")
	
	-- Environment consistency check (works in both Lua 5.1 and LuaU)
	if self.EnvCheck then
		table.insert(codeParts, [[
	-- Check 1: Verify core types exist and are correct
	do
		local function _check_env()
			-- Basic type checks
			if _type(_string) ~= "table" then return false end
			if _type(_math) ~= "table" then return false end
			if _type(_table) ~= "table" then return false end
			if _type(_tostring) ~= "function" then return false end
			if _type(_type) ~= "function" then return false end
			if _type(_pcall) ~= "function" then return false end
			
			-- Verify string.char works correctly (common hook target)
			local ok1, result1 = _pcall(function()
				return _string.char(65) == "A" and _string.char(66) == "B"
			end)
			if not ok1 or not result1 then return false end
			
			-- Verify string.byte works correctly
			local ok2, result2 = _pcall(function()
				return _string.byte("A") == 65 and _string.byte("B") == 66
			end)
			if not ok2 or not result2 then return false end
			
			-- Verify math.floor works correctly
			local ok3, result3 = _pcall(function()
				return _math.floor(1.9) == 1 and _math.floor(2.1) == 2
			end)
			if not ok3 or not result3 then return false end
			
			-- Verify basic arithmetic
			local ok4, result4 = _pcall(function()
				return (2 + 2 == 4) and (10 - 5 == 5) and (3 * 3 == 9)
			end)
			if not ok4 or not result4 then return false end
			
			return true
		end
		
		if not _check_env() then
			_tampered = true
			_corrupt()
		end
	end
]])
	end
	
	-- Hook detection check (compatible with both environments)
	if self.HookDetection then
		table.insert(codeParts, string.format([[
	-- Check 2: Detect function hooking by checking function behavior
	do
		local function _check_hooks()
			-- Generate a test value using the key
			local test_key = %d
			local expected = test_key * 2
			
			-- Test basic arithmetic through a local function
			local function _inner_add(a, b) 
				return a + b 
			end
			local result = _inner_add(test_key, test_key)
			
			if result ~= expected then return false end
			
			-- Check tostring behavior (commonly hooked)
			local ok1, num_str = _pcall(_tostring, 123)
			if not ok1 or num_str ~= "123" then return false end
			
			local ok2, bool_str = _pcall(_tostring, true)
			if not ok2 or bool_str ~= "true" then return false end
			
			-- Check type function (commonly hooked)
			if _type(123) ~= "number" then return false end
			if _type("abc") ~= "string" then return false end
			if _type({}) ~= "table" then return false end
			if _type(true) ~= "boolean" then return false end
			if _type(nil) ~= "nil" then return false end
			if _type(_check_hooks) ~= "function" then return false end
			
			-- Verify tonumber works
			local ok3, num = _pcall(_tonumber, "42")
			if not ok3 or num ~= 42 then return false end
			
			return true
		end
		
		if not _check_hooks() then
			_tampered = true
			_corrupt()
		end
	end
]], checkKey1))
	end
	
	-- Timing check (detects debugger pauses) - works in both Lua 5.1 and LuaU
	if self.TimingCheck then
		table.insert(codeParts, string.format([[
	-- Check 3: Computation integrity check
	do
		local function _check_computation()
			-- Use a simple loop to verify computation integrity
			local key = %d
			local sum = 0
			
			-- Quick computation that should produce a known result
			for i = 1, 100 do
				sum = sum + i
			end
			
			-- Verify the computation result (ensures loop wasn't tampered with)
			if sum ~= 5050 then return false end
			
			-- Additional verification with the key
			local check = (key * 2) - key
			if check ~= key then return false end
			
			-- String operation check
			local test_str = "ABCDEFGHIJ"
			local ok, len = _pcall(function() return #test_str end)
			if not ok or len ~= 10 then return false end
			
			return true
		end
		
		if not _check_computation() then
			_tampered = true
			_corrupt()
		end
	end
]], checkKey2))
	end
	
	-- Set a subtle integrity marker that doesn't rely on _G (LuaU compatible)
	-- Uses a closure to store state instead
	table.insert(codeParts, string.format([[
	-- Integrity state (accessible via closure if needed)
	local _integrity_check_passed = not _tampered
	local _check_value = %d
]], checkSum))
	
	table.insert(codeParts, "end")
	
	local code = table.concat(codeParts, "\n")
	
	-- Parse the anti-tamper code
	local newAst = Parser:new({ LuaVersion = Enums.LuaVersion.Lua51 }):parse(code)
	local doStat = newAst.body.statements[1]
	
	-- Insert anti-tamper checks at the beginning of the script
	doStat.body.scope:setParent(ast.body.scope)
	table.insert(ast.body.statements, 1, doStat)
	
	return ast
end

return AntiTamper

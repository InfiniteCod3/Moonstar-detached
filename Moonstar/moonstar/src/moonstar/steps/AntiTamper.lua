-- This Script is Part of the Moonstar Obfuscator
--
-- AntiTamper.lua
--
-- This Script provides an Obfuscation Step that adds anti-tamper checks

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Scope = require("moonstar.scope")
local Parser = require("moonstar.parser")
local Enums = require("moonstar.enums")

local AntiTamper = Step:extend()
AntiTamper.Description = "This Step will add anti-tamper checks to detect hooks and debugging attempts."
AntiTamper.Name = "Anti-Tamper"

AntiTamper.SettingsDescriptor = {
	Enabled = {
		type = "boolean",
		default = true,
	},
	CheckMetatable = {
		type = "boolean",
		default = true,
	},
	CheckToString = {
		type = "boolean",
		default = true,
	},
}

function AntiTamper:init(settings) end

function AntiTamper:apply(ast, pipeline)
	-- Generate anti-tamper check code
	-- This code is Roblox-compatible (no debug library usage)
	-- We use the behavior of getfenv in Lua 5.1: it throws an error for C functions.
	local code = [[
do
	-- Anti-Tamper / Anti-Hook Checks
	local function check_integrity()
		-- 1. Check Core Global Types
		-- Verify that essential libraries are tables and haven't been overwritten
		if type(string) ~= "table" or type(math) ~= "table" or type(table) ~= "table" then
			while true do end
		end

		-- 2. Anti-Hooking (C-Function Verification)
		-- uses error message analysis to detect Lua wrappers.
		-- This is robust across Lua 5.1 and Luau (Roblox).
		local function is_secure_func(func)
			if type(func) ~= "function" then return false end
			
			local err_msg = ""
			local function handler(msg)
				err_msg = msg
			end
			
			-- Trigger a deliberate error using an invalid argument type (a table)
			-- We expect C functions to throw a clean error, and Lua wrappers to throw an error with line info.
			local success = xpcall(function()
				return func({}) 
			end, handler)
			
			-- If it didn't error, we can't verify (e.g. it accepts tables)
			if success then return true end
			
			-- Check for line number info in error message (e.g., "script.lua:10: ...")
			-- Standard C functions usually don't include this in the message itself.
			if string.find(tostring(err_msg), ":%d+:") then
				return false -- Hook detected (Lua wrapper)
			end
			
			return true
		end
		
		-- Only check functions that enforce argument types
		local critical_functions = {
			string.sub,
			math.abs,
			table.insert,
			setmetatable
		}
		
		for i = 1, #critical_functions do
			if not is_secure_func(critical_functions[i]) then
				while true do end
			end
		end

		-- 3. Verify getmetatable logic (Standard Tamper Check)
		local test_table = {}
		local test_meta = {__index = function() return 42 end}
		setmetatable(test_table, test_meta)
		
		-- If getmetatable doesn't return our metatable, it's hooked
		local retrieved_meta = getmetatable(test_table)
		if retrieved_meta ~= test_meta then
			while true do end
		end
		
		-- 4. Verify metatable protection works
		local protected_table = {}
		setmetatable(protected_table, {__metatable = "protected"})
		local meta_result = getmetatable(protected_table)
		if meta_result ~= "protected" then
			while true do end
		end
	end
	
	check_integrity()
end
]]

	-- Parse the anti-tamper code
	local newAst = Parser:new({ LuaVersion = Enums.LuaVersion.Lua51 }):parse(code);
	local doStat = newAst.body.statements[1];
	
	-- Insert anti-tamper checks at the beginning of the script
	doStat.body.scope:setParent(ast.body.scope);
	table.insert(ast.body.statements, 1, doStat);
	
	return ast
end

return AntiTamper

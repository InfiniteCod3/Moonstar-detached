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
	local code = [[
do
	-- Anti-Tamper Checks
	local function check_integrity()
		-- Check 1: Verify getmetatable works as expected
		local test_table = {}
		local test_meta = {__index = function() return 42 end}
		setmetatable(test_table, test_meta)
		
		-- If getmetatable doesn't return our metatable, it's hooked
		local retrieved_meta = getmetatable(test_table)
		if retrieved_meta ~= test_meta then
			-- Tampered! Enter infinite loop
			while true do end
		end
		
		-- Check 2: Verify tostring on core functions
		-- tostring on built-in functions should return a consistent format
		local tostring_test = tostring(getmetatable)
		if not tostring_test or tostring_test == "" then
			while true do end
		end
		
		-- Check 3: Verify metatable protection works
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

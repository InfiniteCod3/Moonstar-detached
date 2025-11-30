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
	-- Check if Vmify is active
	local vmifyActive = false
	if pipeline and pipeline.steps then
		for _, step in ipairs(pipeline.steps) do
			if step.Name == "Vmify" or step.Name == "Vmify2" then
				vmifyActive = true
				break
			end
		end
	end

	-- If Vmify is active, we disable runtime checks that rely on standard Lua behavior
	-- which might be emulated differently or broken within the Moonstar VM.
	local checksEnabled = not vmifyActive

	local codeParts = {}
	table.insert(codeParts, "do")
	table.insert(codeParts, "	local function check_integrity()")

	if checksEnabled then
		table.insert(codeParts, [[
		local function punish()
			-- Silent corruption: Break standard library functions subtly
			local _r = math.random
			math.random = function(...) return 0 end
			
			local _ti = table.insert
			table.insert = function(...) end
			
			local _ts = tostring
			tostring = function(...) return "nil" end
			
			local _p = pairs
			pairs = function(...) return function() end end
			
			-- Subtle logic breakage
			getmetatable = function(...) return {} end
			
			-- Corrupt global state if possible
			if _G then
				setmetatable(_G, {
					__index = function() return nil end,
					__newindex = function() end
				})
			end
		end

		-- 1. Check Core Global Types
		if type(string) ~= "table" or type(math) ~= "table" or type(table) ~= "table" then
			punish()
			return
		end

		-- 2. Verify getmetatable logic
		local test_table = {}
		local test_meta = {__index = function() return 42 end}
		setmetatable(test_table, test_meta)
		if getmetatable(test_table) ~= test_meta then
			punish()
			return
		end
		
		-- 3. Verify metatable protection
		local protected_table = {}
		setmetatable(protected_table, {__metatable = "protected"})
		if getmetatable(protected_table) ~= "protected" then
			punish()
			return
		end
]])
	else
		table.insert(codeParts, "		-- Integrity checks disabled for VM compatibility")
	end
	
	table.insert(codeParts, "	end")
	table.insert(codeParts, "	check_integrity()")
	table.insert(codeParts, "end")

	local code = table.concat(codeParts, "\n")

	-- Parse the anti-tamper code
	local newAst = Parser:new({ LuaVersion = Enums.LuaVersion.Lua51 }):parse(code);
	local doStat = newAst.body.statements[1];
	
	-- Insert anti-tamper checks at the beginning of the script
	doStat.body.scope:setParent(ast.body.scope);
	table.insert(ast.body.statements, 1, doStat);
	
	return ast
end

return AntiTamper

-- This Script is Part of the Moonstar Obfuscator
--
-- AntiDebug.lua
--
-- Detects debugging attempts and responds with silent corruption or errors.
-- Compatible with Lua 5.1 and LuaU (Roblox).

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Parser = require("moonstar.parser")
local Enums = require("moonstar.enums")
local logger = require("logger")

local AntiDebug = Step:extend()
AntiDebug.Description = "Detects debugging attempts and responds defensively."
AntiDebug.Name = "Anti-Debug"

AntiDebug.SettingsDescriptor = {
	Enabled = {
		type = "boolean",
		default = true,
	},
	-- Detect debug library usage
	DetectDebugLib = {
		type = "boolean",
		default = true,
	},
	-- Detect function hooking attempts
	DetectHooking = {
		type = "boolean",
		default = true,
	},
	-- Detect execution timing anomalies
	DetectTiming = {
		type = "boolean",
		default = false, -- Disabled by default, can cause false positives
	},
	-- Detect stack inspection
	DetectStackInspection = {
		type = "boolean",
		default = true,
	},
	-- Check interval (every N operations)
	CheckInterval = {
		type = "number",
		default = 100,
		min = 10,
		max = 1000,
	},
	-- Response type: "error", "silent", "corrupt"
	ResponseType = {
		type = "enum",
		values = {"error", "silent", "corrupt"},
		default = "corrupt",
	},
	-- Roblox-specific checks
	RobloxChecks = {
		type = "boolean",
		default = true,
	},
}

function AntiDebug:init(settings)
	-- Generate unique keys for this obfuscation
	self.checkKey = math.random(10000, 99999)
	self.corruptionSeed = math.random(1, 255)
end

function AntiDebug:generateAntiDebugCode()
	local code = [[
do
	local _ad_check_count = 0
	local _ad_interval = ]] .. self.CheckInterval .. [[
	
	local _ad_triggered = false
	local _ad_orig_funcs = {}
	
	-- Store original functions for hook detection
	local _type = type
	local _tostring = tostring
	local _pairs = pairs
	local _pcall = pcall
	local _error = error
	local _setmetatable = setmetatable
	local _getmetatable = getmetatable
	local _rawget = rawget
	local _rawset = rawset
	local _select = select
	local _unpack = unpack or table.unpack
	
	-- Math functions
	local _floor = math.floor
	local _random = math.random
	local _abs = math.abs
	
	-- String functions
	local _len = string.len
	local _sub = string.sub
	local _byte = string.byte
	local _char = string.char
	
	-- Response function
	local function _ad_respond()
		if _ad_triggered then return end
		_ad_triggered = true
]]

	if self.ResponseType == "error" then
		code = code .. [[
		_error("Security violation detected", 0)
]]
	elseif self.ResponseType == "corrupt" then
		code = code .. [[
		-- Silent corruption of key functions
		local _cs = ]] .. self.corruptionSeed .. [[
		
		math.floor = function(x)
			if _type(x) == "number" and _abs(x) > 100 then
				return _floor(x) + (_cs % 3)
			end
			return _floor(x)
		end
		
		math.random = function(a, b)
			local r = _random(a, b)
			if _type(r) == "number" and r > 50 then
				return r - 1
			end
			return r
		end
		
		string.sub = function(s, i, j)
			local result = _sub(s, i, j)
			if _len(result) > 10 and _random() < 0.05 then
				return result .. " "
			end
			return result
		end
		
		table.insert = function(t, ...)
			local args = {...}
			if #args == 1 then
				_rawset(t, #t + 1, args[1])
				if _random() < 0.02 then
					_rawset(t, #t + 1, nil)
				end
			elseif #args == 2 then
				local pos, val = args[1], args[2]
				for i = #t, pos, -1 do
					_rawset(t, i + 1, _rawget(t, i))
				end
				_rawset(t, pos, val)
			end
		end
]]
	else -- silent
		code = code .. [[
		-- Silent mode: do nothing visible but mark as triggered
]]
	end

	code = code .. [[
	end
]]

	-- Debug library detection
	if self.DetectDebugLib then
		code = code .. [[
	
	-- Debug library detection
	local function _ad_check_debug()
		-- Check if debug library exists and is being used
		local d = _rawget(_G, "debug")
		if d then
			-- Check for common debug functions
			if _type(_rawget(d, "getinfo")) == "function" then
				-- debug.getinfo exists - potential debugging
				local info = d.getinfo(1)
				if info and info.what == "C" then
					return true -- Being called from C (debugger)
				end
			end
			if _type(_rawget(d, "sethook")) == "function" then
				-- Check if a hook is set
				local hook = d.gethook and d.gethook()
				if hook then
					return true
				end
			end
			if _type(_rawget(d, "traceback")) == "function" then
				-- Traceback being used could indicate debugging
				-- We don't trigger on existence alone
			end
		end
		return false
	end
]]
	end

	-- Function hooking detection
	if self.DetectHooking then
		code = code .. [[
	
	-- Hooking detection - verify function identity
	local function _ad_check_hooks()
		-- Check if core functions have been replaced
		if _type(print) ~= "function" then return true end
		if _type(tostring) ~= "function" then return true end
		if _type(type) ~= "function" then return true end
		
		-- Check function identity by string representation
		local ts1 = _tostring(math.floor)
		local ts2 = _tostring(math.random)
		local ts3 = _tostring(string.sub)
		
		-- Native functions have specific patterns
		-- If they don't match expected patterns, they may be hooked
		if not ts1:find("builtin") and not ts1:find("native") and not ts1:find("function:") then
			-- Could be hooked, but be careful of false positives
		end
		
		-- Check if pcall behavior is normal
		local ok, err = _pcall(function() _error("test", 0) end)
		if ok then return true end -- pcall should have caught the error
		
		return false
	end
]]
	end

	-- Timing detection
	if self.DetectTiming then
		code = code .. [[
	
	-- Timing anomaly detection
	local _ad_last_time = os.clock and os.clock() or 0
	local _ad_time_threshold = 5 -- seconds
	
	local function _ad_check_timing()
		if not os.clock then return false end
		
		local now = os.clock()
		local diff = now - _ad_last_time
		_ad_last_time = now
		
		-- If too much time passed between checks, likely paused in debugger
		if diff > _ad_time_threshold then
			return true
		end
		
		return false
	end
]]
	end

	-- Stack inspection detection
	if self.DetectStackInspection then
		code = code .. [[
	
	-- Stack inspection detection
	local function _ad_check_stack()
		local d = _rawget(_G, "debug")
		if not d or not d.getinfo then return false end
		
		-- Check call stack depth - excessive depth might indicate injection
		local depth = 0
		while d.getinfo(depth + 1) do
			depth = depth + 1
			if depth > 200 then
				return true -- Unusually deep stack
			end
		end
		
		-- Check for suspicious callers
		for i = 1, _floor(depth / 2) do
			local info = d.getinfo(i)
			if info then
				local src = info.source or ""
				-- Check for debugger-injected code
				if src:find("debugger") or src:find("breakpoint") or src:find("@stdin") then
					return true
				end
			end
		end
		
		return false
	end
]]
	end

	-- Roblox-specific checks
	if self.RobloxChecks then
		code = code .. [[
	
	-- Roblox-specific checks
	local function _ad_check_roblox()
		-- Only run if we're in Roblox
		local game = _rawget(_G, "game")
		if not game then return false end
		
		local ok, result = _pcall(function()
			-- Check for exploit detection
			local rs = game:GetService("RunService")
			
			-- Check if running in Studio (might be legitimate, but flag for awareness)
			if rs:IsStudio() then
				-- Studio mode - could be legitimate development
				-- Don't trigger, but could log
				return false
			end
			
			-- Check for suspicious services that shouldn't exist
			local suspicious = {"HookService", "DebugService", "ExploitService"}
			for _, svc in _pairs(suspicious) do
				local s, _ = _pcall(function() return game:GetService(svc) end)
				if s then
					return true
				end
			end
			
			-- Check for getgenv (exploit environment)
			if _rawget(_G, "getgenv") then
				-- This is an exploit executor function
				-- Could trigger, but many legit scripts run in executors
				-- return true
			end
			
			return false
		end)
		
		return ok and result
	end
]]
	end

	-- Main check function
	code = code .. [[
	
	-- Main anti-debug check
	local function _ad_check()
		_ad_check_count = _ad_check_count + 1
		if _ad_check_count < _ad_interval then
			return
		end
		_ad_check_count = 0
		
		local detected = false
]]

	if self.DetectDebugLib then
		code = code .. [[
		if not detected and _ad_check_debug() then detected = true end
]]
	end

	if self.DetectHooking then
		code = code .. [[
		if not detected and _ad_check_hooks() then detected = true end
]]
	end

	if self.DetectTiming then
		code = code .. [[
		if not detected and _ad_check_timing() then detected = true end
]]
	end

	if self.DetectStackInspection then
		code = code .. [[
		if not detected and _ad_check_stack() then detected = true end
]]
	end

	if self.RobloxChecks then
		code = code .. [[
		if not detected and _ad_check_roblox() then detected = true end
]]
	end

	code = code .. [[
		
		if detected then
			_ad_respond()
		end
	end
	
	-- Expose check function for integration with VM
	_G["_ad_c"] = _ad_check
	
	-- Run initial check
	_ad_check()
end
]]

	return code
end

function AntiDebug:apply(ast, pipeline)
	if not self.Enabled then
		return ast
	end
	
	logger:info("Applying Anti-Debug protection")
	
	local code = self:generateAntiDebugCode()
	
	local parser = Parser:new({ LuaVersion = Enums.LuaVersion.Lua51 })
	local success, newAst = pcall(function()
		return parser:parse(code)
	end)
	
	if not success then
		logger:warn("Anti-Debug: Failed to parse generated code, skipping")
		return ast
	end
	
	local doStat = newAst.body.statements[1]
	doStat.body.scope:setParent(ast.body.scope)
	
	-- Insert at the beginning
	table.insert(ast.body.statements, 1, doStat)
	
	logger:info(string.format("Anti-Debug: Enabled checks - Debug:%s, Hooking:%s, Timing:%s, Stack:%s, Roblox:%s",
		self.DetectDebugLib and "yes" or "no",
		self.DetectHooking and "yes" or "no",
		self.DetectTiming and "yes" or "no",
		self.DetectStackInspection and "yes" or "no",
		self.RobloxChecks and "yes" or "no"
	))
	
	return ast
end

return AntiDebug

-- This Script is Part of the Moonstar Obfuscator
--
-- AntiTamper.lua
--
-- VM-Integrated Anti-Tamper Protection
-- Provides fast checksum-based integrity verification that integrates with the VM
-- Compatible with Lua 5.1 and LuaU (Roblox)

local Step = require("moonstar.step")
local Ast = require("moonstar.ast")
local Parser = require("moonstar.parser")
local Enums = require("moonstar.enums")
local logger = require("logger")

local AntiTamper = Step:extend()
AntiTamper.Description = "VM-integrated anti-tamper with fast checksums and integrity verification."
AntiTamper.Name = "Anti-Tamper"

AntiTamper.SettingsDescriptor = {
	Enabled = {
		type = "boolean",
		default = true,
	},
	-- Checksum verification for bytecode constants
	ChecksumConstants = {
		type = "boolean",
		default = true,
	},
	-- Verify handler dispatch table integrity
	CheckHandlers = {
		type = "boolean",
		default = true,
	},
	-- Runtime environment validation
	EnvironmentCheck = {
		type = "boolean",
		default = true,
	},
	-- Timing-based anti-debug detection
	TimingCheck = {
		type = "boolean",
		default = false, -- Disabled by default (can cause false positives)
	},
	-- Silent corruption vs error on tamper detection
	SilentCorruption = {
		type = "boolean",
		default = true,
	},
}

function AntiTamper:init(settings)
	-- Generate random keys for this obfuscation session
	self.checksumSeed = math.random(1, 2^20)
	self.xorKey = math.random(1, 255)
	self.magicValue = math.random(1000, 9999)
end

-- Fast XOR-based checksum (compatible with Lua 5.1 and LuaU)
-- Uses pure arithmetic to avoid bit library dependency
local function generateChecksumCode(seed, xorKey)
	return string.format([[
local function _cs(s, seed)
	local h = seed or %d
	local len = #s
	for i = 1, len do
		local b = string.byte(s, i)
		h = (h * 31 + b) %% 2147483647
		h = ((h - (h %% 256)) / 256 + h * 256 + %d) %% 2147483647
	end
	return h
end
]], seed, xorKey)
end

-- Environment integrity check (works in both Lua 5.1 and LuaU)
local function generateEnvCheckCode(magicValue)
	return string.format([[
local function _ec()
	local _m = %d
	local _ok = true
	
	-- Check core types exist and are correct
	if type(string) ~= "table" then _ok = false end
	if type(math) ~= "table" then _ok = false end
	if type(table) ~= "table" then _ok = false end
	
	-- Verify string functions haven't been replaced with non-functions
	if type(string.byte) ~= "function" then _ok = false end
	if type(string.char) ~= "function" then _ok = false end
	if type(string.sub) ~= "function" then _ok = false end
	
	-- Verify math functions
	if type(math.floor) ~= "function" then _ok = false end
	if type(math.random) ~= "function" then _ok = false end
	
	-- Verify table functions
	if type(table.insert) ~= "function" then _ok = false end
	if type(table.concat) ~= "function" then _ok = false end
	
	-- Test basic functionality
	local _t1 = string.byte("A")
	local _t2 = string.char(65)
	if _t1 ~= 65 or _t2 ~= "A" then _ok = false end
	
	-- Test math
	local _t3 = math.floor(3.7)
	if _t3 ~= 3 then _ok = false end
	
	-- Return magic value if OK, corrupted value if not
	if _ok then
		return _m
	else
		return _m + 1
	end
end
]], magicValue)
end

-- Silent corruption function
local function generateCorruptionCode()
	return [[
local _corrupted = false
local function _corrupt()
	if _corrupted then return end
	_corrupted = true
	
	-- Silently corrupt key functions
	local _old_floor = math.floor
	math.floor = function(x)
		if type(x) == "number" and x > 100 then
			return _old_floor(x) + 1
		end
		return _old_floor(x)
	end
	
	local _old_random = math.random
	math.random = function(a, b)
		local r = _old_random(a, b)
		if type(r) == "number" and r > 10 then
			return r - 1
		end
		return r
	end
	
	-- Corrupt string operations subtly
	local _old_sub = string.sub
	string.sub = function(s, i, j)
		local result = _old_sub(s, i, j)
		if #result > 20 and math.random() < 0.1 then
			return result .. " "
		end
		return result
	end
end
]]
end

-- Timing check for anti-debug (optional, can cause false positives)
local function generateTimingCheckCode(threshold)
	return string.format([[
local _last_time = os.clock and os.clock() or 0
local function _tc()
	if not os.clock then return true end
	local now = os.clock()
	local diff = now - _last_time
	_last_time = now
	-- If more than %d seconds between checks, likely debugging
	return diff < %d
end
]], threshold, threshold)
end

-- Generate the integrity verification wrapper
local function generateIntegrityWrapper(self)
	local parts = {}
	
	-- Add checksum function
	if self.ChecksumConstants then
		table.insert(parts, generateChecksumCode(self.checksumSeed, self.xorKey))
	end
	
	-- Add environment check
	if self.EnvironmentCheck then
		table.insert(parts, generateEnvCheckCode(self.magicValue))
	end
	
	-- Add corruption function
	if self.SilentCorruption then
		table.insert(parts, generateCorruptionCode())
	end
	
	-- Add timing check
	if self.TimingCheck then
		table.insert(parts, generateTimingCheckCode(5))
	end
	
	-- Main verification function
	local verifyCode = [[
local function _verify()
	local _valid = true
]]
	
	if self.EnvironmentCheck then
		verifyCode = verifyCode .. string.format([[
	if _ec() ~= %d then _valid = false end
]], self.magicValue)
	end
	
	if self.TimingCheck then
		verifyCode = verifyCode .. [[
	if not _tc() then _valid = false end
]]
	end
	
	if self.SilentCorruption then
		verifyCode = verifyCode .. [[
	if not _valid then _corrupt() end
]]
	end
	
	verifyCode = verifyCode .. [[
	return _valid
end
]]
	
	table.insert(parts, verifyCode)
	
	return table.concat(parts, "\n")
end

-- Generate checksum for a string constant
function AntiTamper:computeChecksum(str)
	local h = self.checksumSeed
	for i = 1, #str do
		local b = string.byte(str, i)
		h = (h * 31 + b) % 2147483647
		h = (math.floor(h / 256) + h * 256 + self.xorKey) % 2147483647
	end
	return h
end

-- Store checksums for critical strings
function AntiTamper:collectChecksums(ast)
	local checksums = {}
	local visitast = require("moonstar.visitast")
	local AstKind = Ast.AstKind
	
	visitast(ast, nil, function(node, data)
		if node.kind == AstKind.StringExpression then
			local value = node.value
			if #value >= 4 and #value <= 100 then -- Only checksum medium-length strings
				local cs = self:computeChecksum(value)
				checksums[value] = cs
			end
		end
	end)
	
	return checksums
end

function AntiTamper:apply(ast, pipeline)
	if not self.Enabled then
		return ast
	end
	
	-- Check if Vmify is active - if so, we integrate differently
	local vmifyActive = false
	if pipeline and pipeline.steps then
		for _, step in ipairs(pipeline.steps) do
			if step.Name == "Vmify" or step.Name == "Vmify2" then
				vmifyActive = true
				break
			end
		end
	end
	
	logger:info("Applying Anti-Tamper protection" .. (vmifyActive and " (VM-integrated mode)" or " (standalone mode)"))
	
	-- Collect checksums for verification
	local checksums = self:collectChecksums(ast)
	local checksumCount = 0
	for _ in pairs(checksums) do checksumCount = checksumCount + 1 end
	
	-- Generate the integrity code
	local integrityCode = generateIntegrityWrapper(self)
	
	-- Add checksum verification calls for critical strings
	local checksumVerifyCode = ""
	if self.ChecksumConstants and checksumCount > 0 then
		-- Select a few strings to verify (not all, to keep overhead low)
		local selectedStrings = {}
		local count = 0
		for str, cs in pairs(checksums) do
			if count < 5 then -- Max 5 checksum verifications
				table.insert(selectedStrings, {str = str, checksum = cs})
				count = count + 1
			end
		end
		
		if #selectedStrings > 0 then
			checksumVerifyCode = "local function _cv()\n"
			for _, item in ipairs(selectedStrings) do
				-- Escape the string for embedding in code
				local escaped = string.gsub(item.str, "([\"'\\])", "\\%1")
				escaped = string.gsub(escaped, "\n", "\\n")
				escaped = string.gsub(escaped, "\r", "\\r")
				escaped = string.gsub(escaped, "\t", "\\t")
				
				checksumVerifyCode = checksumVerifyCode .. string.format(
					'\tif _cs("%s", %d) ~= %d then return false end\n',
					escaped, self.checksumSeed, item.checksum
				)
			end
			checksumVerifyCode = checksumVerifyCode .. "\treturn true\nend\n"
		end
	end
	
	-- Build the complete anti-tamper wrapper
	local wrapperCode
	if vmifyActive then
		-- For VM mode: lightweight checks that run before VM dispatch
		wrapperCode = string.format([[
do
%s
%s
	-- Initial verification
	local _init_valid = _verify()
	
	-- Periodic verification counter
	local _check_counter = 0
	local _check_interval = %d
	
	-- Expose verification for VM integration
	_G["_at_v"] = function()
		_check_counter = _check_counter + 1
		if _check_counter >= _check_interval then
			_check_counter = 0
			_verify()
		end
		return true
	end
end
]], integrityCode, checksumVerifyCode, math.random(50, 200))
	else
		-- For non-VM mode: wrap entire execution
		wrapperCode = string.format([[
do
%s
%s
	-- Run verification
	_verify()
	%s
end
]], integrityCode, checksumVerifyCode,
	checksumCount > 0 and "if _cv then _cv() end" or "")
	end
	
	-- Parse and inject
	local parser = Parser:new({ LuaVersion = Enums.LuaVersion.Lua51 })
	local success, newAst = pcall(function()
		return parser:parse(wrapperCode)
	end)
	
	if not success then
		logger:warn("Anti-Tamper: Failed to parse generated code, skipping")
		return ast
	end
	
	local doStat = newAst.body.statements[1]
	
	-- Set parent scope
	doStat.body.scope:setParent(ast.body.scope)
	
	-- Insert at the beginning of the script
	table.insert(ast.body.statements, 1, doStat)
	
	logger:info(string.format("Anti-Tamper: Added %d checksum verifications, environment check: %s, timing check: %s",
		checksumCount > 5 and 5 or checksumCount,
		self.EnvironmentCheck and "yes" or "no",
		self.TimingCheck and "yes" or "no"))
	
	return ast
end

return AntiTamper

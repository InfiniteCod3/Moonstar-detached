-- This Script is Part of the Moonstar Obfuscator by Aurologic
--
-- logger.lua

local logger = {}
local config = require("config");
local colors = require("colors");

logger.LogLevel = {
	Error = 0,
	Warn = 1,
	Log = 2,
	Info = 2,
	Debug = 3,
	Trace = 4, -- Even more verbose for deep debugging
}

logger.logLevel = logger.LogLevel.Log;

-- Debug mode flag for enhanced formatting
logger.debugMode = false;

-- Get timestamp for debug mode
local function getTimestamp()
	if logger.debugMode then
		return string.format("[%s] ", os.date("%H:%M:%S"))
	end
	return ""
end

-- Trace level (most verbose)
logger.traceCallback = function(...)
	local timestamp = getTimestamp()
	print(colors(timestamp .. config.NameUpper .. " [TRACE]: " .. ..., "cyan"));
end;
function logger:trace(...)
	if self.logLevel >= self.LogLevel.Trace then
		self.traceCallback(...);
	end
end

-- Debug level
logger.debugCallback = function(...)
	local timestamp = getTimestamp()
	if logger.debugMode then
		print(colors(timestamp .. config.NameUpper .. " [DEBUG]: " .. ..., "grey"));
	else
		print(colors(config.NameUpper .. ": " .. ..., "grey"));
	end
end;
function logger:debug(...)
	if self.logLevel >= self.LogLevel.Debug then
		self.debugCallback(...);
	end
end

-- Info/Log level
logger.logCallback = function(...)
	local timestamp = getTimestamp()
	if logger.debugMode then
		print(colors(timestamp .. config.NameUpper .. " [INFO]: ", "magenta") .. ...);
	else
		print(colors(config.NameUpper .. ": ", "magenta") .. ...);
	end
end;
function logger:log(...)
	if self.logLevel >= self.LogLevel.Log then
		self.logCallback(...);
	end
end

function logger:info(...)
	if self.logLevel >= self.LogLevel.Log then
		self.logCallback(...);
	end
end

-- Warning level
logger.warnCallback = function(...)
	local timestamp = getTimestamp()
	if logger.debugMode then
		print(colors(timestamp .. config.NameUpper .. " [WARN]: " .. ..., "yellow"));
	else
		print(colors(config.NameUpper .. ": " .. ..., "yellow"));
	end
end;
function logger:warn(...)
	if self.logLevel >= self.LogLevel.Warn then
		self.warnCallback(...);
	end
end

-- Error level
logger.errorCallback = function(...)
	local timestamp = getTimestamp()
	if logger.debugMode then
		print(colors(timestamp .. config.NameUpper .. " [ERROR]: " .. ..., "red"))
	else
		print(colors(config.NameUpper .. ": " .. ..., "red"))
	end
	error(...);
end;
function logger:error(...)
	self.errorCallback(...);
	error(config.NameUpper .. ": logger.errorCallback did not throw an Error!");
end

-- Helper to enable debug mode (called from pipeline/main)
function logger:enableDebugMode()
	self.debugMode = true
	self.logLevel = self.LogLevel.Debug
end


return logger;
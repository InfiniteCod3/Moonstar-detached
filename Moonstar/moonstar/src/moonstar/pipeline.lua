-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- pipeline.lua
--
-- This Script Provides a Configurable Obfuscation Pipeline that can obfuscate code using different Modules
-- These Modules can simply be added to the pipeline

local config = require("config");
local Ast    = require("moonstar.ast");
local Enums  = require("moonstar.enums");
local util = require("moonstar.util");
local Parser = require("moonstar.parser");
local Unparser = require("moonstar.unparser");
local logger = require("logger");

local NameGenerators = require("moonstar.namegenerators");

local Steps = require("moonstar.steps");

local lookupify = util.lookupify;
local LuaVersion = Enums.LuaVersion;
local AstKind = Ast.AstKind;

-- On Windows os.clock can be used. On other Systems os.time must be used for benchmarking
local isWindows = package and package.config and type(package.config) == "string" and package.config:sub(1,1) == "\\";
local function gettime()
	if isWindows then
		return os.clock();
	else
		return os.time();
	end
end

local Pipeline = {
	NameGenerators = NameGenerators;
	Steps = Steps;
	DefaultSettings = {
		LuaVersion = LuaVersion.LuaU; -- The Lua Version to use for the Tokenizer, Parser and Unparser
		PrettyPrint = false; -- Note that Pretty Print is currently not producing Pretty results
		Seed = 0; -- The Seed. 0 or below uses the current time as a seed
		VarNamePrefix = ""; -- The Prefix that every variable will start with
	}
}


function Pipeline:new(settings)
	local luaVersion = settings.luaVersion or settings.LuaVersion or Pipeline.DefaultSettings.LuaVersion;
	local conventions = Enums.Conventions[luaVersion];
	if(not conventions) then
		logger:error("The Lua Version \"" .. luaVersion 
			.. "\" is not recognised by the Tokenizer! Please use one of the following: \"" .. table.concat(util.keys(Enums.Conventions), "\",\"") .. "\"");
	end
	
	local prettyPrint = settings.PrettyPrint or Pipeline.DefaultSettings.PrettyPrint;
	local prefix = settings.VarNamePrefix or Pipeline.DefaultSettings.VarNamePrefix;
	local seed = settings.Seed or 0;
	
	local pipeline = {
		LuaVersion = luaVersion;
		PrettyPrint = prettyPrint;
		VarNamePrefix = prefix;
		Seed = seed;
		parser = Parser:new({
			LuaVersion = luaVersion;
		});
		unparser = Unparser:new({
			LuaVersion = luaVersion;
			PrettyPrint = prettyPrint;
			Highlight = settings.Highlight;
		});
		namegenerator = Pipeline.NameGenerators.MangledShuffled;
		conventions = conventions;
		steps = {};
	}
	
	setmetatable(pipeline, self);
	self.__index = self;
	
	return pipeline;
end

-- Canonical ordered pipeline construction following plan.md.
-- Supports:
--  - New config schema: per-step tables, e.g. config.EncryptStrings = { Enabled = true, ... }
--  - Legacy schema: config.Steps = { { Name = "EncryptStrings", Settings = {...} }, ... }
--    This is mapped into the new schema with a deprecation warning.
--
-- Rules:
--  - Steps are instantiated in a fixed global order.
--  - Inclusion is driven by StepConfig.Enabled flags (or defaults), not by arbitrary arrays.
--  - No dynamic reordering beyond this deterministic template.
local CANONICAL_ORDER = {
	"WrapInFunction",
	"EncryptStrings",
	"SplitStrings",
	"ConstantArray",
	"LayeredStringDecrypt",
	"NumbersToExpressions",
	"ProxifyLocals",
	"AddVararg",
	"ControlFlowRestructuring",
	"OpaquePredicates",
	"StructuredJunk",
	"Vmify",
	"VmProfileRandomizer",
	"StagedConstantDecode",
	"PolymorphicLayout",
	"LocalLifetimeSplitting",
};

-- Default enablement for steps when using the canonical schema (may be refined by presets).
-- These defaults are intentionally conservative; presets should override explicitly.
local DEFAULT_ENABLED = {
	WrapInFunction           = false,
	EncryptStrings           = false,
	SplitStrings             = false,
	ConstantArray            = false,
	LayeredStringDecrypt     = false,
	NumbersToExpressions     = false,
	ProxifyLocals            = false,
	AddVararg                = false,
	ControlFlowRestructuring = false,
	OpaquePredicates         = false,
	StructuredJunk           = false,
	Vmify                    = false,
	VmProfileRandomizer      = false,
	StagedConstantDecode     = false,
	PolymorphicLayout        = false,
	LocalLifetimeSplitting   = false,
};

-- Merge legacy config.Steps into per-step config tables.
local function normalizeLegacyStepsConfig(config)
	local steps = config.Steps;
	if type(steps) ~= "table" or #steps == 0 then
		return;
	end

	logger:warn("[moonstar.pipeline] Detected legacy config.Steps usage. This is deprecated; please migrate to per-step config tables.");

	for _, entry in ipairs(steps) do
		if type(entry) == "table" and type(entry.Name) == "string" then
			local name = entry.Name;
			local settings = entry.Settings or {};
			local stepCfg = config[name];

			if type(stepCfg) ~= "table" then
				stepCfg = {};
				config[name] = stepCfg;
			end

			-- Legacy semantics: presence in Steps list means enabled.
			if stepCfg.Enabled == nil and stepCfg.enabled == nil then
				stepCfg.Enabled = true;
			end

			-- Shallow-merge legacy Settings into stepCfg if not already set.
			for k, v in pairs(settings) do
				if stepCfg[k] == nil then
					stepCfg[k] = v;
				end
			end
		end
	end
end

local function isStepEnabled(stepName, stepCfg)
	-- Prefer explicit Enabled if present.
	if stepCfg.Enabled ~= nil then
		return not not stepCfg.Enabled;
	end
	-- Support legacy "enabled" boolean for a transition period.
	if stepCfg.enabled ~= nil then
		return not not stepCfg.enabled;
	end
	-- Fall back to default table.
	return not not DEFAULT_ENABLED[stepName];
end

function Pipeline:fromConfig(config)
	config = config or {};

	-- Normalize legacy style config.Steps into the new schema.
	if type(config.Steps) == "table" and #config.Steps > 0 then
		normalizeLegacyStepsConfig(config);
	end

	local pipeline = Pipeline:new({
		LuaVersion    = config.LuaVersion or LuaVersion.Lua51;
		PrettyPrint   = config.PrettyPrint or false;
		VarNamePrefix = config.VarNamePrefix or "";
		Seed          = config.Seed or 0;
	});

	pipeline:setNameGenerator(config.NameGenerator or "MangledShuffled");

	-- Deterministic, canonical ordered construction.
	for _, stepName in ipairs(CANONICAL_ORDER) do
		local constructor = pipeline.Steps[stepName];
		if constructor then
			local stepCfg = config[stepName];
			if type(stepCfg) ~= "table" then
				stepCfg = {};
			end

			if isStepEnabled(stepName, stepCfg) then
				pipeline:addStep(constructor:new(stepCfg));
			end
		end
	end

	return pipeline;
end

function Pipeline:addStep(step)
	table.insert(self.steps, step);
end

function Pipeline:resetSteps(step)
	self.steps = {};
end

function Pipeline:getSteps()
	return self.steps;
end

function Pipeline:setOption(name, value)
	assert(false, "TODO");
	if(Pipeline.DefaultSettings[name] ~= nil) then
		
	else
		logger:error(string.format("\"%s\" is not a valid setting"));
	end
end

function Pipeline:setLuaVersion(luaVersion)
	local conventions = Enums.Conventions[luaVersion];
	if(not conventions) then
		logger:error("The Lua Version \"" .. luaVersion 
			.. "\" is not recognised by the Tokenizer! Please use one of the following: \"" .. table.concat(util.keys(Enums.Conventions), "\",\"") .. "\"");
	end
	
	self.parser = Parser:new({
		luaVersion = luaVersion;
	});
	self.unparser = Unparser:new({
		luaVersion = luaVersion;
	});
	self.conventions = conventions;
end

function Pipeline:getLuaVersion()
	return self.luaVersion;
end

function Pipeline:setNameGenerator(nameGenerator)
	if(type(nameGenerator) == "string") then
		nameGenerator = Pipeline.NameGenerators[nameGenerator];
	end
	
	if(type(nameGenerator) == "function" or type(nameGenerator) == "table") then
		self.namegenerator = nameGenerator;
		return;
	else
		logger:error("The Argument to Pipeline:setNameGenerator must be a valid NameGenerator function or function name e.g: \"mangled\"")
	end
end

function Pipeline:apply(code, filename)
	local startTime = gettime();
	filename = filename or "Anonymus Script";
	logger:info(string.format("Applying Obfuscation Pipeline to %s ...", filename));
	-- Seed the Random Generator
	if(self.Seed > 0) then
		math.randomseed(self.Seed);
	else
		math.randomseed(os.time())
	end
	
	logger:info("Parsing ...");
	local parserStartTime = gettime();

	local sourceLen = string.len(code);
	local ast = self.parser:parse(code);

	local parserTimeDiff = gettime() - parserStartTime;
	logger:info(string.format("Parsing Done in %.2f seconds", parserTimeDiff));
	
	-- User Defined Steps
	for i, step in ipairs(self.steps) do
		local stepStartTime = gettime();
		logger:info(string.format("Applying Step \"%s\" ...", step.Name or "Unnamed"));
		local newAst = step:apply(ast, self);
		if type(newAst) == "table" then
			ast = newAst;
		end
		logger:info(string.format("Step \"%s\" Done in %.2f seconds", step.Name or "Unnamed", gettime() - stepStartTime));
	end
	
	-- Rename Variables Step
    local f = io.open("debug_pipeline.txt", "a")
    if f then
        f:write("Before Renaming:\n")
        f:write("ast.body.scope: " .. tostring(ast.body.scope) .. "\n")
        f:write("Metatable: " .. tostring(getmetatable(ast.body.scope)) .. "\n")
        f:close()
    end

	self:renameVariables(ast);

    f = io.open("debug_pipeline.txt", "a")
    if f then
        f:write("After Renaming:\n")
        f:write("ast.body.scope: " .. tostring(ast.body.scope) .. "\n")
        f:write("Metatable: " .. tostring(getmetatable(ast.body.scope)) .. "\n")
        f:close()
    end
	
	code = self:unparse(ast);
	
	local timeDiff = gettime() - startTime;
	logger:info(string.format("Obfuscation Done in %.2f seconds", timeDiff));
	
	logger:info(string.format("Generated Code size is %.2f%% of the Source Code size", (string.len(code) / sourceLen)*100))
	
	return code;
end

function Pipeline:unparse(ast)
	local startTime = gettime();
	logger:info("Generating Code ...");
	
	local unparsed = self.unparser:unparse(ast);
	
	local timeDiff = gettime() - startTime;
	logger:info(string.format("Code Generation Done in %.2f seconds", timeDiff));
	
	return unparsed;
end

function Pipeline:renameVariables(ast)
	local startTime = gettime();
	logger:info("Renaming Variables ...");
	
	
	local generatorFunction = self.namegenerator or Pipeline.NameGenerators.mangled;
	if(type(generatorFunction) == "table") then
		if (type(generatorFunction.prepare) == "function") then
			generatorFunction.prepare(ast);
		end
		generatorFunction = generatorFunction.generateName;
	end
	
	if not self.unparser:isValidIdentifier(self.VarNamePrefix) and #self.VarNamePrefix ~= 0 then
		logger:error(string.format("The Prefix \"%s\" is not a valid Identifier in %s", self.VarNamePrefix, self.LuaVersion));
	end

	local globalScope = ast.globalScope;
	globalScope:renameVariables({
		Keywords = self.conventions.Keywords;
		generateName = generatorFunction;
		prefix = self.VarNamePrefix;
	});
	
	local timeDiff = gettime() - startTime;
	logger:info(string.format("Renaming Done in %.2f seconds", timeDiff));
end




return Pipeline;

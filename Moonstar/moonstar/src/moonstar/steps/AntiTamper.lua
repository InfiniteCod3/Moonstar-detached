-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- AntiTamper.lua
--
-- This Script provides an Obfuscation Step, that breaks the script, when someone tries to tamper with it.

local Step = require("moonstar.step");
local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local RandomStrings = require("moonstar.randomStrings")
local Parser = require("moonstar.parser");
local Enums = require("moonstar.enums");
local logger = require("logger");

local AntiTamper = Step:extend();
AntiTamper.Description = "This Step Breaks your Script when it is modified. This is only effective when using the new VM.";
AntiTamper.Name = "Anti Tamper";

AntiTamper.SettingsDescriptor = {
    UseDebug = {
        type = "boolean",
        default = true,
        description = "Use debug library. (Recommended, however scripts will not work without debug library.)"
    },
	-- Plan.md enhancements
	Enabled = {
		type = "boolean",
		default = true,
	},
	Scope = {
		type = "enum",
		values = {"vm_only", "all_critical"},
		default = "vm_only",
	},
	ChecksumVariant = {
		type = "enum",
		values = {"simple", "robust", "mixed"},
		default = "simple",
	},
}

function AntiTamper:init(settings)
	
end

function AntiTamper:apply(ast, pipeline)
    if pipeline.PrettyPrint then
        logger:warn(string.format("\"%s\" cannot be used with PrettyPrint, ignoring \"%s\"", self.Name, self.Name));
        return ast;
    end
	local code = [[do local valid = true;
    -- Store references to original functions before any user code can tamper with them
    -- This prevents metatable spoofing vulnerabilities (Issue #186)
    local _pcall = pcall;
    local _type = type;
    local _tostring = tostring;
    local _getmetatable = getmetatable;
    local _rawget = rawget;
    
    -- Detect environment (Roblox/LuaU vs standard Lua)
    -- LuaU/Roblox has limited/no debug library access (Issue #163)
    -- Check not just if debug exists, but if critical debug functions are available
    local isLuaU = (_G.game ~= nil and _G.workspace ~= nil) or _G.task ~= nil;
    local hasDebug = debug ~= nil and not isLuaU and debug.getinfo ~= nil and debug.sethook ~= nil;
]];
    if self.UseDebug then
        local string = RandomStrings.randomString();
        code = code .. [[
            -- Debug-based anti-tamper checks (only for standard Lua with debug library)
            if hasDebug then
			local sethook = debug.sethook;
			local allowedLine = nil;
			local called = 0;
			sethook(function(s, line)
				if not line then
					return
				end
				called = called + 1;
				if allowedLine then
					if allowedLine ~= line then
						sethook(error, "l", 5);
					end
				else
					allowedLine = line;
				end
			end, "l", 5);
			(function() end)();
			(function() end)();
			sethook();
			if called < 2 then
				valid = false;
			end

            -- Anti Function Hook
            local funcs = {_pcall, string.char, debug.getinfo, string.dump}
            for i = 1, #funcs do
                if debug.getinfo(funcs[i]).what ~= "C" then
                    valid = false;
                end

                if debug.getlocal(funcs[i], 1) then
                    valid = false;
                end

                if debug.getupvalue(funcs[i], 1) then
                    valid = false;
                end

                if _pcall(string.dump, funcs[i]) then
                    valid = false;
                end
            end

            -- Anti Beautify
            local function getTraceback()
                local str = (function(arg)
                    return debug.traceback(arg)
                end)("]] .. string .. [[");
                return str;
            end
    
            local traceback = getTraceback();
            valid = valid and traceback:sub(1, traceback:find("\n") - 1) == "]] .. string .. [[";
            local iter = traceback:gmatch(":(%d*):");
            local v, c = iter(), 1;
            for i in iter do
                valid = valid and i == v;
                c = c + 1;
            end
            valid = valid and c >= 2;
            end -- end hasDebug
        ]]
    end
    code = code .. [[
    local gmatch = string.gmatch;
    local err = function() error("Tamper Detected!") end;

    -- Validate pcall integrity using stored reference (prevents metatable spoofing)
    local pcallIntact2 = false;
    local pcallIntact = _pcall(function()
        pcallIntact2 = true;
    end) and pcallIntact2;

    local random = math.random;
    local tblconcat = table.concat;
    local unpkg = table and table.unpack or unpack;
    local n = random(3, 65);
    local acc1 = 0;
    local acc2 = 0;
    
    -- Get initial error message for validation
    -- Use stored _pcall to prevent tampering
    local pcallRet = {_pcall(function() local a = ]] .. tostring(math.random(1, 2^24)) .. [[ - "]] .. RandomStrings.randomString() .. [[" ^ ]] .. tostring(math.random(1, 2^24)) .. [[ return "]] .. RandomStrings.randomString() .. [[" / a; end)};
    local origMsg = pcallRet[2];
    
    -- CRITICAL: Validate that error message is a string, not a spoofed table with __tostring
    -- This prevents the metatable spoofing vulnerability (Issue #186)
    if _type(origMsg) ~= "string" then
        valid = false;
    end
    
    local line = nil;
    if valid and origMsg then
        line = tonumber(gmatch(_tostring(origMsg), ':(%d*):')());
    end
    
    for i = 1, n do
        local len = math.random(1, 100);
        local n2 = random(0, 255);
        local pos = random(1, len);
        local shouldErr = random(1, 2) == 1;
        local msg = origMsg and origMsg:gsub(':(%d*):', ':' .. tostring(random(0, 10000)) .. ':') or "";
        local arr = {_pcall(function()
            if random(1, 2) == 1 or i == n then
                local errRet = {_pcall(function() local a = ]] .. tostring(math.random(1, 2^24)) .. [[ - "]] .. RandomStrings.randomString() .. [[" ^ ]] .. tostring(math.random(1, 2^24)) .. [[ return "]] .. RandomStrings.randomString() .. [[" / a; end)};
                local errMsg = errRet[2];
                -- Validate error message type to prevent spoofing
                if _type(errMsg) == "string" then
                    local line2 = tonumber(gmatch(_tostring(errMsg), ':(%d*):')());
                    valid = valid and line == line2;
                end
            end
            if shouldErr then
                error(msg, 0);
            end
            local arr = {};
            for i = 1, len do
                arr[i] = random(0, 255);
            end
            arr[pos] = n2;
            return unpkg(arr);
        end)};
        if shouldErr then
            -- Validate error message is a string before comparing
            valid = valid and arr[1] == false and _type(arr[2]) == "string" and arr[2] == msg;
        else
            valid = valid and arr[1];
            acc1 = (acc1 + arr[pos + 1]) % 256;
            acc2 = (acc2 + n2) % 256;
        end
    end
    valid = valid and acc1 == acc2;

    if valid then else
        repeat 
            return (function()
                while true do
                    l1, l2 = l2, l1;
                    err();
                end
            end)(); 
        until true;
        while true do
            l2 = random(1, 6);
            if l2 > 2 then
                l2 = tostring(l1);
            else
                l1 = l2;
            end
        end
        return;
    end
end

    -- Anti Function Arg Hook
    local obj = setmetatable({}, {
        __tostring = err,
    });
    obj[math.random(1, 100)] = obj;
    (function() end)(obj);

    repeat until valid;
    ]]
    
    -- Add integration with IntegrityMesh if available
    if pipeline and pipeline.integrityChecks and #pipeline.integrityChecks > 0 then
        -- Only add checks based on Scope setting
        if self.Scope == "all_critical" then
            code = code .. "\n    -- Integrity checks from IntegrityMesh\n"
            for _, checkName in ipairs(pipeline.integrityChecks) do
                code = code .. "    if " .. checkName .. " then " .. checkName .. "() end\n"
            end
        elseif self.Scope == "vm_only" and pipeline.vmIntegrityChecks then
            code = code .. "\n    -- VM integrity checks\n"
            for _, checkName in ipairs(pipeline.vmIntegrityChecks) do
                code = code .. "    if " .. checkName .. " then " .. checkName .. "() end\n"
            end
        end
    end

    local parsed = Parser:new({LuaVersion = Enums.LuaVersion.Lua51}):parse(code);
    local doStat = parsed.body.statements[1];
    doStat.body.scope:setParent(ast.body.scope);
    table.insert(ast.body.statements, 1, doStat);

    return ast;
end

return AntiTamper;

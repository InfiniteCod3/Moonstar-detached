-- This Script is Part of the Moonstar Obfuscator
--
-- moonstar.lua
-- This file is the entrypoint for Moonstar

-- Configure package.path for require
local function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*[/%\\])")
end

local oldPkgPath = package.path;
package.path = script_path() .. "?.lua;" .. package.path;

-- Math.random Fix for Lua5.1
-- Check if fix is needed
if not pcall(function()
    return math.random(1, 2^40);
end) then
    local oldMathRandom = math.random;
    math.random = function(a, b)
        if not a and b then
            return oldMathRandom();
        end
        if not b then
            return math.random(1, a);
        end
        if a > b then
            a, b = b, a;
        end
        local diff = b - a;
        
        -- Better error message for debugging
        if diff < 0 then
            error(string.format("Invalid interval: a=%s, b=%s, diff=%s", tostring(a), tostring(b), tostring(diff)))
        end
        
        -- Handle empty interval (a == b)
        if diff == 0 then
            return a;
        end
        -- Use manual calculation for large ranges OR negative numbers OR if b exceeds 2^31-1
        -- Native Lua 5.1 math.random doesn't support negative numbers or values >= 2^31
        if diff > 2 ^ 31 - 1 or a < 0 or b >= 2^31 then
            return math.floor(oldMathRandom() * diff + a);
        else
            -- Ensure integers for oldMathRandom
            local ia = math.floor(a + 0.5);
            local ib = math.floor(b + 0.5);
            -- Re-check after rounding
            if ia > ib then
                ia, ib = ib, ia;
            end
            if ia == ib then
                return ia;
            end
            return oldMathRandom(ia, ib);
        end
    end
end

-- newproxy polyfill
_G.newproxy = _G.newproxy or function(arg)
    if arg then
        return setmetatable({}, {});
    end
    return {};
end


-- Require Prometheus Submodules
local Pipeline  = require("moonstar.pipeline");
local highlight = require("highlightlua");
local colors    = require("colors");
local Logger    = require("logger");
local Config    = require("config");
local util      = require("moonstar.util");

-- Canonical preset configs for the new pipeline schema.
-- Each preset:
--  - Uses per-step config tables (StepName = { Enabled = bool, ... }).
--  - Relies on Pipeline:fromConfig canonical ordering.
--  - Avoids custom Steps arrays; legacy callers may still pass Steps and will be normalized.
local Presets   = {
    ["Minify"] = {
        LuaVersion    = "Lua51";
        VarNamePrefix = "";
        NameGenerator = "MangledShuffled";
        PrettyPrint   = false;
        Seed          = 0;

        WrapInFunction = {
            Enabled = false; -- Can be toggled by user for module-style wrapping.
        };

        -- All obfuscation/defensive features disabled by default.
    };

    ["Weak"] = {
        LuaVersion    = "Lua51";
        VarNamePrefix = "";
        NameGenerator = "MangledShuffled";
        PrettyPrint   = false;
        Seed          = 0;

        WrapInFunction = {
            Enabled = true;
        };

        EncryptStrings = {
            Enabled = true;
            Mode = "light";
        };

        SplitStrings = {
            Enabled = true;
            MaxSegmentLength = 16;
            Strategy = "random";
        };

        ConstantArray = {
            Enabled = true;
            EncodeStrings = true;
            IndexObfuscation = false;
        };

        NumbersToExpressions = {
            Enabled = true;
            Complexity = "low";
        };
    };

    ["Medium"] = {
        LuaVersion    = "Lua51";
        VarNamePrefix = "";
        NameGenerator = "MangledShuffled";
        PrettyPrint   = false;
        Seed          = 0;

        WrapInFunction = { Enabled = true };

        EncryptStrings = {
            Enabled = true;
            Mode = "standard";
        };

        SplitStrings = {
            Enabled = true;
            MaxSegmentLength = 16;
            Strategy = "random";
        };

        ConstantArray = {
            Enabled = true;
            EncodeStrings = true;
            IndexObfuscation = true;
        };

        NumbersToExpressions = {
            Enabled = true;
            Complexity = "low";
        };

        AddVararg = {
            Enabled = true;
            Probability = 0.15;
        };
    };

    ["Strong"] = {
        LuaVersion    = "Lua51";
        VarNamePrefix = "";
        NameGenerator = "MangledShuffled";
        PrettyPrint   = false;
        Seed          = 0;
        
        GlobalVirtualization = {
            Enabled = true;
            VirtualizeEnv = true;
        };

        WrapInFunction = { Enabled = true };

        ConstantFolding = {
            Enabled = true;
        };
        
        JitStringDecryptor = {
            Enabled = false;
            MaxLength = 30;
        };

        EncryptStrings = {
            Enabled = true;
            Mode = "standard";
            DecryptorVariant = "polymorphic";
            LayerDepth = 1;
            InlineThreshold = 16;
            EnvironmentCheck = true;
        };
        
        ControlFlowFlattening = {
            Enabled = true;
            ChunkSize = 3;
        };

        ConstantArray = {
            Enabled = true;
            EncodeStrings = true;
            IndexObfuscation = true;
        };

        NumbersToExpressions = {
            Enabled = true;
            Complexity = "medium";
        };

        AddVararg = {
            Enabled = true;
            Probability = 0.1;
        };
        
        AntiTamper = {
            Enabled = true;
        };

        Vmify = {
            Enabled = true;
            InlineVMState = true;
            ObfuscateHandlers = true;
            InstructionRandomization = true;
            EncryptVmStrings = true;
        };

        VmProfileRandomizer = {
            Enabled = true;
            PermuteOpcodes = true;
            ShuffleHandlers = true;
            RandomizeNames = true;
        };

        Compression = {
            Enabled = true;
            FastMode = false;     -- Disable fast mode
            BalancedMode = true;  -- Enable balanced mode
            BWT = true;
            RLE = true;
            ANS = true;  -- tANS encoder (2-5x faster decode than arithmetic)
            Huffman = false;
            ArithmeticCoding = false;
            PPM = true;
            PPMOrder = 4;
            -- Note: LuaDictionary omitted - VMify transforms keywords to bytecode
        };
    };
};
 
-- Restore package.path
package.path = oldPkgPath;
 
-- Export
return {
    Pipeline  = Pipeline;
    colors    = colors;
    Config    = util.readonly(Config); -- Readonly
    Logger    = Logger;
    highlight = highlight;
    Presets   = Presets;
}


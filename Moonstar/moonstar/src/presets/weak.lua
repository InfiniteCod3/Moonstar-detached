-- This Script is Part of the Moonstar Obfuscator
--
-- presets/weak.lua
--
-- Weak preset: Basic protection with string encryption and constant array.
-- Suitable for casual protection where performance is prioritized.

return function(ctx)
    return {
        LuaVersion    = ctx.LUA_VERSIONS.LUA51,
        VarNamePrefix = "",
        NameGenerator = "MangledShuffled",
        PrettyPrint   = false,
        Seed          = 0,

        WrapInFunction = {
            Enabled = true,
        },

        EncryptStrings = {
            Enabled = true,
            Mode = "light",
        },

        SplitStrings = {
            Enabled = true,
            MaxSegmentLength = 16,
            Strategy = "random",
        },

        ConstantArray = {
            Enabled = true,
            EncodeStrings = true,
            IndexObfuscation = false,
        },

        NumbersToExpressions = {
            Enabled = true,
            Complexity = "low",
        },
    }
end

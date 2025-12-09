-- This Script is Part of the Moonstar Obfuscator
--
-- presets/medium.lua
--
-- Medium preset: Balanced protection with encryption, constant array, and vararg injection.
-- Good balance between security and performance for most use cases.

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
            Mode = "standard",
        },

        SplitStrings = {
            Enabled = true,
            MaxSegmentLength = 16,
            Strategy = "random",
        },

        ConstantArray = {
            Enabled = true,
            EncodeStrings = true,
            IndexObfuscation = true,
        },

        NumbersToExpressions = {
            Enabled = true,
            Complexity = "low",
        },

        AddVararg = {
            Enabled = true,
            Probability = 0.15,
        },
    }
end

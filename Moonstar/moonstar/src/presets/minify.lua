-- This Script is Part of the Moonstar Obfuscator
--
-- presets/minify.lua
--
-- Minify preset: No obfuscation, just minification.
-- Use this when you only want to reduce file size without security features.

return function(ctx)
    return {
        LuaVersion    = ctx.LUA_VERSIONS.LUA51,
        VarNamePrefix = "",
        NameGenerator = "MangledShuffled",
        PrettyPrint   = false,
        Seed          = 0,

        WrapInFunction = {
            Enabled = false,
        },
    }
end

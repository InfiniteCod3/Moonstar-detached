-- Moonstar Preset: Minify
-- No obfuscation (just minification)

return {
    LuaVersion    = "Lua51";
    VarNamePrefix = "";
    NameGenerator = "MangledShuffled";
    PrettyPrint   = false;
    Seed          = 0;

    WrapInFunction = {
        Enabled = false; -- Can be toggled by user for module-style wrapping.
    };

    -- All obfuscation/defensive features disabled by default.
}

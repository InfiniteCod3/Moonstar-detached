-- Moonstar Preset: Weak
-- Basic protection (light encryption + constant array)
-- Removed overhead: SplitStrings (redundant), NumbersToExpressions (trivially reversed)

return {
    LuaVersion    = "Lua51";
    VarNamePrefix = "";
    NameGenerator = "MangledShuffled";
    PrettyPrint   = false;
    Seed          = 0;

    -- Light string encryption
    EncryptStrings = {
        Enabled = true;
        Mode = "light";
    };

    -- Basic constant array (no index obfuscation for speed)
    ConstantArray = {
        Enabled = true;
        EncodeStrings = true;
        IndexObfuscation = false;
    };

    -- Module isolation wrapper
    WrapInFunction = {
        Enabled = true;
    };

    -- Compression (optional, disabled by default)
    Compression = {
        Enabled = false;
        FastMode = true;
    };
}

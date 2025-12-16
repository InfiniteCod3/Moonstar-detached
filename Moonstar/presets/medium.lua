-- Moonstar Preset: Medium
-- Balanced protection (encryption + constant obfuscation) [recommended]
-- Removed overhead: SplitStrings (redundant with EncryptStrings), AddVararg, NumbersToExpressions

return {
    LuaVersion    = "Lua51";
    VarNamePrefix = "";
    NameGenerator = "MangledShuffled";
    PrettyPrint   = false;
    Seed          = 0;

    -- String protection
    EncryptStrings = {
        Enabled = true;
        Mode = "standard";
        DecryptorVariant = "arith";
    };

    -- Constant protection with index obfuscation
    ConstantArray = {
        Enabled = true;
        EncodeStrings = true;
        IndexObfuscation = true;
        AntiDeobfuscation = true;
    };

    -- Module isolation wrapper
    WrapInFunction = { Enabled = true };

    -- Compression (optional, disabled by default)
    Compression = {
        Enabled = false;
        FastMode = true;
    };
}

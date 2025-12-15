-- Moonstar Preset: Weak
-- Basic VM protection (Vmify + constant array)

return {
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
}

-- Moonstar Preset: Medium
-- Balanced protection (encryption + VM + all features) [recommended]

return {
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
}

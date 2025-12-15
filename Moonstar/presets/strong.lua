-- Moonstar Preset: Strong
-- Maximum protection (double VM + all features)

return {
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
        Enabled = false;
        FastMode = true;  -- Prioritize decompression speed for Roblox
        Preseed = true;
        BWT = true;
        RLE = true;
        Huffman = true;
        ArithmeticCoding = true;
        PPM = true;
        PPMOrder = 2;
        ParallelTests = 4;
    };
}

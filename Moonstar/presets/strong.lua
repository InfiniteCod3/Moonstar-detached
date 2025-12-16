-- Moonstar Preset: Strong
-- Maximum protection (VM + core security features)
-- Removed overhead steps: AddVararg, NumbersToExpressions (contradicts ConstantFolding)
-- AntiTamper integrates with Vmify for periodic integrity checks

return {
    LuaVersion    = "Lua51";
    VarNamePrefix = "";
    NameGenerator = "MangledShuffled";
    PrettyPrint   = false;
    Seed          = 0;

    -- VM-integrated anti-tamper protection
    AntiTamper = {
        Enabled = true;
        ChecksumConstants = true;
        CheckHandlers = true;
        EnvironmentCheck = true;
        SilentCorruption = true;
        TimingCheck = false;  -- Can cause false positives
    };

    -- Core protection: Custom bytecode VM
    Vmify = {
        Enabled = true;
        InlineVMState = true;
        ObfuscateHandlers = true;
        InstructionRandomization = true;
        EncryptVmStrings = true;
    };

    -- Enhances VM with randomized opcode layouts
    VmProfileRandomizer = {
        Enabled = true;
        PermuteOpcodes = true;
        ShuffleHandlers = true;
        RandomizeNames = true;
    };

    -- String protection with polymorphic decryptor
    EncryptStrings = {
        Enabled = true;
        Mode = "aggressive";
        DecryptorVariant = "polymorphic";
        LayerDepth = 1;
        InlineThreshold = 16;
        EnvironmentCheck = true;
    };

    -- Constant protection with index obfuscation
    ConstantArray = {
        Enabled = true;
        EncodeStrings = true;
        IndexObfuscation = true;
        AntiDeobfuscation = true;
    };

    -- Control flow obfuscation
    ControlFlowFlattening = {
        Enabled = true;
        ChunkSize = 3;
    };

    -- Pre-calculate expressions (optimization)
    ConstantFolding = {
        Enabled = true;
    };

    -- Module isolation wrapper
    WrapInFunction = { Enabled = true };

    -- Compression (optional, for size reduction)
    Compression = {
        Enabled = false;
        FastMode = true;
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

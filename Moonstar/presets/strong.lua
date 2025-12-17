-- Moonstar Preset: Strong
-- Maximum protection (VM + core security features)
-- Includes new security steps: OpaquePredicates, NumberObfuscation, AntiDebug, StringSplitting, BytecodePoisoning
-- AntiTamper and AntiDebug integrate with Vmify for comprehensive protection

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

    -- Anti-debugging protection
    AntiDebug = {
        Enabled = true;
        DetectDebugLib = true;
        DetectHooking = true;
        DetectTiming = false;  -- Disabled by default, can cause false positives
        DetectStackInspection = true;
        CheckInterval = 100;
        ResponseType = "corrupt";  -- "error", "silent", or "corrupt"
        RobloxChecks = true;
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

    -- Bytecode poisoning to break decompilers
    BytecodePoisoning = {
        Enabled = true;
        DeepNesting = true;
        UnusualSyntax = true;
        ConfusingVariables = true;
        TableEdgeCases = true;
        SelfReference = true;
        Intensity = 0.3;
        MaxNestingDepth = 15;
    };

    -- Opaque predicates for control flow obfuscation
    OpaquePredicates = {
        Enabled = true;
        Intensity = 0.3;
        UseMathPredicates = true;
        UseModuloPredicates = true;
        UseComparisonPredicates = true;
        WrapConditions = true;
        InsertFakeBranches = true;
    };

    -- Number obfuscation (transforms literals to expressions)
    NumberObfuscation = {
        Enabled = true;
        Intensity = 0.5;
        MaxDepth = 3;
        MinValue = 0;
        UseAddSub = true;
        UseMulDiv = true;
        UseMod = true;
        UseBitArith = true;
    };

    -- String splitting (breaks strings into runtime-concatenated chunks)
    StringSplitting = {
        Enabled = true;
        MinLength = 4;
        MaxChunks = 5;
        MinChunkSize = 1;
        Intensity = 0.7;
        UseTableConcat = true;
        ShuffleChunks = true;
        UseCharEncoding = true;
        ReverseChunks = true;
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

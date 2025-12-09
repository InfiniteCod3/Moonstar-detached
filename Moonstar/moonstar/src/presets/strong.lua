-- This Script is Part of the Moonstar Obfuscator
--
-- presets/strong.lua
--
-- Strong preset: Maximum protection with VM, control flow flattening, and all features.
-- Use this when security is the top priority and file size/performance are secondary.

return function(ctx)
    return {
        LuaVersion    = ctx.LUA_VERSIONS.LUA51,
        VarNamePrefix = "",
        NameGenerator = "MangledShuffled",
        PrettyPrint   = false,
        Seed          = 0,

        GlobalVirtualization = {
            Enabled = true,
            VirtualizeEnv = true,
        },

        WrapInFunction = {
            Enabled = true,
        },

        ConstantFolding = {
            Enabled = true,
        },

        JitStringDecryptor = {
            Enabled = false,
            MaxLength = 30,
        },

        EncryptStrings = {
            Enabled = true,
            Mode = "standard",
            DecryptorVariant = "polymorphic",
            LayerDepth = 1,
            InlineThreshold = 16,
            EnvironmentCheck = true,
        },

        ControlFlowFlattening = {
            Enabled = true,
            ChunkSize = 3,
        },

        ConstantArray = {
            Enabled = true,
            EncodeStrings = true,
            IndexObfuscation = true,
        },

        NumbersToExpressions = {
            Enabled = true,
            Complexity = "medium",
        },

        AddVararg = {
            Enabled = true,
            Probability = 0.1,
        },

        AntiTamper = {
            Enabled = true,
        },

        Vmify = {
            Enabled = true,
            InlineVMState = true,
            ObfuscateHandlers = true,
            InstructionRandomization = true,
            EncryptVmStrings = true,
            VmDispatchMode = "auto",
            VmDispatchTableThreshold = 100,
            -- P2: Aggressive Block Inlining (enabled by default, using extended thresholds)
            EnableAggressiveInlining = true,
            InlineThresholdNormal = 15,     -- Slightly higher than default for more inlining
            InlineThresholdHot = 30,        -- Higher threshold for hot paths in Strong preset
            MaxInlineDepth = 12,            -- Allow deeper inlining chains
            -- P3: Constant Hoisting (hoist frequently-used globals to locals)
            EnableConstantHoisting = true,
            ConstantHoistThreshold = 2,     -- More aggressive: hoist globals used 2+ times
            -- P5: Specialized Instruction Patterns
            EnableSpecializedPatterns = true,
            StrCatChainThreshold = 3,       -- Optimize string concat chains with 3+ operands
            -- P6: Loop Unrolling (unroll small constant-bound loops)
            EnableLoopUnrolling = true,
            MaxUnrollIterations = 8,        -- Unroll loops with up to 8 iterations
            -- P7: Tail Call Optimization (emit proper tail calls)
            EnableTailCallOptimization = true,
            -- P8: Dead Code Elimination (remove unreachable blocks, dead stores, redundant jumps)
            EnableDeadCodeElimination = true,
        },

        VmProfileRandomizer = {
            Enabled = true,
            PermuteOpcodes = true,
            ShuffleHandlers = true,
            RandomizeNames = true,
        },

        Compression = ctx.deepCopy(ctx.CompressionConfig.Fast),
    }
end

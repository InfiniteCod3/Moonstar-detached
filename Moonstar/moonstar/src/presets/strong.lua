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

        WrapInFunction = {
            Enabled = true,
        },

        ConstantFolding = {
            Enabled = true,
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
            
            -- Sprint 1: Foundations
            -- S1: Opcode Shuffling (randomize block external IDs with gaps)
            EnableOpcodeShuffling = true,
            -- P11: Peephole Optimization (local pattern optimizations)
            EnablePeepholeOptimization = true,
            MaxPeepholeIterations = 5,
            -- P15: Extended Strength Reduction (power-of-2 optimizations)
            EnableStrengthReduction = true,
            
            -- Sprint 2: Core Security
            -- S2: Dynamic Register Remapping (shuffle register IDs, inject ghost writes)
            EnableRegisterRemapping = true,
            GhostRegisterDensity = 15,          -- 15% of statements get ghost writes
            -- S4: Multi-Layer String Encryption (XOR → Caesar → Substitution chain)
            EnableMultiLayerEncryption = true,
            EncryptionLayers = 3,               -- Chain 3 encryption layers
            -- S6: Instruction Polymorphism (semantic-preserving code transformations)
            EnableInstructionPolymorphism = true,
            PolymorphismRate = 50,              -- 50% of applicable expressions are transformed
            
            -- Sprint 3: Core Performance
            -- P9: Inline Caching for Globals (cache resolved global lookups for hot paths)
            EnableInlineCaching = true,
            InlineCacheThreshold = 3,           -- Cache globals accessed 3+ times (lower for strong perf)
            -- P10: Loop Invariant Code Motion (hoist invariant computations out of loops)
            EnableLICM = true,
            LicmMinIterations = 2,              -- Apply LICM to loops with 2+ expected iterations
            -- P14: Common Subexpression Elimination (reuse computed expression results)
            EnableCSE = true,
            MaxCSEIterations = 3,               -- Max CSE optimization passes per block
            
            -- Sprint 5: Advanced Performance
            -- P12: Small Function Inlining (inline small local functions at call sites)
            EnableFunctionInlining = true,
            MaxInlineFunctionSize = 10,         -- Inline functions with ≤10 statements
            MaxInlineParameters = 5,            -- Inline functions with ≤5 parameters
            MaxInlineDepth = 3,                 -- Prevent excessive inlining chains
            -- P17: Table Pre-sizing (emit table.create hints for large static tables)
            EnableTablePresizing = true,
            TablePresizeArrayThreshold = 4,     -- Pre-size arrays with 4+ elements
            TablePresizeHashThreshold = 4,      -- Pre-size hashes with 4+ elements
            -- P18: Vararg Optimization (optimize select('#', ...) and {...}[n] patterns)
            EnableVarargOptimization = true,
            
            -- Sprint 7: Advanced Performance (P19, P20)
            -- P19: Copy Propagation (eliminate redundant register copies)
            EnableCopyPropagation = true,
            MaxCopyPropagationIterations = 3,   -- Max optimization iterations per block
            -- P20: Allocation Sinking (defer/eliminate memory allocations)
            EnableAllocationSinking = true,
            
            -- Sprint 8: Bytecode Execution Performance (P21, P22)
            -- P21: Register Locality Optimization (group live registers for cache locality)
            EnableRegisterLocality = true,
            -- P22: Conditional Fusion (fuse and/or chains into direct branching)
            EnableConditionalFusion = true,
            
            -- Dispatch Enhancements
            -- D1: Encrypted Block IDs (XOR-encrypt block IDs with per-compilation seed)
            EnableEncryptedBlockIds = true,
            -- D2: Randomized BST Comparison Order (randomly flip < vs >= comparisons)
            EnableRandomizedBSTOrder = true,
            BstRandomizationRate = 60,          -- 60% of comparisons will use >=
            -- D3: Hybrid Dispatch (DISABLED for strong preset - table dispatch exposes block IDs)
            -- EnableHybridDispatch = false,    -- Keep BST for better obfuscation
            
            -- VM Profile Randomization (merged from VmProfileRandomizer step)
            PermuteOpcodes = true,
            ShuffleHandlers = true,
            RandomizeNames = true,
        },

        DebugInfoRemover = {
            Enabled = true,
            RemoveSourceLocations = true,
            RemoveTokens = true,
        },
    }
end


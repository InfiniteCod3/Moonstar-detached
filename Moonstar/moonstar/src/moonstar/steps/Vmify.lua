-- This Script is Part of the Moonstar Obfuscator by Aurologic
--
-- Vmify.lua
--
-- This Script provides a Complex Obfuscation Step that will compile the entire Script to  a fully custom bytecode that does not share it's instructions
-- with lua, making it much harder to crack than other lua obfuscators

local Step = require("moonstar.step");
local Compiler = require("moonstar.compiler.init");

local Vmify = Step:extend();
Vmify.Description = "This Step will Compile your script into a fully-custom (not a half custom like other lua obfuscators) Bytecode Format and emit a vm for executing it.";
Vmify.Name = "Vmify";

Vmify.SettingsDescriptor = {
    InstructionRandomization = {
        description = "Enable instruction set randomization (block ID randomization)",
        default = false,
        type = "boolean"
    },
	-- Plan.md enhancements
	Enabled = {
		type = "boolean",
		default = true,
	},
	PartialRatio = {
		type = "number",
		default = 1.0,
		min = 0.0,
		max = 1.0,
	},
	InlineVMState = {
		type = "boolean",
		default = false,
	},
	ObfuscateHandlers = {
		type = "boolean",
		default = true,
	},
	EncryptVmStrings = {
		type = "boolean",
		default = false,
	},
	VmDispatchMode = {
		description = "VM dispatch mode: 'bst' (binary search tree), 'table' (O(1) hash table), or 'auto' (choose based on block count)",
		type = "string",
		default = "auto",
	},
	VmDispatchTableThreshold = {
		description = "Block count threshold for auto mode to use table dispatch (use table when blocks < threshold)",
		type = "number",
		default = 100,
	},
	-- P2: Aggressive Block Inlining settings
	EnableAggressiveInlining = {
		description = "Enable P2 aggressive block inlining with loop detection and extended thresholds",
		type = "boolean",
		default = true,
	},
	InlineThresholdNormal = {
		description = "Max statements for normal block inlining",
		type = "number",
		default = 12,
	},
	InlineThresholdHot = {
		description = "Max statements for hot path (loop) block inlining",
		type = "number",
		default = 25,
	},
	MaxInlineDepth = {
		description = "Max inline chain depth to prevent code explosion",
		type = "number",
		default = 10,
	},
	-- P3: Constant Hoisting settings
	EnableConstantHoisting = {
		description = "Enable P3 constant hoisting (hoist frequently-used globals to local variables)",
		type = "boolean",
		default = true,
	},
	ConstantHoistThreshold = {
		description = "Minimum access count to hoist a global variable",
		type = "number",
		default = 3,
	},
	-- P5: Specialized Instruction Patterns settings
	EnableSpecializedPatterns = {
		description = "Enable P5 specialized instruction patterns (e.g., string concat chains)",
		type = "boolean",
		default = true,
	},
	StrCatChainThreshold = {
		description = "Minimum operands for table.concat optimization in string concatenation chains",
		type = "number",
		default = 3,
	},
	-- P6: Loop Unrolling settings
	EnableLoopUnrolling = {
		description = "Enable P6 loop unrolling (unroll small constant-bound numeric for loops)",
		type = "boolean",
		default = false,
	},
	MaxUnrollIterations = {
		description = "Maximum number of loop iterations to unroll",
		type = "number",
		default = 8,
	},
	-- P7: Tail Call Optimization settings
	EnableTailCallOptimization = {
		description = "Enable P7 tail call optimization (emit proper tail calls for single function call returns)",
		type = "boolean",
		default = true,
	},
	-- P8: Dead Code Elimination settings
	EnableDeadCodeElimination = {
		description = "Enable P8 dead code elimination (remove unreachable blocks, dead stores, redundant jumps)",
		type = "boolean",
		default = true,
	},
	-- Sprint 1: S1 Opcode Shuffling
	EnableOpcodeShuffling = {
		description = "Enable S1 opcode shuffling (randomize block external IDs with gaps)",
		type = "boolean",
		default = false,
	},
	-- Sprint 1: P11 Peephole Optimization
	EnablePeepholeOptimization = {
		description = "Enable P11 peephole optimization (local pattern optimizations)",
		type = "boolean",
		default = true,
	},
	MaxPeepholeIterations = {
		description = "Maximum iterations for peephole optimization per block",
		type = "number",
		default = 5,
	},
	-- Sprint 1: P15 Extended Strength Reduction
	EnableStrengthReduction = {
		description = "Enable P15 extended strength reduction (power-of-2 optimizations)",
		type = "boolean",
		default = true,
	},
	-- Sprint 2: S2 Dynamic Register Remapping
	EnableRegisterRemapping = {
		description = "Enable S2 dynamic register remapping (shuffle register IDs, inject ghost writes)",
		type = "boolean",
		default = false,
	},
	GhostRegisterDensity = {
		description = "Percentage (0-100) of statements to inject ghost writes (never-read assignments)",
		type = "number",
		default = 15,
	},
	-- Sprint 2: S4 Multi-Layer String Encryption
	EnableMultiLayerEncryption = {
		description = "Enable S4 multi-layer string encryption (XOR → Caesar → Substitution chain)",
		type = "boolean",
		default = false,
	},
	EncryptionLayers = {
		description = "Number of encryption layers for multi-layer encryption (1-5)",
		type = "number",
		default = 3,
	},
	-- Sprint 2: S6 Instruction Polymorphism
	EnableInstructionPolymorphism = {
		description = "Enable S6 instruction polymorphism (semantic-preserving code transformations)",
		type = "boolean",
		default = false,
	},
	PolymorphismRate = {
		description = "Percentage (0-100) of applicable expressions to transform",
		type = "number",
		default = 50,
	},
	-- Sprint 3: P9 Inline Caching for Globals
	EnableInlineCaching = {
		description = "Enable P9 inline caching for globals (cache resolved global lookups for hot paths)",
		type = "boolean",
		default = false,
	},
	InlineCacheThreshold = {
		description = "Minimum access count to cache a global variable",
		type = "number",
		default = 5,
	},
	-- Sprint 3: P10 Loop Invariant Code Motion
	EnableLICM = {
		description = "Enable P10 LICM (hoist invariant computations out of loops)",
		type = "boolean",
		default = false,
	},
	LicmMinIterations = {
		description = "Minimum expected loop iterations to apply LICM",
		type = "number",
		default = 2,
	},
	-- Sprint 3: P14 Common Subexpression Elimination
	EnableCSE = {
		description = "Enable P14 CSE (reuse previously computed expression results)",
		type = "boolean",
		default = false,
	},
	MaxCSEIterations = {
		description = "Maximum CSE optimization iterations per block",
		type = "number",
		default = 3,
	},
	-- Sprint 5: P12 Small Function Inlining
	EnableFunctionInlining = {
		description = "Enable P12 small function inlining (inline small local functions at call sites)",
		type = "boolean",
		default = false,
	},
	MaxInlineFunctionSize = {
		description = "Maximum statements in a function body for inlining",
		type = "number",
		default = 10,
	},
	MaxInlineParameters = {
		description = "Maximum parameters for inlining",
		type = "number",
		default = 5,
	},
	-- Sprint 5: P17 Table Pre-sizing
	EnableTablePresizing = {
		description = "Enable P17 table pre-sizing (emit table.create hints for large static tables)",
		type = "boolean",
		default = false,
	},
	TablePresizeArrayThreshold = {
		description = "Minimum array elements to add size hint",
		type = "number",
		default = 4,
	},
	TablePresizeHashThreshold = {
		description = "Minimum hash elements to add size hint",
		type = "number",
		default = 4,
	},
	-- Sprint 5: P18 Vararg Optimization
	EnableVarargOptimization = {
		description = "Enable P18 vararg optimization (optimize select('#', ...) and {...}[n] patterns)",
		type = "boolean",
		default = false,
	},
	-- Sprint 8: P21 Register Locality Optimization
	EnableRegisterLocality = {
		description = "Enable P21 register locality optimization (group live registers for cache locality)",
		type = "boolean",
		default = false,
	},
	-- Sprint 8: P22 Conditional Fusion
	EnableConditionalFusion = {
		description = "Enable P22 conditional fusion (fuse and/or chains into direct branching)",
		type = "boolean",
		default = false,
	},
	-- Dispatch Enhancements: D1 Encrypted Block IDs
	EnableEncryptedBlockIds = {
		description = "Enable D1 encrypted block IDs (XOR-encrypt block IDs with per-compilation seed)",
		type = "boolean",
		default = false,
	},
	-- Dispatch Enhancements: D2 Randomized BST Comparison Order
	EnableRandomizedBSTOrder = {
		description = "Enable D2 randomized BST comparison order (randomly flip < vs >= comparisons)",
		type = "boolean",
		default = false,
	},
	BstRandomizationRate = {
		description = "Percentage (0-100) of BST nodes to randomize comparison order",
		type = "number",
		default = 50,
	},
	-- Dispatch Enhancements: D3 Hybrid Hot-Path Dispatch
	EnableHybridDispatch = {
		description = "Enable D3 hybrid dispatch (table dispatch for hot blocks, BST for cold)",
		type = "boolean",
		default = false,
	},
	HybridHotBlockThreshold = {
		description = "Minimum in-degree to consider a block 'hot'",
		type = "number",
		default = 2,
	},
	MaxHybridHotBlocks = {
		description = "Maximum number of hot blocks for table dispatch",
		type = "number",
		default = 20,
	},
	-- VM Profile Randomization (merged from VmProfileRandomizer step)
	PermuteOpcodes = {
		description = "Randomize opcode assignments for each compilation",
		type = "boolean",
		default = true,
	},
	ShuffleHandlers = {
		description = "Randomize handler order in the VM",
		type = "boolean",
		default = true,
	},
	RandomizeNames = {
		description = "Randomize internal VM variable names",
		type = "boolean",
		default = true,
	},
}

function Vmify:init(settings)
	settings = settings or {}  -- Handle nil settings
	self.InstructionRandomization = settings.InstructionRandomization
	if self.InstructionRandomization == nil then
		self.InstructionRandomization = true  -- Default to enabled
	end
	self.EncryptVmStrings = settings.EncryptVmStrings
	self.VmDispatchMode = settings.VmDispatchMode or "auto"
	self.VmDispatchTableThreshold = settings.VmDispatchTableThreshold or 100
	-- P2: Aggressive Block Inlining settings
	self.EnableAggressiveInlining = settings.EnableAggressiveInlining ~= false  -- Default: true
	self.InlineThresholdNormal = settings.InlineThresholdNormal or 12
	self.InlineThresholdHot = settings.InlineThresholdHot or 25
	self.MaxInlineDepth = settings.MaxInlineDepth or 10
	-- P3: Constant Hoisting settings
	self.EnableConstantHoisting = settings.EnableConstantHoisting ~= false  -- Default: true
	self.ConstantHoistThreshold = settings.ConstantHoistThreshold or 3
	-- P5: Specialized Instruction Patterns settings
	self.EnableSpecializedPatterns = settings.EnableSpecializedPatterns ~= false  -- Default: true
	self.StrCatChainThreshold = settings.StrCatChainThreshold or 3
	-- P6: Loop Unrolling settings
	self.EnableLoopUnrolling = settings.EnableLoopUnrolling or false  -- Default: false (security)
	self.MaxUnrollIterations = settings.MaxUnrollIterations or 8
	-- P7: Tail Call Optimization settings
	self.EnableTailCallOptimization = settings.EnableTailCallOptimization ~= false  -- Default: true
	-- P8: Dead Code Elimination settings
	self.EnableDeadCodeElimination = settings.EnableDeadCodeElimination ~= false  -- Default: true
	-- Sprint 1: S1 Opcode Shuffling
	self.EnableOpcodeShuffling = settings.EnableOpcodeShuffling or false  -- Default: false
	-- Sprint 1: P11 Peephole Optimization
	self.EnablePeepholeOptimization = settings.EnablePeepholeOptimization ~= false  -- Default: true
	self.MaxPeepholeIterations = settings.MaxPeepholeIterations or 5
	-- Sprint 1: P15 Extended Strength Reduction
	self.EnableStrengthReduction = settings.EnableStrengthReduction ~= false  -- Default: true
	-- Sprint 2: S2 Dynamic Register Remapping
	self.EnableRegisterRemapping = settings.EnableRegisterRemapping or false  -- Default: false
	self.GhostRegisterDensity = settings.GhostRegisterDensity or 15
	-- Sprint 2: S4 Multi-Layer String Encryption
	self.EnableMultiLayerEncryption = settings.EnableMultiLayerEncryption or false  -- Default: false
	self.EncryptionLayers = settings.EncryptionLayers or 3
	-- Sprint 2: S6 Instruction Polymorphism
	self.EnableInstructionPolymorphism = settings.EnableInstructionPolymorphism or false  -- Default: false
	self.PolymorphismRate = settings.PolymorphismRate or 50
	-- Sprint 3: P9 Inline Caching for Globals
	self.EnableInlineCaching = settings.EnableInlineCaching or false  -- Default: false
	self.InlineCacheThreshold = settings.InlineCacheThreshold or 5
	-- Sprint 3: P10 Loop Invariant Code Motion
	self.EnableLICM = settings.EnableLICM or false  -- Default: false
	self.LicmMinIterations = settings.LicmMinIterations or 2
	-- Sprint 3: P14 Common Subexpression Elimination
	self.EnableCSE = settings.EnableCSE or false  -- Default: false
	self.MaxCSEIterations = settings.MaxCSEIterations or 3
	-- Sprint 5: P12 Small Function Inlining
	self.EnableFunctionInlining = settings.EnableFunctionInlining or false  -- Default: false
	self.MaxInlineFunctionSize = settings.MaxInlineFunctionSize or 10
	self.MaxInlineParameters = settings.MaxInlineParameters or 5
	-- Sprint 5: P17 Table Pre-sizing
	self.EnableTablePresizing = settings.EnableTablePresizing or false  -- Default: false
	self.TablePresizeArrayThreshold = settings.TablePresizeArrayThreshold or 4
	self.TablePresizeHashThreshold = settings.TablePresizeHashThreshold or 4
	-- Sprint 5: P18 Vararg Optimization
	self.EnableVarargOptimization = settings.EnableVarargOptimization or false  -- Default: false
	-- Sprint 8: P21 Register Locality Optimization
	self.EnableRegisterLocality = settings.EnableRegisterLocality or false  -- Default: false
	-- Sprint 8: P22 Conditional Fusion
	self.EnableConditionalFusion = settings.EnableConditionalFusion or false  -- Default: false
	-- Dispatch Enhancements: D1 Encrypted Block IDs
	self.EnableEncryptedBlockIds = settings.EnableEncryptedBlockIds or false  -- Default: false
	-- Dispatch Enhancements: D2 Randomized BST Comparison Order
	self.EnableRandomizedBSTOrder = settings.EnableRandomizedBSTOrder or false  -- Default: false
	self.BstRandomizationRate = settings.BstRandomizationRate or 50
	-- Dispatch Enhancements: D3 Hybrid Hot-Path Dispatch
	self.EnableHybridDispatch = settings.EnableHybridDispatch or false  -- Default: false
	self.HybridHotBlockThreshold = settings.HybridHotBlockThreshold or 2
	self.MaxHybridHotBlocks = settings.MaxHybridHotBlocks or 20
	-- VM Profile Randomization (merged from VmProfileRandomizer step)
	self.PermuteOpcodes = settings.PermuteOpcodes ~= false  -- Default: true
	self.ShuffleHandlers = settings.ShuffleHandlers ~= false  -- Default: true
	self.RandomizeNames = settings.RandomizeNames ~= false  -- Default: true
end

function Vmify:apply(ast, pipeline)
    -- VUL-2025-011 FIX: Track VM application count for multi-layer VMs
    pipeline = pipeline or {}
    if pipeline.vmApplicationCount then
        pipeline.vmApplicationCount = pipeline.vmApplicationCount + 1
    else
        pipeline.vmApplicationCount = 1
    end
    
    -- VUL-2025-011 FIX: Reseed PRNG for each VM layer with layer-specific entropy
    if self.InstructionRandomization and pipeline.vmApplicationCount > 1 then
        -- Generate layer-specific entropy
        local prev_state = math.random(1, 2^31)
        local layer_entropy = os.time() * 1000 + 
                             pipeline.vmApplicationCount * 1000000 +
                             string.byte(tostring(ast), -8) +
                             prev_state
        
        math.randomseed(layer_entropy % (2^32))
        -- Warmup to ensure good randomness
        for i = 1, 50 do 
            math.random() 
        end
    end
    
    -- Determine instruction randomization based on Profile
    local enableRandomization = self.InstructionRandomization
    
    -- Check PartialRatio for selective vmification
    local partialRatio = self.PartialRatio or 1.0
    if partialRatio < 1.0 then
        -- Partial vmification: only process a percentage of the code
        -- For simplicity, we'll use a probability check
        -- A full implementation would selectively vmify specific functions
        if math.random() > partialRatio then
            -- Skip vmification for this run (simplified implementation)
            -- In a full implementation, we'd need to:
            -- 1. Parse AST to identify functions
            -- 2. Select subset based on PartialRatio
            -- 3. Only vmify selected functions
            -- For now, apply standard vmification
        end
    end
    
    -- Create Compiler with instruction randomization and profile config
	local compiler = Compiler:new({
		enableInstructionRandomization = enableRandomization,
		inlineVMState = self.InlineVMState or false,
		obfuscateHandlers = self.ObfuscateHandlers ~= false,  -- Default true
		encryptVmStrings = self.EncryptVmStrings or false,
		vmDispatchMode = self.VmDispatchMode or "auto",
		vmDispatchTableThreshold = self.VmDispatchTableThreshold or 100,
		-- P2: Aggressive Block Inlining config
		enableAggressiveInlining = self.EnableAggressiveInlining ~= false,
		inlineThresholdNormal = self.InlineThresholdNormal or 12,
		inlineThresholdHot = self.InlineThresholdHot or 25,
		maxInlineDepth = self.MaxInlineDepth or 10,
		-- P3: Constant Hoisting config
		enableConstantHoisting = self.EnableConstantHoisting ~= false,
		constantHoistThreshold = self.ConstantHoistThreshold or 3,
		-- P5: Specialized Instruction Patterns config
		enableSpecializedPatterns = self.EnableSpecializedPatterns ~= false,
		strCatChainThreshold = self.StrCatChainThreshold or 3,
		-- P6: Loop Unrolling config
		enableLoopUnrolling = self.EnableLoopUnrolling or false,
		maxUnrollIterations = self.MaxUnrollIterations or 8,
		-- P7: Tail Call Optimization config
		enableTailCallOptimization = self.EnableTailCallOptimization ~= false,
		-- P8: Dead Code Elimination config
		enableDeadCodeElimination = self.EnableDeadCodeElimination ~= false,
		-- Sprint 1: S1 Opcode Shuffling config
		enableOpcodeShuffling = self.EnableOpcodeShuffling or false,
		-- Sprint 1: P11 Peephole Optimization config
		enablePeepholeOptimization = self.EnablePeepholeOptimization ~= false,
		maxPeepholeIterations = self.MaxPeepholeIterations or 5,
		-- Sprint 1: P15 Extended Strength Reduction config
		enableStrengthReduction = self.EnableStrengthReduction ~= false,
		-- Sprint 2: S2 Dynamic Register Remapping config
		enableRegisterRemapping = self.EnableRegisterRemapping or false,
		ghostRegisterDensity = self.GhostRegisterDensity or 15,
		-- Sprint 2: S4 Multi-Layer String Encryption config
		enableMultiLayerEncryption = self.EnableMultiLayerEncryption or false,
		encryptionLayers = self.EncryptionLayers or 3,
		-- Sprint 2: S6 Instruction Polymorphism config
		enableInstructionPolymorphism = self.EnableInstructionPolymorphism or false,
		polymorphismRate = self.PolymorphismRate or 50,
		-- Sprint 3: P9 Inline Caching for Globals config
		enableInlineCaching = self.EnableInlineCaching or false,
		inlineCacheThreshold = self.InlineCacheThreshold or 5,
		-- Sprint 3: P10 Loop Invariant Code Motion config
		enableLICM = self.EnableLICM or false,
		licmMinIterations = self.LicmMinIterations or 2,
		-- Sprint 3: P14 Common Subexpression Elimination config
		enableCSE = self.EnableCSE or false,
		maxCSEIterations = self.MaxCSEIterations or 3,
		-- Sprint 5: P12 Small Function Inlining config
		enableFunctionInlining = self.EnableFunctionInlining or false,
		maxInlineFunctionSize = self.MaxInlineFunctionSize or 10,
		maxInlineParameters = self.MaxInlineParameters or 5,
		-- Sprint 5: P17 Table Pre-sizing config
		enableTablePresizing = self.EnableTablePresizing or false,
		tablePresizeArrayThreshold = self.TablePresizeArrayThreshold or 4,
		tablePresizeHashThreshold = self.TablePresizeHashThreshold or 4,
		-- Sprint 5: P18 Vararg Optimization config
		enableVarargOptimization = self.EnableVarargOptimization or false,
		-- Sprint 8: P21 Register Locality Optimization config
		enableRegisterLocality = self.EnableRegisterLocality or false,
		-- Sprint 8: P22 Conditional Fusion config
		enableConditionalFusion = self.EnableConditionalFusion or false,
		-- Dispatch Enhancements: D1 Encrypted Block IDs config
		enableEncryptedBlockIds = self.EnableEncryptedBlockIds or false,
		-- Dispatch Enhancements: D2 Randomized BST Comparison Order config
		enableRandomizedBSTOrder = self.EnableRandomizedBSTOrder or false,
		bstRandomizationRate = self.BstRandomizationRate or 50,
		-- Dispatch Enhancements: D3 Hybrid Hot-Path Dispatch config
		enableHybridDispatch = self.EnableHybridDispatch or false,
		hybridHotBlockThreshold = self.HybridHotBlockThreshold or 2,
		maxHybridHotBlocks = self.MaxHybridHotBlocks or 20,
		-- VM Profile Randomization config
		permuteOpcodes = self.PermuteOpcodes ~= false,
		shuffleHandlers = self.ShuffleHandlers ~= false,
		randomizeNames = self.RandomizeNames ~= false,
	});
    
    -- Compile the Script into a bytecode vm
    return compiler:compile(ast);
end

return Vmify;
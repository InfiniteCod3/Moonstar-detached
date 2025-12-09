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
	}
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
	});
    
    -- Compile the Script into a bytecode vm
    return compiler:compile(ast);
end

return Vmify;
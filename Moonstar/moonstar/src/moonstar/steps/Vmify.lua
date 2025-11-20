-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- Vmify.lua
--
-- This Script provides a Complex Obfuscation Step that will compile the entire Script to  a fully custom bytecode that does not share it's instructions
-- with lua, making it much harder to crack than other lua obfuscators

local Step = require("moonstar.step");
local Compiler = require("moonstar.compiler.compiler");

local Vmify = Step:extend();
Vmify.Description = "This Step will Compile your script into a fully-custom (not a half custom like other lua obfuscators) Bytecode Format and emit a vm for executing it.";
Vmify.Name = "Vmify";

Vmify.SettingsDescriptor = {
    InstructionRandomization = {
        description = "Enable instruction set randomization (block ID randomization)",
        default = true,
        type = "boolean"
    },
	-- Plan.md enhancements
	Enabled = {
		type = "boolean",
		default = true,
	},
	Profile = {
		type = "enum",
		values = {"baseline", "stealth", "heavy", "array"},
		default = "baseline",
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
}

function Vmify:init(settings)
	settings = settings or {}  -- Handle nil settings
	self.InstructionRandomization = settings.InstructionRandomization
	if self.InstructionRandomization == nil then
		self.InstructionRandomization = true  -- Default to enabled
	end
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
    local profile = self.Profile or "baseline"
    
    if profile == "stealth" then
        -- Stealth mode: enable extra randomization
        enableRandomization = true
    elseif profile == "heavy" then
        -- Heavy mode: enable all features
        enableRandomization = true
    end
    -- baseline uses default settings
    
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
		vmProfile = profile,
		inlineVMState = self.InlineVMState or false,
		obfuscateHandlers = self.ObfuscateHandlers ~= false  -- Default true
	});
    
    -- Compile the Script into a bytecode vm
    return compiler:compile(ast);
end

return Vmify;
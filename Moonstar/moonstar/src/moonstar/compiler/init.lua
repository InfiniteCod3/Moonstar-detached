-- init.lua
-- Core compiler state, block management, and main compilation orchestration
-- This is the main entry point for the compiler module

-- The max Number of variables used as registers
local MAX_REGS = 150;

-- P4: Number of spill registers (local variables for registers MAX_REGS to MAX_REGS + SPILL_REGS - 1)
-- These provide faster access than table indexing for overflow registers
local SPILL_REGS = 10;

local Compiler = {};

local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local logger = require("logger");
local util = require("moonstar.util");
local visitast = require("moonstar.visitast")
local randomStrings = require("moonstar.randomStrings")
local VmConstantEncryptor = require("moonstar.compiler.vmConstantEncryptor")

-- Refactored modules
local Statements = require("moonstar.compiler.statements")
local Expressions = require("moonstar.compiler.expressions")
local VmGen = require("moonstar.compiler.vm")
local Registers = require("moonstar.compiler.registers")
local Upvalues = require("moonstar.compiler.upvalues")

local InlineCache = require("moonstar.compiler.inline_cache")
local Inlining = require("moonstar.compiler.inlining")
local TablePresizing = require("moonstar.compiler.table_presizing")
local VarargOptimization = require("moonstar.compiler.vararg_optimization")

local lookupify = util.lookupify;
local AstKind = Ast.AstKind;

local unpack = unpack or table.unpack;

-- newproxy polyfill for Lua 5.2+ compatibility
-- newproxy exists in Lua 5.1 but was removed in Lua 5.2+
if not _G.newproxy then
    _G.newproxy = function(arg)
        if arg then
            return setmetatable({}, {});
        end
        return {};
    end
end

-- PERFORMANCE: Cache platform entropy to avoid repeated io.popen() calls
-- This is computed once per module load instead of per-compilation
-- Using false as sentinel value to distinguish 'not computed' from 'computed as 0'
local cached_platform_entropy = false
local function getPlatformEntropy()
    if cached_platform_entropy ~= false then
        return cached_platform_entropy
    end
    
    local platform_entropy = 0
    if package.config:sub(1,1) == '\\' then  -- Windows
        local handle = io.popen("powershell -Command \"Get-Random\"", "r")
        if handle then
            local rand = handle:read("*a")
            handle:close()
            platform_entropy = tonumber(rand) or 0
        end
        -- Note: If io.popen fails, we fall back to 0 (still have 4 other entropy sources)
    else  -- Unix-like systems
        local handle = io.popen("od -An -N4 -tu4 /dev/urandom 2>/dev/null", "r")
        if handle then
            local rand = handle:read("*a")
            handle:close()
            platform_entropy = tonumber(rand) or 0
        end
        -- Note: If io.popen fails, we fall back to 0 (still have 4 other entropy sources)
    end
    
    cached_platform_entropy = platform_entropy
    return platform_entropy
end

function Compiler:new(config)
    config = config or {}
    
    -- Seed random number generator for instruction randomization
    if config.enableInstructionRandomization then
        -- VUL-2025-002 FIX: Enhanced PRNG seeding with multiple entropy sources
        local entropy_sources = {
            os.time() * 1000,              -- Time-based entropy (millisecond resolution attempt)
            os.clock() * 1000000,          -- Process time with microsecond precision
            collectgarbage("count"),       -- Memory usage as entropy
            string.byte(tostring({}), -8), -- Memory address randomness
        }
        
        -- PERFORMANCE: Use cached platform entropy instead of calling io.popen() every time
        table.insert(entropy_sources, getPlatformEntropy())
        
        -- Combine entropy sources with weighted mixing
        local seed = 0
        for i, source in ipairs(entropy_sources) do
            seed = seed + (source * (i * 1000000))
        end
        
        -- Apply modulo to stay within safe range for 32-bit systems
        math.randomseed(seed % (2^32))
        
        -- PERFORMANCE: Reduced warmup iterations from 100 to 20
        for i = 1, 20 do 
            math.random() 
        end
    end
    
    local compiler = {
        blocks = {};
        registers = {
        };
        freeRegisters = {}; -- Optimization: Free List
        constants = {}; -- Optimization: Shared Constant Pool
        constantRegs = {}; -- To prevent freeing constant registers
        activeBlock = nil;
        registersForVar = {};
        usedRegisters = 0;
        maxUsedRegister = 0;
        registerVars = {};
        
        -- Instruction randomization config
        enableInstructionRandomization = config.enableInstructionRandomization or false;

        -- VM string encryption config
        encryptVmStrings = config.encryptVmStrings or false;
        
        -- VM dispatch mode config
        -- Options: "bst" (binary search tree), "table" (O(1) hash table), "auto" (choose based on block count)
        vmDispatchMode = config.vmDispatchMode or "auto";
        vmDispatchTableThreshold = config.vmDispatchTableThreshold or 100; -- Use table dispatch when block count < threshold in auto mode
        
        -- P2: Aggressive Block Inlining config
        -- These options control how aggressively the compiler inlines blocks to reduce dispatch overhead
        enableAggressiveInlining = config.enableAggressiveInlining ~= false; -- Default: true (enabled)
        inlineThresholdNormal = config.inlineThresholdNormal or 12;  -- Max statements for normal block inlining
        inlineThresholdHot = config.inlineThresholdHot or 25;        -- Max statements for hot path (loop) block inlining
        maxInlineDepth = config.maxInlineDepth or 10;                -- Max inline chain depth to prevent code explosion
        
        -- P3: Constant Hoisting config
        -- Hoist frequently-accessed globals to local variables outside the dispatch loop
        enableConstantHoisting = config.enableConstantHoisting ~= false; -- Default: true (enabled)
        constantHoistThreshold = config.constantHoistThreshold or 3;     -- Min access count to hoist a global
        
        -- P3: Runtime tracking for global accesses
        globalAccessCounts = {};   -- name -> count of accesses
        hoistedGlobals = {};       -- name -> variable info for hoisted globals
        hoistedGlobalRegs = {};    -- reg -> true for hoisted global registers (don't free)
        
        -- VUL-2025-003 FIX: Per-compilation salt for non-uniform distribution
        compilationSalt = config.enableInstructionRandomization and math.random(0, 2^20) or 0;

        -- P4: Spill register variables (for registers MAX_REGS to MAX_REGS + SPILL_REGS - 1)
        -- These are declared as local variables instead of using table indexing
        spillVars = {};

        -- P5: Specialized Instruction Patterns config
        -- Optimize common patterns like string concatenation chains and increment/decrement
        enableSpecializedPatterns = config.enableSpecializedPatterns ~= false; -- Default: true (enabled)
        strCatChainThreshold = config.strCatChainThreshold or 3; -- Min operands for table.concat optimization

        -- P6: Loop Unrolling config
        -- Unroll small numeric for loops with constant bounds
        enableLoopUnrolling = config.enableLoopUnrolling or false; -- Default: false (disabled for security, enable for performance)
        maxUnrollIterations = config.maxUnrollIterations or 8; -- Max iterations to unroll a loop

        -- P7: Tail Call Optimization config
        -- Emit proper tail calls for return statements with a single function call
        enableTailCallOptimization = config.enableTailCallOptimization ~= false; -- Default: true (enabled)

        -- P8: Dead Code Elimination config
        -- Remove unreachable blocks, dead stores, and redundant jumps
        enableDeadCodeElimination = config.enableDeadCodeElimination ~= false; -- Default: true (enabled)

        -- S1: Opcode Shuffling config
        -- Randomize block external IDs with gaps to confuse static analysis
        enableOpcodeShuffling = config.enableOpcodeShuffling or false; -- Default: false (disabled)
        opcodeMap = {}; -- Maps internal block ID -> external block ID
        reverseOpcodeMap = {}; -- Maps external block ID -> internal block ID
        nextShuffledId = 1; -- Counter for generating shuffled IDs

        -- S2: Dynamic Register Remapping config
        -- Permute register indices at compile time, inject ghost registers
        enableRegisterRemapping = config.enableRegisterRemapping or false; -- Default: false (disabled)
        ghostRegisterDensity = config.ghostRegisterDensity or 15; -- Percentage (0-100) of statements to inject ghost writes
        registerShuffleMap = nil; -- Will be initialized if enabled
        registerReverseMap = nil; -- Will be initialized if enabled
        ghostRegisters = {}; -- Track ghost register allocations
        ghostRegisterCounter = 0; -- Count of ghost registers allocated

        -- S4: Multi-Layer String Encryption config
        -- Chain XOR → Caesar → Substitution encryption for enhanced security
        enableMultiLayerEncryption = config.enableMultiLayerEncryption or false; -- Default: false (use single-layer LCG)
        encryptionLayers = config.encryptionLayers or 3; -- Number of encryption layers (1-5)

        -- S6: Instruction Polymorphism config
        -- Generate semantically equivalent but syntactically different code patterns
        enableInstructionPolymorphism = config.enableInstructionPolymorphism or false; -- Default: false (disabled)
        polymorphismRate = config.polymorphismRate or 50; -- Percentage (0-100) of expressions to transform

        -- P11: Peephole Optimization config
        -- Apply local pattern optimizations to instruction sequences
        enablePeepholeOptimization = config.enablePeepholeOptimization ~= false; -- Default: true (enabled)
        maxPeepholeIterations = config.maxPeepholeIterations or 5; -- Max optimization iterations per block

        -- P15: Extended Strength Reduction config
        -- Additional patterns: x * 4 -> (x + x) + (x + x), x / 2 -> x * 0.5, x % (2^n) -> bit ops
        enableStrengthReduction = config.enableStrengthReduction ~= false; -- Default: true (enabled)

        -- P9: Inline Caching for Globals config
        -- Cache resolved global lookups for hot paths
        enableInlineCaching = config.enableInlineCaching or false; -- Default: false (disabled)
        inlineCacheThreshold = config.inlineCacheThreshold or 5; -- Min accesses to cache a global

        -- P10: Loop Invariant Code Motion (LICM) config
        -- Hoist invariant computations out of loops
        enableLICM = config.enableLICM or false; -- Default: false (disabled)
        licmMinIterations = config.licmMinIterations or 2; -- Min loop iterations to apply LICM

        -- P14: Common Subexpression Elimination (CSE) config
        -- Reuse previously computed expression results
        enableCSE = config.enableCSE or false; -- Default: false (disabled)
        maxCSEIterations = config.maxCSEIterations or 3; -- Max optimization iterations

        -- P12: Small Function Inlining config
        -- Inline small local functions at call sites
        enableFunctionInlining = config.enableFunctionInlining or false; -- Default: false (disabled)
        maxInlineFunctionSize = config.maxInlineFunctionSize or 10; -- Max statements in function body
        maxInlineParameters = config.maxInlineParameters or 5; -- Max parameters for inlining
        maxInlineDepth = config.maxInlineDepth or 3; -- Max nesting depth for inline expansions

        -- P17: Table Pre-sizing config
        -- Emit table constructors with size hints when known
        enableTablePresizing = config.enableTablePresizing or false; -- Default: false (disabled)
        tablePresizeArrayThreshold = config.tablePresizeArrayThreshold or 4; -- Min array elements to add size hint
        tablePresizeHashThreshold = config.tablePresizeHashThreshold or 4; -- Min hash elements to add size hint

        -- P18: Vararg Optimization config
        -- Optimize common vararg patterns for better performance
        enableVarargOptimization = config.enableVarargOptimization or false; -- Default: false (disabled)

        -- P19: Copy Propagation config
        -- Eliminate redundant register copies by forward-substituting values
        enableCopyPropagation = config.enableCopyPropagation or false; -- Default: false (disabled)
        maxCopyPropagationIterations = config.maxCopyPropagationIterations or 3; -- Max optimization iterations

        -- P20: Allocation Sinking config
        -- Defer/eliminate memory allocations to reduce GC pressure
        enableAllocationSinking = config.enableAllocationSinking or false; -- Default: false (disabled)

        -- D1: Encrypted Block IDs config
        -- XOR-encrypt block IDs with per-compilation seed to prevent pattern matching
        enableEncryptedBlockIds = config.enableEncryptedBlockIds or false; -- Default: false (disabled)
        blockIdEncryptionSeed = nil; -- Generated at compile time if enabled
        blockSeedVar = nil; -- Variable for storing seed in generated code
        bitVar = nil; -- Reference to bit library (bit32 or bit)

        -- D2: Randomized BST Comparison Order config
        -- Randomly flip comparison operators in BST dispatch for obfuscation
        enableRandomizedBSTOrder = config.enableRandomizedBSTOrder or false; -- Default: false (disabled)
        bstRandomizationRate = config.bstRandomizationRate or 50; -- Percentage (0-100) of nodes to randomize

        -- D3: Hybrid Hot-Path Dispatch config
        -- Use table dispatch for hot blocks (loops), BST for cold blocks
        enableHybridDispatch = config.enableHybridDispatch or false; -- Default: false (disabled)
        hybridHotBlockThreshold = config.hybridHotBlockThreshold or 2; -- Min iterations to consider "hot"
        maxHybridHotBlocks = config.maxHybridHotBlocks or 20; -- Max blocks to put in hot table
        hotBlockIds = nil; -- Set of hot block IDs for hybrid dispatch

        VAR_REGISTER = newproxy(false);
        RETURN_ALL = newproxy(false); 
        POS_REGISTER = newproxy(false);
        RETURN_REGISTER = newproxy(false);
        UPVALUE = newproxy(false);

        MAX_REGS = MAX_REGS; -- Expose MAX_REGS
        SPILL_REGS = SPILL_REGS; -- P4: Expose SPILL_REGS

        BIN_OPS = lookupify{
            AstKind.LessThanExpression,
            AstKind.GreaterThanExpression,
            AstKind.LessThanOrEqualsExpression,
            AstKind.GreaterThanOrEqualsExpression,
            AstKind.NotEqualsExpression,
            AstKind.EqualsExpression,
            AstKind.StrCatExpression,
            AstKind.AddExpression,
            AstKind.SubExpression,
            AstKind.MulExpression,
            AstKind.DivExpression,
            AstKind.ModExpression,
            AstKind.PowExpression,
        };
    };

    setmetatable(compiler, self);
    self.__index = self;

    return compiler;
end

-- ============================================================================
-- Block Management
-- ============================================================================

function Compiler:createBlock()
    -- Internal ID is always sequential for ordering
    local internalId = #self.blocks + 1;
    
    local externalId;
    
    -- S1: Opcode Shuffling - generate randomized external IDs with gaps
    if self.enableOpcodeShuffling then
        repeat
            -- Generate external ID with random gaps
            -- Format: (random 4-digit * 1000) + sequential counter
            -- This creates large gaps that prevent pattern-based deobfuscation
            local randomBase = math.random(1000, 9999)
            externalId = randomBase * 1000 + self.nextShuffledId
            self.nextShuffledId = self.nextShuffledId + 1
        until not self.usedBlockIds[externalId];
        
        -- Store mappings for S1
        self.opcodeMap[internalId] = externalId
        self.reverseOpcodeMap[externalId] = internalId
        
    elseif self.enableInstructionRandomization then
        -- VUL-2025-003 FIX: Non-uniform distribution to prevent statistical fingerprinting
        repeat
            -- Use exponential distribution with random base and exponent
            local base = math.random(0, 2^20)
            local exp = math.random(0, 5)
            externalId = (base * (2^exp)) % (2^25)
            
            -- Add per-compilation salt to prevent signature matching
            externalId = (externalId + self.compilationSalt) % (2^25)
        until not self.usedBlockIds[externalId];
    else
        -- OPTIMIZATION: Use sequential IDs when randomization is disabled
        -- This reduces bytecode size (smaller numbers) and potentially improves dispatch slightly
        externalId = internalId;
    end
    
    -- D1: Encrypt block external ID with XOR seed (compile-time encryption)
    -- This makes the block IDs appear random and prevents pattern matching
    if self.enableEncryptedBlockIds and self.blockIdEncryptionSeed then
        -- Use host Lua's bit library for compile-time XOR
        local bxor = bit32 and bit32.bxor or (bit and bit.bxor) or function(a, b)
            -- Portable XOR fallback for compile-time (host Lua may lack bit libraries)
            local result = 0
            local bitval = 1
            while a > 0 or b > 0 do
                local abit = a % 2
                local bbit = b % 2
                if abit ~= bbit then result = result + bitval end
                a = math.floor(a / 2)
                b = math.floor(b / 2)
                bitval = bitval * 2
            end
            return result
        end
        externalId = bxor(externalId, self.blockIdEncryptionSeed)
    end
    
    self.usedBlockIds[externalId] = true;

    local scope = Scope:new(self.containerFuncScope);
    local block = {
        id = externalId; -- Use external ID for dispatch (what appears in bytecode)
        internalId = internalId; -- Internal ID for ordering (used for optimization passes)
        statements = {

        };
        scope = scope;
        advanceToNextBlock = true;
    };
    table.insert(self.blocks, block);
    return block;
end

function Compiler:createJunkBlock()
    return VmGen.createJunkBlock(self);
end

function Compiler:setActiveBlock(block)
    self.activeBlock = block;
end

function Compiler:addStatement(statement, writes, reads, usesUpvals)
    if(self.activeBlock.advanceToNextBlock) then  
        table.insert(self.activeBlock.statements, {
            statement = statement,
            writes = lookupify(writes),
            reads = lookupify(reads),
            usesUpvals = usesUpvals or false,
        });
    end
end

-- ============================================================================
-- Register Module Delegation
-- ============================================================================

function Compiler:freeRegister(id, force)
    return Registers.freeRegister(self, id, force)
end

function Compiler:isVarRegister(id)
    return Registers.isVarRegister(self, id)
end

function Compiler:allocRegister(isVar, forceNumeric)
    return Registers.allocRegister(self, isVar, forceNumeric)
end

function Compiler:getVarRegister(scope, id, functionDepth, potentialId)
    return Registers.getVarRegister(self, scope, id, functionDepth, potentialId)
end

function Compiler:getRegisterVarId(id)
    return Registers.getRegisterVarId(self, id)
end

function Compiler:isSafeExpression(expr)
    return Registers.isSafeExpression(self, expr)
end

function Compiler:isLiteral(expr)
    return Registers.isLiteral(self, expr)
end

function Compiler:compileOperand(scope, expr, funcDepth)
    return Registers.compileOperand(self, scope, expr, funcDepth)
end

function Compiler:register(scope, id)
    return Registers.register(self, scope, id)
end

function Compiler:registerList(scope, ids)
    return Registers.registerList(self, scope, ids)
end

function Compiler:registerAssignment(scope, id)
    return Registers.registerAssignment(self, scope, id)
end

function Compiler:setRegister(scope, id, val, compoundArg)
    return Registers.setRegister(self, scope, id, val, compoundArg)
end

function Compiler:setRegisters(scope, ids, vals)
    return Registers.setRegisters(self, scope, ids, vals)
end

function Compiler:copyRegisters(scope, to, from)
    return Registers.copyRegisters(self, scope, to, from)
end

function Compiler:resetRegisters()
    return Registers.resetRegisters(self)
end

function Compiler:pos(scope)
    return Registers.pos(self, scope)
end

function Compiler:posAssignment(scope)
    return Registers.posAssignment(self, scope)
end

function Compiler:args(scope)
    return Registers.args(self, scope)
end

function Compiler:unpack(scope)
    return Registers.unpack(self, scope)
end

function Compiler:env(scope)
    return Registers.env(self, scope)
end

function Compiler:jmp(scope, to)
    return Registers.jmp(self, scope, to)
end

function Compiler:setPos(scope, val)
    return Registers.setPos(self, scope, val)
end

function Compiler:setReturn(scope, val)
    return Registers.setReturn(self, scope, val)
end

function Compiler:getReturn(scope)
    return Registers.getReturn(self, scope)
end

function Compiler:returnAssignment(scope)
    return Registers.returnAssignment(self, scope)
end

function Compiler:pushRegisterUsageInfo()
    return Registers.pushRegisterUsageInfo(self)
end

function Compiler:popRegisterUsageInfo()
    return Registers.popRegisterUsageInfo(self)
end

-- ============================================================================
-- P3: Constant Hoisting Module (Enhanced with P9: Inline Caching)
-- Hoist frequently-used globals to local variables outside the dispatch loop
-- P9 adds intelligent caching for immutable globals (math, string, table, etc.)
-- ============================================================================

-- Track a global access (Phase 1: counting)
function Compiler:trackGlobalAccess(name)
    if not self.enableConstantHoisting and not self.enableInlineCaching then return end
    self.globalAccessCounts[name] = (self.globalAccessCounts[name] or 0) + 1
end

-- Get the hoisted global variable expression if it exists (Phase 2: usage)
-- Returns the register ID if the global is hoisted, nil otherwise
function Compiler:getHoistedGlobal(name)
    if not self.enableConstantHoisting and not self.enableInlineCaching then return nil end
    return self.hoistedGlobals[name]
end

-- Emit hoisted global declarations (called before the dispatch loop in vm.lua)
-- Creates local variables for frequently-accessed globals
-- P9 Enhancement: Immutable globals have lower thresholds for caching
function Compiler:emitHoistedGlobals()
    if not self.enableConstantHoisting and not self.enableInlineCaching then return {} end
    
    local hoistStatements = {}
    local threshold = self.constantHoistThreshold or 3
    local inlineCacheThreshold = self.inlineCacheThreshold or 5
    local scope = self.containerFuncScope
    
    -- P9: Apply inline caching enhancement before sorting
    if self.enableInlineCaching then
        InlineCache.enhanceHoisting(self)
    end
    
    -- Sort globals by access count for deterministic output
    local sortedGlobals = {}
    for name, count in pairs(self.globalAccessCounts) do
        -- P9: Immutable globals (from InlineCache whitelist) have lower threshold
        local effectiveThreshold = threshold
        if self.enableInlineCaching and InlineCache.isImmutable(name) then
            effectiveThreshold = 2 -- Immutable globals are cheap to cache
        end
        
        if count >= effectiveThreshold then
            table.insert(sortedGlobals, {
                name = name,
                count = count,
                isImmutable = self.enableInlineCaching and InlineCache.isImmutable(name)
            })
        end
    end
    table.sort(sortedGlobals, function(a, b)
        -- P9: Prioritize immutable globals
        if a.isImmutable ~= b.isImmutable then
            return a.isImmutable -- true sorts before false
        end
        if a.count ~= b.count then return a.count > b.count end
        return a.name < b.name
    end)
    
    -- Create hoisted variables for each frequent global
    for _, entry in ipairs(sortedGlobals) do
        local name = entry.name
        
        -- Add variable to containerFuncScope
        local hoistVar = scope:addVariable()
        
        -- Create initialization: local _hoisted = _ENV["globalName"]
        -- Handle nested globals like "table.insert" -> _ENV["table"]["insert"]
        local initExpr
        if name:find(".", 1, true) then
            -- Nested global: a.b.c -> _ENV["a"]["b"]["c"]
            local parts = {}
            for part in name:gmatch("[^.]+") do
                table.insert(parts, part)
            end
            
            initExpr = Ast.IndexExpression(
                Ast.VariableExpression(self.scope, self.envVar),
                Ast.StringExpression(parts[1])
            )
            for i = 2, #parts do
                initExpr = Ast.IndexExpression(initExpr, Ast.StringExpression(parts[i]))
            end
            
            -- Add reference to env
            scope:addReferenceToHigherScope(self.scope, self.envVar)
        else
            -- Simple global: _ENV["name"]
            scope:addReferenceToHigherScope(self.scope, self.envVar)
            initExpr = Ast.IndexExpression(
                Ast.VariableExpression(self.scope, self.envVar),
                Ast.StringExpression(name)
            )
        end
        
        -- Create the declaration statement
        local declStat = Ast.LocalVariableDeclaration(scope, {hoistVar}, {initExpr})
        table.insert(hoistStatements, declStat)
        
        -- Store the hoisted variable for later reference
        self.hoistedGlobals[name] = hoistVar
    end
    
    return hoistStatements
end

-- ============================================================================
-- Upvalue Module Delegation
-- ============================================================================

function Compiler:isUpvalue(scope, id)
    return Upvalues.isUpvalue(self, scope, id)
end

function Compiler:makeUpvalue(scope, id)
    return Upvalues.makeUpvalue(self, scope, id)
end

function Compiler:createUpvaluesGcFunc()
    return Upvalues.createUpvaluesGcFunc(self)
end

function Compiler:createFreeUpvalueFunc()
    return Upvalues.createFreeUpvalueFunc(self)
end

function Compiler:createUpvaluesProxyFunc()
    return Upvalues.createUpvaluesProxyFunc(self)
end

function Compiler:createAllocUpvalFunction()
    return Upvalues.createAllocUpvalFunction(self)
end

function Compiler:setUpvalueMember(scope, idExpr, valExpr, compoundConstructor)
    return Upvalues.setUpvalueMember(self, scope, idExpr, valExpr, compoundConstructor)
end

function Compiler:getUpvalueMember(scope, idExpr)
    return Upvalues.getUpvalueMember(self, scope, idExpr)
end

-- ============================================================================
-- VM Generation Delegation
-- ============================================================================

function Compiler:emitContainerFuncBody()
    return VmGen.emitContainerFuncBody(self);
end

-- ============================================================================
-- Main Compilation Methods
-- ============================================================================

function Compiler:compile(ast)
    self.blocks = {};
    self.registers = {};
    self.activeBlock = nil;
    self.registersForVar = {};
    self.scopeFunctionDepths = {};
    self.maxUsedRegister = 0;
    self.usedRegisters = 0;
    self.registerVars = {};
    self.usedBlockIds = {};

    self.upvalVars = {};
    self.registerUsageStack = {};

    -- P3: Reset global access tracking
    self.globalAccessCounts = {};
    self.hoistedGlobals = {};
    self.hoistedGlobalRegs = {};

    -- P4: Reset spill register variables
    self.spillVars = {};

    -- S2: Initialize register remapping if enabled
    if self.enableRegisterRemapping then
        Registers.initRegisterRemapping(self);
    end

    -- P12: Initialize function inlining
    Inlining.init(self);

    -- P17: Initialize table pre-sizing
    TablePresizing.init(self);

    self.upvalsProxyLenReturn = math.random(-2^22, 2^22);

    local newGlobalScope = Scope:newGlobal();
    local psc = Scope:new(newGlobalScope, nil);

    local _, getfenvVar = newGlobalScope:resolve("getfenv");
    local _, tableVar  = newGlobalScope:resolve("table");
    local _, unpackVar = newGlobalScope:resolve("unpack");
    local _, envVar = newGlobalScope:resolve("_ENV");
    local _, newproxyVar = newGlobalScope:resolve("newproxy");
    local _, setmetatableVar = newGlobalScope:resolve("setmetatable");
    local _, getmetatableVar = newGlobalScope:resolve("getmetatable");
    local _, selectVar = newGlobalScope:resolve("select");
    
    psc:addReferenceToHigherScope(newGlobalScope, getfenvVar, 2);
    psc:addReferenceToHigherScope(newGlobalScope, tableVar);
    psc:addReferenceToHigherScope(newGlobalScope, unpackVar);
    psc:addReferenceToHigherScope(newGlobalScope, envVar);
    psc:addReferenceToHigherScope(newGlobalScope, newproxyVar);
    psc:addReferenceToHigherScope(newGlobalScope, setmetatableVar);
    psc:addReferenceToHigherScope(newGlobalScope, getmetatableVar);

    self.scope = Scope:new(psc);
    self.envVar = self.scope:addVariable();
    self.containerFuncVar = self.scope:addVariable();
    self.unpackVar = self.scope:addVariable();
    self.newproxyVar = self.scope:addVariable();
    self.setmetatableVar = self.scope:addVariable();
    self.getmetatableVar = self.scope:addVariable();
    self.selectVar = self.scope:addVariable();

    local argVar = self.scope:addVariable();

    -- Inject VM Constant Decryptor if enabled
    if self.encryptVmStrings then
        self.vmDecryptFuncVar = VmConstantEncryptor.injectDecoder(self);
    end

    self.containerFuncScope = Scope:new(self.scope);
    self.whileScope = Scope:new(self.containerFuncScope);

    -- D1: Generate block ID encryption seed and resolve bit library
    if self.enableEncryptedBlockIds then
        -- Generate 24-bit seed to stay within safe integer range
        self.blockIdEncryptionSeed = math.random(0, 2^24 - 1)
        
        -- Create seed variable for emission in generated code
        self.blockSeedVar = self.containerFuncScope:addVariable()
        
        -- Resolve bit library for XOR operations (Lua 5.1/LuaU compatible)
        -- Try bit32 first (Lua 5.2+, LuaU), then bit (Lua 5.1, LuaJIT)
        local _, bit32Var = newGlobalScope:resolve("bit32")
        local _, bitVar = newGlobalScope:resolve("bit")
        
        if bit32Var then
            self.bitVar = bit32Var
            psc:addReferenceToHigherScope(newGlobalScope, bit32Var)
        elseif bitVar then
            self.bitVar = bitVar
            psc:addReferenceToHigherScope(newGlobalScope, bitVar)
        end
        -- Note: If neither is available, we'll use a fallback in vm.lua
    end

    self.posVar = self.containerFuncScope:addVariable();
    self.argsVar = self.containerFuncScope:addVariable();
    self.registersTableVar = self.containerFuncScope:addVariable(); -- For array-based VM
    self.currentUpvaluesVar = self.containerFuncScope:addVariable();
    self.detectGcCollectVar = self.containerFuncScope:addVariable();
    self.returnVar  = self.containerFuncScope:addVariable();

    -- Upvalues Handling
    self.upvaluesTable = self.scope:addVariable();
    self.upvaluesReferenceCountsTable = self.scope:addVariable();
    self.allocUpvalFunction = self.scope:addVariable();
    self.currentUpvalId = self.scope:addVariable();

    -- Gc Handling for Upvalues
    self.upvaluesProxyFunctionVar = self.scope:addVariable();
    self.upvaluesGcFunctionVar = self.scope:addVariable();
    self.freeUpvalueFunc = self.scope:addVariable();

    self.createClosureVars = {};
    self.createVarargClosureVar = self.scope:addVariable();
    local createClosureScope = Scope:new(self.scope);
    local createClosurePosArg = createClosureScope:addVariable();
    local createClosureUpvalsArg = createClosureScope:addVariable();
    local createClosureProxyObject = createClosureScope:addVariable();
    local createClosureFuncVar = createClosureScope:addVariable();

    local createClosureSubScope = Scope:new(createClosureScope);

    local upvalEntries = {};
    local upvalueIds   = {};
    self.getUpvalueId = function(self, scope, id)
        local expression;
        local scopeFuncDepth = self.scopeFunctionDepths[scope];
        if(scopeFuncDepth == 0) then
            if upvalueIds[id] then
                return upvalueIds[id];
            end
            expression = Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {});
        else
            logger:error("Unresolved Upvalue, this error should not occur!");
        end
        table.insert(upvalEntries, Ast.TableEntry(expression));
        local uid = #upvalEntries;
        upvalueIds[id] = uid;
        return uid;
    end

    -- Reference to Higher Scopes
    createClosureSubScope:addReferenceToHigherScope(self.scope, self.containerFuncVar);
    createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosurePosArg)
    createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosureUpvalsArg, 1)
    createClosureScope:addReferenceToHigherScope(self.scope, self.upvaluesProxyFunctionVar)
    createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosureProxyObject);

    -- Invoke Compiler
    self:compileTopNode(ast);

    local functionNodeAssignments = {
        {
            var = Ast.AssignmentVariable(self.scope, self.containerFuncVar),
            val = Ast.FunctionLiteralExpression({
                Ast.VariableExpression(self.containerFuncScope, self.posVar),
                Ast.VariableExpression(self.containerFuncScope, self.argsVar),
                Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar),
                Ast.VariableExpression(self.containerFuncScope, self.detectGcCollectVar)
            }, self:emitContainerFuncBody());
        }, {
            var = Ast.AssignmentVariable(self.scope, self.createVarargClosureVar),
            val = Ast.FunctionLiteralExpression({
                    Ast.VariableExpression(createClosureScope, createClosurePosArg),
                    Ast.VariableExpression(createClosureScope, createClosureUpvalsArg),
                },
                Ast.Block({
                    Ast.LocalVariableDeclaration(createClosureScope, {
                        createClosureProxyObject
                    }, {
                        Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.upvaluesProxyFunctionVar), {
                            Ast.VariableExpression(createClosureScope, createClosureUpvalsArg)
                        })
                    }),
                    Ast.LocalVariableDeclaration(createClosureScope, {createClosureFuncVar},{
                        Ast.FunctionLiteralExpression({
                            Ast.VarargExpression();
                        },
                        Ast.Block({
                            Ast.ReturnStatement{
                                Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.containerFuncVar), {
                                    Ast.VariableExpression(createClosureScope, createClosurePosArg),
                                    Ast.TableConstructorExpression({Ast.TableEntry(Ast.VarargExpression())}),
                                    Ast.VariableExpression(createClosureScope, createClosureUpvalsArg), -- Upvalues
                                    Ast.VariableExpression(createClosureScope, createClosureProxyObject)
                                })
                            }
                        }, createClosureSubScope)
                        );
                    });
                    Ast.ReturnStatement{Ast.VariableExpression(createClosureScope, createClosureFuncVar)};
                }, createClosureScope)
            );
        }, {
            var = Ast.AssignmentVariable(self.scope, self.upvaluesTable),
            val = Ast.TableConstructorExpression({}),
        }, {
            var = Ast.AssignmentVariable(self.scope, self.upvaluesReferenceCountsTable),
            val = Ast.TableConstructorExpression({}),
        }, {
            var = Ast.AssignmentVariable(self.scope, self.allocUpvalFunction),
            val = self:createAllocUpvalFunction(),
        }, {
            var = Ast.AssignmentVariable(self.scope, self.currentUpvalId),
            val = Ast.NumberExpression(0),
        }, {
            var = Ast.AssignmentVariable(self.scope, self.upvaluesProxyFunctionVar),
            val = self:createUpvaluesProxyFunc(),
        }, {
            var = Ast.AssignmentVariable(self.scope, self.upvaluesGcFunctionVar),
            val = self:createUpvaluesGcFunc(),
        }, {
            var = Ast.AssignmentVariable(self.scope, self.freeUpvalueFunc),
            val = self:createFreeUpvalueFunc(),
        },
    }

    local tbl = {
        Ast.VariableExpression(self.scope, self.containerFuncVar),
        Ast.VariableExpression(self.scope, self.createVarargClosureVar),
        Ast.VariableExpression(self.scope, self.upvaluesTable),
        Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable),
        Ast.VariableExpression(self.scope, self.allocUpvalFunction),
        Ast.VariableExpression(self.scope, self.currentUpvalId),
        Ast.VariableExpression(self.scope, self.upvaluesProxyFunctionVar),
        Ast.VariableExpression(self.scope, self.upvaluesGcFunctionVar),
        Ast.VariableExpression(self.scope, self.freeUpvalueFunc),
    };
    for i, entry in pairs(self.createClosureVars) do
        table.insert(functionNodeAssignments, entry);
        table.insert(tbl, Ast.VariableExpression(entry.var.scope, entry.var.id));
    end

    util.shuffle(functionNodeAssignments);
    local assignmentStatLhs, assignmentStatRhs = {}, {};
    for i, v in ipairs(functionNodeAssignments) do
        assignmentStatLhs[i] = v.var;
        assignmentStatRhs[i] = v.val;
    end

    -- Emit Code
    local functionNode = Ast.FunctionLiteralExpression({
        Ast.VariableExpression(self.scope, self.envVar),
        Ast.VariableExpression(self.scope, self.unpackVar),
        Ast.VariableExpression(self.scope, self.newproxyVar),
        Ast.VariableExpression(self.scope, self.setmetatableVar),
        Ast.VariableExpression(self.scope, self.getmetatableVar),
        Ast.VariableExpression(self.scope, self.selectVar),
        Ast.VariableExpression(self.scope, argVar),
        unpack(util.shuffle(tbl))
    }, Ast.Block({
        Ast.AssignmentStatement(assignmentStatLhs, assignmentStatRhs);
        Ast.ReturnStatement{
            Ast.FunctionCallExpression(Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.createVarargClosureVar), {
                    Ast.NumberExpression(self.startBlockId);
                    Ast.TableConstructorExpression(upvalEntries);
                }), {Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.unpackVar), {Ast.VariableExpression(self.scope, argVar)})});
        }
    }, self.scope));

    return Ast.TopNode(Ast.Block({
        Ast.ReturnStatement{Ast.FunctionCallExpression(functionNode, {
            Ast.OrExpression(Ast.AndExpression(Ast.VariableExpression(newGlobalScope, getfenvVar), Ast.FunctionCallExpression(Ast.VariableExpression(newGlobalScope, getfenvVar), {})), Ast.VariableExpression(newGlobalScope, envVar));
            Ast.OrExpression(Ast.VariableExpression(newGlobalScope, unpackVar), Ast.IndexExpression(Ast.VariableExpression(newGlobalScope, tableVar), Ast.StringExpression("unpack")));
            Ast.VariableExpression(newGlobalScope, newproxyVar);
            Ast.VariableExpression(newGlobalScope, setmetatableVar);
            Ast.VariableExpression(newGlobalScope, getmetatableVar);
            Ast.VariableExpression(newGlobalScope, selectVar);
            Ast.TableConstructorExpression({
                Ast.TableEntry(Ast.VarargExpression());
            })
        })};
    }, psc), newGlobalScope);
end

function Compiler:getCreateClosureVar(argCount)
    if not self.createClosureVars[argCount] then
        local var = Ast.AssignmentVariable(self.scope, self.scope:addVariable());
        local createClosureScope = Scope:new(self.scope);
        local createClosureSubScope = Scope:new(createClosureScope);
        
        local createClosurePosArg = createClosureScope:addVariable();
        local createClosureUpvalsArg = createClosureScope:addVariable();
        local createClosureProxyObject = createClosureScope:addVariable();
        local createClosureFuncVar = createClosureScope:addVariable();

        createClosureSubScope:addReferenceToHigherScope(self.scope, self.containerFuncVar);
        createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosurePosArg)
        createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosureUpvalsArg, 1)
        createClosureScope:addReferenceToHigherScope(self.scope, self.upvaluesProxyFunctionVar)
        createClosureSubScope:addReferenceToHigherScope(createClosureScope, createClosureProxyObject);

        local  argsTb, argsTb2 = {}, {};
        for i = 1, argCount do
            local arg = createClosureSubScope:addVariable()
            argsTb[i] = Ast.VariableExpression(createClosureSubScope, arg);
            argsTb2[i] = Ast.TableEntry(Ast.VariableExpression(createClosureSubScope, arg));
        end

        local val = Ast.FunctionLiteralExpression({
            Ast.VariableExpression(createClosureScope, createClosurePosArg),
            Ast.VariableExpression(createClosureScope, createClosureUpvalsArg),
        }, Ast.Block({
                Ast.LocalVariableDeclaration(createClosureScope, {
                    createClosureProxyObject
                }, {
                    Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.upvaluesProxyFunctionVar), {
                        Ast.VariableExpression(createClosureScope, createClosureUpvalsArg)
                    })
                }),
                Ast.LocalVariableDeclaration(createClosureScope, {createClosureFuncVar},{
                    Ast.FunctionLiteralExpression(argsTb,
                    Ast.Block({
                        Ast.ReturnStatement{
                            Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.containerFuncVar), {
                                Ast.VariableExpression(createClosureScope, createClosurePosArg),
                                Ast.TableConstructorExpression(argsTb2),
                                Ast.VariableExpression(createClosureScope, createClosureUpvalsArg), -- Upvalues
                                Ast.VariableExpression(createClosureScope, createClosureProxyObject)
                            })
                        }
                    }, createClosureSubScope)
                    );
                });
                Ast.ReturnStatement{Ast.VariableExpression(createClosureScope, createClosureFuncVar)}
            }, createClosureScope)
        );
        self.createClosureVars[argCount] = {
            var = var,
            val = val,
        }
    end

    
    local var = self.createClosureVars[argCount].var;
    return var.scope, var.id;
end

function Compiler:compileTopNode(node)
    -- Create Initial Block
    local startBlock = self:createBlock();
    local scope = startBlock.scope;
    self.startBlockId = startBlock.id;
    self:setActiveBlock(startBlock);

    local varAccessLookup = lookupify{
        AstKind.AssignmentVariable,
        AstKind.VariableExpression,
        AstKind.FunctionDeclaration,
        AstKind.LocalFunctionDeclaration,
    }

    local functionLookup = lookupify{
        AstKind.FunctionDeclaration,
        AstKind.LocalFunctionDeclaration,
        AstKind.FunctionLiteralExpression,
        AstKind.TopNode,
    }
    -- Collect Upvalues AND P3: Track Global Accesses
    visitast(node, function(node, data) 
        if node.kind == AstKind.Block then
            node.scope.__depth = data.functionData.depth;
        end

        if varAccessLookup[node.kind] then
            if not node.scope.isGlobal then
                if node.scope.__depth < data.functionData.depth then
                    if not self:isUpvalue(node.scope, node.id) then
                        self:makeUpvalue(node.scope, node.id);
                    end
                end
            else
                -- P3: Track global accesses for constant hoisting
                local name = node.scope:getVariableName(node.id)
                if name then
                    self:trackGlobalAccess(name)
                end
            end
        end
        
        -- P3: Track nested global accesses (table.insert, string.format, etc.)
        -- These appear as IndexExpression where base is a global VariableExpression
        if node.kind == AstKind.IndexExpression then
            local base = node.base
            local index = node.index
            
            -- Check if base is a global variable and index is a string constant
            if base and base.kind == AstKind.VariableExpression and 
               base.scope and base.scope.isGlobal and
               index and index.kind == AstKind.StringExpression then
                
                local baseName = base.scope:getVariableName(base.id)
                local indexName = index.value
                
                if baseName and indexName then
                    -- Track as "baseName.indexName" (e.g., "table.insert")
                    local nestedName = baseName .. "." .. indexName
                    self:trackGlobalAccess(nestedName)
                end
            end
        end
    end, nil, nil)

    self.varargReg = self:allocRegister(true);
    scope:addReferenceToHigherScope(self.containerFuncScope, self.argsVar);
    scope:addReferenceToHigherScope(self.scope, self.selectVar);
    scope:addReferenceToHigherScope(self.scope, self.unpackVar);
    self:addStatement(self:setRegister(scope, self.varargReg, Ast.VariableExpression(self.containerFuncScope, self.argsVar)), {self.varargReg}, {}, false);

    -- Compile Block
    self:compileBlock(node.body, 0);
    if(self.activeBlock.advanceToNextBlock) then
        self:addStatement(self:setPos(self.activeBlock.scope, nil), {self.POS_REGISTER}, {}, false);
        self:addStatement(self:setReturn(self.activeBlock.scope, Ast.TableConstructorExpression({})), {self.RETURN_REGISTER}, {}, false)
        self.activeBlock.advanceToNextBlock = false;
    end

    self:resetRegisters();
end

function Compiler:compileFunction(node, funcDepth)
    funcDepth = funcDepth + 1;
    local oldActiveBlock = self.activeBlock;

    local upperVarargReg = self.varargReg;
    self.varargReg = nil;

    local upvalueExpressions = {};
    local upvalueIds = {};
    local usedRegs = {};

    local oldGetUpvalueId = self.getUpvalueId;
    self.getUpvalueId = function(self, scope, id)
        if(not upvalueIds[scope]) then
            upvalueIds[scope] = {};
        end
        if(upvalueIds[scope][id]) then
            return upvalueIds[scope][id];
        end
        local scopeFuncDepth = self.scopeFunctionDepths[scope];
        local expression;
        if(scopeFuncDepth == funcDepth) then
            oldActiveBlock.scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
            expression = Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {});
        elseif(scopeFuncDepth == funcDepth - 1) then
            local varReg = self:getVarRegister(scope, id, scopeFuncDepth, nil);
            expression = self:register(oldActiveBlock.scope, varReg);
            table.insert(usedRegs, varReg);
        else
            local higherId = oldGetUpvalueId(self, scope, id);
            oldActiveBlock.scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
            expression = Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(higherId));
        end
        table.insert(upvalueExpressions, Ast.TableEntry(expression));
        local uid = #upvalueExpressions;
        upvalueIds[scope][id] = uid;
        return uid;
    end

    local block = self:createBlock();
    self:setActiveBlock(block);
    local scope = self.activeBlock.scope;
    self:pushRegisterUsageInfo();

    -- OPTIMIZATION: Shared Constant Pool
    local constantCounts = {}

    local function scanConstants(n)
        if not n then return end
        if type(n) ~= "table" then return end

        if n.kind == AstKind.StringExpression or n.kind == AstKind.NumberExpression then
            local key = n.value
            if type(key) == "number" or type(key) == "string" then
                 constantCounts[key] = (constantCounts[key] or 0) + 1
            end
        elseif n.kind == AstKind.VariableExpression and n.scope.isGlobal then
            -- Also count global variable names as string constants
            local name = n.scope:getVariableName(n.id)
            if name then
                constantCounts[name] = (constantCounts[name] or 0) + 1
            end
        end

        -- Recursively scan children
        for k, v in pairs(n) do
            if type(v) == "table" and k ~= "scope" and k ~= "parentScope" then -- Avoid cycles and scopes
                if v.kind then -- It's a node
                    scanConstants(v)
                elseif type(k) == "number" then -- Array of nodes (e.g. statements)
                    scanConstants(v)
                end
            end
        end
    end

    scanConstants(node.body)

    -- Allocate registers for frequent constants
    -- We use a deterministic order to ensure consistency
    local sortedKeys = {}
    for k,v in pairs(constantCounts) do table.insert(sortedKeys, k) end
    table.sort(sortedKeys, function(a,b)
        if type(a) ~= type(b) then return type(a) < type(b) end
        return a < b
    end)

    for _, k in ipairs(sortedKeys) do
        local count = constantCounts[k]
        -- Policy: Hoist all strings, and numbers used > 1 time
        if type(k) == "string" or (type(k) == "number" and count > 1) then
            -- Use allocRegister with forceNumeric=true to avoid special registers
            local reg = self:allocRegister(false, true)

            local expr
            if self.encryptVmStrings and type(k) == "string" then
                -- Encrypt string constants if enabled
                local encryptedBytes, seed = VmConstantEncryptor.encrypt(k)
                local byteEntries = {}
                for _, b in ipairs(encryptedBytes) do
                    table.insert(byteEntries, Ast.TableEntry(Ast.NumberExpression(b)))
                end

                -- Emit: DECRYPT(seed, {bytes})
                expr = Ast.FunctionCallExpression(
                    Ast.VariableExpression(self.scope, self.vmDecryptFuncVar),
                    {
                        Ast.NumberExpression(seed),
                        Ast.TableConstructorExpression(byteEntries)
                    }
                )
            else
                expr = type(k) == "string" and Ast.StringExpression(k) or Ast.NumberExpression(k)
            end

            self:addStatement(self:setRegister(scope, reg, expr), {reg}, {}, false)
            self.constants[k] = reg
            self.constantRegs[reg] = true
        end
    end

    for i, arg in ipairs(node.args) do
        if(arg.kind == AstKind.VariableExpression) then
            if(self:isUpvalue(arg.scope, arg.id)) then
                scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
                local argReg = self:getVarRegister(arg.scope, arg.id, funcDepth, nil);
                self:addStatement(self:setRegister(scope, argReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})), {argReg}, {}, false);
                self:addStatement(self:setUpvalueMember(scope, self:register(scope, argReg), Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.argsVar), Ast.NumberExpression(i))), {}, {argReg}, true);
            else
                local argReg = self:getVarRegister(arg.scope, arg.id, funcDepth, nil);
                scope:addReferenceToHigherScope(self.containerFuncScope, self.argsVar);
                self:addStatement(self:setRegister(scope, argReg, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.argsVar), Ast.NumberExpression(i))), {argReg}, {}, false);
            end
        else
            self.varargReg = self:allocRegister(true);
            scope:addReferenceToHigherScope(self.containerFuncScope, self.argsVar);
            scope:addReferenceToHigherScope(self.scope, self.selectVar);
            scope:addReferenceToHigherScope(self.scope, self.unpackVar);
            self:addStatement(self:setRegister(scope, self.varargReg, Ast.TableConstructorExpression({
                Ast.TableEntry(Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.selectVar), {
                    Ast.NumberExpression(i);
                    Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.unpackVar), {
                        Ast.VariableExpression(self.containerFuncScope, self.argsVar),
                    });
                })),
            })), {self.varargReg}, {}, false);
        end
    end

    self:compileBlock(node.body, funcDepth);
    if(self.activeBlock.advanceToNextBlock) then
        self:addStatement(self:setPos(self.activeBlock.scope, nil), {self.POS_REGISTER}, {}, false);
        self:addStatement(self:setReturn(self.activeBlock.scope, Ast.TableConstructorExpression({})), {self.RETURN_REGISTER}, {}, false);
        self.activeBlock.advanceToNextBlock = false;
    end

    if(self.varargReg) then
        self:freeRegister(self.varargReg, true);
    end
    self.varargReg = upperVarargReg;
    self.getUpvalueId = oldGetUpvalueId;

    self:popRegisterUsageInfo();
    self:setActiveBlock(oldActiveBlock);

    local scope = self.activeBlock.scope;
    
    local retReg = self:allocRegister(false);

    local isVarargFunction = #node.args > 0 and node.args[#node.args].kind == AstKind.VarargExpression;

    local retrieveExpression
    if isVarargFunction then
        scope:addReferenceToHigherScope(self.scope, self.createVarargClosureVar);
        retrieveExpression = Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.createVarargClosureVar), {
            Ast.NumberExpression(block.id),
            Ast.TableConstructorExpression(upvalueExpressions)
        });
    else
        local varScope, var = self:getCreateClosureVar(#node.args + math.random(0, 5));
        scope:addReferenceToHigherScope(varScope, var);
        retrieveExpression = Ast.FunctionCallExpression(Ast.VariableExpression(varScope, var), {
            Ast.NumberExpression(block.id),
            Ast.TableConstructorExpression(upvalueExpressions)
        });
    end

    self:addStatement(self:setRegister(scope, retReg, retrieveExpression), {retReg}, usedRegs, false);
    return retReg;
end

function Compiler:compileBlock(block, funcDepth)
    for i, stat in ipairs(block.statements) do
        self:compileStatement(stat, funcDepth);
    end

    local scope = self.activeBlock.scope;
    local regsToClear = {}
    local nils = {}

    for id, name in ipairs(block.scope.variables) do
        local varReg = self:getVarRegister(block.scope, id, funcDepth, nil);
        if self:isUpvalue(block.scope, id) then
            scope:addReferenceToHigherScope(self.scope, self.freeUpvalueFunc);
            self:addStatement(self:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.freeUpvalueFunc), {
                self:register(scope, varReg)
            })), {varReg}, {varReg}, false);
        else
            table.insert(regsToClear, varReg)
            table.insert(nils, Ast.NilExpression())
        end
        self:freeRegister(varReg, true);
    end

    if #regsToClear > 0 then
        self:addStatement(self:setRegisters(scope, regsToClear, nils), regsToClear, {}, false);
    end
end

function Compiler:compileStatement(statement, funcDepth)
    local handler = Statements[statement.kind]
    if handler then
        handler(self, statement, funcDepth)
    else
        logger:error(string.format("%s is not a compileable statement!", statement.kind));
    end
end

function Compiler:compileExpression(expression, funcDepth, numReturns, targetRegs)
    local handler = Expressions[expression.kind]
    if handler then
        return handler(self, expression, funcDepth, numReturns, targetRegs)
    else
        logger:error(string.format("%s is not an compliable expression!", expression.kind));
        return {}
    end
end



return Compiler;

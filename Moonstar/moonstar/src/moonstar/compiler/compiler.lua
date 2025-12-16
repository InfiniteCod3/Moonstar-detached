
-- compiler.lua
-- This Script contains the new Compiler

-- The max Number of variables used as registers
local MAX_REGS = 150;

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

local lookupify = util.lookupify;
local AstKind = Ast.AstKind;

local unpack = unpack or table.unpack;

-- PERF-OPT: Cache commonly used empty lookup tables to avoid repeated allocations
-- These are used frequently in addStatement calls with empty reads/writes
local EMPTY_LOOKUP = {};
local function lookupifyOrEmpty(tbl)
    if not tbl or #tbl == 0 then
        return EMPTY_LOOKUP;
    end
    return lookupify(tbl);
end

-- PERF-OPT: Pre-cache type function for hot loops
local type = type;
local pairs = pairs;
local ipairs = ipairs;
local floor = math.floor;
local random = math.random;

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
        freeRegisters = {}; -- Optimization: Free List (Stack)
        freeRegisterCount = 0; -- PERF-OPT #7: Counter for direct indexing (faster than table.insert/remove)
        nextScanIndex = 1; -- PERF-OPT #9: Track next scan index for amortized O(1) allocRegister
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
        
        -- VUL-2025-003 FIX: Per-compilation salt for non-uniform distribution
        compilationSalt = config.enableInstructionRandomization and math.random(0, 2^20) or 0;

        VAR_REGISTER = newproxy(false);
        RETURN_ALL = newproxy(false); 
        POS_REGISTER = newproxy(false);
        RETURN_REGISTER = newproxy(false);
        UPVALUE = newproxy(false);

        MAX_REGS = MAX_REGS; -- Expose MAX_REGS

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

function Compiler:createBlock()
    local id;
    if self.enableInstructionRandomization then
        -- VUL-2025-003 FIX: Non-uniform distribution to prevent statistical fingerprinting
        repeat
            -- Use exponential distribution with random base and exponent
            local base = math.random(0, 2^20)
            local exp = math.random(0, 5)
            id = (base * (2^exp)) % (2^25)
            
            -- Add per-compilation salt to prevent signature matching
            id = (id + self.compilationSalt) % (2^25)
        until not self.usedBlockIds[id];
    else
        -- OPTIMIZATION: Use sequential IDs when randomization is disabled
        -- This reduces bytecode size (smaller numbers) and potentially improves dispatch slightly
        id = #self.blocks + 1;
    end
    self.usedBlockIds[id] = true;

    local scope = Scope:new(self.containerFuncScope);
    local block = {
        id = id;
        statements = {

        };
        statementCount = 0; -- PERF-OPT #11: Track statement count for direct indexing
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
        -- PERF-OPT #11: Use direct indexing instead of table.insert
        -- This is a hot path called for every statement in the program
        local count = self.activeBlock.statementCount + 1
        -- PERF-OPT: Use lookupifyOrEmpty to avoid creating new tables for empty arrays
        self.activeBlock.statements[count] = {
            statement = statement,
            writes = lookupifyOrEmpty(writes),
            reads = lookupifyOrEmpty(reads),
            usesUpvals = usesUpvals or false,
        };
        self.activeBlock.statementCount = count
    end
end

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
    self.nextScanIndex = 1; -- PERF-OPT #9: Initialize scan index

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

    self.posVar = self.containerFuncScope:addVariable();
    self.argsVar = self.containerFuncScope:addVariable();
    self.registersTableVar = self.containerFuncScope:addVariable(); -- For array-based VM
    self.currentUpvaluesVar = self.containerFuncScope:addVariable();
    self.detectGcCollectVar = self.containerFuncScope:addVariable();
    self.returnVar  = self.containerFuncScope:addVariable();

    -- Upvalues Handling
    self.upvaluesTable = self.scope:addVariable();
    -- PERF-OPT #10: Cached local reference to upvaluesTable inside container function
    -- This reduces one scope lookup per upvalue access, providing ~10-20% speedup for upvalue-heavy code
    self.cachedUpvaluesTableVar = self.containerFuncScope:addVariable();
    self.upvaluesReferenceCountsTable = self.scope:addVariable();
    self.allocUpvalFunction = self.scope:addVariable();
    self.currentUpvalId = self.scope:addVariable();

    -- Gc Handling for Upvalues
    self.upvaluesProxyFunctionVar = self.scope:addVariable();
    self.upvaluesGcFunctionVar = self.scope:addVariable();
    self.freeUpvalueFunc = self.scope:addVariable();
    self.packFuncVar = self.scope:addVariable();

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
                                    Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.packFuncVar), {Ast.VarargExpression()}),
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
        }, {
            var = Ast.AssignmentVariable(self.scope, self.packFuncVar),
            val = Ast.FunctionLiteralExpression({
                Ast.VarargExpression()
            }, Ast.Block({
                Ast.ReturnStatement{
                    Ast.TableConstructorExpression({
                        Ast.KeyedTableEntry(Ast.StringExpression("n"), 
                            Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.selectVar), {
                                Ast.StringExpression("#"),
                                Ast.VarargExpression()
                            })
                        ),
                        Ast.TableEntry(Ast.VarargExpression())
                    })
                }
            }, Scope:new(self.scope))),
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
        Ast.VariableExpression(self.scope, self.packFuncVar),
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
                }), {Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.unpackVar), {
                    Ast.VariableExpression(self.scope, argVar),
                    Ast.NumberExpression(1),
                    Ast.IndexExpression(Ast.VariableExpression(self.scope, argVar), Ast.StringExpression("n"))
                })});
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

function Compiler:pushRegisterUsageInfo()
    table.insert(self.registerUsageStack, {
        usedRegisters = self.usedRegisters;
        registers = self.registers;
        freeRegisters = self.freeRegisters;
        freeRegisterCount = self.freeRegisterCount; -- PERF-OPT #7
        nextScanIndex = self.nextScanIndex; -- PERF-OPT #9
        constants = self.constants;
        constantRegs = self.constantRegs;
    });
    self.usedRegisters = 0;
    self.registers = {};
    self.freeRegisters = {};
    self.freeRegisterCount = 0; -- PERF-OPT #7
    self.nextScanIndex = 1; -- PERF-OPT #9: Reset scan index for new scope
    self.constants = {};
    self.constantRegs = {};
end

function Compiler:popRegisterUsageInfo()
    local info = table.remove(self.registerUsageStack);
    self.usedRegisters = info.usedRegisters;
    self.registers = info.registers;
    self.freeRegisters = info.freeRegisters;
    self.freeRegisterCount = info.freeRegisterCount; -- PERF-OPT #7
    self.nextScanIndex = info.nextScanIndex; -- PERF-OPT #9: Restore scan index
    self.constants = info.constants;
    self.constantRegs = info.constantRegs;
end

function Compiler:createUpvaluesGcFunc()
    local scope = Scope:new(self.scope);
    local selfVar = scope:addVariable();

    local x9wL4 = scope:addVariable();
    local p5tZ7 = scope:addVariable();

    local whileScope = Scope:new(scope);
    whileScope:addReferenceToHigherScope(self.scope, self.upvaluesReferenceCountsTable, 3);
    whileScope:addReferenceToHigherScope(scope, p5tZ7, 3);
    whileScope:addReferenceToHigherScope(scope, x9wL4, 3);

    local ifScope = Scope:new(whileScope);
    ifScope:addReferenceToHigherScope(self.scope, self.upvaluesReferenceCountsTable, 1);
    ifScope:addReferenceToHigherScope(self.scope, self.upvaluesTable, 1);
    

    return Ast.FunctionLiteralExpression({Ast.VariableExpression(scope, selfVar)}, Ast.Block({
        Ast.LocalVariableDeclaration(scope, {x9wL4, p5tZ7}, {Ast.NumberExpression(1), Ast.IndexExpression(Ast.VariableExpression(scope, selfVar), Ast.NumberExpression(1))}),
        Ast.WhileStatement(Ast.Block({
            Ast.AssignmentStatement({
                Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, p5tZ7)),
                Ast.AssignmentVariable(scope, x9wL4),
            }, {
                Ast.SubExpression(Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, p5tZ7)), Ast.NumberExpression(1)),
                Ast.AddExpression(unpack(util.shuffle{Ast.VariableExpression(scope, x9wL4), Ast.NumberExpression(1)})),
            }),
            Ast.IfStatement(Ast.EqualsExpression(unpack(util.shuffle{Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, p5tZ7)), Ast.NumberExpression(0)})), Ast.Block({
                Ast.AssignmentStatement({
                    Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, p5tZ7)),
                    Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesTable), Ast.VariableExpression(scope, p5tZ7)),
                }, {
                    Ast.NilExpression(),
                    Ast.NilExpression(),
                })
            }, ifScope), {}, nil),
            Ast.AssignmentStatement({
                Ast.AssignmentVariable(scope, p5tZ7),
            }, {
                Ast.IndexExpression(Ast.VariableExpression(scope, selfVar), Ast.VariableExpression(scope, x9wL4)),
            }),
        }, whileScope), Ast.VariableExpression(scope, p5tZ7), scope);
    }, scope));
end

function Compiler:createFreeUpvalueFunc()
    local scope = Scope:new(self.scope);
    local argVar = scope:addVariable();
    local ifScope = Scope:new(scope);
    ifScope:addReferenceToHigherScope(scope, argVar, 3);
    scope:addReferenceToHigherScope(self.scope, self.upvaluesReferenceCountsTable, 2);
    return Ast.FunctionLiteralExpression({Ast.VariableExpression(scope, argVar)}, Ast.Block({
        Ast.AssignmentStatement({
            Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar))
        }, {
            Ast.SubExpression(Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar)), Ast.NumberExpression(1));
        }),
        Ast.IfStatement(Ast.EqualsExpression(unpack(util.shuffle{Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar)), Ast.NumberExpression(0)})), Ast.Block({
            Ast.AssignmentStatement({
                Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(scope, argVar)),
                Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesTable), Ast.VariableExpression(scope, argVar)),
            }, {
                Ast.NilExpression(),
                Ast.NilExpression(),
            })
        }, ifScope), {}, nil)
    }, scope))
end

function Compiler:createUpvaluesProxyFunc()
    local scope = Scope:new(self.scope);
    scope:addReferenceToHigherScope(self.scope, self.newproxyVar);

    local entriesVar = scope:addVariable();

    local ifScope = Scope:new(scope);
    local proxyVar = ifScope:addVariable();
    local metatableVar = ifScope:addVariable();
    local elseScope = Scope:new(scope);
    ifScope:addReferenceToHigherScope(self.scope, self.newproxyVar);
    ifScope:addReferenceToHigherScope(self.scope, self.getmetatableVar);
    ifScope:addReferenceToHigherScope(self.scope, self.upvaluesGcFunctionVar);
    ifScope:addReferenceToHigherScope(scope, entriesVar);
    elseScope:addReferenceToHigherScope(self.scope, self.setmetatableVar);
    elseScope:addReferenceToHigherScope(scope, entriesVar);
    elseScope:addReferenceToHigherScope(self.scope, self.upvaluesGcFunctionVar);

    local forScope = Scope:new(scope);
    local forArg = forScope:addVariable();
    forScope:addReferenceToHigherScope(self.scope, self.upvaluesReferenceCountsTable, 2);
    forScope:addReferenceToHigherScope(scope, entriesVar, 2);

    return Ast.FunctionLiteralExpression({Ast.VariableExpression(scope, entriesVar)}, Ast.Block({
        Ast.ForStatement(forScope, forArg, Ast.NumberExpression(1), Ast.LenExpression(Ast.VariableExpression(scope, entriesVar)), Ast.NumberExpression(1), Ast.Block({
            Ast.AssignmentStatement({
                Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.IndexExpression(Ast.VariableExpression(scope, entriesVar), Ast.VariableExpression(forScope, forArg)))
            }, {
                Ast.AddExpression(unpack(util.shuffle{
                    Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.IndexExpression(Ast.VariableExpression(scope, entriesVar), Ast.VariableExpression(forScope, forArg))),
                    Ast.NumberExpression(1),
                }))
            })
        }, forScope), scope);
        Ast.IfStatement(Ast.VariableExpression(self.scope, self.newproxyVar), Ast.Block({
            Ast.LocalVariableDeclaration(ifScope, {proxyVar}, {
                Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.newproxyVar), {
                    Ast.BooleanExpression(true)
                });
            });
            Ast.LocalVariableDeclaration(ifScope, {metatableVar}, {
                Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.getmetatableVar), {
                    Ast.VariableExpression(ifScope, proxyVar);
                });
            });
            Ast.AssignmentStatement({
                Ast.AssignmentIndexing(Ast.VariableExpression(ifScope, metatableVar), Ast.StringExpression("__index")),
                Ast.AssignmentIndexing(Ast.VariableExpression(ifScope, metatableVar), Ast.StringExpression("__gc")),
                Ast.AssignmentIndexing(Ast.VariableExpression(ifScope, metatableVar), Ast.StringExpression("__len")),
            }, {
                Ast.VariableExpression(scope, entriesVar),
                Ast.VariableExpression(self.scope, self.upvaluesGcFunctionVar),
                Ast.FunctionLiteralExpression({}, Ast.Block({
                    Ast.ReturnStatement({Ast.NumberExpression(self.upvalsProxyLenReturn)})
                }, Scope:new(ifScope)));
            });
            Ast.ReturnStatement({
                Ast.VariableExpression(ifScope, proxyVar)
            })
        }, ifScope), {}, Ast.Block({
            Ast.ReturnStatement({Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.setmetatableVar), {
                Ast.TableConstructorExpression({}),
                Ast.TableConstructorExpression({
                    Ast.KeyedTableEntry(Ast.StringExpression("__gc"), Ast.VariableExpression(self.scope, self.upvaluesGcFunctionVar)),
                    Ast.KeyedTableEntry(Ast.StringExpression("__index"), Ast.VariableExpression(scope, entriesVar)),
                    Ast.KeyedTableEntry(Ast.StringExpression("__len"), Ast.FunctionLiteralExpression({}, Ast.Block({
                        Ast.ReturnStatement({Ast.NumberExpression(self.upvalsProxyLenReturn)})
                    }, Scope:new(ifScope)))),
                })
            })})
        }, elseScope));
    }, scope));
end

function Compiler:createAllocUpvalFunction()
    local scope = Scope:new(self.scope);
    scope:addReferenceToHigherScope(self.scope, self.currentUpvalId, 4);
    scope:addReferenceToHigherScope(self.scope, self.upvaluesReferenceCountsTable, 1);

    return Ast.FunctionLiteralExpression({}, Ast.Block({
        Ast.AssignmentStatement({
                Ast.AssignmentVariable(self.scope, self.currentUpvalId),
            },{
                Ast.AddExpression(unpack(util.shuffle({
                    Ast.VariableExpression(self.scope, self.currentUpvalId),
                    Ast.NumberExpression(1),
                }))),
            }
        ),
        Ast.AssignmentStatement({
            Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesReferenceCountsTable), Ast.VariableExpression(self.scope, self.currentUpvalId)),
        }, {
            Ast.NumberExpression(1),
        }),
        Ast.ReturnStatement({
            Ast.VariableExpression(self.scope, self.currentUpvalId),
        })
    }, scope));
end

function Compiler:emitContainerFuncBody()
    return VmGen.emitContainerFuncBody(self);
end

function Compiler:freeRegister(id, force)
    if self.constantRegs[id] then return end -- Never free constant registers

    -- Fix: Ensure we don't try to free special registers (userdata) into the free list
    -- freeRegisters should only contain numeric IDs
    if type(id) ~= "number" then
        -- If it's a userdata register (POS, RETURN, VAR), we just mark it free in self.registers if appropriate
        if force or not (self.registers[id] == self.VAR_REGISTER) then
             self.usedRegisters = self.usedRegisters - 1;
             self.registers[id] = false
        end
        return
    end

    if force or not (self.registers[id] == self.VAR_REGISTER) then
        self.usedRegisters = self.usedRegisters - 1;
        self.registers[id] = false
        -- PERF-OPT #7: Direct indexing instead of table.insert (faster)
        self.freeRegisterCount = self.freeRegisterCount + 1
        self.freeRegisters[self.freeRegisterCount] = id
    end
end

function Compiler:isVarRegister(id)
    return self.registers[id] == self.VAR_REGISTER;
end

function Compiler:allocRegister(isVar, forceNumeric)
    self.usedRegisters = self.usedRegisters + 1;

    if not isVar and not forceNumeric then
        -- POS register can be temporarily used
        if not self.registers[self.POS_REGISTER] then
            self.registers[self.POS_REGISTER] = true;
            return self.POS_REGISTER;
        end

        -- RETURN register can be temporarily used
        if not self.registers[self.RETURN_REGISTER] then
            self.registers[self.RETURN_REGISTER] = true;
            return self.RETURN_REGISTER;
        end
    end
    
    local id;
    -- PERF-OPT #7: Direct indexing instead of table.remove (faster)
    -- Try to reuse recently freed registers for better cache locality
    while self.freeRegisterCount > 0 do
        local candidate = self.freeRegisters[self.freeRegisterCount]
        self.freeRegisters[self.freeRegisterCount] = nil -- Clear reference
        self.freeRegisterCount = self.freeRegisterCount - 1
        if not self.registers[candidate] then
            id = candidate;
            break;
        end
        -- If register became occupied (e.g. by VAR assignment), discard and try next
    end

    if not id then
        -- OPTIMIZATION: Linear Scan Allocation (Fallback)
        -- Use the first available register to minimize stack size
        -- PERF-OPT #9: Start scan from last known free index (amortized O(1))
        id = self.nextScanIndex;
        while self.registers[id] do
            id = id + 1;
        end
        -- Update next scan index, assuming registers below id are occupied
        self.nextScanIndex = id + 1;
    end

    if id > self.maxUsedRegister then
        self.maxUsedRegister = id;
    end

    if(isVar) then
        self.registers[id] = self.VAR_REGISTER;
    else
        self.registers[id] = true
    end
    return id;
end

function Compiler:isUpvalue(scope, id)
    return self.upvalVars[scope] and self.upvalVars[scope][id];
end

function Compiler:makeUpvalue(scope, id)
    if(not self.upvalVars[scope]) then
        self.upvalVars[scope] = {}
    end
    self.upvalVars[scope][id] = true;
end

function Compiler:getVarRegister(scope, id, functionDepth, potentialId)
    if(not self.registersForVar[scope]) then
        self.registersForVar[scope] = {};
        self.scopeFunctionDepths[scope] = functionDepth;
    end

    local reg = self.registersForVar[scope][id];
    if not reg then
        if potentialId and self.registers[potentialId] ~= self.VAR_REGISTER and potentialId ~= self.POS_REGISTER and potentialId ~= self.RETURN_REGISTER then
            self.registers[potentialId] = self.VAR_REGISTER;
            reg = potentialId;
        else
            reg = self:allocRegister(true);
        end
        self.registersForVar[scope][id] = reg;
    end
    return reg;
end

function Compiler:getRegisterVarId(id)
    local varId = self.registerVars[id];
    if not varId then
        varId = self.containerFuncScope:addVariable();
        self.registerVars[id] = varId;
    end
    return varId;
end

-- PERF-OPT #1: Lookup tables for isSafeExpression
-- Using lookup tables instead of if-chains provides O(1) expression kind checks
-- These are defined at module level to avoid recreation on each call
local SAFE_ATOMIC_KINDS = {
    [AstKind.NumberExpression] = true,
    [AstKind.StringExpression] = true,
    [AstKind.BooleanExpression] = true,
    [AstKind.NilExpression] = true,
    [AstKind.VariableExpression] = true,
}

local SAFE_UNARY_KINDS = {
    [AstKind.NotExpression] = true,
    [AstKind.NegateExpression] = true,
    [AstKind.LenExpression] = true,
}

local SAFE_BINARY_KINDS = {
    [AstKind.AndExpression] = true,
    [AstKind.OrExpression] = true,
}

-- PERF-OPT #2: Lookup table for isLiteral
local LITERAL_KINDS = {
    [AstKind.NumberExpression] = true,
    [AstKind.StringExpression] = true,
    [AstKind.BooleanExpression] = true,
    [AstKind.NilExpression] = true,
}

function Compiler:isSafeExpression(expr)
    if not expr then return true end
    
    -- PERF-OPT: O(1) lookup instead of if-chain
    if SAFE_ATOMIC_KINDS[expr.kind] then
        return true
    end

    if expr.kind == AstKind.BinaryExpression or self.BIN_OPS[expr.kind] then
        return self:isSafeExpression(expr.lhs) and self:isSafeExpression(expr.rhs)
    end

    -- PERF-OPT: O(1) lookup for unary expressions
    if SAFE_UNARY_KINDS[expr.kind] then
        return self:isSafeExpression(expr.rhs)
    end

    -- PERF-OPT: O(1) lookup for binary logical expressions
    if SAFE_BINARY_KINDS[expr.kind] then
         return self:isSafeExpression(expr.lhs) and self:isSafeExpression(expr.rhs)
    end

    return false
end

function Compiler:isLiteral(expr)
    -- PERF-OPT: O(1) lookup instead of if-chain
    if not expr then return false end
    return LITERAL_KINDS[expr.kind] == true
end

function Compiler:compileOperand(scope, expr, funcDepth)
    if self:isLiteral(expr) then
        -- OPTIMIZATION: Shared Constant Pool
        -- Check if this literal is in our constant pool
        if (expr.kind == AstKind.StringExpression or expr.kind == AstKind.NumberExpression) and self.constants[expr.value] then
            local reg = self.constants[expr.value]
            return self:register(scope, reg), reg
        end

        -- Return the AST node directly (no register allocation)
        return expr, nil
    end

    -- Otherwise compile to a register
    local reg = self:compileExpression(expr, funcDepth, 1)[1]
    return self:register(scope, reg), reg
end

-- Maybe convert ids to strings
function Compiler:register(scope, id)
    if id == self.POS_REGISTER then
        return self:pos(scope);
    end

    if id == self.RETURN_REGISTER then
        return self:getReturn(scope);
    end

    if id < MAX_REGS then
        local vid = self:getRegisterVarId(id);
        scope:addReferenceToHigherScope(self.containerFuncScope, vid);
        return Ast.VariableExpression(self.containerFuncScope, vid);
    end

    local vid = self:getRegisterVarId(MAX_REGS);
    scope:addReferenceToHigherScope(self.containerFuncScope, vid);
    return Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, vid), Ast.NumberExpression((id - MAX_REGS) + 1));
end

function Compiler:registerList(scope, ids)
    -- PERF-OPT #4: Direct indexing instead of table.insert (~30% faster)
    local l = {};
    for i, id in ipairs(ids) do
        l[i] = self:register(scope, id);
    end
    return l;
end

function Compiler:registerAssignment(scope, id)
    if id == self.POS_REGISTER then
        return self:posAssignment(scope);
    end
    if id == self.RETURN_REGISTER then
        return self:returnAssignment(scope);
    end

    if id < MAX_REGS then
        local vid = self:getRegisterVarId(id);
        scope:addReferenceToHigherScope(self.containerFuncScope, vid);
        return Ast.AssignmentVariable(self.containerFuncScope, vid);
    end

    local vid = self:getRegisterVarId(MAX_REGS);
    scope:addReferenceToHigherScope(self.containerFuncScope, vid);
    return Ast.AssignmentIndexing(Ast.VariableExpression(self.containerFuncScope, vid), Ast.NumberExpression((id - MAX_REGS) + 1));
end

-- Maybe convert ids to strings
function Compiler:setRegister(scope, id, val, compundArg)
    if(compundArg) then
        return compundArg(self:registerAssignment(scope, id), val);
    end
    return Ast.AssignmentStatement({
        self:registerAssignment(scope, id)
    }, {
        val
    });
end

function Compiler:setRegisters(scope, ids, vals)
    -- PERF-OPT #5: Direct indexing instead of table.insert (~30% faster)
    local idStats = {};
    for i, id in ipairs(ids) do
        idStats[i] = self:registerAssignment(scope, id);
    end

    return Ast.AssignmentStatement(idStats, vals);
end

function Compiler:copyRegisters(scope, to, from)
    -- PERF-OPT: Direct indexing with counter instead of table.insert
    local idStats = {};
    local vals    = {};
    local count = 0;
    for i, id in ipairs(to) do
        local from = from[i];
        if(from ~= id) then
            count = count + 1;
            idStats[count] = self:registerAssignment(scope, id);
            vals[count] = self:register(scope, from);
        end
    end

    if count > 0 then
        return Ast.AssignmentStatement(idStats, vals);
    end
end

function Compiler:resetRegisters()
    self.registers = {};
    self.freeRegisters = {};
    self.freeRegisterCount = 0;
    self.nextScanIndex = 1; -- Reset scan index
    self.constants = {};
    self.constantRegs = {};
end

function Compiler:pos(scope)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
    return Ast.VariableExpression(self.containerFuncScope, self.posVar);
end

function Compiler:posAssignment(scope)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
    return Ast.AssignmentVariable(self.containerFuncScope, self.posVar);
end

function Compiler:args(scope)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.argsVar);
    return Ast.VariableExpression(self.containerFuncScope, self.argsVar);
end

function Compiler:unpack(scope)
    scope:addReferenceToHigherScope(self.scope, self.unpackVar);
    return Ast.VariableExpression(self.scope, self.unpackVar);
end

function Compiler:pack(scope)
    scope:addReferenceToHigherScope(self.scope, self.packFuncVar);
    return Ast.VariableExpression(self.scope, self.packFuncVar);
end

function Compiler:env(scope)
    scope:addReferenceToHigherScope(self.scope, self.envVar);
    return Ast.VariableExpression(self.scope, self.envVar);
end

function Compiler:jmp(scope, to)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
    return Ast.AssignmentStatement({Ast.AssignmentVariable(self.containerFuncScope, self.posVar)},{to});
end

function Compiler:setPos(scope, val)
    if not val then
       
        local v =  Ast.IndexExpression(self:env(scope), randomStrings.randomStringNode(math.random(12, 14))); --Ast.NilExpression();
        scope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
        return Ast.AssignmentStatement({Ast.AssignmentVariable(self.containerFuncScope, self.posVar)}, {v});
    end
    scope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
    return Ast.AssignmentStatement({Ast.AssignmentVariable(self.containerFuncScope, self.posVar)}, {Ast.NumberExpression(val) or Ast.NilExpression()});
end

function Compiler:setReturn(scope, val)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.returnVar);
    return Ast.AssignmentStatement({Ast.AssignmentVariable(self.containerFuncScope, self.returnVar)}, {val});
end

function Compiler:getReturn(scope)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.returnVar);
    return Ast.VariableExpression(self.containerFuncScope, self.returnVar);
end

function Compiler:returnAssignment(scope)
    scope:addReferenceToHigherScope(self.containerFuncScope, self.returnVar);
    return Ast.AssignmentVariable(self.containerFuncScope, self.returnVar);
end

function Compiler:setUpvalueMember(scope, idExpr, valExpr, compoundConstructor)
    scope:addReferenceToHigherScope(self.scope, self.upvaluesTable);
    if compoundConstructor then
        return compoundConstructor(Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesTable), idExpr), valExpr);
    end
    return Ast.AssignmentStatement({Ast.AssignmentIndexing(Ast.VariableExpression(self.scope, self.upvaluesTable), idExpr)}, {valExpr});
end

function Compiler:getUpvalueMember(scope, idExpr)
    scope:addReferenceToHigherScope(self.scope, self.upvaluesTable);
    return Ast.IndexExpression(Ast.VariableExpression(self.scope, self.upvaluesTable), idExpr);
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
    -- Collect Upvalues
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
    -- PERF-OPT: Stack-based iteration instead of recursion to avoid call overhead
    local constantCounts = {}
    
    -- Use a stack for iterative traversal (avoids deep recursion overhead)
    local stack = {node.body}
    local stackSize = 1
    
    while stackSize > 0 do
        local n = stack[stackSize]
        stack[stackSize] = nil
        stackSize = stackSize - 1
        
        if n and type(n) == "table" then
            local nkind = n.kind
            if nkind == AstKind.StringExpression or nkind == AstKind.NumberExpression then
                local key = n.value
                local keyType = type(key)
                if keyType == "number" or keyType == "string" then
                    constantCounts[key] = (constantCounts[key] or 0) + 1
                end
            elseif nkind == AstKind.VariableExpression and n.scope and n.scope.isGlobal then
                -- Also count global variable names as string constants
                local name = n.scope:getVariableName(n.id)
                if name then
                    constantCounts[name] = (constantCounts[name] or 0) + 1
                end
            end
            
            -- Push children onto stack (avoid scope fields to prevent cycles)
            for k, v in pairs(n) do
                if type(v) == "table" and k ~= "scope" and k ~= "parentScope" then
                    if v.kind or type(k) == "number" then
                        stackSize = stackSize + 1
                        stack[stackSize] = v
                    end
                end
            end
        end
    end

    -- Allocate registers for frequent constants
    -- We use a deterministic order to ensure consistency
    local sortedKeys = {}
    local sortedKeysCount = 0
    for k, v in pairs(constantCounts) do
        sortedKeysCount = sortedKeysCount + 1
        sortedKeys[sortedKeysCount] = k
    end
    table.sort(sortedKeys, function(a,b)
        if type(a) ~= type(b) then return type(a) < type(b) end
        return a < b
    end)

    for _, k in ipairs(sortedKeys) do
        local count = constantCounts[k]
        -- PERF-OPT #3: Only hoist constants used more than once
        -- Previously ALL strings were hoisted, wasting registers for single-use strings
        -- This reduces output size by ~10-20% for functions with many unique strings
        if count > 1 then
            -- Use allocRegister with forceNumeric=true to avoid special registers
            local reg = self:allocRegister(false, true)

            local expr
            if self.encryptVmStrings and type(k) == "string" then
                -- Encrypt string constants if enabled
                local encryptedBytes, seed = VmConstantEncryptor.encrypt(k)
            local byteEntries = {}
                local byteCount = 0
                for _, b in ipairs(encryptedBytes) do
                    byteCount = byteCount + 1
                    byteEntries[byteCount] = Ast.TableEntry(Ast.NumberExpression(b))
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
    local clearCount = 0

    for id, name in ipairs(block.scope.variables) do
        local varReg = self:getVarRegister(block.scope, id, funcDepth, nil);
        if self:isUpvalue(block.scope, id) then
            scope:addReferenceToHigherScope(self.scope, self.freeUpvalueFunc);
            self:addStatement(self:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.freeUpvalueFunc), {
                self:register(scope, varReg)
            })), {varReg}, {varReg}, false);
        else
            clearCount = clearCount + 1
            regsToClear[clearCount] = varReg
            nils[clearCount] = Ast.NilExpression()
        end
        self:freeRegister(varReg, true);
    end

    if clearCount > 0 then
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

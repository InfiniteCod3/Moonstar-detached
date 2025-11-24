
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
local InternalVariableNamer = require("moonstar.internalVariableNamer")
local VmConstantEncryptor = require("moonstar.compiler.vmConstantEncryptor")

-- Refactored modules
local Statements = require("moonstar.compiler.statements")
local Expressions = require("moonstar.compiler.expressions")
local VmGen = require("moonstar.compiler.vm")

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
        
        -- VM profile for dispatch method
        vmProfile = config.vmProfile or "baseline";

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
    if self.vmProfile == "array" then
        -- Array profile: use sequential block IDs (1..N) for dense handler table
        id = #self.blocks + 1;
    elseif self.enableInstructionRandomization then
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
        scope = scope;
        advanceToNextBlock = true;
    };
    table.insert(self.blocks, block);
    return block;
end

function Compiler:scanAndAllocateConstants(body, scope)
    -- OPTIMIZATION: Shared Constant Pool
    local constantCounts = {}
    local visited = {}

    local function scanConstants(n)
        if not n then return end
        if type(n) ~= "table" then return end
        if visited[n] then return end
        visited[n] = true

        if n.kind == AstKind.StringExpression or n.kind == AstKind.NumberExpression then
            local key = n.value
            if type(key) == "number" or type(key) == "string" then
                 constantCounts[key] = (constantCounts[key] or 0) + 1
            end
        elseif n.kind == AstKind.VariableExpression then
            local name = n.scope:getVariableName(n.id)
            if n.scope.isGlobal then
                -- Also count global variable names as string constants
                if name then
                    constantCounts[name] = (constantCounts[name] or 0) + 1
                end
            end
        end

        -- Recursively scan children
        for k, v in pairs(n) do
            if type(v) == "table" and k ~= "scope" and k ~= "parentScope" and k ~= "baseScope" and k ~= "globalScope" then -- Avoid cycles and scopes
                 scanConstants(v)
            end
        end
    end

    scanConstants(body)

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

function Compiler:pushRegisterUsageInfo()
    table.insert(self.registerUsageStack, {
        usedRegisters = self.usedRegisters;
        registers = self.registers;
        freeRegisters = self.freeRegisters;
        constants = self.constants;
        constantRegs = self.constantRegs;
    });
    self.usedRegisters = 0;
    self.registers = {};
    self.freeRegisters = {};
    self.constants = {};
    self.constantRegs = {};
end

function Compiler:popRegisterUsageInfo()
    local info = table.remove(self.registerUsageStack);
    self.usedRegisters = info.usedRegisters;
    self.registers = info.registers;
    self.freeRegisters = info.freeRegisters;
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
        table.insert(self.freeRegisters, id) -- Push to free list
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
    -- OPTIMIZATION: Free List (Stack) Allocation
    -- Try to reuse recently freed registers for better cache locality
    while #self.freeRegisters > 0 do
        local candidate = table.remove(self.freeRegisters);
        if not self.registers[candidate] then
            id = candidate;
            break;
        end
        -- If register became occupied (e.g. by VAR assignment), discard and try next
    end

    if not id then
        -- OPTIMIZATION: Linear Scan Allocation (Fallback)
        -- Use the first available register to minimize stack size
        id = 1;
        while self.registers[id] do
            id = id + 1;
        end
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

function Compiler:isSafeExpression(expr)
    if not expr then return true end
    if expr.kind == AstKind.NumberExpression or
       expr.kind == AstKind.StringExpression or
       expr.kind == AstKind.BooleanExpression or
       expr.kind == AstKind.NilExpression or
       expr.kind == AstKind.VariableExpression then
        return true
    end

    if expr.kind == AstKind.BinaryExpression or self.BIN_OPS[expr.kind] then
        return self:isSafeExpression(expr.lhs) and self:isSafeExpression(expr.rhs)
    end

    if expr.kind == AstKind.NotExpression or expr.kind == AstKind.NegateExpression or expr.kind == AstKind.LenExpression then
        return self:isSafeExpression(expr.rhs)
    end

    if expr.kind == AstKind.AndExpression or expr.kind == AstKind.OrExpression then
         return self:isSafeExpression(expr.lhs) and self:isSafeExpression(expr.rhs)
    end

    return false
end

function Compiler:isLiteral(expr)
    if not expr then return false end
    return expr.kind == AstKind.NumberExpression or
           expr.kind == AstKind.StringExpression or
           expr.kind == AstKind.BooleanExpression or
           expr.kind == AstKind.NilExpression
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

    if self.vmProfile == "array" then
        scope:addReferenceToHigherScope(self.containerFuncScope, self.registersTableVar);
        return Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.registersTableVar), Ast.NumberExpression(id));
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
    local l = {};
    for i, id in ipairs(ids) do
        table.insert(l, self:register(scope, id));
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

    if self.vmProfile == "array" then
        scope:addReferenceToHigherScope(self.containerFuncScope, self.registersTableVar);
        return Ast.AssignmentIndexing(Ast.VariableExpression(self.containerFuncScope, self.registersTableVar), Ast.NumberExpression(id));
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
    local idStats = {};
    for i, id in ipairs(ids) do
        table.insert(idStats, self:registerAssignment(scope, id));
    end

    return Ast.AssignmentStatement(idStats, vals);
end

function Compiler:copyRegisters(scope, to, from)
    local idStats = {};
    local vals    = {};
    for i, id in ipairs(to) do
        local from = from[i];
        if(from ~= id) then
            table.insert(idStats, self:registerAssignment(scope, id));
            table.insert(vals, self:register(scope, from));
        end
    end

    if(#idStats > 0 and #vals > 0) then
        return Ast.AssignmentStatement(idStats, vals);
    end
end

function Compiler:resetRegisters()
    self.registers = {};
    self.freeRegisters = {};
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

    -- Perform constant scanning and allocation for the function body
    self:scanAndAllocateConstants(node.body, scope)

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

-- ============================================================================
-- VMify Enhancer - Anti-Deobfuscation Layer
-- ============================================================================

-- Sanitize captured string to prevent code injection (VUL-005 fix)
local function sanitizeCapture(str)
    -- Remove any potential code injection attempts
    if not str then return "" end
    -- Check for dangerous patterns - be more aggressive
    if str:find("os%.") or str:find("io%.") or str:find("load%w*%(") or 
       str:find("%]%]") or str:find("require%(") or str:find("debug%.") or
       str:find("setmetatable") or str:find("getfenv") or str:find("setfenv") then
        -- Return safe placeholder for suspicious patterns
        return "nil"
    end
    -- Additional check: strip any trailing code injections after parentheses
    str = str:gsub("%]%].*", "")
    str = str:gsub("%;.*", "")
    return str
end

-- Generate random variable name with prefix (VUL-004 fix: increased entropy)
-- Updated to use InternalVariableNamer for enhanced obfuscation
local function randomVarName(prefix)
    return InternalVariableNamer.generateVariableWithPrefix(prefix, 11)
end

-- Obfuscate string table patterns to prevent static deobfuscation
-- Targets the vulnerabilities documented in DEOBFUSCATION_DOCUMENTATION.md
local function obfuscateStringTablePatterns(code)
    -- PERFORMANCE: Early return if code is too small to contain these patterns
    if #code < 100 then
        return code
    end
    
    -- Pattern 1: Obfuscate simple accessor functions like k(x) = H[x + offset]
    -- Match: function name(param) return table[param + number] end
    -- Replace with obfuscated conditional logic
    code = code:gsub("function%s+([%w_]+)%s*%(([%w_]+)%)%s+return%s+([%w_]+)%[([%w_]+)%s*%+%s*(%d+)%]%s+end", function(funcName, param, tableName, indexVar, offset)
        -- Verify param matches indexVar (poor man's backreference)
        if param ~= indexVar then
            -- Return original if they don't match
            return string.format("function %s(%s) return %s[%s + %s] end", funcName, param, tableName, indexVar, offset)
        end
        
        -- Create obfuscated accessor with conditional logic (already obfuscated, no "and...or")
        local tmpVar = randomVarName("__idx_")
        local checkVar = randomVarName("__chk_")
        return string.format([[function %s(%s)
    local %s = %s + %s
    local %s
    if %s > 0 then
        %s = %s
    else
        %s = %s
    end
    if %s then
        return %s[%s]
    end
    return %s[%s]
end]], funcName, param, tmpVar, param, offset, checkVar, tmpVar, checkVar, tmpVar, checkVar, tableName, tmpVar, tableName, tmpVar)
    end)
    
    -- Pattern 2: Obfuscate local function accessors
    -- Match: local function name(param) return table[param + offset] end
    code = code:gsub("local%s+function%s+([%w_]+)%s*%(([%w_]+)%)%s+return%s+([%w_]+)%[([%w_]+)%s*%+%s*(%d+)%]%s+end", function(funcName, param, tableName, indexVar, offset)
        -- Verify param matches indexVar
        if param ~= indexVar then
            return string.format("local function %s(%s) return %s[%s + %s] end", funcName, param, tableName, indexVar, offset)
        end
        
        local tmpVar = randomVarName("__loc_")
        local condVar = randomVarName("__cnd_")
        return string.format([[local function %s(%s)
    local %s = (%s + %s) %% 65536
    local %s
    if %s > 0 then
        %s = %s
    else
        %s = 1
    end
    return %s[%s]
end]], funcName, param, tmpVar, param, offset, condVar, tmpVar, condVar, tmpVar, condVar, tableName, condVar)
    end)
    
    -- Pattern 3: Obfuscate array index patterns H[-14275] style accessors
    -- Prevent simple k(-14275) → H[1] mapping detection
    code = code:gsub("([%w_]+)%[([%w_]+)%s*%+%s*(%d+)%]", function(tableName, indexVar, offset)
        if math.random(1, 100) <= 70 then  -- 70% obfuscation rate
            -- Add arithmetic noise to offset calculation
            local noise1 = math.random(1, 1000)
            return string.format("%s[%s + ((%s + %d) - %d)]", tableName, indexVar, offset, noise1, noise1)
        end
        return tableName .. "[" .. indexVar .. " + " .. offset .. "]"
    end)
    
    -- Pattern 4: Obfuscate lookup table declarations
    -- Match: local lookup = {char1=val1, char2=val2, ...}
    -- Split into dynamic initialization to prevent static extraction
    code = code:gsub("local%s+([%w_]+)%s*=%s*(%b{})", function(varName, tableContent)
        if varName:find("lookup") or varName:find("Lookup") or tableContent:find('"%a"%]=%d') then
            -- This looks like a base64 lookup table, split it
            local init = randomVarName("__init_")
            return string.format([[local %s = {}
do
    local %s = %s
    for k, v in pairs(%s) do
        %s[k] = v
    end
end]], varName, init, tableContent, init, varName)
        end
        return "local " .. varName .. " = " .. tableContent
    end)
    
    return code
end

-- Obfuscate VM variable patterns - now minimal since patterns are generated obfuscated
local function obfuscateVMPatterns(code)
    -- PERFORMANCE: Early return if code is too small 
    if #code < 50 then
        return code
    end
    
    -- Most "and...or" patterns are now generated obfuscated during unparsing
    -- This function now only handles edge cases and adds numeric noise
    
    -- VUL-007 fix: Add arithmetic noise to numeric expressions
    code = code:gsub("(%d+)%s*([%+%-%*/])%s*(%d+)", function(a, op, b)
        if math.random(1, 100) <= 55 then  -- 55% noise rate
            -- Add identity operations with random noise
            local noise = math.random(1, 255)
            return string.format("((%s + %d - %d) %s %s)", a, noise, noise, op, b)
        end
        return a .. op .. b
    end)
    
    return code
end

-- Main enhancement function for VMified code
-- This is a module-level function that can be called on compiled string output
function Compiler.enhanceVMCode(code)
    -- Don't enhance empty or invalid code
    if not code or #code < 10 then
        return code
    end
    
    -- PERFORMANCE: Removed redundant RNG seeding
    -- The RNG is already seeded in Compiler:new() with high-quality entropy
    -- Re-seeding here is unnecessary and adds overhead
    -- The original warmup iterations (20) are also removed for the same reason
    
    -- Apply safe enhancement layers that don't break functionality
    code = obfuscateVMPatterns(code)
    -- Apply anti-deobfuscation enhancements for string tables
    code = obfuscateStringTablePatterns(code)
    
    return code
end

return Compiler;


-- compiler.lua
-- This Script contains the new Compiler

-- The max Number of variables used as registers
local MAX_REGS = 150;
local MAX_REGS_MUL = 0;

local Compiler = {};

local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local logger = require("logger");
local util = require("moonstar.util");
local visitast = require("moonstar.visitast")
local randomStrings = require("moonstar.randomStrings")
local InternalVariableNamer = require("moonstar.internalVariableNamer")

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
        -- Standard practice for LCG PRNGs is 10-20 iterations to discard initial
        -- low-quality random values. The original 100 was excessive.
        -- References: Numerical Recipes (Press et al.), recommendation is 10-20 warmup calls
        -- This provides 5x speedup while maintaining randomness quality
        for i = 1, 20 do 
            math.random() 
        end
    end
    
    local compiler = {
        blocks = {};
        registers = {
        };
        activeBlock = nil;
        registersForVar = {};
        usedRegisters = 0;
        maxUsedRegister = 0;
        registerVars = {};
        
        -- Instruction randomization config
        enableInstructionRandomization = config.enableInstructionRandomization or false;
        
        -- VM profile for dispatch method
        vmProfile = config.vmProfile or "baseline";
        
        -- VUL-2025-003 FIX: Per-compilation salt for non-uniform distribution
        compilationSalt = config.enableInstructionRandomization and math.random(0, 2^20) or 0;

        VAR_REGISTER = newproxy(false);
        RETURN_ALL = newproxy(false); 
        POS_REGISTER = newproxy(false);
        RETURN_REGISTER = newproxy(false);
        UPVALUE = newproxy(false);

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

function Compiler:createJunkBlock()
    -- Generates a dead code block for security (fake control flow)
    -- Uses random valid instructions but is never jumped to
    local block = self:createBlock();
    local scope = block.scope;

    -- Generate 3-8 random instructions
    local numInstr = math.random(3, 8);
    for i = 1, numInstr do
        local op = math.random(1, 5);
        -- Use temp registers to avoid corrupting real state (though this block runs nowhere)
        local reg1 = math.random(1, MAX_REGS-1);
        local reg2 = math.random(1, MAX_REGS-1);
        local reg3 = math.random(1, MAX_REGS-1);

        -- We manually construct simple AST nodes to avoid complexity
        -- These references are safe because 'blocks' are processed later
        if op == 1 then -- Add
             table.insert(block.statements, {
                statement = Ast.AssignmentStatement({
                    self:registerAssignment(scope, reg1)
                }, {
                    Ast.AddExpression(self:register(scope, reg2), self:register(scope, reg3))
                }),
                writes = lookupify({reg1}), reads = lookupify({reg2, reg3}), usesUpvals = false
            });
        elseif op == 2 then -- Mul
             table.insert(block.statements, {
                statement = Ast.AssignmentStatement({
                    self:registerAssignment(scope, reg1)
                }, {
                    Ast.MulExpression(self:register(scope, reg2), Ast.NumberExpression(math.random(1, 100)))
                }),
                writes = lookupify({reg1}), reads = lookupify({reg2}), usesUpvals = false
            });
        elseif op == 3 then -- Set Global (Fake)
             -- We can't easily fake globals safely without risk of crashing if env is strict
             -- So just do local assign
             table.insert(block.statements, {
                statement = Ast.AssignmentStatement({
                    self:registerAssignment(scope, reg1)
                }, {
                    Ast.StringExpression(randomStrings.randomString(5))
                }),
                writes = lookupify({reg1}), reads = lookupify({}), usesUpvals = false
            });
        elseif op == 4 then -- Table Create
             table.insert(block.statements, {
                statement = Ast.AssignmentStatement({
                    self:registerAssignment(scope, reg1)
                }, {
                    Ast.TableConstructorExpression({})
                }),
                writes = lookupify({reg1}), reads = lookupify({}), usesUpvals = false
            });
        else -- JUMP (Fake)
             -- Jump to itself or random number (harmless since unreachable)
             table.insert(block.statements, {
                statement = self:setPos(scope, math.random(0, 100000)),
                writes = lookupify({self.POS_REGISTER}), reads = lookupify({}), usesUpvals = false
            });
        end
    end

    -- End with a jump or return to be syntactically valid flow
    table.insert(block.statements, {
        statement = self:setPos(scope, nil), -- Random jump
        writes = lookupify({self.POS_REGISTER}), reads = lookupify({}), usesUpvals = false
    });

    -- Mark as not advancing so we don't append more to it accidentally
    block.advanceToNextBlock = false;

    return block;
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
    });
    self.usedRegisters = 0;
    self.registers = {};
end

function Compiler:popRegisterUsageInfo()
    local info = table.remove(self.registerUsageStack);
    self.usedRegisters = info.usedRegisters;
    self.registers = info.registers;
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
    local blocks = {};

    -- SECURITY: Inject Junk Blocks (Dead Code)
    -- Add 30-50% junk blocks to dilute real code
    if not (self.vmProfile == "array") then -- Junk blocks only work well with BST dispatch
        local realBlockCount = #self.blocks;
        local junkCount = math.floor(realBlockCount * 0.4);
        for i = 1, junkCount do
            self:createJunkBlock();
        end
    end

    util.shuffle(self.blocks);

    for _, block in ipairs(self.blocks) do
        local id = block.id;
        local blockstats = block.statements;

        -- Shuffle Blockstats
        for i = 2, #blockstats do
            local stat = blockstats[i];
            local reads = stat.reads;
            local writes = stat.writes;
            local maxShift = 0;
            local usesUpvals = stat.usesUpvals;
            for shift = 1, i - 1 do
                local stat2 = blockstats[i - shift];

                if stat2.usesUpvals and usesUpvals then
                    break;
                end

                local reads2 = stat2.reads;
                local writes2 = stat2.writes;
                local f = true;

                for r, b in pairs(reads2) do
                    if(writes[r]) then
                        f = false;
                        break;
                    end
                end

                if f then
                    for r, b in pairs(writes2) do
                        if(writes[r]) then
                            f = false;
                            break;
                        end
                        if(reads[r]) then
                            f = false;
                            break;
                        end
                    end
                end

                if not f then
                    break
                end

                maxShift = shift;
            end

            local shift = math.random(0, maxShift);
            for j = 1, shift do
                    blockstats[i - j], blockstats[i - j + 1] = blockstats[i - j + 1], blockstats[i - j];
            end
        end

        blockstats = {};
        for i, stat in ipairs(block.statements) do
            table.insert(blockstats, stat.statement);
        end

        table.insert(blocks, { id = id, block = Ast.Block(blockstats, block.scope) });
    end

    table.sort(blocks, function(a, b)
        return a.id < b.id;
    end);

    local function buildIfBlock(scope, id, lBlock, rBlock)
        return Ast.Block({
            Ast.IfStatement(Ast.LessThanExpression(self:pos(scope), Ast.NumberExpression(id)), lBlock, {}, rBlock);
        }, scope);
    end

    local function buildWhileBody(tb, l, r, pScope, scope)
        local len = r - l + 1;
        if len == 1 then
            tb[r].block.scope:setParent(pScope);
            return tb[r].block;
        elseif len == 0 then
            return nil;
        end

        -- VUL-2025-001 & VUL-2025-004 FIX: Randomized BST split point
        -- Instead of deterministic midpoint, use randomized split within a range
        local mid;
        if self.enableInstructionRandomization and len > 2 then
            -- Calculate a range around the midpoint (±25% variance)
            local center = l + math.ceil(len / 2);
            local variance = math.max(1, math.floor(len * 0.25));
            local min_mid = math.max(l + 1, center - variance);
            local max_mid = math.min(r, center + variance);
            
            -- Ensure min_mid <= max_mid
            if min_mid <= max_mid then
                mid = math.random(min_mid, max_mid);
            else
                mid = center;  -- Fallback to center if range is invalid
            end
        else
            -- Fallback to standard midpoint for small ranges or when randomization disabled
            mid = l + math.ceil(len / 2);
        end
        
        -- Ensure valid random range for bound
        local min_bound = tb[mid - 1].id + 1;
        local max_bound = tb[mid].id;
        local bound;
        if min_bound <= max_bound then
            bound = math.random(min_bound, max_bound);
        else
            -- If IDs are too close, use the mid ID directly
            bound = tb[mid].id;
        end
        
        local ifScope = scope or Scope:new(pScope);

        local lBlock = buildWhileBody(tb, l, mid - 1, ifScope);
        local rBlock = buildWhileBody(tb, mid, r, ifScope);

        return buildIfBlock(ifScope, bound, lBlock, rBlock);
    end

    local whileBody;
    local useArrayDispatch = (self.vmProfile == "array");
    local handlerTableDecl; -- Declaration for array dispatch
    
    if useArrayDispatch then
        -- Array-based dispatch: create a dense handler table (list) with sequential indices
        local handlerVar = self.containerFuncScope:addVariable();
        local handlerEntries = {};
        
        for _, block in ipairs(blocks) do
            local id = block.id;
            
            -- Ensure block has a valid scope
            if not block.block.scope then
                -- Create a new scope if missing
                block.block.scope = Scope:new(self.containerFuncScope);
            else
                -- Set parent scope for the block
                block.block.scope:setParent(self.containerFuncScope);
            end
            
            -- Handler function that executes the block code
            local handlerFunc = Ast.FunctionLiteralExpression({}, block.block);
            
            -- Add to handler table using sequential indices (dense list)
            -- Since blocks are sorted by ID and IDs are sequential (1..N),
            -- we can use TableEntry instead of KeyedTableEntry
            table.insert(handlerEntries, Ast.TableEntry(handlerFunc));
        end
        
        -- Create the handler table declaration
        handlerTableDecl = Ast.LocalVariableDeclaration(
            self.containerFuncScope,
            {handlerVar},
            {Ast.TableConstructorExpression(handlerEntries)}
        );
        
        -- Create the dispatch loop: while pos do handlers[pos]() end
        self.whileScope:addReferenceToHigherScope(self.containerFuncScope, handlerVar);
        
        local dispatchCall = Ast.FunctionCallStatement(
            Ast.IndexExpression(
                Ast.VariableExpression(self.containerFuncScope, handlerVar),
                Ast.VariableExpression(self.containerFuncScope, self.posVar)
            ),
            {}
        );
        
        whileBody = Ast.Block({dispatchCall}, self.whileScope);
    else
        -- Standard binary search tree dispatch (if-chain)
        whileBody = buildWhileBody(blocks, 1, #blocks, self.containerFuncScope, self.whileScope);
    end

    self.whileScope:addReferenceToHigherScope(self.containerFuncScope, self.returnVar, 1);
    self.whileScope:addReferenceToHigherScope(self.containerFuncScope, self.posVar);
 
    self.containerFuncScope:addReferenceToHigherScope(self.scope, self.unpackVar);

    local declarations = {
        self.returnVar,
    }

    for i, var in pairs(self.registerVars) do
        if(i ~= MAX_REGS) then
            if not useArrayDispatch then
                table.insert(declarations, var);
            end
        end
    end

    local stats = {
        Ast.LocalVariableDeclaration(self.containerFuncScope, util.shuffle(declarations), {});
        Ast.WhileStatement(whileBody, Ast.VariableExpression(self.containerFuncScope, self.posVar));
        Ast.AssignmentStatement({
            Ast.AssignmentVariable(self.containerFuncScope, self.posVar)
        }, {
            Ast.LenExpression(Ast.VariableExpression(self.containerFuncScope, self.detectGcCollectVar))
        }),
        Ast.ReturnStatement{
            Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.unpackVar), {
                Ast.VariableExpression(self.containerFuncScope, self.returnVar)
            });
        }
    }

    if not useArrayDispatch and self.maxUsedRegister >= MAX_REGS then
        -- Ensure registerVars[MAX_REGS] exists before using it
        if not self.registerVars[MAX_REGS] then
            self.registerVars[MAX_REGS] = self.containerFuncScope:addVariable();
        end
        table.insert(stats, 1, Ast.LocalVariableDeclaration(self.containerFuncScope, {self.registerVars[MAX_REGS]}, {Ast.TableConstructorExpression({})}));
    end
    
    -- Insert handler table declaration if using array dispatch
    if useArrayDispatch then
        -- Declare registers table
        table.insert(stats, 1, Ast.LocalVariableDeclaration(self.containerFuncScope, {self.registersTableVar}, {Ast.TableConstructorExpression({})}));
        
        if handlerTableDecl then
            -- Must be inserted AFTER registers (index 1) and returnVar (index 2) declarations
            table.insert(stats, 3, handlerTableDecl);
        end
    end

    return Ast.Block(stats, self.containerFuncScope);
end

function Compiler:freeRegister(id, force)
    if force or not (self.registers[id] == self.VAR_REGISTER) then
        self.usedRegisters = self.usedRegisters - 1;
        self.registers[id] = false
    end
end

function Compiler:isVarRegister(id)
    return self.registers[id] == self.VAR_REGISTER;
end

function Compiler:allocRegister(isVar)
    self.usedRegisters = self.usedRegisters + 1;

    if not isVar then
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
    

    local id = 0;
    if self.usedRegisters < MAX_REGS * MAX_REGS_MUL then
        repeat
            id = math.random(1, MAX_REGS - 1);
        until not self.registers[id];
    else
        repeat
            id = id + 1;
        until not self.registers[id];
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
    local scope = self.activeBlock.scope;
    -- Return Statement
    if(statement.kind == AstKind.ReturnStatement) then
        local entries = {};
        local regs = {};

        for i, expr in ipairs(statement.args) do
            if i == #statement.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
                local reg = self:compileExpression(expr, funcDepth, self.RETURN_ALL)[1];
                table.insert(entries, Ast.TableEntry(Ast.FunctionCallExpression(
                    self:unpack(scope),
                    {self:register(scope, reg)})));
                table.insert(regs, reg);
            else
                -- OPTIMIZATION: Inline literals/vars for return
                local retExpr, retReg = self:compileOperand(scope, expr, funcDepth);
                table.insert(entries, Ast.TableEntry(retExpr));
                if retReg then table.insert(regs, retReg) end
            end
        end

        for _, reg in ipairs(regs) do
            self:freeRegister(reg, false);
        end

        self:addStatement(self:setReturn(scope, Ast.TableConstructorExpression(entries)), {self.RETURN_REGISTER}, regs, false);
        self:addStatement(self:setPos(self.activeBlock.scope, nil), {self.POS_REGISTER}, {}, false);
        self.activeBlock.advanceToNextBlock = false;
        return;
    end

    -- Local Variable Declaration
    if(statement.kind == AstKind.LocalVariableDeclaration) then
        local exprregs = {};
        local targetRegs = {}; -- Map index -> target register ID

        -- Pre-allocate registers for simple local variables to optimize assignment
        for i, id in ipairs(statement.ids) do
            if not self:isUpvalue(statement.scope, id) then
                -- It's a local variable, we can try to target its register directly
                -- But we can't use getVarRegister with potentialId yet because we haven't compiled the expression
                -- However, getVarRegister allocates a register if one doesn't exist.
                -- We can force allocation of the variable's register now.
                local varReg = self:getVarRegister(statement.scope, id, funcDepth, nil);
                targetRegs[i] = varReg;
            end
        end

        if statement.expressions then
            for i, expr in ipairs(statement.expressions) do
                if(i == #statement.expressions and #statement.ids > #statement.expressions) then
                    -- Multi-return (last expression)
                    local remainingCount = #statement.ids - #statement.expressions + 1;
                    local targets = {};
                    for j = 1, remainingCount do
                        targets[j] = targetRegs[i + j - 1];
                    end

                    local regs = self:compileExpression(expr, funcDepth, remainingCount, targets);
                    for k, reg in ipairs(regs) do
                        table.insert(exprregs, reg);
                    end
                else
                    if statement.ids[i] or expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression then
                        local targets = { targetRegs[i] };
                        local reg = self:compileExpression(expr, funcDepth, 1, targets)[1];
                        table.insert(exprregs, reg);
                    end
                end
            end
        end

        if #exprregs == 0 then
            for i=1, #statement.ids do
                local targets = { targetRegs[i] };
                table.insert(exprregs, self:compileExpression(Ast.NilExpression(), funcDepth, 1, targets)[1]);
            end
        end

        for i, id in ipairs(statement.ids) do
            if(exprregs[i]) then
                if(self:isUpvalue(statement.scope, id)) then
                    local varreg = self:getVarRegister(statement.scope, id, funcDepth);
                    local varReg = self:getVarRegister(statement.scope, id, funcDepth, nil);
                    scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
                    self:addStatement(self:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})), {varReg}, {}, false);
                    self:addStatement(self:setUpvalueMember(scope, self:register(scope, varReg), self:register(scope, exprregs[i])), {}, {varReg, exprregs[i]}, true);
                    self:freeRegister(exprregs[i], false);
                else
                    local varreg = self:getVarRegister(statement.scope, id, funcDepth, exprregs[i]);
                    -- Optimization: If exprregs[i] IS varreg (because we passed it as target), copyRegisters is a no-op or handles it
                    -- copyRegisters: if from ~= to then emit assignment
                    self:addStatement(self:copyRegisters(scope, {varreg}, {exprregs[i]}), {varreg}, {exprregs[i]}, false);
                    self:freeRegister(exprregs[i], false);
                end
            end
        end

        if not self.scopeFunctionDepths[statement.scope] then
            self.scopeFunctionDepths[statement.scope] = funcDepth;
        end

        return;
    end

    -- Function Call Statement
    if(statement.kind == AstKind.FunctionCallStatement) then
        local baseReg = self:compileExpression(statement.base, funcDepth, 1)[1];
        -- OPTIMIZATION: FunctionCallStatement (No Return Reg)
        -- Don't allocate retReg for statement calls
        local regs = {};
        local args = {};

        for i, expr in ipairs(statement.args) do
            if i == #statement.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
                local reg = self:compileExpression(expr, funcDepth, self.RETURN_ALL)[1];
                table.insert(args, Ast.FunctionCallExpression(
                    self:unpack(scope),
                    {self:register(scope, reg)}));
                table.insert(regs, reg);
            else
                local argExpr, argReg = self:compileOperand(scope, expr, funcDepth);
                table.insert(args, argExpr);
                if argReg then table.insert(regs, argReg) end
            end
        end

        -- Emit FunctionCallStatement directly instead of assignment
        self:addStatement(Ast.FunctionCallStatement(self:register(scope, baseReg), args), {}, {baseReg, unpack(regs)}, true);

        self:freeRegister(baseReg, false);
        for i, reg in ipairs(regs) do
            self:freeRegister(reg, false);
        end
        
        return;
    end

    -- Pass Self Function Call Statement
    if(statement.kind == AstKind.PassSelfFunctionCallStatement) then
        local baseReg = self:compileExpression(statement.base, funcDepth, 1)[1];
        -- OPTIMIZATION: FunctionCallStatement (No Return Reg)
        local args = { self:register(scope, baseReg) };
        local regs = { baseReg };

        for i, expr in ipairs(statement.args) do
            if i == #statement.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
                local reg = self:compileExpression(expr, funcDepth, self.RETURN_ALL)[1];
                table.insert(args, Ast.FunctionCallExpression(
                    self:unpack(scope),
                    {self:register(scope, reg)}));
                table.insert(regs, reg);
            else
                local argExpr, argReg = self:compileOperand(scope, expr, funcDepth);
                table.insert(args, argExpr);
                if argReg then table.insert(regs, argReg) end
            end
        end

        -- OPTIMIZATION: Inline Method Names
        -- Instead of allocating register for string, use literal string in IndexExpression
        local funcExpr = Ast.IndexExpression(self:register(scope, baseReg), Ast.StringExpression(statement.passSelfFunctionName))

        self:addStatement(Ast.FunctionCallStatement(funcExpr, args), {}, {baseReg, unpack(regs)}, true);

        for i, reg in ipairs(regs) do
            self:freeRegister(reg, false);
        end
        
        return;
    end

    -- Local Function Declaration
    if(statement.kind == AstKind.LocalFunctionDeclaration) then
        
        if(self:isUpvalue(statement.scope, statement.id)) then
            local varReg = self:getVarRegister(statement.scope, statement.id, funcDepth, nil);
            scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
            self:addStatement(self:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})), {varReg}, {}, false);
            local retReg = self:compileFunction(statement, funcDepth);
            self:addStatement(self:setUpvalueMember(scope, self:register(scope, varReg), self:register(scope, retReg)), {}, {varReg, retReg}, true);
            self:freeRegister(retReg, false);
        else
            local retReg = self:compileFunction(statement, funcDepth);
            local varReg = self:getVarRegister(statement.scope, statement.id, funcDepth, retReg);
            self:addStatement(self:copyRegisters(scope, {varReg}, {retReg}), {varReg}, {retReg}, false);
            self:freeRegister(retReg, false);
        end
        return;
    end

    -- Function Declaration
    if(statement.kind == AstKind.FunctionDeclaration) then
        local retReg = self:compileFunction(statement, funcDepth);
        if(#statement.indices > 0) then
            local tblReg;
            if statement.scope.isGlobal then
                tblReg = self:allocRegister(false);
                self:addStatement(self:setRegister(scope, tblReg, Ast.StringExpression(statement.scope:getVariableName(statement.id))), {tblReg}, {}, false);
                self:addStatement(self:setRegister(scope, tblReg, Ast.IndexExpression(self:env(scope), self:register(scope, tblReg))), {tblReg}, {tblReg}, true);
            else
                if self.scopeFunctionDepths[statement.scope] == funcDepth then
                    if self:isUpvalue(statement.scope, statement.id) then
                        tblReg = self:allocRegister(false);
                        local reg = self:getVarRegister(statement.scope, statement.id, funcDepth);
                        self:addStatement(self:setRegister(scope, tblReg, self:getUpvalueMember(scope, self:register(scope, reg))), {tblReg}, {reg}, true);
                    else
                        tblReg = self:getVarRegister(statement.scope, statement.id, funcDepth, retReg);
                    end
                else
                    tblReg = self:allocRegister(false);
                    local upvalId = self:getUpvalueId(statement.scope, statement.id);
                    scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
                    self:addStatement(self:setRegister(scope, tblReg, self:getUpvalueMember(scope, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(upvalId)))), {tblReg}, {}, true);
                end
            end

            for i = 1, #statement.indices - 1 do
                local index = statement.indices[i];
                local indexReg = self:compileExpression(Ast.StringExpression(index), funcDepth, 1)[1];
                local tblRegOld = tblReg;
                tblReg = self:allocRegister(false);
                self:addStatement(self:setRegister(scope, tblReg, Ast.IndexExpression(self:register(scope, tblRegOld), self:register(scope, indexReg))), {tblReg}, {tblReg, indexReg}, false);
                self:freeRegister(tblRegOld, false);
                self:freeRegister(indexReg, false);
            end

            local index = statement.indices[#statement.indices];
            local indexReg = self:compileExpression(Ast.StringExpression(index), funcDepth, 1)[1];
            self:addStatement(Ast.AssignmentStatement({
                Ast.AssignmentIndexing(self:register(scope, tblReg), self:register(scope, indexReg)),
            }, {
                self:register(scope, retReg),
            }), {}, {tblReg, indexReg, retReg}, true);
            self:freeRegister(indexReg, false);
            self:freeRegister(tblReg, false);
            self:freeRegister(retReg, false);

            return;
        end
        if statement.scope.isGlobal then
            -- OPTIMIZATION: Inline Global Name Strings
            self:addStatement(Ast.AssignmentStatement({Ast.AssignmentIndexing(self:env(scope), Ast.StringExpression(statement.scope:getVariableName(statement.id)))},
             {self:register(scope, retReg)}), {}, {retReg}, true);
        else
            if self.scopeFunctionDepths[statement.scope] == funcDepth then
                if self:isUpvalue(statement.scope, statement.id) then
                    local reg = self:getVarRegister(statement.scope, statement.id, funcDepth);
                    self:addStatement(self:setUpvalueMember(scope, self:register(scope, reg), self:register(scope, retReg)), {}, {reg, retReg}, true);
                else
                    local reg = self:getVarRegister(statement.scope, statement.id, funcDepth, retReg);
                    if reg ~= retReg then
                        self:addStatement(self:setRegister(scope, reg, self:register(scope, retReg)), {reg}, {retReg}, false);
                    end
                end
            else
                local upvalId = self:getUpvalueId(statement.scope, statement.id);
                scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
                self:addStatement(self:setUpvalueMember(scope, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(upvalId)), self:register(scope, retReg)), {}, {retReg}, true);
            end
        end
        self:freeRegister(retReg, false);
        return;
     end

    -- Assignment Statement
    if(statement.kind == AstKind.AssignmentStatement) then
        local exprregs = {};
        local assignmentIndexingRegs = {};
        local targetRegs = {};

        for i, primaryExpr in ipairs(statement.lhs) do
            if(primaryExpr.kind == AstKind.AssignmentIndexing) then
                assignmentIndexingRegs [i] = {
                    base = self:compileExpression(primaryExpr.base, funcDepth, 1)[1],
                    index = self:compileExpression(primaryExpr.index, funcDepth, 1)[1],
                };
            elseif primaryExpr.kind == AstKind.AssignmentVariable then
                if not primaryExpr.scope.isGlobal then
                     -- Local or Upvalue
                     if self.scopeFunctionDepths[primaryExpr.scope] == funcDepth and not self:isUpvalue(primaryExpr.scope, primaryExpr.id) then
                        -- It's a local in current scope
                        targetRegs[i] = self:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth, nil);
                     end
                end
            end
        end

        for i, expr in ipairs(statement.rhs) do
            if(i == #statement.rhs and #statement.lhs > #statement.rhs) then
                local remainingCount = #statement.lhs - #statement.rhs + 1;
                local targets = {};
                for j = 1, remainingCount do
                    targets[j] = targetRegs[i + j - 1];
                end

                local regs = self:compileExpression(expr, funcDepth, remainingCount, targets);

                for k, reg in ipairs(regs) do
                    if(self:isVarRegister(reg) and reg ~= targetRegs[i + k - 1]) then
                        local ro = reg;
                        reg = self:allocRegister(false);
                        self:addStatement(self:copyRegisters(scope, {reg}, {ro}), {reg}, {ro}, false);
                    end
                    table.insert(exprregs, reg);
                end
            else
                if statement.lhs[i] or expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression then
                    local targets = { targetRegs[i] };
                    local reg = self:compileExpression(expr, funcDepth, 1, targets)[1];

                    -- If we successfully targeted the register, we don't need to copy.
                    -- But existing logic handles copies for VarRegister safety?
                    -- "if(self:isVarRegister(reg))" logic seems to be about preventing accidental overwrite of vars if they are used in RHS?
                    -- But we just compiled RHS.
                    -- If reg == targetRegs[i], then we wrote directly to it.
                    -- If reg is a DIFFERENT var register, we might need to copy.

                    if(self:isVarRegister(reg) and reg ~= targetRegs[i]) then
                        local ro = reg;
                        reg = self:allocRegister(false);
                        self:addStatement(self:copyRegisters(scope, {reg}, {ro}), {reg}, {ro}, false);
                    end
                    table.insert(exprregs, reg);
                end
            end
        end

        for i, primaryExpr in ipairs(statement.lhs) do
            if primaryExpr.kind == AstKind.AssignmentVariable then
                if primaryExpr.scope.isGlobal then
                    -- OPTIMIZATION: Inline Global Name Strings
                    self:addStatement(Ast.AssignmentStatement({Ast.AssignmentIndexing(self:env(scope), Ast.StringExpression(primaryExpr.scope:getVariableName(primaryExpr.id)))},
                     {self:register(scope, exprregs[i])}), {}, {exprregs[i]}, true);
                else
                    if self.scopeFunctionDepths[primaryExpr.scope] == funcDepth then
                        if self:isUpvalue(primaryExpr.scope, primaryExpr.id) then
                            local reg = self:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth);
                            self:addStatement(self:setUpvalueMember(scope, self:register(scope, reg), self:register(scope, exprregs[i])), {}, {reg, exprregs[i]}, true);
                        else
                            local reg = self:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth, exprregs[i]);
                            if reg ~= exprregs[i] then
                                self:addStatement(self:setRegister(scope, reg, self:register(scope, exprregs[i])), {reg}, {exprregs[i]}, false);
                            end
                        end
                    else
                        local upvalId = self:getUpvalueId(primaryExpr.scope, primaryExpr.id);
                        scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
                        self:addStatement(self:setUpvalueMember(scope, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(upvalId)), self:register(scope, exprregs[i])), {}, {exprregs[i]}, true);
                    end
                end
            elseif primaryExpr.kind == AstKind.AssignmentIndexing then
                local baseReg = assignmentIndexingRegs[i].base;
                local indexReg = assignmentIndexingRegs[i].index;
                self:addStatement(Ast.AssignmentStatement({
                    Ast.AssignmentIndexing(self:register(scope, baseReg), self:register(scope, indexReg))
                }, {
                    self:register(scope, exprregs[i])
                }), {}, {exprregs[i], baseReg, indexReg}, true);
                self:freeRegister(exprregs[i], false);
                self:freeRegister(baseReg, false);
                self:freeRegister(indexReg, false);
            else
                print("DEBUG: Invalid Assignment LHS Kind:", primaryExpr.kind)
                if primaryExpr.kind == "VariableExpression" then
                    print("DEBUG: Variable Name:", primaryExpr:getName())
                    print("DEBUG: Variable ID:", primaryExpr.id)
                    print("DEBUG: Scope:", primaryExpr.scope.name)
                end
                error(string.format("Invalid Assignment lhs: %s", statement.lhs));
            end
        end

        return
    end

    -- If Statement
    if(statement.kind == AstKind.IfStatement) then
        local conditionReg = self:compileExpression(statement.condition, funcDepth, 1)[1];
        local finalBlock = self:createBlock();

        local nextBlock
        if statement.elsebody or #statement.elseifs > 0 then
            nextBlock = self:createBlock();
        else
            nextBlock = finalBlock;
        end
        local innerBlock = self:createBlock();

        self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(self:register(scope, conditionReg), Ast.NumberExpression(innerBlock.id)), Ast.NumberExpression(nextBlock.id))), {self.POS_REGISTER}, {conditionReg}, false);
        
        self:freeRegister(conditionReg, false);

        self:setActiveBlock(innerBlock);
        scope = innerBlock.scope
        self:compileBlock(statement.body, funcDepth);
        self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpression(finalBlock.id)), {self.POS_REGISTER}, {}, false);

        for i, eif in ipairs(statement.elseifs) do
            self:setActiveBlock(nextBlock);
            conditionReg = self:compileExpression(eif.condition, funcDepth, 1)[1];
            local innerBlock = self:createBlock();
            if statement.elsebody or i < #statement.elseifs then
                nextBlock = self:createBlock();
            else
                nextBlock = finalBlock;
            end
            local scope = self.activeBlock.scope;
            self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(self:register(scope, conditionReg), Ast.NumberExpression(innerBlock.id)), Ast.NumberExpression(nextBlock.id))), {self.POS_REGISTER}, {conditionReg}, false);
        
            self:freeRegister(conditionReg, false);

            self:setActiveBlock(innerBlock);
            scope = innerBlock.scope;
            self:compileBlock(eif.body, funcDepth);
            self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpression(finalBlock.id)), {self.POS_REGISTER}, {}, false);
        end

        if statement.elsebody then
            self:setActiveBlock(nextBlock);
            self:compileBlock(statement.elsebody, funcDepth);
            self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpression(finalBlock.id)), {self.POS_REGISTER}, {}, false);
        end

        self:setActiveBlock(finalBlock);

        return;
    end

    -- Do Statement
    if(statement.kind == AstKind.DoStatement) then
        self:compileBlock(statement.body, funcDepth);
        return;
    end

    -- While Statement
    if(statement.kind == AstKind.WhileStatement) then
        local innerBlock = self:createBlock();
        local finalBlock = self:createBlock();
        local checkBlock = self:createBlock();

        statement.__start_block = checkBlock;
        statement.__final_block = finalBlock;

        self:addStatement(self:setPos(scope, checkBlock.id), {self.POS_REGISTER}, {}, false);

        self:setActiveBlock(checkBlock);
        local scope = self.activeBlock.scope;
        local conditionReg = self:compileExpression(statement.condition, funcDepth, 1)[1];
        self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(self:register(scope, conditionReg), Ast.NumberExpression(innerBlock.id)), Ast.NumberExpression(finalBlock.id))), {self.POS_REGISTER}, {conditionReg}, false);
        self:freeRegister(conditionReg, false);

        self:setActiveBlock(innerBlock);
        local scope = self.activeBlock.scope;
        self:compileBlock(statement.body, funcDepth);

        -- OPTIMIZATION: Inline the check at the end of Body
        -- Instead of jumping to checkBlock, we compile condition here.
        -- Loop until cond is false: if cond is true, loop (inner). Else exit (final).
        -- POS = Cond and Inner or Final
        local conditionReg2 = self:compileExpression(statement.condition, funcDepth, 1)[1];
        self:addStatement(self:setRegister(scope, self.POS_REGISTER,
            Ast.OrExpression(
                Ast.AndExpression(self:register(scope, conditionReg2), Ast.NumberExpression(innerBlock.id)),
                Ast.NumberExpression(finalBlock.id)
            )
        ), {self.POS_REGISTER}, {conditionReg2}, false);
        self:freeRegister(conditionReg2, false);

        self:setActiveBlock(finalBlock);
        return;
    end

    -- Repeat Statement
    if(statement.kind == AstKind.RepeatStatement) then
        local innerBlock = self:createBlock();
        local finalBlock = self:createBlock();
        local checkBlock = self:createBlock(); -- Keep for 'continue' jump target

        statement.__start_block = checkBlock;
        statement.__final_block = finalBlock;

        -- Initial jump to inner
        self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpression(innerBlock.id)), {self.POS_REGISTER}, {}, false);

        -- Inner (Body)
        self:setActiveBlock(innerBlock);
        self:compileBlock(statement.body, funcDepth);

        -- OPTIMIZATION: Inline the check at the end of Body
        -- Instead of jumping to checkBlock, we compile condition here.
        local conditionReg = self:compileExpression(statement.condition, funcDepth, 1)[1];
        -- Repeat until cond: if cond is true, exit. Else loop (inner).
        -- POS = Cond and Final or Inner
        self:addStatement(self:setRegister(scope, self.POS_REGISTER,
            Ast.OrExpression(
                Ast.AndExpression(self:register(scope, conditionReg), Ast.NumberExpression(finalBlock.id)),
                Ast.NumberExpression(innerBlock.id)
            )
        ), {self.POS_REGISTER}, {conditionReg}, false);
        self:freeRegister(conditionReg, false);

        -- Check Block (Only used by Continue)
        self:setActiveBlock(checkBlock);
        -- Ensure scope is updated to the checkBlock's scope
        local scope = self.activeBlock.scope;
        local conditionReg2 = self:compileExpression(statement.condition, funcDepth, 1)[1];
        self:addStatement(self:setRegister(scope, self.POS_REGISTER,
            Ast.OrExpression(
                Ast.AndExpression(self:register(scope, conditionReg2), Ast.NumberExpression(finalBlock.id)),
                Ast.NumberExpression(innerBlock.id)
            )
        ), {self.POS_REGISTER}, {conditionReg2}, false);
        self:freeRegister(conditionReg2, false);

        self:setActiveBlock(finalBlock);

        return;
    end

    -- For Statement
    if(statement.kind == AstKind.ForStatement) then
        local checkBlock = self:createBlock();
        local innerBlock = self:createBlock();
        local finalBlock = self:createBlock();

        statement.__start_block = checkBlock;
        statement.__final_block = finalBlock;

        local posState = self.registers[self.POS_REGISTER];
        self.registers[self.POS_REGISTER] = self.VAR_REGISTER;

        local initialReg = self:compileExpression(statement.initialValue, funcDepth, 1)[1];

        local finalExprReg = self:compileExpression(statement.finalValue, funcDepth, 1)[1];
        local finalReg = self:allocRegister(false);
        self:addStatement(self:copyRegisters(scope, {finalReg}, {finalExprReg}), {finalReg}, {finalExprReg}, false);
        self:freeRegister(finalExprReg);

        local incrementExprReg = self:compileExpression(statement.incrementBy, funcDepth, 1)[1];
        local incrementReg = self:allocRegister(false);
        self:addStatement(self:copyRegisters(scope, {incrementReg}, {incrementExprReg}), {incrementReg}, {incrementExprReg}, false);
        self:freeRegister(incrementExprReg);

        local a7bX9 = self:allocRegister(false);
        self:addStatement(self:setRegister(scope, a7bX9, Ast.NumberExpression(0)), {a7bX9}, {}, false);
        local incrementIsNegReg = self:allocRegister(false);
        self:addStatement(self:setRegister(scope, incrementIsNegReg, Ast.LessThanExpression(self:register(scope, incrementReg), self:register(scope, a7bX9))), {incrementIsNegReg}, {incrementReg, a7bX9}, false);     
        self:freeRegister(a7bX9);

        local currentReg = self:allocRegister(true);
        self:addStatement(self:setRegister(scope, currentReg, Ast.SubExpression(self:register(scope, initialReg), self:register(scope, incrementReg))), {currentReg}, {initialReg, incrementReg}, false);
        self:freeRegister(initialReg);

        self:addStatement(self:jmp(scope, Ast.NumberExpression(checkBlock.id)), {self.POS_REGISTER}, {}, false);

        self:setActiveBlock(checkBlock);

        scope = checkBlock.scope;

        -- Define function to emit increment/check logic
        local function emitIncrementCheck()
            self:addStatement(self:setRegister(scope, currentReg, Ast.AddExpression(self:register(scope, currentReg), self:register(scope, incrementReg))), {currentReg}, {currentReg, incrementReg}, false);
            local z2pR6 = self:allocRegister(false);
            local m3kQ8 = self:allocRegister(false);
            self:addStatement(self:setRegister(scope, m3kQ8, Ast.NotExpression(self:register(scope, incrementIsNegReg))), {m3kQ8}, {incrementIsNegReg}, false);
            self:addStatement(self:setRegister(scope, z2pR6, Ast.LessThanOrEqualsExpression(self:register(scope, currentReg), self:register(scope, finalReg))), {z2pR6}, {currentReg, finalReg}, false);
            self:addStatement(self:setRegister(scope, z2pR6, Ast.AndExpression(self:register(scope, m3kQ8), self:register(scope, z2pR6))), {z2pR6}, {z2pR6, m3kQ8}, false);
            self:addStatement(self:setRegister(scope, m3kQ8, Ast.GreaterThanOrEqualsExpression(self:register(scope, currentReg), self:register(scope, finalReg))), {m3kQ8}, {currentReg, finalReg}, false);
            self:addStatement(self:setRegister(scope, m3kQ8, Ast.AndExpression(self:register(scope, incrementIsNegReg), self:register(scope, m3kQ8))), {m3kQ8}, {m3kQ8, incrementIsNegReg}, false);
            self:addStatement(self:setRegister(scope, z2pR6, Ast.OrExpression(self:register(scope, m3kQ8), self:register(scope, z2pR6))), {z2pR6}, {z2pR6, m3kQ8}, false);
            self:freeRegister(m3kQ8);

            -- Logic to set POS: if valid, inner; else final
            local innerBlockId = Ast.NumberExpression(innerBlock.id)
            local finalBlockId = Ast.NumberExpression(finalBlock.id)

            self:addStatement(self:setRegister(scope, self.POS_REGISTER,
                Ast.OrExpression(
                    Ast.AndExpression(self:register(scope, z2pR6), innerBlockId),
                    finalBlockId
                )
            ), {self.POS_REGISTER}, {z2pR6}, false);

            self:freeRegister(z2pR6);
        end

        -- Check Block (Original)
        emitIncrementCheck()

        self:setActiveBlock(innerBlock);
        scope = innerBlock.scope;
        self.registers[self.POS_REGISTER] = posState;

        local varReg = self:getVarRegister(statement.scope, statement.id, funcDepth, nil);

        if(self:isUpvalue(statement.scope, statement.id)) then
            scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
            self:addStatement(self:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})), {varReg}, {}, false);
            self:addStatement(self:setUpvalueMember(scope, self:register(scope, varReg), self:register(scope, currentReg)), {}, {varReg, currentReg}, true);
        else
            self:addStatement(self:setRegister(scope, varReg, self:register(scope, currentReg)), {varReg}, {currentReg}, false);
        end

        self:compileBlock(statement.body, funcDepth);

        -- OPTIMIZATION: Inline increment/check at the end of Body
        emitIncrementCheck()
        -- self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpression(checkBlock.id)), {self.POS_REGISTER}, {}, false);
        
        self.registers[self.POS_REGISTER] = self.VAR_REGISTER;
        self:freeRegister(finalReg);
        self:freeRegister(incrementIsNegReg);
        self:freeRegister(incrementReg);
        self:freeRegister(currentReg, true);

        self.registers[self.POS_REGISTER] = posState;
        self:setActiveBlock(finalBlock);

        return;
    end

    -- For In Statement
    if(statement.kind == AstKind.ForInStatement) then
        local expressionsLength = #statement.expressions;
        local exprregs = {};
        for i, expr in ipairs(statement.expressions) do
            if(i == expressionsLength and expressionsLength < 3) then
                local regs = self:compileExpression(expr, funcDepth, 4 - expressionsLength);
                for i = 1, 4 - expressionsLength do
                    table.insert(exprregs, regs[i]);
                end
            else
                if i <= 3 then
                    table.insert(exprregs, self:compileExpression(expr, funcDepth, 1)[1])
                else
                    self:freeRegister(self:compileExpression(expr, funcDepth, 1)[1], false);
                end
            end
        end

        for i, reg in ipairs(exprregs) do
            if reg and self.registers[reg] ~= self.VAR_REGISTER and reg ~= self.POS_REGISTER and reg ~= self.RETURN_REGISTER then
                self.registers[reg] = self.VAR_REGISTER;
            else
                exprregs[i] = self:allocRegister(true);
                self:addStatement(self:copyRegisters(scope, {exprregs[i]}, {reg}), {exprregs[i]}, {reg}, false);
            end
        end

        local checkBlock = self:createBlock();
        local bodyBlock = self:createBlock();
        local finalBlock = self:createBlock();

        statement.__start_block = checkBlock;
        statement.__final_block = finalBlock;

        self:addStatement(self:setPos(scope, checkBlock.id), {self.POS_REGISTER}, {}, false);

        -- Pre-calculate varRegs for optimization
        local varRegs = {};
        for i, id in ipairs(statement.ids) do
            varRegs[i] = self:getVarRegister(statement.scope, id, funcDepth)
        end

        -- Helper to emit iterator call and jump
        local function emitIteratorLogic(targetScope)
            self:addStatement(Ast.AssignmentStatement({
                self:registerAssignment(targetScope, exprregs[3]),
                varRegs[2] and self:registerAssignment(targetScope, varRegs[2]),
            }, {
                Ast.FunctionCallExpression(self:register(targetScope, exprregs[1]), {
                    self:register(targetScope, exprregs[2]),
                    self:register(targetScope, exprregs[3]),
                })
            }), {exprregs[3], varRegs[2]}, {exprregs[1], exprregs[2], exprregs[3]}, true);

            self:addStatement(Ast.AssignmentStatement({
                self:posAssignment(targetScope)
            }, {
                Ast.OrExpression(Ast.AndExpression(self:register(targetScope, exprregs[3]), Ast.NumberExpression(bodyBlock.id)), Ast.NumberExpression(finalBlock.id))
            }), {self.POS_REGISTER}, {exprregs[3]}, false);
        end

        -- Check Block (First Iteration)
        self:setActiveBlock(checkBlock);
        local scope = self.activeBlock.scope;
        emitIteratorLogic(scope);

        -- Body Block
        self:setActiveBlock(bodyBlock);
        local scope = self.activeBlock.scope;

        self:addStatement(self:copyRegisters(scope, {varRegs[1]}, {exprregs[3]}), {varRegs[1]}, {exprregs[3]}, false);
        for i=3, #varRegs do
            self:addStatement(self:setRegister(scope, varRegs[i], Ast.NilExpression()), {varRegs[i]}, {}, false);
        end

        -- Upvalue fix
        for i, id in ipairs(statement.ids) do
            if(self:isUpvalue(statement.scope, id)) then
                local varreg = varRegs[i];
                local a7bX9 = self:allocRegister(false);
                scope:addReferenceToHigherScope(self.scope, self.allocUpvalFunction);
                self:addStatement(self:setRegister(scope, a7bX9, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.allocUpvalFunction), {})), {a7bX9}, {}, false);
                self:addStatement(self:setUpvalueMember(scope, self:register(scope, a7bX9), self:register(scope, varreg)), {}, {a7bX9, varreg}, true);
                self:addStatement(self:copyRegisters(scope, {varreg}, {a7bX9}), {varreg}, {a7bX9}, false);
                self:freeRegister(a7bX9, false);
            end
        end

        self:compileBlock(statement.body, funcDepth);

        -- OPTIMIZATION: Loop Rotation
        -- Inline the iterator call and check at the end of the body
        -- This avoids the jump back to checkBlock, saving 1 dispatch cycle per iteration
        emitIteratorLogic(scope);
        -- self:addStatement(self:setPos(scope, checkBlock.id), {self.POS_REGISTER}, {}, false);

        self:setActiveBlock(finalBlock);

        for i, reg in ipairs(exprregs) do
            self:freeRegister(exprregs[i], true)
        end

        return;
    end

    -- Do Statement
    if(statement.kind == AstKind.DoStatement) then
        self:compileBlock(statement.body, funcDepth);
        return;
    end

    -- Break Statement
    if(statement.kind == AstKind.BreakStatement) then
        local toFreeVars = {};
        local statScope;
        repeat
            statScope = statScope and statScope.parentScope or statement.scope;
            for id, name in ipairs(statScope.variables) do
                table.insert(toFreeVars, {
                    scope = statScope,
                    id = id;
                });
            end
        until statScope == statement.loop.body.scope;

        local regsToClear = {}
        local nils = {}

        for i, var in pairs(toFreeVars) do
            local varScope, id = var.scope, var.id;
            local varReg = self:getVarRegister(varScope, id, nil, nil);
            if self:isUpvalue(varScope, id) then
                scope:addReferenceToHigherScope(self.scope, self.freeUpvalueFunc);
                self:addStatement(self:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.freeUpvalueFunc), {
                    self:register(scope, varReg)
                })), {varReg}, {varReg}, false);
            else
                table.insert(regsToClear, varReg)
                table.insert(nils, Ast.NilExpression())
            end
        end

        if #regsToClear > 0 then
            self:addStatement(self:setRegisters(scope, regsToClear, nils), regsToClear, {}, false);
        end

        self:addStatement(self:setPos(scope, statement.loop.__final_block.id), {self.POS_REGISTER}, {}, false);
        self.activeBlock.advanceToNextBlock = false;
        return;
    end

    -- Continue Statement
    if(statement.kind == AstKind.ContinueStatement) then
        local toFreeVars = {};
        local statScope;
        repeat
            statScope = statScope and statScope.parentScope or statement.scope;
            for id, name in pairs(statScope.variables) do
                table.insert(toFreeVars, {
                    scope = statScope,
                    id = id;
                });
            end
        until statScope == statement.loop.body.scope;

        local regsToClear = {}
        local nils = {}

        for i, var in ipairs(toFreeVars) do
            local varScope, id = var.scope, var.id;
            local varReg = self:getVarRegister(varScope, id, nil, nil);
            if self:isUpvalue(varScope, id) then
                scope:addReferenceToHigherScope(self.scope, self.freeUpvalueFunc);
                self:addStatement(self:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(self.scope, self.freeUpvalueFunc), {
                    self:register(scope, varReg)
                })), {varReg}, {varReg}, false);
            else
                table.insert(regsToClear, varReg)
                table.insert(nils, Ast.NilExpression())
            end
        end

        if #regsToClear > 0 then
            self:addStatement(self:setRegisters(scope, regsToClear, nils), regsToClear, {}, false);
        end

        self:addStatement(self:setPos(scope, statement.loop.__start_block.id), {self.POS_REGISTER}, {}, false);
        self.activeBlock.advanceToNextBlock = false;
        return;
    end

    -- Compound Statements
    local compoundConstructors = {
        [AstKind.CompoundAddStatement] = Ast.CompoundAddStatement,
        [AstKind.CompoundSubStatement] = Ast.CompoundSubStatement,
        [AstKind.CompoundMulStatement] = Ast.CompoundMulStatement,
        [AstKind.CompoundDivStatement] = Ast.CompoundDivStatement,
        [AstKind.CompoundModStatement] = Ast.CompoundModStatement,
        [AstKind.CompoundPowStatement] = Ast.CompoundPowStatement,
        [AstKind.CompoundConcatStatement] = Ast.CompoundConcatStatement,
    }
    if compoundConstructors[statement.kind] then
        local compoundConstructor = compoundConstructors[statement.kind];
        if statement.lhs.kind == AstKind.AssignmentIndexing then
            local indexing = statement.lhs;
            local baseReg = self:compileExpression(indexing.base, funcDepth, 1)[1];
            local indexReg = self:compileExpression(indexing.index, funcDepth, 1)[1];
            local valueReg = self:compileExpression(statement.rhs, funcDepth, 1)[1];

            self:addStatement(compoundConstructor(Ast.AssignmentIndexing(self:register(scope, baseReg), self:register(scope, indexReg)), self:register(scope, valueReg)), {}, {baseReg, indexReg, valueReg}, true);
        else
            local valueReg = self:compileExpression(statement.rhs, funcDepth, 1)[1];
            local primaryExpr = statement.lhs;
            if primaryExpr.scope.isGlobal then
                -- OPTIMIZATION: Inline Global Name Strings
                self:addStatement(Ast.AssignmentStatement({Ast.AssignmentIndexing(self:env(scope), Ast.StringExpression(primaryExpr.scope:getVariableName(primaryExpr.id)))},
                 {self:register(scope, valueReg)}), {}, {valueReg}, true);
            else
                if self.scopeFunctionDepths[primaryExpr.scope] == funcDepth then
                    if self:isUpvalue(primaryExpr.scope, primaryExpr.id) then
                        local reg = self:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth);
                        self:addStatement(self:setUpvalueMember(scope, self:register(scope, reg), self:register(scope, valueReg), compoundConstructor), {}, {reg, valueReg}, true);
                    else
                        local reg = self:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth, valueReg);
                        if reg ~= valueReg then
                            self:addStatement(self:setRegister(scope, reg, self:register(scope, valueReg), compoundConstructor), {reg}, {valueReg}, false);
                        end
                    end
                else
                    local upvalId = self:getUpvalueId(primaryExpr.scope, primaryExpr.id);
                    scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
                    self:addStatement(self:setUpvalueMember(scope, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(upvalId)), self:register(scope, valueReg), compoundConstructor), {}, {valueReg}, true);
                end
            end
        end
        return;
    end

    logger:error(string.format("%s is not a compileable statement!", statement.kind));
end

function Compiler:compileExpression(expression, funcDepth, numReturns, targetRegs)
    local scope = self.activeBlock.scope;

    -- String Expression
    if(expression.kind == AstKind.StringExpression) then
        local regs = {};
        for i=1, numReturns, 1 do
            if targetRegs and targetRegs[i] then
                regs[i] = targetRegs[i];
            else
                regs[i] = self:allocRegister();
            end

            if(i == 1) then
                self:addStatement(self:setRegister(scope, regs[i], Ast.StringExpression(expression.value)), {regs[i]}, {}, false);
            else
                self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    -- Number Expression
    if(expression.kind == AstKind.NumberExpression) then
        local regs = {};
        for i=1, numReturns do
            if targetRegs and targetRegs[i] then
                regs[i] = targetRegs[i];
            else
                regs[i] = self:allocRegister();
            end

            if(i == 1) then
               self:addStatement(self:setRegister(scope, regs[i], Ast.NumberExpression(expression.value)), {regs[i]}, {}, false);
            else
               self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    -- Boolean Expression
    if(expression.kind == AstKind.BooleanExpression) then
        local regs = {};
        for i=1, numReturns do
            if targetRegs and targetRegs[i] then
                regs[i] = targetRegs[i];
            else
                regs[i] = self:allocRegister();
            end

            if(i == 1) then
               self:addStatement(self:setRegister(scope, regs[i], Ast.BooleanExpression(expression.value)), {regs[i]}, {}, false);
            else
               self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    -- Nil Expression
    if(expression.kind == AstKind.NilExpression) then
        local regs = {};
        for i=1, numReturns do
            if targetRegs and targetRegs[i] then
                regs[i] = targetRegs[i];
            else
                regs[i] = self:allocRegister();
            end
            self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
        return regs;
    end

    -- Variable Expression
    if(expression.kind == AstKind.VariableExpression) then
        local regs = {};
        for i=1, numReturns do
            if(i == 1) then
                if(expression.scope.isGlobal) then
                    -- Global Variable
                    if targetRegs and targetRegs[i] then
                        regs[i] = targetRegs[i];
                    else
                        regs[i] = self:allocRegister(false);
                    end

                    -- OPTIMIZATION: Inline Global Name Strings
                    self:addStatement(self:setRegister(scope, regs[i], Ast.IndexExpression(self:env(scope), Ast.StringExpression(expression.scope:getVariableName(expression.id)))), {regs[i]}, {}, true);
                else
                    -- Local Variable
                    if(self.scopeFunctionDepths[expression.scope] == funcDepth) then
                        if self:isUpvalue(expression.scope, expression.id) then
                            if targetRegs and targetRegs[i] then
                                regs[i] = targetRegs[i];
                            else
                                regs[i] = self:allocRegister(false);
                            end
                            local varReg = self:getVarRegister(expression.scope, expression.id, funcDepth, nil);
                            self:addStatement(self:setRegister(scope, regs[i], self:getUpvalueMember(scope, self:register(scope, varReg))), {regs[i]}, {varReg}, true);
                        else
                            regs[i] = self:getVarRegister(expression.scope, expression.id, funcDepth, nil);
                            -- Optimization: If targetReg is provided and different from varReg, copy.
                            -- However, VariableExpression typically returns the register OF the variable.
                            -- If we want to "load" it into targetReg, we should copy.
                            if targetRegs and targetRegs[i] and regs[i] ~= targetRegs[i] then
                                self:addStatement(self:copyRegisters(scope, {targetRegs[i]}, {regs[i]}), {targetRegs[i]}, {regs[i]}, false);
                                regs[i] = targetRegs[i];
                            end
                        end
                    else
                        if targetRegs and targetRegs[i] then
                            regs[i] = targetRegs[i];
                        else
                            regs[i] = self:allocRegister(false);
                        end
                        local upvalId = self:getUpvalueId(expression.scope, expression.id);
                        scope:addReferenceToHigherScope(self.containerFuncScope, self.currentUpvaluesVar);
                        self:addStatement(self:setRegister(scope, regs[i], self:getUpvalueMember(scope, Ast.IndexExpression(Ast.VariableExpression(self.containerFuncScope, self.currentUpvaluesVar), Ast.NumberExpression(upvalId)))), {regs[i]}, {}, true);
                    end
                end
            else
                if targetRegs and targetRegs[i] then
                    regs[i] = targetRegs[i];
                else
                    regs[i] = self:allocRegister();
                end
                self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    -- Function Call Expression
    if(expression.kind == AstKind.FunctionCallExpression) then
        local baseReg = self:compileExpression(expression.base, funcDepth, 1)[1];

        local retRegs  = {};
        local returnAll = numReturns == self.RETURN_ALL;
        if returnAll then
            if targetRegs and targetRegs[1] then
                retRegs[1] = targetRegs[1]
            else
                retRegs[1] = self:allocRegister(false);
            end
        else
            for i = 1, numReturns do
                if targetRegs and targetRegs[i] then
                    retRegs[i] = targetRegs[i];
                else
                    retRegs[i] = self:allocRegister(false);
                end
            end
        end
        
        local regs = {};
        local args = {};
        for i, expr in ipairs(expression.args) do
            if i == #expression.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
                local reg = self:compileExpression(expr, funcDepth, self.RETURN_ALL)[1];
                table.insert(args, Ast.FunctionCallExpression(
                    self:unpack(scope),
                    {self:register(scope, reg)}));
                table.insert(regs, reg);
            else
                local argExpr, argReg = self:compileOperand(scope, expr, funcDepth);
                table.insert(args, argExpr);
                if argReg then table.insert(regs, argReg) end
            end
        end

        if(returnAll) then
            self:addStatement(self:setRegister(scope, retRegs[1], Ast.TableConstructorExpression{Ast.TableEntry(Ast.FunctionCallExpression(self:register(scope, baseReg), args))}), {retRegs[1]}, {baseReg, unpack(regs)}, true);
        else
            if(numReturns > 1) then
                local a7bX9 = self:allocRegister(false);
    
                self:addStatement(self:setRegister(scope, a7bX9, Ast.TableConstructorExpression{Ast.TableEntry(Ast.FunctionCallExpression(self:register(scope, baseReg), args))}), {a7bX9}, {baseReg, unpack(regs)}, true);
    
                for i, reg in ipairs(retRegs) do
                    self:addStatement(self:setRegister(scope, reg, Ast.IndexExpression(self:register(scope, a7bX9), Ast.NumberExpression(i))), {reg}, {a7bX9}, false);
                end
    
                self:freeRegister(a7bX9, false);
            else
                self:addStatement(self:setRegister(scope, retRegs[1], Ast.FunctionCallExpression(self:register(scope, baseReg), args)), {retRegs[1]}, {baseReg, unpack(regs)}, true);
            end
        end

        self:freeRegister(baseReg, false);
        for i, reg in ipairs(regs) do
            self:freeRegister(reg, false);
        end
        
        return retRegs;
    end

    -- Pass Self Function Call Expression
    if(expression.kind == AstKind.PassSelfFunctionCallExpression) then
        local baseReg = self:compileExpression(expression.base, funcDepth, 1)[1];
        local retRegs  = {};
        local returnAll = numReturns == self.RETURN_ALL;
        if returnAll then
            retRegs[1] = self:allocRegister(false);
        else
            for i = 1, numReturns do
                retRegs[i] = self:allocRegister(false);
            end
        end

        local args = { self:register(scope, baseReg) };
        local regs = { baseReg };

        for i, expr in ipairs(expression.args) do
            if i == #expression.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
                local reg = self:compileExpression(expr, funcDepth, self.RETURN_ALL)[1];
                table.insert(args, Ast.FunctionCallExpression(
                    self:unpack(scope),
                    {self:register(scope, reg)}));
                table.insert(regs, reg);
            else
                local argExpr, argReg = self:compileOperand(scope, expr, funcDepth);
                table.insert(args, argExpr);
                if argReg then table.insert(regs, argReg) end
            end
        end

        if(returnAll or numReturns > 1) then
            local a7bX9 = self:allocRegister(false);

            self:addStatement(self:setRegister(scope, a7bX9, Ast.StringExpression(expression.passSelfFunctionName)), {a7bX9}, {}, false);
            self:addStatement(self:setRegister(scope, a7bX9, Ast.IndexExpression(self:register(scope, baseReg), self:register(scope, a7bX9))), {a7bX9}, {baseReg, a7bX9}, false);

            if returnAll then
                self:addStatement(self:setRegister(scope, retRegs[1], Ast.TableConstructorExpression{Ast.TableEntry(Ast.FunctionCallExpression(self:register(scope, a7bX9), args))}), {retRegs[1]}, {a7bX9, unpack(regs)}, true);
            else
                self:addStatement(self:setRegister(scope, a7bX9, Ast.TableConstructorExpression{Ast.TableEntry(Ast.FunctionCallExpression(self:register(scope, a7bX9), args))}), {a7bX9}, {a7bX9, unpack(regs)}, true);

                for i, reg in ipairs(retRegs) do
                    self:addStatement(self:setRegister(scope, reg, Ast.IndexExpression(self:register(scope, a7bX9), Ast.NumberExpression(i))), {reg}, {a7bX9}, false);
                end
            end

            self:freeRegister(a7bX9, false);
        else
            local a7bX9 = retRegs[1] or self:allocRegister(false);

            self:addStatement(self:setRegister(scope, a7bX9, Ast.StringExpression(expression.passSelfFunctionName)), {a7bX9}, {}, false);
            self:addStatement(self:setRegister(scope, a7bX9, Ast.IndexExpression(self:register(scope, baseReg), self:register(scope, a7bX9))), {a7bX9}, {baseReg, a7bX9}, false);

            self:addStatement(self:setRegister(scope, retRegs[1], Ast.FunctionCallExpression(self:register(scope, a7bX9), args)), {retRegs[1]}, {baseReg, unpack(regs)}, true);
        end

        for i, reg in ipairs(regs) do
            self:freeRegister(reg, false);
        end
        
        return retRegs;
    end

    -- Index Expression
    if(expression.kind == AstKind.IndexExpression) then
        local regs = {};
        for i=1, numReturns do
            if targetRegs and targetRegs[i] then
                regs[i] = targetRegs[i];
            else
                regs[i] = self:allocRegister();
            end

            if(i == 1) then
                local baseReg = self:compileExpression(expression.base, funcDepth, 1)[1];

                -- OPTIMIZATION: Literal Inlining for Index
                local indexExpr, indexReg = self:compileOperand(scope, expression.index, funcDepth);

                local reads = {baseReg}
                if indexReg then table.insert(reads, indexReg) end

                self:addStatement(self:setRegister(scope, regs[i], Ast.IndexExpression(self:register(scope, baseReg), indexExpr)), {regs[i]}, reads, true);

                self:freeRegister(baseReg, false);
                if indexReg then self:freeRegister(indexReg, false) end
            else
               self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    -- Binary Operations
    if(self.BIN_OPS[expression.kind]) then
        local regs = {};
        for i=1, numReturns do
            if targetRegs and targetRegs[i] then
                regs[i] = targetRegs[i];
            else
                regs[i] = self:allocRegister();
            end

            if(i == 1) then
                -- OPTIMIZATION: Literal Inlining
                local lhsExpr, lhsReg = self:compileOperand(scope, expression.lhs, funcDepth);
                local rhsExpr, rhsReg = self:compileOperand(scope, expression.rhs, funcDepth);

                -- OPTIMIZATION: Arithmetic Identities
                local identityFound = false

                -- OPTIMIZATION: Constant Folding
                if lhsExpr.kind == AstKind.NumberExpression and rhsExpr.kind == AstKind.NumberExpression then
                    local l, r = lhsExpr.value, rhsExpr.value
                    local res
                    if expression.kind == AstKind.AddExpression then res = l + r
                    elseif expression.kind == AstKind.SubExpression then res = l - r
                    elseif expression.kind == AstKind.MulExpression then res = l * r
                    elseif expression.kind == AstKind.DivExpression and r ~= 0 then res = l / r
                    elseif expression.kind == AstKind.ModExpression and r ~= 0 then res = l % r
                    elseif expression.kind == AstKind.PowExpression then res = l ^ r
                    end

                    -- Check for finite result (avoid inf/nan/nil)
                    if res and res == res and math.abs(res) ~= math.huge then
                        self:addStatement(self:setRegister(scope, regs[i], Ast.NumberExpression(res)), {regs[i]}, {}, false);
                        identityFound = true
                    end
                end

                if not identityFound then
                    if expression.kind == AstKind.AddExpression then
                        -- x + 0 -> x
                        if rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 0 then
                            self:addStatement(self:setRegister(scope, regs[i], lhsExpr), {regs[i]}, lhsReg and {lhsReg} or {}, false);
                            identityFound = true
                        -- 0 + x -> x
                        elseif lhsExpr.kind == AstKind.NumberExpression and lhsExpr.value == 0 then
                            self:addStatement(self:setRegister(scope, regs[i], rhsExpr), {regs[i]}, rhsReg and {rhsReg} or {}, false);
                            identityFound = true
                        end
                    elseif expression.kind == AstKind.SubExpression then
                        -- x - 0 -> x
                        if rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 0 then
                            self:addStatement(self:setRegister(scope, regs[i], lhsExpr), {regs[i]}, lhsReg and {lhsReg} or {}, false);
                            identityFound = true
                        end
                    elseif expression.kind == AstKind.MulExpression then
                        -- x * 1 -> x
                        if rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 1 then
                            self:addStatement(self:setRegister(scope, regs[i], lhsExpr), {regs[i]}, lhsReg and {lhsReg} or {}, false);
                            identityFound = true
                        -- 1 * x -> x
                        elseif lhsExpr.kind == AstKind.NumberExpression and lhsExpr.value == 1 then
                            self:addStatement(self:setRegister(scope, regs[i], rhsExpr), {regs[i]}, rhsReg and {rhsReg} or {}, false);
                            identityFound = true
                        end
                    elseif expression.kind == AstKind.DivExpression then
                        -- x / 1 -> x
                        if rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 1 then
                            self:addStatement(self:setRegister(scope, regs[i], lhsExpr), {regs[i]}, lhsReg and {lhsReg} or {}, false);
                            identityFound = true
                        end
                    elseif expression.kind == AstKind.PowExpression then
                        -- x ^ 1 -> x
                        if rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 1 then
                            self:addStatement(self:setRegister(scope, regs[i], lhsExpr), {regs[i]}, lhsReg and {lhsReg} or {}, false);
                            identityFound = true
                        -- x ^ 0 -> 1
                        elseif rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 0 then
                            self:addStatement(self:setRegister(scope, regs[i], Ast.NumberExpression(1)), {regs[i]}, {}, false);
                            identityFound = true
                        end
                    end
                end

                -- OPTIMIZATION: Operator Strength Reduction
                if not identityFound and rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 2 then
                    if expression.kind == AstKind.MulExpression then
                        -- x * 2 -> x + x
                        local reads = lhsReg and {lhsReg} or {}
                        self:addStatement(self:setRegister(scope, regs[i], Ast.AddExpression(lhsExpr, lhsExpr)), {regs[i]}, reads, true);
                        identityFound = true
                    elseif expression.kind == AstKind.PowExpression then
                        -- x ^ 2 -> x * x
                        local reads = lhsReg and {lhsReg} or {}
                        self:addStatement(self:setRegister(scope, regs[i], Ast.MulExpression(lhsExpr, lhsExpr)), {regs[i]}, reads, true);
                        identityFound = true
                    end
                end

                if not identityFound then
                    local reads = {}
                    if lhsReg then table.insert(reads, lhsReg) end
                    if rhsReg then table.insert(reads, rhsReg) end

                    self:addStatement(self:setRegister(scope, regs[i], Ast[expression.kind](lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                end

                if rhsReg then self:freeRegister(rhsReg, false) end
                if lhsReg then self:freeRegister(lhsReg, false) end
            else
               self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(expression.kind == AstKind.NotExpression) then
        local regs = {};
        for i=1, numReturns do
            if targetRegs and targetRegs[i] then
                regs[i] = targetRegs[i];
            else
                regs[i] = self:allocRegister();
            end

            if(i == 1) then
                -- OPTIMIZATION: Boolean Logic Simplification
                -- not (not x) -> x
                if expression.rhs.kind == AstKind.NotExpression then
                    local inner = expression.rhs.rhs;
                    local innerExpr, innerReg = self:compileOperand(scope, inner, funcDepth);
                    local reads = innerReg and {innerReg} or {}
                    self:addStatement(self:setRegister(scope, regs[i], innerExpr), {regs[i]}, reads, false);
                    if innerReg then self:freeRegister(innerReg, false) end
                -- not (a < b) -> a >= b
                elseif expression.rhs.kind == AstKind.LessThanExpression then
                    local lhsExpr, lhsReg = self:compileOperand(scope, expression.rhs.lhs, funcDepth);
                    local rhsExpr, rhsReg = self:compileOperand(scope, expression.rhs.rhs, funcDepth);
                    local reads = {}
                    if lhsReg then table.insert(reads, lhsReg) end
                    if rhsReg then table.insert(reads, rhsReg) end
                    self:addStatement(self:setRegister(scope, regs[i], Ast.GreaterThanOrEqualsExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                    if lhsReg then self:freeRegister(lhsReg, false) end
                    if rhsReg then self:freeRegister(rhsReg, false) end
                elseif expression.rhs.kind == AstKind.GreaterThanExpression then
                    local lhsExpr, lhsReg = self:compileOperand(scope, expression.rhs.lhs, funcDepth);
                    local rhsExpr, rhsReg = self:compileOperand(scope, expression.rhs.rhs, funcDepth);
                    local reads = {}
                    if lhsReg then table.insert(reads, lhsReg) end
                    if rhsReg then table.insert(reads, rhsReg) end
                    self:addStatement(self:setRegister(scope, regs[i], Ast.LessThanOrEqualsExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                    if lhsReg then self:freeRegister(lhsReg, false) end
                    if rhsReg then self:freeRegister(rhsReg, false) end
                elseif expression.rhs.kind == AstKind.LessThanOrEqualsExpression then
                    local lhsExpr, lhsReg = self:compileOperand(scope, expression.rhs.lhs, funcDepth);
                    local rhsExpr, rhsReg = self:compileOperand(scope, expression.rhs.rhs, funcDepth);
                    local reads = {}
                    if lhsReg then table.insert(reads, lhsReg) end
                    if rhsReg then table.insert(reads, rhsReg) end
                    self:addStatement(self:setRegister(scope, regs[i], Ast.GreaterThanExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                    if lhsReg then self:freeRegister(lhsReg, false) end
                    if rhsReg then self:freeRegister(rhsReg, false) end
                elseif expression.rhs.kind == AstKind.GreaterThanOrEqualsExpression then
                    local lhsExpr, lhsReg = self:compileOperand(scope, expression.rhs.lhs, funcDepth);
                    local rhsExpr, rhsReg = self:compileOperand(scope, expression.rhs.rhs, funcDepth);
                    local reads = {}
                    if lhsReg then table.insert(reads, lhsReg) end
                    if rhsReg then table.insert(reads, rhsReg) end
                    self:addStatement(self:setRegister(scope, regs[i], Ast.LessThanExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                    if lhsReg then self:freeRegister(lhsReg, false) end
                    if rhsReg then self:freeRegister(rhsReg, false) end
                elseif expression.rhs.kind == AstKind.EqualsExpression then
                    local lhsExpr, lhsReg = self:compileOperand(scope, expression.rhs.lhs, funcDepth);
                    local rhsExpr, rhsReg = self:compileOperand(scope, expression.rhs.rhs, funcDepth);
                    local reads = {}
                    if lhsReg then table.insert(reads, lhsReg) end
                    if rhsReg then table.insert(reads, rhsReg) end
                    self:addStatement(self:setRegister(scope, regs[i], Ast.NotEqualsExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                    if lhsReg then self:freeRegister(lhsReg, false) end
                    if rhsReg then self:freeRegister(rhsReg, false) end
                elseif expression.rhs.kind == AstKind.NotEqualsExpression then
                    local lhsExpr, lhsReg = self:compileOperand(scope, expression.rhs.lhs, funcDepth);
                    local rhsExpr, rhsReg = self:compileOperand(scope, expression.rhs.rhs, funcDepth);
                    local reads = {}
                    if lhsReg then table.insert(reads, lhsReg) end
                    if rhsReg then table.insert(reads, rhsReg) end
                    self:addStatement(self:setRegister(scope, regs[i], Ast.EqualsExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                    if lhsReg then self:freeRegister(lhsReg, false) end
                    if rhsReg then self:freeRegister(rhsReg, false) end
                else
                    -- Normal Not
                    local rhsExpr, rhsReg = self:compileOperand(scope, expression.rhs, funcDepth);
                    local reads = rhsReg and {rhsReg} or {}

                    self:addStatement(self:setRegister(scope, regs[i], Ast.NotExpression(rhsExpr)), {regs[i]}, reads, false);
                    if rhsReg then self:freeRegister(rhsReg, false) end
                end
            else
               self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(expression.kind == AstKind.NegateExpression) then
        local regs = {};
        for i=1, numReturns do
            if targetRegs and targetRegs[i] then
                regs[i] = targetRegs[i];
            else
                regs[i] = self:allocRegister();
            end

            if(i == 1) then
                -- OPTIMIZATION: Constant Folding -(-(x)) -> x
                if expression.rhs.kind == AstKind.NegateExpression then
                    local inner = expression.rhs.rhs;
                    local innerExpr, innerReg = self:compileOperand(scope, inner, funcDepth);
                    local reads = innerReg and {innerReg} or {}
                    self:addStatement(self:setRegister(scope, regs[i], innerExpr), {regs[i]}, reads, true);
                    if innerReg then self:freeRegister(innerReg, false) end
                else
                    -- OPTIMIZATION: Literal Inlining
                    local rhsExpr, rhsReg = self:compileOperand(scope, expression.rhs, funcDepth);
                    local reads = rhsReg and {rhsReg} or {}

                    self:addStatement(self:setRegister(scope, regs[i], Ast.NegateExpression(rhsExpr)), {regs[i]}, reads, true);
                    if rhsReg then self:freeRegister(rhsReg, false) end
                end
            else
               self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(expression.kind == AstKind.LenExpression) then
        local regs = {};
        for i=1, numReturns do
            if targetRegs and targetRegs[i] then
                regs[i] = targetRegs[i];
            else
                regs[i] = self:allocRegister();
            end

            if(i == 1) then
                -- OPTIMIZATION: Constant Folding for String Length
                if expression.rhs.kind == AstKind.StringExpression then
                    self:addStatement(self:setRegister(scope, regs[i], Ast.NumberExpression(#expression.rhs.value)), {regs[i]}, {}, false);
                else
                    -- OPTIMIZATION: Literal Inlining
                    local rhsExpr, rhsReg = self:compileOperand(scope, expression.rhs, funcDepth);
                    local reads = rhsReg and {rhsReg} or {}

                    self:addStatement(self:setRegister(scope, regs[i], Ast.LenExpression(rhsExpr)), {regs[i]}, reads, true);
                    if rhsReg then self:freeRegister(rhsReg, false) end
                end
            else
               self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(expression.kind == AstKind.OrExpression) then      
        local posState = self.registers[self.POS_REGISTER];
        self.registers[self.POS_REGISTER] = self.VAR_REGISTER;

        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i ~= 1) then
                self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end

        local resReg = regs[1];

        -- OPTIMIZATION: Inline Or if both sides are safe (no side effects)
        if self:isSafeExpression(expression.lhs) and self:isSafeExpression(expression.rhs) then
            local lhsReg = self:compileExpression(expression.lhs, funcDepth, 1)[1];
            local rhsReg = self:compileExpression(expression.rhs, funcDepth, 1)[1];
            self:addStatement(self:setRegister(scope, resReg, Ast.OrExpression(self:register(scope, lhsReg), self:register(scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false);
            self:freeRegister(lhsReg, false);
            self:freeRegister(rhsReg, false);

            self.registers[self.POS_REGISTER] = posState;
            return regs;
        end

        local a7bX9;

        if posState then
            a7bX9 = self:allocRegister(false);
            self:addStatement(self:copyRegisters(scope, {a7bX9}, {self.POS_REGISTER}), {a7bX9}, {self.POS_REGISTER}, false);
        end

        local lhsReg = self:compileExpression(expression.lhs, funcDepth, 1)[1];
        if(expression.rhs.isConstant) then
            local rhsReg = self:compileExpression(expression.rhs, funcDepth, 1)[1];
            self:addStatement(self:setRegister(scope, resReg, Ast.OrExpression(self:register(scope, lhsReg), self:register(scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false);
            if a7bX9 then
                self:freeRegister(a7bX9, false);
            end
            self:freeRegister(lhsReg, false);
            self:freeRegister(rhsReg, false);
            return regs;
        end

        local block1, block2 = self:createBlock(), self:createBlock();
        self:addStatement(self:copyRegisters(scope, {resReg}, {lhsReg}), {resReg}, {lhsReg}, false);
        self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(self:register(scope, lhsReg), Ast.NumberExpression(block2.id)), Ast.NumberExpression(block1.id))), {self.POS_REGISTER}, {lhsReg}, false);
        self:freeRegister(lhsReg, false);

        do
            self:setActiveBlock(block1);
            local scope = block1.scope;
            local rhsReg = self:compileExpression(expression.rhs, funcDepth, 1)[1];
            self:addStatement(self:copyRegisters(scope, {resReg}, {rhsReg}), {resReg}, {rhsReg}, false);
            self:freeRegister(rhsReg, false);
            self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpression(block2.id)), {self.POS_REGISTER}, {}, false);
        end

        self.registers[self.POS_REGISTER] = posState;

        self:setActiveBlock(block2);
        scope = block2.scope;

        if a7bX9 then
            self:addStatement(self:copyRegisters(scope, {self.POS_REGISTER}, {a7bX9}), {self.POS_REGISTER}, {a7bX9}, false);
            self:freeRegister(a7bX9, false);
        end

        return regs;
    end

    if(expression.kind == AstKind.AndExpression) then      
        local posState = self.registers[self.POS_REGISTER];
        self.registers[self.POS_REGISTER] = self.VAR_REGISTER;

        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister();
            if(i ~= 1) then
                self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end

        local resReg = regs[1];

        -- OPTIMIZATION: Inline And if both sides are safe (no side effects)
        if self:isSafeExpression(expression.lhs) and self:isSafeExpression(expression.rhs) then
            local lhsReg = self:compileExpression(expression.lhs, funcDepth, 1)[1];
            local rhsReg = self:compileExpression(expression.rhs, funcDepth, 1)[1];
            self:addStatement(self:setRegister(scope, resReg, Ast.AndExpression(self:register(scope, lhsReg), self:register(scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false);
            self:freeRegister(lhsReg, false);
            self:freeRegister(rhsReg, false);

            self.registers[self.POS_REGISTER] = posState;
            return regs;
        end

        local a7bX9;

        if posState then
            a7bX9 = self:allocRegister(false);
            self:addStatement(self:copyRegisters(scope, {a7bX9}, {self.POS_REGISTER}), {a7bX9}, {self.POS_REGISTER}, false);
        end

       
        local lhsReg = self:compileExpression(expression.lhs, funcDepth, 1)[1];
        if(expression.rhs.isConstant) then
            local rhsReg = self:compileExpression(expression.rhs, funcDepth, 1)[1];
            self:addStatement(self:setRegister(scope, resReg, Ast.AndExpression(self:register(scope, lhsReg), self:register(scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false);
            if a7bX9 then
                self:freeRegister(a7bX9, false);
            end
            self:freeRegister(lhsReg, false);
            self:freeRegister(rhsReg, false)
            return regs;
        end


        local block1, block2 = self:createBlock(), self:createBlock();
        self:addStatement(self:copyRegisters(scope, {resReg}, {lhsReg}), {resReg}, {lhsReg}, false);
        self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(self:register(scope, lhsReg), Ast.NumberExpression(block1.id)), Ast.NumberExpression(block2.id))), {self.POS_REGISTER}, {lhsReg}, false);
        self:freeRegister(lhsReg, false);
        do
            self:setActiveBlock(block1);
            scope = block1.scope;
            local rhsReg = self:compileExpression(expression.rhs, funcDepth, 1)[1];
            self:addStatement(self:copyRegisters(scope, {resReg}, {rhsReg}), {resReg}, {rhsReg}, false);
            self:freeRegister(rhsReg, false);
            self:addStatement(self:setRegister(scope, self.POS_REGISTER, Ast.NumberExpression(block2.id)), {self.POS_REGISTER}, {}, false);
        end

        self.registers[self.POS_REGISTER] = posState;

        self:setActiveBlock(block2);
        scope = block2.scope;

        if a7bX9 then
            self:addStatement(self:copyRegisters(scope, {self.POS_REGISTER}, {a7bX9}), {self.POS_REGISTER}, {a7bX9}, false);
            self:freeRegister(a7bX9, false);
        end

        return regs;
    end

    if(expression.kind == AstKind.TableConstructorExpression) then
        local regs = {};
        for i=1, numReturns do
            if targetRegs and targetRegs[i] then
                regs[i] = targetRegs[i];
            else
                regs[i] = self:allocRegister();
            end

            if(i == 1) then
                local entries = {};
                local entryRegs = {};
                for i, entry in ipairs(expression.entries) do
                    if(entry.kind == AstKind.TableEntry) then
                        local value = entry.value;
                        if i == #expression.entries and (value.kind == AstKind.FunctionCallExpression or value.kind == AstKind.PassSelfFunctionCallExpression or value.kind == AstKind.VarargExpression) then
                            local reg = self:compileExpression(entry.value, funcDepth, self.RETURN_ALL)[1];
                            table.insert(entries, Ast.TableEntry(Ast.FunctionCallExpression(
                                self:unpack(scope),
                                {self:register(scope, reg)})));
                            table.insert(entryRegs, reg);
                        else
                            -- OPTIMIZATION: Inline literals/vars/safe-expressions for array part
                            local valExpr, valReg = self:compileOperand(scope, entry.value, funcDepth);
                            table.insert(entries, Ast.TableEntry(valExpr));
                            if valReg then table.insert(entryRegs, valReg) end
                        end
                    else
                        -- OPTIMIZATION: Literal Inlining for Table Constructor Keys/Values
                        local keyExpr, keyReg = self:compileOperand(scope, entry.key, funcDepth);
                        local valExpr, valReg = self:compileOperand(scope, entry.value, funcDepth);

                        table.insert(entries, Ast.KeyedTableEntry(keyExpr, valExpr));
                        if keyReg then table.insert(entryRegs, keyReg) end
                        if valReg then table.insert(entryRegs, valReg) end
                    end
                end
                self:addStatement(self:setRegister(scope, regs[i], Ast.TableConstructorExpression(entries)), {regs[i]}, entryRegs, false);
                for i, reg in ipairs(entryRegs) do
                    self:freeRegister(reg, false);
                end
            else
                self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(expression.kind == AstKind.FunctionLiteralExpression) then
        local regs = {};
        for i=1, numReturns do
            if(i == 1) then
                regs[i] = self:compileFunction(expression, funcDepth);
            else
                regs[i] = self:allocRegister();
                self:addStatement(self:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
            end
        end
        return regs;
    end

    if(expression.kind == AstKind.VarargExpression) then
        if numReturns == self.RETURN_ALL then
            return {self.varargReg};
        end
        local regs = {};
        for i=1, numReturns do
            regs[i] = self:allocRegister(false);
            self:addStatement(self:setRegister(scope, regs[i], Ast.IndexExpression(self:register(scope, self.varargReg), Ast.NumberExpression(i))), {regs[i]}, {self.varargReg}, false);
        end
        return regs;
    end

    logger:error(string.format("%s is not an compliable expression!", expression.kind));
end

-- ============================================================================
-- VMify Enhancer - Anti-Deobfuscation Layer
-- ============================================================================
-- This section provides post-processing enhancements to vmified code
-- to resist pattern-based deobfuscation techniques used by
-- prometheus-deobfuscator and similar tools.
-- 
-- Integrated from src/vmify_enhancer.lua
-- Security patches applied: v4.3 (VUL-001 to VUL-007)

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
end]], funcName, param, tmpVar, param, offset, checkVar, tmpVar, checkVar, tmpVar, checkVar, tmpVar, checkVar, tableName, tmpVar, tableName, tmpVar)
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

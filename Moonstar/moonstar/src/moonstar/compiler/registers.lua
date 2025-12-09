-- registers.lua
-- Register allocation and management logic for the compiler

local Ast = require("moonstar.ast");
local Scope = require("moonstar.scope");
local AstKind = Ast.AstKind;

local Registers = {}

-- Free a register for reuse
function Registers.freeRegister(compiler, id, force)
    if compiler.constantRegs[id] then return end -- Never free constant registers

    -- Fix: Ensure we don't try to free special registers (userdata) into the free list
    -- freeRegisters should only contain numeric IDs
    if type(id) ~= "number" then
        -- If it's a userdata register (POS, RETURN, VAR), we just mark it free in compiler.registers if appropriate
        if force or not (compiler.registers[id] == compiler.VAR_REGISTER) then
             compiler.usedRegisters = compiler.usedRegisters - 1;
             compiler.registers[id] = false
        end
        return
    end

    if force or not (compiler.registers[id] == compiler.VAR_REGISTER) then
        compiler.usedRegisters = compiler.usedRegisters - 1;
        compiler.registers[id] = false
        table.insert(compiler.freeRegisters, id) -- Push to free list
    end
end

-- Check if a register is used for a variable
function Registers.isVarRegister(compiler, id)
    return compiler.registers[id] == compiler.VAR_REGISTER;
end

-- Allocate a new register
function Registers.allocRegister(compiler, isVar, forceNumeric)
    compiler.usedRegisters = compiler.usedRegisters + 1;

    if not isVar and not forceNumeric then
        -- POS register can be temporarily used
        if not compiler.registers[compiler.POS_REGISTER] then
            compiler.registers[compiler.POS_REGISTER] = true;
            return compiler.POS_REGISTER;
        end

        -- RETURN register can be temporarily used
        if not compiler.registers[compiler.RETURN_REGISTER] then
            compiler.registers[compiler.RETURN_REGISTER] = true;
            return compiler.RETURN_REGISTER;
        end
    end
    
    local id;
    -- OPTIMIZATION: Free List (Stack) Allocation
    -- Try to reuse recently freed registers for better cache locality
    while #compiler.freeRegisters > 0 do
        local candidate = table.remove(compiler.freeRegisters);
        if not compiler.registers[candidate] then
            id = candidate;
            break;
        end
        -- If register became occupied (e.g. by VAR assignment), discard and try next
    end

    if not id then
        -- OPTIMIZATION: Linear Scan Allocation (Fallback)
        -- SECURITY: Randomize starting offset when enabled to prevent pattern matching
        if compiler.enableInstructionRandomization then
            id = math.random(1, 15)
        else
            id = 1
        end
        while compiler.registers[id] do
            id = id + 1;
        end
    end

    if id > compiler.maxUsedRegister then
        compiler.maxUsedRegister = id;
    end

    if(isVar) then
        compiler.registers[id] = compiler.VAR_REGISTER;
    else
        compiler.registers[id] = true
    end
    return id;
end

-- Get or create a register for a variable
function Registers.getVarRegister(compiler, scope, id, functionDepth, potentialId)
    if(not compiler.registersForVar[scope]) then
        compiler.registersForVar[scope] = {};
        compiler.scopeFunctionDepths[scope] = functionDepth;
    end

    local reg = compiler.registersForVar[scope][id];
    if not reg then
        if potentialId and compiler.registers[potentialId] ~= compiler.VAR_REGISTER and potentialId ~= compiler.POS_REGISTER and potentialId ~= compiler.RETURN_REGISTER then
            compiler.registers[potentialId] = compiler.VAR_REGISTER;
            reg = potentialId;
        else
            reg = Registers.allocRegister(compiler, true);
        end
        compiler.registersForVar[scope][id] = reg;
    end
    return reg;
end

-- Get the variable ID for a register
function Registers.getRegisterVarId(compiler, id)
    local varId = compiler.registerVars[id];
    if not varId then
        varId = compiler.containerFuncScope:addVariable();
        compiler.registerVars[id] = varId;
    end
    return varId;
end

-- P4: Get or create a spill variable ID (for registers MAX_REGS to MAX_REGS + SPILL_REGS - 1)
function Registers.getSpillVarId(compiler, spillIndex)
    local spillVar = compiler.spillVars[spillIndex]
    if not spillVar then
        spillVar = compiler.containerFuncScope:addVariable()
        compiler.spillVars[spillIndex] = spillVar
    end
    return spillVar
end

-- Check if an expression is safe (no side effects)
function Registers.isSafeExpression(compiler, expr)
    if not expr then return true end
    if expr.kind == AstKind.NumberExpression or
       expr.kind == AstKind.StringExpression or
       expr.kind == AstKind.BooleanExpression or
       expr.kind == AstKind.NilExpression or
       expr.kind == AstKind.VariableExpression then
        return true
    end

    if expr.kind == AstKind.BinaryExpression or compiler.BIN_OPS[expr.kind] then
        return Registers.isSafeExpression(compiler, expr.lhs) and Registers.isSafeExpression(compiler, expr.rhs)
    end

    if expr.kind == AstKind.NotExpression or expr.kind == AstKind.NegateExpression or expr.kind == AstKind.LenExpression then
        return Registers.isSafeExpression(compiler, expr.rhs)
    end

    if expr.kind == AstKind.AndExpression or expr.kind == AstKind.OrExpression then
         return Registers.isSafeExpression(compiler, expr.lhs) and Registers.isSafeExpression(compiler, expr.rhs)
    end

    return false
end

-- Check if an expression is a literal
function Registers.isLiteral(compiler, expr)
    if not expr then return false end
    return expr.kind == AstKind.NumberExpression or
           expr.kind == AstKind.StringExpression or
           expr.kind == AstKind.BooleanExpression or
           expr.kind == AstKind.NilExpression
end

-- Compile an operand (literal or expression to register)
function Registers.compileOperand(compiler, scope, expr, funcDepth)
    if Registers.isLiteral(compiler, expr) then
        -- OPTIMIZATION: Shared Constant Pool
        -- Check if this literal is in our constant pool
        if (expr.kind == AstKind.StringExpression or expr.kind == AstKind.NumberExpression) and compiler.constants[expr.value] then
            local reg = compiler.constants[expr.value]
            return Registers.register(compiler, scope, reg), reg
        end

        -- Return the AST node directly (no register allocation)
        return expr, nil
    end

    -- Otherwise compile to a register
    local reg = compiler:compileExpression(expr, funcDepth, 1)[1]
    return Registers.register(compiler, scope, reg), reg
end

-- Convert a register ID to an AST expression
function Registers.register(compiler, scope, id)
    local MAX_REGS = compiler.MAX_REGS;
    local SPILL_REGS = compiler.SPILL_REGS;
    
    if id == compiler.POS_REGISTER then
        return Registers.pos(compiler, scope);
    end

    if id == compiler.RETURN_REGISTER then
        return Registers.getReturn(compiler, scope);
    end

    if id < MAX_REGS then
        -- Normal register: use local variable
        local vid = Registers.getRegisterVarId(compiler, id);
        scope:addReferenceToHigherScope(compiler.containerFuncScope, vid);
        return Ast.VariableExpression(compiler.containerFuncScope, vid);
    end

    -- P4: Spill register optimization
    -- Registers MAX_REGS to MAX_REGS + SPILL_REGS - 1 use dedicated local variables
    local spillIndex = id - MAX_REGS  -- 0-based index into spill registers
    if spillIndex < SPILL_REGS then
        -- Use spill local variable (faster than table indexing)
        local spillVar = Registers.getSpillVarId(compiler, spillIndex)
        scope:addReferenceToHigherScope(compiler.containerFuncScope, spillVar)
        return Ast.VariableExpression(compiler.containerFuncScope, spillVar)
    end

    -- Table fallback for registers beyond spill range (MAX_REGS + SPILL_REGS and above)
    local vid = Registers.getRegisterVarId(compiler, MAX_REGS);
    scope:addReferenceToHigherScope(compiler.containerFuncScope, vid);
    local tableIndex = id - MAX_REGS - SPILL_REGS + 1  -- 1-based index into overflow table
    return Ast.IndexExpression(Ast.VariableExpression(compiler.containerFuncScope, vid), Ast.NumberExpression(tableIndex));
end

-- Convert multiple register IDs to AST expressions
function Registers.registerList(compiler, scope, ids)
    local l = {};
    for i, id in ipairs(ids) do
        table.insert(l, Registers.register(compiler, scope, id));
    end
    return l;
end

-- Create an assignment target for a register
function Registers.registerAssignment(compiler, scope, id)
    local MAX_REGS = compiler.MAX_REGS;
    local SPILL_REGS = compiler.SPILL_REGS;
    
    if id == compiler.POS_REGISTER then
        return Registers.posAssignment(compiler, scope);
    end
    if id == compiler.RETURN_REGISTER then
        return Registers.returnAssignment(compiler, scope);
    end

    if id < MAX_REGS then
        -- Normal register: use local variable
        local vid = Registers.getRegisterVarId(compiler, id);
        scope:addReferenceToHigherScope(compiler.containerFuncScope, vid);
        return Ast.AssignmentVariable(compiler.containerFuncScope, vid);
    end

    -- P4: Spill register optimization
    -- Registers MAX_REGS to MAX_REGS + SPILL_REGS - 1 use dedicated local variables
    local spillIndex = id - MAX_REGS  -- 0-based index into spill registers
    if spillIndex < SPILL_REGS then
        -- Use spill local variable (faster than table indexing)
        local spillVar = Registers.getSpillVarId(compiler, spillIndex)
        scope:addReferenceToHigherScope(compiler.containerFuncScope, spillVar)
        return Ast.AssignmentVariable(compiler.containerFuncScope, spillVar)
    end

    -- Table fallback for registers beyond spill range (MAX_REGS + SPILL_REGS and above)
    local vid = Registers.getRegisterVarId(compiler, MAX_REGS);
    scope:addReferenceToHigherScope(compiler.containerFuncScope, vid);
    local tableIndex = id - MAX_REGS - SPILL_REGS + 1  -- 1-based index into overflow table
    return Ast.AssignmentIndexing(Ast.VariableExpression(compiler.containerFuncScope, vid), Ast.NumberExpression(tableIndex));
end

-- Set a register to a value
function Registers.setRegister(compiler, scope, id, val, compoundArg)
    if(compoundArg) then
        return compoundArg(Registers.registerAssignment(compiler, scope, id), val);
    end
    return Ast.AssignmentStatement({
        Registers.registerAssignment(compiler, scope, id)
    }, {
        val
    });
end

-- Set multiple registers
function Registers.setRegisters(compiler, scope, ids, vals)
    local idStats = {};
    for i, id in ipairs(ids) do
        table.insert(idStats, Registers.registerAssignment(compiler, scope, id));
    end

    return Ast.AssignmentStatement(idStats, vals);
end

-- Copy registers
function Registers.copyRegisters(compiler, scope, to, from)
    local idStats = {};
    local vals    = {};
    for i, id in ipairs(to) do
        local fromReg = from[i];
        if(fromReg ~= id) then
            table.insert(idStats, Registers.registerAssignment(compiler, scope, id));
            table.insert(vals, Registers.register(compiler, scope, fromReg));
        end
    end

    if(#idStats > 0 and #vals > 0) then
        return Ast.AssignmentStatement(idStats, vals);
    end
end

-- Reset all registers
function Registers.resetRegisters(compiler)
    compiler.registers = {};
    compiler.freeRegisters = {};
    compiler.constants = {};
    compiler.constantRegs = {};
end

-- Get position variable expression
function Registers.pos(compiler, scope)
    scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.posVar);
    return Ast.VariableExpression(compiler.containerFuncScope, compiler.posVar);
end

-- Get position assignment target
function Registers.posAssignment(compiler, scope)
    scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.posVar);
    return Ast.AssignmentVariable(compiler.containerFuncScope, compiler.posVar);
end

-- Get args variable expression
function Registers.args(compiler, scope)
    scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.argsVar);
    return Ast.VariableExpression(compiler.containerFuncScope, compiler.argsVar);
end

-- Get unpack function expression
function Registers.unpack(compiler, scope)
    scope:addReferenceToHigherScope(compiler.scope, compiler.unpackVar);
    return Ast.VariableExpression(compiler.scope, compiler.unpackVar);
end

-- Get environment variable expression
function Registers.env(compiler, scope)
    scope:addReferenceToHigherScope(compiler.scope, compiler.envVar);
    return Ast.VariableExpression(compiler.scope, compiler.envVar);
end

-- Set position to a jump target
function Registers.jmp(compiler, scope, to)
    scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.posVar);
    return Ast.AssignmentStatement({Ast.AssignmentVariable(compiler.containerFuncScope, compiler.posVar)},{to});
end

-- Set position to a value (or nil-like for termination)
-- SECURITY: Exit polymorphism + jump target encoding
function Registers.setPos(compiler, scope, val)
    local randomStrings = require("moonstar.randomStrings")
    
    scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.posVar)
    
    if not val then
        -- EXIT POLYMORPHISM: Multiple exit patterns to prevent signature matching
        local exitStyle = math.random(1, 4)
        local v
        if exitStyle == 1 then
            -- Original: _ENV["randomString"] (undefined = nil)
            v = Ast.IndexExpression(Registers.env(compiler, scope), randomStrings.randomStringNode(math.random(12, 14)))
        elseif exitStyle == 2 then
            -- Direct nil
            v = Ast.NilExpression()
        elseif exitStyle == 3 then
            -- Boolean false (falsy, exits while loop)
            v = Ast.BooleanExpression(false)
        else
            -- Negative number (used as invalid block ID)
            v = Ast.NumberExpression(-math.random(1, 100000))
        end
        return Ast.AssignmentStatement({Ast.AssignmentVariable(compiler.containerFuncScope, compiler.posVar)}, {v})
    end
    
    -- JUMP TARGET ENCODING: Obfuscate block IDs with arithmetic
    local targetExpr
    if compiler.enableInstructionRandomization and math.random() > 0.3 then
        local offset = math.random(-500, 500)
        local mult = math.random(2, 5)
        -- Encode: val = (encoded - offset) / mult  =>  encoded = val * mult + offset
        local encoded = val * mult + offset
        targetExpr = Ast.DivExpression(
            Ast.SubExpression(Ast.NumberExpression(encoded), Ast.NumberExpression(offset)),
            Ast.NumberExpression(mult)
        )
    else
        targetExpr = Ast.NumberExpression(val)
    end
    
    return Ast.AssignmentStatement({Ast.AssignmentVariable(compiler.containerFuncScope, compiler.posVar)}, {targetExpr})
end

-- Set return value
function Registers.setReturn(compiler, scope, val)
    scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.returnVar);
    return Ast.AssignmentStatement({Ast.AssignmentVariable(compiler.containerFuncScope, compiler.returnVar)}, {val});
end

-- Get return value expression
function Registers.getReturn(compiler, scope)
    scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.returnVar);
    return Ast.VariableExpression(compiler.containerFuncScope, compiler.returnVar);
end

-- Get return assignment target
function Registers.returnAssignment(compiler, scope)
    scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.returnVar);
    return Ast.AssignmentVariable(compiler.containerFuncScope, compiler.returnVar);
end

-- Push register usage info onto stack (for nested functions)
function Registers.pushRegisterUsageInfo(compiler)
    table.insert(compiler.registerUsageStack, {
        usedRegisters = compiler.usedRegisters;
        registers = compiler.registers;
        freeRegisters = compiler.freeRegisters;
        constants = compiler.constants;
        constantRegs = compiler.constantRegs;
    });
    compiler.usedRegisters = 0;
    compiler.registers = {};
    compiler.freeRegisters = {};
    compiler.constants = {};
    compiler.constantRegs = {};
end

-- Pop register usage info from stack
function Registers.popRegisterUsageInfo(compiler)
    local info = table.remove(compiler.registerUsageStack);
    compiler.usedRegisters = info.usedRegisters;
    compiler.registers = info.registers;
    compiler.freeRegisters = info.freeRegisters;
    compiler.constants = info.constants;
    compiler.constantRegs = info.constantRegs;
end

return Registers

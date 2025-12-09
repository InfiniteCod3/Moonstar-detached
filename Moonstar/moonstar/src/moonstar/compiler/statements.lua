local Ast = require("moonstar.ast");
local AstKind = Ast.AstKind;
local logger = require("logger");
local util = require("moonstar.util");

local unpack = unpack or table.unpack;

local isComparisonOp = {
    [AstKind.LessThanExpression] = true,
    [AstKind.GreaterThanExpression] = true,
    [AstKind.LessThanOrEqualsExpression] = true,
    [AstKind.GreaterThanOrEqualsExpression] = true,
    [AstKind.NotEqualsExpression] = true,
    [AstKind.EqualsExpression] = true,
}

local function emitConditionalJump(compiler, condition, trueBlock, falseBlock, funcDepth)
    local scope = compiler.activeBlock.scope

    if isComparisonOp[condition.kind] then
        -- Fused instruction path: Directly use the comparison in the jump logic
        -- This avoids creating an intermediate register for the boolean result.
        local lhsExpr, lhsReg = compiler:compileOperand(scope, condition.lhs, funcDepth)
        local rhsExpr, rhsReg = compiler:compileOperand(scope, condition.rhs, funcDepth)

        local reads = {}
        if lhsReg then table.insert(reads, lhsReg) end
        if rhsReg then table.insert(reads, rhsReg) end

        local fusedCondition = Ast[condition.kind](lhsExpr, rhsExpr)

        compiler:addStatement(
            compiler:setRegister(scope, compiler.POS_REGISTER, Ast.OrExpression(
                Ast.AndExpression(fusedCondition, Ast.NumberExpression(trueBlock.id)),
                Ast.NumberExpression(falseBlock.id)
            )),
            {compiler.POS_REGISTER},
            reads,
            true -- can use upvalues if lhs/rhs are upvalues
        );

        if lhsReg then compiler:freeRegister(lhsReg, false) end
        if rhsReg then compiler:freeRegister(rhsReg, false) end
    else
        -- Original path for complex conditions (e.g. with 'and'/'or' or function calls)
        local conditionReg = compiler:compileExpression(condition, funcDepth, 1)[1];
        compiler:addStatement(compiler:setRegister(scope, compiler.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(compiler:register(scope, conditionReg), Ast.NumberExpression(trueBlock.id)), Ast.NumberExpression(falseBlock.id))), {compiler.POS_REGISTER}, {conditionReg}, false);
        compiler:freeRegister(conditionReg, false);
    end
end

-- P6: Loop Unrolling helper functions
-- Check if an expression is a compile-time constant number
local function isConstantNumber(expr)
    if expr.kind == AstKind.NumberExpression then
        return true, expr.value
    elseif expr.kind == AstKind.NegateExpression and expr.expression.kind == AstKind.NumberExpression then
        return true, -expr.expression.value
    end
    return false, nil
end

-- Check if a block contains break, return, continue, or goto statements
-- These would prevent loop unrolling
local function containsLoopControl(node)
    if not node then return false end
    
    local kind = node.kind
    if kind == AstKind.BreakStatement or 
       kind == AstKind.ContinueStatement or 
       kind == AstKind.ReturnStatement then
        return true
    end
    
    -- Recursively check blocks
    if kind == AstKind.Block then
        for _, stat in ipairs(node.statements) do
            if containsLoopControl(stat) then
                return true
            end
        end
    elseif kind == AstKind.IfStatement then
        if containsLoopControl(node.body) then return true end
        for _, eif in ipairs(node.elseifs or {}) do
            if containsLoopControl(eif.body) then return true end
        end
        if containsLoopControl(node.elsebody) then return true end
    elseif kind == AstKind.DoStatement then
        if containsLoopControl(node.body) then return true end
    -- Don't recurse into nested loops - they have their own break/continue targets
    elseif kind == AstKind.WhileStatement or 
           kind == AstKind.RepeatStatement or 
           kind == AstKind.ForStatement or 
           kind == AstKind.ForInStatement then
        return false  -- Nested loop has its own control flow
    end
    
    return false
end

local Statements = {}

function Statements.ReturnStatement(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    local entries = {};
    local regs = {};

    -- P7: Tail Call Optimization
    -- If returning a single function call, emit a proper tail call
    if compiler.enableTailCallOptimization and #statement.args == 1 then
        local arg = statement.args[1]
        if arg.kind == AstKind.FunctionCallExpression or arg.kind == AstKind.PassSelfFunctionCallExpression then
            -- Compile the function call as a tail call
            -- We need to build the function call and return it directly
            local baseReg = compiler:compileExpression(arg.base, funcDepth, 1)[1]
            local callArgs = {}
            local callRegs = { baseReg }
            
            -- Handle self-calls
            if arg.kind == AstKind.PassSelfFunctionCallExpression then
                table.insert(callArgs, compiler:register(scope, baseReg))
            end
            
            -- Compile arguments
            for i, expr in ipairs(arg.args) do
                if i == #arg.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
                    local reg = compiler:compileExpression(expr, funcDepth, compiler.RETURN_ALL)[1]
                    table.insert(callArgs, Ast.FunctionCallExpression(
                        compiler:unpack(scope),
                        {compiler:register(scope, reg)}))
                    table.insert(callRegs, reg)
                else
                    local argExpr, argReg = compiler:compileOperand(scope, expr, funcDepth)
                    table.insert(callArgs, argExpr)
                    if argReg then table.insert(callRegs, argReg) end
                end
            end
            
            -- Build the tail call expression
            local tailCallExpr
            if arg.kind == AstKind.PassSelfFunctionCallExpression then
                tailCallExpr = Ast.FunctionCallExpression(
                    Ast.IndexExpression(compiler:register(scope, baseReg), Ast.StringExpression(arg.passSelfFunctionName)),
                    callArgs
                )
            else
                tailCallExpr = Ast.FunctionCallExpression(
                    compiler:register(scope, baseReg),
                    callArgs
                )
            end
            
            -- Emit the return with the tail call
            compiler:addStatement(compiler:setReturn(scope, Ast.TableConstructorExpression({
                Ast.TableEntry(tailCallExpr)
            })), {compiler.RETURN_REGISTER}, callRegs, true)
            compiler:addStatement(compiler:setPos(scope, nil), {compiler.POS_REGISTER}, {}, false)
            compiler.activeBlock.advanceToNextBlock = false
            
            -- Free registers
            for _, reg in ipairs(callRegs) do
                compiler:freeRegister(reg, false)
            end
            
            return
        end
    end

    -- Original path for non-tail-call returns
    for i, expr in ipairs(statement.args) do
        if i == #statement.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
            local reg = compiler:compileExpression(expr, funcDepth, compiler.RETURN_ALL)[1];
            table.insert(entries, Ast.TableEntry(Ast.FunctionCallExpression(
                compiler:unpack(scope),
                {compiler:register(scope, reg)})));
            table.insert(regs, reg);
        else
            -- OPTIMIZATION: Inline literals/vars for return
            local retExpr, retReg = compiler:compileOperand(scope, expr, funcDepth);
            table.insert(entries, Ast.TableEntry(retExpr));
            if retReg then table.insert(regs, retReg) end
        end
    end

    for _, reg in ipairs(regs) do
        compiler:freeRegister(reg, false);
    end

    compiler:addStatement(compiler:setReturn(scope, Ast.TableConstructorExpression(entries)), {compiler.RETURN_REGISTER}, regs, false);
    compiler:addStatement(compiler:setPos(compiler.activeBlock.scope, nil), {compiler.POS_REGISTER}, {}, false);
    compiler.activeBlock.advanceToNextBlock = false;
end

function Statements.LocalVariableDeclaration(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    local exprregs = {};
    local targetRegs = {}; -- Map index -> target register ID

    -- Pre-allocate registers for simple local variables to optimize assignment
    for i, id in ipairs(statement.ids) do
        if not compiler:isUpvalue(statement.scope, id) then
            -- It's a local variable, we can try to target its register directly
            local varReg = compiler:getVarRegister(statement.scope, id, funcDepth, nil);
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

                local regs = compiler:compileExpression(expr, funcDepth, remainingCount, targets);
                for k, reg in ipairs(regs) do
                    table.insert(exprregs, reg);
                end
            else
                if statement.ids[i] or expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression then
                    local targets = { targetRegs[i] };
                    local reg = compiler:compileExpression(expr, funcDepth, 1, targets)[1];
                    table.insert(exprregs, reg);
                end
            end
        end
    end

    if #exprregs == 0 then
        for i=1, #statement.ids do
            local targets = { targetRegs[i] };
            table.insert(exprregs, compiler:compileExpression(Ast.NilExpression(), funcDepth, 1, targets)[1]);
        end
    end

    for i, id in ipairs(statement.ids) do
        if(exprregs[i]) then
            if(compiler:isUpvalue(statement.scope, id)) then
                local varReg = compiler:getVarRegister(statement.scope, id, funcDepth, nil);
                scope:addReferenceToHigherScope(compiler.scope, compiler.allocUpvalFunction);
                compiler:addStatement(compiler:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(compiler.scope, compiler.allocUpvalFunction), {})), {varReg}, {}, false);
                compiler:addStatement(compiler:setUpvalueMember(scope, compiler:register(scope, varReg), compiler:register(scope, exprregs[i])), {}, {varReg, exprregs[i]}, true);
                compiler:freeRegister(exprregs[i], false);
            else
                local varreg = compiler:getVarRegister(statement.scope, id, funcDepth, exprregs[i]);
                if varreg ~= exprregs[i] then
                    compiler:addStatement(compiler:copyRegisters(scope, {varreg}, {exprregs[i]}), {varreg}, {exprregs[i]}, false);
                    compiler:freeRegister(exprregs[i], false);
                end
            end
        end
    end

    if not compiler.scopeFunctionDepths[statement.scope] then
        compiler.scopeFunctionDepths[statement.scope] = funcDepth;
    end
end

function Statements.FunctionCallStatement(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    local baseReg = compiler:compileExpression(statement.base, funcDepth, 1)[1];
    local regs = {};
    local args = {};

    for i, expr in ipairs(statement.args) do
        if i == #statement.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
            local reg = compiler:compileExpression(expr, funcDepth, compiler.RETURN_ALL)[1];
            table.insert(args, Ast.FunctionCallExpression(
                compiler:unpack(scope),
                {compiler:register(scope, reg)}));
            table.insert(regs, reg);
        else
            local argExpr, argReg = compiler:compileOperand(scope, expr, funcDepth);
            table.insert(args, argExpr);
            if argReg then table.insert(regs, argReg) end
        end
    end

    compiler:addStatement(Ast.FunctionCallStatement(compiler:register(scope, baseReg), args), {}, {baseReg, unpack(regs)}, true);

    compiler:freeRegister(baseReg, false);
    for i, reg in ipairs(regs) do
        compiler:freeRegister(reg, false);
    end
end

function Statements.PassSelfFunctionCallStatement(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    local baseReg = compiler:compileExpression(statement.base, funcDepth, 1)[1];
    local args = { compiler:register(scope, baseReg) };
    local regs = { baseReg };

    for i, expr in ipairs(statement.args) do
        if i == #statement.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
            local reg = compiler:compileExpression(expr, funcDepth, compiler.RETURN_ALL)[1];
            table.insert(args, Ast.FunctionCallExpression(
                compiler:unpack(scope),
                {compiler:register(scope, reg)}));
            table.insert(regs, reg);
        else
            local argExpr, argReg = compiler:compileOperand(scope, expr, funcDepth);
            table.insert(args, argExpr);
            if argReg then table.insert(regs, argReg) end
        end
    end

    local funcExpr = Ast.IndexExpression(compiler:register(scope, baseReg), Ast.StringExpression(statement.passSelfFunctionName))

    compiler:addStatement(Ast.FunctionCallStatement(funcExpr, args), {}, {baseReg, unpack(regs)}, true);

    for i, reg in ipairs(regs) do
        compiler:freeRegister(reg, false);
    end
end

function Statements.LocalFunctionDeclaration(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    if(compiler:isUpvalue(statement.scope, statement.id)) then
        local varReg = compiler:getVarRegister(statement.scope, statement.id, funcDepth, nil);
        scope:addReferenceToHigherScope(compiler.scope, compiler.allocUpvalFunction);
        compiler:addStatement(compiler:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(compiler.scope, compiler.allocUpvalFunction), {})), {varReg}, {}, false);
        local retReg = compiler:compileFunction(statement, funcDepth);
        compiler:addStatement(compiler:setUpvalueMember(scope, compiler:register(scope, varReg), compiler:register(scope, retReg)), {}, {varReg, retReg}, true);
        compiler:freeRegister(retReg, false);
    else
        local retReg = compiler:compileFunction(statement, funcDepth);
        local varReg = compiler:getVarRegister(statement.scope, statement.id, funcDepth, retReg);
        compiler:addStatement(compiler:copyRegisters(scope, {varReg}, {retReg}), {varReg}, {retReg}, false);
        compiler:freeRegister(retReg, false);
    end
end

function Statements.FunctionDeclaration(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    local retReg = compiler:compileFunction(statement, funcDepth);
    if(#statement.indices > 0) then
        local tblReg;
        if statement.scope.isGlobal then
            tblReg = compiler:allocRegister(false);
            compiler:addStatement(compiler:setRegister(scope, tblReg, Ast.StringExpression(statement.scope:getVariableName(statement.id))), {tblReg}, {}, false);
            compiler:addStatement(compiler:setRegister(scope, tblReg, Ast.IndexExpression(compiler:env(scope), compiler:register(scope, tblReg))), {tblReg}, {tblReg}, true);
        else
            if compiler.scopeFunctionDepths[statement.scope] == funcDepth then
                if compiler:isUpvalue(statement.scope, statement.id) then
                    tblReg = compiler:allocRegister(false);
                    local reg = compiler:getVarRegister(statement.scope, statement.id, funcDepth);
                    compiler:addStatement(compiler:setRegister(scope, tblReg, compiler:getUpvalueMember(scope, compiler:register(scope, reg))), {tblReg}, {reg}, true);
                else
                    tblReg = compiler:getVarRegister(statement.scope, statement.id, funcDepth, retReg);
                end
            else
                tblReg = compiler:allocRegister(false);
                local upvalId = compiler:getUpvalueId(statement.scope, statement.id);
                scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.currentUpvaluesVar);
                compiler:addStatement(compiler:setRegister(scope, tblReg, compiler:getUpvalueMember(scope, Ast.IndexExpression(Ast.VariableExpression(compiler.containerFuncScope, compiler.currentUpvaluesVar), Ast.NumberExpression(upvalId)))), {tblReg}, {}, true);
            end
        end

        for i = 1, #statement.indices - 1 do
            local index = statement.indices[i];
            local indexReg = compiler:compileExpression(Ast.StringExpression(index), funcDepth, 1)[1];
            local tblRegOld = tblReg;
            tblReg = compiler:allocRegister(false);
            compiler:addStatement(compiler:setRegister(scope, tblReg, Ast.IndexExpression(compiler:register(scope, tblRegOld), compiler:register(scope, indexReg))), {tblReg}, {tblReg, indexReg}, false);
            compiler:freeRegister(tblRegOld, false);
            compiler:freeRegister(indexReg, false);
        end

        local index = statement.indices[#statement.indices];
        local indexReg = compiler:compileExpression(Ast.StringExpression(index), funcDepth, 1)[1];
        compiler:addStatement(Ast.AssignmentStatement({
            Ast.AssignmentIndexing(compiler:register(scope, tblReg), compiler:register(scope, indexReg)),
        }, {
            compiler:register(scope, retReg),
        }), {}, {tblReg, indexReg, retReg}, true);
        compiler:freeRegister(indexReg, false);
        compiler:freeRegister(tblReg, false);
        compiler:freeRegister(retReg, false);

        return;
    end
    if statement.scope.isGlobal then
        -- OPTIMIZATION: Inline Global Name Strings
        compiler:addStatement(Ast.AssignmentStatement({Ast.AssignmentIndexing(compiler:env(scope), Ast.StringExpression(statement.scope:getVariableName(statement.id)))},
            {compiler:register(scope, retReg)}), {}, {retReg}, true);
    else
        if compiler.scopeFunctionDepths[statement.scope] == funcDepth then
            if compiler:isUpvalue(statement.scope, statement.id) then
                local reg = compiler:getVarRegister(statement.scope, statement.id, funcDepth);
                compiler:addStatement(compiler:setUpvalueMember(scope, compiler:register(scope, reg), compiler:register(scope, retReg)), {}, {reg, retReg}, true);
            else
                local reg = compiler:getVarRegister(statement.scope, statement.id, funcDepth, retReg);
                if reg ~= retReg then
                    compiler:addStatement(compiler:setRegister(scope, reg, compiler:register(scope, retReg)), {reg}, {retReg}, false);
                end
            end
        else
            local upvalId = compiler:getUpvalueId(statement.scope, statement.id);
            scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.currentUpvaluesVar);
            compiler:addStatement(compiler:setUpvalueMember(scope, Ast.IndexExpression(Ast.VariableExpression(compiler.containerFuncScope, compiler.currentUpvaluesVar), Ast.NumberExpression(upvalId)), compiler:register(scope, retReg)), {}, {retReg}, true);
        end
    end
    compiler:freeRegister(retReg, false);
end

function Statements.AssignmentStatement(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    local exprregs = {};
    local assignmentIndexingRegs = {};
    local targetRegs = {};

    for i, primaryExpr in ipairs(statement.lhs) do
        if(primaryExpr.kind == AstKind.AssignmentIndexing) then
            assignmentIndexingRegs [i] = {
                base = compiler:compileExpression(primaryExpr.base, funcDepth, 1)[1],
                index = compiler:compileExpression(primaryExpr.index, funcDepth, 1)[1],
            };
        elseif primaryExpr.kind == AstKind.AssignmentVariable then
            if not primaryExpr.scope.isGlobal then
                    -- Local or Upvalue
                    if compiler.scopeFunctionDepths[primaryExpr.scope] == funcDepth and not compiler:isUpvalue(primaryExpr.scope, primaryExpr.id) then
                    -- It's a local in current scope
                    targetRegs[i] = compiler:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth, nil);
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

            local regs = compiler:compileExpression(expr, funcDepth, remainingCount, targets);

            for k, reg in ipairs(regs) do
                if(compiler:isVarRegister(reg) and reg ~= targetRegs[i + k - 1]) then
                    local ro = reg;
                    reg = compiler:allocRegister(false);
                    compiler:addStatement(compiler:copyRegisters(scope, {reg}, {ro}), {reg}, {ro}, false);
                end
                table.insert(exprregs, reg);
            end
        else
            if statement.lhs[i] or expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression then
                local targets = { targetRegs[i] };
                local reg = compiler:compileExpression(expr, funcDepth, 1, targets)[1];

                if(compiler:isVarRegister(reg) and reg ~= targetRegs[i]) then
                    local ro = reg;
                    reg = compiler:allocRegister(false);
                    compiler:addStatement(compiler:copyRegisters(scope, {reg}, {ro}), {reg}, {ro}, false);
                end
                table.insert(exprregs, reg);
            end
        end
    end

    for i, primaryExpr in ipairs(statement.lhs) do
        if primaryExpr.kind == AstKind.AssignmentVariable then
            if primaryExpr.scope.isGlobal then
                -- OPTIMIZATION: Inline Global Name Strings
                compiler:addStatement(Ast.AssignmentStatement({Ast.AssignmentIndexing(compiler:env(scope), Ast.StringExpression(primaryExpr.scope:getVariableName(primaryExpr.id)))},
                    {compiler:register(scope, exprregs[i])}), {}, {exprregs[i]}, true);
            else
                if compiler.scopeFunctionDepths[primaryExpr.scope] == funcDepth then
                    if compiler:isUpvalue(primaryExpr.scope, primaryExpr.id) then
                        local reg = compiler:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth);
                        compiler:addStatement(compiler:setUpvalueMember(scope, compiler:register(scope, reg), compiler:register(scope, exprregs[i])), {}, {reg, exprregs[i]}, true);
                    else
                        local reg = compiler:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth, exprregs[i]);
                        if reg ~= exprregs[i] then
                            compiler:addStatement(compiler:setRegister(scope, reg, compiler:register(scope, exprregs[i])), {reg}, {exprregs[i]}, false);
                        end
                    end
                else
                    local upvalId = compiler:getUpvalueId(primaryExpr.scope, primaryExpr.id);
                    scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.currentUpvaluesVar);
                    compiler:addStatement(compiler:setUpvalueMember(scope, Ast.IndexExpression(Ast.VariableExpression(compiler.containerFuncScope, compiler.currentUpvaluesVar), Ast.NumberExpression(upvalId)), compiler:register(scope, exprregs[i])), {}, {exprregs[i]}, true);
                end
            end
        elseif primaryExpr.kind == AstKind.AssignmentIndexing then
            local baseReg = assignmentIndexingRegs[i].base;
            local indexReg = assignmentIndexingRegs[i].index;
            compiler:addStatement(Ast.AssignmentStatement({
                Ast.AssignmentIndexing(compiler:register(scope, baseReg), compiler:register(scope, indexReg))
            }, {
                compiler:register(scope, exprregs[i])
            }), {}, {exprregs[i], baseReg, indexReg}, true);
            compiler:freeRegister(exprregs[i], false);
            compiler:freeRegister(baseReg, false);
            compiler:freeRegister(indexReg, false);
        else
            logger:error(string.format("Invalid Assignment lhs: %s", statement.lhs));
        end
    end
end

function Statements.IfStatement(compiler, statement, funcDepth)
    local finalBlock = compiler:createBlock();
    local nextBlock;
    if statement.elsebody or #statement.elseifs > 0 then
        nextBlock = compiler:createBlock();
    else
        nextBlock = finalBlock;
    end

    local innerBlock = compiler:createBlock();
    emitConditionalJump(compiler, statement.condition, innerBlock, nextBlock, funcDepth);

    compiler:setActiveBlock(innerBlock);
    compiler:compileBlock(statement.body, funcDepth);
    compiler:addStatement(compiler:setPos(compiler.activeBlock.scope, finalBlock.id), {compiler.POS_REGISTER}, {}, false);

    for i, eif in ipairs(statement.elseifs) do
        compiler:setActiveBlock(nextBlock);
        if statement.elsebody or i < #statement.elseifs then
            nextBlock = compiler:createBlock();
        else
            nextBlock = finalBlock;
        end
        local innerBlock = compiler:createBlock();
        emitConditionalJump(compiler, eif.condition, innerBlock, nextBlock, funcDepth);

        compiler:setActiveBlock(innerBlock);
        compiler:compileBlock(eif.body, funcDepth);
        compiler:addStatement(compiler:setPos(compiler.activeBlock.scope, finalBlock.id), {compiler.POS_REGISTER}, {}, false);
    end

    if statement.elsebody then
        compiler:setActiveBlock(nextBlock);
        compiler:compileBlock(statement.elsebody, funcDepth);
        compiler:addStatement(compiler:setPos(compiler.activeBlock.scope, finalBlock.id), {compiler.POS_REGISTER}, {}, false);
    end

    compiler:setActiveBlock(finalBlock);
end

function Statements.DoStatement(compiler, statement, funcDepth)
    compiler:compileBlock(statement.body, funcDepth);
end

function Statements.WhileStatement(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    local innerBlock = compiler:createBlock();
    local finalBlock = compiler:createBlock();
    local checkBlock = compiler:createBlock();

    statement.__start_block = checkBlock;
    statement.__final_block = finalBlock;

    compiler:addStatement(compiler:setPos(scope, checkBlock.id), {compiler.POS_REGISTER}, {}, false);

    compiler:setActiveBlock(checkBlock);
    local scope = compiler.activeBlock.scope;
    local conditionReg = compiler:compileExpression(statement.condition, funcDepth, 1)[1];
    compiler:addStatement(compiler:setRegister(scope, compiler.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(compiler:register(scope, conditionReg), Ast.NumberExpression(innerBlock.id)), Ast.NumberExpression(finalBlock.id))), {compiler.POS_REGISTER}, {conditionReg}, false);
    compiler:freeRegister(conditionReg, false);

    compiler:setActiveBlock(innerBlock);
    local scope = compiler.activeBlock.scope;
    compiler:compileBlock(statement.body, funcDepth);

    local conditionReg2 = compiler:compileExpression(statement.condition, funcDepth, 1)[1];
    compiler:addStatement(compiler:setRegister(scope, compiler.POS_REGISTER,
        Ast.OrExpression(
            Ast.AndExpression(compiler:register(scope, conditionReg2), Ast.NumberExpression(innerBlock.id)),
            Ast.NumberExpression(finalBlock.id)
        )
    ), {compiler.POS_REGISTER}, {conditionReg2}, false);
    compiler:freeRegister(conditionReg2, false);

    compiler:setActiveBlock(finalBlock);
end

function Statements.RepeatStatement(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    local innerBlock = compiler:createBlock();
    local finalBlock = compiler:createBlock();
    local checkBlock = compiler:createBlock(); -- Keep for 'continue' jump target

    statement.__start_block = checkBlock;
    statement.__final_block = finalBlock;

    -- Initial jump to inner
    compiler:addStatement(compiler:setRegister(scope, compiler.POS_REGISTER, Ast.NumberExpression(innerBlock.id)), {compiler.POS_REGISTER}, {}, false);

    -- Inner (Body)
    compiler:setActiveBlock(innerBlock);
    compiler:compileBlock(statement.body, funcDepth);

    -- OPTIMIZATION: Inline the check at the end of Body
    local conditionReg = compiler:compileExpression(statement.condition, funcDepth, 1)[1];
    -- Repeat until cond: if cond is true, exit. Else loop (inner).
    -- POS = Cond and Final or Inner
    compiler:addStatement(compiler:setRegister(scope, compiler.POS_REGISTER,
        Ast.OrExpression(
            Ast.AndExpression(compiler:register(scope, conditionReg), Ast.NumberExpression(finalBlock.id)),
            Ast.NumberExpression(innerBlock.id)
        )
    ), {compiler.POS_REGISTER}, {conditionReg}, false);
    compiler:freeRegister(conditionReg, false);

    -- Check Block (Only used by Continue)
    compiler:setActiveBlock(checkBlock);
    local scope = compiler.activeBlock.scope;
    local conditionReg2 = compiler:compileExpression(statement.condition, funcDepth, 1)[1];
    compiler:addStatement(compiler:setRegister(scope, compiler.POS_REGISTER,
        Ast.OrExpression(
            Ast.AndExpression(compiler:register(scope, conditionReg2), Ast.NumberExpression(finalBlock.id)),
            Ast.NumberExpression(innerBlock.id)
        )
    ), {compiler.POS_REGISTER}, {conditionReg2}, false);
    compiler:freeRegister(conditionReg2, false);

    compiler:setActiveBlock(finalBlock);
end

function Statements.ForStatement(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    
    -- P6: Loop Unrolling
    -- Check if we can unroll this loop
    if compiler.enableLoopUnrolling then
        local isStartConst, startVal = isConstantNumber(statement.initialValue)
        local isEndConst, endVal = isConstantNumber(statement.finalValue)
        local isStepConst, stepVal = isConstantNumber(statement.incrementBy)
        
        -- All bounds must be constant, step must not be zero
        if isStartConst and isEndConst and isStepConst and stepVal ~= 0 then
            -- Calculate iteration count
            local iterations = 0
            if stepVal > 0 and endVal >= startVal then
                iterations = math.floor((endVal - startVal) / stepVal) + 1
            elseif stepVal < 0 and startVal >= endVal then
                iterations = math.floor((startVal - endVal) / (-stepVal)) + 1
            end
            
            -- Check if iteration count is within the threshold
            if iterations > 0 and iterations <= compiler.maxUnrollIterations then
                -- Check if loop variable is NOT an upvalue (upvalues need special handling per iteration)
                local isUpval = compiler:isUpvalue(statement.scope, statement.id)
                
                -- Check if body contains break/return/continue
                local hasControlFlow = containsLoopControl(statement.body)
                
                -- Only unroll if conditions are met
                if not isUpval and not hasControlFlow then
                    -- Register for the scope function depth
                    if not compiler.scopeFunctionDepths[statement.scope] then
                        compiler.scopeFunctionDepths[statement.scope] = funcDepth
                    end
                    
                    -- Emit unrolled iterations
                    for i = startVal, endVal, stepVal do
                        -- Allocate register for loop variable
                        local varReg = compiler:getVarRegister(statement.scope, statement.id, funcDepth, nil)
                        
                        -- Set loop variable to constant value
                        compiler:addStatement(
                            compiler:setRegister(scope, varReg, Ast.NumberExpression(i)),
                            {varReg},
                            {},
                            false
                        )
                        
                        -- Compile the loop body for this iteration
                        compiler:compileBlock(statement.body, funcDepth)
                        
                        -- Update scope reference for next iteration
                        scope = compiler.activeBlock.scope
                    end
                    
                    -- Loop unrolling complete - no need for normal loop handling
                    return
                end
            end
        end
    end
    
    -- Normal loop handling (fallback when unrolling not possible)
    local checkBlock = compiler:createBlock();
    local innerBlock = compiler:createBlock();
    local finalBlock = compiler:createBlock();

    statement.__start_block = checkBlock;
    statement.__final_block = finalBlock;

    local posState = compiler.registers[compiler.POS_REGISTER];
    compiler.registers[compiler.POS_REGISTER] = compiler.VAR_REGISTER;

    local initialReg = compiler:compileExpression(statement.initialValue, funcDepth, 1)[1];

    local finalExprReg = compiler:compileExpression(statement.finalValue, funcDepth, 1)[1];
    local finalReg = compiler:allocRegister(false);
    compiler:addStatement(compiler:copyRegisters(scope, {finalReg}, {finalExprReg}), {finalReg}, {finalExprReg}, false);
    compiler:freeRegister(finalExprReg);

    local incrementExprReg = compiler:compileExpression(statement.incrementBy, funcDepth, 1)[1];
    local incrementReg = compiler:allocRegister(false);
    compiler:addStatement(compiler:copyRegisters(scope, {incrementReg}, {incrementExprReg}), {incrementReg}, {incrementExprReg}, false);
    compiler:freeRegister(incrementExprReg);

    local a7bX9 = compiler:allocRegister(false);
    compiler:addStatement(compiler:setRegister(scope, a7bX9, Ast.NumberExpression(0)), {a7bX9}, {}, false);
    local incrementIsNegReg = compiler:allocRegister(false);
    compiler:addStatement(compiler:setRegister(scope, incrementIsNegReg, Ast.LessThanExpression(compiler:register(scope, incrementReg), compiler:register(scope, a7bX9))), {incrementIsNegReg}, {incrementReg, a7bX9}, false);
    compiler:freeRegister(a7bX9);

    local currentReg = compiler:allocRegister(true);
    compiler:addStatement(compiler:setRegister(scope, currentReg, Ast.SubExpression(compiler:register(scope, initialReg), compiler:register(scope, incrementReg))), {currentReg}, {initialReg, incrementReg}, false);
    compiler:freeRegister(initialReg);

    compiler:addStatement(compiler:jmp(scope, Ast.NumberExpression(checkBlock.id)), {compiler.POS_REGISTER}, {}, false);

    compiler:setActiveBlock(checkBlock);

    scope = checkBlock.scope;

    -- Define function to emit increment/check logic
    local function emitIncrementCheck()
        compiler:addStatement(compiler:setRegister(scope, currentReg, Ast.AddExpression(compiler:register(scope, currentReg), compiler:register(scope, incrementReg))), {currentReg}, {currentReg, incrementReg}, false);
        local z2pR6 = compiler:allocRegister(false);
        local m3kQ8 = compiler:allocRegister(false);
        compiler:addStatement(compiler:setRegister(scope, m3kQ8, Ast.NotExpression(compiler:register(scope, incrementIsNegReg))), {m3kQ8}, {incrementIsNegReg}, false);
        compiler:addStatement(compiler:setRegister(scope, z2pR6, Ast.LessThanOrEqualsExpression(compiler:register(scope, currentReg), compiler:register(scope, finalReg))), {z2pR6}, {currentReg, finalReg}, false);
        compiler:addStatement(compiler:setRegister(scope, z2pR6, Ast.AndExpression(compiler:register(scope, m3kQ8), compiler:register(scope, z2pR6))), {z2pR6}, {z2pR6, m3kQ8}, false);
        compiler:addStatement(compiler:setRegister(scope, m3kQ8, Ast.GreaterThanOrEqualsExpression(compiler:register(scope, currentReg), compiler:register(scope, finalReg))), {m3kQ8}, {currentReg, finalReg}, false);
        compiler:addStatement(compiler:setRegister(scope, m3kQ8, Ast.AndExpression(compiler:register(scope, incrementIsNegReg), compiler:register(scope, m3kQ8))), {m3kQ8}, {m3kQ8, incrementIsNegReg}, false);
        compiler:addStatement(compiler:setRegister(scope, z2pR6, Ast.OrExpression(compiler:register(scope, m3kQ8), compiler:register(scope, z2pR6))), {z2pR6}, {z2pR6, m3kQ8}, false);
        compiler:freeRegister(m3kQ8);

        -- Logic to set POS: if valid, inner; else final
        local innerBlockId = Ast.NumberExpression(innerBlock.id)
        local finalBlockId = Ast.NumberExpression(finalBlock.id)

        compiler:addStatement(compiler:setRegister(scope, compiler.POS_REGISTER,
            Ast.OrExpression(
                Ast.AndExpression(compiler:register(scope, z2pR6), innerBlockId),
                finalBlockId
            )
        ), {compiler.POS_REGISTER}, {z2pR6}, false);

        compiler:freeRegister(z2pR6);
    end

    -- Check Block (Original)
    emitIncrementCheck()

    compiler:setActiveBlock(innerBlock);
    scope = innerBlock.scope;
    compiler.registers[compiler.POS_REGISTER] = posState;

    local varReg = compiler:getVarRegister(statement.scope, statement.id, funcDepth, nil);

    if(compiler:isUpvalue(statement.scope, statement.id)) then
        scope:addReferenceToHigherScope(compiler.scope, compiler.allocUpvalFunction);
        compiler:addStatement(compiler:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(compiler.scope, compiler.allocUpvalFunction), {})), {varReg}, {}, false);
        compiler:addStatement(compiler:setUpvalueMember(scope, compiler:register(scope, varReg), compiler:register(scope, currentReg)), {}, {varReg, currentReg}, true);
    else
        compiler:addStatement(compiler:setRegister(scope, varReg, compiler:register(scope, currentReg)), {varReg}, {currentReg}, false);
    end

    compiler:compileBlock(statement.body, funcDepth);

    -- OPTIMIZATION: Inline increment/check at the end of Body
    emitIncrementCheck()

    compiler.registers[compiler.POS_REGISTER] = compiler.VAR_REGISTER;
    compiler:freeRegister(finalReg);
    compiler:freeRegister(incrementIsNegReg);
    compiler:freeRegister(incrementReg);
    compiler:freeRegister(currentReg, true);

    compiler.registers[compiler.POS_REGISTER] = posState;
    compiler:setActiveBlock(finalBlock);
end

function Statements.ForInStatement(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    local expressionsLength = #statement.expressions;
    local exprregs = {};
    for i, expr in ipairs(statement.expressions) do
        if(i == expressionsLength and expressionsLength < 3) then
            local regs = compiler:compileExpression(expr, funcDepth, 4 - expressionsLength);
            for i = 1, 4 - expressionsLength do
                table.insert(exprregs, regs[i]);
            end
        else
            if i <= 3 then
                table.insert(exprregs, compiler:compileExpression(expr, funcDepth, 1)[1])
            else
                compiler:freeRegister(compiler:compileExpression(expr, funcDepth, 1)[1], false);
            end
        end
    end

    for i, reg in ipairs(exprregs) do
        if reg and compiler.registers[reg] ~= compiler.VAR_REGISTER and reg ~= compiler.POS_REGISTER and reg ~= compiler.RETURN_REGISTER then
            compiler.registers[reg] = compiler.VAR_REGISTER;
        else
            exprregs[i] = compiler:allocRegister(true);
            compiler:addStatement(compiler:copyRegisters(scope, {exprregs[i]}, {reg}), {exprregs[i]}, {reg}, false);
        end
    end

    local checkBlock = compiler:createBlock();
    local bodyBlock = compiler:createBlock();
    local finalBlock = compiler:createBlock();

    statement.__start_block = checkBlock;
    statement.__final_block = finalBlock;

    compiler:addStatement(compiler:setPos(scope, checkBlock.id), {compiler.POS_REGISTER}, {}, false);

    -- Pre-calculate varRegs for optimization
    local varRegs = {};
    for i, id in ipairs(statement.ids) do
        varRegs[i] = compiler:getVarRegister(statement.scope, id, funcDepth)
    end

    -- Helper to emit iterator call and jump
    local function emitIteratorLogic(targetScope)
        compiler:addStatement(Ast.AssignmentStatement({
            compiler:registerAssignment(targetScope, exprregs[3]),
            varRegs[2] and compiler:registerAssignment(targetScope, varRegs[2]),
        }, {
            Ast.FunctionCallExpression(compiler:register(targetScope, exprregs[1]), {
                compiler:register(targetScope, exprregs[2]),
                compiler:register(targetScope, exprregs[3]),
            })
        }), {exprregs[3], varRegs[2]}, {exprregs[1], exprregs[2], exprregs[3]}, true);

        compiler:addStatement(Ast.AssignmentStatement({
            compiler:posAssignment(targetScope)
        }, {
            Ast.OrExpression(Ast.AndExpression(compiler:register(targetScope, exprregs[3]), Ast.NumberExpression(bodyBlock.id)), Ast.NumberExpression(finalBlock.id))
        }), {compiler.POS_REGISTER}, {exprregs[3]}, false);
    end

    -- Check Block (First Iteration)
    compiler:setActiveBlock(checkBlock);
    local scope = compiler.activeBlock.scope;
    emitIteratorLogic(scope);

    -- Body Block
    compiler:setActiveBlock(bodyBlock);
    local scope = compiler.activeBlock.scope;

    compiler:addStatement(compiler:copyRegisters(scope, {varRegs[1]}, {exprregs[3]}), {varRegs[1]}, {exprregs[3]}, false);
    for i=3, #varRegs do
        compiler:addStatement(compiler:setRegister(scope, varRegs[i], Ast.NilExpression()), {varRegs[i]}, {}, false);
    end

    -- Upvalue fix
    for i, id in ipairs(statement.ids) do
        if(compiler:isUpvalue(statement.scope, id)) then
            local varreg = varRegs[i];
            local a7bX9 = compiler:allocRegister(false);
            scope:addReferenceToHigherScope(compiler.scope, compiler.allocUpvalFunction);
            compiler:addStatement(compiler:setRegister(scope, a7bX9, Ast.FunctionCallExpression(Ast.VariableExpression(compiler.scope, compiler.allocUpvalFunction), {})), {a7bX9}, {}, false);
            compiler:addStatement(compiler:setUpvalueMember(scope, compiler:register(scope, a7bX9), compiler:register(scope, varreg)), {}, {a7bX9, varreg}, true);
            compiler:addStatement(compiler:copyRegisters(scope, {varreg}, {a7bX9}), {varreg}, {a7bX9}, false);
            compiler:freeRegister(a7bX9, false);
        end
    end

    compiler:compileBlock(statement.body, funcDepth);

    -- OPTIMIZATION: Loop Rotation
    emitIteratorLogic(scope);

    compiler:setActiveBlock(finalBlock);

    for i, reg in ipairs(exprregs) do
        compiler:freeRegister(exprregs[i], true)
    end
end

function Statements.BreakStatement(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
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
        local varReg = compiler:getVarRegister(varScope, id, nil, nil);
        if compiler:isUpvalue(varScope, id) then
            scope:addReferenceToHigherScope(compiler.scope, compiler.freeUpvalueFunc);
            compiler:addStatement(compiler:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(compiler.scope, compiler.freeUpvalueFunc), {
                compiler:register(scope, varReg)
            })), {varReg}, {varReg}, false);
        else
            table.insert(regsToClear, varReg)
            table.insert(nils, Ast.NilExpression())
        end
    end

    if #regsToClear > 0 then
        compiler:addStatement(compiler:setRegisters(scope, regsToClear, nils), regsToClear, {}, false);
    end

    compiler:addStatement(compiler:setPos(scope, statement.loop.__final_block.id), {compiler.POS_REGISTER}, {}, false);
    compiler.activeBlock.advanceToNextBlock = false;
end

function Statements.ContinueStatement(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
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
        local varReg = compiler:getVarRegister(varScope, id, nil, nil);
        if compiler:isUpvalue(varScope, id) then
            scope:addReferenceToHigherScope(compiler.scope, compiler.freeUpvalueFunc);
            compiler:addStatement(compiler:setRegister(scope, varReg, Ast.FunctionCallExpression(Ast.VariableExpression(compiler.scope, compiler.freeUpvalueFunc), {
                compiler:register(scope, varReg)
            })), {varReg}, {varReg}, false);
        else
            table.insert(regsToClear, varReg)
            table.insert(nils, Ast.NilExpression())
        end
    end

    if #regsToClear > 0 then
        compiler:addStatement(compiler:setRegisters(scope, regsToClear, nils), regsToClear, {}, false);
    end

    compiler:addStatement(compiler:setPos(scope, statement.loop.__start_block.id), {compiler.POS_REGISTER}, {}, false);
    compiler.activeBlock.advanceToNextBlock = false;
end

local compoundConstructors = {
    [AstKind.CompoundAddStatement] = Ast.CompoundAddStatement,
    [AstKind.CompoundSubStatement] = Ast.CompoundSubStatement,
    [AstKind.CompoundMulStatement] = Ast.CompoundMulStatement,
    [AstKind.CompoundDivStatement] = Ast.CompoundDivStatement,
    [AstKind.CompoundModStatement] = Ast.CompoundModStatement,
    [AstKind.CompoundPowStatement] = Ast.CompoundPowStatement,
    [AstKind.CompoundConcatStatement] = Ast.CompoundConcatStatement,
}

function Statements.CompoundStatement(compiler, statement, funcDepth)
    local scope = compiler.activeBlock.scope;
    local compoundConstructor = compoundConstructors[statement.kind];
    if not compoundConstructor then return end -- Should be dispatched correctly

    if statement.lhs.kind == AstKind.AssignmentIndexing then
        local indexing = statement.lhs;
        local baseReg = compiler:compileExpression(indexing.base, funcDepth, 1)[1];
        local indexReg = compiler:compileExpression(indexing.index, funcDepth, 1)[1];
        local valueReg = compiler:compileExpression(statement.rhs, funcDepth, 1)[1];

        compiler:addStatement(compoundConstructor(Ast.AssignmentIndexing(compiler:register(scope, baseReg), compiler:register(scope, indexReg)), compiler:register(scope, valueReg)), {}, {baseReg, indexReg, valueReg}, true);
    else
        local valueReg = compiler:compileExpression(statement.rhs, funcDepth, 1)[1];
        local primaryExpr = statement.lhs;
        if primaryExpr.scope.isGlobal then
            -- OPTIMIZATION: Inline Global Name Strings
            compiler:addStatement(Ast.AssignmentStatement({Ast.AssignmentIndexing(compiler:env(scope), Ast.StringExpression(primaryExpr.scope:getVariableName(primaryExpr.id)))},
                {compiler:register(scope, valueReg)}), {}, {valueReg}, true);
        else
            if compiler.scopeFunctionDepths[primaryExpr.scope] == funcDepth then
                if compiler:isUpvalue(primaryExpr.scope, primaryExpr.id) then
                    local reg = compiler:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth);
                    compiler:addStatement(compiler:setUpvalueMember(scope, compiler:register(scope, reg), compiler:register(scope, valueReg), compoundConstructor), {}, {reg, valueReg}, true);
                else
                    local reg = compiler:getVarRegister(primaryExpr.scope, primaryExpr.id, funcDepth, valueReg);
                    if reg ~= valueReg then
                        compiler:addStatement(compiler:setRegister(scope, reg, compiler:register(scope, valueReg), compoundConstructor), {reg}, {valueReg}, false);
                    end
                end
            else
                local upvalId = compiler:getUpvalueId(primaryExpr.scope, primaryExpr.id);
                scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.currentUpvaluesVar);
                compiler:addStatement(compiler:setUpvalueMember(scope, Ast.IndexExpression(Ast.VariableExpression(compiler.containerFuncScope, compiler.currentUpvaluesVar), Ast.NumberExpression(upvalId)), compiler:register(scope, valueReg), compoundConstructor), {}, {valueReg}, true);
            end
        end
    end
end

for k, v in pairs(compoundConstructors) do
    Statements[k] = Statements.CompoundStatement
end

return Statements

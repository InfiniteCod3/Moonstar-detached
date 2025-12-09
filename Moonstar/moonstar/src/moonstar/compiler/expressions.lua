local Ast = require("moonstar.ast");
local AstKind = Ast.AstKind;
local logger = require("logger");
local util = require("moonstar.util");

local unpack = unpack or table.unpack;

local Expressions = {}

-- P5: Helper to collect all operands from chained string concatenation (a .. b .. c .. d)
-- Returns a flat array of operands if chain has threshold+ parts, otherwise nil
local function collectStrCatOperands(expr, threshold)
    if expr.kind ~= AstKind.StrCatExpression then
        return nil
    end
    
    threshold = threshold or 3
    local operands = {}
    
    local function collect(node)
        if node.kind == AstKind.StrCatExpression then
            -- Recursively collect from nested StrCat
            collect(node.lhs)
            collect(node.rhs)
        else
            -- Leaf node - add to operands
            table.insert(operands, node)
        end
    end
    
    collect(expr)
    
    -- Only return if we have threshold+ operands (otherwise normal concat is fine)
    if #operands >= threshold then
        return operands
    end
    
    return nil
end

function Expressions.StringExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns, 1 do
        if targetRegs and targetRegs[i] then
            regs[i] = targetRegs[i];
        else
            regs[i] = compiler:allocRegister();
        end

        if(i == 1) then
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.StringExpression(expression.value)), {regs[i]}, {}, false);
        else
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

function Expressions.NumberExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns do
        if targetRegs and targetRegs[i] then
            regs[i] = targetRegs[i];
        else
            regs[i] = compiler:allocRegister();
        end

        if(i == 1) then
           compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NumberExpression(expression.value)), {regs[i]}, {}, false);
        else
           compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

function Expressions.BooleanExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns do
        if targetRegs and targetRegs[i] then
            regs[i] = targetRegs[i];
        else
            regs[i] = compiler:allocRegister();
        end

        if(i == 1) then
           compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.BooleanExpression(expression.value)), {regs[i]}, {}, false);
        else
           compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

function Expressions.NilExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns do
        if targetRegs and targetRegs[i] then
            regs[i] = targetRegs[i];
        else
            regs[i] = compiler:allocRegister();
        end
        compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
    end
    return regs;
end

function Expressions.VariableExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns do
        if(i == 1) then
            if(expression.scope.isGlobal) then
                -- Global Variable
                if targetRegs and targetRegs[i] then
                    regs[i] = targetRegs[i];
                else
                    regs[i] = compiler:allocRegister(false);
                end

                -- P3: Check for hoisted global first
                local name = expression.scope:getVariableName(expression.id)
                local hoistedVar = compiler:getHoistedGlobal(name)
                
                if hoistedVar then
                    -- P3: Use hoisted local variable instead of _ENV lookup
                    scope:addReferenceToHigherScope(compiler.containerFuncScope, hoistedVar)
                    compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.VariableExpression(compiler.containerFuncScope, hoistedVar)), {regs[i]}, {}, false);
                else
                    -- OPTIMIZATION: Inline Global Name Strings
                    -- Use compileOperand to allow string encryption/hoisting
                    local nameExpr, nameReg = compiler:compileOperand(scope, Ast.StringExpression(name), funcDepth)
                    local reads = nameReg and {nameReg} or {}

                    compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.IndexExpression(compiler:env(scope), nameExpr)), {regs[i]}, reads, true);
                    if nameReg then compiler:freeRegister(nameReg, false) end
                end
            else
                -- Local Variable
                if(compiler.scopeFunctionDepths[expression.scope] == funcDepth) then
                    if compiler:isUpvalue(expression.scope, expression.id) then
                        if targetRegs and targetRegs[i] then
                            regs[i] = targetRegs[i];
                        else
                            regs[i] = compiler:allocRegister(false);
                        end
                        local varReg = compiler:getVarRegister(expression.scope, expression.id, funcDepth, nil);
                        compiler:addStatement(compiler:setRegister(scope, regs[i], compiler:getUpvalueMember(scope, compiler:register(scope, varReg))), {regs[i]}, {varReg}, true);
                    else
                        regs[i] = compiler:getVarRegister(expression.scope, expression.id, funcDepth, nil);
                        -- Optimization: If targetReg is provided and different from varReg, copy.
                        if targetRegs and targetRegs[i] and regs[i] ~= targetRegs[i] then
                            compiler:addStatement(compiler:copyRegisters(scope, {targetRegs[i]}, {regs[i]}), {targetRegs[i]}, {regs[i]}, false);
                            regs[i] = targetRegs[i];
                        end
                    end
                else
                    if targetRegs and targetRegs[i] then
                        regs[i] = targetRegs[i];
                    else
                        regs[i] = compiler:allocRegister(false);
                    end
                    local upvalId = compiler:getUpvalueId(expression.scope, expression.id);
                    scope:addReferenceToHigherScope(compiler.containerFuncScope, compiler.currentUpvaluesVar);
                    compiler:addStatement(compiler:setRegister(scope, regs[i], compiler:getUpvalueMember(scope, Ast.IndexExpression(Ast.VariableExpression(compiler.containerFuncScope, compiler.currentUpvaluesVar), Ast.NumberExpression(upvalId)))), {regs[i]}, {}, true);
                end
            end
        else
            if targetRegs and targetRegs[i] then
                regs[i] = targetRegs[i];
            else
                regs[i] = compiler:allocRegister();
            end
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

function Expressions.FunctionCallExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local baseReg = compiler:compileExpression(expression.base, funcDepth, 1)[1];

    local retRegs  = {};
    local returnAll = numReturns == compiler.RETURN_ALL;
    if returnAll then
        if targetRegs and targetRegs[1] then
            retRegs[1] = targetRegs[1]
        else
            retRegs[1] = compiler:allocRegister(false);
        end
    else
        for i = 1, numReturns do
            if targetRegs and targetRegs[i] then
                retRegs[i] = targetRegs[i];
            else
                retRegs[i] = compiler:allocRegister(false);
            end
        end
    end

    local regs = {};
    local args = {};
    for i, expr in ipairs(expression.args) do
        if i == #expression.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
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

    if(returnAll) then
        compiler:addStatement(compiler:setRegister(scope, retRegs[1], Ast.TableConstructorExpression{Ast.TableEntry(Ast.FunctionCallExpression(compiler:register(scope, baseReg), args))}), {retRegs[1]}, {baseReg, unpack(regs)}, true);
    else
        if(numReturns > 1) then
            local a7bX9 = compiler:allocRegister(false);

            compiler:addStatement(compiler:setRegister(scope, a7bX9, Ast.TableConstructorExpression{Ast.TableEntry(Ast.FunctionCallExpression(compiler:register(scope, baseReg), args))}), {a7bX9}, {baseReg, unpack(regs)}, true);

            for i, reg in ipairs(retRegs) do
                compiler:addStatement(compiler:setRegister(scope, reg, Ast.IndexExpression(compiler:register(scope, a7bX9), Ast.NumberExpression(i))), {reg}, {a7bX9}, false);
            end

            compiler:freeRegister(a7bX9, false);
        else
            compiler:addStatement(compiler:setRegister(scope, retRegs[1], Ast.FunctionCallExpression(compiler:register(scope, baseReg), args)), {retRegs[1]}, {baseReg, unpack(regs)}, true);
        end
    end

    compiler:freeRegister(baseReg, false);
    for i, reg in ipairs(regs) do
        compiler:freeRegister(reg, false);
    end

    return retRegs;
end

function Expressions.PassSelfFunctionCallExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local baseReg = compiler:compileExpression(expression.base, funcDepth, 1)[1];
    local retRegs  = {};
    local returnAll = numReturns == compiler.RETURN_ALL;
    if returnAll then
        retRegs[1] = compiler:allocRegister(false);
    else
        for i = 1, numReturns do
            retRegs[i] = compiler:allocRegister(false);
        end
    end

    local args = { compiler:register(scope, baseReg) };
    local regs = { baseReg };

    for i, expr in ipairs(expression.args) do
        if i == #expression.args and (expr.kind == AstKind.FunctionCallExpression or expr.kind == AstKind.PassSelfFunctionCallExpression or expr.kind == AstKind.VarargExpression) then
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

    if(returnAll or numReturns > 1) then
        local a7bX9 = compiler:allocRegister(false);

        compiler:addStatement(compiler:setRegister(scope, a7bX9, Ast.StringExpression(expression.passSelfFunctionName)), {a7bX9}, {}, false);
        compiler:addStatement(compiler:setRegister(scope, a7bX9, Ast.IndexExpression(compiler:register(scope, baseReg), compiler:register(scope, a7bX9))), {a7bX9}, {baseReg, a7bX9}, false);

        if returnAll then
            compiler:addStatement(compiler:setRegister(scope, retRegs[1], Ast.TableConstructorExpression{Ast.TableEntry(Ast.FunctionCallExpression(compiler:register(scope, a7bX9), args))}), {retRegs[1]}, {a7bX9, unpack(regs)}, true);
        else
            compiler:addStatement(compiler:setRegister(scope, a7bX9, Ast.TableConstructorExpression{Ast.TableEntry(Ast.FunctionCallExpression(compiler:register(scope, a7bX9), args))}), {a7bX9}, {a7bX9, unpack(regs)}, true);

            for i, reg in ipairs(retRegs) do
                compiler:addStatement(compiler:setRegister(scope, reg, Ast.IndexExpression(compiler:register(scope, a7bX9), Ast.NumberExpression(i))), {reg}, {a7bX9}, false);
            end
        end

        compiler:freeRegister(a7bX9, false);
    else
        local a7bX9 = retRegs[1] or compiler:allocRegister(false);

        compiler:addStatement(compiler:setRegister(scope, a7bX9, Ast.StringExpression(expression.passSelfFunctionName)), {a7bX9}, {}, false);
        compiler:addStatement(compiler:setRegister(scope, a7bX9, Ast.IndexExpression(compiler:register(scope, baseReg), compiler:register(scope, a7bX9))), {a7bX9}, {baseReg, a7bX9}, false);

        compiler:addStatement(compiler:setRegister(scope, retRegs[1], Ast.FunctionCallExpression(compiler:register(scope, a7bX9), args)), {retRegs[1]}, {baseReg, unpack(regs)}, true);
    end

    for i, reg in ipairs(regs) do
        compiler:freeRegister(reg, false);
    end

    return retRegs;
end

function Expressions.IndexExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns do
        if targetRegs and targetRegs[i] then
            regs[i] = targetRegs[i];
        else
            regs[i] = compiler:allocRegister();
        end

        if(i == 1) then
            -- P3: Check for hoisted nested global (e.g., table.insert)
            local hoistedVar = nil
            local base = expression.base
            local index = expression.index
            
            if base and base.kind == AstKind.VariableExpression and
               base.scope and base.scope.isGlobal and
               index and index.kind == AstKind.StringExpression then
                -- This is a nested global access like table.insert
                local baseName = base.scope:getVariableName(base.id)
                local indexName = index.value
                
                if baseName and indexName then
                    local nestedName = baseName .. "." .. indexName
                    hoistedVar = compiler:getHoistedGlobal(nestedName)
                end
            end
            
            if hoistedVar then
                -- P3: Use hoisted local variable instead of nested lookup
                scope:addReferenceToHigherScope(compiler.containerFuncScope, hoistedVar)
                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.VariableExpression(compiler.containerFuncScope, hoistedVar)), {regs[i]}, {}, false);
            else
                local baseReg = compiler:compileExpression(expression.base, funcDepth, 1)[1];

                -- OPTIMIZATION: Literal Inlining for Index
                local indexExpr, indexReg = compiler:compileOperand(scope, expression.index, funcDepth);

                local reads = {baseReg}
                if indexReg then table.insert(reads, indexReg) end

                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.IndexExpression(compiler:register(scope, baseReg), indexExpr)), {regs[i]}, reads, true);

                compiler:freeRegister(baseReg, false);
                if indexReg then compiler:freeRegister(indexReg, false) end
            end
        else
           compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

function Expressions.BinaryExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns do
        if targetRegs and targetRegs[i] then
            regs[i] = targetRegs[i];
        else
            regs[i] = compiler:allocRegister();
        end

        if(i == 1) then
            -- P5: String Concatenation Chain Optimization (a .. b .. c .. d -> table.concat({a, b, c, d}))
            -- Only apply when enabled and there are threshold+ concatenation operands
            local p5Handled = false
            if compiler.enableSpecializedPatterns and expression.kind == AstKind.StrCatExpression then
                local strCatOperands = collectStrCatOperands(expression, compiler.strCatChainThreshold)
                if strCatOperands then
                    -- Collect all operands into a table and use table.concat
                    local tableEntries = {}
                    local operandRegs = {}
                    
                    for _, operand in ipairs(strCatOperands) do
                        local opExpr, opReg = compiler:compileOperand(scope, operand, funcDepth)
                        table.insert(tableEntries, Ast.TableEntry(opExpr))
                        if opReg then table.insert(operandRegs, opReg) end
                    end
                    
                    -- Create: table.concat({operand1, operand2, ...})
                    -- We need to access table.concat via _ENV
                    local tableGlobal = Ast.IndexExpression(compiler:env(scope), Ast.StringExpression("table"))
                    local concatFunc = Ast.IndexExpression(tableGlobal, Ast.StringExpression("concat"))
                    local tableArg = Ast.TableConstructorExpression(tableEntries)
                    local callExpr = Ast.FunctionCallExpression(concatFunc, {tableArg})
                    
                    compiler:addStatement(compiler:setRegister(scope, regs[i], callExpr), {regs[i]}, operandRegs, true)
                    
                    -- Free operand registers
                    for _, opReg in ipairs(operandRegs) do
                        compiler:freeRegister(opReg, false)
                    end
                    
                    p5Handled = true
                end
            end
            
            if not p5Handled then
            -- OPTIMIZATION: Literal Inlining
            local lhsExpr, lhsReg = compiler:compileOperand(scope, expression.lhs, funcDepth);
            local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs, funcDepth);

            -- OPTIMIZATION: Arithmetic Identities
            local identityFound = false

            -- OPTIMIZATION: Operand Register Reuse
            local reused = false
            local targetReg = regs[i]

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
                    compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NumberExpression(res)), {regs[i]}, {}, false);
                    identityFound = true
                end
            end

            if not identityFound then
                if expression.kind == AstKind.AddExpression then
                    -- x + 0 -> x
                    if rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 0 then
                        compiler:addStatement(compiler:setRegister(scope, regs[i], lhsExpr), {regs[i]}, lhsReg and {lhsReg} or {}, false);
                        identityFound = true
                    -- 0 + x -> x
                    elseif lhsExpr.kind == AstKind.NumberExpression and lhsExpr.value == 0 then
                        compiler:addStatement(compiler:setRegister(scope, regs[i], rhsExpr), {regs[i]}, rhsReg and {rhsReg} or {}, false);
                        identityFound = true
                    end
                elseif expression.kind == AstKind.SubExpression then
                    -- x - 0 -> x
                    if rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 0 then
                        compiler:addStatement(compiler:setRegister(scope, regs[i], lhsExpr), {regs[i]}, lhsReg and {lhsReg} or {}, false);
                        identityFound = true
                    end
                elseif expression.kind == AstKind.MulExpression then
                    -- x * 1 -> x
                    if rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 1 then
                        compiler:addStatement(compiler:setRegister(scope, regs[i], lhsExpr), {regs[i]}, lhsReg and {lhsReg} or {}, false);
                        identityFound = true
                    -- 1 * x -> x
                    elseif lhsExpr.kind == AstKind.NumberExpression and lhsExpr.value == 1 then
                        compiler:addStatement(compiler:setRegister(scope, regs[i], rhsExpr), {regs[i]}, rhsReg and {rhsReg} or {}, false);
                        identityFound = true
                    end
                elseif expression.kind == AstKind.DivExpression then
                    -- x / 1 -> x
                    if rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 1 then
                        compiler:addStatement(compiler:setRegister(scope, regs[i], lhsExpr), {regs[i]}, lhsReg and {lhsReg} or {}, false);
                        identityFound = true
                    end
                elseif expression.kind == AstKind.PowExpression then
                    -- x ^ 1 -> x
                    if rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 1 then
                        compiler:addStatement(compiler:setRegister(scope, regs[i], lhsExpr), {regs[i]}, lhsReg and {lhsReg} or {}, false);
                        identityFound = true
                    -- x ^ 0 -> 1
                    elseif rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 0 then
                        compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NumberExpression(1)), {regs[i]}, {}, false);
                        identityFound = true
                    end
                end
            end

            -- OPTIMIZATION: Operator Strength Reduction
            if not identityFound and rhsExpr.kind == AstKind.NumberExpression and rhsExpr.value == 2 then
                if expression.kind == AstKind.MulExpression then
                    -- x * 2 -> x + x
                    local reads = lhsReg and {lhsReg} or {}
                    compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.AddExpression(lhsExpr, lhsExpr)), {regs[i]}, reads, true);
                    identityFound = true
                elseif expression.kind == AstKind.PowExpression then
                    -- x ^ 2 -> x * x
                    local reads = lhsReg and {lhsReg} or {}
                    compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.MulExpression(lhsExpr, lhsExpr)), {regs[i]}, reads, true);
                    identityFound = true
                end
            end

            if not identityFound then
                -- Attempt to reuse LHS or RHS register if they are temporary
                -- Only do this if we didn't receive a specific target register
                if not (targetRegs and targetRegs[i]) then
                        if lhsReg and compiler.registers[lhsReg] == true and lhsReg ~= compiler.POS_REGISTER and lhsReg ~= compiler.RETURN_REGISTER then
                            compiler:freeRegister(regs[i], true) -- Free the newly allocated one
                            regs[i] = lhsReg
                            targetReg = lhsReg
                            reused = true
                            -- LHS reused, don't free it later
                        elseif rhsReg and compiler.registers[rhsReg] == true and rhsReg ~= compiler.POS_REGISTER and rhsReg ~= compiler.RETURN_REGISTER then
                            compiler:freeRegister(regs[i], true)
                            regs[i] = rhsReg
                            targetReg = rhsReg
                            reused = true
                            -- RHS reused, don't free it later
                        end
                end

                local reads = {}
                if lhsReg and (not reused or lhsReg ~= targetReg) then table.insert(reads, lhsReg) end
                if rhsReg and (not reused or rhsReg ~= targetReg) then table.insert(reads, rhsReg) end

                compiler:addStatement(compiler:setRegister(scope, targetReg, Ast[expression.kind](lhsExpr, rhsExpr)), {targetReg}, reads, true);
            end

            if rhsReg and (not reused or targetReg ~= rhsReg) then compiler:freeRegister(rhsReg, false) end
            if lhsReg and (not reused or targetReg ~= lhsReg) then compiler:freeRegister(lhsReg, false) end
            end -- P5: end of if not p5Handled
        else
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

function Expressions.NotExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns do
        if targetRegs and targetRegs[i] then
            regs[i] = targetRegs[i];
        else
            regs[i] = compiler:allocRegister();
        end

        if(i == 1) then
            -- OPTIMIZATION: Boolean Logic Simplification
            -- not (not x) -> x
            if expression.rhs.kind == AstKind.NotExpression then
                local inner = expression.rhs.rhs;
                local innerExpr, innerReg = compiler:compileOperand(scope, inner, funcDepth);
                local reads = innerReg and {innerReg} or {}
                compiler:addStatement(compiler:setRegister(scope, regs[i], innerExpr), {regs[i]}, reads, false);
                if innerReg then compiler:freeRegister(innerReg, false) end
            -- not (a < b) -> a >= b
            elseif expression.rhs.kind == AstKind.LessThanExpression then
                local lhsExpr, lhsReg = compiler:compileOperand(scope, expression.rhs.lhs, funcDepth);
                local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs.rhs, funcDepth);
                local reads = {}
                if lhsReg then table.insert(reads, lhsReg) end
                if rhsReg then table.insert(reads, rhsReg) end
                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.GreaterThanOrEqualsExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                if lhsReg then compiler:freeRegister(lhsReg, false) end
                if rhsReg then compiler:freeRegister(rhsReg, false) end
            elseif expression.rhs.kind == AstKind.GreaterThanExpression then
                local lhsExpr, lhsReg = compiler:compileOperand(scope, expression.rhs.lhs, funcDepth);
                local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs.rhs, funcDepth);
                local reads = {}
                if lhsReg then table.insert(reads, lhsReg) end
                if rhsReg then table.insert(reads, rhsReg) end
                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.LessThanOrEqualsExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                if lhsReg then compiler:freeRegister(lhsReg, false) end
                if rhsReg then compiler:freeRegister(rhsReg, false) end
            elseif expression.rhs.kind == AstKind.LessThanOrEqualsExpression then
                local lhsExpr, lhsReg = compiler:compileOperand(scope, expression.rhs.lhs, funcDepth);
                local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs.rhs, funcDepth);
                local reads = {}
                if lhsReg then table.insert(reads, lhsReg) end
                if rhsReg then table.insert(reads, rhsReg) end
                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.GreaterThanExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                if lhsReg then compiler:freeRegister(lhsReg, false) end
                if rhsReg then compiler:freeRegister(rhsReg, false) end
            elseif expression.rhs.kind == AstKind.GreaterThanOrEqualsExpression then
                local lhsExpr, lhsReg = compiler:compileOperand(scope, expression.rhs.lhs, funcDepth);
                local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs.rhs, funcDepth);
                local reads = {}
                if lhsReg then table.insert(reads, lhsReg) end
                if rhsReg then table.insert(reads, rhsReg) end
                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.LessThanExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                if lhsReg then compiler:freeRegister(lhsReg, false) end
                if rhsReg then compiler:freeRegister(rhsReg, false) end
            elseif expression.rhs.kind == AstKind.EqualsExpression then
                local lhsExpr, lhsReg = compiler:compileOperand(scope, expression.rhs.lhs, funcDepth);
                local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs.rhs, funcDepth);
                local reads = {}
                if lhsReg then table.insert(reads, lhsReg) end
                if rhsReg then table.insert(reads, rhsReg) end
                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NotEqualsExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                if lhsReg then compiler:freeRegister(lhsReg, false) end
                if rhsReg then compiler:freeRegister(rhsReg, false) end
            elseif expression.rhs.kind == AstKind.NotEqualsExpression then
                local lhsExpr, lhsReg = compiler:compileOperand(scope, expression.rhs.lhs, funcDepth);
                local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs.rhs, funcDepth);
                local reads = {}
                if lhsReg then table.insert(reads, lhsReg) end
                if rhsReg then table.insert(reads, rhsReg) end
                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.EqualsExpression(lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                if lhsReg then compiler:freeRegister(lhsReg, false) end
                if rhsReg then compiler:freeRegister(rhsReg, false) end
            else
                -- Normal Not
                local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs, funcDepth);
                local reads = rhsReg and {rhsReg} or {}

                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NotExpression(rhsExpr)), {regs[i]}, reads, false);
                if rhsReg then compiler:freeRegister(rhsReg, false) end
            end
        else
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

function Expressions.NegateExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns do
        if targetRegs and targetRegs[i] then
            regs[i] = targetRegs[i];
        else
            regs[i] = compiler:allocRegister();
        end

        if(i == 1) then
            -- OPTIMIZATION: Constant Folding -(-(x)) -> x
            if expression.rhs.kind == AstKind.NegateExpression then
                local inner = expression.rhs.rhs;
                local innerExpr, innerReg = compiler:compileOperand(scope, inner, funcDepth);
                local reads = innerReg and {innerReg} or {}
                compiler:addStatement(compiler:setRegister(scope, regs[i], innerExpr), {regs[i]}, reads, true);
                if innerReg then compiler:freeRegister(innerReg, false) end
            else
                -- OPTIMIZATION: Literal Inlining
                local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs, funcDepth);
                local reads = rhsReg and {rhsReg} or {}

                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NegateExpression(rhsExpr)), {regs[i]}, reads, true);
                if rhsReg then compiler:freeRegister(rhsReg, false) end
            end
        else
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

function Expressions.LenExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns do
        if targetRegs and targetRegs[i] then
            regs[i] = targetRegs[i];
        else
            regs[i] = compiler:allocRegister();
        end

        if(i == 1) then
            -- OPTIMIZATION: Constant Folding for String Length
            if expression.rhs.kind == AstKind.StringExpression then
                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NumberExpression(#expression.rhs.value)), {regs[i]}, {}, false);
            else
                -- OPTIMIZATION: Literal Inlining
                local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs, funcDepth);
                local reads = rhsReg and {rhsReg} or {}

                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.LenExpression(rhsExpr)), {regs[i]}, reads, true);
                if rhsReg then compiler:freeRegister(rhsReg, false) end
            end
        else
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

function Expressions.OrExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local posState = compiler.registers[compiler.POS_REGISTER];
    compiler.registers[compiler.POS_REGISTER] = compiler.VAR_REGISTER;

    local regs = {};
    for i=1, numReturns do
        regs[i] = compiler:allocRegister();
        if(i ~= 1) then
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end

    local resReg = regs[1];

    -- OPTIMIZATION: Inline Or if both sides are safe (no side effects)
    if compiler:isSafeExpression(expression.lhs) and compiler:isSafeExpression(expression.rhs) then
        local lhsReg = compiler:compileExpression(expression.lhs, funcDepth, 1)[1];
        local rhsReg = compiler:compileExpression(expression.rhs, funcDepth, 1)[1];
        compiler:addStatement(compiler:setRegister(scope, resReg, Ast.OrExpression(compiler:register(scope, lhsReg), compiler:register(scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false);
        compiler:freeRegister(lhsReg, false);
        compiler:freeRegister(rhsReg, false);

        compiler.registers[compiler.POS_REGISTER] = posState;
        return regs;
    end

    local a7bX9;

    if posState then
        a7bX9 = compiler:allocRegister(false);
        compiler:addStatement(compiler:copyRegisters(scope, {a7bX9}, {compiler.POS_REGISTER}), {a7bX9}, {compiler.POS_REGISTER}, false);
    end

    local lhsReg = compiler:compileExpression(expression.lhs, funcDepth, 1)[1];
    if(expression.rhs.isConstant) then
        local rhsReg = compiler:compileExpression(expression.rhs, funcDepth, 1)[1];
        compiler:addStatement(compiler:setRegister(scope, resReg, Ast.OrExpression(compiler:register(scope, lhsReg), compiler:register(scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false);
        if a7bX9 then
            compiler:freeRegister(a7bX9, false);
        end
        compiler:freeRegister(lhsReg, false);
        compiler:freeRegister(rhsReg, false);
        return regs;
    end

    local block1, block2 = compiler:createBlock(), compiler:createBlock();
    compiler:addStatement(compiler:copyRegisters(scope, {resReg}, {lhsReg}), {resReg}, {lhsReg}, false);
    compiler:addStatement(compiler:setRegister(scope, compiler.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(compiler:register(scope, lhsReg), Ast.NumberExpression(block2.id)), Ast.NumberExpression(block1.id))), {compiler.POS_REGISTER}, {lhsReg}, false);
    compiler:freeRegister(lhsReg, false);

    do
        compiler:setActiveBlock(block1);
        local scope = block1.scope;
        local rhsReg = compiler:compileExpression(expression.rhs, funcDepth, 1)[1];
        compiler:addStatement(compiler:copyRegisters(scope, {resReg}, {rhsReg}), {resReg}, {rhsReg}, false);
        compiler:freeRegister(rhsReg, false);
        compiler:addStatement(compiler:setRegister(scope, compiler.POS_REGISTER, Ast.NumberExpression(block2.id)), {compiler.POS_REGISTER}, {}, false);
    end

    compiler.registers[compiler.POS_REGISTER] = posState;

    compiler:setActiveBlock(block2);
    scope = block2.scope;

    if a7bX9 then
        compiler:addStatement(compiler:copyRegisters(scope, {compiler.POS_REGISTER}, {a7bX9}), {compiler.POS_REGISTER}, {a7bX9}, false);
        compiler:freeRegister(a7bX9, false);
    end

    return regs;
end

function Expressions.AndExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local posState = compiler.registers[compiler.POS_REGISTER];
    compiler.registers[compiler.POS_REGISTER] = compiler.VAR_REGISTER;

    local regs = {};
    for i=1, numReturns do
        regs[i] = compiler:allocRegister();
        if(i ~= 1) then
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end

    local resReg = regs[1];

    -- OPTIMIZATION: Inline And if both sides are safe (no side effects)
    if compiler:isSafeExpression(expression.lhs) and compiler:isSafeExpression(expression.rhs) then
        local lhsReg = compiler:compileExpression(expression.lhs, funcDepth, 1)[1];
        local rhsReg = compiler:compileExpression(expression.rhs, funcDepth, 1)[1];
        compiler:addStatement(compiler:setRegister(scope, resReg, Ast.AndExpression(compiler:register(scope, lhsReg), compiler:register(scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false);
        compiler:freeRegister(lhsReg, false);
        compiler:freeRegister(rhsReg, false);

        compiler.registers[compiler.POS_REGISTER] = posState;
        return regs;
    end

    local a7bX9;

    if posState then
        a7bX9 = compiler:allocRegister(false);
        compiler:addStatement(compiler:copyRegisters(scope, {a7bX9}, {compiler.POS_REGISTER}), {a7bX9}, {compiler.POS_REGISTER}, false);
    end


    local lhsReg = compiler:compileExpression(expression.lhs, funcDepth, 1)[1];
    if(expression.rhs.isConstant) then
        local rhsReg = compiler:compileExpression(expression.rhs, funcDepth, 1)[1];
        compiler:addStatement(compiler:setRegister(scope, resReg, Ast.AndExpression(compiler:register(scope, lhsReg), compiler:register(scope, rhsReg))), {resReg}, {lhsReg, rhsReg}, false);
        if a7bX9 then
            compiler:freeRegister(a7bX9, false);
        end
        compiler:freeRegister(lhsReg, false);
        compiler:freeRegister(rhsReg, false)
        return regs;
    end


    local block1, block2 = compiler:createBlock(), compiler:createBlock();
    compiler:addStatement(compiler:copyRegisters(scope, {resReg}, {lhsReg}), {resReg}, {lhsReg}, false);
    compiler:addStatement(compiler:setRegister(scope, compiler.POS_REGISTER, Ast.OrExpression(Ast.AndExpression(compiler:register(scope, lhsReg), Ast.NumberExpression(block1.id)), Ast.NumberExpression(block2.id))), {compiler.POS_REGISTER}, {lhsReg}, false);
    compiler:freeRegister(lhsReg, false);
    do
        compiler:setActiveBlock(block1);
        scope = block1.scope;
        local rhsReg = compiler:compileExpression(expression.rhs, funcDepth, 1)[1];
        compiler:addStatement(compiler:copyRegisters(scope, {resReg}, {rhsReg}), {resReg}, {rhsReg}, false);
        compiler:freeRegister(rhsReg, false);
        compiler:addStatement(compiler:setRegister(scope, compiler.POS_REGISTER, Ast.NumberExpression(block2.id)), {compiler.POS_REGISTER}, {}, false);
    end

    compiler.registers[compiler.POS_REGISTER] = posState;

    compiler:setActiveBlock(block2);
    scope = block2.scope;

    if a7bX9 then
        compiler:addStatement(compiler:copyRegisters(scope, {compiler.POS_REGISTER}, {a7bX9}), {compiler.POS_REGISTER}, {a7bX9}, false);
        compiler:freeRegister(a7bX9, false);
    end

    return regs;
end

function Expressions.TableConstructorExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns do
        if targetRegs and targetRegs[i] then
            regs[i] = targetRegs[i];
        else
            regs[i] = compiler:allocRegister();
        end

        if(i == 1) then
            local entries = {};
            local entryRegs = {};
            for i, entry in ipairs(expression.entries) do
                if(entry.kind == AstKind.TableEntry) then
                    local value = entry.value;
                    if i == #expression.entries and (value.kind == AstKind.FunctionCallExpression or value.kind == AstKind.PassSelfFunctionCallExpression or value.kind == AstKind.VarargExpression) then
                        local reg = compiler:compileExpression(entry.value, funcDepth, compiler.RETURN_ALL)[1];
                        table.insert(entries, Ast.TableEntry(Ast.FunctionCallExpression(
                            compiler:unpack(scope),
                            {compiler:register(scope, reg)})));
                        table.insert(entryRegs, reg);
                    else
                        -- OPTIMIZATION: Inline literals/vars/safe-expressions for array part
                        local valExpr, valReg = compiler:compileOperand(scope, entry.value, funcDepth);
                        table.insert(entries, Ast.TableEntry(valExpr));
                        if valReg then table.insert(entryRegs, valReg) end
                    end
                else
                    -- OPTIMIZATION: Literal Inlining for Table Constructor Keys/Values
                    local keyExpr, keyReg = compiler:compileOperand(scope, entry.key, funcDepth);
                    local valExpr, valReg = compiler:compileOperand(scope, entry.value, funcDepth);

                    table.insert(entries, Ast.KeyedTableEntry(keyExpr, valExpr));
                    if keyReg then table.insert(entryRegs, keyReg) end
                    if valReg then table.insert(entryRegs, valReg) end
                end
            end
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.TableConstructorExpression(entries)), {regs[i]}, entryRegs, false);
            for i, reg in ipairs(entryRegs) do
                compiler:freeRegister(reg, false);
            end
        else
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

function Expressions.FunctionLiteralExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    for i=1, numReturns do
        if(i == 1) then
            regs[i] = compiler:compileFunction(expression, funcDepth);
        else
            regs[i] = compiler:allocRegister();
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

function Expressions.VarargExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    if numReturns == compiler.RETURN_ALL then
        return {compiler.varargReg};
    end
    local regs = {};
    for i=1, numReturns do
        regs[i] = compiler:allocRegister(false);
        compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.IndexExpression(compiler:register(scope, compiler.varargReg), Ast.NumberExpression(i))), {regs[i]}, {compiler.varargReg}, false);
    end
    return regs;
end

-- Register Binary Operations
local BIN_OPS = {
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

for _, op in ipairs(BIN_OPS) do
    Expressions[op] = Expressions.BinaryExpression
end

return Expressions

local Ast = require("moonstar.ast");
local AstKind = Ast.AstKind;
local logger = require("logger");
local util = require("moonstar.util");

local unpack = unpack or table.unpack;

local Expressions = {}

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

                -- OPTIMIZATION: Inline Global Name Strings
                -- Use compileOperand to allow string encryption/hoisting
                local name = expression.scope:getVariableName(expression.id)
                local nameExpr, nameReg = compiler:compileOperand(scope, Ast.StringExpression(name), funcDepth)
                local reads = nameReg and {nameReg} or {}

                compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.IndexExpression(compiler:env(scope), nameExpr)), {regs[i]}, reads, true);
                if nameReg then compiler:freeRegister(nameReg, false) end
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
            -- VUL-FIX: Unpack using explicit count (.n) to handle holes/nils
            table.insert(args, Ast.FunctionCallExpression(
                compiler:unpack(scope),
                {
                    compiler:register(scope, reg),
                    Ast.NumberExpression(1),
                    Ast.IndexExpression(compiler:register(scope, reg), Ast.StringExpression("n"))
                }));
            table.insert(regs, reg);
        else
            local argExpr, argReg = compiler:compileOperand(scope, expr, funcDepth);
            table.insert(args, argExpr);
            if argReg then table.insert(regs, argReg) end
        end
    end

    if(returnAll) then
        -- VUL-FIX: Pack result into table with .n count
        compiler:addStatement(compiler:setRegister(scope, retRegs[1], 
            Ast.FunctionCallExpression(compiler:pack(scope), {
                Ast.FunctionCallExpression(compiler:register(scope, baseReg), args)
            })
        ), {retRegs[1]}, {baseReg, unpack(regs)}, true);
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
            -- VUL-FIX: Unpack using explicit count (.n)
            table.insert(args, Ast.FunctionCallExpression(
                compiler:unpack(scope),
                {
                    compiler:register(scope, reg),
                    Ast.NumberExpression(1),
                    Ast.IndexExpression(compiler:register(scope, reg), Ast.StringExpression("n"))
                }));
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
            -- VUL-FIX: Pack result into table with .n count
            compiler:addStatement(compiler:setRegister(scope, retRegs[1], 
                Ast.FunctionCallExpression(compiler:pack(scope), {
                    Ast.FunctionCallExpression(compiler:register(scope, a7bX9), args)
                })
            ), {retRegs[1]}, {a7bX9, unpack(regs)}, true);
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
            local baseReg = compiler:compileExpression(expression.base, funcDepth, 1)[1];

            -- OPTIMIZATION: Literal Inlining for Index
            local indexExpr, indexReg = compiler:compileOperand(scope, expression.index, funcDepth);

            local reads = {baseReg}
            if indexReg then table.insert(reads, indexReg) end

            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.IndexExpression(compiler:register(scope, baseReg), indexExpr)), {regs[i]}, reads, true);

            compiler:freeRegister(baseReg, false);
            if indexReg then compiler:freeRegister(indexReg, false) end
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
            -- OPTIMIZATION: Literal Inlining
            local lhsExpr, lhsReg = compiler:compileOperand(scope, expression.lhs, funcDepth);
            local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs, funcDepth);

            -- OPTIMIZATION: Arithmetic Identities
            local identityFound = false

            -- OPTIMIZATION: Operand Register Reuse
            local reused = false
            local targetReg = regs[i]

            -- OPTIMIZATION: Constant Folding (Numeric)
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

            -- OPTIMIZATION: Constant Folding (Comparison Operations)
            -- Fold comparisons like 1 < 2 → true, "a" == "a" → true
            -- Security: Does not affect obfuscation as values are still processed normally
            if not identityFound then
                if lhsExpr.kind == AstKind.NumberExpression and rhsExpr.kind == AstKind.NumberExpression then
                    local l, r = lhsExpr.value, rhsExpr.value
                    local res
                    if expression.kind == AstKind.LessThanExpression then res = l < r
                    elseif expression.kind == AstKind.GreaterThanExpression then res = l > r
                    elseif expression.kind == AstKind.LessThanOrEqualsExpression then res = l <= r
                    elseif expression.kind == AstKind.GreaterThanOrEqualsExpression then res = l >= r
                    elseif expression.kind == AstKind.EqualsExpression then res = l == r
                    elseif expression.kind == AstKind.NotEqualsExpression then res = l ~= r
                    end
                    if res ~= nil then
                        compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.BooleanExpression(res)), {regs[i]}, {}, false);
                        identityFound = true
                    end
                elseif lhsExpr.kind == AstKind.StringExpression and rhsExpr.kind == AstKind.StringExpression then
                    local l, r = lhsExpr.value, rhsExpr.value
                    local res
                    if expression.kind == AstKind.EqualsExpression then res = l == r
                    elseif expression.kind == AstKind.NotEqualsExpression then res = l ~= r
                    end
                    if res ~= nil then
                        compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.BooleanExpression(res)), {regs[i]}, {}, false);
                        identityFound = true
                    end
                elseif lhsExpr.kind == AstKind.BooleanExpression and rhsExpr.kind == AstKind.BooleanExpression then
                    local l, r = lhsExpr.value, rhsExpr.value
                    local res
                    if expression.kind == AstKind.EqualsExpression then res = l == r
                    elseif expression.kind == AstKind.NotEqualsExpression then res = l ~= r
                    end
                    if res ~= nil then
                        compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.BooleanExpression(res)), {regs[i]}, {}, false);
                        identityFound = true
                    end
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
        else
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

-- PERF-OPT: Comparison Inversion Lookup Table
-- Maps comparison operators to their logical inverses for "not (a op b)" optimization
-- Using a lookup table instead of if-elseif chain reduces O(n) branching to O(1) lookup
-- and eliminates ~40 lines of duplicated code
local comparisonInversions = {
    [AstKind.LessThanExpression] = "GreaterThanOrEqualsExpression",
    [AstKind.GreaterThanExpression] = "LessThanOrEqualsExpression",
    [AstKind.LessThanOrEqualsExpression] = "GreaterThanExpression",
    [AstKind.GreaterThanOrEqualsExpression] = "LessThanExpression",
    [AstKind.EqualsExpression] = "NotEqualsExpression",
    [AstKind.NotEqualsExpression] = "EqualsExpression",
}

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
            else
                -- PERF-OPT: Use lookup table for comparison inversions
                -- not (a < b) -> a >= b, not (a > b) -> a <= b, etc.
                local inverseName = comparisonInversions[expression.rhs.kind]
                if inverseName then
                    local lhsExpr, lhsReg = compiler:compileOperand(scope, expression.rhs.lhs, funcDepth);
                    local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs.rhs, funcDepth);
                    local reads = {}
                    if lhsReg then table.insert(reads, lhsReg) end
                    if rhsReg then table.insert(reads, rhsReg) end
                    compiler:addStatement(compiler:setRegister(scope, regs[i], Ast[inverseName](lhsExpr, rhsExpr)), {regs[i]}, reads, true);
                    if lhsReg then compiler:freeRegister(lhsReg, false) end
                    if rhsReg then compiler:freeRegister(rhsReg, false) end
                else
                    -- Normal Not (no inversion possible)
                    local rhsExpr, rhsReg = compiler:compileOperand(scope, expression.rhs, funcDepth);
                    local reads = rhsReg and {rhsReg} or {}

                    compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NotExpression(rhsExpr)), {regs[i]}, reads, false);
                    if rhsReg then compiler:freeRegister(rhsReg, false) end
                end
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
                        -- VUL-FIX: Unpack using explicit count (.n)
                        table.insert(entries, Ast.TableEntry(Ast.FunctionCallExpression(
                            compiler:unpack(scope),
                            {
                                compiler:register(scope, reg),
                                Ast.NumberExpression(1),
                                Ast.IndexExpression(compiler:register(scope, reg), Ast.StringExpression("n"))
                            })));
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

-- OPTIMIZATION: Chained String Concatenation Flattening
-- Converts a .. b .. c .. d into table.concat({a, b, c, d})
-- This reduces output code size and improves runtime from O(n²) to O(n)
-- for chained concatenations with 3+ operands.
--
-- Performance Impact:
--   - Reduces number of VM statements for chained concats
--   - Avoids creating intermediate temporary strings
--   - Expected improvement: ~40-60% faster string concatenation in output code
--   - Expected improvement: ~20-30% smaller output for concat-heavy code

-- Helper: Recursively collect all operands from a chained StrCatExpression tree
local function collectConcatOperands(expr, operands)
    if expr.kind == AstKind.StrCatExpression then
        -- StrCat is right-associative, so we recurse into both sides
        collectConcatOperands(expr.lhs, operands)
        collectConcatOperands(expr.rhs, operands)
    else
        table.insert(operands, expr)
    end
end

function Expressions.StrCatExpression(compiler, expression, funcDepth, numReturns, targetRegs)
    local scope = compiler.activeBlock.scope;
    local regs = {};
    
    for i=1, numReturns do
        if targetRegs and targetRegs[i] then
            regs[i] = targetRegs[i];
        else
            regs[i] = compiler:allocRegister();
        end

        if(i == 1) then
            -- Collect all operands from the concatenation chain
            local operands = {}
            collectConcatOperands(expression, operands)
            
            -- OPTIMIZATION: Constant String Folding
            -- Merge adjacent string literals: "a" .. "b" .. x .. "c" → "ab" .. x .. "c"
            -- Security: Does not affect obfuscation as strings are still processed normally
            local foldedOperands = {}
            local pendingString = nil
            
            for _, op in ipairs(operands) do
                if op.kind == AstKind.StringExpression then
                    if pendingString then
                        -- Merge with previous string
                        pendingString = pendingString .. op.value
                    else
                        pendingString = op.value
                    end
                else
                    -- Flush pending string if any
                    if pendingString then
                        table.insert(foldedOperands, Ast.StringExpression(pendingString))
                        pendingString = nil
                    end
                    table.insert(foldedOperands, op)
                end
            end
            
            -- Flush final pending string
            if pendingString then
                table.insert(foldedOperands, Ast.StringExpression(pendingString))
            end
            
            operands = foldedOperands
            
            -- OPTIMIZATION: If all operands folded into one string, emit directly
            if #operands == 1 and operands[1].kind == AstKind.StringExpression then
                compiler:addStatement(
                    compiler:setRegister(scope, regs[i], Ast.StringExpression(operands[1].value)),
                    {regs[i]}, {}, false
                )
            -- OPTIMIZATION: Use table.concat for 3+ operands
            -- DISABLED: This breaks __concat metamethods (e.g. object .. " string") because table.concat
            -- requires strings/numbers and does not invoke __concat or __tostring on elements.
            -- To make this safe, we would need to ensure all operands are primitives, which is hard.
            -- elseif #operands >= 3 then
            elseif false and #operands >= 3 then
                -- Build table entries for each operand
                local entries = {}
                local entryRegs = {}
                
                for j, operand in ipairs(operands) do
                    local opExpr, opReg = compiler:compileOperand(scope, operand, funcDepth)
                    table.insert(entries, Ast.TableEntry(opExpr))
                    if opReg then table.insert(entryRegs, opReg) end
                end
                
                -- Emit: table.concat({operand1, operand2, ...})
                -- We need to access table.concat via the environment
                local tableStringReg = compiler:allocRegister(false)
                compiler:addStatement(
                    compiler:setRegister(scope, tableStringReg, Ast.StringExpression("table")),
                    {tableStringReg}, {}, false
                )
                
                local tableReg = compiler:allocRegister(false)
                compiler:addStatement(
                    compiler:setRegister(scope, tableReg, Ast.IndexExpression(compiler:env(scope), compiler:register(scope, tableStringReg))),
                    {tableReg}, {tableStringReg}, true
                )
                compiler:freeRegister(tableStringReg, false)
                
                local concatStringReg = compiler:allocRegister(false)
                compiler:addStatement(
                    compiler:setRegister(scope, concatStringReg, Ast.StringExpression("concat")),
                    {concatStringReg}, {}, false
                )
                
                local concatFuncReg = compiler:allocRegister(false)
                compiler:addStatement(
                    compiler:setRegister(scope, concatFuncReg, Ast.IndexExpression(compiler:register(scope, tableReg), compiler:register(scope, concatStringReg))),
                    {concatFuncReg}, {tableReg, concatStringReg}, false
                )
                compiler:freeRegister(tableReg, false)
                compiler:freeRegister(concatStringReg, false)
                
                -- Create the table and call concat
                compiler:addStatement(
                    compiler:setRegister(scope, regs[i], Ast.FunctionCallExpression(
                        compiler:register(scope, concatFuncReg),
                        {Ast.TableConstructorExpression(entries)}
                    )),
                    {regs[i]}, {concatFuncReg, unpack(entryRegs)}, true
                )
                
                compiler:freeRegister(concatFuncReg, false)
                for _, reg in ipairs(entryRegs) do
                    compiler:freeRegister(reg, false)
                end

            else
                -- SAFE ITERATIVE CONCATENATION
                -- Replaces table.concat strategy to respect __concat metamethods
                
                -- 1. Compile first operand
                local firstExpr, firstReg = compiler:compileOperand(scope, operands[1], funcDepth)
                
                if #operands == 1 then
                    -- Just one operand (others folded), assign directly
                    compiler:addStatement(
                        compiler:setRegister(scope, regs[i], firstExpr),
                        {regs[i]}, firstReg and {firstReg} or {}, false
                    )
                    if firstReg then compiler:freeRegister(firstReg, false) end
                else
                    -- 2. Initialize target with first operand
                    compiler:addStatement(
                        compiler:setRegister(scope, regs[i], firstExpr),
                        {regs[i]}, firstReg and {firstReg} or {}, false
                    )
                    if firstReg then compiler:freeRegister(firstReg, false) end
                    
                    -- 3. Iteratively append subsequent operands
                    for k = 2, #operands do
                         local nextExpr, nextReg = compiler:compileOperand(scope, operands[k], funcDepth)
                         local reads = {regs[i]}
                         if nextReg then table.insert(reads, nextReg) end
                         
                         -- regs[i] = regs[i] .. nextReg
                         compiler:addStatement(
                             compiler:setRegister(scope, regs[i], Ast.StrCatExpression(compiler:register(scope, regs[i]), nextExpr)),
                             {regs[i]}, reads, true
                         )
                         
                         if nextReg then compiler:freeRegister(nextReg, false) end
                    end
                end
             end
        else
            compiler:addStatement(compiler:setRegister(scope, regs[i], Ast.NilExpression()), {regs[i]}, {}, false);
        end
    end
    return regs;
end

-- Register Binary Operations
-- NOTE: StrCatExpression is NOT in BIN_OPS because it has a specialized handler above
local BIN_OPS = {
    AstKind.LessThanExpression,
    AstKind.GreaterThanExpression,
    AstKind.LessThanOrEqualsExpression,
    AstKind.GreaterThanOrEqualsExpression,
    AstKind.NotEqualsExpression,
    AstKind.EqualsExpression,
    -- AstKind.StrCatExpression removed - uses specialized handler
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

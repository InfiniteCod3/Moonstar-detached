-- conditional_fusion.lua
-- P22: Conditional Fusion (Branch Merging)
-- Detects chains of and/or comparisons and emits fused conditionals
-- to avoid allocating intermediate registers for boolean results

local Ast = require("moonstar.ast")
local AstKind = Ast.AstKind

local ConditionalFusion = {}

-- ============================================================================
-- Comparison Expression Detection
-- Check if an expression is a simple comparison that can be fused
-- ============================================================================

local isComparisonKind = {
    [AstKind.LessThanExpression] = true,
    [AstKind.GreaterThanExpression] = true,
    [AstKind.LessThanOrEqualsExpression] = true,
    [AstKind.GreaterThanOrEqualsExpression] = true,
    [AstKind.NotEqualsExpression] = true,
    [AstKind.EqualsExpression] = true,
}

function ConditionalFusion.isSimpleComparison(expr)
    return expr and isComparisonKind[expr.kind] == true
end

-- Check if an expression is safe to duplicate (no side effects)
function ConditionalFusion.isSafeOperand(expr)
    if not expr then return false end
    
    local kind = expr.kind
    
    -- Literals are always safe
    if kind == AstKind.NumberExpression or
       kind == AstKind.StringExpression or
       kind == AstKind.BooleanExpression or
       kind == AstKind.NilExpression then
        return true
    end
    
    -- Variable reads are safe
    if kind == AstKind.VariableExpression then
        return true
    end
    
    -- Negate of safe is safe
    if kind == AstKind.NegateExpression then
        return ConditionalFusion.isSafeOperand(expr.rhs)
    end
    
    -- Index expressions might have __index metamethods - not safe to duplicate
    -- Function calls have side effects - not safe
    return false
end

-- Check if a comparison has safe operands (can be evaluated without side effects)
function ConditionalFusion.isSafeComparison(expr)
    if not ConditionalFusion.isSimpleComparison(expr) then
        return false
    end
    
    return ConditionalFusion.isSafeOperand(expr.lhs) and
           ConditionalFusion.isSafeOperand(expr.rhs)
end

-- ============================================================================
-- And/Or Chain Detection
-- Detect chains like (a < b and c > d) or (a < b or c > d)
-- ============================================================================

-- Flatten an and-chain into a list of conditions
-- Returns: { condition1, condition2, ... } or nil if not a valid chain
function ConditionalFusion.flattenAndChain(expr)
    if not expr then return nil end
    
    if expr.kind == AstKind.AndExpression then
        local lhs = ConditionalFusion.flattenAndChain(expr.lhs)
        local rhs = ConditionalFusion.flattenAndChain(expr.rhs)
        
        if lhs and rhs then
            -- Merge the two lists
            for _, cond in ipairs(rhs) do
                table.insert(lhs, cond)
            end
            return lhs
        end
        return nil
    elseif ConditionalFusion.isSimpleComparison(expr) then
        return { expr }
    else
        return nil -- Not a fusable expression
    end
end

-- Flatten an or-chain into a list of conditions
-- Returns: { condition1, condition2, ... } or nil if not a valid chain
function ConditionalFusion.flattenOrChain(expr)
    if not expr then return nil end
    
    if expr.kind == AstKind.OrExpression then
        local lhs = ConditionalFusion.flattenOrChain(expr.lhs)
        local rhs = ConditionalFusion.flattenOrChain(expr.rhs)
        
        if lhs and rhs then
            for _, cond in ipairs(rhs) do
                table.insert(lhs, cond)
            end
            return lhs
        end
        return nil
    elseif ConditionalFusion.isSimpleComparison(expr) then
        return { expr }
    else
        return nil
    end
end

-- ============================================================================
-- Fused Conditional Emission
-- Emit a chain of comparisons with direct jumps (no intermediate registers)
-- ============================================================================

-- Emit a fused and-chain: all conditions must be true
-- Short-circuit: if any condition is false, jump to falseBlock
-- If all are true, jump to trueBlock
function ConditionalFusion.emitAndChain(compiler, conditions, trueBlock, falseBlock, funcDepth)
    local scope = compiler.activeBlock.scope
    
    -- For and-chains: each condition that fails jumps to falseBlock
    -- The last condition that succeeds jumps to trueBlock
    
    for i, condition in ipairs(conditions) do
        local lhsExpr, lhsReg = compiler:compileOperand(scope, condition.lhs, funcDepth)
        local rhsExpr, rhsReg = compiler:compileOperand(scope, condition.rhs, funcDepth)
        
        local reads = {}
        if lhsReg then table.insert(reads, lhsReg) end
        if rhsReg then table.insert(reads, rhsReg) end
        
        -- Reconstruct the comparison with compiled operands
        local fusedCondition = Ast[condition.kind](lhsExpr, rhsExpr)
        
        if i == #conditions then
            -- Last condition: true -> trueBlock, false -> falseBlock
            compiler:addStatement(
                compiler:setRegister(scope, compiler.POS_REGISTER,
                    Ast.OrExpression(
                        Ast.AndExpression(fusedCondition, Ast.NumberExpression(trueBlock.id)),
                        Ast.NumberExpression(falseBlock.id)
                    )
                ),
                {compiler.POS_REGISTER},
                reads,
                true
            )
        else
            -- Intermediate condition: if false -> falseBlock, otherwise continue
            -- We need to create an intermediate block for the "continue" case
            local nextCheckBlock = compiler:createBlock()
            
            compiler:addStatement(
                compiler:setRegister(scope, compiler.POS_REGISTER,
                    Ast.OrExpression(
                        Ast.AndExpression(fusedCondition, Ast.NumberExpression(nextCheckBlock.id)),
                        Ast.NumberExpression(falseBlock.id)
                    )
                ),
                {compiler.POS_REGISTER},
                reads,
                true
            )
            
            -- Move to the next check block for the following condition
            compiler:setActiveBlock(nextCheckBlock)
            scope = nextCheckBlock.scope
        end
        
        -- Free the registers used for operands
        if lhsReg then compiler:freeRegister(lhsReg, false) end
        if rhsReg then compiler:freeRegister(rhsReg, false) end
    end
end

-- Emit a fused or-chain: any condition being true succeeds
-- Short-circuit: if any condition is true, jump to trueBlock
-- If all are false, jump to falseBlock
function ConditionalFusion.emitOrChain(compiler, conditions, trueBlock, falseBlock, funcDepth)
    local scope = compiler.activeBlock.scope
    
    for i, condition in ipairs(conditions) do
        local lhsExpr, lhsReg = compiler:compileOperand(scope, condition.lhs, funcDepth)
        local rhsExpr, rhsReg = compiler:compileOperand(scope, condition.rhs, funcDepth)
        
        local reads = {}
        if lhsReg then table.insert(reads, lhsReg) end
        if rhsReg then table.insert(reads, rhsReg) end
        
        local fusedCondition = Ast[condition.kind](lhsExpr, rhsExpr)
        
        if i == #conditions then
            -- Last condition: true -> trueBlock, false -> falseBlock
            compiler:addStatement(
                compiler:setRegister(scope, compiler.POS_REGISTER,
                    Ast.OrExpression(
                        Ast.AndExpression(fusedCondition, Ast.NumberExpression(trueBlock.id)),
                        Ast.NumberExpression(falseBlock.id)
                    )
                ),
                {compiler.POS_REGISTER},
                reads,
                true
            )
        else
            -- Intermediate condition: if true -> trueBlock, otherwise continue
            local nextCheckBlock = compiler:createBlock()
            
            compiler:addStatement(
                compiler:setRegister(scope, compiler.POS_REGISTER,
                    Ast.OrExpression(
                        Ast.AndExpression(fusedCondition, Ast.NumberExpression(trueBlock.id)),
                        Ast.NumberExpression(nextCheckBlock.id)
                    )
                ),
                {compiler.POS_REGISTER},
                reads,
                true
            )
            
            compiler:setActiveBlock(nextCheckBlock)
            scope = nextCheckBlock.scope
        end
        
        if lhsReg then compiler:freeRegister(lhsReg, false) end
        if rhsReg then compiler:freeRegister(rhsReg, false) end
    end
end

-- ============================================================================
-- Main Entry Point: Try to Fuse a Condition Expression
-- Returns true if fusion was applied, false if standard path should be used
-- ============================================================================

function ConditionalFusion.tryEmitFusedConditional(compiler, condition, trueBlock, falseBlock, funcDepth)
    if not compiler.enableConditionalFusion then
        return false
    end
    
    -- Try to detect and-chains
    if condition.kind == AstKind.AndExpression then
        local andChain = ConditionalFusion.flattenAndChain(condition)
        if andChain and #andChain >= 2 then
            -- Check all conditions are safe
            local allSafe = true
            for _, cond in ipairs(andChain) do
                if not ConditionalFusion.isSafeComparison(cond) then
                    allSafe = false
                    break
                end
            end
            
            if allSafe then
                ConditionalFusion.emitAndChain(compiler, andChain, trueBlock, falseBlock, funcDepth)
                return true
            end
        end
    end
    
    -- Try to detect or-chains
    if condition.kind == AstKind.OrExpression then
        local orChain = ConditionalFusion.flattenOrChain(condition)
        if orChain and #orChain >= 2 then
            local allSafe = true
            for _, cond in ipairs(orChain) do
                if not ConditionalFusion.isSafeComparison(cond) then
                    allSafe = false
                    break
                end
            end
            
            if allSafe then
                ConditionalFusion.emitOrChain(compiler, orChain, trueBlock, falseBlock, funcDepth)
                return true
            end
        end
    end
    
    -- Not a fusable condition
    return false
end

-- ============================================================================
-- Statistics and Debugging
-- ============================================================================

function ConditionalFusion.createContext()
    return {
        fusedAndChains = 0,
        fusedOrChains = 0,
        unfusedConditions = 0,
    }
end

return ConditionalFusion

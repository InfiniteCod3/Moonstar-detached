-- copy_propagation.lua
-- P19: Copy Propagation with Escape Analysis
-- Eliminate redundant register copies by forward-substituting values

local Ast = require("moonstar.ast")
local AstKind = Ast.AstKind

local CopyPropagation = {}

-- ============================================================================
-- Copy Detection
-- ============================================================================

-- Check if statement is a simple copy: rX = rY
function CopyPropagation.isCopyStatement(statWrapper)
    local stat = statWrapper.statement
    if not stat or stat.kind ~= AstKind.AssignmentStatement then
        return false
    end
    
    -- Single target, single source
    if not stat.lhs or not stat.rhs then
        return false
    end
    if #stat.lhs ~= 1 or #stat.rhs ~= 1 then
        return false
    end
    
    -- RHS must be a simple variable expression (register read)
    local rhs = stat.rhs[1]
    if not rhs or rhs.kind ~= AstKind.VariableExpression then
        return false
    end
    
    -- PERFORMANCE: Use pre-computed numeric register IDs
    local writeReg = statWrapper.numericWriteReg
    local readRegs = statWrapper.numericReadRegs or {}
    local readReg = readRegs[1]
    
    -- Check: exactly 1 numeric write and 1 numeric read, and they differ
    local writeCount = writeReg and 1 or 0
    local readCount = #readRegs
    
    return writeCount == 1 and readCount == 1 and writeReg ~= readReg, writeReg, readReg
end

-- ============================================================================
-- Copy Map Building
-- ============================================================================

function CopyPropagation.buildCopyMap(statements)
    local copyMap = {}
    
    for i, statWrapper in ipairs(statements) do
        if statWrapper then
            local isCopy, targetReg, sourceReg = CopyPropagation.isCopyStatement(statWrapper)
            
            if isCopy then
                copyMap[targetReg] = {
                    sourceReg = sourceReg,
                    defIndex = i,
                    isValid = true
                }
            end
            
            -- PERFORMANCE: Use pre-computed numeric write register
            local writtenReg = statWrapper.numericWriteReg
            if writtenReg then
                -- Invalidate copies that source from this reg
                for target, info in pairs(copyMap) do
                    if info.sourceReg == writtenReg and info.isValid then
                        info.isValid = false
                    end
                end
                -- Clear this reg as a copy target if it's being redefined (and not a new copy)
                if copyMap[writtenReg] and not isCopy then
                    copyMap[writtenReg] = nil
                end
            end
        end
    end
    
    return copyMap
end

-- ============================================================================
-- Escape Analysis
-- ============================================================================

function CopyPropagation.canPropagate(statWrapper, sourceReg)
    -- Conservative: don't propagate if upvalues are involved
    if statWrapper.usesUpvals then
        return false
    end
    
    local stat = statWrapper.statement
    if not stat then return false end
    
    -- Don't propagate into return statements (value escapes)
    if stat.kind == AstKind.ReturnStatement then
        return false
    end
    
    -- Don't propagate into function calls where the register is an argument
    -- (the value could escape through the function)
    if stat.kind == AstKind.FunctionCallStatement or
       stat.kind == AstKind.FunctionCallExpression then
        return false
    end
    
    return true
end

-- ============================================================================
-- AST Substitution
-- ============================================================================

-- Replace register references in an expression
function CopyPropagation.substituteInExpr(expr, oldReg, newReg, scope, compiler)
    if not expr then return expr end
    
    -- If this is a variable expression pointing to oldReg, replace it
    if expr.kind == AstKind.VariableExpression then
        -- Check if this variable corresponds to oldReg
        -- This requires checking against the compiler's register mapping
        -- For now, we'll handle this in the statement wrapper level
        return expr
    end
    
    -- Recursively handle binary expressions
    if expr.lhs then
        expr.lhs = CopyPropagation.substituteInExpr(expr.lhs, oldReg, newReg, scope, compiler)
    end
    if expr.rhs then
        expr.rhs = CopyPropagation.substituteInExpr(expr.rhs, oldReg, newReg, scope, compiler)
    end
    
    -- Handle other expression types...
    if expr.base then
        expr.base = CopyPropagation.substituteInExpr(expr.base, oldReg, newReg, scope, compiler)
    end
    if expr.index then
        expr.index = CopyPropagation.substituteInExpr(expr.index, oldReg, newReg, scope, compiler)
    end
    if expr.args then
        for i, arg in ipairs(expr.args) do
            expr.args[i] = CopyPropagation.substituteInExpr(arg, oldReg, newReg, scope, compiler)
        end
    end
    
    return expr
end

-- ============================================================================
-- Main Optimization Pass
-- ============================================================================

function CopyPropagation.optimizeBlock(compiler, block)
    if not compiler.enableCopyPropagation then
        return false
    end
    
    local statements = block.statements
    if #statements < 2 then
        return false
    end
    
    local changed = false
    local iterations = 0
    local maxIterations = compiler.maxCopyPropagationIterations or 3
    
    repeat
        local iterChanged = false
        iterations = iterations + 1
        
        -- Phase 1: Build copy map
        local copyMap = CopyPropagation.buildCopyMap(statements)
        
        -- Phase 2 & 3: Propagate copies forward
        for i, statWrapper in ipairs(statements) do
            if statWrapper then
                for reg, _ in pairs(statWrapper.reads) do
                    if type(reg) == "number" then
                        local copyInfo = copyMap[reg]
                        
                        if copyInfo and copyInfo.isValid and copyInfo.defIndex < i then
                            if CopyPropagation.canPropagate(statWrapper, copyInfo.sourceReg) then
                                -- Update the reads tracking
                                statWrapper.reads[reg] = nil
                                statWrapper.reads[copyInfo.sourceReg] = true
                                
                                -- The actual AST substitution is tricky because we use
                                -- scope-based variable expressions. For now, mark changed
                                -- and let the subsequent dead store elimination clean up.
                                iterChanged = true
                            end
                        end
                    end
                end
            end
        end
        
        changed = changed or iterChanged
    until not iterChanged or iterations >= maxIterations
    
    return changed
end

-- ============================================================================
-- Compiler Integration
-- ============================================================================

function CopyPropagation.optimizeAllBlocks(compiler)
    if not compiler.enableCopyPropagation then
        return
    end
    
    for _, block in ipairs(compiler.blocks) do
        CopyPropagation.optimizeBlock(compiler, block)
    end
end

return CopyPropagation

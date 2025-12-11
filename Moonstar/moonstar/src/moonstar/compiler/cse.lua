-- cse.lua
-- P14: Common Subexpression Elimination (CSE)
-- Reuse previously computed expression results to avoid redundant computation
-- These optimizations are applied after block generation but before VM emission

local Ast = require("moonstar.ast");
local AstKind = Ast.AstKind;

local CSE = {}

-- ============================================================================
-- Expression Hashing
-- Create a canonical hash of an expression structure for comparison
-- PERFORMANCE: Memoize hashes on AST nodes and use table.concat to reduce GC
-- ============================================================================

-- PERFORMANCE: Cache for kind-to-string conversion (avoid repeated tostring calls)
local kindStringCache = {}
local function getKindString(kind)
    local cached = kindStringCache[kind]
    if cached then return cached end
    cached = tostring(kind)
    kindStringCache[kind] = cached
    return cached
end

-- ============================================================================
-- PERFORMANCE: Pre-computed lookup tables for O(1) side-effect detection
-- These replace O(n) conditional chains in hasSideEffects() for faster checks
-- ============================================================================

-- Expressions that never have side effects (pure literals and variable reads)
local noSideEffectsKinds = {
    [AstKind.NumberExpression] = true,
    [AstKind.StringExpression] = true,
    [AstKind.BooleanExpression] = true,
    [AstKind.NilExpression] = true,
    [AstKind.VariableExpression] = true,
}

-- Binary expressions: need to check both operands for side effects
local binaryExprKinds = {
    [AstKind.AddExpression] = true,
    [AstKind.SubExpression] = true,
    [AstKind.MulExpression] = true,
    [AstKind.DivExpression] = true,
    [AstKind.ModExpression] = true,
    [AstKind.PowExpression] = true,
    [AstKind.StrCatExpression] = true,
    [AstKind.LessThanExpression] = true,
    [AstKind.GreaterThanExpression] = true,
    [AstKind.LessThanOrEqualsExpression] = true,
    [AstKind.GreaterThanOrEqualsExpression] = true,
    [AstKind.EqualsExpression] = true,
    [AstKind.NotEqualsExpression] = true,
    [AstKind.AndExpression] = true,
    [AstKind.OrExpression] = true,
}

-- Unary expressions: need to check the operand for side effects
local unaryExprKinds = {
    [AstKind.NotExpression] = true,
    [AstKind.NegateExpression] = true,
    [AstKind.LenExpression] = true,
}

-- Generate a canonical string representation of an expression for hashing
-- PERFORMANCE: Memoize result on AST node to avoid recomputation
function CSE.hashExpression(expr)
    if not expr then return nil end
    
    -- PERFORMANCE: Check memoized hash first
    if expr._cseHash ~= nil then
        return expr._cseHash  -- nil means "computed as unhashable", false means "not computed"
    end
    
    local kind = expr.kind
    local result = nil
    
    -- Literals: hash by value (simple concatenation is fine for 2-part strings)
    if kind == AstKind.NumberExpression then
        result = "NUM:" .. tostring(expr.value)
    elseif kind == AstKind.StringExpression then
        result = "STR:" .. expr.value
    elseif kind == AstKind.BooleanExpression then
        result = "BOOL:" .. tostring(expr.value)
    elseif kind == AstKind.NilExpression then
        result = "NIL"
    
    -- Variable expressions: hash by scope and id
    elseif kind == AstKind.VariableExpression then
        -- PERFORMANCE: Use table.concat for 5-part string
        local scopeId = tostring(expr.scope) or "?"
        local varId = tostring(expr.id) or "?"
        result = table.concat({"VAR:", scopeId, ":", varId})
    
    -- PERFORMANCE: O(1) lookup instead of O(n) conditional chain for binary expressions
    -- Uses the pre-computed binaryExprKinds table to avoid ~15 conditional checks per call
    elseif binaryExprKinds[kind] then
        local lhsHash = CSE.hashExpression(expr.lhs)
        local rhsHash = CSE.hashExpression(expr.rhs)
        if lhsHash and rhsHash then
            -- PERFORMANCE: Use table.concat for 5-part string
            result = table.concat({getKindString(kind), "(", lhsHash, ",", rhsHash, ")"})
        end
    
    -- PERFORMANCE: O(1) lookup instead of O(n) conditional chain for unary expressions
    -- Uses the pre-computed unaryExprKinds table to avoid ~3 conditional checks per call
    elseif unaryExprKinds[kind] then
        local rhsHash = CSE.hashExpression(expr.rhs)
        if rhsHash then
            result = table.concat({getKindString(kind), "(", rhsHash, ")"})
        end
    
    -- Index expressions
    elseif kind == AstKind.IndexExpression then
        local baseHash = CSE.hashExpression(expr.base)
        local indexHash = CSE.hashExpression(expr.index)
        if baseHash and indexHash then
            result = table.concat({"IDX(", baseHash, ",", indexHash, ")"})
        end
    end
    
    -- Function calls, table constructors, etc. are NOT eligible for CSE
    -- (side effects or unique values) - result stays nil
    
    -- PERFORMANCE: Memoize result (including nil for unhashable expressions)
    expr._cseHash = result
    return result
end

-- Clear memoized hashes when AST is mutated (call after peephole or other passes modify AST)
function CSE.invalidateHashes(statements)
    if not statements then return end
    for _, statWrapper in ipairs(statements) do
        local stat = statWrapper and statWrapper.statement
        if stat then
            CSE.invalidateExprHashes(stat)
        end
    end
end

-- Recursively clear hash from an expression and its children
function CSE.invalidateExprHashes(node)
    if not node then return end
    node._cseHash = nil
    if node.lhs then CSE.invalidateExprHashes(node.lhs) end
    if node.rhs then CSE.invalidateExprHashes(node.rhs) end
    if node.base then CSE.invalidateExprHashes(node.base) end
    if node.index then CSE.invalidateExprHashes(node.index) end
end

-- ============================================================================
-- Side Effect Detection
-- Check if an expression has side effects (rendering it ineligible for CSE)
-- ============================================================================

function CSE.hasSideEffects(expr)
    if not expr then return true end
    
    local kind = expr.kind
    
    -- PERFORMANCE: O(1) lookup instead of O(n) conditional chain
    -- Pure expressions (literals, variable reads) have no side effects
    if noSideEffectsKinds[kind] then
        return false
    end
    
    -- Binary expressions: check both operands (recursive)
    if binaryExprKinds[kind] then
        return CSE.hasSideEffects(expr.lhs) or CSE.hasSideEffects(expr.rhs)
    end
    
    -- Unary expressions: check the operand (recursive)
    if unaryExprKinds[kind] then
        return CSE.hasSideEffects(expr.rhs)
    end
    
    -- All other expressions (function calls, table constructors, index expressions, etc.)
    -- are assumed to have side effects or create unique values
    return true
end

-- ============================================================================
-- Check if an expression reads from a specific register
-- ============================================================================

function CSE.readsRegister(expr, targetReg, scope)
    if not expr then return false end
    
    local kind = expr.kind
    
    -- Variable expressions might read the target register
    if kind == AstKind.VariableExpression then
        -- This is complex because we need to know the register mapping
        -- For now, we'll rely on the statement wrapper's reads info
        return false
    end
    
    -- Check recursively for compound expressions
    if expr.lhs and CSE.readsRegister(expr.lhs, targetReg, scope) then
        return true
    end
    if expr.rhs and CSE.readsRegister(expr.rhs, targetReg, scope) then
        return true
    end
    if expr.base and CSE.readsRegister(expr.base, targetReg, scope) then
        return true
    end
    if expr.index and CSE.readsRegister(expr.index, targetReg, scope) then
        return true
    end
    
    return false
end

-- ============================================================================
-- Find and eliminate common subexpressions within a block
-- ============================================================================

function CSE.optimizeBlock(compiler, block)
    if not compiler.enableCSE then
        return false
    end
    
    local statements = block.statements
    if #statements < 2 then
        return false
    end
    
    local changed = false
    
    -- Map: expression hash -> { firstReg, firstIndex, isValid }
    local exprMap = {}
    
    -- Track which registers have been invalidated (written to)
    local invalidatedRegs = {}
    
    for i, statWrapper in ipairs(statements) do
        local stat = statWrapper.statement
        
        -- First, invalidate expressions that depend on registers being written to
        for reg, _ in pairs(statWrapper.writes) do
            if type(reg) == "number" then
                invalidatedRegs[reg] = i
            end
        end
        
        -- Only process simple assignments
        if stat.kind == AstKind.AssignmentStatement and
           #stat.lhs == 1 and #stat.rhs == 1 then
            
            local rhsExpr = stat.rhs[1]
            
            -- Skip if expression has side effects
            if not CSE.hasSideEffects(rhsExpr) and not statWrapper.usesUpvals then
                local hash = CSE.hashExpression(rhsExpr)
                
                if hash then
                    local existing = exprMap[hash]
                    
                    if existing and existing.isValid then
                        -- Check if the source register is still valid
                        local sourceReg = existing.firstReg
                        local sourceIndex = existing.firstIndex
                        
                        -- Check if source register was invalidated after it was set
                        local sourceInvalidated = invalidatedRegs[sourceReg] and
                                                   invalidatedRegs[sourceReg] > sourceIndex
                        
                        if not sourceInvalidated then
                            -- Check if any register read by the original expression was
                            -- modified between the original and this occurrence
                            local dependencyInvalidated = false
                            -- PERFORMANCE: Use pre-computed numeric read registers
                            local originalWrapper = statements[sourceIndex]
                            local originalNumericReads = originalWrapper.numericReadRegs or {}
                            
                            for _, reg in ipairs(originalNumericReads) do
                                local invalidationIndex = invalidatedRegs[reg]
                                if invalidationIndex and
                                   invalidationIndex > sourceIndex and
                                   invalidationIndex <= i then
                                    dependencyInvalidated = true
                                    break
                                end
                            end
                            
                            if not dependencyInvalidated then
                                -- We can reuse the previous computation!
                                -- Get the target register for this statement
                                -- PERFORMANCE: Use pre-computed numeric write register
                                local targetReg = statWrapper.numericWriteReg
                                
                                if targetReg and targetReg ~= sourceReg then
                                    -- Replace the RHS with a register read
                                    -- Create a new assignment that copies from the cached register
                                    local scope = block.scope
                                    
                                    -- We need to create a VariableExpression that reads the source register
                                    -- This depends on how registers are represented in the AST
                                    -- For now, we'll use the compiler's register() method pattern
                                    
                                    -- Update reads to only include source register
                                    statWrapper.reads = { [sourceReg] = true }
                                    
                                    -- Create new RHS that reads from source register
                                    -- We need access to the compiler's register variable mapping
                                    if compiler.registerVars[sourceReg] then
                                        local regVar = compiler.registerVars[sourceReg]
                                        local regScope = compiler.containerFuncScope
                                        
                                        -- Update the statement's RHS to be a copy
                                        stat.rhs[1] = Ast.VariableExpression(regScope, regVar)
                                        scope:addReferenceToHigherScope(regScope, regVar)
                                        
                                        changed = true
                                    end
                                end
                            end
                        end
                    else
                        -- First occurrence of this expression
                        -- PERFORMANCE: Use pre-computed numeric write register
                        local targetReg = statWrapper.numericWriteReg
                        
                        if targetReg then
                            exprMap[hash] = {
                                firstReg = targetReg,
                                firstIndex = i,
                                isValid = true
                            }
                        end
                    end
                end
            end
        end
    end
    
    return changed
end

-- ============================================================================
-- Optimize all blocks in the compiler
-- ============================================================================

function CSE.optimizeAllBlocks(compiler, maxIterations)
    if not compiler.enableCSE then
        return
    end
    
    maxIterations = maxIterations or 3
    
    local totalOptimizations = 0
    
    for iter = 1, maxIterations do
        local changed = false
        
        for _, block in ipairs(compiler.blocks) do
            if CSE.optimizeBlock(compiler, block) then
                changed = true
                totalOptimizations = totalOptimizations + 1
            end
        end
        
        if not changed then
            break
        end
    end
    
    return totalOptimizations
end

-- ============================================================================
-- Local CSE within expression compilation
-- Track computed expressions during a single expression compilation
-- This is more fine-grained than block-level CSE
-- ============================================================================

-- Create a new CSE context for tracking expressions during compilation
function CSE.createContext()
    return {
        expressions = {}, -- hash -> register
        enabled = true
    }
end

-- Try to find a cached result for an expression
function CSE.findCached(context, expr)
    if not context or not context.enabled then
        return nil
    end
    
    local hash = CSE.hashExpression(expr)
    if hash then
        return context.expressions[hash]
    end
    return nil
end

-- Cache the result of an expression computation
function CSE.cacheResult(context, expr, register)
    if not context or not context.enabled then
        return
    end
    
    -- Don't cache expressions with side effects
    if CSE.hasSideEffects(expr) then
        return
    end
    
    local hash = CSE.hashExpression(expr)
    if hash then
        context.expressions[hash] = register
    end
end

-- Invalidate cached expressions that depend on a modified register
function CSE.invalidateRegister(context, register)
    if not context or not context.enabled then
        return
    end
    
    -- For now, we do a simple invalidation by clearing entries
    -- that might depend on this register
    -- A more sophisticated approach would track dependencies
    
    -- This is conservative: we could track which hashes depend on which registers
    -- For now, invalidate everything when any register changes
    -- (This is overly conservative but safe)
    context.expressions = {}
end

return CSE

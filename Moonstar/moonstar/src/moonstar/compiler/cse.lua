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
-- ============================================================================

-- Generate a canonical string representation of an expression for hashing
function CSE.hashExpression(expr)
    if not expr then return nil end
    
    local kind = expr.kind
    
    -- Literals: hash by value
    if kind == AstKind.NumberExpression then
        return "NUM:" .. tostring(expr.value)
    elseif kind == AstKind.StringExpression then
        return "STR:" .. expr.value
    elseif kind == AstKind.BooleanExpression then
        return "BOOL:" .. tostring(expr.value)
    elseif kind == AstKind.NilExpression then
        return "NIL"
    end
    
    -- Variable expressions: hash by scope and id
    if kind == AstKind.VariableExpression then
        -- Use a unique identifier for the variable
        local scopeId = tostring(expr.scope) or "?"
        local varId = tostring(expr.id) or "?"
        return "VAR:" .. scopeId .. ":" .. varId
    end
    
    -- Binary expressions: hash by kind and operand hashes
    if kind == AstKind.AddExpression or
       kind == AstKind.SubExpression or
       kind == AstKind.MulExpression or
       kind == AstKind.DivExpression or
       kind == AstKind.ModExpression or
       kind == AstKind.PowExpression or
       kind == AstKind.StrCatExpression or
       kind == AstKind.LessThanExpression or
       kind == AstKind.GreaterThanExpression or
       kind == AstKind.LessThanOrEqualsExpression or
       kind == AstKind.GreaterThanOrEqualsExpression or
       kind == AstKind.EqualsExpression or
       kind == AstKind.NotEqualsExpression then
        local lhsHash = CSE.hashExpression(expr.lhs)
        local rhsHash = CSE.hashExpression(expr.rhs)
        if lhsHash and rhsHash then
            return tostring(kind) .. "(" .. lhsHash .. "," .. rhsHash .. ")"
        end
        return nil
    end
    
    -- And/Or expressions
    if kind == AstKind.AndExpression or kind == AstKind.OrExpression then
        local lhsHash = CSE.hashExpression(expr.lhs)
        local rhsHash = CSE.hashExpression(expr.rhs)
        if lhsHash and rhsHash then
            return tostring(kind) .. "(" .. lhsHash .. "," .. rhsHash .. ")"
        end
        return nil
    end
    
    -- Unary expressions: hash by kind and operand hash
    if kind == AstKind.NotExpression or
       kind == AstKind.NegateExpression or
       kind == AstKind.LenExpression then
        local rhsHash = CSE.hashExpression(expr.rhs)
        if rhsHash then
            return tostring(kind) .. "(" .. rhsHash .. ")"
        end
        return nil
    end
    
    -- Index expressions
    if kind == AstKind.IndexExpression then
        local baseHash = CSE.hashExpression(expr.base)
        local indexHash = CSE.hashExpression(expr.index)
        if baseHash and indexHash then
            return "IDX(" .. baseHash .. "," .. indexHash .. ")"
        end
        return nil
    end
    
    -- Function calls, table constructors, etc. are NOT eligible for CSE
    -- (side effects or unique values)
    return nil
end

-- ============================================================================
-- Side Effect Detection
-- Check if an expression has side effects (rendering it ineligible for CSE)
-- ============================================================================

function CSE.hasSideEffects(expr)
    if not expr then return true end
    
    local kind = expr.kind
    
    -- Literals have no side effects
    if kind == AstKind.NumberExpression or
       kind == AstKind.StringExpression or
       kind == AstKind.BooleanExpression or
       kind == AstKind.NilExpression then
        return false
    end
    
    -- Variable reads have no side effects
    if kind == AstKind.VariableExpression then
        return false
    end
    
    -- Binary and unary expressions: check operands
    if kind == AstKind.AddExpression or
       kind == AstKind.SubExpression or
       kind == AstKind.MulExpression or
       kind == AstKind.DivExpression or
       kind == AstKind.ModExpression or
       kind == AstKind.PowExpression or
       kind == AstKind.StrCatExpression or
       kind == AstKind.LessThanExpression or
       kind == AstKind.GreaterThanExpression or
       kind == AstKind.LessThanOrEqualsExpression or
       kind == AstKind.GreaterThanOrEqualsExpression or
       kind == AstKind.EqualsExpression or
       kind == AstKind.NotEqualsExpression or
       kind == AstKind.AndExpression or
       kind == AstKind.OrExpression then
        return CSE.hasSideEffects(expr.lhs) or CSE.hasSideEffects(expr.rhs)
    end
    
    if kind == AstKind.NotExpression or
       kind == AstKind.NegateExpression or
       kind == AstKind.LenExpression then
        return CSE.hasSideEffects(expr.rhs)
    end
    
    -- Index expressions might have side effects via __index metamethod
    -- For safety, we treat them as having potential side effects
    if kind == AstKind.IndexExpression then
        return true
    end
    
    -- Function calls always have potential side effects
    if kind == AstKind.FunctionCallExpression or
       kind == AstKind.PassSelfFunctionCallExpression then
        return true
    end
    
    -- Table constructors don't have side effects but create unique values
    -- so they shouldn't be CSE'd
    if kind == AstKind.TableConstructorExpression then
        return true
    end
    
    -- Default: assume side effects
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
                            local originalReads = statements[sourceIndex].reads
                            
                            for reg, _ in pairs(originalReads) do
                                if type(reg) == "number" then
                                    local invalidationIndex = invalidatedRegs[reg]
                                    if invalidationIndex and
                                       invalidationIndex > sourceIndex and
                                       invalidationIndex <= i then
                                        dependencyInvalidated = true
                                        break
                                    end
                                end
                            end
                            
                            if not dependencyInvalidated then
                                -- We can reuse the previous computation!
                                -- Get the target register for this statement
                                local targetReg = nil
                                for reg, _ in pairs(statWrapper.writes) do
                                    if type(reg) == "number" then
                                        targetReg = reg
                                        break
                                    end
                                end
                                
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
                        local targetReg = nil
                        for reg, _ in pairs(statWrapper.writes) do
                            if type(reg) == "number" then
                                targetReg = reg
                                break
                            end
                        end
                        
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

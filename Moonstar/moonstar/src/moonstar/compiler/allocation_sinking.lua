-- allocation_sinking.lua
-- P20: Allocation Sinking - Defer/eliminate memory allocations
-- Reduces GC pressure by removing dead allocations and sinking live ones closer to first use

local Ast = require("moonstar.ast")
local AstKind = Ast.AstKind

local AllocationSinking = {}

-- ============================================================================
-- Allocation Detection
-- ============================================================================

function AllocationSinking.isAllocation(expr)
    if not expr then return false end
    return expr.kind == AstKind.TableConstructorExpression or
           expr.kind == AstKind.FunctionLiteralExpression
end

function AllocationSinking.isTableAllocation(expr)
    return expr and expr.kind == AstKind.TableConstructorExpression
end

function AllocationSinking.isClosureAllocation(expr)
    return expr and expr.kind == AstKind.FunctionLiteralExpression
end

-- Find all allocations in a block
function AllocationSinking.findAllocations(block)
    local allocations = {}
    
    for i, statWrapper in ipairs(block.statements) do
        local stat = statWrapper.statement
        if stat then
            if stat.kind == AstKind.AssignmentStatement then
                for j, rhs in ipairs(stat.rhs or {}) do
                    if AllocationSinking.isAllocation(rhs) then
                        -- Find target register
                        local targetReg = nil
                        for reg, _ in pairs(statWrapper.writes) do
                            if type(reg) == "number" then
                                targetReg = reg
                                break
                            end
                        end
                        
                        if targetReg then
                            table.insert(allocations, {
                                statIndex = i,
                                rhsIndex = j,
                                targetReg = targetReg,
                                expr = rhs,
                                isTable = AllocationSinking.isTableAllocation(rhs),
                                isClosure = AllocationSinking.isClosureAllocation(rhs),
                                entries = rhs.entries, -- For tables
                            })
                        end
                    end
                end
            end
        end
    end
    
    return allocations
end

-- ============================================================================
-- Escape Analysis
-- ============================================================================

function AllocationSinking.doesEscape(alloc, statements)
    local reg = alloc.targetReg
    
    for i = alloc.statIndex + 1, #statements do
        local statWrapper = statements[i]
        if statWrapper then
            -- Check if this statement reads our register
            if statWrapper.reads[reg] then
                local stat = statWrapper.statement
                if stat then
                    -- Escape via return
                    if stat.kind == AstKind.ReturnStatement then
                        return true, "return"
                    end
                    
                    -- Escape via upvalue capture
                    if statWrapper.usesUpvals then
                        return true, "upvalue"
                    end
                    
                    -- Escape via function call (passed as argument)
                    if stat.kind == AstKind.FunctionCallStatement or
                       stat.kind == AstKind.FunctionCallExpression then
                        return true, "function_call"
                    end
                end
            end
        end
    end
    
    return false, nil
end

-- ============================================================================
-- Usage Analysis
-- ============================================================================

function AllocationSinking.analyzeUsage(alloc, statements)
    local reg = alloc.targetReg
    
    local usage = {
        readCount = 0,
        writeCount = 0,
        firstUseIndex = nil,
        lastUseIndex = nil,
        isUsed = false,
    }
    
    for i = alloc.statIndex + 1, #statements do
        local statWrapper = statements[i]
        if statWrapper then
            if statWrapper.reads[reg] then
                usage.readCount = usage.readCount + 1
                usage.isUsed = true
                usage.lastUseIndex = i
                if not usage.firstUseIndex then
                    usage.firstUseIndex = i
                end
            end
            
            if statWrapper.writes[reg] then
                usage.writeCount = usage.writeCount + 1
            end
        end
    end
    
    return usage
end

-- ============================================================================
-- Optimization Transformations
-- ============================================================================

-- Check if an expression is pure (no side effects)
function AllocationSinking.isExpressionPure(expr)
    if not expr then return true end
    
    local kind = expr.kind
    
    -- Literals are pure
    if kind == AstKind.NumberExpression or
       kind == AstKind.StringExpression or
       kind == AstKind.BooleanExpression or
       kind == AstKind.NilExpression then
        return true
    end
    
    -- Variable reads are pure
    if kind == AstKind.VariableExpression then
        return true
    end
    
    -- Function calls are NOT pure
    if kind == AstKind.FunctionCallExpression or
       kind == AstKind.PassSelfFunctionCallExpression then
        return false
    end
    
    -- Binary/unary ops are pure if operands are pure
    if expr.lhs and not AllocationSinking.isExpressionPure(expr.lhs) then
        return false
    end
    if expr.rhs and not AllocationSinking.isExpressionPure(expr.rhs) then
        return false
    end
    
    return true
end

-- Check if an allocation has side effects
function AllocationSinking.isAllocationPure(alloc)
    if alloc.isClosure then
        -- Closures are pure (no side effects on creation)
        return true
    end
    
    if alloc.isTable then
        -- Table is pure if all entries are pure expressions
        local entries = alloc.entries or {}
        for _, entry in ipairs(entries) do
            if entry.value then
                if not AllocationSinking.isExpressionPure(entry.value) then
                    return false
                end
            end
            -- Also check key expressions for keyed entries
            if entry.key then
                if not AllocationSinking.isExpressionPure(entry.key) then
                    return false
                end
            end
        end
        return true
    end
    
    return false
end

-- Pattern B: Remove dead allocations
function AllocationSinking.removeDeadAllocations(compiler, block)
    local statements = block.statements
    local allocations = AllocationSinking.findAllocations(block)
    local removed = 0
    
    -- Process in reverse order to maintain proper indices
    local toRemove = {}
    
    for _, alloc in ipairs(allocations) do
        local usage = AllocationSinking.analyzeUsage(alloc, statements)
        
        if not usage.isUsed then
            -- This allocation is never used - check if it's pure
            local isPure = AllocationSinking.isAllocationPure(alloc)
            
            if isPure then
                table.insert(toRemove, alloc.statIndex)
            end
        end
    end
    
    -- Sort in descending order to remove from end first
    table.sort(toRemove, function(a, b) return a > b end)
    
    for _, idx in ipairs(toRemove) do
        if statements[idx] then
            table.remove(statements, idx)
            removed = removed + 1
        end
    end
    
    return removed > 0
end

-- Pattern A: Sink allocation closer to first use
function AllocationSinking.sinkToFirstUse(compiler, block)
    local statements = block.statements
    local allocations = AllocationSinking.findAllocations(block)
    local changed = false
    
    for _, alloc in ipairs(allocations) do
        local usage = AllocationSinking.analyzeUsage(alloc, statements)
        local escapes, _ = AllocationSinking.doesEscape(alloc, statements)
        
        -- Only sink non-escaping allocations
        if not escapes then
            -- Check if we can sink (first use is more than 1 statement away)
            if usage.firstUseIndex and usage.firstUseIndex > alloc.statIndex + 1 then
                local canSink = true
                
                -- Ensure no reads of the target register between alloc and first use
                for i = alloc.statIndex + 1, usage.firstUseIndex - 1 do
                    local statWrapper = statements[i]
                    if statWrapper and statWrapper.reads[alloc.targetReg] then
                        canSink = false
                        break
                    end
                end
                
                if canSink then
                    -- Move allocation just before first use
                    local allocStat = table.remove(statements, alloc.statIndex)
                    -- Adjust for removal (index shifts down by 1)
                    local newIndex = usage.firstUseIndex - 1
                    table.insert(statements, newIndex, allocStat)
                    changed = true
                    -- After modifying, we should break and restart since indices changed
                    break
                end
            end
        end
    end
    
    return changed
end

-- ============================================================================
-- Main Optimization Pass
-- ============================================================================

function AllocationSinking.optimizeBlock(compiler, block)
    if not compiler.enableAllocationSinking then
        return false
    end
    
    local changed = false
    
    -- Phase 1: Remove dead allocations
    if AllocationSinking.removeDeadAllocations(compiler, block) then
        changed = true
    end
    
    -- Phase 2: Sink remaining allocations (iterate until no more changes)
    local sinkChanged = true
    local maxIterations = 10
    local iterations = 0
    
    while sinkChanged and iterations < maxIterations do
        iterations = iterations + 1
        sinkChanged = AllocationSinking.sinkToFirstUse(compiler, block)
        if sinkChanged then
            changed = true
        end
    end
    
    return changed
end

function AllocationSinking.optimizeAllBlocks(compiler)
    if not compiler.enableAllocationSinking then
        return
    end
    
    for _, block in ipairs(compiler.blocks) do
        AllocationSinking.optimizeBlock(compiler, block)
    end
end

return AllocationSinking

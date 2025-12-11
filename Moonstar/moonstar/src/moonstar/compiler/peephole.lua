-- peephole.lua
-- P11: Peephole Optimization Pass
-- Apply local pattern optimizations to instruction sequences
-- These optimizations are applied after block generation but before VM emission

local Ast = require("moonstar.ast");
local AstKind = Ast.AstKind;

local Peephole = {}

-- Configuration defaults
local DEFAULT_MAX_ITERATIONS = 5

-- ============================================================================
-- Pattern 1: Remove Redundant Copies (r1 = r2; r3 = r1 → r3 = r2 if r1 unused)
-- ============================================================================
function Peephole.removeRedundantCopies(compiler, statements)
    local changed = false
    local i = 1
    -- PERFORMANCE: Cache statement count to avoid repeated # operator
    local numStatements = #statements
    
    while i <= numStatements do
        local statWrapper = statements[i]
        local stat = statWrapper and statWrapper.statement
        
        -- Check if this is a simple copy: rX = rY
        if stat and stat.kind == AstKind.AssignmentStatement and
           #stat.lhs == 1 and #stat.rhs == 1 then
            
            local lhsVar = stat.lhs[1]
            local rhsExpr = stat.rhs[1]
            
            -- Check if RHS is a variable expression (register read)
            if rhsExpr.kind == AstKind.VariableExpression then
                -- PERFORMANCE: Use pre-computed numeric register IDs
                local targetReg = statWrapper.numericWriteReg
                local sourceReg = statWrapper.numericReadRegs and statWrapper.numericReadRegs[1]
                
                if targetReg and sourceReg and targetReg ~= sourceReg then
                    -- Look ahead to see if target is used as a source and then overwritten
                    local targetUsedAsSource = false
                    local targetOverwritten = false
                    local canPropagate = true
                    
                    for j = i + 1, numStatements do
                        local futureWrapper = statements[j]
                        
                        -- Skip nil entries (can happen after merge operations)
                        if futureWrapper then
                            if futureWrapper.reads and futureWrapper.reads[targetReg] then
                                targetUsedAsSource = true
                            end
                            
                            if futureWrapper.writes and futureWrapper.writes[targetReg] then
                                targetOverwritten = true
                                
                                -- If target is overwritten without being used, we can remove this copy
                                if not targetUsedAsSource and not statWrapper.usesUpvals then
                                    table.remove(statements, i)
                                    changed = true
                                    i = i - 1 -- Re-check this position
                                end
                                break
                            end
                            
                            -- Don't propagate across upvalue operations
                            if futureWrapper.usesUpvals then
                                canPropagate = false
                                break
                            end
                        end
                    end
                end
            end
        end
        
        i = i + 1
    end
    
    return changed
end

-- ============================================================================
-- Pattern 2: Remove Dead Stores (r1 = x; r1 = y → r1 = y if x not read between)
-- ============================================================================
function Peephole.removeDeadStores(compiler, statements)
    local changed = false
    local i = 1
    -- PERFORMANCE: Cache statement count to avoid repeated # operator
    local numStatements = #statements
    
    while i < numStatements do
        local statWrapper = statements[i]
        
        -- PERFORMANCE: Use pre-computed numeric write register
        local writtenReg = statWrapper.numericWriteReg
        
        -- If it writes to a register and doesn't use upvalues
        if writtenReg and not statWrapper.usesUpvals then
            local isRead = false
            local overwriteIndex = nil
            
            -- Look ahead for reads or overwrites
            for j = i + 1, numStatements do
                local futureWrapper = statements[j]
                
                -- Skip nil entries (can happen after merge operations)
                if futureWrapper then
                    if futureWrapper.reads and futureWrapper.reads[writtenReg] then
                        isRead = true
                        break
                    end
                    
                    if futureWrapper.writes and futureWrapper.writes[writtenReg] then
                        overwriteIndex = j
                        break
                    end
                end
            end
            
            -- If the register is overwritten without being read, remove this store
            if overwriteIndex and not isRead then
                table.remove(statements, i)
                changed = true
                i = i - 1 -- Recheck this position
            end
        end
        
        i = i + 1
    end
    
    return changed
end

-- ============================================================================
-- Pattern 3: Fold Identity Operations
-- r1 = r2 + 0 → r1 = r2
-- r1 = r2 * 1 → r1 = r2
-- r1 = r2 - 0 → r1 = r2
-- r1 = r2 / 1 → r1 = r2
-- ============================================================================
function Peephole.foldIdentityOps(compiler, statements)
    local changed = false
    
    for i, statWrapper in ipairs(statements) do
        local stat = statWrapper and statWrapper.statement
        
        if stat and stat.kind == AstKind.AssignmentStatement and
           #stat.lhs == 1 and #stat.rhs == 1 then
            
            local rhsExpr = stat.rhs[1]
            local simplified = nil
            local newReads = nil
            
            -- x + 0 or 0 + x
            if rhsExpr.kind == AstKind.AddExpression then
                if rhsExpr.rhs.kind == AstKind.NumberExpression and rhsExpr.rhs.value == 0 then
                    simplified = rhsExpr.lhs
                elseif rhsExpr.lhs.kind == AstKind.NumberExpression and rhsExpr.lhs.value == 0 then
                    simplified = rhsExpr.rhs
                end
            
            -- x - 0
            elseif rhsExpr.kind == AstKind.SubExpression then
                if rhsExpr.rhs.kind == AstKind.NumberExpression and rhsExpr.rhs.value == 0 then
                    simplified = rhsExpr.lhs
                end
            
            -- x * 1 or 1 * x
            elseif rhsExpr.kind == AstKind.MulExpression then
                if rhsExpr.rhs.kind == AstKind.NumberExpression and rhsExpr.rhs.value == 1 then
                    simplified = rhsExpr.lhs
                elseif rhsExpr.lhs.kind == AstKind.NumberExpression and rhsExpr.lhs.value == 1 then
                    simplified = rhsExpr.rhs
                end
                
            -- x / 1
            elseif rhsExpr.kind == AstKind.DivExpression then
                if rhsExpr.rhs.kind == AstKind.NumberExpression and rhsExpr.rhs.value == 1 then
                    simplified = rhsExpr.lhs
                end
                
            -- x ^ 1
            elseif rhsExpr.kind == AstKind.PowExpression then
                if rhsExpr.rhs.kind == AstKind.NumberExpression and rhsExpr.rhs.value == 1 then
                    simplified = rhsExpr.lhs
                -- x ^ 0 = 1
                elseif rhsExpr.rhs.kind == AstKind.NumberExpression and rhsExpr.rhs.value == 0 then
                    simplified = Ast.NumberExpression(1)
                    newReads = {}
                end
            end
            
            if simplified then
                stat.rhs[1] = simplified
                -- Update reads if we have new reads, otherwise keep existing
                if newReads then
                    statWrapper.reads = {}
                    for _, r in ipairs(newReads) do
                        statWrapper.reads[r] = true
                    end
                end
                changed = true
            end
        end
    end
    
    return changed
end

-- ============================================================================
-- Pattern 4: Merge Consecutive Jumps (pos = X; pos = Y → pos = Y)
-- ============================================================================
function Peephole.mergeJumps(compiler, statements)
    local changed = false
    local i = 1
    
    while i < #statements do
        local statWrapper = statements[i]
        local nextWrapper = statements[i + 1]
        
        -- Check if both write to POS_REGISTER
        if statWrapper.writes[compiler.POS_REGISTER] and
           nextWrapper.writes[compiler.POS_REGISTER] then
            
            -- Check that the first write isn't read
            local firstStat = statWrapper.statement
            local secondStat = nextWrapper.statement
            
            -- Only merge unconditional jumps (NumberExpression)
            if firstStat.kind == AstKind.AssignmentStatement and
               secondStat.kind == AstKind.AssignmentStatement and
               #firstStat.rhs == 1 and #secondStat.rhs == 1 then
                
                local firstRhs = firstStat.rhs[1]
                
                -- If first jump is unconditional, remove it
                if firstRhs.kind == AstKind.NumberExpression then
                    table.remove(statements, i)
                    changed = true
                    i = i - 1 -- Recheck this position
                end
            end
        end
        
        i = i + 1
    end
    
    return changed
end

-- ============================================================================
-- Pattern 5: Constant Propagation within Block
-- If r1 = constant and r1 is only read (not written) before next use
-- ============================================================================
function Peephole.constantPropagation(compiler, statements)
    local changed = false
    local constants = {} -- reg -> constant expression
    
    for i, statWrapper in ipairs(statements) do
        local stat = statWrapper and statWrapper.statement
        
        -- First, update any reads with known constants
        if stat and stat.kind == AstKind.AssignmentStatement and
           #stat.rhs == 1 then
            
            local rhsExpr = stat.rhs[1]
            
            -- Propagate constants in binary expressions
            if rhsExpr.kind == AstKind.AddExpression or
               rhsExpr.kind == AstKind.SubExpression or
               rhsExpr.kind == AstKind.MulExpression or
               rhsExpr.kind == AstKind.DivExpression or
               rhsExpr.kind == AstKind.ModExpression or
               rhsExpr.kind == AstKind.PowExpression then
                
                -- Check if both sides are now constant (after propagation)
                local lhs = rhsExpr.lhs
                local rhs = rhsExpr.rhs
                
                if lhs.kind == AstKind.NumberExpression and
                   rhs.kind == AstKind.NumberExpression then
                    
                    local l, r = lhs.value, rhs.value
                    local res = nil
                    
                    if rhsExpr.kind == AstKind.AddExpression then res = l + r
                    elseif rhsExpr.kind == AstKind.SubExpression then res = l - r
                    elseif rhsExpr.kind == AstKind.MulExpression then res = l * r
                    elseif rhsExpr.kind == AstKind.DivExpression and r ~= 0 then res = l / r
                    elseif rhsExpr.kind == AstKind.ModExpression and r ~= 0 then res = l % r
                    elseif rhsExpr.kind == AstKind.PowExpression then res = l ^ r
                    end
                    
                    if res and res == res and math.abs(res) ~= math.huge then
                        stat.rhs[1] = Ast.NumberExpression(res)
                        changed = true
                    end
                end
            end
        end
        
        -- Track constants for future propagation
        if stat and stat.kind == AstKind.AssignmentStatement and
           #stat.lhs == 1 and #stat.rhs == 1 then
            
            -- PERFORMANCE: Use pre-computed numeric write register\n            local writtenReg = statWrapper.numericWriteReg
            
            local rhsExpr = stat.rhs[1]
            
            if writtenReg then
                if rhsExpr.kind == AstKind.NumberExpression or
                   rhsExpr.kind == AstKind.StringExpression or
                   rhsExpr.kind == AstKind.BooleanExpression or
                   rhsExpr.kind == AstKind.NilExpression then
                    constants[writtenReg] = rhsExpr
                else
                    -- Invalidate if not a constant
                    constants[writtenReg] = nil
                end
            end
        end
    end
    
    return changed
end

-- ============================================================================
-- Pattern 5c: Superinstruction Fusion (MAJOR RUNTIME OPTIMIZATION #3)
-- Fuse load+test+branch into single expressions for faster execution
-- Example: r1 = x; pos = (r1 < 10) and A or B → pos = (x < 10) and A or B
-- This eliminates intermediate register allocation and reduces instruction count
-- ============================================================================
function Peephole.superinstructionFusion(compiler, statements)
    local changed = false
    local i = 1
    local numStatements = #statements
    
    while i < numStatements do
        local statWrapper = statements[i]
        local nextWrapper = statements[i + 1]
        local didFuse = false
        
        -- Only process if both wrappers exist
        if statWrapper and nextWrapper then
            local stat = statWrapper.statement
            local nextStat = nextWrapper.statement
            
            -- Pattern: LOAD-TEST-BRANCH Fusion
            -- r1 = expr; pos = (r1 op const) and A or B
            -- → pos = (expr op const) and A or B
            if stat and nextStat and
               stat.kind == AstKind.AssignmentStatement and
               nextStat.kind == AstKind.AssignmentStatement and
               #stat.lhs == 1 and #stat.rhs == 1 and
               #nextStat.lhs == 1 and #nextStat.rhs == 1 then
                
                local loadReg = statWrapper.numericWriteReg
                local loadRhs = stat.rhs[1]
                
                -- Check if next statement is a conditional jump using our loaded value
                if loadReg and nextWrapper.writes[compiler.POS_REGISTER] then
                    local condExpr = nextStat.rhs[1]
                    
                    -- Look for OrExpression(AndExpression(condition, target1), target2)
                    -- This is the standard conditional jump pattern
                    if condExpr and condExpr.kind == AstKind.OrExpression and
                       condExpr.lhs and condExpr.lhs.kind == AstKind.AndExpression then
                        
                        local andExpr = condExpr.lhs
                        local condition = andExpr.lhs
                        
                        -- Check if condition is a comparison that uses our register
                        if condition and (
                           condition.kind == AstKind.LessThanExpression or
                           condition.kind == AstKind.GreaterThanExpression or
                           condition.kind == AstKind.LessThanOrEqualsExpression or
                           condition.kind == AstKind.GreaterThanOrEqualsExpression or
                           condition.kind == AstKind.EqualsExpression or
                           condition.kind == AstKind.NotEqualsExpression) then
                            
                            -- Check if LHS or RHS references the loaded register
                            local lhsUsesReg = condition.lhs and 
                                              condition.lhs.kind == AstKind.VariableExpression
                            local rhsUsesReg = condition.rhs and 
                                              condition.rhs.kind == AstKind.VariableExpression
                            
                            -- Check if the loaded register is only used in this comparison
                            if (lhsUsesReg or rhsUsesReg) and nextWrapper.reads[loadReg] then
                                -- Check that loadReg is not read anywhere else after this
                                local usedElsewhere = false
                                for j = i + 2, numStatements do
                                    local futureWrapper = statements[j]
                                    if futureWrapper and futureWrapper.reads[loadReg] then
                                        usedElsewhere = true
                                        break
                                    end
                                end
                                
                                -- Also check that the load expression is side-effect free
                                if not usedElsewhere and not statWrapper.usesUpvals then
                                    -- Perform the fusion!
                                    local usesLoadReg = false
                                    local newCondition
                                    
                                    if lhsUsesReg and condition.lhs.kind == AstKind.VariableExpression then
                                        -- Substitute LHS
                                        newCondition = Ast[condition.kind:gsub("Expression$", "") .. "Expression"](
                                            loadRhs,
                                            condition.rhs
                                        )
                                        usesLoadReg = true
                                    elseif rhsUsesReg and condition.rhs.kind == AstKind.VariableExpression then
                                        -- Substitute RHS
                                        newCondition = Ast[condition.kind:gsub("Expression$", "") .. "Expression"](
                                            condition.lhs,
                                            loadRhs
                                        )
                                        usesLoadReg = true
                                    end
                                    
                                    if usesLoadReg and newCondition then
                                        -- Build new fused conditional
                                        local newAndExpr = Ast.AndExpression(newCondition, andExpr.rhs)
                                        local newOrExpr = Ast.OrExpression(newAndExpr, condExpr.rhs)
                                        
                                        -- Update next statement RHS
                                        nextStat.rhs[1] = newOrExpr
                                        
                                        -- Update reads: remove loadReg, add reads from original expression
                                        nextWrapper.reads[loadReg] = nil
                                        for reg, _ in pairs(statWrapper.reads) do
                                            nextWrapper.reads[reg] = true
                                        end
                                        
                                        -- Remove the load statement
                                        table.remove(statements, i)
                                        numStatements = numStatements - 1
                                        
                                        changed = true
                                        didFuse = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Only increment if we didn't fuse (fusion removes current statement)
        if not didFuse then
            i = i + 1
        end
    end
    
    return changed
end

-- ============================================================================
-- Pattern 5b: Merge Adjacent Assignments (RUNTIME OPTIMIZATION #5)
-- r1 = v1; r2 = v2; r3 = v3 → r1, r2, r3 = v1, v2, v3
-- Batched assignments generate fewer Lua VM instructions and execute faster
-- ============================================================================
function Peephole.mergeAdjacentAssignments(compiler, statements)
    local changed = false
    local i = 1
    local numStatements = #statements
    
    while i < numStatements do
        local statWrapper = statements[i]
        local stat = statWrapper and statWrapper.statement
        
        -- Check if this is a simple assignment with single LHS and RHS
        if stat and stat.kind == AstKind.AssignmentStatement and
           #stat.lhs == 1 and #stat.rhs == 1 and
           not statWrapper.usesUpvals then
            
            -- Find consecutive simple assignments that can be merged
            local mergeableCount = 0
            local j = i + 1
            
            while j <= numStatements do
                local nextWrapper = statements[j]
                local nextStat = nextWrapper and nextWrapper.statement
                
                -- Check if next statement is also a simple assignment
                if nextStat and nextStat.kind == AstKind.AssignmentStatement and
                   #nextStat.lhs == 1 and #nextStat.rhs == 1 and
                   not nextWrapper.usesUpvals then
                    
                    -- Ensure no write-after-read dependency: 
                    -- If next assignment reads what we're about to write, can't merge
                    local prevWriteReg = statWrapper.numericWriteReg
                    local nextReadRegs = nextWrapper.numericReadRegs or {}
                    
                    local hasDataDependency = false
                    for _, readReg in ipairs(nextReadRegs) do
                        if readReg == prevWriteReg then
                            hasDataDependency = true
                            break
                        end
                    end
                    
                    -- Also check for write-write conflicts (same register)
                    local nextWriteReg = nextWrapper.numericWriteReg
                    if prevWriteReg and nextWriteReg and prevWriteReg == nextWriteReg then
                        hasDataDependency = true
                    end
                    
                    if hasDataDependency then
                        break
                    end
                    
                    mergeableCount = mergeableCount + 1
                    j = j + 1
                    -- Update prevWriteReg for next iteration
                    statWrapper = nextWrapper
                else
                    break
                end
            end
            
            -- If we found at least 2 consecutive mergeable assignments, merge them
            if mergeableCount >= 1 then
                local firstWrapper = statements[i]
                local firstStat = firstWrapper.statement
                local mergedLhs = { firstStat.lhs[1] }
                local mergedRhs = { firstStat.rhs[1] }
                local mergedWrites = {}
                local mergedReads = {}
                
                -- Collect all writes/reads
                if firstWrapper.numericWriteReg then
                    mergedWrites[firstWrapper.numericWriteReg] = true
                end
                for reg, _ in pairs(firstWrapper.reads) do
                    mergedReads[reg] = true
                end
                
                -- Merge subsequent assignments
                for k = 1, mergeableCount do
                    local mergeWrapper = statements[i + k]
                    local mergeStat = mergeWrapper.statement
                    
                    table.insert(mergedLhs, mergeStat.lhs[1])
                    table.insert(mergedRhs, mergeStat.rhs[1])
                    
                    if mergeWrapper.numericWriteReg then
                        mergedWrites[mergeWrapper.numericWriteReg] = true
                    end
                    for reg, _ in pairs(mergeWrapper.reads) do
                        mergedReads[reg] = true
                    end
                end
                
                -- Create merged assignment statement
                local mergedStatement = Ast.AssignmentStatement(mergedLhs, mergedRhs)
                
                -- Update first statement wrapper with merged statement
                firstWrapper.statement = mergedStatement
                firstWrapper.writes = mergedWrites
                firstWrapper.reads = mergedReads
                
                -- Remove the merged statements (mark as nil, will be compacted later)
                for k = 1, mergeableCount do
                    statements[i + k] = nil
                end
                
                changed = true
                -- Skip past the merged statements
                i = i + mergeableCount + 1
            else
                i = i + 1
            end
        else
            i = i + 1
        end
    end
    
    -- Compact the statements array to remove nils
    if changed then
        local compacted = {}
        for _, wrapper in pairs(statements) do
            if wrapper then
                table.insert(compacted, wrapper)
            end
        end
        -- Replace contents
        for k in pairs(statements) do
            statements[k] = nil
        end
        for k, v in ipairs(compacted) do
            statements[k] = v
        end
    end
    
    return changed
end

-- ============================================================================
-- Main Optimization Function
-- Runs all peephole patterns iteratively until no changes
-- ============================================================================
function Peephole.optimize(compiler, block, maxIterations)
    maxIterations = maxIterations or DEFAULT_MAX_ITERATIONS
    
    local changed = true
    local iterations = 0
    
    while changed and iterations < maxIterations do
        changed = false
        iterations = iterations + 1
        
        -- Apply each pattern
        changed = Peephole.removeRedundantCopies(compiler, block.statements) or changed
        changed = Peephole.removeDeadStores(compiler, block.statements) or changed
        changed = Peephole.foldIdentityOps(compiler, block.statements) or changed
        changed = Peephole.mergeJumps(compiler, block.statements) or changed
        changed = Peephole.constantPropagation(compiler, block.statements) or changed
        -- MAJOR RUNTIME OPTIMIZATION #3: Superinstruction Fusion (load+test+branch → single expr)
        changed = Peephole.superinstructionFusion(compiler, block.statements) or changed
        -- RUNTIME OPTIMIZATION #5: Merge consecutive simple assigns into batched multi-assigns
        changed = Peephole.mergeAdjacentAssignments(compiler, block.statements) or changed
    end
    
    return iterations
end

-- ============================================================================
-- Apply peephole optimization to all blocks in the compiler
-- ============================================================================
function Peephole.optimizeAllBlocks(compiler, maxIterations)
    if not compiler.enablePeepholeOptimization then
        return
    end
    
    maxIterations = maxIterations or compiler.maxPeepholeIterations or DEFAULT_MAX_ITERATIONS
    
    for _, block in ipairs(compiler.blocks) do
        Peephole.optimize(compiler, block, maxIterations)
    end
end

return Peephole

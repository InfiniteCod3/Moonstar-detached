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
    
    while i <= #statements do
        local statWrapper = statements[i]
        local stat = statWrapper and statWrapper.statement
        
        -- Check if this is a simple copy: rX = rY
        if stat and stat.kind == AstKind.AssignmentStatement and
           #stat.lhs == 1 and #stat.rhs == 1 then
            
            local lhsVar = stat.lhs[1]
            local rhsExpr = stat.rhs[1]
            
            -- Check if RHS is a variable expression (register read)
            if rhsExpr.kind == AstKind.VariableExpression then
                local targetReg = nil
                local sourceReg = nil
                
                -- Extract target register from writes
                for reg, _ in pairs(statWrapper.writes) do
                    if type(reg) == "number" then
                        targetReg = reg
                        break
                    end
                end
                
                -- Extract source register from reads
                for reg, _ in pairs(statWrapper.reads) do
                    if type(reg) == "number" then
                        sourceReg = reg
                        break
                    end
                end
                
                if targetReg and sourceReg and targetReg ~= sourceReg then
                    -- Look ahead to see if target is used as a source and then overwritten
                    local targetUsedAsSource = false
                    local targetOverwritten = false
                    local canPropagate = true
                    
                    for j = i + 1, #statements do
                        local futureWrapper = statements[j]
                        
                        if futureWrapper.reads[targetReg] then
                            targetUsedAsSource = true
                        end
                        
                        if futureWrapper.writes[targetReg] then
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
    
    while i < #statements do
        local statWrapper = statements[i]
        
        -- Find what register this statement writes to
        local writtenReg = nil
        for reg, _ in pairs(statWrapper.writes) do
            if type(reg) == "number" then
                writtenReg = reg
                break
            end
        end
        
        -- If it writes to a register and doesn't use upvalues
        if writtenReg and not statWrapper.usesUpvals then
            local isRead = false
            local overwriteIndex = nil
            
            -- Look ahead for reads or overwrites
            for j = i + 1, #statements do
                local futureWrapper = statements[j]
                
                if futureWrapper.reads[writtenReg] then
                    isRead = true
                    break
                end
                
                if futureWrapper.writes[writtenReg] then
                    overwriteIndex = j
                    break
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
            
            local writtenReg = nil
            for reg, _ in pairs(statWrapper.writes) do
                if type(reg) == "number" then
                    writtenReg = reg
                    break
                end
            end
            
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

-- licm.lua
-- P10: Loop Invariant Code Motion (LICM)
-- Hoist invariant computations out of loops to reduce redundant work
-- These optimizations are applied after block generation but before VM emission

local Ast = require("moonstar.ast");
local AstKind = Ast.AstKind;

local LICM = {}

-- ============================================================================
-- Invariant Detection
-- Check if an expression is loop-invariant (doesn't depend on loop variables
-- or any variables modified within the loop)
-- ============================================================================

-- Check if a raw expression AST node is invariant
-- loopVars: set of register IDs that are loop control variables
-- modifiedVars: set of register IDs modified within the loop body
function LICM.isInvariantExpression(expr, loopVars, modifiedVars)
    if not expr then return false end
    
    local kind = expr.kind
    
    -- Literal values are always invariant
    if kind == AstKind.NumberExpression or
       kind == AstKind.StringExpression or
       kind == AstKind.BooleanExpression or
       kind == AstKind.NilExpression then
        return true
    end
    
    -- Variable expressions need to check if the variable is modified/loop-controlled
    if kind == AstKind.VariableExpression then
        -- This is a scope-based variable reference
        -- For now, we're conservative: if we can't track it, it's not invariant
        return false
    end
    
    -- Binary expressions are invariant if both sides are invariant
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
        return LICM.isInvariantExpression(expr.lhs, loopVars, modifiedVars) and
               LICM.isInvariantExpression(expr.rhs, loopVars, modifiedVars)
    end
    
    -- Unary expressions (not, negate, len)
    if kind == AstKind.NotExpression or
       kind == AstKind.NegateExpression or
       kind == AstKind.LenExpression then
        return LICM.isInvariantExpression(expr.rhs, loopVars, modifiedVars)
    end
    
    -- Index expressions: check base and index
    if kind == AstKind.IndexExpression then
        -- Conservative: table access might have side effects via __index
        -- Only hoist if we can prove it's safe (e.g., known immutable globals)
        return false
    end
    
    -- Function calls are NOT invariant (side effects)
    if kind == AstKind.FunctionCallExpression or
       kind == AstKind.PassSelfFunctionCallExpression then
        return false
    end
    
    -- Table constructors are NOT invariant (creates new table each time)
    if kind == AstKind.TableConstructorExpression then
        return false
    end
    
    -- Vararg and other special expressions are NOT invariant
    return false
end

-- ============================================================================
-- Statement-Level Invariant Detection
-- Check if a statement wrapper is loop-invariant
-- ============================================================================

function LICM.isInvariantStatement(statWrapper, loopVars, modifiedRegs)
    if not statWrapper then return false end
    
    local stat = statWrapper.statement
    if not stat then return false end
    
    -- We can only hoist simple assignments
    if stat.kind ~= AstKind.AssignmentStatement then
        return false
    end
    
    -- Must be a single assignment
    if #stat.lhs ~= 1 or #stat.rhs ~= 1 then
        return false
    end
    
    -- Don't hoist if the statement uses upvalues (may have side effects)
    if statWrapper.usesUpvals then
        return false
    end
    
    -- PERFORMANCE: Use pre-computed numeric write register
    local writtenReg = statWrapper.numericWriteReg
    
    -- If it writes to a loop variable, it's not invariant
    if writtenReg and loopVars[writtenReg] then
        return false
    end
    
    -- PERFORMANCE: Use pre-computed numeric read registers
    local numericReadRegs = statWrapper.numericReadRegs or {}
    for _, reg in ipairs(numericReadRegs) do
        if modifiedRegs[reg] or loopVars[reg] then
            return false
        end
    end
    
    -- The RHS expression must be invariant
    local rhsExpr = stat.rhs[1]
    return LICM.isInvariantExpression(rhsExpr, loopVars, modifiedRegs)
end

-- ============================================================================
-- Find all registers modified within a block
-- ============================================================================

function LICM.findModifiedRegisters(statements)
    local modified = {}
    for _, statWrapper in ipairs(statements) do
        -- PERFORMANCE: Use pre-computed numeric write register
        local reg = statWrapper.numericWriteReg
        if reg then
            modified[reg] = true
        end
    end
    return modified
end

-- ============================================================================
-- Find all registers read within a block
-- ============================================================================

function LICM.findReadRegisters(statements)
    local reads = {}
    for _, statWrapper in ipairs(statements) do
        -- PERFORMANCE: Use pre-computed numeric read registers
        local numericReads = statWrapper.numericReadRegs or {}
        for _, reg in ipairs(numericReads) do
            reads[reg] = true
        end
    end
    return reads
end

-- ============================================================================
-- Optimize a loop body by hoisting invariant statements
-- Returns: hoistedStatements (to insert before loop), optimizedStatements
-- ============================================================================

function LICM.hoistFromBlock(statements, loopVars)
    loopVars = loopVars or {}
    
    -- Find all registers modified within the loop
    local modifiedRegs = LICM.findModifiedRegisters(statements)
    
    local hoisted = {}
    local remaining = {}
    local hoistedRegs = {} -- Track which registers have been hoisted
    
    -- First pass: identify invariant statements
    for i, statWrapper in ipairs(statements) do
        local canHoist = LICM.isInvariantStatement(statWrapper, loopVars, modifiedRegs)
        
        if canHoist then
            -- Additional check: the written register shouldn't be read before
            -- this statement in the loop (data dependency)
            -- PERFORMANCE: Use pre-computed numeric write register
            local writtenReg = statWrapper.numericWriteReg
            
            -- Check if any earlier statement reads this register
            local hasEarlierRead = false
            for j = 1, i - 1 do
                if statements[j].reads[writtenReg] then
                    hasEarlierRead = true
                    break
                end
            end
            
            -- Check if any later statement in the same iteration reads this register
            -- before it's written again (this would change semantics)
            local hasLaterReadBeforeWrite = false
            local writtenAgain = false
            for j = i + 1, #statements do
                if statements[j].writes[writtenReg] then
                    writtenAgain = true
                    break
                end
                if statements[j].reads[writtenReg] then
                    hasLaterReadBeforeWrite = true
                    break
                end
            end
            
            -- Only hoist if it's safe
            if not hasEarlierRead and not (hasLaterReadBeforeWrite and not writtenAgain) then
                table.insert(hoisted, statWrapper)
                hoistedRegs[writtenReg] = true
            else
                table.insert(remaining, statWrapper)
            end
        else
            table.insert(remaining, statWrapper)
        end
    end
    
    return hoisted, remaining, hoistedRegs
end

-- ============================================================================
-- Main LICM optimization pass for the compiler
-- This should be called during loop compilation in statements.lua
-- ============================================================================

function LICM.optimize(compiler, loopBodyBlock, loopVars)
    if not compiler.enableLICM then
        return nil -- No hoisted statements
    end
    
    local hoisted, remaining, hoistedRegs = LICM.hoistFromBlock(loopBodyBlock.statements, loopVars)
    
    if #hoisted > 0 then
        -- Update the block's statements to only contain non-hoisted ones
        loopBodyBlock.statements = remaining
        return hoisted
    end
    
    return nil
end

-- ============================================================================
-- Block-Level LICM (for VM optimization pass)
-- Detect loop structures and hoist invariants from loop bodies
-- ============================================================================

function LICM.optimizeAllBlocks(compiler)
    if not compiler.enableLICM then
        return
    end
    
    -- Build block map and edge information
    local blockMap = {}
    local allEdges = {}
    
    for _, block in ipairs(compiler.blocks) do
        blockMap[block.id] = block
        allEdges[block.id] = {}
    end
    
    -- Collect jump targets
    local function collectTargets(expr, targets)
        if not expr then return end
        if expr.kind == AstKind.NumberExpression then
            table.insert(targets, expr.value)
        elseif expr.kind == AstKind.BinaryExpression or
               expr.kind == AstKind.OrExpression or
               expr.kind == AstKind.AndExpression then
            collectTargets(expr.lhs, targets)
            collectTargets(expr.rhs, targets)
        end
    end
    
    for _, block in ipairs(compiler.blocks) do
        if #block.statements > 0 then
            local lastStatWrapper = block.statements[#block.statements]
            if lastStatWrapper.writes[compiler.POS_REGISTER] then
                local assignStat = lastStatWrapper.statement
                local val = assignStat.rhs[1]
                collectTargets(val, allEdges[block.id])
            end
        end
    end
    
    -- Detect back edges (loops) using DFS
    local visited = {}
    local inStack = {}
    local loopHeaders = {}
    local loopBodies = {} -- header -> set of block IDs in loop
    
    local function dfs(blockId, path)
        if visited[blockId] then return end
        visited[blockId] = true
        inStack[blockId] = true
        table.insert(path, blockId)
        
        local edges = allEdges[blockId]
        if edges then
            for _, targetId in ipairs(edges) do
                if inStack[targetId] then
                    -- Back edge found: targetId is a loop header
                    loopHeaders[targetId] = true
                    
                    -- Collect all blocks in this loop
                    if not loopBodies[targetId] then
                        loopBodies[targetId] = {}
                    end
                    
                    -- Add all blocks from header to current block in path
                    local inLoop = false
                    for _, pathBlockId in ipairs(path) do
                        if pathBlockId == targetId then
                            inLoop = true
                        end
                        if inLoop then
                            loopBodies[targetId][pathBlockId] = true
                        end
                    end
                elseif not visited[targetId] then
                    dfs(targetId, path)
                end
            end
        end
        
        table.remove(path)
        inStack[blockId] = false
    end
    
    dfs(compiler.startBlockId, {})
    
    -- For each loop, try to hoist invariants from loop body blocks
    local totalHoisted = 0
    
    for headerId, bodyBlocks in pairs(loopBodies) do
        local headerBlock = blockMap[headerId]
        if headerBlock then
            -- Collect all registers modified in ANY block of the loop
            local loopModifiedRegs = {}
            for blockId, _ in pairs(bodyBlocks) do
                local block = blockMap[blockId]
                if block then
                    local modified = LICM.findModifiedRegisters(block.statements)
                    for reg, _ in pairs(modified) do
                        loopModifiedRegs[reg] = true
                    end
                end
            end
            
            -- Process each block in the loop for potential hoisting
            for blockId, _ in pairs(bodyBlocks) do
                local block = blockMap[blockId]
                if block and blockId ~= headerId then
                    local hoisted, remaining = LICM.hoistFromBlock(block.statements, loopModifiedRegs)
                    
                    if #hoisted > 0 then
                        -- Insert hoisted statements at the beginning of the header block
                        -- (before the loop condition check)
                        for i = #hoisted, 1, -1 do
                            table.insert(headerBlock.statements, 1, hoisted[i])
                        end
                        block.statements = remaining
                        totalHoisted = totalHoisted + #hoisted
                    end
                end
            end
        end
    end
    
    return totalHoisted
end

return LICM

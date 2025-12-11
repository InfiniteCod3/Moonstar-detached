-- register_coalescing.lua
-- P21: Register Locality Optimization (Live Range Coalescing)
-- Groups registers that are live at the same time into contiguous ranges
-- to improve cache locality and reduce trace compilation overhead

local Ast = require("moonstar.ast")
local AstKind = Ast.AstKind

local RegisterCoalescing = {}

-- ============================================================================
-- Live Interval Computation
-- Compute the [start, end] interval for each register's live range
-- ============================================================================

-- Build live intervals for all numeric registers in a block
-- Returns: { [regId] = { start = first_use_index, last = last_use_index } }
function RegisterCoalescing.computeLiveIntervals(statements)
    local intervals = {}
    
    for i, statWrapper in ipairs(statements) do
        -- Record writes (definitions)
        if statWrapper.numericWriteReg then
            local reg = statWrapper.numericWriteReg
            if not intervals[reg] then
                intervals[reg] = { start = i, last = i }
            else
                -- Definition extends the interval
                intervals[reg].last = i
            end
        end
        
        -- Record reads (uses)
        if statWrapper.numericReadRegs then
            for _, reg in ipairs(statWrapper.numericReadRegs) do
                if not intervals[reg] then
                    intervals[reg] = { start = i, last = i }
                else
                    intervals[reg].last = i
                end
            end
        end
        
        -- Also check the reads table for other uses
        for reg, _ in pairs(statWrapper.reads) do
            if type(reg) == "number" then
                if not intervals[reg] then
                    intervals[reg] = { start = i, last = i }
                else
                    intervals[reg].last = i
                end
            end
        end
    end
    
    return intervals
end

-- ============================================================================
-- Register Adjacency Hints
-- Track which registers are used together (in the same expression)
-- Allocating them adjacently improves cache locality
-- ============================================================================

-- Build adjacency graph: which registers are used in the same statement
-- Returns: { [regId] = { [otherRegId] = count } }
function RegisterCoalescing.buildAdjacencyGraph(statements)
    local adjacency = {}
    
    for _, statWrapper in ipairs(statements) do
        -- Collect all numeric registers in this statement
        local regsInStatement = {}
        
        if statWrapper.numericWriteReg then
            regsInStatement[statWrapper.numericWriteReg] = true
        end
        
        if statWrapper.numericReadRegs then
            for _, reg in ipairs(statWrapper.numericReadRegs) do
                regsInStatement[reg] = true
            end
        end
        
        -- All registers in the same statement are "adjacent" (want to be close)
        local regList = {}
        for reg, _ in pairs(regsInStatement) do
            table.insert(regList, reg)
        end
        
        for i = 1, #regList do
            for j = i + 1, #regList do
                local r1, r2 = regList[i], regList[j]
                
                if not adjacency[r1] then adjacency[r1] = {} end
                if not adjacency[r2] then adjacency[r2] = {} end
                
                adjacency[r1][r2] = (adjacency[r1][r2] or 0) + 1
                adjacency[r2][r1] = (adjacency[r2][r1] or 0) + 1
            end
        end
    end
    
    return adjacency
end

-- ============================================================================
-- Register Renumbering
-- After allocation, renumber registers to maximize locality
-- ============================================================================

-- Compute optimal register ordering based on live intervals and adjacency
-- Returns: { [oldRegId] = newRegId }
function RegisterCoalescing.computeOptimalOrdering(intervals, adjacency, maxReg)
    if not next(intervals) then
        return {} -- No registers to reorder
    end
    
    -- Strategy: Sort registers by their first use (start of live interval)
    -- Registers with overlapping live ranges that are used together get adjacent IDs
    
    local regList = {}
    for reg, interval in pairs(intervals) do
        table.insert(regList, {
            id = reg,
            start = interval.start,
            last = interval.last,
            weight = 0 -- Adjacency weight for tie-breaking
        })
    end
    
    -- Compute adjacency weights
    for _, entry in ipairs(regList) do
        local adj = adjacency[entry.id]
        if adj then
            for _, count in pairs(adj) do
                entry.weight = entry.weight + count
            end
        end
    end
    
    -- Sort by: 1) start of live interval, 2) adjacency weight (prefer high adjacency)
    table.sort(regList, function(a, b)
        if a.start ~= b.start then
            return a.start < b.start
        end
        return a.weight > b.weight
    end)
    
    -- Assign new register IDs in sorted order
    local remapping = {}
    local nextId = 1
    
    for _, entry in ipairs(regList) do
        -- Only remap if it would change the ID
        if entry.id ~= nextId and entry.id <= maxReg then
            remapping[entry.id] = nextId
        end
        nextId = nextId + 1
    end
    
    return remapping
end

-- ============================================================================
-- Apply Register Remapping to Statements
-- Updates all register references in-place
-- ============================================================================

-- Remap a single register ID using the mapping
local function remapReg(reg, mapping)
    if type(reg) == "number" and mapping[reg] then
        return mapping[reg]
    end
    return reg
end

-- Recursively remap registers in an AST expression
local function remapExpressionRegisters(expr, mapping, containerFuncScope, registerVars)
    if not expr then return end
    
    local kind = expr.kind
    
    -- Variable expressions that reference registers need remapping
    if kind == AstKind.VariableExpression then
        -- Check if this variable corresponds to a remapped register
        for oldReg, newReg in pairs(mapping) do
            if registerVars[oldReg] == expr.id and registerVars[newReg] then
                -- Update to point to the new register's variable
                expr.id = registerVars[newReg]
            end
        end
    end
    
    -- Recurse into child expressions
    if expr.lhs then remapExpressionRegisters(expr.lhs, mapping, containerFuncScope, registerVars) end
    if expr.rhs then remapExpressionRegisters(expr.rhs, mapping, containerFuncScope, registerVars) end
    if expr.base then remapExpressionRegisters(expr.base, mapping, containerFuncScope, registerVars) end
    if expr.index then remapExpressionRegisters(expr.index, mapping, containerFuncScope, registerVars) end
    if expr.expression then remapExpressionRegisters(expr.expression, mapping, containerFuncScope, registerVars) end
    
    if expr.args then
        for _, arg in ipairs(expr.args) do
            remapExpressionRegisters(arg, mapping, containerFuncScope, registerVars)
        end
    end
    
    if expr.entries then
        for _, entry in ipairs(expr.entries) do
            if entry.key then remapExpressionRegisters(entry.key, mapping, containerFuncScope, registerVars) end
            if entry.value then remapExpressionRegisters(entry.value, mapping, containerFuncScope, registerVars) end
        end
    end
end

-- Apply remapping to a block's statements
function RegisterCoalescing.applyRemapping(block, mapping, compiler)
    if not next(mapping) then
        return -- Nothing to remap
    end
    
    for _, statWrapper in ipairs(block.statements) do
        -- Remap the pre-computed numeric registers
        if statWrapper.numericWriteReg then
            statWrapper.numericWriteReg = remapReg(statWrapper.numericWriteReg, mapping)
        end
        
        if statWrapper.numericReadRegs then
            for i, reg in ipairs(statWrapper.numericReadRegs) do
                statWrapper.numericReadRegs[i] = remapReg(reg, mapping)
            end
        end
        
        -- Remap the reads/writes lookup tables
        local newReads = {}
        for reg, val in pairs(statWrapper.reads) do
            newReads[remapReg(reg, mapping)] = val
        end
        statWrapper.reads = newReads
        
        local newWrites = {}
        for reg, val in pairs(statWrapper.writes) do
            newWrites[remapReg(reg, mapping)] = val
        end
        statWrapper.writes = newWrites
        
        -- Remap registers in the actual AST
        -- This is done via the expression trees
        local stat = statWrapper.statement
        if stat then
            if stat.lhs then
                for _, expr in ipairs(stat.lhs) do
                    remapExpressionRegisters(expr, mapping, compiler.containerFuncScope, compiler.registerVars)
                end
            end
            if stat.rhs then
                for _, expr in ipairs(stat.rhs) do
                    remapExpressionRegisters(expr, mapping, compiler.containerFuncScope, compiler.registerVars)
                end
            end
            if stat.condition then
                remapExpressionRegisters(stat.condition, mapping, compiler.containerFuncScope, compiler.registerVars)
            end
            if stat.args then
                for _, arg in ipairs(stat.args) do
                    remapExpressionRegisters(arg, mapping, compiler.containerFuncScope, compiler.registerVars)
                end
            end
        end
    end
end

-- ============================================================================
-- Main Optimization Entry Points
-- ============================================================================

-- Optimize a single block's register allocation for locality
function RegisterCoalescing.optimizeBlock(compiler, block)
    if not compiler.enableRegisterLocality then
        return false
    end
    
    local statements = block.statements
    if #statements < 3 then
        return false -- Not enough statements to optimize
    end
    
    -- Compute live intervals
    local intervals = RegisterCoalescing.computeLiveIntervals(statements)
    
    -- Build adjacency graph
    local adjacency = RegisterCoalescing.buildAdjacencyGraph(statements)
    
    -- Compute optimal ordering
    local mapping = RegisterCoalescing.computeOptimalOrdering(intervals, adjacency, compiler.MAX_REGS)
    
    -- Apply remapping
    if next(mapping) then
        RegisterCoalescing.applyRemapping(block, mapping, compiler)
        return true
    end
    
    return false
end

-- Optimize all blocks in the compiler
function RegisterCoalescing.optimizeAllBlocks(compiler)
    if not compiler.enableRegisterLocality then
        return 0
    end
    
    local optimizedCount = 0
    
    for _, block in ipairs(compiler.blocks) do
        if RegisterCoalescing.optimizeBlock(compiler, block) then
            optimizedCount = optimizedCount + 1
        end
    end
    
    return optimizedCount
end

-- ============================================================================
-- Register Hints (for use during allocation)
-- Suggest register IDs based on what's already allocated
-- ============================================================================

-- Get a hint for allocating a new register that will be used with 'relatedReg'
-- Returns a suggested register ID that's adjacent to relatedReg
function RegisterCoalescing.getAdjacentHint(compiler, relatedReg)
    if not compiler.enableRegisterLocality then
        return nil
    end
    
    if type(relatedReg) ~= "number" then
        return nil
    end
    
    -- Try adjacent IDs: relatedReg + 1, relatedReg - 1
    local candidates = {
        relatedReg + 1,
        relatedReg - 1,
        relatedReg + 2,
        relatedReg - 2,
    }
    
    for _, candidate in ipairs(candidates) do
        if candidate >= 1 and candidate < compiler.MAX_REGS then
            if not compiler.registers[candidate] then
                return candidate
            end
        end
    end
    
    return nil
end

-- ============================================================================
-- Compiler Integration Hook
-- Called from vm.lua after block generation but before emission
-- ============================================================================

function RegisterCoalescing.runOptimization(compiler)
    if not compiler.enableRegisterLocality then
        return
    end
    
    -- Run locality optimization on all blocks
    local count = RegisterCoalescing.optimizeAllBlocks(compiler)
    
    -- Update registerVars if any remapping occurred
    -- This ensures the final code emission uses the optimized register layout
end

return RegisterCoalescing

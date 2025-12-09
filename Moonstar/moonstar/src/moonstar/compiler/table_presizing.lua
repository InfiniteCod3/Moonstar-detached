-- table_presizing.lua
-- P17: Table Pre-sizing Optimization
-- Emit table constructors with size hints when known for LuaU compatibility

local Ast = require("moonstar.ast")
local AstKind = Ast.AstKind
local visitast = require("moonstar.visitast")

local TablePresizing = {}

-- ============================================================================
-- Configuration
-- ============================================================================
local DEFAULT_ARRAY_THRESHOLD = 4   -- Min array elements to add size hint
local DEFAULT_HASH_THRESHOLD = 4    -- Min hash elements to add size hint

-- ============================================================================
-- Table Size Analysis
-- ============================================================================

-- Analyze a TableConstructorExpression to determine its static size
-- Returns { arrayPart = n, hashPart = m, isDynamic = bool }
function TablePresizing.analyzeSize(tableExpr)
    if not tableExpr or tableExpr.kind ~= AstKind.TableConstructorExpression then
        return nil
    end
    
    local entries = tableExpr.entries or {}
    local arrayCount = 0
    local hashCount = 0
    local isDynamic = false
    
    for i, entry in ipairs(entries) do
        if entry.kind == AstKind.TableEntry then
            -- Array-style entry: { value } or { value1, value2, ... }
            -- Check if the last entry is a function call or vararg (dynamic size)
            if i == #entries then
                local value = entry.value
                if value and (
                    value.kind == AstKind.FunctionCallExpression or
                    value.kind == AstKind.PassSelfFunctionCallExpression or
                    value.kind == AstKind.VarargExpression
                ) then
                    isDynamic = true
                end
            end
            arrayCount = arrayCount + 1
        elseif entry.kind == AstKind.KeyedTableEntry then
            -- Hash-style entry: { [key] = value } or { key = value }
            hashCount = hashCount + 1
        end
    end
    
    return {
        arrayPart = arrayCount,
        hashPart = hashCount,
        isDynamic = isDynamic,
        totalEntries = #entries
    }
end

-- ============================================================================
-- Size Hint Generation
-- ============================================================================

-- Generate LuaU-compatible table.create hint
-- LuaU: table.create(arraySize, hashSize) or table.create(arraySize)
function TablePresizing.generateSizeHint(sizeInfo, compiler)
    if not sizeInfo or sizeInfo.isDynamic then
        return nil
    end
    
    local arraySize = sizeInfo.arrayPart
    local hashSize = sizeInfo.hashPart
    
    -- Check if size exceeds threshold for optimization
    local arrayThreshold = compiler.tablePresizeArrayThreshold or DEFAULT_ARRAY_THRESHOLD
    local hashThreshold = compiler.tablePresizeHashThreshold or DEFAULT_HASH_THRESHOLD
    
    if arraySize < arrayThreshold and hashSize < hashThreshold then
        return nil
    end
    
    -- Return size info for emission
    return {
        arraySize = arraySize,
        hashSize = hashSize
    }
end

-- ============================================================================
-- Expression Optimization
-- ============================================================================

-- Check if we should apply table.create optimization
function TablePresizing.shouldOptimize(tableExpr, compiler)
    if not compiler.enableTablePresizing then
        return false, nil
    end
    
    local sizeInfo = TablePresizing.analyzeSize(tableExpr)
    if not sizeInfo then
        return false, nil
    end
    
    local hint = TablePresizing.generateSizeHint(sizeInfo, compiler)
    if not hint then
        return false, nil
    end
    
    return true, hint
end

-- Generate optimized table creation expression
-- Creates: table.create and table.create(n) or table.create(n, 0) then assigns entries
function TablePresizing.generateOptimizedCreate(hint, entries, compiler, scope)
    -- We generate a pattern that works in both Lua 5.1 and LuaU:
    -- (table.create and table.create(arraySize, 0)) or {}
    -- This returns {} in Lua 5.1 (no table.create) and a pre-sized table in LuaU
    
    local envExpr = Ast.IndexExpression(
        Ast.VariableExpression(compiler.scope, compiler.envVar),
        Ast.StringExpression("table")
    )
    
    -- table.create
    local tableCreateExpr = Ast.IndexExpression(
        envExpr,
        Ast.StringExpression("create")
    )
    
    -- Arguments for table.create
    local createArgs = { Ast.NumberExpression(hint.arraySize) }
    if hint.hashSize > 0 then
        -- LuaU doesn't support hash pre-sizing directly, but we can use the second arg
        -- as initial value (0) for array elements
        table.insert(createArgs, Ast.NumberExpression(0))
    end
    
    -- table.create(n, 0)
    local createCall = Ast.FunctionCallExpression(tableCreateExpr, createArgs)
    
    -- table.create and table.create(n, 0)
    local andExpr = Ast.AndExpression(tableCreateExpr, createCall)
    
    -- (table.create and table.create(n, 0)) or {}
    local fallbackExpr = Ast.OrExpression(andExpr, Ast.TableConstructorExpression({}))
    
    return fallbackExpr
end

-- ============================================================================
-- Block-Level Optimization
-- ============================================================================

-- Analyze table usage in a block to track growth patterns
-- This is used to detect tables that grow dynamically and suggest pre-sizing
function TablePresizing.analyzeTableGrowth(block, compiler)
    if not compiler.enableTablePresizing then
        return {}
    end
    
    local tableVars = {}  -- varId -> { maxSize, insertCount }
    
    visitast(block, function(node, data)
        -- Track table.insert calls
        if node.kind == AstKind.FunctionCallStatement or
           node.kind == AstKind.FunctionCallExpression then
            local base = node.base
            
            -- Check for table.insert pattern
            if base and base.kind == AstKind.IndexExpression then
                local tableBase = base.base
                local indexExpr = base.index
                
                if tableBase and tableBase.kind == AstKind.VariableExpression and
                   indexExpr and indexExpr.kind == AstKind.StringExpression and
                   indexExpr.value == "insert" then
                    -- This might be table.insert(t, ...)
                    local args = node.args or {}
                    if #args >= 1 then
                        local targetTable = args[1]
                        if targetTable and targetTable.kind == AstKind.VariableExpression then
                            local key = tostring(targetTable.scope) .. "_" .. tostring(targetTable.id)
                            tableVars[key] = tableVars[key] or { insertCount = 0, maxSize = 0 }
                            tableVars[key].insertCount = tableVars[key].insertCount + 1
                        end
                    end
                end
            end
        end
        
        -- Track direct indexing assignments: t[n] = value
        if node.kind == AstKind.AssignmentStatement then
            for _, lhs in ipairs(node.lhs or {}) do
                if lhs.kind == AstKind.AssignmentIndexing then
                    local base = lhs.base
                    local index = lhs.index
                    
                    if base and base.kind == AstKind.VariableExpression then
                        local key = tostring(base.scope) .. "_" .. tostring(base.id)
                        tableVars[key] = tableVars[key] or { insertCount = 0, maxSize = 0 }
                        
                        -- If index is a constant number, track max size
                        if index and index.kind == AstKind.NumberExpression then
                            local idx = index.value
                            if idx > tableVars[key].maxSize then
                                tableVars[key].maxSize = idx
                            end
                        else
                            tableVars[key].insertCount = tableVars[key].insertCount + 1
                        end
                    end
                end
            end
        end
    end, nil, nil)
    
    return tableVars
end

-- ============================================================================
-- Integration with Compiler
-- ============================================================================

-- Called when compiling a TableConstructorExpression
-- Returns (shouldUseOptimized, optimizedExpr) or (false, nil)
function TablePresizing.optimizeTableConstructor(tableExpr, compiler, scope)
    local shouldOptimize, hint = TablePresizing.shouldOptimize(tableExpr, compiler)
    
    if not shouldOptimize then
        return false, nil
    end
    
    -- For tables with only a few entries being pre-sized, check if inline is better
    -- Only optimize larger tables where pre-sizing gives real benefit
    if hint.arraySize + hint.hashSize < 8 then
        -- Small tables: inline is often faster than table.create call
        return false, nil
    end
    
    -- Generate optimized creation pattern
    local optimizedExpr = TablePresizing.generateOptimizedCreate(
        hint,
        tableExpr.entries,
        compiler,
        scope
    )
    
    return true, optimizedExpr, hint
end

-- Initialize table pre-sizing for a compilation
function TablePresizing.init(compiler)
    if not compiler.enableTablePresizing then
        return
    end
    
    -- Register tracking for table growth analysis
    compiler.tableGrowthTracking = {}
end

return TablePresizing

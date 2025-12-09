-- vararg_optimization.lua
-- P18: Vararg Optimization
-- Optimize common vararg patterns for better performance

local Ast = require("moonstar.ast")
local AstKind = Ast.AstKind
local visitast = require("moonstar.visitast")

local VarargOptimization = {}

-- ============================================================================
-- Vararg Pattern Detection
-- ============================================================================

-- Pattern 1: select('#', ...) - length of varargs
-- This is commonly used and can be cached at function entry
function VarargOptimization.isSelectLengthPattern(expr)
    if not expr or expr.kind ~= AstKind.FunctionCallExpression then
        return false
    end
    
    local base = expr.base
    local args = expr.args or {}
    
    -- Check for select base
    if not base or base.kind ~= AstKind.VariableExpression then
        return false
    end
    
    -- Check for select('#', ...) pattern
    if #args >= 2 then
        local firstArg = args[1]
        local secondArg = args[2]
        
        if firstArg and firstArg.kind == AstKind.StringExpression and 
           firstArg.value == "#" and
           secondArg and secondArg.kind == AstKind.VarargExpression then
            return true
        end
    end
    
    return false
end

-- Pattern 2: {...}[n] - immediate indexed access to vararg table
-- Can be optimized to select(n, ...) to avoid table allocation
function VarargOptimization.isImmediateVarargIndex(expr)
    if not expr or expr.kind ~= AstKind.IndexExpression then
        return false, nil
    end
    
    local base = expr.base
    local index = expr.index
    
    -- Check if base is a table constructor with only vararg
    if not base or base.kind ~= AstKind.TableConstructorExpression then
        return false, nil
    end
    
    local entries = base.entries or {}
    if #entries ~= 1 then
        return false, nil
    end
    
    local entry = entries[1]
    if not entry or entry.kind ~= AstKind.TableEntry then
        return false, nil
    end
    
    local value = entry.value
    if not value or value.kind ~= AstKind.VarargExpression then
        return false, nil
    end
    
    -- Check if index is a constant number
    if index and index.kind == AstKind.NumberExpression then
        return true, index.value
    end
    
    return false, nil
end

-- Pattern 3: f(...) - direct forwarding of varargs
-- Already handled well by the VM, but can be optimized
function VarargOptimization.isDirectForwarding(callExpr)
    if not callExpr or 
       (callExpr.kind ~= AstKind.FunctionCallExpression and
        callExpr.kind ~= AstKind.PassSelfFunctionCallExpression) then
        return false
    end
    
    local args = callExpr.args or {}
    
    -- Check if the only argument (or last argument) is vararg
    if #args >= 1 then
        local lastArg = args[#args]
        if lastArg and lastArg.kind == AstKind.VarargExpression then
            return true, #args == 1  -- isOnlyArg
        end
    end
    
    return false, false
end

-- ============================================================================
-- Optimization Tracking
-- ============================================================================

-- Track vararg usage in a function for optimization opportunities
function VarargOptimization.analyzeFunction(funcDef, compiler)
    if not compiler.enableVarargOptimization then
        return nil
    end
    
    local analysis = {
        hasVarargs = false,
        selectLengthCount = 0,
        immediateIndexCount = 0,
        forwardingCount = 0,
        otherUseCount = 0,
        selectLengthLocations = {},
        canCacheLength = false
    }
    
    -- Check if function has varargs
    local args = funcDef.args or {}
    for _, arg in ipairs(args) do
        if arg.kind == AstKind.VarargExpression then
            analysis.hasVarargs = true
            break
        end
    end
    
    if not analysis.hasVarargs then
        return nil
    end
    
    -- Analyze usage patterns in function body
    visitast(funcDef.body, function(node, data)
        -- Check for select('#', ...)
        if VarargOptimization.isSelectLengthPattern(node) then
            analysis.selectLengthCount = analysis.selectLengthCount + 1
            table.insert(analysis.selectLengthLocations, node)
            return
        end
        
        -- Check for {...}[n]
        local isImmediate, index = VarargOptimization.isImmediateVarargIndex(node)
        if isImmediate then
            analysis.immediateIndexCount = analysis.immediateIndexCount + 1
            return
        end
        
        -- Check for f(...)
        local isForwarding, isOnlyArg = VarargOptimization.isDirectForwarding(node)
        if isForwarding then
            analysis.forwardingCount = analysis.forwardingCount + 1
            return
        end
        
        -- Other vararg uses
        if node.kind == AstKind.VarargExpression then
            analysis.otherUseCount = analysis.otherUseCount + 1
        end
    end, nil, nil)
    
    -- Determine if we can cache length
    -- Cache if:
    -- - Multiple select('#', ...) calls
    -- - No other vararg uses that might mutate (they can't, but for analysis simplicity)
    analysis.canCacheLength = analysis.selectLengthCount > 1
    
    return analysis
end

-- ============================================================================
-- Optimization Transformations
-- ============================================================================

-- Transform select('#', ...) to use a cached length variable
-- This is done at function entry to avoid repeated calls
function VarargOptimization.emitCachedLength(compiler, scope, varargReg)
    if not compiler.enableVarargOptimization then
        return nil
    end
    
    -- Create a local variable for cached length
    local lengthVar = scope:addVariable()
    
    -- Emit: local _varargLen = select('#', unpack(varargReg))
    -- In the VM context, this becomes: local _varargLen = #varargReg
    
    -- The varargReg is already a table containing the varargs
    -- So we can just use the # operator
    local lenExpr = Ast.LenExpression(Ast.VariableExpression(scope, varargReg))
    
    return lengthVar, lenExpr
end

-- Transform {...}[n] to select(n, ...)
-- Avoids table allocation for immediate indexed access
function VarargOptimization.transformImmediateIndex(index, compiler, scope, varargReg)
    if not compiler.enableVarargOptimization then
        return nil
    end
    
    -- In the VM context, varargReg is already a table
    -- So {...}[n] is equivalent to varargReg[n]
    -- This is already optimal in our VM implementation
    
    -- For better semantics matching select(n, ...), we could use:
    -- select(n, unpack(varargReg))
    -- But direct indexing is faster
    
    local indexExpr = Ast.IndexExpression(
        Ast.VariableExpression(scope, varargReg),
        Ast.NumberExpression(index)
    )
    
    return indexExpr
end

-- ============================================================================
-- Compiler Integration
-- ============================================================================

-- Called at function entry to set up vararg optimizations
function VarargOptimization.initFunction(compiler, funcDef, scope, varargReg)
    if not compiler.enableVarargOptimization then
        return {}
    end
    
    local analysis = VarargOptimization.analyzeFunction(funcDef, compiler)
    if not analysis then
        return {}
    end
    
    local initStatements = {}
    
    -- If multiple select('#', ...) calls, cache the length
    if analysis.canCacheLength then
        local lengthVar, lenExpr = VarargOptimization.emitCachedLength(compiler, scope, varargReg)
        
        if lengthVar then
            -- Store for later use
            compiler.cachedVarargLength = lengthVar
            
            -- Emit the length caching statement
            table.insert(initStatements, Ast.LocalVariableDeclaration(
                scope,
                { lengthVar },
                { lenExpr }
            ))
        end
    end
    
    -- Store analysis for use during compilation
    compiler.varargAnalysis = analysis
    
    return initStatements
end

-- Check if we can use cached length instead of select('#', ...)
function VarargOptimization.getCachedLength(compiler, scope)
    if not compiler.enableVarargOptimization then
        return nil
    end
    
    if compiler.cachedVarargLength then
        return Ast.VariableExpression(scope, compiler.cachedVarargLength)
    end
    
    return nil
end

-- Optimize a vararg-related expression
function VarargOptimization.optimizeExpression(expr, compiler, scope, funcDepth)
    if not compiler.enableVarargOptimization then
        return false, nil
    end
    
    -- Pattern 1: select('#', ...) -> cached length or #varargReg
    if VarargOptimization.isSelectLengthPattern(expr) then
        local cached = VarargOptimization.getCachedLength(compiler, scope)
        if cached then
            return true, cached
        end
        
        -- Fallback: use #varargReg directly
        if compiler.varargReg then
            return true, Ast.LenExpression(
                Ast.VariableExpression(scope, compiler.varargReg)
            )
        end
    end
    
    -- Pattern 2: {...}[n] -> varargReg[n]
    local isImmediate, index = VarargOptimization.isImmediateVarargIndex(expr)
    if isImmediate and compiler.varargReg then
        return true, Ast.IndexExpression(
            Ast.VariableExpression(scope, compiler.varargReg),
            Ast.NumberExpression(index)
        )
    end
    
    return false, nil
end

-- Cleanup at end of function
function VarargOptimization.cleanupFunction(compiler)
    compiler.cachedVarargLength = nil
    compiler.varargAnalysis = nil
end

return VarargOptimization

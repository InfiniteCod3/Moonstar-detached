-- inlining.lua
-- P12: Small Function Inlining
-- Inline small local functions at call sites for improved performance

local Ast = require("moonstar.ast")
local AstKind = Ast.AstKind
local visitast = require("moonstar.visitast")

local Inlining = {}

-- ============================================================================
-- Configuration defaults
-- ============================================================================
local DEFAULT_MAX_STATEMENTS = 10    -- Max statements in function body
local DEFAULT_MAX_PARAMETERS = 5     -- Max parameters for inlining
local DEFAULT_MAX_INLINE_DEPTH = 3   -- Max nesting depth for inline expansions

-- ============================================================================
-- Function Analysis
-- ============================================================================

-- Check if a function definition is eligible for inlining
-- Criteria:
--   - ≤ maxStatements statements
--   - ≤ maxParameters parameters
--   - No recursion (direct or indirect)
--   - No varargs in function definition
--   - No upvalue captures beyond the immediate scope
--   - Single return value or no return (for simplicity)
function Inlining.isInlineable(funcDef, config)
    if not funcDef or not funcDef.body then
        return false, "no body"
    end
    
    local maxStatements = config.maxInlineFunctionSize or DEFAULT_MAX_STATEMENTS
    local maxParams = config.maxInlineParameters or DEFAULT_MAX_PARAMETERS
    
    -- Check parameter count
    local args = funcDef.args or {}
    if #args > maxParams then
        return false, "too many parameters"
    end
    
    -- Check for varargs in function definition
    for _, arg in ipairs(args) do
        if arg.kind == AstKind.VarargExpression then
            return false, "contains varargs"
        end
    end
    
    -- Count statements in function body
    local stmtCount = Inlining.countStatements(funcDef.body)
    if stmtCount > maxStatements then
        return false, "too many statements"
    end
    
    -- Check for complex patterns that prevent inlining
    local hasComplexPatterns = false
    local complexReason = nil
    
    visitast(funcDef.body, function(node, data)
        if hasComplexPatterns then return end
        
        -- No nested function definitions (closures)
        if node.kind == AstKind.FunctionDeclaration or
           node.kind == AstKind.LocalFunctionDeclaration or
           node.kind == AstKind.FunctionLiteralExpression then
            hasComplexPatterns = true
            complexReason = "contains nested function"
            return
        end
        
        -- No vararg expressions in body
        if node.kind == AstKind.VarargExpression then
            hasComplexPatterns = true
            complexReason = "uses varargs"
            return
        end
        
        -- No goto statements (control flow complexity)
        if node.kind == AstKind.GotoStatement or node.kind == AstKind.LabelStatement then
            hasComplexPatterns = true
            complexReason = "uses goto/labels"
            return
        end
    end, nil, nil)
    
    if hasComplexPatterns then
        return false, complexReason
    end
    
    -- Check for multiple return statements or complex return patterns
    local returnCount, returnInfo = Inlining.analyzeReturns(funcDef.body)
    if returnCount > 1 then
        -- Multiple returns are tricky to inline properly
        return false, "multiple returns"
    end
    
    if returnInfo.hasMultiValue then
        return false, "multi-value return"
    end
    
    return true, nil
end

-- Count the number of statements in a block (recursive for nested blocks)
function Inlining.countStatements(block)
    if not block or not block.statements then
        return 0
    end
    
    local count = 0
    for _, stmt in ipairs(block.statements) do
        count = count + 1
        
        -- Count nested statements in control structures
        if stmt.kind == AstKind.IfStatement then
            count = count + Inlining.countStatements(stmt.body)
            for _, elseif_ in ipairs(stmt.elseifs or {}) do
                count = count + Inlining.countStatements(elseif_.body)
            end
            if stmt.elsebody then
                count = count + Inlining.countStatements(stmt.elsebody)
            end
        elseif stmt.kind == AstKind.WhileStatement or
               stmt.kind == AstKind.RepeatStatement or
               stmt.kind == AstKind.ForStatement or
               stmt.kind == AstKind.ForInStatement then
            count = count + Inlining.countStatements(stmt.body)
        elseif stmt.kind == AstKind.DoStatement then
            count = count + Inlining.countStatements(stmt.body)
        end
    end
    
    return count
end

-- Analyze return statements in a function body
function Inlining.analyzeReturns(block)
    local returnCount = 0
    local hasMultiValue = false
    
    visitast(block, function(node, data)
        if node.kind == AstKind.ReturnStatement then
            returnCount = returnCount + 1
            
            -- Check if return has multiple values
            if node.args and #node.args > 1 then
                hasMultiValue = true
            end
            
            -- Check if single return is a function call or vararg (multi-value)
            if node.args and #node.args == 1 then
                local arg = node.args[1]
                if arg.kind == AstKind.FunctionCallExpression or
                   arg.kind == AstKind.PassSelfFunctionCallExpression or
                   arg.kind == AstKind.VarargExpression then
                    hasMultiValue = true
                end
            end
        end
    end, nil, nil)
    
    return returnCount, { hasMultiValue = hasMultiValue }
end

-- ============================================================================
-- Inlining Registry
-- ============================================================================

-- Track inlineable functions during compilation
-- Maps function ID -> function definition and metadata
function Inlining.createRegistry(compiler)
    return {
        functions = {},      -- id -> { def = node, scope = scope, isInlineable = bool }
        callSites = {},      -- list of { caller, callee, location }
        inlineDepth = {},    -- id -> current inline depth
        maxDepth = compiler.maxInlineDepth or DEFAULT_MAX_INLINE_DEPTH
    }
end

-- Register a local function declaration for potential inlining
function Inlining.registerFunction(registry, scope, id, funcDef, config)
    local isInlineable, reason = Inlining.isInlineable(funcDef, config)
    
    registry.functions[scope] = registry.functions[scope] or {}
    registry.functions[scope][id] = {
        def = funcDef,
        isInlineable = isInlineable,
        reason = reason,
        callCount = 0
    }
    
    return isInlineable
end

-- Look up a function for potential inlining
function Inlining.lookupFunction(registry, scope, id)
    if not registry.functions[scope] then
        return nil
    end
    return registry.functions[scope][id]
end

-- ============================================================================
-- Parameter Substitution
-- ============================================================================

-- Clone an AST node with parameter substitution
-- This creates a copy of the function body with parameters replaced by arguments
function Inlining.cloneWithSubstitution(node, paramMap, scope)
    if not node then return nil end
    
    -- Handle variable expressions - substitute if it's a parameter
    if node.kind == AstKind.VariableExpression then
        local key = tostring(node.scope) .. "_" .. tostring(node.id)
        if paramMap[key] then
            -- Return a clone of the argument expression
            return Inlining.deepClone(paramMap[key])
        end
        -- Return the original variable reference
        return node
    end
    
    -- For other nodes, recursively clone children
    local clone = {}
    for k, v in pairs(node) do
        if type(v) == "table" and k ~= "scope" and k ~= "parentScope" then
            if type(k) == "number" then
                -- Array element
                clone[k] = Inlining.cloneWithSubstitution(v, paramMap, scope)
            elseif v.kind then
                -- AST node
                clone[k] = Inlining.cloneWithSubstitution(v, paramMap, scope)
            else
                -- Regular table, shallow copy
                clone[k] = v
            end
        else
            clone[k] = v
        end
    end
    
    return clone
end

-- Deep clone an AST node
function Inlining.deepClone(node)
    if not node then return nil end
    if type(node) ~= "table" then return node end
    
    local clone = {}
    for k, v in pairs(node) do
        if type(v) == "table" and k ~= "scope" and k ~= "parentScope" then
            clone[k] = Inlining.deepClone(v)
        else
            clone[k] = v
        end
    end
    
    return clone
end

-- ============================================================================
-- Inline Expansion
-- ============================================================================

-- Check if a function call can be inlined at this site
function Inlining.canInlineCall(registry, callExpr, compiler)
    if not compiler.enableFunctionInlining then
        return false, nil
    end
    
    -- Only handle simple variable calls (not method calls or computed calls)
    local base = callExpr.base
    if not base or base.kind ~= AstKind.VariableExpression then
        return false, nil
    end
    
    -- Look up the function
    local funcInfo = Inlining.lookupFunction(registry, base.scope, base.id)
    if not funcInfo or not funcInfo.isInlineable then
        return false, nil
    end
    
    -- Check inline depth
    local currentDepth = registry.inlineDepth[base.scope] or 0
    if currentDepth >= registry.maxDepth then
        return false, nil
    end
    
    -- Check argument count matches parameter count
    local funcDef = funcInfo.def
    local args = callExpr.args or {}
    local params = funcDef.args or {}
    
    -- For now, require exact match (could be relaxed with nil padding)
    if #args ~= #params then
        return false, nil
    end
    
    return true, funcInfo
end

-- Generate inlined code for a function call
-- Returns a list of statements to emit and the result expression
function Inlining.expandInline(funcInfo, callArgs, compiler, funcDepth)
    local funcDef = funcInfo.def
    local params = funcDef.args or {}
    
    -- Build parameter -> argument mapping
    local paramMap = {}
    for i, param in ipairs(params) do
        if param.kind == AstKind.VariableExpression then
            local key = tostring(param.scope) .. "_" .. tostring(param.id)
            paramMap[key] = callArgs[i]
        end
    end
    
    -- Clone the function body with parameter substitution
    local inlinedBody = Inlining.cloneWithSubstitution(funcDef.body, paramMap, compiler.activeBlock.scope)
    
    -- Extract return value if present
    local resultExpr = nil
    if inlinedBody and inlinedBody.statements then
        local lastStmt = inlinedBody.statements[#inlinedBody.statements]
        if lastStmt and lastStmt.kind == AstKind.ReturnStatement then
            -- Remove the return statement
            table.remove(inlinedBody.statements)
            -- Extract the return value
            if lastStmt.args and #lastStmt.args > 0 then
                resultExpr = lastStmt.args[1]
            end
        end
    end
    
    return inlinedBody, resultExpr
end

-- ============================================================================
-- Optimization Interface
-- ============================================================================

-- Initialize inlining for a compilation
function Inlining.init(compiler)
    if not compiler.enableFunctionInlining then
        return nil
    end
    
    compiler.inliningRegistry = Inlining.createRegistry(compiler)
    return compiler.inliningRegistry
end

-- Track a local function declaration
function Inlining.trackFunction(compiler, scope, id, funcDef)
    if not compiler.inliningRegistry then
        return false
    end
    
    return Inlining.registerFunction(
        compiler.inliningRegistry,
        scope,
        id,
        funcDef,
        compiler
    )
end

-- Attempt to inline a function call
-- Returns (shouldInline, inlinedBody, resultExpr)
function Inlining.tryInline(compiler, callExpr, funcDepth)
    if not compiler.inliningRegistry then
        return false, nil, nil
    end
    
    local canInline, funcInfo = Inlining.canInlineCall(
        compiler.inliningRegistry,
        callExpr,
        compiler
    )
    
    if not canInline then
        return false, nil, nil
    end
    
    -- Increment call count for statistics
    funcInfo.callCount = funcInfo.callCount + 1
    
    -- Expand inline
    local inlinedBody, resultExpr = Inlining.expandInline(
        funcInfo,
        callExpr.args or {},
        compiler,
        funcDepth
    )
    
    return true, inlinedBody, resultExpr
end

return Inlining

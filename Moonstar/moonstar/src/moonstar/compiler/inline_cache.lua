-- inline_cache.lua
-- P9: Inline Caching for Globals
-- Cache resolved global lookups for hot paths to avoid repeated _ENV indexing
-- This is integrated during the global access tracking phase

local Ast = require("moonstar.ast");
local AstKind = Ast.AstKind;

local InlineCache = {}

-- ============================================================================
-- Immutable Globals Whitelist
-- These globals are known to be immutable in standard Lua/LuaU
-- and can always be safely cached
-- ============================================================================

InlineCache.immutableGlobals = {
    -- Math library
    ["math"] = true,
    ["math.abs"] = true,
    ["math.acos"] = true,
    ["math.asin"] = true,
    ["math.atan"] = true,
    ["math.atan2"] = true,
    ["math.ceil"] = true,
    ["math.cos"] = true,
    ["math.cosh"] = true,
    ["math.deg"] = true,
    ["math.exp"] = true,
    ["math.floor"] = true,
    ["math.fmod"] = true,
    ["math.frexp"] = true,
    ["math.huge"] = true,
    ["math.ldexp"] = true,
    ["math.log"] = true,
    ["math.log10"] = true,
    ["math.max"] = true,
    ["math.min"] = true,
    ["math.modf"] = true,
    ["math.pi"] = true,
    ["math.pow"] = true,
    ["math.rad"] = true,
    ["math.random"] = true,
    ["math.randomseed"] = true,
    ["math.sin"] = true,
    ["math.sinh"] = true,
    ["math.sqrt"] = true,
    ["math.tan"] = true,
    ["math.tanh"] = true,
    
    -- String library
    ["string"] = true,
    ["string.byte"] = true,
    ["string.char"] = true,
    ["string.dump"] = true,
    ["string.find"] = true,
    ["string.format"] = true,
    ["string.gmatch"] = true,
    ["string.gsub"] = true,
    ["string.len"] = true,
    ["string.lower"] = true,
    ["string.match"] = true,
    ["string.rep"] = true,
    ["string.reverse"] = true,
    ["string.sub"] = true,
    ["string.upper"] = true,
    
    -- Table library
    ["table"] = true,
    ["table.concat"] = true,
    ["table.insert"] = true,
    ["table.maxn"] = true,
    ["table.remove"] = true,
    ["table.sort"] = true,
    ["table.unpack"] = true,
    ["table.pack"] = true,
    ["table.move"] = true,
    ["table.create"] = true, -- LuaU
    ["table.find"] = true,   -- LuaU
    ["table.clear"] = true,  -- LuaU
    ["table.freeze"] = true, -- LuaU
    ["table.isfrozen"] = true, -- LuaU
    ["table.clone"] = true,  -- LuaU
    
    -- Core functions
    ["assert"] = true,
    ["collectgarbage"] = true,
    ["error"] = true,
    ["getmetatable"] = true,
    ["ipairs"] = true,
    ["next"] = true,
    ["pairs"] = true,
    ["pcall"] = true,
    ["print"] = true,
    ["rawequal"] = true,
    ["rawget"] = true,
    ["rawset"] = true,
    ["select"] = true,
    ["setmetatable"] = true,
    ["tonumber"] = true,
    ["tostring"] = true,
    ["type"] = true,
    ["unpack"] = true,
    ["xpcall"] = true,
    
    -- Bit library (Lua 5.2+ / LuaJIT / LuaU)
    ["bit32"] = true,
    ["bit32.arshift"] = true,
    ["bit32.band"] = true,
    ["bit32.bnot"] = true,
    ["bit32.bor"] = true,
    ["bit32.btest"] = true,
    ["bit32.bxor"] = true,
    ["bit32.extract"] = true,
    ["bit32.lrotate"] = true,
    ["bit32.lshift"] = true,
    ["bit32.replace"] = true,
    ["bit32.rrotate"] = true,
    ["bit32.rshift"] = true,
    
    -- Coroutine library
    ["coroutine"] = true,
    ["coroutine.create"] = true,
    ["coroutine.resume"] = true,
    ["coroutine.running"] = true,
    ["coroutine.status"] = true,
    ["coroutine.wrap"] = true,
    ["coroutine.yield"] = true,
    
    -- OS library (subset - some functions have side effects)
    ["os"] = true,
    ["os.clock"] = true,
    ["os.date"] = true,
    ["os.difftime"] = true,
    ["os.time"] = true,
    
    -- Debug library (read-only functions)
    ["debug"] = true,
    ["debug.traceback"] = true,
}

-- ============================================================================
-- Check if a global is safe to cache (immutable)
-- ============================================================================

function InlineCache.isImmutable(name)
    return InlineCache.immutableGlobals[name] == true
end

-- ============================================================================
-- Inline Cache Context Management
-- ============================================================================

-- Create a new inline cache context for a compilation unit
function InlineCache.createContext()
    return {
        accessCounts = {},    -- name -> count
        cachedVars = {},      -- name -> variable reference
        enabled = true
    }
end

-- Track a global access
function InlineCache.trackAccess(context, name)
    if not context or not context.enabled then
        return
    end
    context.accessCounts[name] = (context.accessCounts[name] or 0) + 1
end

-- Get the access count for a global
function InlineCache.getAccessCount(context, name)
    if not context then
        return 0
    end
    return context.accessCounts[name] or 0
end

-- ============================================================================
-- Determine which globals should be cached based on access patterns
-- ============================================================================

function InlineCache.selectGlobalsToCache(compiler, threshold)
    threshold = threshold or compiler.inlineCacheThreshold or 5
    
    local toCache = {}
    
    for name, count in pairs(compiler.globalAccessCounts) do
        if count >= threshold then
            -- Either already marked as immutable, or accessed frequently enough
            if InlineCache.isImmutable(name) or count >= threshold * 2 then
                table.insert(toCache, {
                    name = name,
                    count = count,
                    isImmutable = InlineCache.isImmutable(name)
                })
            end
        end
    end
    
    -- Sort by access count (descending)
    table.sort(toCache, function(a, b)
        return a.count > b.count
    end)
    
    return toCache
end

-- ============================================================================
-- Generate cache code for a global
-- This creates: local __cache_X = _ENV["globalName"]
-- ============================================================================

function InlineCache.generateCacheDeclaration(compiler, name, cacheVar)
    local scope = compiler.containerFuncScope
    
    -- Create initialization expression: _ENV["name"] or _ENV["base"]["member"]
    local initExpr
    
    if name:find(".", 1, true) then
        -- Nested global: a.b.c -> _ENV["a"]["b"]["c"]
        local parts = {}
        for part in name:gmatch("[^.]+") do
            table.insert(parts, part)
        end
        
        initExpr = Ast.IndexExpression(
            Ast.VariableExpression(compiler.scope, compiler.envVar),
            Ast.StringExpression(parts[1])
        )
        for i = 2, #parts do
            initExpr = Ast.IndexExpression(initExpr, Ast.StringExpression(parts[i]))
        end
        
        scope:addReferenceToHigherScope(compiler.scope, compiler.envVar)
    else
        -- Simple global: _ENV["name"]
        scope:addReferenceToHigherScope(compiler.scope, compiler.envVar)
        initExpr = Ast.IndexExpression(
            Ast.VariableExpression(compiler.scope, compiler.envVar),
            Ast.StringExpression(name)
        )
    end
    
    -- Return the declaration statement
    return Ast.LocalVariableDeclaration(scope, {cacheVar}, {initExpr})
end

-- ============================================================================
-- Hook into the existing constant hoisting system
-- P9 enhances P3's constant hoisting with more intelligent caching decisions
-- ============================================================================

function InlineCache.enhanceHoisting(compiler)
    if not compiler.enableInlineCaching then
        return
    end
    
    local threshold = compiler.inlineCacheThreshold or 5
    
    -- Mark immutable globals for preferential hoisting
    for name, count in pairs(compiler.globalAccessCounts) do
        if InlineCache.isImmutable(name) then
            -- Immutable globals only need 2 accesses to be worth caching
            -- (lower threshold than mutable globals)
            if count >= 2 then
                -- Boost the count to ensure it meets the hoisting threshold
                compiler.globalAccessCounts[name] = math.max(count, compiler.constantHoistThreshold)
            end
        end
    end
end

-- ============================================================================
-- Integration with expressions.lua for on-the-fly caching
-- ============================================================================

-- Check if we should use a cached value for a global access
function InlineCache.shouldUseCache(compiler, name)
    if not compiler.enableInlineCaching then
        return false
    end
    
    local threshold = compiler.inlineCacheThreshold or 5
    local count = compiler.globalAccessCounts[name] or 0
    
    -- Use cache if:
    -- 1. It's an immutable global accessed 2+ times, OR
    -- 2. It's any global accessed threshold+ times
    return (InlineCache.isImmutable(name) and count >= 2) or (count >= threshold)
end

-- ============================================================================
-- Runtime access pattern tracking (for future optimization)
-- This could be used to generate profiling information
-- ============================================================================

function InlineCache.generateAccessProfile(compiler)
    local profile = {
        immutableAccesses = 0,
        mutableAccesses = 0,
        cachedAccesses = 0,
        uncachedAccesses = 0,
        topGlobals = {}
    }
    
    local threshold = compiler.inlineCacheThreshold or 5
    
    for name, count in pairs(compiler.globalAccessCounts) do
        if InlineCache.isImmutable(name) then
            profile.immutableAccesses = profile.immutableAccesses + count
        else
            profile.mutableAccesses = profile.mutableAccesses + count
        end
        
        if InlineCache.shouldUseCache(compiler, name) then
            profile.cachedAccesses = profile.cachedAccesses + count
        else
            profile.uncachedAccesses = profile.uncachedAccesses + count
        end
        
        table.insert(profile.topGlobals, { name = name, count = count })
    end
    
    -- Sort top globals by count
    table.sort(profile.topGlobals, function(a, b) return a.count > b.count end)
    
    -- Keep only top 20
    while #profile.topGlobals > 20 do
        table.remove(profile.topGlobals)
    end
    
    return profile
end

return InlineCache

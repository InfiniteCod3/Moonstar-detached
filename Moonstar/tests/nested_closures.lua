-- Nested closures with multiple upvalue levels
-- Tests proper upvalue handling in obfuscated code

local function createMultiplier(factor)
    local cached = {}
    
    return function(x)
        if cached[x] then
            return cached[x]
        end
        
        local result = x * factor
        cached[x] = result
        
        -- Return another closure that captures both outer scopes
        return result, function()
            factor = factor + 1
            cached = {}  -- Clear cache when factor changes
            return factor
        end
    end
end

local double = createMultiplier(2)
local val1, modifier = double(5)
print("5 * 2 =", val1)

-- Modify the outer state
print("New factor:", modifier())

-- Test with modified factor
local val2, _ = double(5)
print("5 * 3 =", val2)

-- Test caching behavior
local val3, _ = double(5)
print("Cached 5 * 3 =", val3)

-- Chain of closures with shared state
local function createChain()
    local state = 0
    
    local function increment()
        state = state + 1
        return state
    end
    
    local function decrement()
        state = state - 1
        return state
    end
    
    local function get()
        return state
    end
    
    local function modify(fn)
        state = fn(state)
        return state
    end
    
    return {
        inc = increment,
        dec = decrement,
        get = get,
        modify = modify
    }
end

local chain = createChain()
print("Initial:", chain.get())
print("After inc:", chain.inc())
print("After inc:", chain.inc())
print("After dec:", chain.dec())
print("After modify:", chain.modify(function(x) return x * 10 end))

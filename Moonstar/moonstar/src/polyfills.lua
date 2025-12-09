-- This Script is Part of the Moonstar Obfuscator
--
-- polyfills.lua
--
-- Provides Lua 5.1 compatibility polyfills for environments that need them.
-- This module is shared between the CLI entry point and library module.

local Polyfills = {}

--------------------------------------------------------------------------------
-- math.random Fix for Large Numbers
--------------------------------------------------------------------------------
-- Lua 5.1's math.random can't handle numbers larger than 2^31-1.
-- This polyfill provides a workaround for large number ranges.

function Polyfills.applyMathRandomFix()
    local needsFix = not pcall(function()
        return math.random(1, 2^40)
    end)

    if not needsFix then return end

    local nativeRandom = math.random

    math.random = function(a, b)
        -- No arguments: return [0, 1)
        if a == nil and b == nil then
            return nativeRandom()
        end

        -- Single argument: return [1, a]
        if b == nil then
            return math.random(1, a)
        end

        -- Ensure a <= b
        if a > b then
            a, b = b, a
        end

        local range = b - a

        -- Validate range
        if range < 0 then
            error(string.format("Invalid interval: a=%s, b=%s", tostring(a), tostring(b)))
        end

        -- Handle degenerate case
        if range == 0 then
            return a
        end

        -- Use manual calculation for large ranges, negatives, or values >= 2^31
        local MAX_NATIVE = 2^31 - 1
        if range > MAX_NATIVE or a < 0 or b >= 2^31 then
            return math.floor(nativeRandom() * range + a)
        end

        -- Use native random with rounded integers
        local intA = math.floor(a + 0.5)
        local intB = math.floor(b + 0.5)

        if intA > intB then
            intA, intB = intB, intA
        end

        if intA == intB then
            return intA
        end

        return nativeRandom(intA, intB)
    end
end

--------------------------------------------------------------------------------
-- newproxy Polyfill
--------------------------------------------------------------------------------
-- Some Lua environments don't have newproxy. This provides a basic fallback.
-- Note: This fallback uses tables instead of userdata, which may behave
-- slightly differently in edge cases involving type() checks.

function Polyfills.applyNewproxyPolyfill()
    if _G.newproxy then return end

    _G.newproxy = function(addMetatable)
        if addMetatable then
            return setmetatable({}, {})
        end
        return {}
    end
end

--------------------------------------------------------------------------------
-- Apply All Polyfills
--------------------------------------------------------------------------------
-- Convenience function to apply all polyfills at once.

function Polyfills.apply()
    Polyfills.applyMathRandomFix()
    Polyfills.applyNewproxyPolyfill()
end

return Polyfills

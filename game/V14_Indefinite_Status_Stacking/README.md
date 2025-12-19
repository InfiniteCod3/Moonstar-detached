# V14 - Indefinite Status Stacking

## Severity: HIGH

## Summary
Multiple skills apply status effects (particularly IFrames/invincibility) WITHOUT specifying a duration. These can be stacked indefinitely by rapidly using teleport-based skills, resulting in permanent invincibility.

## Vulnerability Details

### Root Cause
The `teleport` functions in skill modules apply `IFrames` status without a duration parameter, and these are only removed under specific conditions that can be avoided.

### Affected Code Pattern
```lua
-- BladeStormModule_ID98.luau:126
table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames"))  -- NO DURATION!

-- SiphonModule_ID107.luau:74
table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "IFrames"))  -- NO DURATION!

-- The removal only happens under specific conditions:
task.delay(0.3, function()
    var33_upvw -= 1
    if var33_upvw <= 0 then  -- Only removes if counter reaches 0
        -- cleanup code
    end
end)
```

### Attack Vector
1. Rapidly trigger teleport functions in skills
2. Each teleport adds IFrames without duration
3. Counter manipulation or timing exploits prevent cleanup
4. Status effects stack indefinitely
5. Player becomes permanently invincible

## Impact
- Permanent invincibility (IFrames never expire)
- Status effect stacking (Freeze immunity, Stun immunity)
- Complete combat advantage
- Game-breaking in PvP scenarios

## Affected Files
| File | Line | Status Applied |
|------|------|----------------|
| BladeStormModule_ID98.luau | 126 | IFrames (no duration) |
| BladeStormModule_ID98.luau | 201 | IFrames (skill-level) |
| SiphonModule_ID107.luau | 74 | IFrames (no duration) |
| Multiple teleport functions | Various | IFrames stacking |

## Proof of Concept
See `poc.luau` in this folder.

## Remediation
```lua
-- Always specify a maximum duration for status effects
local MAX_IFRAME_DURATION = 0.5
table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames", MAX_IFRAME_DURATION))

-- Add server-side status effect limits
local MAX_IFRAMES_STACKS = 1
if countActiveStatus(player, "IFrames") >= MAX_IFRAMES_STACKS then
    return -- Don't apply more
end
```

## References
- CWE-400: Uncontrolled Resource Consumption
- Game Design: Status Effect Management

# V17 - Physics Constraint Race Condition

## Severity: MEDIUM

## Summary
Skills destroy existing BodyVelocity/BodyPosition constraints before applying new ones. This creates a race condition where clients can inject their own physics objects that survive the cleanup, or prevent legitimate constraints from being applied.

## Vulnerability Details

### Root Cause
The cleanup loop iterates through descendants and destroys physics constraints, but there's no atomic lock preventing new constraints from being added during iteration.

### Affected Code Pattern
```lua
-- BladeStormModule_ID98.luau:242-245
for _, v_11 in v_9:GetDescendants() do
    if v_11:IsA("BodyVelocity") or v_11:IsA("BodyPosition") then
        v_11:Destroy()
    end
end
-- NEW constraint added AFTER the loop:
local BodyVelocity_2 = Instance.new("BodyVelocity", v_9.Head)
BodyVelocity_2.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
```

### Attack Vector
1. Monitor for skill activation
2. During the cleanup loop, inject custom BodyVelocity
3. Custom constraint survives because it's added after iteration starts
4. Or: Add constraint with different name/type to bypass IsA check
5. Result: Custom physics behavior alongside or instead of intended

## Impact
- Fly hacks (inject upward BodyVelocity that survives)
- Speed hacks (inject forward BodyVelocity)
- Immunity to knockback (inject zero-velocity constraint)
- Desync between server physics and client state

## Affected Files
| File | Line | Pattern |
|------|------|---------|
| BladeStormModule_ID98.luau | 242-245 | GetDescendants cleanup loop |
| FluidMotionModule_ID188.luau | 139 | Same pattern |
| GreatGeyserModule_ID184.luau | 95 | Same pattern |
| LightspeedSlashesModule_ID169.luau | 100 | Same pattern |
| Ultimate_ID95/init.luau | 44 | Same pattern |
| CleaveModule_ID13.luau | 105 | if IsA("BodyVelocity") destroy |

## Proof of Concept
See `poc.luau` in this folder.

## Remediation
```lua
-- Use a more robust cleanup that locks state
local function cleanupPhysicsConstraints(character)
    -- Collect all constraints first
    local toDestroy = {}
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BodyMover") then -- Catches all physics constraints
            table.insert(toDestroy, obj)
        end
    end

    -- Destroy all collected
    for _, obj in ipairs(toDestroy) do
        obj:Destroy()
    end

    -- Mark cleanup complete
    character:SetAttribute("_PhysicsCleanupComplete", tick())
end

-- When adding new constraint, verify cleanup was recent
local function addConstraint(character, constraint)
    local cleanupTime = character:GetAttribute("_PhysicsCleanupComplete")
    if not cleanupTime or tick() - cleanupTime > 0.1 then
        cleanupPhysicsConstraints(character)
    end
    constraint.Parent = character
end
```

## References
- CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization
- TOCTOU (Time-of-check Time-of-use) vulnerabilities

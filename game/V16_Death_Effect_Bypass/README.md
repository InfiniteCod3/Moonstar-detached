# V16 - Death Effect Bypass

## Severity: HIGH

## Summary
Death effects (burning animations, ragdoll, health display hiding) only trigger under specific conditions that can be manipulated by clients. Attackers can prevent death effects from applying to themselves or force them on others.

## Vulnerability Details

### Root Cause
Death effect application checks for specific attributes and child objects that clients can manipulate.

### Affected Code Pattern
```lua
-- ConsumeModule_ID118.luau:36
if arg1_2.Humanoid.Health <= 1 and not arg1_2:FindFirstChild("burnVfx") and not arg1_2:GetAttribute("DeathEffect") then
    arg1_2:SetAttribute("DeathEffect", true)
    arg1_2.Humanoid.HealthDisplayType = "AlwaysOff"
    -- Apply death effects...
end

-- DestroyModule_ID115.luau:34
if arg1_2.Humanoid.Health <= 1 and not arg1_2:FindFirstChild("burnVfx") and not arg1_2:GetAttribute("DeathEffect") then

-- GraspingSoulModule_ID121.luau:333
if var73.Humanoid.Health <= 1 and not var73:FindFirstChild("burnVfx") and not var73:GetAttribute("DeathEffect") then
```

### Attack Vector
**Defensive (prevent death effects on self):**
1. Add a fake `burnVfx` child to your character
2. Or set `DeathEffect` attribute to `true` preemptively
3. Death effects will never apply to you

**Offensive (force death effects on others - if exploitable):**
1. Remove `burnVfx` and `DeathEffect` from target
2. Repeatedly trigger death effect code paths

## Impact
- Avoid visual death indicators (stealth kills)
- Bypass ragdoll death animations
- Keep health bar visible when it should be hidden
- Potential desync between actual state and visual state

## Affected Files
| File | Line | Condition Checked |
|------|------|-------------------|
| ConsumeModule_ID118.luau | 36 | Health <= 1 AND no burnVfx AND no DeathEffect |
| DestroyModule_ID115.luau | 34 | Same pattern |
| GraspingSoulModule_ID121.luau | 333 | Same pattern |
| GraveDiggerModule_ID122.luau | 104 | Same pattern |
| DecayingSoulModule_ID120.luau | 219 | Same pattern |
| EarthCatastropheModule_ID22.luau | 112 | Health <= 1 check |

## Proof of Concept
See `poc.luau` in this folder.

## Remediation
```lua
-- Server-side death handling that can't be bypassed
local function handleDeath(character)
    -- Use a server-controlled flag, not client-accessible attribute
    local deathHandled = character:GetAttribute("_ServerDeathHandled")
    if deathHandled then return end

    -- Set server flag immediately
    character:SetAttribute("_ServerDeathHandled", true)

    -- Apply death effects regardless of client state
    applyDeathEffects(character)
end

-- Don't check for client-addable objects
-- Instead, track death state server-side
```

## References
- CWE-807: Reliance on Untrusted Inputs in a Security Decision
- Game Security: Death State Manipulation

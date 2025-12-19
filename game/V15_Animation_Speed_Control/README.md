# V15 - Client Animation Speed Control

## Severity: MEDIUM

## Summary
Animation markers (`GetMarkerReachedSignal`) control when damage, effects, and skill phases trigger. Since animations play client-side, manipulating animation speed allows attackers to trigger damage events faster or slower than intended.

## Vulnerability Details

### Root Cause
The server uses animation marker signals to trigger skill effects, but animations run on the client. Exploiters can manipulate animation playback speed to desync timing.

### Affected Code Pattern
```lua
-- Common pattern across all skill modules:
local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Skill.Animation)
any_LoadAnimation_result1:Play()
any_LoadAnimation_result1:AdjustSpeed(0.5)  -- Speed can be manipulated

-- Damage triggers on animation markers
var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function()
    -- This triggers when animation reaches "slash" marker
    var3_upvw.applyDamage(target, 20)
end), module_upvr.Cooldown)
```

### Attack Vector
1. Hook the Animator:LoadAnimation function
2. Modify returned AnimationTrack's speed
3. Set speed to very high value (instant damage)
4. Or set speed to 0 (freeze at advantageous state)
5. Damage/effects trigger at manipulated times

## Impact
- Instant damage application (skip charge-up animations)
- Permanent effect states (freeze animation mid-IFrame)
- Desync between visual and actual game state
- Combo timing exploitation

## Affected Files
| File | Line | Animation Usage |
|------|------|-----------------|
| BladeStormModule_ID98.luau | 196-197 | LoadAnimation + AdjustSpeed |
| ConsumeModule_ID118.luau | 67-69 | LiftAnimation with markers |
| SiphonModule_ID107.luau | 41-43 | Animation with AdjustSpeed |
| All *Module_ID*.luau files | Various | GetMarkerReachedSignal pattern |

## Proof of Concept
See `poc.luau` in this folder.

## Remediation
```lua
-- Server-side timing validation
local EXPECTED_ANIMATION_TIME = 1.5
local animStartTime = tick()

markerSignal:Connect(function()
    local elapsed = tick() - animStartTime
    if elapsed < EXPECTED_ANIMATION_TIME * 0.5 then
        -- Animation is playing too fast, reject
        warn("Animation speed manipulation detected")
        return
    end
    -- Process damage
end)

-- Or use server-side timers instead of animation markers
task.delay(SKILL_DELAY, function()
    applyDamage(target, damage)
end)
```

## References
- Game Security: Animation Exploitation
- CWE-367: Time-of-check Time-of-use (TOCTOU) Race Condition

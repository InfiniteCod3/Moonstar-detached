# V27 - Animation-Marker Hijacking

## Severity: HIGH

## Summary
Critical gameplay events (damage, effects) are triggered by animation markers. Clients can fast-forward animations to instantly trigger these markers, bypassing charge/windup times.

## Vulnerability Details

### Affected Code Pattern
```lua
-- Ultimate_ID1.luau:44-55
animation:GetMarkerReachedSignal("strike"):Connect(function()
    -- Main damage and VFX logic triggers here
    applyDamage(target, 50)
end)
-- Client can skip animation to this marker instantly
```

### Attack Vector
1. Hook AnimationTrack
2. Immediately jump to marker time position
3. Damage triggers instantly
4. No windup = no counterplay

## Impact
- Instant skill damage
- No parry/dodge windows
- Complete combo advantage

## Remediation
```lua
-- Server-side timing validation
local startTime = tick()
markerSignal:Connect(function()
    if tick() - startTime < MINIMUM_CAST_TIME then
        return -- Too fast, reject
    end
    applyDamage(target, damage)
end)
```

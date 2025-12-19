# V26 - Ultimate Meter Drain Bypass

## Severity: MEDIUM

## Summary
Ultimate abilities check client-side meter values to determine when to end. Clients can suppress the "meter empty" signal to extend ultimates indefinitely.

## Vulnerability Details

### Affected Code Pattern
```lua
-- Client_ID181.luau:38-43
if arg1.Info.UltimateMeter.Value == 0 then
    -- Disconnect theme loop
    -- Client signals end of ultimate
end
-- Client can prevent this check from triggering
```

### Attack Vector
1. Hook the Value changed event
2. Never let it return 0 to the check
3. Ultimate state continues indefinitely

## Impact
- Extended ultimate duration
- Permanent ultimate state
- Major combat advantage

## Remediation
```lua
-- Server-side ultimate timer
local ultimateEndTime = tick() + ULTIMATE_DURATION
task.delay(ULTIMATE_DURATION, function()
    endUltimate(player)
end)
```

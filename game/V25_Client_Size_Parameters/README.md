# V25 - Client-Controlled Size Parameters

## Severity: HIGH

## Summary
The client calculates and sends size/magnitude values that the server uses to scale hitboxes or visual effects, allowing inflated attack ranges.

## Vulnerability Details

### Affected Code Pattern
```lua
-- Client_ID179.luau:46-49
ClientInfo:FireServer("Quick Breeze", {
    SizeZ = (HumanoidRootPart.Position - CFrame.p).Magnitude
})
-- Server uses SizeZ for hitbox length
```

### Attack Vector
1. Calculate artificially large SizeZ value
2. Server creates hitbox with that size
3. Hit targets much further than intended

## Impact
- Extended skill ranges
- Hit through walls (large enough hitbox)
- Balance-breaking advantages

## Remediation
```lua
-- Server: Clamp size values
local MAX_SIZE = 50
data.SizeZ = math.clamp(data.SizeZ or 10, 1, MAX_SIZE)
```

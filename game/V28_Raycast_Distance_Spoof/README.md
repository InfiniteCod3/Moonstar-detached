# V28 - Raycast Distance Spoofing

## Severity: HIGH

## Summary
Client raycasts use extreme distances (100,000+ units) to find surfaces. The resulting positions are sent to the server, allowing hits through geometry or in out-of-bounds areas.

## Vulnerability Details

### Affected Code Pattern
```lua
-- Client_ID100.luau:62, 68
local rayResult = workspace:Raycast(
    HumanoidRootPart.Position + LookVector * 95,
    Vector3.new(0, -100000, 0),  -- Extreme distance
    raycastParams
)
-- Result position sent to server for skill placement
```

### Attack Vector
1. Modify raycast to return custom positions
2. Position can be through walls or off-map
3. Skills execute at spoofed locations

## Impact
- Attack through walls/floors
- Hit targets in unreachable areas
- Bypass map boundaries

## Remediation
```lua
-- Server: Validate raycast results
local MAX_RAYCAST_DISTANCE = 200
local distance = (claimedPosition - playerPosition).Magnitude
if distance > MAX_RAYCAST_DISTANCE then
    return -- Invalid position
end
```

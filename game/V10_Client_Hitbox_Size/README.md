# V10: Client-Controlled Hitbox Size

## Severity: MEDIUM

## Description

Server-side skill modules accept hitbox size parameters from the client, specifically the `SizeZ` property. This allows exploiters to create massive hitboxes that can hit multiple players across large areas simultaneously.

## Vulnerability Details

The `QuickBreezeModule_ID178.luau` and `AgressiveBreezeModule_ID171.luau` modules create hitboxes with one dimension controlled entirely by client-provided data (`arg3.SizeZ`). There is no validation or clamping of this value on the server.

### Attack Vector

1. Client fires the skill remote with a custom `SizeZ` value
2. Server creates hitbox with `Vector3.new(X, Y, arg3.SizeZ)`
3. Hitbox can be arbitrarily large, hitting players far beyond intended range
4. Combined with V09 (CFrame control), can hit any player on the map

## Affected Files

| File | Line(s) | Vulnerable Code |
|------|---------|-----------------|
| `QuickBreezeModule_ID178.luau` | 76 | `clone_3.Size = Vector3.new(6, 6, arg3.SizeZ)` |
| `AgressiveBreezeModule_ID171.luau` | 78 | `clone_3.Size = Vector3.new(25, 25, arg3.SizeZ)` |

## Vulnerable Code Examples

### QuickBreezeModule_ID178.luau (Lines 70-77)
```lua
-- Line 60-77
var16_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2, arg3)
    -- Upvalues omitted for brevity
    if arg2_2 ~= "Quick Breeze" or arg1_3 ~= arg2 then
    else
        var16_upvw:Disconnect()
        local clone_3 = Aggressive_Breeze_upvr.Hitbox:Clone()
        clone_3.Parent = Folder_upvr
        clone_3.CFrame = arg3.CF                         -- V09: Client CFrame
        clone_3.Size = Vector3.new(6, 6, arg3.SizeZ)     -- VULNERABLE: Client controls SizeZ!
        var2_upvw.applyDebris(clone_3, 3)
        -- Damage all enemies in hitbox
        for i_2, v_2_upvr in var2_upvw.findEnemiesPart(clone_3), nil do
            -- Applies damage/effects to all found enemies
        end
    end
end)
```

### AgressiveBreezeModule_ID171.luau (Lines 72-78)
```lua
-- Line 61-78
var17_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2, arg3)
    -- Upvalues omitted for brevity
    if arg2_2 ~= "Agressive Breeze" or arg1_3 ~= arg2 then
    else
        var17_upvw:Disconnect()
        local clone_3 = Aggressive_Breeze_upvr.Hitbox:Clone()
        clone_3.Parent = Folder_upvr
        clone_3.CFrame = arg3.CF                         -- V09: Client CFrame
        clone_3.Size = Vector3.new(25, 25, arg3.SizeZ)   -- VULNERABLE: Client controls SizeZ!
        var2_upvw.applyDebris(clone_3, 3)
        -- ...
    end
end), module_upvr.Cooldown)
```

### Client-Side Code (Client_ID172.luau, Line 41)
```lua
-- Line 39-43 - Shows how SizeZ is calculated on client
HumanoidRootPart_upvr.CFrame += HumanoidRootPart_upvr.CFrame.LookVector * 55
ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Agressive Breeze", {
    SizeZ = (HumanoidRootPart_upvr.Position - CFrame.p).Magnitude;  -- Distance-based
    CF = HumanoidRootPart_upvr.CFrame:Lerp(CFrame, 0.5);
})
```

## Exploitation

An exploiter can send extremely large `SizeZ` values to create map-wide hitboxes:

```lua
-- Exploit: Create massive hitbox covering entire map
local RemoteEvent = game.ReplicatedStorage.Remotes.ClientInfo
local HRP = game.Players.LocalPlayer.Character.HumanoidRootPart

-- Agressive Breeze with massive hitbox
RemoteEvent:FireServer("Agressive Breeze", {
    SizeZ = 10000,  -- Covers entire map!
    CF = HRP.CFrame
})

-- Quick Breeze with massive hitbox
RemoteEvent:FireServer("Quick Breeze", {
    SizeZ = 5000,   -- Also very large
    CF = HRP.CFrame
})
```

## Impact

- **Mass Damage**: Hit all players on the server simultaneously with one attack
- **Area Denial**: Create hitboxes covering entire regions
- **One-Hit All**: Combined with high damage skills, can eliminate multiple players instantly
- **Unfair Advantage**: Drastically increase hit chance by enlarging hitbox
- **Griefing**: Constantly damage all players regardless of their position

## Visual Representation

```
Normal Hitbox (SizeZ = 55):
Player ====[=====]====>
              ^
        Intended range

Exploited Hitbox (SizeZ = 10000):
Player ====[===============================================...
              ^
        Covers entire map
```

## Remediation

### 1. Clamp SizeZ to Maximum Value
```lua
local MAX_HITBOX_SIZE_Z = 100  -- Maximum allowed hitbox length

-- Before creating hitbox:
local validatedSizeZ = math.clamp(arg3.SizeZ, 1, MAX_HITBOX_SIZE_Z)
clone_3.Size = Vector3.new(25, 25, validatedSizeZ)
```

### 2. Calculate Size Server-Side
```lua
-- Don't trust client SizeZ at all - calculate on server
local startPosition = previousPosition  -- Stored from animation start
local endPosition = HumanoidRootPart_upvr.Position
local actualDistance = (endPosition - startPosition).Magnitude

-- Clamp to reasonable maximum
local sizeZ = math.min(actualDistance, MAX_HITBOX_SIZE_Z)
clone_3.Size = Vector3.new(25, 25, sizeZ)
```

### 3. Remove Client Control Entirely
```lua
-- Use fixed hitbox size defined in skill properties
local SKILL_HITBOX_SIZES = {
    ["Quick Breeze"] = Vector3.new(6, 6, 55),
    ["Agressive Breeze"] = Vector3.new(25, 25, 75),
}

clone_3.Size = SKILL_HITBOX_SIZES["Quick Breeze"]
-- Ignore client-provided SizeZ entirely
```

### 4. Validate Against Player Movement
```lua
-- Track player movement and validate claimed distance
local maxPossibleDistance = MAX_PLAYER_SPEED * timeSinceSkillStart
local clampedSizeZ = math.min(arg3.SizeZ, maxPossibleDistance + HITBOX_BASE_LENGTH)
```

## References

- Related to V09 (No Range Validation) - often exploited together
- [Roblox Hit Detection Best Practices](https://create.roblox.com/docs/scripting/security/security-best-practices)

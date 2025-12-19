# V09: No Distance/Range Validation

## Severity: HIGH

## Description

Server-side skill modules do not validate that client-provided positions or targets are within reasonable distance from the player. This allows exploiters to teleport anywhere in the game world, place hitboxes at arbitrary locations, or attack players from across the map.

## Vulnerability Details

The server blindly accepts position data (CFrame, Vector3, TeleportPosition) from clients without checking:
- Distance from the player's current position
- Whether the target location is reachable
- Maximum allowed range for the specific skill

### Affected Patterns

1. **Direct CFrame Assignment**: Server sets player CFrame directly from client data
2. **Teleport Position**: Client specifies exact teleport destination
3. **Hitbox Positioning**: Attack hitboxes placed at client-specified locations

## Affected Files

| File | Line(s) | Vulnerability |
|------|---------|---------------|
| `SiphonModule_ID107.luau` | 198 | `HumanoidRootPart_upvr.CFrame = arg3` |
| `BlinkStrikeModule_ID106.luau` | 227 | `HumanoidRootPart_upvr.CFrame = arg1_2` |
| `BodySlamModule_ID160.luau` | 74 | `HumanoidRootPart_upvr.CFrame = arg3` |
| `BladeStormModule_ID98.luau` | 182 | `HumanoidRootPart_upvr.CFrame = arg1_3` |
| `FlashOverdriveModule_ID103.luau` | 121 | `HumanoidRootPart_upvr.CFrame = arg1_2` |
| `AgressiveBreezeModule_ID171.luau` | 77 | `clone_3.CFrame = arg3.CF` |
| `QuickBreezeModule_ID178.luau` | 75 | `clone_3.CFrame = arg3.CF` |
| `ChillingArcModule_ID77.luau` | 56 | `clone_5.CFrame = arg3.IndicatorCF` |
| `AerialSmiteModule_ID148.luau` | 88 | `clone_3_upvr.CFrame = arg3.ClientCF` |

## Vulnerable Code Examples

### Example 1: SiphonModule_ID107.luau (Line 198)
```lua
-- Line 179-198
var53_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2, arg3)
    -- ...
    if arg2_2 ~= "Siphon" or arg1_3 ~= arg2 then
    else
        var53_upvw:Disconnect()
        HumanoidRootPart_upvr.CFrame = arg3  -- VULNERABLE: No distance validation!
        var2_upvw.camShake(arg1, "Bump")
        -- ...
    end
end)
```

### Example 2: BodySlamModule_ID160.luau (Lines 70-75)
```lua
-- Line 55-75
var15_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3)
    -- ...
    if arg2_2 ~= "BodySlam" or arg1_2 ~= arg2 or not var15_upvw then
    else
        var15_upvw:Disconnect()
        if arg3 then
            HumanoidRootPart_upvr.CFrame = arg3  -- VULNERABLE: Teleports to any position!
        end
        -- ...
    end
end), module_upvr.Cooldown)
```

### Example 3: BlinkStrikeModule_ID106.luau (Lines 226-227)
```lua
-- Line 154-227 (teleport function)
;(function(arg1_2)
    -- ...
    if arg1_2 then
        HumanoidRootPart_upvr.CFrame = arg1_2  -- VULNERABLE: No range check!
    end
    -- ...
end)(var57_upvw)
```

## Exploitation

An exploiter can send arbitrary position values to teleport anywhere:

```lua
-- Exploit: Teleport to any position in the game
local targetPosition = Vector3.new(99999, 500, 99999)
local remoteCFrame = CFrame.new(targetPosition)

-- For Siphon skill
game.ReplicatedStorage.Remotes.ClientInfo:FireServer("Siphon", remoteCFrame)

-- For BodySlam skill
game.ReplicatedStorage.Remotes.ClientInfo:FireServer("BodySlam", remoteCFrame)

-- Teleport behind a specific player
local targetPlayer = game.Players:FindFirstChild("VictimName")
if targetPlayer and targetPlayer.Character then
    local behindCFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
    game.ReplicatedStorage.Remotes.ClientInfo:FireServer("Siphon", behindCFrame)
end
```

## Impact

- **Teleport Anywhere**: Players can teleport to any coordinate in the game world
- **Map Escape**: Bypass boundaries and reach restricted areas
- **Combat Exploits**: Teleport behind enemies for guaranteed hits
- **Speed Hacking**: Rapidly fire teleport abilities to move at extreme speeds
- **Unreachable Positions**: Teleport to positions where players cannot be attacked

## Remediation

### 1. Add Maximum Distance Validation
```lua
local MAX_TELEPORT_DISTANCE = 50  -- Adjust based on skill design
local MAX_HITBOX_DISTANCE = 30

function validatePosition(currentPosition, requestedPosition, maxDistance)
    local distance = (requestedPosition - currentPosition).Magnitude
    if distance > maxDistance then
        -- Clamp to maximum allowed distance
        return currentPosition + (requestedPosition - currentPosition).Unit * maxDistance
    end
    return requestedPosition
end

-- Usage in skill module:
local validatedCFrame = validatePosition(
    HumanoidRootPart_upvr.Position,
    arg3.Position,
    MAX_TELEPORT_DISTANCE
)
HumanoidRootPart_upvr.CFrame = CFrame.new(validatedCFrame) * (arg3 - arg3.Position)
```

### 2. Implement Skill-Specific Range Limits
```lua
local SKILL_RANGES = {
    ["Siphon"] = 40,
    ["BodySlam"] = 60,
    ["Blink Strike"] = 75,
}

function checkSkillRange(skillName, playerPosition, targetPosition)
    local maxRange = SKILL_RANGES[skillName] or 50
    return (targetPosition - playerPosition).Magnitude <= maxRange
end
```

### 3. Add Server-Side Raycast Validation
```lua
function canReachPosition(startPosition, endPosition)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {workspace.Characters}

    local result = workspace:Raycast(startPosition, endPosition - startPosition, rayParams)
    return result == nil  -- No obstacles in the way
end
```

## References

- [OWASP Input Validation](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/07-Input_Validation_Testing/README)
- [Roblox Security Best Practices](https://create.roblox.com/docs/scripting/security/security-best-practices)

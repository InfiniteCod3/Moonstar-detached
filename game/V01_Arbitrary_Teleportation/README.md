# V01: Arbitrary Teleportation Vulnerability

## Severity: CRITICAL

## Overview

Multiple skill modules accept unvalidated `TeleportPosition` data from clients via the `ClientInfo.OnServerEvent` RemoteEvent. The server directly uses this client-provided position to set the player's `HumanoidRootPart.CFrame`, allowing malicious clients to teleport anywhere in the game world without any server-side validation.

## Affected Files

| File | Vulnerable Lines | Skill Name |
|------|------------------|------------|
| ConceptModule_ID9.luau | Lines 37-62 | Concept (Basic Sword Ultimate) |
| SnowCloakModule_ID75.luau | Lines 69-102 | Snow Cloak (Snow Blasters) |
| BodySlamModule_ID160.luau | Lines 55-74 | Body Slam (Fire Fists Ultimate) |

## Vulnerability Details

### Root Cause

The server listens for `ClientInfo.OnServerEvent` and trusts the `arg3.TeleportPosition` or `arg3` (CFrame) value sent by the client without performing any validation such as:

- Distance checks from current position
- Bounds checking within the game world
- Line-of-sight verification
- Anti-cheat sanity checks

### Vulnerable Code Snippets

#### ConceptModule_ID9.luau (Lines 37-62)

```lua
-- Line 37: Server connects to ClientInfo.OnServerEvent
var11_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3)
    -- ...
    -- Line 54: Only checks if player matches and action is "Concept"
    if arg1_2 ~= arg2 or arg2_2 ~= "Concept" then
    else
        var11_upvw:Disconnect()
        -- ...
        -- Line 61-62: VULNERABLE - Directly uses client-provided TeleportPosition
        NONE_2 = CFrame.new(arg3.TeleportPosition) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
        HumanoidRootPart_upvr.CFrame = NONE_2
        -- ...
    end
end), 5)
```

#### SnowCloakModule_ID75.luau (Lines 69-102)

```lua
-- Line 69: Server connects to ClientInfo.OnServerEvent
var24_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_4, arg2_2, arg3)
    -- ...
    -- Line 82: Only checks if action is "SnowCloak" and player matches
    if arg2_2 ~= "SnowCloak" or arg1_4 ~= arg2 then
    else
        var24_upvw:Disconnect()
        -- ...
        -- Line 102: VULNERABLE - Directly uses client-provided TeleportPosition
        HumanoidRootPart_upvr.CFrame = CFrame.new(arg3.TeleportPosition) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
        -- ...
    end
end), module_upvr.Cooldown)
```

#### BodySlamModule_ID160.luau (Lines 55-74)

```lua
-- Line 55: Server connects to ClientInfo.OnServerEvent
var15_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3)
    -- ...
    -- Line 70: Only checks if action is "BodySlam" and player matches
    if arg2_2 ~= "BodySlam" or arg1_2 ~= arg2 or not var15_upvw then
    else
        var15_upvw:Disconnect()
        -- Lines 73-74: VULNERABLE - Directly uses client-provided CFrame
        if arg3 then
            HumanoidRootPart_upvr.CFrame = arg3
        end
        -- ...
    end
end), module_upvr.Cooldown)
```

## Exploit Mechanism

### Step-by-Step Attack Flow

1. **Attacker activates the skill**: The attacker uses a legitimate skill (Concept, Snow Cloak, or Body Slam) to trigger the server-side event listener.

2. **Server sets up event listener**: Upon skill activation, the server creates a connection to `ReplicatedStorage.Remotes.ClientInfo.OnServerEvent` waiting for client input.

3. **Attacker crafts malicious payload**: Instead of sending a legitimate teleport position based on their actual mouse click or skill range, the attacker sends an arbitrary position:
   ```lua
   -- Attacker's exploit script
   local targetPosition = Vector3.new(99999, 1000, 99999) -- Any arbitrary position
   game.ReplicatedStorage.Remotes.ClientInfo:FireServer("Concept", {
       TeleportPosition = targetPosition
   })
   ```

4. **Server blindly accepts position**: The server receives the event, verifies only that:
   - The player ID matches the skill user
   - The action name matches the expected skill

   It does NOT verify:
   - Whether the position is within valid teleport range
   - Whether the position is reachable
   - Whether the position is within map boundaries

5. **Teleportation executed**: The server sets the player's CFrame to the attacker-specified position, teleporting them anywhere.

## Impact Assessment

### Severity: CRITICAL

| Impact Category | Description |
|-----------------|-------------|
| **Game Integrity** | Players can teleport to any location, bypassing intended game mechanics, barriers, and progression systems |
| **PvP Exploitation** | Attackers can instantly teleport behind enemies, escape combat, or reach unreachable positions |
| **Map Boundaries** | Players can escape the intended play area, potentially accessing developer-only areas or causing undefined behavior |
| **Economy Impact** | If valuable resources or objectives are location-based, attackers can instantly reach them |
| **Anti-Cheat Bypass** | Traditional movement-based anti-cheat is bypassed since the teleportation is "legitimized" by the server |
| **User Experience** | Legitimate players face unfair disadvantage against exploiters |

### Attack Surface

- **Ease of Exploitation**: Low barrier - requires only basic Roblox exploit knowledge
- **Detection Difficulty**: Moderate - teleportation happens server-side, may not trigger client-side anti-cheat
- **Reproducibility**: 100% - vulnerability is deterministic

## Remediation Recommendations

### Immediate Fixes

#### 1. Implement Maximum Distance Validation

```lua
local MAX_TELEPORT_DISTANCE = 50 -- studs

local function validateTeleportPosition(currentPosition, targetPosition)
    local distance = (targetPosition - currentPosition).Magnitude
    return distance <= MAX_TELEPORT_DISTANCE
end

-- In the event handler:
if not validateTeleportPosition(HumanoidRootPart.Position, arg3.TeleportPosition) then
    warn("Invalid teleport distance from player: " .. tostring(arg1_2))
    return
end
```

#### 2. Implement Bounds Checking

```lua
local MAP_BOUNDS = {
    Min = Vector3.new(-1000, -100, -1000),
    Max = Vector3.new(1000, 500, 1000)
}

local function isWithinBounds(position)
    return position.X >= MAP_BOUNDS.Min.X and position.X <= MAP_BOUNDS.Max.X
       and position.Y >= MAP_BOUNDS.Min.Y and position.Y <= MAP_BOUNDS.Max.Y
       and position.Z >= MAP_BOUNDS.Min.Z and position.Z <= MAP_BOUNDS.Max.Z
end
```

#### 3. Implement Line-of-Sight Verification

```lua
local function hasLineOfSight(fromPosition, toPosition)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}

    local result = workspace:Raycast(fromPosition, toPosition - fromPosition, raycastParams)
    return result == nil or (result.Position - toPosition).Magnitude < 1
end
```

#### 4. Server-Calculated Teleport Position

The most secure approach is to have the server calculate valid teleport positions based on client input direction, rather than accepting exact coordinates:

```lua
-- Client sends direction/intent, not exact position
-- Server calculates valid position within skill range
local function calculateServerTeleportPosition(character, direction, maxRange)
    local origin = character.HumanoidRootPart.Position
    local targetPosition = origin + direction.Unit * maxRange

    -- Raycast to find valid ground position
    local rayResult = workspace:Raycast(targetPosition + Vector3.new(0, 10, 0), Vector3.new(0, -50, 0))
    if rayResult then
        return rayResult.Position + Vector3.new(0, 3, 0)
    end
    return nil -- Invalid position
end
```

### Long-Term Recommendations

1. **Audit all RemoteEvents**: Review every `OnServerEvent` handler for similar trust issues
2. **Implement rate limiting**: Prevent rapid-fire exploit attempts
3. **Add server-side logging**: Log suspicious teleportation patterns for review
4. **Implement anti-cheat monitoring**: Track player positions and flag impossible movements
5. **Use a validation library**: Create a centralized validation module for all client inputs

## References

- [Roblox Security Best Practices](https://create.roblox.com/docs/scripting/security)
- [RemoteEvent Security](https://create.roblox.com/docs/scripting/events/remote-events-and-functions)
- OWASP Input Validation Guidelines

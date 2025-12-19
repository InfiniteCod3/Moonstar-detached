# V03: Client Hitbox Positioning Vulnerability

## Severity: CRITICAL

## Vulnerability Overview

The server-side skill modules accept client-provided CFrame/position data to position damage hitboxes and visual effects without any validation. This allows malicious clients to place hitboxes at arbitrary locations in the game world, enabling attacks on players anywhere on the map regardless of the attacker's actual position.

## Affected Files

| File | Vulnerable Lines | Description |
|------|------------------|-------------|
| `BindModule_ID42.luau` | 39, 56, 62 | Indicator CFrame from client `arg3` parameter |
| `ChillingArcModule_ID77.luau` | 37, 48, 56 | VFX CFrame from client `arg3.IndicatorCF` |
| `FieryLeapModule_ID25.luau` | 67, 76, 116, 118, 124, 129 | Explosion position from client `arg3.ExplosionPosition` |

## Detailed Technical Analysis

### Vulnerability Pattern

All three modules follow the same vulnerable pattern:

1. Server listens for `ClientInfo.OnServerEvent` from RemoteEvent
2. Client sends skill activation with arbitrary position/CFrame data
3. Server uses this data directly to position hitboxes and damage zones
4. No validation is performed against the player's actual position

### Vulnerable Code Snippets

#### BindModule_ID42.luau (Lines 39-62)

```lua
-- Line 39: Server listens for client event
var11_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 48
    -- ...
    if arg1_2 ~= arg2 or arg2_2 ~= "Bind" then
    else
        var11_upvw:Disconnect()
        var3_upvw.applySound(Bind_upvr.Snap, HumanoidRootPart_upvr)
        var3_upvw.changeFov(arg1, 65, 0, 2)
        var3_upvw.camShake(arg1, "SmallBump")
        task.wait()
        local clone_2_upvr = Bind_upvr.Indicator:Clone()
        clone_2_upvr.Parent = Folder_upvr
        -- Line 62: VULNERABLE - Client-provided CFrame (arg3) used directly
        clone_2_upvr.CFrame = arg3 + arg3.LookVector * 30 + Vector3.new(0, -2.9000, 0)
        -- ...
        -- Line 83: Hitbox positioned using client data finds enemies
        for _, v_upvr in var3_upvw.findEnemiesPart(clone_2_upvr.hitbox, true), nil do
            -- Damage is applied to enemies found in client-controlled hitbox
            var3_upvw.applyDamage(v_upvr, 10)
```

#### ChillingArcModule_ID77.luau (Lines 37-74)

```lua
-- Line 37: Server listens for client event
var10_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 44
    -- ...
    if arg2_2 ~= "Chilling Arc" or arg1_2 ~= arg2 then
    else
        var10_upvw:Disconnect()
        -- ...
        local clone_5 = Chilling_Arc_upvr.VFX:Clone()
        clone_5.Parent = Folder_upvr
        -- Line 56: VULNERABLE - Client-provided CFrame used directly
        clone_5.CFrame = arg3.IndicatorCF
        var2_upvw.applyDebris(clone_5, 10)
        -- ...
        for i_2 = 1, 4 do
            local SOME = clone_5:FindFirstChild(i_2)
            -- ...
            -- Line 74: Damage applied based on client-controlled position
            for _, v_2 in var2_upvw.findEnemiesMagnitude(SOME.Position, 18, true), nil do
                if not table.find(tbl, v_2) then
                    table.insert(tbl, v_2)
                    if not var2_upvw.CheckBlock(v_2) then
                        var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, -20, 5)
                        var2_upvw.applyStatus(v_2, "Ragdoll", 1)
                        var2_upvw.applyStatus(v_2, "Slowed", 1.5)
                        var2_upvw.applyDamage(v_2, 13)
```

#### FieryLeapModule_ID25.luau (Lines 67-129)

```lua
-- Lines 67-77: Server event handler stores client-provided position
function var37(arg1_2, arg2_2, arg3) -- Line 81
    -- ...
    if arg2 ~= arg1_2 or arg2_2 ~= "Fiery Leap" then
    else
        var35_upvw = false
        -- Line 76: VULNERABLE - Client position stored without validation
        var34_upvw = arg3.ExplosionPosition
    end
end

-- Later in the code...
-- Line 116: Crater created at client-provided position
var2_upvw.crater(1, var37, 4, 1)
-- Line 118: Debris created at client position
var2_upvw.CreateDebris(var34_upvw, var37, 1, 1, 0.1)

-- Line 121-124: Hitbox positioned at client-provided location
local clone_2 = Fiery_Leap.Hitbox:Clone()
clone_2.Parent = Folder
var37 = Vector3.new(0, clone_2.Size.Y / 2 - 2, 0)
clone_2.Position = var34_upvw + var37  -- VULNERABLE

-- Line 127-129: VFX positioned at client location
local clone_3_upvr = Fiery_Leap["Fire Explosion"]:Clone()
clone_3_upvr.Parent = Folder
clone_3_upvr.Position = var34_upvw  -- VULNERABLE

-- Line 174-177: Enemies found and damaged at client-controlled position
for i_4, v_4 in var2_upvw.findEnemiesPart(clone_2, true), nil do
    var2_upvw.applyStatus(v_4, "Ragdoll", 2.4)
    var2_upvw.Knockback(v_4, HumanoidRootPart.Position, 15, 70)
    var2_upvw.applyDamage(v_4, 15)
```

## Exploitation Methodology

### Step-by-Step Attack Process

1. **Intercept Remote Event**: The attacker uses a script executor to hook into the `ClientInfo` RemoteEvent.

2. **Capture Skill Activation**: When the player activates a skill (Bind, Chilling Arc, or Fiery Leap), the client normally sends position data based on the player's actual location.

3. **Modify Position Data**: The attacker intercepts this outgoing event and modifies the position/CFrame data to target any location in the game world.

4. **Server Accepts Malicious Data**: The server receives the modified data and positions the hitbox/damage zone at the attacker-specified location.

5. **Damage Applied to Remote Targets**: Players at the targeted location receive damage, knockback, ragdoll effects, and status debuffs despite the attacker being nowhere near them.

### Attack Capabilities

- **Bind (BindModule_ID42.luau)**: 10 damage, 2-second stun, auto-rotate disable
- **Chilling Arc (ChillingArcModule_ID77.luau)**: 13 damage per hit (4 hits total = 52 damage), knockback, 1-second ragdoll, 1.5-second slow
- **Fiery Leap (FieryLeapModule_ID25.luau)**: 15 damage, 2.4-second ragdoll, massive knockback, burn effects on kill

## Impact Assessment

### Security Impact

| Impact Category | Severity | Description |
|-----------------|----------|-------------|
| Game Integrity | CRITICAL | Complete bypass of spatial combat mechanics |
| Player Experience | CRITICAL | Players can be killed from anywhere on map |
| Competitive Fairness | CRITICAL | Exploiters gain massive unfair advantage |
| Server Authority | HIGH | Server trusts client for critical game logic |

### Attack Scenarios

1. **Spawn Camping**: Attack players at spawn points from across the map
2. **Safe Zone Violations**: Target players in areas normally protected from combat
3. **Invisible Attacks**: Damage players without revealing attacker's location
4. **Chain Attacks**: Rapidly fire skills at different targets across the map
5. **Event/Boss Griefing**: Kill players during important game events

## Remediation Recommendations

### Immediate Fixes

#### 1. Server-Side Position Validation

```lua
-- Add distance validation before processing client position
local function validateClientPosition(playerPosition, clientPosition, maxDistance)
    local distance = (playerPosition - clientPosition).Magnitude
    if distance > maxDistance then
        warn("Client position rejected: distance exceeded")
        return false
    end
    return true
end

-- In event handler:
local maxSkillRange = 50 -- Configure per skill
if not validateClientPosition(HumanoidRootPart.Position, arg3.Position, maxSkillRange) then
    return -- Reject the request
end
```

#### 2. Server-Authoritative Hitbox Positioning

```lua
-- Calculate hitbox position on server using player's actual position
local serverPosition = HumanoidRootPart.CFrame
local hitboxPosition = serverPosition + serverPosition.LookVector * 30
-- Use serverPosition instead of client-provided arg3
```

#### 3. Rate Limiting

```lua
-- Implement cooldown tracking on server
local lastSkillUse = {}
local function checkCooldown(player, skillName, cooldownTime)
    local key = player.UserId .. skillName
    local lastUse = lastSkillUse[key] or 0
    if tick() - lastUse < cooldownTime then
        return false
    end
    lastSkillUse[key] = tick()
    return true
end
```

### Long-Term Solutions

1. **Server-Authoritative Combat System**: Move all hitbox calculations to the server. The client should only send intent (e.g., "use skill") not position data.

2. **Input Validation Layer**: Create a centralized validation module that sanitizes all client inputs before processing.

3. **Anomaly Detection**: Log and flag suspicious patterns such as:
   - Attacks targeting positions far from player
   - Rapid skill usage exceeding normal human input
   - Consistent hits on players across the map

4. **Replay System**: Implement server-side combat logging for review and automated detection.

## References

- CWE-20: Improper Input Validation
- CWE-807: Reliance on Untrusted Inputs in a Security Decision
- OWASP: Client-Side Trust Issues

## Document Information

- **Vulnerability ID**: V03_Client_Hitbox_Positioning
- **Discovery Date**: 2025-12-18
- **Classification**: Security Vulnerability Documentation
- **Status**: Active/Unpatched

# V29 - Client Victim Injection

## Severity: CRITICAL

## Summary
Multiple skills allow the client to directly specify which player to target (victim injection) or provide CFrame data that positions both the attacker AND victim. The server blindly trusts this data without distance validation or ownership checks.

## Vulnerability Details

This vulnerability encompasses 10 distinct exploitation patterns across different skills:

### Pattern A: Direct Victim Character Injection
Client sends a player's Character directly to server, server applies damage/status to them.

#### A1. Rise - Victim + Duration Control
```lua
-- RiseModule_ID84.luau:84-85
-- Client sends: arg3 = victim character, arg4 = duration
var3_upvw.applyStatus(arg3, "Stunned", arg4 + 1)  -- Client controls duration!
var3_upvw.applyStatus(arg3, "IFrames", arg4 + 1)
-- Line 115: var3_upvw.applyDamage(arg3, 10, true, true)
```
**Exploit**: `FireServer("Rise", targetPlayer.Character, 9999)` = permanent stun

#### A2. Inferior - Direct Victim Targeting
```lua
-- InferiorModule_ID88.luau:77-98
if arg3 and not PlayerStatus_upvr.FindStatus(arg3, "IFrames") then
    var16_upvw = arg3  -- Server trusts client's victim selection
end
var3_upvw.applyDamage(var16_upvw, 5, false, true)
table.insert(tbl_upvr_2, var3_upvw.applyStatus(var16_upvw, "Stunned", 4))
```
**Exploit**: Target any player regardless of distance

#### A3. Anguish - 8-Second Lock
```lua
-- AnguishModule_ID116.luau:199-224
var9_upvw = arg3  -- Server accepts client's victim
var3_upvw.applyStatus(var9_upvw, "Stunned", 8)
var3_upvw.applyStatus(var9_upvw, "IFrames", 8)
var11_upvw = var3_upvw.applyWeld(var9_upvw, Vector3.new(0, 0, 3), ...)
var3_upvw.applyDamage(var9_upvw, 2, true, true)
```
**Exploit**: Lock any player in 8-second stun from any distance

### Pattern B: CFrame Control Affecting Victim
Client sends CFrame that positions the victim player.

#### B1. Skewer - Dual Player Positioning (MOST CRITICAL)
```lua
-- SkewerModule_ID7.luau:142-143
HumanoidRootPart_2_upvr.CFrame = arg3.ClientCF  -- Attacker position
HumanoidRootPart.CFrame = (arg3.ClientCF + HumanoidRootPart_2_upvr.CFrame.LookVector * 3) * CFrame.Angles(0, math.pi, 0)
-- ^^^ VICTIM position is calculated from client CFrame!
```
**Exploit**: Teleport both yourself AND the victim anywhere

### Pattern C: CFrame Teleport + AoE Damage
Client sends CFrame for their position, then AoE damages nearby players.

#### C1. BodySlam
```lua
-- BodySlamModule_ID160.luau:74
HumanoidRootPart_upvr.CFrame = arg3  -- Direct CFrame assignment
-- Then damages all players in radius
```

#### C2. RapidJabs
```lua
-- RapidJabsModule_ID164.luau:69
HumanoidRootPart_upvr.CFrame = arg3
-- Initiates grab combo on nearby players
```

#### C3. Siphon
```lua
-- SiphonModule_ID107.luau:198
HumanoidRootPart_upvr.CFrame = arg3
-- Creates AoE hitbox, stuns and damages all in radius
```

### Pattern D: Client CFrame for Attack Origin
Client CFrame determines where damage hitbox spawns.

#### D1. AerialSmite
```lua
-- AerialSmiteModule_ID148.luau:84-88
local workspace_Raycast_result1_upvr = workspace:Raycast(arg3.ClientCF.p, Vector3.new(0, -500, 0), ...)
clone_3_upvr.CFrame = arg3.ClientCF + Vector3.new(0, -5, 0)
-- Tornado spawns at client position, damages/stuns all in area
```

#### D2. Entry
```lua
-- EntryModule_ID15.luau:108
var10_upvw = arg3.ClientCF + arg3.ClientCF.LookVector * 12 + Vector3.new(0, -5, 0)
-- Attack hitbox positioned from client CFrame
```

## Attack Vectors

### 1. Cross-Map Victim Targeting
```lua
-- Target any player on the map
local target = game.Players:GetPlayers()[2].Character
ReplicatedStorage.Remotes.ClientInfo:FireServer("Anguish", target)
-- Result: 8-second stun on player across the map
```

### 2. Permanent Stun via Duration Control
```lua
-- Rise allows client-controlled duration
local target = getClosestPlayer().Character
ReplicatedStorage.Remotes.ClientInfo:FireServer("Rise", target, 99999)
-- Result: Stun for 100,000 seconds
```

### 3. Dual Teleportation (Skewer)
```lua
-- Teleport both yourself and victim to void
local voidCFrame = CFrame.new(0, -500, 0)
ReplicatedStorage.Remotes.ClientInfo:FireServer("Skewer", {ClientCF = voidCFrame})
-- Result: Both players teleported to void
```

### 4. Spawn-Camping via CFrame Injection
```lua
-- Teleport to spawn and AoE damage
local spawnCFrame = workspace.SpawnLocation.CFrame
ReplicatedStorage.Remotes.ClientInfo:FireServer("BodySlam", spawnCFrame)
-- Result: Teleport to spawn, damage all spawning players
```

## Impact

- **Cross-map targeting**: Hit any player regardless of distance
- **Duration manipulation**: Apply status effects for arbitrary durations
- **Victim teleportation**: Force other players to specific positions
- **Spawn camping**: Teleport to strategic locations and AoE damage
- **Combo locks**: Keep players permanently stunned

## Affected Skills

| Skill | Pattern | Impact |
|-------|---------|--------|
| Rise | A1 | Victim + Duration control |
| Inferior | A2 | Direct victim targeting |
| Anguish | A3 | 8-second victim lock |
| Skewer | B1 | BOTH player positioning |
| BodySlam | C1 | Teleport + AoE |
| RapidJabs | C2 | Teleport + Grab |
| Siphon | C3 | Teleport + AoE |
| AerialSmite | D1 | Attack origin control |
| Entry | D2 | Hitbox positioning |

## IMPORTANT: Exploitation Timing

**Server-side listeners only exist during active skill execution.**

The server creates `OnServerEvent` listeners inside `module.Script()` which means:
1. The skill must be initiated normally (player uses the skill)
2. The server listener only exists for a limited time (e.g., 4-10 seconds)
3. Direct `FireServer` calls without the skill running will be ignored

### Correct Exploitation Approach

These exploits work by **hooking the client's FireServer calls** during normal skill use:

```lua
-- Hook the ClientInfo remote to inject malicious data
local oldFireServer = nil
oldFireServer = hookfunction(ReplicatedStorage.Remotes.ClientInfo.FireServer, function(self, skillName, ...)
    local args = {...}

    -- V04/V29: Inject all players as enemies when PinpointShuriken fires
    if skillName == "PinpointShuriken" and Settings.V04_Enabled then
        args[1] = { enemiesDetected = GetAllEnemies() }
    end

    -- V29: Inject victim when Rise fires
    if skillName == "Rise" and Settings.V29_Enabled then
        args[1] = GetTargetCharacter()  -- Inject our chosen victim
        args[2] = 9999  -- Inject huge duration
    end

    return oldFireServer(self, skillName, unpack(args))
end)
```

This approach:
- Intercepts the client's legitimate skill usage
- Modifies the data before sending to server
- Server listener exists because skill is running normally

### Why Direct FireServer Doesn't Work

```lua
-- This does NOTHING because no server listener exists:
ClientInfoRemote:FireServer("Anguish", targetPlayer.Character)

-- The server module only creates listeners DURING skill execution:
-- AnguishModule_ID116.luau:184
-- var43_upvw = var3_upvw.conTimer(ReplicatedStorage.Remotes.ClientInfo.OnServerEvent:Connect(...)
-- This listener only exists after module.Script() is called
```

## Remediation

```lua
-- 1. Never trust client-provided victim references
local function validateVictim(attacker, claimedVictim)
    if not claimedVictim or not claimedVictim:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    -- Verify victim is within skill range
    local distance = (claimedVictim.HumanoidRootPart.Position - attacker.HumanoidRootPart.Position).Magnitude
    if distance > MAX_SKILL_RANGE then
        return nil
    end

    return claimedVictim
end

-- 2. Server-side victim detection
local function findValidVictims(attacker, range)
    local victims = {}
    for _, player in game.Players:GetPlayers() do
        if player.Character and player.Character ~= attacker then
            local distance = (player.Character.HumanoidRootPart.Position - attacker.HumanoidRootPart.Position).Magnitude
            if distance <= range then
                table.insert(victims, player.Character)
            end
        end
    end
    return victims
end

-- 3. Clamp duration values
local function validateDuration(duration, maxDuration)
    return math.clamp(duration or 1, 0, maxDuration)
end

-- 4. Validate CFrame is reasonable
local function validateCFrame(attacker, clientCFrame, maxDistance)
    local distance = (clientCFrame.Position - attacker.HumanoidRootPart.Position).Magnitude
    if distance > maxDistance then
        return attacker.HumanoidRootPart.CFrame
    end
    return clientCFrame
end
```

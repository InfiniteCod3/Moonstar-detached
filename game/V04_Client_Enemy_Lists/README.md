# V04: Client-Trusted Enemy Lists

## Severity: CRITICAL

## Vulnerability Summary

The server blindly trusts the `arg3.enemiesDetected` list sent by the client via the `ClientInfo` remote event. Instead of performing server-side detection of valid targets within range, the server iterates over whatever targets the client provides and applies damage, status effects, and visual effects to those targets. This allows malicious clients to specify arbitrary players or NPCs as targets, enabling attacks on players anywhere in the game regardless of actual proximity or line of sight.

---

## Affected Files

| File | Module ID | Skill Name | Vulnerable Lines |
|------|-----------|------------|------------------|
| `/mnt/c/Users/User/Downloads/game/RapidIceModule_ID73.luau` | ID73 | Rapid Ice (Snow Blasters) | Lines 61-264 |
| `/mnt/c/Users/User/Downloads/game/PinpointShurikenModule_ID99.luau` | ID99 | Pinpoint Shuriken (Cyber Katana Ultimate) | Lines 145-430 |
| `/mnt/c/Users/User/Downloads/game/RiseModule_ID84.luau` | ID84 | Rise (Titans Edge Ultimate) | Lines 56-253 |

---

## Vulnerable Code Snippets

### RapidIceModule_ID73.luau (Lines 61-90, 176-207)

```lua
-- Line 61-64: Server event listener accepts client-provided enemy list
var24_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2, arg3)
    -- ...
    if arg2_2 ~= "RapidIce" or arg1_3 ~= arg2 then
    else
        var24_upvw:Disconnect()

        -- Line 80: Only checks if list is empty, not if targets are valid
        if #arg3.enemiesDetected <= 0 then
            any_LoadAnimation_result1_upvr:Stop()
        end

        -- Line 83: Iterates directly over client-provided enemy list
        for _, v_3_upvr in arg3.enemiesDetected do
            local var37 = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 40
            local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 40, Vector3.new(0, -100000, 0), var2_upvw.raycastParams)
            if workspace_Raycast_result1 then
                var37 = workspace_Raycast_result1.Position
            end

            -- Line 89: Weak range check (25 studs) - can be bypassed with spoofed positions
            if (var37 - v_3_upvr.HumanoidRootPart.Position).Magnitude <= 25 then
                -- ... applies damage and effects to client-specified targets
```

```lua
-- Lines 176-207: Damage applied to client-specified targets
if not var2_upvw.CheckBlock(v_3_upvr) then
    var47_upvw += 1
    -- ... sound effects ...
    var2_upvw.applyDamage(v_3_upvr, 3)  -- Line 203: Damage applied
    var2_upvw.applyStatus(v_3_upvr, "Stunned", 0.6)  -- Line 205
    var2_upvw.applyStatus(v_3_upvr, "Slowed", 0.8)  -- Line 207
end
```

### PinpointShurikenModule_ID99.luau (Lines 145-186, 270-350)

```lua
-- Line 145: Server event listener accepts client-provided enemy list
var32_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_5, arg2_3, arg3)
    -- ...
    if arg2_3 ~= "PinpointShuriken" or arg1_5 ~= arg2 then
    else
        var32_upvw:Disconnect()
        any_LoadAnimation_result1_upvr:Stop()

        -- Line 165: Only checks if list is empty
        if #arg3.enemiesDetected <= 0 then return end

        -- ... visual effects setup ...

        -- Line 180: Iterates directly over client-provided enemy list
        for _, v_2_upvr in arg3.enemiesDetected do
            local var41 = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 40
            local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 40, Vector3.new(0, -100000, 0), var2_upvw.raycastParams)
            if workspace_Raycast_result1 then
                var41 = workspace_Raycast_result1.Position
            end

            -- Line 186: Extremely weak range check (500 studs!) - nearly useless
            if (var41 - v_2_upvr.HumanoidRootPart.Position).Magnitude <= 500 then
                -- ... spawns homing projectiles at client-specified targets
```

```lua
-- Lines 270-350: Damage and effects applied to client-specified targets
if not var2_upvw.CheckBlock(v_2_upvr) then
    -- ... visual effects ...
    var2_upvw.applyDamage(v_2_upvr, 7)  -- Line 350: 7 damage per hit
    -- Also applies CyberCube trap (3 second stun) at lines 308-309
    var2_upvw.applyStatus(v_2_upvr, "Stunned", 3)
    var2_upvw.applyStatus(v_2_upvr, "AutoRotate", 3)
end
```

### RiseModule_ID84.luau (Lines 56-85, 115-243)

```lua
-- Line 56: Server event listener - NOTE: arg3 is DIRECTLY the target, not a list!
var20_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3, arg4)
    -- ...
    var20_upvw:Disconnect()

    -- Line 71: Only IFrames check on target, no validation that target is in range
    if PlayerStatus_upvr.FindStatus(arg3, "IFrames") then
    else
        var3_upvw.CheckBlock(arg3, true)
        var3_upvw.unragdoll(arg3)

        -- Lines 75-77: Operates directly on client-specified target
        for _, v_2 in arg3.Humanoid:GetPlayingAnimationTracks() do
            v_2:AdjustSpeed(0)
        end

        -- Lines 84-85: Status effects applied to client-specified target
        var3_upvw.applyStatus(arg3, "Stunned", arg4 + 1)
        var3_upvw.applyStatus(arg3, "IFrames", arg4 + 1)

        -- Line 88: Weld applied to client-specified target (teleport grab)
        local any_applyWeld_result1_upvr = var3_upvw.applyWeld(arg3, Vector3.new(0, 0, 6), Vector3.new(0, 180, 0))
```

```lua
-- Lines 115-243: Massive damage combo applied to client-specified target
var3_upvw.applyDamage(arg3, 10, true, true)  -- Line 115: First hit
-- ... teleport sequence ...
var3_upvw.applyDamage(arg3, 10, true, true)  -- Line 231: Second hit
var3_upvw.applyDamage(arg3, 10, true)        -- Line 242: Third hit
var3_upvw.applyStatus(arg3, "Ragdoll", 3)    -- Line 243: Final ragdoll
-- Total: 30 damage + stun + ragdoll to ANY player specified by client
```

---

## How The Exploit Works

### Attack Flow

1. **Client Activation**: The attacker uses the skill normally, which triggers the server-side skill script to start listening for the `ClientInfo` remote event.

2. **Legitimate Flow (Normal)**:
   - Client performs local detection of enemies in range
   - Client sends detected enemies via `ClientInfo:FireServer("SkillName", {enemiesDetected = {...}})`
   - Server trusts this list and applies damage/effects

3. **Exploit Flow (Malicious)**:
   - Attacker intercepts or replaces the client-side detection
   - Attacker crafts a custom `enemiesDetected` table containing arbitrary player/NPC references
   - Attacker fires: `ClientInfo:FireServer("RapidIce", {enemiesDetected = {targetPlayer1, targetPlayer2, ...}})`
   - Server iterates through attacker-specified targets and damages them

### Step-by-Step Exploitation

1. **Obtain target references**: The attacker uses `game.Players:GetPlayers()` or similar to get references to victim players.

2. **Activate the skill**: Fire the appropriate skill activation remote to trigger the server listener.

3. **Send malicious payload**: Within the timing window (before the listener disconnects), send the `ClientInfo` event with fabricated enemy list.

4. **Profit**: Server damages the specified targets regardless of their actual position.

### Why Range Checks Are Insufficient

- **RapidIceModule**: Uses 25 stud check but calculates from a forward position, not actual proximity
- **PinpointShurikenModule**: Uses 500 stud range - virtually useless protection
- **RiseModule**: NO range check at all - accepts any target directly

---

## Impact Assessment

### Severity Breakdown

| Impact Category | Rating | Description |
|----------------|--------|-------------|
| **Confidentiality** | Low | No data exposure |
| **Integrity** | Critical | Game state can be arbitrarily manipulated |
| **Availability** | High | Players can be killed/stunned remotely |

### Specific Impacts

1. **Remote Player Killing**: Attackers can kill any player anywhere on the map
2. **Status Effect Abuse**: Apply stuns, slows, ragdolls to victims remotely
3. **Griefing at Scale**: Target multiple players simultaneously
4. **PvP Cheating**: Guaranteed hits in PvP without aiming
5. **Economy Impact**: If kills grant rewards, this enables farming
6. **Player Retention**: Victims quit due to unexplainable deaths

### CVSS-like Scoring

- **Attack Vector**: Network (Remote)
- **Attack Complexity**: Low (Simple script modification)
- **Privileges Required**: Low (Must be in-game)
- **User Interaction**: None
- **Scope**: Changed (Affects other players)

**Estimated Severity Score: 9.1/10 (CRITICAL)**

---

## Remediation Recommendations

### Immediate Fixes

1. **Server-Side Target Detection**: Replace client-provided enemy lists with server-side detection:

```lua
-- SECURE: Server detects enemies in range
local function getEnemiesInRange(character, range)
    local enemies = {}
    local position = character.HumanoidRootPart.Position

    for _, player in game.Players:GetPlayers() do
        if player.Character and player.Character ~= character then
            local enemyPos = player.Character.HumanoidRootPart.Position
            if (position - enemyPos).Magnitude <= range then
                -- Additional validation: line of sight, same zone, etc.
                table.insert(enemies, player.Character)
            end
        end
    end
    return enemies
end
```

2. **Remove Client Enemy List Trust**: Do not use `arg3.enemiesDetected` at all. Detect server-side.

3. **Add Proper Validation**: If client hints are used for optimization, validate every target:

```lua
-- Validate each claimed target
for _, claimedEnemy in arg3.enemiesDetected do
    -- Verify target exists
    if not claimedEnemy or not claimedEnemy.Parent then continue end

    -- Verify target is actually in range (server calculation)
    local distance = (HumanoidRootPart.Position - claimedEnemy.HumanoidRootPart.Position).Magnitude
    if distance > MAX_RANGE then continue end

    -- Verify line of sight
    local rayResult = workspace:Raycast(HumanoidRootPart.Position,
        (claimedEnemy.HumanoidRootPart.Position - HumanoidRootPart.Position), raycastParams)
    if rayResult and rayResult.Instance:IsDescendantOf(claimedEnemy) then
        -- Target is valid - proceed
    end
end
```

### Long-Term Recommendations

1. **Implement Server Authority Pattern**: All combat calculations must be server-authoritative
2. **Rate Limiting**: Limit how often skills can be used and how many targets can be hit
3. **Logging**: Log all skill usages with targets for abuse detection
4. **Anti-Cheat**: Detect impossible targeting patterns (hitting players across map)
5. **Code Review**: Audit all RemoteEvent handlers for similar trust issues

---

## References

- Roblox Security Best Practices: https://create.roblox.com/docs/scripting/security/security-best-practices
- Server Authority Pattern: https://devforum.roblox.com/t/server-authoritative-combat
- CWE-602: Client-Side Enforcement of Server-Side Security

---

## Document Information

- **Vulnerability ID**: V04_Client_Enemy_Lists
- **Discovery Date**: 2025-12-18
- **Author**: Security Analysis
- **Classification**: Critical Security Vulnerability

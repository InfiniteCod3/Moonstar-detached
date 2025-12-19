# V02_CFrame_Injection

## Severity: CRITICAL

## Vulnerability Summary

The server accepts raw CFrame (Coordinate Frame) data directly from the client via the `ClientInfo` RemoteEvent and uses it without any validation to position players, hitboxes, and skill effects. This allows malicious clients to inject arbitrary position and rotation data, enabling teleportation, impossible attack angles, and complete manipulation of combat mechanics.

## Description

CFrame in Roblox represents a 3D coordinate frame containing both position (Vector3) and rotation (orientation matrix). When the server blindly trusts client-supplied CFrame data, attackers can:

1. **Teleport anywhere on the map** by sending false position data
2. **Attack from impossible angles** by manipulating the LookVector
3. **Bypass range/distance checks** by positioning hitboxes at victim locations
4. **Manipulate other players' positions** when skills affect enemy placement

The vulnerability exists because the server-side skill modules directly consume `arg3.ClientCF` or `arg3` (raw CFrame) values from the `ClientInfo.OnServerEvent` handler without:
- Validating the CFrame is within reasonable distance of the player's actual position
- Checking if the position is reachable/valid
- Verifying the CFrame timestamp or movement speed
- Sanitizing for NaN/Inf values that could crash the server

## Affected Files and Vulnerable Code

### File 1: `/mnt/c/Users/User/Downloads/game/SkewerModule_ID7.luau`

**Lines 127-148** - Server accepts client CFrame and directly applies it to both the attacker and victim:

```lua
-- Line 127-148
var3_upvw.conTimer(var3_upvw.conTimer(Remotes_upvr.ClientInfo.OnServerEvent:Connect(function(arg1_5, arg2_2, arg3) -- Line 177
    --[[ Upvalues[5]:
        [1]: arg2 (readonly)
        [2]: var28_upvw (read and write)
        [3]: var27_upvw (read and write)
        [4]: HumanoidRootPart_2_upvr (readonly)
        [5]: var3_upvw (copied, read and write)
    ]]
    if arg1_5 ~= arg2 or arg2_2 ~= "Skewer" then
    else
        if not var28_upvw then return end
        local HumanoidRootPart = var28_upvw:FindFirstChild("HumanoidRootPart")
        if var27_upvw then
            var27_upvw:Destroy()
        end
        HumanoidRootPart_2_upvr.CFrame = arg3.ClientCF                                    -- LINE 142: VULNERABLE
        HumanoidRootPart.CFrame = (arg3.ClientCF + HumanoidRootPart_2_upvr.CFrame.LookVector * 3) * CFrame.Angles(0, math.pi, 0)  -- LINE 143: VULNERABLE
        HumanoidRootPart_2_upvr.Velocity = Vector3.new(0, 0, 0)
        HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        var3_upvw.Knockback(var28_upvw, HumanoidRootPart_2_upvr.Position, 5)
    end
end), module_upvr.Cooldown), 5)
```

**Critical Issues:**
- Line 142: Attacker's HumanoidRootPart.CFrame is set directly from `arg3.ClientCF`
- Line 143: Victim's HumanoidRootPart.CFrame is calculated from the injected CFrame
- No validation of distance, position validity, or reachability

### File 2: `/mnt/c/Users/User/Downloads/game/BindModule_ID42.luau`

**Lines 39-66** - Server accepts client CFrame and uses it for skill indicator positioning:

```lua
-- Lines 39-83
var11_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 48
    --[[ Upvalues[10]:
        [1]: arg2 (readonly)
        [2]: var11_upvw (read and write)
        [3]: var3_upvw (copied, read and write)
        ...
    ]]
    -- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
    if arg1_2 ~= arg2 or arg2_2 ~= "Bind" then
    else
        var11_upvw:Disconnect()
        var3_upvw.applySound(Bind_upvr.Snap, HumanoidRootPart_upvr)
        var3_upvw.changeFov(arg1, 65, 0, 2)
        var3_upvw.camShake(arg1, "SmallBump")
        task.wait()
        local clone_2_upvr = Bind_upvr.Indicator:Clone()
        clone_2_upvr.Parent = Folder_upvr
        clone_2_upvr.CFrame = arg3 + arg3.LookVector * 30 + Vector3.new(0, -2.9000, 0)    -- LINE 62: VULNERABLE
        var3_upvw.EmitAllDescendants(clone_2_upvr)
        var3_upvw.applyDebris(clone_2_upvr, 3)
        ...
```

**Critical Issues:**
- Line 62: `arg3` is a raw CFrame from the client used directly for indicator/hitbox positioning
- The hitbox can be placed at any location the attacker specifies
- Line 83: `findEnemiesPart(clone_2_upvr.hitbox, true)` uses the client-positioned hitbox to find victims

### File 3: `/mnt/c/Users/User/Downloads/game/EntryModule_ID15.luau`

**Lines 94-116** - Server accepts client CFrame and uses it for attack targeting:

```lua
-- Lines 94-116
var22_upvw = var3_upvw.conTimer(Remotes_upvr.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 83
    --[[ Upvalues[8]:
        [1]: arg2 (readonly)
        [2]: var22_upvw (read and write)
        [3]: var10_upvw (read and write)
        ...
    ]]
    if arg1_2 ~= arg2 or arg2_2 ~= "Entry" then
    else
        var22_upvw:Disconnect()
        var10_upvw = arg3.ClientCF + arg3.ClientCF.LookVector * 12 + Vector3.new(0, -5, 0)  -- LINE 108: VULNERABLE
        table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "AutoRotate", 0.5))
        task.wait(0.15)
        var3_upvw.applyVFX(Entry_upvr.VFX.landVFX, HumanoidRootPart_upvr)
        var3_upvw.applySound(Entry_upvr.landSFX, HumanoidRootPart_upvr)
        var3_upvw.CreateDebris(var10_upvw.Position, 10, 1, 0.5, 0.1)                        -- LINE 113: Uses injected position
        var3_upvw.crater(1, var10_upvw.Position, 2, 0.7)                                   -- LINE 114: Uses injected position
    end
end), module_upvr.Cooldown)
```

**Later in the code (Lines 73-84), the injected CFrame is used for damage calculations:**

```lua
-- Lines 73-84
for _, v in var3_upvw.findEnemiesMagnitude(var20 + var10_upvw.LookVector * 5, 11, true), nil do
    if not var3_upvw.CheckBlock(v, true) then
        var20 = true
        var3_upvw.applyDamage(v, 15)
        var3_upvw.applyStatus(v, "Ragdoll", 1.5)
        var3_upvw.applyVFX(Entry_upvr.VFX.hitVFX, v.Torso)
        var3_upvw.applySound(Entry_upvr.hitSFX, v.Torso)
        var3_upvw.Knockback(v, var10_upvw.Position + HumanoidRootPart_upvr.CFrame.LookVector * -100, 8)
    end
end
```

**Critical Issues:**
- Line 108: Attack target position calculated from client-supplied `arg3.ClientCF`
- Lines 113-114: Effects placed at attacker-controlled position
- Lines 73-84: Enemy detection uses the injected CFrame for range calculations

## How the Exploit Works (Step by Step)

### Attack Scenario 1: Teleportation Exploit (Skewer)

1. Attacker initiates the "Skewer" skill normally
2. Client prepares to send CFrame data via `ClientInfo` RemoteEvent
3. Attacker intercepts/modifies the network call using an executor
4. Attacker sends a fabricated `ClientCF` pointing to any desired location
5. Server receives the data and executes line 142: `HumanoidRootPart_2_upvr.CFrame = arg3.ClientCF`
6. Attacker is instantly teleported to the fabricated position
7. Any grabbed victim is also repositioned relative to the attacker

### Attack Scenario 2: Remote Attack (Bind)

1. Attacker initiates the "Bind" skill
2. Instead of sending their actual position, attacker sends a CFrame located at a victim's position
3. Server places the `Indicator` (and its hitbox) at the victim's location
4. The `findEnemiesPart` function detects enemies near the injected hitbox position
5. Attacker can hit players from across the map

### Attack Scenario 3: Phantom Hitbox (Entry)

1. Attacker initiates the "Entry" skill
2. Attacker sends a CFrame positioned behind/inside walls or at victim locations
3. Server calculates attack position from injected data
4. `findEnemiesMagnitude` searches for enemies around the fake position
5. Attacker bypasses range limitations and line-of-sight requirements

## Impact Assessment

| Impact Category | Severity | Description |
|----------------|----------|-------------|
| **Gameplay Integrity** | CRITICAL | Complete destruction of fair combat mechanics |
| **Player Teleportation** | CRITICAL | Instant movement anywhere on the map |
| **Range Bypass** | CRITICAL | Attack players from any distance |
| **Position Manipulation** | HIGH | Force other players to specific locations |
| **Anti-Cheat Evasion** | HIGH | Hard to detect without server-side position tracking |
| **Server Stability** | MEDIUM | NaN/Inf injection could cause issues |

### Exploitation Difficulty: LOW
- Requires only basic executor knowledge
- CFrame manipulation is trivial
- No obfuscation or complex bypass needed

### Detection Difficulty: HIGH
- Attacks appear legitimate from server logs
- No obvious packet manipulation signatures
- Requires position history analysis to detect

## Remediation Recommendations

### 1. Server-Side Position Validation (REQUIRED)

```lua
-- Example validation function
local MAX_SKILL_RANGE = 50  -- studs
local MAX_TELEPORT_SPEED = 100  -- studs per second

local function validateClientCFrame(player, clientCF, skillName)
    local character = player.Character
    if not character then return nil end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local serverPos = hrp.Position
    local clientPos = clientCF.Position

    -- Check distance from server position
    local distance = (serverPos - clientPos).Magnitude
    if distance > MAX_SKILL_RANGE then
        warn("CFrame injection detected from " .. player.Name)
        return nil
    end

    -- Check for NaN/Inf values
    if clientPos ~= clientPos then  -- NaN check
        return nil
    end

    -- Validate position is in valid game bounds
    if clientPos.Y < -500 or clientPos.Y > 1000 then
        return nil
    end

    return clientCF
end
```

### 2. Use Server-Authoritative Positioning (RECOMMENDED)

```lua
-- Instead of trusting client CFrame, calculate on server
local function getServerCFrame(player)
    local character = player.Character
    if not character then return nil end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    return hrp.CFrame
end

-- In skill handler:
Remotes_upvr.ClientInfo.OnServerEvent:Connect(function(player, skillName, clientData)
    -- Ignore client position data, use server-tracked position
    local serverCF = getServerCFrame(player)
    if not serverCF then return end

    -- Use serverCF instead of clientData.ClientCF
    HumanoidRootPart.CFrame = serverCF
end)
```

### 3. Implement Movement Speed Validation

```lua
local lastPositions = {}

local function validateMovementSpeed(player, newCF)
    local now = tick()
    local lastData = lastPositions[player.UserId]

    if lastData then
        local timeDelta = now - lastData.time
        local distance = (newCF.Position - lastData.position).Magnitude
        local speed = distance / timeDelta

        if speed > MAX_TELEPORT_SPEED then
            return false  -- Impossible movement speed
        end
    end

    lastPositions[player.UserId] = {
        position = newCF.Position,
        time = now
    }

    return true
end
```

### 4. Add Rate Limiting for CFrame Updates

```lua
local cfUpdateCooldowns = {}
local CF_UPDATE_COOLDOWN = 0.1  -- seconds

local function rateLimitCFrameUpdate(player)
    local lastUpdate = cfUpdateCooldowns[player.UserId] or 0
    local now = tick()

    if now - lastUpdate < CF_UPDATE_COOLDOWN then
        return false
    end

    cfUpdateCooldowns[player.UserId] = now
    return true
end
```

### 5. Implement Sanity Checks for CFrame Values

```lua
local function sanitizeCFrame(cf)
    local pos = cf.Position
    local lookVector = cf.LookVector

    -- Check for NaN
    if pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z then
        return nil
    end

    -- Check for Infinity
    if math.abs(pos.X) == math.huge or math.abs(pos.Y) == math.huge or math.abs(pos.Z) == math.huge then
        return nil
    end

    -- Check for reasonable bounds
    if math.abs(pos.X) > 50000 or math.abs(pos.Y) > 10000 or math.abs(pos.Z) > 50000 then
        return nil
    end

    return cf
end
```

## References

- Roblox Developer Hub: [RemoteEvent Security](https://create.roblox.com/docs/scripting/networking/remote-events-and-functions#security)
- OWASP: Input Validation
- CWE-20: Improper Input Validation
- CWE-345: Insufficient Verification of Data Authenticity

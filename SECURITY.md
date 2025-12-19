# Security Vulnerability Report

**Game Skill System - Comprehensive Security Audit**

**Report Date:** December 2024
**Audit Scope:** All Luau skill modules and client scripts
**Total Files Analyzed:** 100+ module and client scripts
**Classification:** CONFIDENTIAL - For Developer Use Only

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Vulnerability Overview](#vulnerability-overview)
3. [Critical Vulnerabilities](#critical-vulnerabilities)
4. [High Severity Vulnerabilities](#high-severity-vulnerabilities)
5. [Medium Severity Vulnerabilities](#medium-severity-vulnerabilities)
6. [Low Severity Vulnerabilities](#low-severity-vulnerabilities)
7. [Affected Files Reference](#affected-files-reference)
8. [Exploitation Scenarios](#exploitation-scenarios)

---

## Executive Summary

This security audit reveals **systemic vulnerabilities** throughout the game's skill system. The fundamental architectural issue is **excessive client trust** - the server accepts and processes client-provided data (positions, targets, hitbox sizes) without validation.

### Key Findings

| Severity | Count | Description |
|----------|-------|-------------|
| **CRITICAL** | 5 | Immediate exploitation possible, game-breaking impact |
| **HIGH** | 3 | Significant gameplay advantage, easy to exploit |
| **MEDIUM** | 4 | Moderate impact, requires some knowledge to exploit |
| **LOW** | 2 | Minor issues, informational concerns |

### Risk Assessment

```
OVERALL RISK LEVEL: CRITICAL

The game is currently vulnerable to:
- Instant kill of all players on the server
- Unlimited range attacks (kill aura)
- Teleportation/noclip through walls
- Server denial of service
- Complete skill system exploitation
```

### Root Cause

The codebase follows a **client-authoritative** pattern where:
1. Client sends skill activation request
2. Server fires `ClientInfo` event to client
3. Client calculates positions/targets and sends back to server
4. **Server blindly trusts and uses client data**

This pattern is fundamentally insecure for competitive multiplayer games.

---

## Vulnerability Overview

### Vulnerability Distribution by Type

| Category | Critical | High | Medium | Low |
|----------|----------|------|--------|-----|
| Input Validation | 3 | 1 | 1 | 0 |
| Authorization | 1 | 2 | 0 | 0 |
| Logic Flaws | 1 | 0 | 1 | 0 |
| Resource Management | 0 | 0 | 2 | 0 |
| Information Disclosure | 0 | 0 | 0 | 2 |

---

## Critical Vulnerabilities

### VULN-001: Arbitrary Hitbox Size Manipulation

**Severity:** CRITICAL
**CVSS-like Score:** 10.0
**Exploitability:** Very Easy
**Impact:** Complete game compromise

#### Affected Files

| File | Line(s) | Function |
|------|---------|----------|
| `AgressiveBreezeModule_ID171.luau` | 77-78 | `OnServerEvent` handler |
| `RapidIceModule_ID73.luau` | ~61 | `OnServerEvent` handler |

#### Vulnerable Code

```lua
-- AgressiveBreezeModule_ID171.luau, Lines 77-78
clone_3.CFrame = arg3.CF           -- Client-controlled position!
clone_3.Size = Vector3.new(25, 25, arg3.SizeZ)  -- Client-controlled size!

-- Later at line 99, this hitbox is used for damage:
for _, v_2_upvr in var2_upvw.findEnemiesPart(clone_3), nil do
    -- ... applies damage to ALL players found in hitbox
    var2_upvw.applyDamage(v_2_upvr, 4)  -- Line 130
```

#### Technical Analysis

The server creates a hitbox part and sets its `CFrame` (position/rotation) and `Size` directly from client-provided data (`arg3.CF` and `arg3.SizeZ`). No validation is performed on:

- The magnitude of `SizeZ` (could be 0 to infinity)
- The position of `CF` (could be anywhere in the game world)
- The distance from the player's actual position

The `findEnemiesPart()` function then finds all enemy characters intersecting this hitbox and applies damage.

#### Proof of Concept

```lua
-- EXPLOIT: Server-Wide Instant Kill
-- Affects: All players on the server simultaneously

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo

-- Method 1: Single massive hitbox covering entire map
RemoteEvent:FireServer("Agressive Breeze", {
    CF = CFrame.new(0, 100, 0),  -- Center of map at Y=100
    SizeZ = 100000               -- 100,000 stud hitbox = covers everything
})

-- Method 2: Targeted position with large radius
local function killAllAtPosition(position)
    RemoteEvent:FireServer("Agressive Breeze", {
        CF = CFrame.new(position),
        SizeZ = 50000
    })
end

-- Method 3: Continuous server wipe
spawn(function()
    while wait(0.5) do  -- Every 0.5 seconds
        RemoteEvent:FireServer("Agressive Breeze", {
            CF = CFrame.new(0, 50, 0),
            SizeZ = 999999
        })
    end
end)

-- Expected Result:
-- Every player on the server receives damage from findEnemiesPart()
-- With SizeZ=100000, hitbox covers entire playable area
-- 4 damage per tick * repeated calls = instant death for all players
```

#### Impact

- **Instant server wipe**: Kill every player simultaneously
- **Unblockable damage**: No counterplay possible
- **Persistent abuse**: Can be spammed continuously
- **Competitive destruction**: Makes PvP meaningless

---

### VULN-002: Server-Side Position Teleportation

**Severity:** CRITICAL
**CVSS-like Score:** 9.8
**Exploitability:** Very Easy
**Impact:** Movement/positioning system bypass

#### Affected Files

| File | Line(s) | Vulnerability |
|------|---------|---------------|
| `SkewerModule_ID7.luau` | 142-143 | Direct CFrame assignment |
| `EntryModule_ID15.luau` | 108 | CFrame used for hit origin |
| `AerialSmiteModule_ID148.luau` | 84, 88 | Raycast origin from client |

#### Vulnerable Code

```lua
-- SkewerModule_ID7.luau, Lines 142-145
-- Server sets player position directly from client data!
HumanoidRootPart_2_upvr.CFrame = arg3.ClientCF
HumanoidRootPart.CFrame = (arg3.ClientCF + HumanoidRootPart_2_upvr.CFrame.LookVector * 3)
    * CFrame.Angles(0, math.pi, 0)
HumanoidRootPart_2_upvr.Velocity = Vector3.new(0, 0, 0)
HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
```

```lua
-- AerialSmiteModule_ID148.luau, Lines 84-88
-- Client controls where the raycast originates!
local workspace_Raycast_result1_upvr = workspace:Raycast(
    arg3.ClientCF.p,              -- CLIENT-CONTROLLED ORIGIN
    Vector3.new(0, -500, 0),
    var3_upvw.raycastParams
)
if workspace_Raycast_result1_upvr then
    local clone_3_upvr = Aerial_Smite_upvr.SpearThrow:Clone()
    clone_3_upvr.Parent = Folder_upvr
    clone_3_upvr.CFrame = arg3.ClientCF + Vector3.new(0, -5, 0)  -- Used directly!
```

#### Technical Analysis

These modules directly use `arg3.ClientCF` to:

1. **Teleport the attacker** (`SkewerModule`): The server sets the player's `HumanoidRootPart.CFrame` to any position
2. **Teleport victims** (`SkewerModule`): The target player is also repositioned
3. **Set attack origin** (`AerialSmiteModule`, `EntryModule`): Damage calculations use client position

#### Proof of Concept

```lua
-- EXPLOIT: Arbitrary Teleportation
-- Affects: Player position, map boundaries, collision

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Method 1: Teleport to specific coordinates
local function teleportTo(x, y, z)
    RemoteEvent:FireServer("Skewer", {
        ClientCF = CFrame.new(x, y, z)
    })
end

-- Teleport to sky (escape combat)
teleportTo(0, 1000, 0)

-- Teleport to secret/admin areas
teleportTo(12345, 100, 67890)

-- Teleport behind walls/barriers
teleportTo(-500, 50, -500)

-- Method 2: Teleport to another player's position
local function teleportToPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if target and target.Character then
        local targetPos = target.Character.HumanoidRootPart.Position
        RemoteEvent:FireServer("Skewer", {
            ClientCF = CFrame.new(targetPos)
        })
    end
end

-- Method 3: Rapid position cycling (noclip effect)
spawn(function()
    local startPos = LocalPlayer.Character.HumanoidRootPart.Position
    for i = 1, 100 do
        RemoteEvent:FireServer("Skewer", {
            ClientCF = CFrame.new(startPos + Vector3.new(0, 0, i * 10))
        })
        wait(0.05)
    end
end)

-- Method 4: Teleport victim player (using Skewer's dual teleport)
-- When Skewer hits, both attacker AND victim get repositioned
-- var28_upvw (victim) has their CFrame set based on attacker's ClientCF

-- Expected Result:
-- Player's server-side position is set to any CFrame value
-- Bypasses walls, boundaries, and movement validation
-- Can access any location in the game world
```

#### Impact

- **Noclip through walls**: Access any area of the map
- **Escape combat**: Teleport away when losing
- **Exploit map geometry**: Reach unintended areas
- **Skip game progression**: Bypass barriers/checkpoints

---

### VULN-003: Client-Controlled Hit Detection Origin

**Severity:** CRITICAL
**CVSS-like Score:** 9.5
**Exploitability:** Easy
**Impact:** Unlimited attack range

#### Affected Files

| File | Line(s) | Issue |
|------|---------|-------|
| `EntryModule_ID15.luau` | 75-84, 108 | Hit origin from client |
| `AerialSmiteModule_ID148.luau` | 146-171 | Damage area from client |

#### Vulnerable Code

```lua
-- EntryModule_ID15.luau, Lines 105-108
-- The attack origin is set from client-provided CFrame
var22_upvw:Disconnect()
var10_upvw = arg3.ClientCF + arg3.ClientCF.LookVector * 12 + Vector3.new(0, -5, 0)

-- Lines 73-84: This position is used for hit detection
var20 = var10_upvw.Position
var20 = false
for _, v in var3_upvw.findEnemiesMagnitude(var20 + var10_upvw.LookVector * 5, 11, true), nil do
    if not var3_upvw.CheckBlock(v, true) then
        var20 = true
        var3_upvw.applyDamage(v, 15)  -- 15 damage per hit
        var3_upvw.applyStatus(v, "Ragdoll", 1.5)
        var3_upvw.applyVFX(Entry_upvr.VFX.hitVFX, v.Torso)
        var3_upvw.applySound(Entry_upvr.hitSFX, v.Torso)
        var3_upvw.Knockback(v, var10_upvw.Position + HumanoidRootPart_upvr.CFrame.LookVector * -100, 8)
    end
end
```

#### Technical Analysis

The flow is:
1. Client sends `ClientCF` with skill activation
2. Server calculates `var10_upvw` (attack origin) from `arg3.ClientCF`
3. `findEnemiesMagnitude()` searches for enemies near `var10_upvw`
4. All enemies found receive damage

Since `var10_upvw` is derived from client data, attackers control where the damage search occurs.

#### Proof of Concept

```lua
-- EXPLOIT: Kill Aura / Infinite Reach
-- Affects: All players regardless of distance

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Method 1: Attack specific player from any distance
local function attackPlayer(targetPlayer)
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        RemoteEvent:FireServer("Entry", {
            ClientCF = targetPlayer.Character.HumanoidRootPart.CFrame
        })
    end
end

-- Method 2: Kill aura - attack ALL players continuously
spawn(function()
    while wait(0.1) do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    RemoteEvent:FireServer("Entry", {
                        ClientCF = rootPart.CFrame
                    })
                end
            end
        end
    end
end)

-- Method 3: Sniper mode - attack from spawn
local function sniperAttack()
    -- Stay at spawn, attack anyone who enters the game
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            wait(1)  -- Wait for spawn
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for i = 1, 10 do  -- 10 hits
                    RemoteEvent:FireServer("Entry", {
                        ClientCF = rootPart.CFrame
                    })
                    wait(0.1)
                end
            end
        end)
    end)
end

-- Method 4: Attack through walls
local function attackThroughWall(targetPosition)
    -- No line-of-sight check, just position
    RemoteEvent:FireServer("Entry", {
        ClientCF = CFrame.new(targetPosition)
    })
end

-- Expected Result:
-- Damage is applied at ClientCF position regardless of attacker location
-- 15 damage + Ragdoll + Knockback per hit
-- Can hit players across entire map
-- No distance validation = infinite range attacks
```

#### Impact

- **Kill Aura**: Hit all players simultaneously
- **Infinite Range**: Attack from anywhere on the map
- **Silent Kills**: Victim may not see the attacker
- **Camping Immunity**: Attack from safe positions

---

### VULN-004: Client-Provided Target List Exploitation

**Severity:** CRITICAL
**CVSS-like Score:** 9.0
**Exploitability:** Easy
**Impact:** Mass damage to arbitrary players

#### Affected Files

| File | Line(s) | Issue |
|------|---------|-------|
| `Client_ID100.luau` | 99-101 | Client sends enemy list |
| `PinpointShurikenModule_ID99.luau` | Various | Server trusts enemy list |

#### Vulnerable Code

```lua
-- Client_ID100.luau, Lines 99-101
-- Client builds list of "detected" enemies and sends to server
ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("PinpointShuriken", {
    enemiesDetected = tbl;  -- CLIENT-CONTROLLED LIST OF TARGETS
})
```

#### Technical Analysis

The client-side script:
1. Uses `findEnemiesPart()` to detect enemies in an indicator zone
2. Builds a table `tbl` of detected enemies
3. Sends this table directly to the server

The server then processes this list and applies damage/effects to each character in it, trusting that the client legitimately detected them.

#### Proof of Concept

```lua
-- EXPLOIT: Mass Target Attack
-- Affects: Server trusts client-provided target list

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Method 1: Target ALL players on server
local function attackAllPlayers()
    local allTargets = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            table.insert(allTargets, player.Character)
        end
    end

    RemoteEvent:FireServer("PinpointShuriken", {
        enemiesDetected = allTargets
    })
end

-- Method 2: Target specific players by name
local function attackSpecificPlayers(nameList)
    local targets = {}

    for _, name in pairs(nameList) do
        local player = Players:FindFirstChild(name)
        if player and player.Character then
            table.insert(targets, player.Character)
        end
    end

    RemoteEvent:FireServer("PinpointShuriken", {
        enemiesDetected = targets
    })
end

attackSpecificPlayers({"Player1", "Player2", "Player3"})

-- Method 3: Continuous mass attack
spawn(function()
    while wait(0.5) do
        attackAllPlayers()
    end
end)

-- Method 4: Target players behind cover/walls
-- Since detection is client-side, no line-of-sight check
local function attackHiddenPlayers()
    local targets = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Include ALL players, even those behind walls
            table.insert(targets, player.Character)
        end
    end
    RemoteEvent:FireServer("PinpointShuriken", {
        enemiesDetected = targets
    })
end

-- Expected Result:
-- Server iterates through enemiesDetected and applies effects to each
-- No distance check on server side
-- No line-of-sight validation
-- All specified players receive shuriken damage
```

#### Impact

- **Server-wide AoE**: Hit every player regardless of position
- **Skill range bypass**: Attack players across the entire map
- **Targeting impossible positions**: Hit players behind walls/cover

---

### VULN-005: Insecure Direct Object Reference (Target Injection)

**Severity:** CRITICAL
**CVSS-like Score:** 9.0
**Exploitability:** Easy
**Impact:** Attack any player remotely

#### Affected Files

| File | Line(s) | Issue |
|------|---------|-------|
| `InferiorModule_ID88.luau` | 77-87 | Direct target from client |

#### Vulnerable Code

```lua
-- InferiorModule_ID88.luau, Lines 61-87
var3_upvw.conTimer(var3_upvw.conTimer(
    ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3, arg4)
        if arg1_2 ~= arg2 or arg2_2 ~= "Inferior" then
        else
            -- arg3 is the target CHARACTER sent by client!
            if arg3 and not arg3:FindFirstChild("Inferior")
               and not PlayerStatus_upvr.FindStatus(arg3, "IFrames") then
                var16_upvw = arg3  -- Server trusts client's target choice
            end
            var20_upvw = arg4

            if not arg3:FindFirstChild("Inferior")
               and not PlayerStatus_upvr.FindStatus(arg3, "IFrames") then
                var3_upvw.unragdoll(var16_upvw)
                any_LoadAnimation_result1_2_upvr:AdjustSpeed(1)
                var3_upvw.CheckBlock(var16_upvw, true)
                var3_upvw.changeFov(arg1, 50, 0.01, 1)
                var3_upvw.camShake(arg1, "Bump")

                -- DAMAGE APPLIED TO CLIENT-SPECIFIED TARGET!
                var3_upvw.applyDamage(var16_upvw, 5, false, true)
```

#### Technical Analysis

The "Inferior" skill allows the client to specify which character (`arg3`) to target. The server:

1. Receives the target character directly from the client
2. Only checks if target has "Inferior" tag or "IFrames" status
3. **Does NOT verify** the target is within range of the attacker
4. Applies damage and status effects to the specified target

#### Proof of Concept

```lua
-- EXPLOIT: Remote Kill / Target Injection
-- Affects: Any player can be targeted regardless of distance

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Method 1: Attack any player by name
local function attackPlayerByName(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character then
        RemoteEvent:FireServer("Inferior", target.Character, {})
        -- Target receives:
        -- - 5 damage initially (line 87)
        -- - 10 damage from follow-up (line 193)
        -- - Stunned status for 3+ seconds
        -- - Knockback
        -- - Animation lock
    end
end

attackPlayerByName("VictimPlayer")

-- Method 2: Hunt specific player repeatedly
local function huntPlayer(playerName)
    spawn(function()
        while wait(1) do
            local target = Players:FindFirstChild(playerName)
            if target and target.Character then
                local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    RemoteEvent:FireServer("Inferior", target.Character, {})
                end
            end
        end
    end)
end

-- Method 3: Attack everyone sequentially
local function attackAllSequentially()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            RemoteEvent:FireServer("Inferior", player.Character, {})
            wait(0.5)  -- Small delay between attacks
        end
    end
end

-- Method 4: Spawn kill - attack players as they spawn
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        wait(0.5)  -- Wait for character to fully load
        RemoteEvent:FireServer("Inferior", char, {})
    end)
end)

-- Method 5: Attack through reference manipulation
-- Get character reference even if player is invisible/hidden
local function getHiddenPlayerCharacter(userId)
    for _, player in pairs(Players:GetPlayers()) do
        if player.UserId == userId then
            return player.Character
        end
    end
    return nil
end

-- Expected Result:
-- arg3 (target character) is accepted without distance validation
-- Only checks: "Inferior" tag and "IFrames" status
-- Full combo executes: damage + stun + knockback + animation
-- Attacker can be anywhere on the map
```

#### Impact

- **Remote Assassination**: Kill players from anywhere
- **No Line of Sight Required**: Attack through walls
- **Target Immunity Bypass**: Only IFrames blocks this
- **Harassment**: Repeatedly target specific players

---

## High Severity Vulnerabilities

### VULN-006: Missing Server-Side Cooldown Enforcement

**Severity:** HIGH
**CVSS-like Score:** 7.5
**Exploitability:** Easy
**Impact:** Skill spam, rapid damage

#### Affected Files

| File | Cooldown Value | Issue |
|------|----------------|-------|
| `BreakModule_ID51.luau` | 20 seconds | No server validation |
| `CrippleModule_ID57.luau` | 23 seconds | No server validation |
| `AgressiveBreezeModule_ID171.luau` | 11 seconds | No server validation |
| All skill modules | Various | Client-controlled timing |

#### Vulnerable Pattern

```lua
-- Common pattern across all modules:
local module_upvr = {
    Cooldown = 20;  -- This is client-side only!
    GlobalCD = 1;
}

-- The OnServerEvent handler does NOT check cooldown:
ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2)
    if arg1_3 ~= arg2 or arg2_2 ~= "Break" then
    else
        -- No cooldown check! Skill activates immediately
        var9_upvw = true
        any_LoadAnimation_result1_upvr:AdjustSpeed(1)
        -- ...skill proceeds...
    end
end)
```

#### Technical Analysis

Every skill module defines a `Cooldown` property, but this is only enforced client-side. The server's `OnServerEvent` handlers do not:

1. Track when each player last used a skill
2. Reject requests that violate cooldown timers
3. Implement any rate limiting

This means exploiters can bypass client-side cooldown logic and spam skills.

#### Proof of Concept

```lua
-- EXPLOIT: Cooldown Bypass / Skill Spam
-- Affects: All skills can be used with no cooldown

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo

-- Method 1: Spam single high-damage skill
-- Break skill has 20 second cooldown, but server doesn't check
spawn(function()
    while wait(0.1) do  -- 10x per second instead of once per 20 seconds
        RemoteEvent:FireServer("Break", {})
    end
end)

-- Method 2: Rapid skill rotation
local skills = {"Break", "Cripple", "Entry", "Skewer"}
spawn(function()
    local i = 1
    while wait(0.05) do
        RemoteEvent:FireServer(skills[i], {})
        i = (i % #skills) + 1
    end
end)

-- Method 3: Ultimate spam
-- Ultimates typically have longest cooldowns (25+ seconds)
spawn(function()
    while wait(0.2) do
        RemoteEvent:FireServer("Agressive Breeze", {
            CF = CFrame.new(0, 100, 0),
            SizeZ = 50
        })
    end
end)

-- Method 4: Combo spam for maximum DPS
local function spamCombo()
    while true do
        RemoteEvent:FireServer("Entry", {ClientCF = targetCF})
        wait(0.05)
        RemoteEvent:FireServer("Break", {})
        wait(0.05)
        RemoteEvent:FireServer("Cripple", {})
        wait(0.05)
    end
end

-- Damage calculation comparison:
-- Normal play: 1 Break every 20 seconds = 20 damage per 20 sec = 1 DPS
-- Exploit: 10 Breaks per second = 200 damage per second = 200 DPS
-- Result: 200x damage increase

-- Expected Result:
-- Skills execute immediately regardless of intended cooldown
-- Server has no timestamp tracking per player per skill
-- Can achieve impossible DPS numbers
-- Effectively infinite skill usage
```

#### Impact

- **200x DPS Increase**: 20-second cooldown reduced to 0.1 seconds
- **Instant Kills**: Combo skills rapidly
- **Server Lag**: Excessive skill processing
- **Competitive Imbalance**: Exploiters dominate legitimate players

---

### VULN-007: Client Authority Over Game State

**Severity:** HIGH
**CVSS-like Score:** 7.0
**Exploitability:** Medium
**Impact:** Desynchronized game state

#### Affected Files

Multiple `Client_ID*.luau` files send critical game state to the server:

| File | Data Sent | Issue |
|------|-----------|-------|
| `Client_ID100.luau` | Enemy list | Server trusts detection |
| `Client_ID102.luau` | Position data | Server uses for attacks |
| `Client_ID10.luau` | Skill parameters | Unvalidated |

#### Vulnerable Pattern

```lua
-- Client_ID100.luau, Line 99-101
-- Client sends list of detected enemies
ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("PinpointShuriken", {
    enemiesDetected = tbl;  -- Server should detect, not client!
})

-- Client_ID102.luau (based on pattern analysis)
-- Client sends its position for skill calculations
ReplicatedStorage.Remotes.ClientInfo:FireServer("SkillName", {
    ClientCF = HumanoidRootPart.CFrame  -- Can be spoofed!
})
```

#### Technical Analysis

The game follows a pattern where:
1. Server initiates skill via `FireClient`
2. Client performs calculations (position, targeting, timing)
3. Client sends results back via `FireServer`
4. Server trusts and processes the results

This is fundamentally backwards from secure game architecture.

#### Impact

- Client can send any data, not just legitimate calculations
- Server has no way to verify client claims
- All dependent systems become exploitable

---

### VULN-008: Animation-Based State Bypass

**Severity:** HIGH
**CVSS-like Score:** 6.5
**Exploitability:** Medium
**Impact:** Skill timing manipulation

#### Affected Files

All module files that use animation markers for skill phases:

```lua
-- Common pattern in all modules:
var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function()
    -- Damage is applied when animation reaches "slash" marker
    for _, v in var3_upvw.findEnemiesPart(clone, true), nil do
        var3_upvw.applyDamage(v, 20)
    end
end), module_upvr.Cooldown)
```

#### Technical Analysis

Skills use animation markers to trigger damage phases. While the animation is loaded server-side, the client can potentially:

1. Manipulate animation speed locally
2. Send premature `FireServer` calls
3. Desynchronize with server animation state

#### Impact

- Skip charge-up phases
- Trigger damage before animation completes
- Break skill timing assumptions

---

## Medium Severity Vulnerabilities

### VULN-009: Resource Exhaustion via Connection Accumulation

**Severity:** MEDIUM
**CVSS-like Score:** 6.0
**Exploitability:** Medium
**Impact:** Server performance degradation

#### Affected Pattern

```lua
-- All modules use conTimer for connection management:
var3_upvw.conTimer(
    ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(...)
        -- Handler code
    end),
    module_upvr.Cooldown  -- Timeout in seconds
)
```

#### Technical Analysis

The `conTimer` function is designed to auto-disconnect handlers after a timeout. However:

1. If skills are interrupted before completion, connections may not be cleaned up
2. Rapid skill activation creates many concurrent connections
3. Each connection consumes server memory and CPU

#### Proof of Concept

```lua
-- EXPLOIT: Connection Flooding / Server Lag
-- Affects: Server performance and stability

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo

-- Method 1: Rapid connection creation
-- Each FireServer creates a new OnServerEvent connection in the module
for i = 1, 1000 do
    spawn(function()
        RemoteEvent:FireServer("Break", {})
    end)
    wait()  -- Minimal delay
end

-- Method 2: Multi-skill connection spam
local skills = {"Break", "Cripple", "Entry", "Skewer", "Inferior"}
for i = 1, 500 do
    for _, skill in pairs(skills) do
        spawn(function()
            RemoteEvent:FireServer(skill, {})
        end)
    end
    wait()
end

-- Method 3: Sustained connection pressure
spawn(function()
    while true do
        for i = 1, 100 do
            RemoteEvent:FireServer("Break", {})
        end
        wait(0.1)
    end
end)

-- Expected Result:
-- Each skill creates OnServerEvent connection
-- conTimer schedules disconnection after Cooldown seconds
-- Rapid firing creates connection buildup before cleanup
-- Server memory increases, CPU usage spikes
-- Eventually causes lag for all players or server crash
```

#### Impact

- Server memory exhaustion
- CPU overload from connection management
- Lag for all players
- Potential server crash

---

### VULN-010: Unbounded Hitbox Iteration

**Severity:** MEDIUM
**CVSS-like Score:** 5.5
**Exploitability:** Medium
**Impact:** Server CPU spike

#### Affected Files

All modules using `findEnemiesPart` or `findEnemiesMagnitude`:

```lua
-- Common pattern:
for _, v in var3_upvw.findEnemiesPart(clone_3), nil do
    -- Process each enemy
    var3_upvw.applyDamage(v, 4)
    var3_upvw.applyStatus(v, "Ragdoll", 1)
    -- ... more processing
end
```

#### Technical Analysis

Combined with VULN-001 (hitbox size manipulation), an attacker can:

1. Create a hitbox covering the entire map
2. Force the server to iterate all players
3. Apply expensive operations to each player
4. Cause significant CPU load

#### Impact

- Server CPU spike on each attack
- Multiplied by cooldown bypass = sustained high CPU
- Can cause server-wide lag

---

### VULN-011: Missing Global Rate Limiting

**Severity:** MEDIUM
**CVSS-like Score:** 5.0
**Exploitability:** Easy
**Impact:** Remote event flooding

#### Technical Analysis

There is no global rate limit on `RemoteEvent` firing. Players can send unlimited requests per second.

#### Proof of Concept

```lua
-- EXPLOIT: Remote Event Flooding
-- Affects: Server processing capacity

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo

-- Method 1: Maximum throughput flooding
spawn(function()
    while true do
        RemoteEvent:FireServer("Break", {})
        -- No wait() = maximum possible rate
    end
end)

-- Method 2: Multi-threaded flooding
for i = 1, 50 do
    spawn(function()
        while true do
            RemoteEvent:FireServer("Entry", {ClientCF = CFrame.new(0,0,0)})
        end
    end)
end

-- Method 3: Garbage data flooding
spawn(function()
    while true do
        RemoteEvent:FireServer("InvalidSkill", {
            garbage = string.rep("x", 10000),  -- Large payload
            moreGarbage = {}
        })
    end
end)

-- Expected Result:
-- Server processes every FireServer call
-- No rate limiting = unlimited processing load
-- Can send thousands of requests per second
-- Server becomes unresponsive
```

#### Impact

- Server overwhelmed with requests
- All players experience lag
- Potential denial of service

---

### VULN-012: Blocking Status Bypass

**Severity:** MEDIUM
**CVSS-like Score:** 4.5
**Exploitability:** Medium
**Impact:** Defense mechanism bypass

#### Affected Code

```lua
-- InferiorModule_ID88.luau, Line 77
if arg3 and not arg3:FindFirstChild("Inferior")
   and not PlayerStatus_upvr.FindStatus(arg3, "IFrames") then
    -- Attack proceeds
```

#### Technical Analysis

Some skills check for `IFrames` or `Blocking` status, but:

1. Checks are done on client-provided target, not server-validated target
2. Status checks happen at moment of request, not moment of impact
3. Race conditions can allow hits during brief status gaps

#### Impact

- Defense abilities less effective
- Timing exploits possible
- Reduces counterplay options

---

## Low Severity Vulnerabilities

### VULN-013: Information Disclosure in Source Comments

**Severity:** LOW
**CVSS-like Score:** 2.0
**Exploitability:** N/A (Passive)
**Impact:** Aids reverse engineering

#### Affected Files

All files contain decompiler metadata:

```lua
-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau
-- by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:06
```

#### Impact

- Reveals tools used to extract game code
- Provides Discord links to exploitation communities
- Indicates code is already being reverse-engineered

---

### VULN-014: Debug/Development Patterns in Production

**Severity:** LOW
**CVSS-like Score:** 1.5
**Exploitability:** N/A
**Impact:** Code quality concern

#### Examples

```lua
-- Decompiler error comments left in code:
-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [294.8]

-- Unused nil checks:
if nil then
    -- Dead code
end
```

#### Impact

- Indicates incomplete decompilation (logic may be missing)
- Dead code paths may cause unexpected behavior
- Makes code harder to audit and maintain

---

## Affected Files Reference

### Critical Risk Files

| File | Vulnerabilities | Priority |
|------|-----------------|----------|
| `AgressiveBreezeModule_ID171.luau` | VULN-001, VULN-006 | Immediate |
| `SkewerModule_ID7.luau` | VULN-002, VULN-006 | Immediate |
| `EntryModule_ID15.luau` | VULN-002, VULN-003, VULN-006 | Immediate |
| `InferiorModule_ID88.luau` | VULN-005, VULN-006 | Immediate |
| `AerialSmiteModule_ID148.luau` | VULN-002, VULN-003, VULN-006 | Immediate |

### High Risk Files

| File | Vulnerabilities | Priority |
|------|-----------------|----------|
| `Client_ID100.luau` | VULN-004, VULN-007 | High |
| `BreakModule_ID51.luau` | VULN-006, VULN-009 | High |
| `CrippleModule_ID57.luau` | VULN-006, VULN-009 | High |
| `RapidIceModule_ID73.luau` | VULN-001, VULN-006 | High |

### All Skill Modules (Require Cooldown Fix)

All `*Module_ID*.luau` files are affected by VULN-006 (missing cooldown enforcement).

---

## Exploitation Scenarios

### Scenario 1: "God Mode" Exploit Chain

An attacker combines multiple vulnerabilities for complete dominance:

```lua
-- COMBINED EXPLOIT: God Mode
-- Uses: VULN-003 (infinite range) + VULN-005 (target injection) + VULN-006 (no cooldown)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo

-- Attack every player continuously with no cooldown
spawn(function()
    while wait(0.1) do  -- 10 attacks per second
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    -- Entry attack at their position (VULN-003)
                    RemoteEvent:FireServer("Entry", {
                        ClientCF = rootPart.CFrame
                    })

                    -- Direct target attack (VULN-005)
                    RemoteEvent:FireServer("Inferior", player.Character, {})
                end
            end
        end
    end
end)

-- Expected Result:
-- Every player on server receives damage every 0.1 seconds
-- Entry: 15 damage + ragdoll + knockback
-- Inferior: 5 + 10 damage + stun + knockback
-- Combined: ~30 damage per 0.1 seconds = 300 DPS to everyone
-- All players die repeatedly, unable to play
```

**Result:** Every player dies repeatedly, game becomes unplayable.

### Scenario 2: Server Crash

```lua
-- COMBINED EXPLOIT: Denial of Service
-- Uses: VULN-001 (huge hitbox) + VULN-009 (connection flood) + VULN-011 (no rate limit)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo

-- Create 100 concurrent flooding threads
for i = 1, 100 do
    spawn(function()
        while true do
            -- Massive hitbox forces iteration over all players (VULN-001)
            RemoteEvent:FireServer("Agressive Breeze", {
                CF = CFrame.new(math.random(-1000, 1000), 100, math.random(-1000, 1000)),
                SizeZ = 999999
            })

            -- Each call creates connections that accumulate (VULN-009)
            -- No rate limiting allows unlimited calls (VULN-011)
        end
    end)
end

-- Additional flood with other skills
for i = 1, 50 do
    spawn(function()
        while true do
            RemoteEvent:FireServer("Break", {})
            RemoteEvent:FireServer("Cripple", {})
            RemoteEvent:FireServer("Entry", {ClientCF = CFrame.new(0,0,0)})
        end
    end)
end

-- Expected Result:
-- Server receives thousands of requests per second
-- Each request creates connections, iterates players, applies effects
-- Memory usage spikes from connection accumulation
-- CPU maxes out from hitbox calculations
-- All players experience severe lag
-- Server eventually crashes or becomes completely unresponsive
```

**Result:** Server CPU maxes out, all players experience lag/disconnect.

### Scenario 3: Competitive Match Fixing

```lua
-- COMBINED EXPLOIT: Tournament Cheating
-- Uses: VULN-002 (teleport) + VULN-003 (infinite range) + VULN-006 (no cooldown)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo

-- Phase 1: Teleport to objective instantly (VULN-002)
local function teleportToObjective()
    RemoteEvent:FireServer("Skewer", {
        ClientCF = CFrame.new(OBJECTIVE_POSITION)
    })
end

-- Phase 2: Kill all enemies from spawn (VULN-003)
local function spawnCamp()
    spawn(function()
        while wait(0.5) do
            for _, player in pairs(Players:GetPlayers()) do
                if player.Team ~= LocalPlayer.Team and player.Character then
                    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        RemoteEvent:FireServer("Entry", {
                            ClientCF = rootPart.CFrame
                        })
                    end
                end
            end
        end
    end)
end

-- Phase 3: Spam ultimates for guaranteed kills (VULN-006)
local function spamUltimates()
    spawn(function()
        while wait(0.2) do
            RemoteEvent:FireServer("Agressive Breeze", {
                CF = CFrame.new(ENEMY_SPAWN_POSITION),
                SizeZ = 100
            })
        end
    end)
end

-- Execute match fixing
teleportToObjective()
spawnCamp()
spamUltimates()

-- Expected Result:
-- Attacker can reach objectives before legitimate movement allows
-- Enemies die at spawn before they can engage
-- Ultimates hit constantly instead of once per cooldown
-- Tournament results completely controlled by exploiter
```

**Result:** Complete competitive integrity breakdown.

### Scenario 4: Targeted Harassment

```lua
-- EXPLOIT: Single Player Hunt
-- Uses: VULN-005 (target injection) + VULN-006 (no cooldown)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RemoteEvent = ReplicatedStorage.Remotes.ClientInfo

local TARGET_NAME = "VictimPlayerName"  -- Specific player to harass

spawn(function()
    while wait(0.2) do
        local target = Players:FindFirstChild(TARGET_NAME)
        if target and target.Character then
            -- Continuously attack only this player
            RemoteEvent:FireServer("Inferior", target.Character, {})

            -- Also use Entry for additional damage
            local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                RemoteEvent:FireServer("Entry", {
                    ClientCF = rootPart.CFrame
                })
            end
        end
    end
end)

-- Expected Result:
-- Target player dies immediately after spawning
-- Cannot participate in gameplay at all
-- Other players unaffected (targeted harassment)
-- Victim forced to leave server
```

**Result:** Specific player unable to play, forced to leave.

---

## Conclusion

This codebase has **fundamental security architecture issues** that make it highly vulnerable to exploitation. The core problem is the client-authoritative design pattern where the server trusts client-provided data for critical game logic.

**Key Issues Summary:**

1. Server trusts client-provided positions (CFrame)
2. Server trusts client-provided hitbox sizes
3. Server trusts client-provided target selections
4. Server trusts client-provided enemy detection lists
5. No server-side cooldown enforcement
6. No rate limiting on remote events
7. No distance validation for attacks

Without addressing these architectural issues, the game is trivially exploitable and unsuitable for any competitive or public play.

---

**Report Prepared By:** Security Audit System
**Classification:** Developer Use Only
**Version:** 1.0

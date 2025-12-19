# Security Vulnerability Index

This directory contains detailed security vulnerability documentation for the Roblox game codebase.

## Vulnerability Summary

| ID | Name | Severity | Status | Folder |
|----|------|----------|--------|--------|
| V01 | Arbitrary Teleportation | **CRITICAL** | Confirmed | [V01_Arbitrary_Teleportation](./V01_Arbitrary_Teleportation/) |
| V02 | CFrame Injection | **CRITICAL** | Confirmed | [V02_CFrame_Injection](./V02_CFrame_Injection/) |
| V03 | Client Hitbox Positioning | **CRITICAL** | Confirmed | [V03_Client_Hitbox_Positioning](./V03_Client_Hitbox_Positioning/) |
| V04 | Client Enemy Lists | **CRITICAL** | Confirmed | [V04_Client_Enemy_Lists](./V04_Client_Enemy_Lists/) |
| V05 | No Cooldown Validation | **HIGH** | Confirmed | [V05_No_Cooldown_Validation](./V05_No_Cooldown_Validation/) |
| V06 | Infinite BodyVelocity | **HIGH** | Confirmed | [V06_Infinite_BodyVelocity](./V06_Infinite_BodyVelocity/) |
| V07 | Indefinite IFrames | **HIGH** | Confirmed | [V07_Indefinite_IFrames](./V07_Indefinite_IFrames/) |
| V08 | Client Duration Control | **HIGH** | Confirmed | [V08_Client_Duration_Control](./V08_Client_Duration_Control/) |
| V09 | No Range Validation | **HIGH** | Confirmed | [V09_No_Range_Validation](./V09_No_Range_Validation/) |
| V10 | Client Hitbox Size | **MEDIUM** | Confirmed | [V10_Client_Hitbox_Size](./V10_Client_Hitbox_Size/) |
| V11 | Missing LOS Checks | **MEDIUM** | Confirmed | [V11_Missing_LOS_Checks](./V11_Missing_LOS_Checks/) |
| V12 | Weak Player Verification | **MEDIUM** | Confirmed | [V12_Weak_Player_Verification](./V12_Weak_Player_Verification/) |
| V13 | Client-Controlled Health Restoration | **CRITICAL** | Confirmed | [V13_Client_Health_Restoration](./V13_Client_Health_Restoration/) |
| V14 | Indefinite Status Stacking | **HIGH** | Confirmed | [V14_Indefinite_Status_Stacking](./V14_Indefinite_Status_Stacking/) |
| V15 | Client Animation Speed Control | **MEDIUM** | Confirmed | [V15_Animation_Speed_Control](./V15_Animation_Speed_Control/) |
| V16 | Death Effect Bypass | **HIGH** | Confirmed | [V16_Death_Effect_Bypass](./V16_Death_Effect_Bypass/) |
| V17 | Physics Constraint Race Condition | **MEDIUM** | Confirmed | [V17_Physics_Race_Condition](./V17_Physics_Race_Condition/) |
| V20 | No Skill Ownership Verification | **HIGH** | Confirmed | [V20_No_Skill_Ownership](./V20_No_Skill_Ownership/) |
| V21 | Raycast Filter Bypass | **MEDIUM** | Confirmed | [V21_Raycast_Filter_Bypass](./V21_Raycast_Filter_Bypass/) |
| V22 | Tween-Based Movement Exploitation | **MEDIUM** | Confirmed | [V22_Tween_Movement_Exploit](./V22_Tween_Movement_Exploit/) |
| V23 | Client-Dictated Ability Branching | **HIGH** | Confirmed | [V23_Ability_Branching](./V23_Ability_Branching/) |
| V24 | Remote-Triggered Instance Spam | **HIGH** | Confirmed | [V24_Remote_Instance_Spam](./V24_Remote_Instance_Spam/) |
| V25 | Client-Controlled Size Parameters | **HIGH** | Confirmed | [V25_Client_Size_Parameters](./V25_Client_Size_Parameters/) |
| V26 | Ultimate Meter Drain Bypass | **MEDIUM** | Confirmed | [V26_Ultimate_Meter_Bypass](./V26_Ultimate_Meter_Bypass/) |
| V27 | Animation-Marker Hijacking | **HIGH** | Confirmed | [V27_Animation_Marker_Hijack](./V27_Animation_Marker_Hijack/) |
| V28 | Raycast Distance Spoofing | **HIGH** | Confirmed | [V28_Raycast_Distance_Spoof](./V28_Raycast_Distance_Spoof/) |
| V29 | Client Victim Injection | **CRITICAL** | Confirmed | [V29_Client_Victim_Injection](./V29_Client_Victim_Injection/) |

## Removed Vulnerabilities (Not Exploitable)

| ID | Name | Reason Removed |
|----|------|----------------|
| ~~V18~~ | ~~Unclamped Knockback Values~~ | Knockback values are hardcoded server-side, not from client args |
| ~~V19~~ | ~~Client VFX Position = Hit Detection~~ | Server recalculates positions with own raycast AND does distance checks |

## Severity Breakdown

- **CRITICAL**: 6 vulnerabilities (V01, V02, V03, V04, V13, V29)
- **HIGH**: 12 vulnerabilities (V05, V06, V07, V08, V09, V14, V16, V20, V23, V24, V25, V27, V28)
- **MEDIUM**: 9 vulnerabilities (V10, V11, V12, V15, V17, V21, V22, V26)

**Total: 27 confirmed vulnerabilities**

## Folder Structure

Each vulnerability folder contains:

```
VXX_Vulnerability_Name/
├── README.md          # Full vulnerability documentation
├── poc.luau           # Proof of concept exploit code
└── affected_files.txt # List of affected files with line numbers
```

## PoC-Tested Vulnerabilities

These have been verified working in-game via `LunaritySecurityPoC.lua`:

**IMPORTANT: Server listeners only exist during skill execution!**
The PoC uses a namecall hook to intercept legitimate skill usage and inject malicious data.
Usage: Enable hook → Select target → Use skill normally → Hook injects exploit data

| ID | Exploit | Notes |
|----|---------|-------|
| **V04** | enemiesDetected Injection | PinpointShuriken has 500 stud range check - BEST |
| **V10** | SizeZ Hitbox Extension | DIRECTIONAL only - must aim at target |
| **V03** | Position Injection | Bind, Chilling Arc, Fiery Leap, Concept, Snow Cloak |
| **V13** | Health Restoration | BladeStorm, SuperSiphon, RapidBlinks - `Health += arg3` |
| **V29** | Client Victim Injection | Rise, Inferior, Anguish, Skewer, BodySlam, Siphon, AerialSmite |

## Quick Reference

### Critical Vulnerabilities (Immediate Action Required)

1. **V01 - Arbitrary Teleportation**: Server accepts `TeleportPosition` from client without validation
2. **V02 - CFrame Injection**: Server accepts raw `ClientCF` CFrame data for player/hitbox positioning
3. **V03 - Client Hitbox Positioning**: Damage hitboxes positioned using client-provided coordinates
4. **V04 - Client Enemy Lists**: Server trusts `enemiesDetected` list from client (PinpointShuriken: 500 studs!)
5. **V13 - Client-Controlled Health Restoration**: Siphon/lifesteal healing amounts controlled by client `arg3` parameter
6. **V29 - Client Victim Injection**: Client sends victim character directly; server damages/stuns them (Rise, Inferior, Anguish, Skewer)

### High Severity Vulnerabilities

7. **V05 - No Cooldown Validation**: Cooldowns only enforced client-side, server doesn't track
7. **V06 - Infinite BodyVelocity**: Using `math.huge` for MaxForce enables physics exploits
8. **V07 - Indefinite IFrames**: `applyStatus(player, "IFrames")` without duration = permanent invincibility
9. **V08 - Client Duration Control**: Status effect durations controlled by client `arg4` parameter
10. **V09 - No Range Validation**: No distance checks on teleports/positions
11. **V14 - Indefinite Status Stacking**: Multiple status effects stack without limits or expiration
12. **V16 - Death Effect Bypass**: Client can add fake attributes to prevent death effects
13. **V20 - No Skill Ownership Verification**: Any skill can be invoked regardless of weapon ownership
14. **V23 - Client-Dictated Ability Branching**: Client chooses skill phase/branch without validation
15. **V24 - Remote-Triggered Instance Spam**: Unthrottled remote calls enable DoS attacks
16. **V25 - Client-Controlled Size Parameters**: Hitbox sizes calculated and sent by client
17. **V27 - Animation-Marker Hijacking**: Instant damage by fast-forwarding to animation markers
18. **V28 - Raycast Distance Spoofing**: Using extreme raycast distances to hit through geometry

### Medium Severity Vulnerabilities

19. **V10 - Client Hitbox Size**: Client controls hitbox Z-dimension via `arg3.SizeZ` (DIRECTIONAL - must aim!)
20. **V11 - Missing LOS Checks**: `findEnemiesPart`/`findEnemiesMagnitude` don't verify line of sight
21. **V12 - Weak Player Verification**: Only checks player identity, not skill ownership or valid state
22. **V15 - Client Animation Speed Control**: Animation speed manipulation affects damage timing
23. **V17 - Physics Constraint Race Condition**: Inject physics objects that survive cleanup loops
24. **V21 - Raycast Filter Bypass**: Manipulate raycastParams to hit through walls
25. **V22 - Tween-Based Movement Exploitation**: Modify tween targets for arbitrary positioning
26. **V26 - Ultimate Meter Drain Bypass**: Suppress meter drain signals to extend ultimate duration

## Root Cause

All vulnerabilities stem from the same architectural flaw:

```lua
-- Server blindly trusts client data
ReplicatedStorage.Remotes.ClientInfo.OnServerEvent:Connect(function(player, skillName, arg3, arg4)
    -- arg3 and arg4 come directly from client with no validation
    HumanoidRootPart.CFrame = arg3.TeleportPosition  -- VULNERABLE
    Humanoid.Health += arg3.HealAmount               -- VULNERABLE
    hitbox.Size = arg3.SizeZ                         -- VULNERABLE
end)
```

## Vulnerability Categories

### Input Validation (10)
V01, V02, V03, V04, V09, V10, V13, V25, V28

### State Management (6)
V07, V08, V14, V16, V23, V26, V27

### Authorization/Access Control (3)
V05, V12, V20

### Race Conditions (3)
V06, V17, V24

### Information Disclosure (4)
V11, V15, V21, V22

## Remediation Priority

1. **Immediate**: V01, V02, V03, V04, V13 (game-breaking exploits)
2. **Short-term**: V05, V06, V07, V08, V09, V14, V16, V20, V23, V24, V25, V27, V28 (significant advantages)
3. **Medium-term**: V10, V11, V12, V15, V17, V21, V22, V26 (quality of life exploits)

## Files Analyzed

- Total files in codebase: 170+ `.luau` files
- Files with vulnerabilities: 100+ files (most skill modules affected)
- Primary vulnerable pattern: `ClientInfo.OnServerEvent` handlers
- Secondary patterns: Animation markers, Raycast results, Physics constraints

## Key Remote Endpoints

| Remote | Purpose | Vulnerabilities |
|--------|---------|-----------------|
| `Remotes.ClientInfo` | Main skill communication | V01-V04, V13, V23, V25 |
| Animation Markers | Damage timing | V15, V27 |
| TweenService | Movement | V22 |
| BodyVelocity/Position | Physics | V06, V17 |

## Recommended Security Architecture

```lua
-- 1. Server-side validation for all client inputs
local function validateSkillData(player, skillName, data)
    -- Check skill ownership
    if not playerOwnsSkill(player, skillName) then return false end

    -- Validate positions are within range
    if data.TeleportPosition then
        local distance = (data.TeleportPosition - player.Character.HumanoidRootPart.Position).Magnitude
        if distance > MAX_SKILL_RANGE then return false end
    end

    -- Clamp values
    if data.HealAmount then
        data.HealAmount = math.clamp(data.HealAmount, 0, MAX_HEAL)
    end

    return true
end

-- 2. Server-side calculations for critical values
local function calculateDamage(attacker, skill)
    -- Don't trust client damage values
    return SKILL_DAMAGES[skill.Name] * attacker:GetAttribute("DamageMultiplier")
end

-- 3. Rate limiting on all remotes
local lastSkillTime = {}
local function canUseSkill(player, skillName)
    local cooldown = SKILL_COOLDOWNS[skillName]
    local lastUse = lastSkillTime[player.UserId .. skillName] or 0
    return tick() - lastUse >= cooldown
end
```

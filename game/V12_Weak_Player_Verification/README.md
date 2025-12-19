# V12: Weak Player Verification

## Severity: MEDIUM

## Description

Skill modules only verify that the player firing the remote event matches the expected player (`arg1_2 == arg2` or `arg1_3 ~= arg2`), but do not perform comprehensive validation of:
- Skill ownership (does the player have this skill?)
- Valid player state (is the player alive, not stunned, etc.?)
- Skill prerequisites (required weapon equipped, enough resources, etc.)
- Skill availability (not on cooldown from server perspective)

## Vulnerability Details

The verification pattern used across all skill modules is:

```lua
if arg2_2 ~= "SkillName" or arg1_3 ~= arg2 then
    -- Do nothing
else
    -- Execute skill logic
end
```

This only checks:
1. The skill name matches what was expected
2. The player who fired the remote is the same player the skill was initiated for

### What's Missing

- No verification that player owns/has access to this skill
- No check if player is in valid state to use skills
- No server-side cooldown enforcement
- No resource/energy cost verification
- No weapon/class requirements check

## Affected Files

All skill modules use this weak verification pattern:

| File | Line | Verification Pattern |
|------|------|---------------------|
| `QuickBreezeModule_ID178.luau` | 70 | `if arg2_2 ~= "Quick Breeze" or arg1_3 ~= arg2` |
| `AgressiveBreezeModule_ID171.luau` | 72 | `if arg2_2 ~= "Agressive Breeze" or arg1_3 ~= arg2` |
| `SiphonModule_ID107.luau` | 195 | `if arg2_2 ~= "Siphon" or arg1_3 ~= arg2` |
| `SuperSiphonModule_ID101.luau` | 160 | `if arg1_3 ~= arg2 or arg2_3 ~= "Super Siphon"` |
| `BreakModule_ID51.luau` | 75 | `if arg1_3 ~= arg2 or arg2_2 ~= "Break"` |
| `CrippleModule_ID57.luau` | 74 | `if arg1_3 ~= arg2 or arg2_2 ~= "Cripple"` |
| `RapidIceModule_ID73.luau` | 77 | `if arg2_2 ~= "RapidIce" or arg1_3 ~= arg2` |
| `AnguishModule_ID116.luau` | - | Similar pattern |
| `BodySlamModule_ID160.luau` | 70 | `if arg2_2 ~= "BodySlam" or arg1_2 ~= arg2` |

## Vulnerable Code Examples

### Example 1: QuickBreezeModule_ID178.luau (Lines 60-71)
```lua
-- Line 60-71
var16_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2, arg3)
    -- Upvalues: [1]: arg2 (readonly) - the player who initiated skill
    --           ...

    if arg2_2 ~= "Quick Breeze" or arg1_3 ~= arg2 then
        -- WEAK: Only checks player identity and skill name
        -- Does NOT check:
        --   - Does player own "Quick Breeze" skill?
        --   - Is player alive?
        --   - Is player stunned/frozen?
        --   - Does player have required weapon?
        --   - Is skill off cooldown (server-side)?
    else
        var16_upvw:Disconnect()
        -- ... execute skill
    end
end)
```

### Example 2: SiphonModule_ID107.luau (Lines 179-198)
```lua
-- Line 179-198
var53_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2, arg3)
    -- ...
    if arg2_2 ~= "Siphon" or arg1_3 ~= arg2 then
        -- Only verifies: skill name matches AND player matches
        -- Missing: skill ownership, player state, cooldown
    else
        var53_upvw:Disconnect()
        HumanoidRootPart_upvr.CFrame = arg3  -- Immediately trusts client data
        -- ...
    end
end)
```

### Example 3: BreakModule_ID51.luau (Lines 74-77)
```lua
-- Line 74-78
if arg1_3 ~= arg2 or arg2_2 ~= "Break" then
    -- Weak verification - same pattern
else
    var9_upvw = true
    any_LoadAnimation_result1_upvr:AdjustSpeed(1)
    -- Skill proceeds without proper validation
end
```

### Example 4: BodySlamModule_ID160.luau (Lines 70-74)
```lua
-- Line 69-74
if arg2_2 ~= "BodySlam" or arg1_2 ~= arg2 or not var15_upvw then
    -- Added check: `not var15_upvw` (connection exists)
    -- Still missing comprehensive state validation
else
    var15_upvw:Disconnect()
    if arg3 then
        HumanoidRootPart_upvr.CFrame = arg3  -- Trusts client immediately
    end
    -- ...
end
```

## Exploitation Scenarios

### Scenario 1: Using Skills Without Owning Them
```lua
-- Exploit: Use a skill the player hasn't unlocked
-- The server only checks if player ID matches, not skill ownership

local RemoteEvent = game.ReplicatedStorage.Remotes.ClientInfo

-- Fire event for a skill the player may not have unlocked
RemoteEvent:FireServer("Super Siphon", {
    -- payload data
})
```

### Scenario 2: Using Skills While Dead/Stunned
```lua
-- Exploit: Execute skill while in invalid state
-- Server doesn't verify player health or status effects

-- Even if player is stunned/frozen, the remote still processes
RemoteEvent:FireServer("Quick Breeze", {
    CF = targetCFrame,
    SizeZ = 100
})
```

### Scenario 3: Bypassing Resource Costs
```lua
-- If skills have resource costs (stamina, mana, etc.)
-- Server doesn't verify sufficient resources before execution
RemoteEvent:FireServer("ExpensiveSkill", {})
-- Skill executes without consuming resources
```

## Impact

- **Skill Access Bypass**: Use skills that haven't been unlocked or purchased
- **State Bypass**: Execute skills while dead, stunned, or frozen
- **Resource Bypass**: Use skills without required resources
- **Class Bypass**: Use skills from other classes/weapons
- **Cooldown Bypass**: Combined with V05, use skills at any time
- **Premium Bypass**: Use premium/paid skills without purchasing

## Remediation

### 1. Comprehensive Player State Validation
```lua
function validatePlayerState(player, character)
    -- Check if player is alive
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false, "Player is dead"
    end

    -- Check if player is stunned/frozen
    local statusFolder = character:FindFirstChild("StatusEffects")
    if statusFolder then
        if statusFolder:FindFirstChild("Stunned") then
            return false, "Player is stunned"
        end
        if statusFolder:FindFirstChild("Frozen") then
            return false, "Player is frozen"
        end
    end

    return true, "Valid"
end
```

### 2. Skill Ownership Verification
```lua
function playerOwnsSkill(player, skillName)
    -- Check player's unlocked skills
    local playerData = getPlayerData(player)
    if not playerData then return false end

    return table.find(playerData.UnlockedSkills, skillName) ~= nil
end

-- In skill module:
if not playerOwnsSkill(arg2, "Quick Breeze") then
    warn("Player", arg2.Name, "attempted to use unowned skill")
    return
end
```

### 3. Server-Side Cooldown Tracking
```lua
local skillCooldowns = {}

function isSkillOnCooldown(player, skillName)
    local key = player.UserId .. "_" .. skillName
    local now = tick()

    if skillCooldowns[key] and now < skillCooldowns[key] then
        return true, skillCooldowns[key] - now
    end
    return false, 0
end

function setSkillCooldown(player, skillName, duration)
    local key = player.UserId .. "_" .. skillName
    skillCooldowns[key] = tick() + duration
end
```

### 4. Weapon/Class Requirements
```lua
function hasRequiredWeapon(character, requiredWeapon)
    return character:FindFirstChild(requiredWeapon) ~= nil
end

-- In skill module:
if not hasRequiredWeapon(arg1, "Firework Rapier") then
    warn("Player missing required weapon for skill")
    return
end
```

### 5. Comprehensive Validation Wrapper
```lua
function validateSkillExecution(player, character, skillName, skillData)
    -- Player identity (existing check)
    -- Already done by arg1_3 == arg2

    -- Player state
    local stateValid, stateMsg = validatePlayerState(player, character)
    if not stateValid then
        return false, stateMsg
    end

    -- Skill ownership
    if not playerOwnsSkill(player, skillName) then
        return false, "Skill not owned"
    end

    -- Cooldown check
    local onCD, remaining = isSkillOnCooldown(player, skillName)
    if onCD then
        return false, "Skill on cooldown: " .. remaining .. "s"
    end

    -- Weapon requirement
    if skillData.RequiredWeapon then
        if not hasRequiredWeapon(character, skillData.RequiredWeapon) then
            return false, "Required weapon not equipped"
        end
    end

    -- Resource check
    if skillData.ResourceCost then
        if not hasResources(player, skillData.ResourceCost) then
            return false, "Insufficient resources"
        end
    end

    return true, "Valid"
end
```

## References

- Related to V05 (No Cooldown Validation) - weak verification enables cooldown bypass
- [Roblox Remote Event Security](https://create.roblox.com/docs/scripting/security/security-best-practices)
- [OWASP Authentication Best Practices](https://owasp.org/www-project-web-security-testing-guide/)

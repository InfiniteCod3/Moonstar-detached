# V20 - No Skill Ownership Verification

## Severity: HIGH

## Summary
Skill modules execute without verifying that the player actually owns or has equipped the corresponding weapon/skill. Attackers can potentially invoke any skill's server handler regardless of what they've unlocked.

## Vulnerability Details

### Root Cause
The skill `module_upvr.Script(arg1, arg2)` function only receives the character model and argument data. No verification checks if the player owns the skill, has it equipped, or meets requirements to use it.

### Affected Code Pattern
```lua
-- Every skill module follows this pattern:
function module_upvr.Script(arg1, arg2)
    var3_upvw = require(arg1.ServerScript.Skills)
    -- Immediately begins executing skill logic
    -- NO CHECK for:
    -- - Does player own this weapon?
    -- - Is this skill unlocked?
    -- - Is the weapon equipped?
    -- - Does player meet level requirements?
    local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
    -- ... skill execution continues ...
end
```

### Attack Vector
1. Find the skill name/identifier for any skill
2. Fire the ClientInfo remote with that skill name
3. Server looks up and executes the skill module
4. No ownership check = skill executes
5. Use ultimate abilities without owning them

## Impact
- Access to all skills regardless of progression
- Use paid/premium skills without purchasing
- Access to abilities from other weapon classes
- Complete gameplay progression bypass

## Affected Files
| File | Pattern |
|------|---------|
| All *Module_ID*.luau files | module_upvr.Script(arg1, arg2) with no ownership check |
| BladeStormModule_ID98.luau | No check for Cyber Katana ownership |
| ConsumeModule_ID118.luau | No check for Soul Lantern ownership |
| All Ultimate_ID*.luau files | No check for ultimate unlock |

## Proof of Concept
See `poc.luau` in this folder.

## Remediation
```lua
function module_upvr.Script(arg1, arg2)
    var3_upvw = require(arg1.ServerScript.Skills)

    -- ADD: Verify skill ownership
    local player = game.Players:GetPlayerFromCharacter(arg1)
    if not player then return end

    -- Check if player owns this weapon
    local ownedWeapons = player:GetAttribute("OwnedWeapons") or {}
    if not table.find(ownedWeapons, "Cyber Katana") then
        warn("Player attempted to use unowned skill")
        return
    end

    -- Check if weapon is equipped
    local equippedWeapon = arg1:FindFirstChild("EquippedWeapon")
    if not equippedWeapon or equippedWeapon.Value ~= "Cyber Katana" then
        return
    end

    -- Check if skill is unlocked
    local unlockedSkills = player:GetAttribute("UnlockedSkills") or {}
    if not table.find(unlockedSkills, "BladeStorm") then
        return
    end

    -- NOW proceed with skill execution
    local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
    -- ...
end
```

## References
- CWE-862: Missing Authorization
- OWASP: Broken Access Control

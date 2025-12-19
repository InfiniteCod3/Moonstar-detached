# V05: No Cooldown Validation

## Severity: HIGH

## Summary

Skill cooldowns are defined client-side in module scripts (`module_upvr.Cooldown`) but are not validated server-side. This allows malicious clients to spam skill remotes without respecting cooldown timers, enabling rapid-fire attacks and ability abuse.

## Technical Details

### Vulnerability Pattern

Each skill module defines a cooldown value at the module level:

```lua
-- BladeStormModule_ID98.luau, Line 11
module_upvr.Cooldown = 19

-- BlinkStrikeModule_ID106.luau, Line 11
module_upvr.Cooldown = 30

-- RiseModule_ID84.luau, Line 11
module_upvr.Cooldown = 18
```

However, these values are only used client-side for UI/feedback purposes. The server does not track or enforce when a skill was last used. When the skill remote is fired, the server processes it immediately without checking:

1. Whether the player has used this skill recently
2. Whether the cooldown period has elapsed
3. Whether the player is spamming the remote

### Affected Code Examples

**BladeStormModule_ID98.luau (Lines 9-27):**
```lua
     9  local module_upvr = {}
    10  local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
    11  module_upvr.Cooldown = 19
    12  module_upvr.GlobalCD = 0.1
    13  local var3_upvw
    14  local TweenService_upvr = game:GetService("TweenService")
    15  local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
    16  function module_upvr.Script(arg1, arg2) -- Line 17
    ...
    25      local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
    26      Folder_upvr.Name = arg1.Name
    27      game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
```

**BlinkStrikeModule_ID106.luau (Lines 9-25):**
```lua
     9  local module_upvr = {}
    10  local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
    11  module_upvr.Cooldown = 30
    12  module_upvr.GlobalCD = 0.1
    13  local var3_upvw
    14  local TweenService_upvr = game:GetService("TweenService")
    15  function module_upvr.Script(arg1, arg2) -- Line 16
    ...
    23      local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
    24      Folder_upvr.Name = arg1.Name
    25      game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
```

## Attack Vector

1. Attacker identifies the skill remote event
2. Creates a script that fires the remote repeatedly
3. Server processes each request without cooldown validation
4. Attacker can spam ultimate abilities continuously

## Impact

- **Ability Spam**: Ultimate abilities can be used every frame instead of every 15-30 seconds
- **Combat Imbalance**: Attackers gain massive advantage by using powerful abilities continuously
- **Server Performance**: Rapid skill spam creates excessive VFX, sounds, and physics objects
- **Game Economy**: If skills provide resources, this enables infinite resource generation

## Remediation

### Server-Side Cooldown Tracking

```lua
-- Server-side cooldown manager
local CooldownManager = {}
local playerCooldowns = {}

function CooldownManager.canUseSkill(player, skillId, cooldownTime)
    local userId = player.UserId
    if not playerCooldowns[userId] then
        playerCooldowns[userId] = {}
    end

    local lastUsed = playerCooldowns[userId][skillId] or 0
    local currentTime = tick()

    if currentTime - lastUsed < cooldownTime then
        return false, cooldownTime - (currentTime - lastUsed)
    end

    playerCooldowns[userId][skillId] = currentTime
    return true
end

-- In skill module
function module_upvr.Script(arg1, arg2)
    local player = game.Players:GetPlayerFromCharacter(arg1)
    if not CooldownManager.canUseSkill(player, "BladeStorm", 19) then
        return -- Reject the skill use
    end
    -- Continue with skill execution
end
```

## References

- CWE-799: Improper Control of Interaction Frequency
- OWASP: Rate Limiting

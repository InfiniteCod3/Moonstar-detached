# V23 - Client-Dictated Ability Branching

## Severity: HIGH

## Summary
In multi-phase skill combos, the client decides which "branch" or "phase" to execute by sending specific strings/data to the server. The server processes these without verifying the player is actually in the correct phase of the combo.

## Vulnerability Details

### Root Cause
Skills with multiple phases (like combos) rely on client-sent signals to transition between states. The server doesn't track the player's current combo state server-side.

### Affected Code Pattern
```lua
-- Client_ID117.luau - Anguish skill
ReplicatedStorage_upvr.Remotes.ClientInfo.OnClientEvent:Connect(function(actionName, data)
    if actionName == "Anguish" then
        -- Client executes local logic and fires back to server
        -- Server trusts that client is in correct phase
    end
end)

-- Client can spoof being in any phase
ClientInfo:FireServer("AnguishStop")  -- Skip to end phase
ClientInfo:FireServer("Anguish", enemyData)  -- Fake hit confirmation
```

### Attack Vector
1. Monitor skill phase transitions
2. Send phase completion signals out of order
3. Skip charging/windup phases entirely
4. Trigger damage phases without meeting conditions
5. Break combos prematurely to avoid punish windows

## Impact
- Skip skill charge times
- Trigger damage without completing animations
- Break out of combo lock states
- Access skill phases without prerequisites

## Affected Files
| File | Line | Pattern |
|------|------|---------|
| Client_ID117.luau | 98-120 | Anguish phase handling |
| Multiple combo skills | Various | Phase-based FireServer calls |

## Proof of Concept
See `poc.luau` in this folder.

## Remediation
```lua
-- Server-side: Track combo state
local playerComboState = {}

local function handleSkillPhase(player, skillName, phase, data)
    local state = playerComboState[player.UserId]

    -- Verify correct phase transition
    if phase == "phase2" and state.currentPhase ~= "phase1" then
        warn("Invalid phase transition from", player.Name)
        return
    end

    -- Update state and process
    state.currentPhase = phase
    processPhase(player, skillName, phase, data)
end
```

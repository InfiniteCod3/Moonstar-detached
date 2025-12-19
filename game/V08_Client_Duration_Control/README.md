# V08: Client Duration Control

## Severity: HIGH

## Summary

In `RiseModule_ID84.luau`, status effect durations are controlled by the client-supplied `arg4` parameter from the `ClientInfo.OnServerEvent` remote. This allows malicious clients to send arbitrary duration values, enabling extended or permanent status effects including invincibility (IFrames), stuns, and freezes.

## Technical Details

### Vulnerability Pattern

The server receives an `arg4` parameter from the client via a remote event, and uses this value directly to set status effect durations:

```lua
-- RiseModule_ID84.luau, Lines 56-85
var20_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(
    function(arg1_2, arg2_2, arg3, arg4)  -- arg4 is client-controlled!
        -- ...
        var3_upvw.applyStatus(arg1, "Freeze", arg4 + 1)      -- Line 81
        var3_upvw.applyStatus(arg1, "GlobalCD", arg4 + 1)    -- Line 82
        var3_upvw.applyStatus(arg1, "IFrames", arg4 + 1)     -- Line 83
        var3_upvw.applyStatus(arg3, "Stunned", arg4 + 1)     -- Line 84
        var3_upvw.applyStatus(arg3, "IFrames", arg4 + 1)     -- Line 85
```

The client can send any value for `arg4`, including:
- `math.huge` (infinity) for permanent effects
- Extremely large numbers like `999999999`
- Negative numbers that may cause unexpected behavior

### Affected Code - RiseModule_ID84.luau

**Remote Event Handler (Lines 56-70):**
```lua
    56  var20_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(
    57      function(arg1_2, arg2_2, arg3, arg4) -- Line 64
    58          --[[ Upvalues[11]:
    59              [1]: var20_upvw (read and write)
    60              [2]: PlayerStatus_upvr (copied, readonly)
    61              [3]: var3_upvw (copied, read and write)
    62              [4]: arg1 (readonly)
    63              [5]: Rise_upvr (readonly)
    64              [6]: HumanoidRootPart_upvr (readonly)
    65              [7]: any_LoadAnimation_result1_4_upvr (readonly)
    66              [8]: Humanoid_upvr (readonly)
    67              [9]: Folder_upvr (readonly)
    68              [10]: TweenService_upvr (copied, readonly)
    69              [11]: module_upvr (copied, readonly)
    70          ]]
```

**Status Application with Client-Controlled Duration (Lines 81-85):**
```lua
    81  var3_upvw.applyStatus(arg1, "Freeze", arg4 + 1)    -- arg4 from client!
    82  var3_upvw.applyStatus(arg1, "GlobalCD", arg4 + 1)  -- arg4 from client!
    83  var3_upvw.applyStatus(arg1, "IFrames", arg4 + 1)   -- arg4 from client!
    84  var3_upvw.applyStatus(arg3, "Stunned", arg4 + 1)   -- arg4 from client!
    85  var3_upvw.applyStatus(arg3, "IFrames", arg4 + 1)   -- arg4 from client!
```

**Also used later (Line 91):**
```lua
    91  task.wait(arg4 + 0.25)  -- Client controls server wait time!
```

## Attack Vector

1. Attacker identifies the `ClientInfo` remote event
2. Attacker fires the remote with a malicious `arg4` value:
   - `math.huge` for permanent effects
   - `999999999` for effectively permanent effects
   - Large values to extend skill duration
3. Server applies status effects using the client-supplied duration
4. Attacker gains extended/permanent IFrames (invincibility) or can permastun enemies

## Impact

### Self-Exploitation (Positive Effects)
- **Permanent IFrames**: `arg4 = math.huge` gives permanent invincibility
- **Extended Skill Duration**: Skill effects last indefinitely
- **Freeze Bypass**: Can control when freeze effect ends

### Victim Exploitation (Negative Effects)
- **Permanent Stun**: Enemy (`arg3`) can be stunned permanently
- **IFrames on Enemy**: Could be used to make enemies invulnerable (griefing)
- **Combat Lockout**: Victims cannot act, move, or defend

### Server Impact
- **Wait Manipulation**: `task.wait(arg4 + 0.25)` can block server threads
- **Resource Exhaustion**: Extended status effects consume server resources
- **Game State Corruption**: Permanent effects break expected game flow

## Remediation

### Validate and Clamp Duration Values

```lua
-- Define maximum allowed durations
local MAX_DURATIONS = {
    IFrames = 5.0,
    Freeze = 10.0,
    GlobalCD = 10.0,
    Stunned = 10.0
}

-- Validate client-supplied duration
local function validateDuration(statusName, clientDuration)
    -- Check for invalid values
    if type(clientDuration) ~= "number" then
        return 1.0  -- Default duration
    end

    if clientDuration ~= clientDuration then  -- NaN check
        return 1.0
    end

    if clientDuration == math.huge or clientDuration == -math.huge then
        warn("Exploit attempt: infinite duration detected")
        return 1.0
    end

    -- Clamp to maximum
    local maxDuration = MAX_DURATIONS[statusName] or 5.0
    return math.clamp(clientDuration, 0, maxDuration)
end

-- Usage in skill code
local safeDuration = validateDuration("IFrames", arg4)
var3_upvw.applyStatus(arg1, "IFrames", safeDuration + 1)
```

### Server-Side Duration Determination

```lua
-- Don't trust client for duration - calculate server-side
local function getSkillDuration(skillName, chargeLevel)
    local baseDurations = {
        Rise = {
            base = 1.0,
            maxCharge = 3.0
        }
    }

    local skill = baseDurations[skillName]
    if not skill then return 1.0 end

    -- Calculate based on charge level (0-1 range)
    chargeLevel = math.clamp(chargeLevel or 0, 0, 1)
    return skill.base + (skill.maxCharge - skill.base) * chargeLevel
end

-- Server determines duration, not client
local duration = getSkillDuration("Rise", chargeLevel)
var3_upvw.applyStatus(arg1, "IFrames", duration)
```

### Input Validation Wrapper

```lua
-- Wrap remote event handler with validation
ReplicatedStorage.Remotes.ClientInfo.OnServerEvent:Connect(function(player, arg2, arg3, arg4)
    -- Validate arg4 is a reasonable number
    if type(arg4) ~= "number" or
       arg4 ~= arg4 or  -- NaN
       arg4 < 0 or
       arg4 > 10 or
       arg4 == math.huge then

        warn("Invalid duration from " .. player.Name .. ": " .. tostring(arg4))
        arg4 = 1.0  -- Use safe default
    end

    -- Continue with validated arg4
    processSkill(player, arg2, arg3, arg4)
end)
```

## References

- CWE-20: Improper Input Validation
- CWE-1284: Improper Validation of Specified Quantity in Input
- OWASP: Input Validation Cheat Sheet

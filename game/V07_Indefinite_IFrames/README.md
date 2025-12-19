# V07: Indefinite IFrames (Invincibility Frames)

## Severity: HIGH

## Summary

Multiple skill modules call `applyStatus(arg1, "IFrames")` without providing a duration parameter. This creates invincibility frames (IFrames) that may persist indefinitely if the cleanup mechanism fails or is bypassed, allowing players to become permanently invulnerable to damage.

## Technical Details

### Vulnerability Pattern

The `applyStatus` function is called with only two parameters when applying IFrames:

```lua
var3_upvw.applyStatus(arg1, "IFrames")  -- No duration parameter!
```

Compare this to the proper usage with a duration:

```lua
var3_upvw.applyStatus(arg1, "IFrames", 1.9)  -- Duration of 1.9 seconds
```

When no duration is specified, the status effect relies on external cleanup mechanisms (like `applyDebris` calls or manual removal). If these cleanup mechanisms fail, are interrupted, or can be bypassed, the IFrames persist indefinitely.

### Affected Code Examples

**BladeStormModule_ID98.luau (Lines 121-127):**
```lua
   121  if not arg1.Head:FindFirstChild("LockBV") then
   122      local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
   123      BodyVelocity.Name = "LockBV"
   124      BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   125      BodyVelocity.Velocity = Vector3.new(0, 0, 0)
   126      table.insert(tbl_upvr_2, var3_upvw.applyStatus(arg1, "IFrames"))  -- NO DURATION
   127  end
```

**BladeStormModule_ID98.luau (Line 201):**
```lua
   199  table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "GlobalCD"))
   200  table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "Freeze"))
   201  table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames"))  -- NO DURATION
   202  table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "AutoRotate"))
```

**BlinkStrikeModule_ID106.luau (Lines 166-172):**
```lua
   166  if not arg1.Head:FindFirstChild("LockBV") then
   167      local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
   168      BodyVelocity.Name = "LockBV"
   169      BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   170      BodyVelocity.Velocity = Vector3.new(0, 0, 0)
   171      table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames"))  -- NO DURATION
   172  end
```

### Cleanup Mechanism (Can Fail)

The cleanup relies on a counter-based system that can be bypassed:

```lua
-- BladeStormModule_ID98.luau (Lines 135-145)
task.delay(0.3, function()
    var33_upvw -= 1
    if var33_upvw <= 0 then
        for _, v in tbl_upvr_2 do
            var3_upvw.applyDebris(v, 0)  -- Cleanup IFrames
        end
        -- ...
    end
end)
```

If the skill is interrupted, the player disconnects during execution, or the counter logic is exploited, the IFrames may never be cleaned up.

## Attack Vector

1. Player initiates a skill that grants indefinite IFrames
2. Exploit one of the following:
   - Disconnect/reconnect at the right moment to skip cleanup
   - Trigger another skill that interferes with the counter logic
   - Exploit race conditions in the async cleanup code
   - Use a modified client to prevent the cleanup callback from executing
3. IFrames persist indefinitely, granting permanent invincibility

## Impact

- **Permanent Invincibility**: Players become immune to all damage
- **Combat Imbalance**: Invulnerable players dominate PvP encounters
- **Game Breaking**: Core gameplay mechanics (damage, combat) become meaningless
- **Economy Impact**: If survival rewards exist, this enables infinite farming

## Remediation

### Always Specify Duration

```lua
-- BAD: No duration specified
table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames"))

-- GOOD: Explicit duration with maximum cap
local IFRAME_DURATION = 0.3
local MAX_IFRAME_DURATION = 5.0
table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames",
    math.min(IFRAME_DURATION, MAX_IFRAME_DURATION)))
```

### Implement Server-Side Status Manager

```lua
local StatusManager = {}
local playerStatuses = {}
local MAX_STATUS_DURATION = {
    IFrames = 5.0,
    Stunned = 10.0,
    Freeze = 10.0
}

function StatusManager.applyStatus(character, statusName, duration)
    local player = game.Players:GetPlayerFromCharacter(character)
    if not player then return end

    -- Enforce maximum duration
    local maxDuration = MAX_STATUS_DURATION[statusName] or 10.0
    duration = duration or maxDuration  -- Default to max if not specified
    duration = math.min(duration, maxDuration)

    -- Apply the status with guaranteed cleanup
    local statusObject = createStatusObject(character, statusName)

    -- Guaranteed cleanup via Debris service
    game.Debris:AddItem(statusObject, duration)

    -- Backup cleanup timer
    task.delay(duration + 0.1, function()
        if statusObject and statusObject.Parent then
            statusObject:Destroy()
            warn("Backup cleanup triggered for " .. statusName)
        end
    end)

    return statusObject
end
```

### Add Status Validation

```lua
-- Periodic check for invalid status effects
game:GetService("RunService").Heartbeat:Connect(function()
    for _, player in ipairs(game.Players:GetPlayers()) do
        local character = player.Character
        if character then
            -- Check for IFrames that have existed too long
            local iframeStart = character:GetAttribute("IFrameStart")
            if iframeStart and (tick() - iframeStart) > 5.0 then
                -- Force remove IFrames
                removeStatus(character, "IFrames")
                warn("Force-removed stale IFrames from " .. player.Name)
            end
        end
    end
end)
```

## References

- CWE-672: Operation on a Resource after Expiration or Release
- CWE-362: Concurrent Execution Using Shared Resource with Improper Synchronization

# V06: Infinite BodyVelocity Forces

## Severity: HIGH

## Summary

Multiple skill modules create `BodyVelocity` and `BodyPosition` physics constraints using `math.huge` for the `MaxForce` property. This creates physics objects with theoretically infinite force, which can be exploited to create unstoppable movement, bypass physics limitations, and potentially cause physics engine instability.

## Technical Details

### Vulnerability Pattern

The pattern involves creating physics body movers with infinite force:

```lua
BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
```

When `MaxForce` is set to `math.huge` (infinity), the physics constraint can overcome any other force in the game, including:
- Gravity
- Collision forces
- Other player interactions
- Anti-exploit push forces

### Affected Code Examples

**BladeStormModule_ID98.luau (Lines 122-125):**
```lua
   122  if not arg1.Head:FindFirstChild("LockBV") then
   123      local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
   124      BodyVelocity.Name = "LockBV"
   125      BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   126      BodyVelocity.Velocity = Vector3.new(0, 0, 0)
```

**BladeStormModule_ID98.luau (Lines 247-250):**
```lua
   247  local BodyVelocity_2 = Instance.new("BodyVelocity", v_9.Head)
   248  BodyVelocity_2.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   249  BodyVelocity_2.Velocity = Vector3.new(0, 0, 0)
   250  var3_upvw.applyDebris(BodyVelocity_2, 1.9)
```

**BlinkStrikeModule_ID106.luau (Lines 167-170):**
```lua
   167  local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
   168  BodyVelocity.Name = "LockBV"
   169  BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   170  BodyVelocity.Velocity = Vector3.new(0, 0, 0)
```

**RiseModule_ID84.luau (Lines 129-136):**
```lua
   129  local BodyVelocity_upvr_2 = Instance.new("BodyVelocity", arg3.Torso)
   130  BodyVelocity_upvr_2.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   131  BodyVelocity_upvr_2.Velocity = Vector3.new(0, 0, 0)
   132  var3_upvw.applyDebris(BodyVelocity_upvr_2, 4)
   133  local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Torso)
   134  BodyVelocity_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   135  BodyVelocity_upvr.Velocity = Vector3.new(0, 0, 0)
   136  var3_upvw.applyDebris(BodyVelocity_upvr, 4)
```

## Attack Vector

1. Attacker triggers a skill that creates a BodyVelocity with `math.huge` force
2. If the attacker can control the Velocity property (via client remote), they can move at unlimited speed
3. The infinite force overcomes any server-side position correction
4. Physics-based anti-exploit systems cannot counteract the movement

## Impact

- **Speed Hacking**: Infinite force allows bypassing movement speed limits
- **Position Exploitation**: Can be used to clip through walls or reach unintended areas
- **Combat Advantage**: Impossible to push away or knock back
- **Server Stability**: Extreme physics values can cause performance issues
- **Anti-Exploit Bypass**: Most physics-based anti-cheats cannot handle `math.huge` values

## Remediation

### Use Finite MaxForce Values

Replace `math.huge` with appropriate finite values:

```lua
-- BAD: Infinite force
BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

-- GOOD: Finite force sufficient for gameplay
local MAX_FORCE = 50000 -- Adjust based on gameplay needs
BodyVelocity.MaxForce = Vector3.new(MAX_FORCE, MAX_FORCE, MAX_FORCE)
```

### Calculate Appropriate Force

```lua
-- Calculate force based on character mass and desired acceleration
local function getAppropriateForce(character, desiredAcceleration)
    local mass = 0
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            mass = mass + part:GetMass()
        end
    end
    -- F = ma, with safety margin
    return mass * desiredAcceleration * 1.5
end

local force = getAppropriateForce(character, 100)
BodyVelocity.MaxForce = Vector3.new(force, force, force)
```

### Validate Physics Objects Server-Side

```lua
-- Monitor for suspicious physics objects
local function validatePhysicsObjects(character)
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") then
            local maxForce = obj.MaxForce
            if maxForce.X == math.huge or maxForce.Y == math.huge or maxForce.Z == math.huge then
                warn("Infinite force detected on " .. character.Name)
                obj:Destroy()
            end
        end
    end
end
```

## References

- Roblox Physics Best Practices
- CWE-400: Uncontrolled Resource Consumption

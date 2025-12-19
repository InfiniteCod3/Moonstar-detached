# V11: Missing Line-of-Sight Checks

## Severity: MEDIUM

## Description

The hit detection functions `findEnemiesPart()` and `findEnemiesMagnitude()` do not verify line of sight (LOS) between the attacker and targets. This allows players to damage enemies through walls, floors, and other solid obstacles.

## Vulnerability Details

The game uses two primary hit detection methods:
1. **`findEnemiesPart(hitbox)`** - Finds enemies within a Part's bounds
2. **`findEnemiesMagnitude(position, radius)`** - Finds enemies within a radius

Neither function checks if there is an unobstructed path between the attacker and target. This means:
- Attacks hit through walls
- Players can be damaged from adjacent rooms
- Underground attacks affect surface players

### Systemic Issue

This vulnerability affects **all combat modules** (100+ files) since they all rely on these shared hit detection functions.

## Affected Files

All modules using `findEnemiesPart` or `findEnemiesMagnitude`:

| Category | Example Files | Count |
|----------|---------------|-------|
| Part-based detection | `BindModule_ID42.luau`, `BreakModule_ID51.luau` | 60+ |
| Magnitude-based detection | `ChillingArcModule_ID77.luau`, `CelestialCollideModule_ID132.luau` | 40+ |
| Both methods | `WrathModule_ID119.luau`, `BodySlamModule_ID160.luau` | 20+ |

## Vulnerable Code Examples

### Example 1: BindModule_ID42.luau (Line 83)
```lua
-- Line 81-85
if workspace_Raycast_result1 then
    clone_2_upvr.CFrame = CFrame.new(workspace_Raycast_result1.Position) * clone_2_upvr.CFrame - clone_2_upvr.CFrame.p
end
for _, v_upvr in var3_upvw.findEnemiesPart(clone_2_upvr.hitbox, true), nil do
    -- Damages all enemies in hitbox, even through walls!
    local Position_2_upvr = clone_2_upvr.Position
    -- ...damage applied without LOS check
end
```

### Example 2: ChillingArcModule_ID77.luau (Line 74)
```lua
-- Line 72-76
Snow_Explosion_2:Play()
var2_upvw.EmitAllDescendants(SOME)
for _, v_2 in var2_upvw.findEnemiesMagnitude(SOME.Position, 18, true), nil do
    -- No line of sight check - damages through walls
    if not table.find(tbl, v_2) then
        table.insert(tbl, v_2)
        -- ...applies effects without visibility check
    end
end
```

### Example 3: CelestialCollideModule_ID132.luau (Line 127)
```lua
-- Line 125-129
var2_upvw.applySound(Celestial_Collide_upvr.Explode2, HumanoidRootPart_upvr)
for i_2, v_2 in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 7, 20, true), nil do
    -- Hits enemies within 20 studs, ignoring walls
    if not var2_upvw.CheckBlock(v_2, true) then
        var2_upvw.applyDamage(v_2, 9)
        -- ...
    end
end
```

### Example 4: WrathModule_ID119.luau (Lines 145-150)
```lua
-- Line 143-152
var3_upvw.changeFov(arg1, 60, 0, 0.8)
var3_upvw.flashScreen(arg1, Color3.new(1, 0.113725, 0.113725), 0.1)
for _, v_3 in var3_upvw.findEnemiesMagnitude(clone_upvr.Position, 100), nil do
    -- 100 stud radius effect - hits through everything
    var3_upvw.camShake(v_3, "Bump")
    -- ...
end
for _, v_4 in var3_upvw.findEnemiesPart(clone_upvr.Hitbox, true), nil do
    -- Also no LOS check on part-based detection
    if not var3_upvw.CheckBlock(v_4) then
        var3_upvw.applyDamage(v_4, 3)
    end
end
```

### Example 5: BodySlamModule_ID160.luau (Lines 84, 162)
```lua
-- Line 84 - Initial grab detection
for _, v in var3_upvw.findEnemiesPart(clone_6, true), nil do
    -- Can grab enemies through walls
    if var3_upvw.CheckBlock(v, true) then break end
    -- ...grab logic
end

-- Line 162 - Landing damage
for _, v_3 in var3_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 20, true), nil do
    -- 20 stud radius damage on landing - hits through floor
    var3_upvw.applyDamage(v_3, 20, false, false)
    var3_upvw.applyStatus(v_3, "Ragdoll", 2.2)
end
```

## Exploitation

This vulnerability enables several attack strategies:

```lua
-- Exploit 1: Attack players in adjacent room
-- Stand next to a wall, attack hitbox extends through wall
local adjacentWallPosition = findWallPosition()
positionSelfAt(adjacentWallPosition)
useAOESkill()  -- Damages players on other side of wall

-- Exploit 2: Underground attacks
-- Position below map surface to attack players above
local undergroundPosition = Vector3.new(0, -10, 0)
-- Combined with V09 teleport exploit:
fireRemote("Siphon", CFrame.new(undergroundPosition))
useAOESkill()  -- Hits surface players from below

-- Exploit 3: Safe zone attacks
-- Attack from inside spawn protection areas through walls
```

## Impact

- **Through-Wall Attacks**: Hit players in completely separate rooms
- **Spawn Camping**: Attack players in protected spawn areas through walls
- **Unfair Combat**: Damage players who cannot see or reach attacker
- **Map Exploits**: Attack from inside geometry or inaccessible areas
- **Safe Zone Bypass**: Hit players who should be protected by physical barriers

## Visual Example

```
Room A               Wall               Room B
+----------+          |          +----------+
|          |          |          |          |
|  [Player]|  <---Attack--->   |[Victim]  |
|  uses    |          |          |  gets    |
|  skill   |          |          |  damaged |
+----------+          |          +----------+

Attack passes through wall without obstruction check
```

## Remediation

### 1. Add LOS Check to findEnemiesPart
```lua
function findEnemiesPartWithLOS(hitbox, attackerPosition)
    local enemies = findEnemiesPart(hitbox)
    local validEnemies = {}

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {hitbox.Parent}

    for _, enemy in enemies do
        local targetPosition = enemy.HumanoidRootPart.Position
        local direction = targetPosition - attackerPosition
        local result = workspace:Raycast(attackerPosition, direction, rayParams)

        -- Only include if no obstruction or hit the target
        if result == nil or result.Instance:IsDescendantOf(enemy) then
            table.insert(validEnemies, enemy)
        end
    end

    return validEnemies
end
```

### 2. Add LOS Check to findEnemiesMagnitude
```lua
function findEnemiesMagnitudeWithLOS(origin, radius, attackerPosition)
    local enemies = findEnemiesMagnitude(origin, radius)
    local validEnemies = {}

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {workspace.Characters}

    for _, enemy in enemies do
        local targetPosition = enemy.HumanoidRootPart.Position
        local direction = targetPosition - attackerPosition

        local result = workspace:Raycast(attackerPosition, direction, rayParams)

        if result == nil then
            table.insert(validEnemies, enemy)
        end
    end

    return validEnemies
end
```

### 3. Update Shared Skills Module
```lua
-- In the shared Skills module, add LOS wrapper
function Skills.findEnemiesPartLOS(hitbox, requireLOS)
    if not requireLOS then
        return Skills.findEnemiesPart(hitbox)
    end

    local attackerPosition = hitbox.Parent:FindFirstChild("HumanoidRootPart").Position
    return findEnemiesPartWithLOS(hitbox, attackerPosition)
end
```

### 4. Per-Skill Toggle
```lua
-- Some skills may intentionally ignore LOS (explosions, etc.)
local SKILL_LOS_REQUIRED = {
    ["Bind"] = true,
    ["ChillingArc"] = true,
    ["CelestialCollide"] = true,
    ["Wrath"] = false,  -- Explosion, intentionally ignores walls
}
```

## References

- Related to V03 (Client-Controlled Hitbox Positioning)
- [Game Design: Line of Sight Systems](https://www.gamedeveloper.com/design/line-of-sight-systems)
- [Roblox Raycasting Documentation](https://create.roblox.com/docs/workspace/raycasting)

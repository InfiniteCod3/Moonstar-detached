--[[
    V11: Missing Line-of-Sight Checks - Proof of Concept

    SEVERITY: MEDIUM

    This PoC demonstrates how the lack of LOS verification allows
    attacking players through walls and solid obstacles.

    FOR EDUCATIONAL/SECURITY TESTING PURPOSES ONLY
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--[[
    Demonstration 1: Through-Wall Attack Analysis

    Shows how findEnemiesPart/findEnemiesMagnitude would detect
    players that are not visible due to wall obstruction.
]]
local function analyzeWallPenetration()
    print("=== V11 Wall Penetration Analysis ===")

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {Character}

    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local distance = (targetHRP.Position - HumanoidRootPart.Position).Magnitude
                local direction = targetHRP.Position - HumanoidRootPart.Position

                -- Check for obstruction
                local result = Workspace:Raycast(
                    HumanoidRootPart.Position,
                    direction,
                    rayParams
                )

                local hasLOS = (result == nil) or result.Instance:IsDescendantOf(player.Character)
                local blocked = result and not result.Instance:IsDescendantOf(player.Character)

                print(string.format(
                    "Player: %s | Distance: %.1f | LOS: %s | Blocked by: %s",
                    player.Name,
                    distance,
                    hasLOS and "YES" or "NO",
                    blocked and result.Instance.Name or "Nothing"
                ))

                if blocked and distance < 50 then
                    print("  ^ VULNERABLE: Would be hit by attacks without LOS check!")
                end
            end
        end
    end

    print("=====================================")
end

--[[
    Exploit 1: Position Next to Wall for Through-Wall Attack

    The attacker positions themselves against a wall and uses
    an AOE skill. The hitbox extends through the wall, damaging
    players on the other side.
]]
local function throughWallPositioning()
    -- Find nearest wall
    local directions = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 0, 1),
        Vector3.new(0, 0, -1),
    }

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {Character}

    local closestWall = nil
    local closestDistance = math.huge

    for _, dir in directions do
        local result = Workspace:Raycast(HumanoidRootPart.Position, dir * 50, rayParams)
        if result and result.Distance < closestDistance then
            closestDistance = result.Distance
            closestWall = result
        end
    end

    if closestWall then
        print("[V11 PoC] Nearest wall:", closestWall.Instance.Name, "at distance:", closestDistance)
        print("[V11 PoC] Move to wall and use AOE skill to hit players on other side")
        return closestWall.Position
    end

    return nil
end

--[[
    Exploit 2: Underground Attack (Combined with V09)

    Teleport below the map surface and attack upward.
    AOE attacks will hit surface players without LOS check.
]]
local function demonstrateUndergroundAttack()
    print("[V11 PoC] Underground Attack Demonstration")

    -- Calculate position below current location
    local undergroundPos = HumanoidRootPart.Position - Vector3.new(0, 20, 0)

    print("[V11 PoC] If teleported to:", undergroundPos)
    print("[V11 PoC] Players within 25 studs above would be hit by findEnemiesMagnitude")

    -- Check what players would be affected
    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer and player.Character then
            local targetPos = player.Character.HumanoidRootPart.Position
            local horizDist = Vector2.new(
                targetPos.X - undergroundPos.X,
                targetPos.Z - undergroundPos.Z
            ).Magnitude

            local vertDist = targetPos.Y - undergroundPos.Y

            if horizDist < 25 and vertDist > 0 and vertDist < 25 then
                print("[V11 PoC] Player", player.Name, "would be hit from underground!")
            end
        end
    end
end

--[[
    Exploit 3: Geometry Hiding

    Position inside map geometry (using V09 teleport) and attack outward.
    Players cannot see or attack you, but you can hit them.
]]
local function analyzeGeometryHiding()
    print("[V11 PoC] Analyzing potential geometry hiding spots...")

    -- Cast rays in all directions to find enclosed spaces
    local enclosed = true
    local directions = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 1, 0),
        Vector3.new(0, -1, 0),
        Vector3.new(0, 0, 1),
        Vector3.new(0, 0, -1),
    }

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {Character}

    local nearestWallDistance = math.huge

    for _, dir in directions do
        local result = Workspace:Raycast(HumanoidRootPart.Position, dir * 10, rayParams)
        if result then
            nearestWallDistance = math.min(nearestWallDistance, result.Distance)
        else
            enclosed = false
        end
    end

    if enclosed then
        print("[V11 PoC] Current position is enclosed!")
        print("[V11 PoC] Can attack out without being hit back")
    else
        print("[V11 PoC] Current position is not enclosed")
        print("[V11 PoC] Nearest wall distance:", nearestWallDistance)
    end
end

--[[
    Demonstration 4: Show Affected Skills

    List skills that use findEnemiesPart/findEnemiesMagnitude
    without LOS checks.
]]
local function listVulnerableSkills()
    local vulnerableSkills = {
        {name = "Bind", module = "BindModule_ID42.luau", line = 83, method = "findEnemiesPart"},
        {name = "Chilling Arc", module = "ChillingArcModule_ID77.luau", line = 74, method = "findEnemiesMagnitude"},
        {name = "Celestial Collide", module = "CelestialCollideModule_ID132.luau", line = 127, method = "findEnemiesMagnitude"},
        {name = "Wrath", module = "WrathModule_ID119.luau", line = 145, method = "findEnemiesMagnitude"},
        {name = "Wrath (hitbox)", module = "WrathModule_ID119.luau", line = 150, method = "findEnemiesPart"},
        {name = "Body Slam", module = "BodySlamModule_ID160.luau", line = 84, method = "findEnemiesPart"},
        {name = "Body Slam (landing)", module = "BodySlamModule_ID160.luau", line = 162, method = "findEnemiesMagnitude"},
        {name = "Break", module = "BreakModule_ID51.luau", line = 104, method = "findEnemiesPart"},
        {name = "Agressive Breeze", module = "AgressiveBreezeModule_ID171.luau", line = 99, method = "findEnemiesPart"},
        {name = "Quick Breeze", module = "QuickBreezeModule_ID178.luau", line = 93, method = "findEnemiesPart"},
    }

    print("=== Vulnerable Skills (No LOS Check) ===")
    for _, skill in vulnerableSkills do
        print(string.format(
            "  %s (%s) - %s:%d",
            skill.name,
            skill.method,
            skill.module,
            skill.line
        ))
    end
    print("Total: 100+ skills affected (all using shared hit detection)")
    print("=========================================")
end

-- Run demonstrations (commented for safety):
--[[
analyzeWallPenetration()
throughWallPositioning()
demonstrateUndergroundAttack()
analyzeGeometryHiding()
listVulnerableSkills()
]]

return {
    analyzeWallPenetration = analyzeWallPenetration,
    throughWallPositioning = throughWallPositioning,
    demonstrateUndergroundAttack = demonstrateUndergroundAttack,
    analyzeGeometryHiding = analyzeGeometryHiding,
    listVulnerableSkills = listVulnerableSkills,
}

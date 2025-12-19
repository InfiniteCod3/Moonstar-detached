--[[
    V10: Client-Controlled Hitbox Size - Proof of Concept

    SEVERITY: MEDIUM

    This PoC demonstrates how client-controlled hitbox size (SizeZ)
    allows creating massive attack areas that hit multiple players.

    FOR EDUCATIONAL/SECURITY TESTING PURPOSES ONLY
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Configuration
local NORMAL_SIZE_Z = 55       -- Normal intended hitbox length
local EXPLOITED_SIZE_Z = 10000 -- Massively extended hitbox

--[[
    Exploit 1: Massive Hitbox - Agressive Breeze

    The server uses: clone_3.Size = Vector3.new(25, 25, arg3.SizeZ)
    We can send any SizeZ value to create a hitbox covering the entire map.

    Vulnerable code in AgressiveBreezeModule_ID171.luau:78:
    clone_3.Size = Vector3.new(25, 25, arg3.SizeZ)
]]
local function massiveAgressiveBreeze()
    ReplicatedStorage.Remotes.ClientInfo:FireServer("Agressive Breeze", {
        SizeZ = EXPLOITED_SIZE_Z,  -- 10000 stud long hitbox!
        CF = HumanoidRootPart.CFrame
    })

    print("[V10 PoC] Fired Agressive Breeze with SizeZ:", EXPLOITED_SIZE_Z)
    print("[V10 PoC] Normal SizeZ would be approximately:", NORMAL_SIZE_Z)
end

--[[
    Exploit 2: Massive Hitbox - Quick Breeze

    Similar to Agressive Breeze but uses different base size.

    Vulnerable code in QuickBreezeModule_ID178.luau:76:
    clone_3.Size = Vector3.new(6, 6, arg3.SizeZ)
]]
local function massiveQuickBreeze()
    ReplicatedStorage.Remotes.ClientInfo:FireServer("Quick Breeze", {
        SizeZ = EXPLOITED_SIZE_Z,  -- 10000 stud long hitbox!
        CF = HumanoidRootPart.CFrame
    })

    print("[V10 PoC] Fired Quick Breeze with SizeZ:", EXPLOITED_SIZE_Z)
end

--[[
    Exploit 3: Directional Map Sweep

    Combine with V09 (CFrame control) to position hitbox
    and sweep across the entire map in a direction.
]]
local function mapSweepAttack(direction: Vector3)
    local sweepCFrame = CFrame.lookAt(
        HumanoidRootPart.Position,
        HumanoidRootPart.Position + direction
    )

    ReplicatedStorage.Remotes.ClientInfo:FireServer("Agressive Breeze", {
        SizeZ = 50000,  -- Extends across entire map in direction
        CF = sweepCFrame
    })

    print("[V10 PoC] Map sweep attack in direction:", direction)
end

--[[
    Exploit 4: 360 Degree Kill Zone

    Fire multiple attacks in all directions with massive hitboxes
    to create an inescapable damage zone.
]]
local function killZone360()
    local angles = {0, 45, 90, 135, 180, 225, 270, 315}

    for _, angle in ipairs(angles) do
        local radians = math.rad(angle)
        local direction = Vector3.new(math.sin(radians), 0, math.cos(radians))
        local attackCFrame = CFrame.lookAt(
            HumanoidRootPart.Position,
            HumanoidRootPart.Position + direction
        )

        ReplicatedStorage.Remotes.ClientInfo:FireServer("Quick Breeze", {
            SizeZ = 20000,
            CF = attackCFrame
        })

        task.wait(0.1)  -- Small delay between attacks
    end

    print("[V10 PoC] 360 degree kill zone created")
end

--[[
    Exploit 5: Sniper Attack

    Use massive SizeZ combined with precise CFrame (V09)
    to hit a specific player from across the map.
]]
local function sniperAttack(targetPlayerName: string)
    local targetPlayer = Players:FindFirstChild(targetPlayerName)
    if not targetPlayer or not targetPlayer.Character then
        warn("[V10 PoC] Target player not found")
        return
    end

    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    -- Calculate CFrame pointing at target
    local sniperCFrame = CFrame.lookAt(
        HumanoidRootPart.Position,
        targetHRP.Position
    )

    -- Distance to target
    local distance = (targetHRP.Position - HumanoidRootPart.Position).Magnitude

    ReplicatedStorage.Remotes.ClientInfo:FireServer("Agressive Breeze", {
        SizeZ = distance + 100,  -- Just long enough to reach target
        CF = sniperCFrame
    })

    print("[V10 PoC] Sniper attack on", targetPlayerName, "at distance:", distance)
end

--[[
    Comparison: Normal vs Exploited

    Shows the difference between legitimate and exploited SizeZ values.
]]
local function compareNormalVsExploited()
    print("=== V10 Size Comparison ===")
    print("Normal Quick Breeze hitbox: 6x6x" .. NORMAL_SIZE_Z)
    print("Exploited Quick Breeze hitbox: 6x6x" .. EXPLOITED_SIZE_Z)
    print("Increase factor:", EXPLOITED_SIZE_Z / NORMAL_SIZE_Z .. "x")
    print("")
    print("Normal Agressive Breeze hitbox: 25x25x" .. NORMAL_SIZE_Z)
    print("Exploited Agressive Breeze hitbox: 25x25x" .. EXPLOITED_SIZE_Z)
    print("===========================")
end

-- Example usage (commented out for safety):
--[[
compareNormalVsExploited()

-- Fire massive hitbox attacks
massiveAgressiveBreeze()
massiveQuickBreeze()

-- Sweep attack in forward direction
mapSweepAttack(HumanoidRootPart.CFrame.LookVector)

-- Create 360 kill zone
killZone360()

-- Sniper attack on specific player
sniperAttack("TargetPlayerName")
]]

return {
    massiveAgressiveBreeze = massiveAgressiveBreeze,
    massiveQuickBreeze = massiveQuickBreeze,
    mapSweepAttack = mapSweepAttack,
    killZone360 = killZone360,
    sniperAttack = sniperAttack,
    compareNormalVsExploited = compareNormalVsExploited,
}

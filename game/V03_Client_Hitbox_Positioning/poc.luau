--[[
    Proof of Concept: V03_Client_Hitbox_Positioning Exploit

    DISCLAIMER: This script is for educational and security research purposes only.
    Unauthorized use of this exploit against live game servers is prohibited.

    Vulnerability: Server accepts client-provided CFrame/Position data for
    damage hitbox positioning without validation, allowing remote attacks.
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local ClientInfoRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClientInfo")

--[[
    EXPLOIT MODULE: Client Hitbox Positioning Bypass

    Demonstrates the vulnerability where the server trusts client-provided
    position data for skill hitbox placement.
]]

local HitboxExploit = {}

-- Configuration
HitboxExploit.Config = {
    -- Enable/disable individual exploits
    EnableBindExploit = true,
    EnableChillingArcExploit = true,
    EnableFieryLeapExploit = true,

    -- Debug output
    DebugMode = true,
}

-- Utility function to log debug messages
local function debugLog(message)
    if HitboxExploit.Config.DebugMode then
        print("[V03_POC] " .. message)
    end
end

-- Get all players except local player
local function getEnemyPlayers()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                table.insert(enemies, {
                    Player = player,
                    Character = player.Character,
                    Position = hrp.Position,
                    CFrame = hrp.CFrame
                })
            end
        end
    end
    return enemies
end

-- Find closest enemy to a position
local function findClosestEnemy(position)
    local closest = nil
    local closestDist = math.huge

    for _, enemy in pairs(getEnemyPlayers()) do
        local dist = (enemy.Position - position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = enemy
        end
    end

    return closest, closestDist
end

--[[
    EXPLOIT 1: Bind Skill Remote Hitbox

    Vulnerable code (BindModule_ID42.luau, Line 62):
        clone_2_upvr.CFrame = arg3 + arg3.LookVector * 30 + Vector3.new(0, -2.9000, 0)

    The server uses the client-provided CFrame (arg3) directly to position
    the damage indicator. This allows attacking any player on the map.
]]
function HitboxExploit.ExploitBind(targetPosition)
    if not HitboxExploit.Config.EnableBindExploit then return end

    debugLog("Exploiting Bind skill - targeting position: " .. tostring(targetPosition))

    -- Craft malicious CFrame pointing at target
    -- The server adds LookVector * 30, so we offset back
    local attackerPos = LocalPlayer.Character.HumanoidRootPart.Position
    local direction = (targetPosition - attackerPos).Unit
    local maliciousCFrame = CFrame.lookAt(targetPosition - direction * 30, targetPosition)

    -- Fire the remote with spoofed position
    -- arg1: Player (auto-filled by server)
    -- arg2: Skill name
    -- arg3: CFrame (EXPLOITED - should be validated)
    ClientInfoRemote:FireServer("Bind", maliciousCFrame)

    debugLog("Bind exploit fired - hitbox will appear at target location")
end

--[[
    EXPLOIT 2: Chilling Arc Remote Hitbox

    Vulnerable code (ChillingArcModule_ID77.luau, Line 56):
        clone_5.CFrame = arg3.IndicatorCF

    The server uses arg3.IndicatorCF directly from the client to position
    the VFX and damage zones.
]]
function HitboxExploit.ExploitChillingArc(targetPosition)
    if not HitboxExploit.Config.EnableChillingArcExploit then return end

    debugLog("Exploiting Chilling Arc skill - targeting position: " .. tostring(targetPosition))

    -- Craft malicious payload with spoofed IndicatorCF
    local maliciousPayload = {
        IndicatorCF = CFrame.new(targetPosition)
    }

    -- Fire the remote with spoofed position data
    -- The server will position VFX and find enemies at our chosen location
    ClientInfoRemote:FireServer("Chilling Arc", maliciousPayload)

    debugLog("Chilling Arc exploit fired - 4 damage zones at target location")
end

--[[
    EXPLOIT 3: Fiery Leap Remote Explosion

    Vulnerable code (FieryLeapModule_ID25.luau, Lines 76, 124, 129):
        var34_upvw = arg3.ExplosionPosition
        clone_2.Position = var34_upvw + var37
        clone_3_upvr.Position = var34_upvw

    The server uses arg3.ExplosionPosition to place the explosion hitbox
    and visual effects anywhere we specify.
]]
function HitboxExploit.ExploitFieryLeap(targetPosition)
    if not HitboxExploit.Config.EnableFieryLeapExploit then return end

    debugLog("Exploiting Fiery Leap skill - targeting position: " .. tostring(targetPosition))

    -- Craft malicious payload with spoofed ExplosionPosition
    local maliciousPayload = {
        ExplosionPosition = targetPosition
    }

    -- Fire the remote with spoofed position data
    -- The server will create hitbox, crater, and explosion at our chosen location
    ClientInfoRemote:FireServer("Fiery Leap", maliciousPayload)

    debugLog("Fiery Leap exploit fired - explosion hitbox at target location")
end

--[[
    AUTOMATED EXPLOIT: Target Nearest Enemy Anywhere on Map

    Demonstrates the full attack chain:
    1. Find all enemies on the map
    2. Target the closest one (or a specific one)
    3. Fire exploited skill at their position
]]
function HitboxExploit.AutoTargetNearestEnemy(skillName)
    local enemies = getEnemyPlayers()

    if #enemies == 0 then
        debugLog("No enemies found on map")
        return false
    end

    -- Find closest enemy to our position
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local target, distance = findClosestEnemy(myPos)

    if not target then
        debugLog("Failed to find target")
        return false
    end

    debugLog(string.format("Target acquired: %s at distance %.1f studs",
        target.Player.Name, distance))

    -- Execute exploit based on skill selection
    if skillName == "Bind" or skillName == "all" then
        HitboxExploit.ExploitBind(target.Position)
    end

    if skillName == "ChillingArc" or skillName == "all" then
        task.wait(0.1) -- Small delay between skills
        HitboxExploit.ExploitChillingArc(target.Position)
    end

    if skillName == "FieryLeap" or skillName == "all" then
        task.wait(0.1)
        HitboxExploit.ExploitFieryLeap(target.Position)
    end

    return true
end

--[[
    DEMONSTRATION: Attack Specific Map Coordinates

    This demonstrates the ability to attack ANY position on the map,
    regardless of where the attacker is located.
]]
function HitboxExploit.AttackMapPosition(x, y, z, skillName)
    local targetPos = Vector3.new(x, y, z)

    debugLog(string.format("Attacking map coordinates: (%.1f, %.1f, %.1f) with %s",
        x, y, z, skillName))

    if skillName == "Bind" then
        HitboxExploit.ExploitBind(targetPos)
    elseif skillName == "ChillingArc" then
        HitboxExploit.ExploitChillingArc(targetPos)
    elseif skillName == "FieryLeap" then
        HitboxExploit.ExploitFieryLeap(targetPos)
    else
        debugLog("Unknown skill: " .. skillName)
    end
end

--[[
    DEMONSTRATION: Attack All Players on Map

    Rapidly cycles through all players and attacks each one,
    demonstrating the ability to hit everyone simultaneously.
]]
function HitboxExploit.AttackAllPlayers()
    local enemies = getEnemyPlayers()

    debugLog(string.format("Attacking all %d players on map", #enemies))

    for i, enemy in ipairs(enemies) do
        debugLog(string.format("[%d/%d] Attacking: %s", i, #enemies, enemy.Player.Name))

        -- Use all three exploits on each target
        HitboxExploit.ExploitBind(enemy.Position)
        task.wait(0.05)
        HitboxExploit.ExploitChillingArc(enemy.Position)
        task.wait(0.05)
        HitboxExploit.ExploitFieryLeap(enemy.Position)
        task.wait(0.1)
    end

    debugLog("Attack sequence complete")
end

--[[
    USAGE EXAMPLES (commented out for safety)

    -- Attack nearest enemy with all skills
    HitboxExploit.AutoTargetNearestEnemy("all")

    -- Attack specific map coordinates
    HitboxExploit.AttackMapPosition(100, 50, 200, "FieryLeap")

    -- Attack all players on the server
    HitboxExploit.AttackAllPlayers()

    -- Individual skill exploits
    local targetPos = Vector3.new(0, 10, 0)
    HitboxExploit.ExploitBind(targetPos)
    HitboxExploit.ExploitChillingArc(targetPos)
    HitboxExploit.ExploitFieryLeap(targetPos)
]]

-- Print exploit loaded message
print([[
================================================================================
    V03_Client_Hitbox_Positioning - Proof of Concept Loaded

    Vulnerability: Damage hitboxes positioned using unvalidated client data

    Affected Skills:
    - Bind (BindModule_ID42.luau) - 10 damage, 2s stun
    - Chilling Arc (ChillingArcModule_ID77.luau) - 52 total damage, knockback
    - Fiery Leap (FieryLeapModule_ID25.luau) - 15 damage, ragdoll, burn

    Impact: Attack any player anywhere on the map from any location

    FOR EDUCATIONAL AND SECURITY RESEARCH PURPOSES ONLY
================================================================================
]])

return HitboxExploit

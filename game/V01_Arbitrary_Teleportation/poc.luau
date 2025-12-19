--[[
    PROOF OF CONCEPT: V01 Arbitrary Teleportation Vulnerability

    WARNING: This script is for educational and security testing purposes only.
    Unauthorized use of this exploit against live games is against Roblox TOS.

    This PoC demonstrates how an attacker can abuse the unvalidated TeleportPosition
    parameter in ClientInfo.OnServerEvent to teleport anywhere in the game.
]]

-- ============================================================================
-- EXPLOIT CONFIGURATION
-- ============================================================================

local TARGET_POSITION = Vector3.new(0, 1000, 0)  -- Teleport destination
local EXPLOIT_METHOD = "Concept"  -- Options: "Concept", "SnowCloak", "BodySlam"

-- ============================================================================
-- SERVICES
-- ============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ============================================================================
-- REFERENCES
-- ============================================================================

local LocalPlayer = Players.LocalPlayer
local ClientInfoRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClientInfo")

-- ============================================================================
-- EXPLOIT FUNCTIONS
-- ============================================================================

--[[
    Exploit Method 1: Concept (Basic Sword Ultimate)

    Vulnerable code in ConceptModule_ID9.luau:
    Line 61-62:
        NONE_2 = CFrame.new(arg3.TeleportPosition) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
        HumanoidRootPart_upvr.CFrame = NONE_2

    The server directly uses arg3.TeleportPosition without any validation.
]]
local function exploitConcept(targetPosition: Vector3)
    print("[PoC] Attempting Concept teleport exploit...")
    print("[PoC] Target position:", targetPosition)

    -- The server expects:
    -- arg1: Player (automatically provided by Roblox)
    -- arg2: Action name "Concept"
    -- arg3: Table containing TeleportPosition

    ClientInfoRemote:FireServer("Concept", {
        TeleportPosition = targetPosition
    })

    print("[PoC] Exploit payload sent!")
end

--[[
    Exploit Method 2: Snow Cloak (Snow Blasters)

    Vulnerable code in SnowCloakModule_ID75.luau:
    Line 102:
        HumanoidRootPart_upvr.CFrame = CFrame.new(arg3.TeleportPosition) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p

    Same vulnerability pattern - direct use of client TeleportPosition.
]]
local function exploitSnowCloak(targetPosition: Vector3)
    print("[PoC] Attempting Snow Cloak teleport exploit...")
    print("[PoC] Target position:", targetPosition)

    ClientInfoRemote:FireServer("SnowCloak", {
        TeleportPosition = targetPosition
    })

    print("[PoC] Exploit payload sent!")
end

--[[
    Exploit Method 3: Body Slam (Fire Fists Ultimate)

    Vulnerable code in BodySlamModule_ID160.luau:
    Lines 73-74:
        if arg3 then
            HumanoidRootPart_upvr.CFrame = arg3
        end

    This variant directly accepts a CFrame instead of extracting TeleportPosition.
    Even more dangerous as attacker controls full CFrame including rotation.
]]
local function exploitBodySlam(targetPosition: Vector3)
    print("[PoC] Attempting Body Slam teleport exploit...")
    print("[PoC] Target position:", targetPosition)

    -- Body Slam directly accepts CFrame as arg3
    local targetCFrame = CFrame.new(targetPosition)

    ClientInfoRemote:FireServer("BodySlam", targetCFrame)

    print("[PoC] Exploit payload sent!")
end

-- ============================================================================
-- ADVANCED EXPLOIT SCENARIOS
-- ============================================================================

--[[
    Scenario 1: Teleport to map boundaries/outside map
    Demonstrates escaping intended play area
]]
local function teleportOutOfBounds()
    local outOfBoundsPosition = Vector3.new(99999, 99999, 99999)
    exploitConcept(outOfBoundsPosition)
end

--[[
    Scenario 2: Teleport to specific player
    Demonstrates using exploit for PvP advantage
]]
local function teleportToPlayer(targetPlayerName: string)
    local targetPlayer = Players:FindFirstChild(targetPlayerName)
    if targetPlayer and targetPlayer.Character then
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            -- Teleport behind the target for advantage
            local behindPosition = targetHRP.Position - targetHRP.CFrame.LookVector * 5
            exploitConcept(behindPosition)
        end
    end
end

--[[
    Scenario 3: Rapid teleportation spam
    Demonstrates lack of rate limiting
]]
local function rapidTeleportSpam(count: number, interval: number)
    for i = 1, count do
        local randomPosition = Vector3.new(
            math.random(-500, 500),
            math.random(10, 100),
            math.random(-500, 500)
        )
        exploitConcept(randomPosition)
        task.wait(interval)
    end
end

--[[
    Scenario 4: Teleport to unreachable location
    Demonstrates bypassing intended game barriers
]]
local function teleportToUnreachable()
    -- Example: Teleport to a floating island or locked area
    local unreachablePosition = Vector3.new(0, 5000, 0)  -- Very high in the sky
    exploitSnowCloak(unreachablePosition)
end

-- ============================================================================
-- MAIN EXECUTION
-- ============================================================================

print("========================================")
print("V01 Arbitrary Teleportation PoC")
print("========================================")
print("")
print("This PoC demonstrates the vulnerability where")
print("the server trusts client-provided TeleportPosition")
print("without any validation.")
print("")
print("Vulnerable RemoteEvent: ReplicatedStorage.Remotes.ClientInfo")
print("")
print("Affected Skills:")
print("  - Concept (ConceptModule_ID9.luau)")
print("  - Snow Cloak (SnowCloakModule_ID75.luau)")
print("  - Body Slam (BodySlamModule_ID160.luau)")
print("")
print("========================================")

-- Execute based on configured method
if EXPLOIT_METHOD == "Concept" then
    exploitConcept(TARGET_POSITION)
elseif EXPLOIT_METHOD == "SnowCloak" then
    exploitSnowCloak(TARGET_POSITION)
elseif EXPLOIT_METHOD == "BodySlam" then
    exploitBodySlam(TARGET_POSITION)
else
    warn("[PoC] Unknown exploit method:", EXPLOIT_METHOD)
end

--[[
    ADDITIONAL NOTES FOR SECURITY TESTERS:

    1. The vulnerability exists because the server only validates:
       - That the firing player matches the skill user
       - That the action name matches expected value

    2. The server does NOT validate:
       - Distance from current position to target
       - Whether target is within map bounds
       - Whether target is reachable via line of sight
       - Rate of teleportation requests

    3. The fix should include:
       - Maximum teleport distance check
       - Map boundary validation
       - Line of sight verification
       - Server-calculated positions instead of client-provided
       - Rate limiting on skill usage

    4. Detection methods:
       - Log teleportation distances
       - Flag teleports exceeding skill range
       - Monitor for impossible position changes
]]

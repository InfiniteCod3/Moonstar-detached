--[[
    PROOF OF CONCEPT: Client-Trusted Enemy Lists Vulnerability (V04)

    DISCLAIMER: This script is for EDUCATIONAL and SECURITY RESEARCH purposes only.
    Using this to exploit games without authorization is against Roblox ToS and may
    result in account termination. This PoC demonstrates the vulnerability to help
    developers understand and fix the issue.

    Vulnerability: Server trusts arg3.enemiesDetected list from client instead of
    detecting targets server-side. Client can specify arbitrary targets.

    Affected Skills:
    - Rapid Ice (Snow Blasters) - RapidIceModule_ID73
    - Pinpoint Shuriken (Cyber Katana Ultimate) - PinpointShurikenModule_ID99
    - Rise (Titans Edge Ultimate) - RiseModule_ID84
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get remotes (path may vary by game)
local ClientInfoRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClientInfo")

-- Local player reference
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--[[
    EXPLOIT 1: Rapid Ice - Target any players on the map

    Normal behavior: Client detects enemies in cone in front of player
    Exploit: Specify any player(s) as targets regardless of position

    Server code trusts arg3.enemiesDetected without proper validation.
    The 25 stud range check at line 89 is easily bypassed because it
    checks against a calculated forward position, not actual distance.
]]
local function exploitRapidIce(targetPlayers)
    -- Build fake enemy list with arbitrary targets
    local fakeEnemyList = {}

    for _, targetPlayer in ipairs(targetPlayers) do
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(fakeEnemyList, targetPlayer.Character)
        end
    end

    -- Fire the exploit payload
    -- The server at RapidIceModule_ID73.luau line 83 will iterate over this list
    -- and apply damage at line 203: var2_upvw.applyDamage(v_3_upvr, 3)
    ClientInfoRemote:FireServer("RapidIce", {
        enemiesDetected = fakeEnemyList
    })

    print("[PoC] Rapid Ice exploit fired at", #fakeEnemyList, "targets")
end

--[[
    EXPLOIT 2: Pinpoint Shuriken - Snipe any player across the map

    Normal behavior: Client detects enemies for homing shuriken
    Exploit: Shuriken will home in on ANY specified target

    Server code at PinpointShurikenModule_ID99.luau line 180 iterates
    over arg3.enemiesDetected. The 500 stud range check at line 186
    is nearly useless - covers most of any game map.

    Damage dealt: 7 per shuriken hit (line 350), plus 3 second stun
]]
local function exploitPinpointShuriken(targetPlayers)
    local fakeEnemyList = {}

    for _, targetPlayer in ipairs(targetPlayers) do
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(fakeEnemyList, targetPlayer.Character)
        end
    end

    -- Fire exploit payload
    -- Server spawns homing shuriken at each target in the list
    ClientInfoRemote:FireServer("PinpointShuriken", {
        enemiesDetected = fakeEnemyList
    })

    print("[PoC] Pinpoint Shuriken exploit fired at", #fakeEnemyList, "targets")
end

--[[
    EXPLOIT 3: Rise (Titans Edge Ultimate) - Grab and slam ANY player

    Normal behavior: Client sends detected grab target
    Exploit: Grab ANY player regardless of position

    THIS IS THE MOST SEVERE - No range check at all!

    Server code at RiseModule_ID84.luau line 56 accepts arg3 directly
    as the target (not even a list). There is NO range validation.

    The attack sequence:
    - Line 88: Weld victim to attacker (teleport grab)
    - Line 115: 10 damage
    - Line 231: 10 damage
    - Line 242: 10 damage
    - Line 243: 3 second ragdoll

    Total: 30 damage + full combo on ANY player on the server
]]
local function exploitRise(targetPlayer, chargeTime)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("[PoC] Target player has no valid character")
        return
    end

    -- arg3 = target character (directly, not in a list!)
    -- arg4 = charge time (affects stun duration)
    local targetCharacter = targetPlayer.Character
    chargeTime = chargeTime or 0.5  -- Default charge time

    -- Fire exploit payload
    -- Server will grab and slam the target through walls, across the map, anywhere
    ClientInfoRemote:FireServer("Rise", targetCharacter, chargeTime)

    print("[PoC] Rise exploit fired at", targetPlayer.Name, "- 30 damage combo incoming")
end

--[[
    UTILITY: Get all other players in the server
]]
local function getAllOtherPlayers()
    local others = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(others, player)
        end
    end
    return others
end

--[[
    UTILITY: Get player by name
]]
local function getPlayerByName(name)
    return Players:FindFirstChild(name)
end

--[[
    DEMONSTRATION FUNCTIONS

    These show how an attacker would use the exploits.
    In a real attack scenario, these would be bound to GUI buttons
    or hotkeys in an executor.
]]

-- Demo: Attack all players with Rapid Ice
local function demoRapidIceAll()
    local targets = getAllOtherPlayers()
    if #targets > 0 then
        exploitRapidIce(targets)
    else
        warn("[PoC] No other players to target")
    end
end

-- Demo: Attack specific player with Pinpoint Shuriken
local function demoPinpointShurikenTarget(playerName)
    local target = getPlayerByName(playerName)
    if target then
        exploitPinpointShuriken({target})
    else
        warn("[PoC] Player not found:", playerName)
    end
end

-- Demo: Grab and slam specific player with Rise
local function demoRiseTarget(playerName)
    local target = getPlayerByName(playerName)
    if target then
        exploitRise(target, 1.0)  -- 1 second charge for maximum stun
    else
        warn("[PoC] Player not found:", playerName)
    end
end

--[[
    AUTO-TARGETING LOOP (Most Dangerous Form)

    This demonstrates how an attacker could continuously target
    all players in the server with no effort.
]]
local function autoTargetLoop(skillName, interval)
    interval = interval or 2

    while true do
        local targets = getAllOtherPlayers()

        if skillName == "RapidIce" then
            exploitRapidIce(targets)
        elseif skillName == "PinpointShuriken" then
            exploitPinpointShuriken(targets)
        elseif skillName == "Rise" and #targets > 0 then
            -- Rise only targets one player at a time
            exploitRise(targets[math.random(1, #targets)])
        end

        task.wait(interval)
    end
end

--[[
    EXECUTION

    Uncomment the desired exploit demonstration:
]]

-- Single target demonstrations:
-- demoPinpointShurikenTarget("TargetPlayerName")
-- demoRiseTarget("TargetPlayerName")

-- Mass target demonstrations:
-- demoRapidIceAll()

-- Auto-targeting (extremely disruptive):
-- task.spawn(function() autoTargetLoop("RapidIce", 3) end)
-- task.spawn(function() autoTargetLoop("PinpointShuriken", 5) end)

print([[
================================================================================
V04 Client-Trusted Enemy Lists - Proof of Concept Loaded
================================================================================

Available exploit functions:
  exploitRapidIce(targetPlayers)      -- Array of Player objects
  exploitPinpointShuriken(targetPlayers) -- Array of Player objects
  exploitRise(targetPlayer, chargeTime)  -- Single Player, optional charge time

Demonstration functions:
  demoRapidIceAll()                   -- Attack all players with Rapid Ice
  demoPinpointShurikenTarget("Name")  -- Shuriken a specific player
  demoRiseTarget("Name")              -- Rise combo a specific player

Auto-targeting (DANGEROUS):
  autoTargetLoop("RapidIce", interval)
  autoTargetLoop("PinpointShuriken", interval)
  autoTargetLoop("Rise", interval)

REMINDER: This PoC is for security research and remediation testing only.
================================================================================
]])

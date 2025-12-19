--[[
    V08: Client Duration Control - Proof of Concept

    SEVERITY: HIGH

    DESCRIPTION:
    This PoC demonstrates how the RiseModule_ID84 accepts client-controlled
    duration values (arg4) for status effects, allowing attackers to send
    math.huge or large values for permanent/extended effects.

    VULNERABILITY PATTERN:
    ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3, arg4)
        var3_upvw.applyStatus(arg1, "IFrames", arg4 + 1)  -- arg4 from client!
]]

-- ============================================
-- VULNERABLE CODE FROM RiseModule_ID84.luau
-- ============================================

-- Remote Event Handler (Lines 56-70):
--[[
    var20_upvw = var3_upvw.conTimer(
        ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(
            function(arg1_2, arg2_2, arg3, arg4) -- arg4 is CLIENT-CONTROLLED
                -- ... validation checks ...
]]

-- Status Effects Using Client Duration (Lines 81-85):
--[[
    var3_upvw.applyStatus(arg1, "Freeze", arg4 + 1)      -- Line 81: arg4 from client!
    var3_upvw.applyStatus(arg1, "GlobalCD", arg4 + 1)    -- Line 82: arg4 from client!
    var3_upvw.applyStatus(arg1, "IFrames", arg4 + 1)     -- Line 83: arg4 from client!
    var3_upvw.applyStatus(arg3, "Stunned", arg4 + 1)     -- Line 84: arg4 from client!
    var3_upvw.applyStatus(arg3, "IFrames", arg4 + 1)     -- Line 85: arg4 from client!
]]

-- Server Wait Using Client Duration (Line 91):
--[[
    task.wait(arg4 + 0.25)  -- Server waits based on client value!
]]

-- ============================================
-- PROOF OF CONCEPT - DURATION MANIPULATION
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Get the vulnerable remote
local ClientInfoRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClientInfo")

-- ============================================
-- EXPLOIT 1: Permanent Self-Invincibility
-- ============================================
local function exploitPermanentIFrames()
    -- The server uses: var3_upvw.applyStatus(arg1, "IFrames", arg4 + 1)
    -- If we send arg4 = math.huge, duration becomes math.huge + 1 = math.huge (infinity)

    local targetEnemy = nil -- Would be the enemy character
    local maliciousDuration = math.huge

    -- Fire the remote with infinite duration
    -- ClientInfoRemote:FireServer(someData, targetEnemy, maliciousDuration)

    print("Exploit: Sending duration = math.huge")
    print("Result: IFrames applied for infinite duration")
    print("Effect: Permanent invincibility")
end

-- ============================================
-- EXPLOIT 2: Extended Duration (Stealthy)
-- ============================================
local function exploitExtendedDuration()
    -- For a more subtle exploit, use large but finite values
    -- Normal duration might be 1-3 seconds
    -- Extended to 999999 seconds (11.5 days)

    local extendedDuration = 999999

    -- ClientInfoRemote:FireServer(someData, targetEnemy, extendedDuration)

    print("Exploit: Sending duration = 999999 seconds")
    print("Result: Effects last 11.5 days")
    print("Effect: Effectively permanent without using math.huge")
end

-- ============================================
-- EXPLOIT 3: Permanent Enemy Stun
-- ============================================
local function exploitPermanentStun()
    -- Line 84: var3_upvw.applyStatus(arg3, "Stunned", arg4 + 1)
    -- arg3 is the enemy, so we can permastun them!

    local targetEnemy = workspace:FindFirstChild("EnemyPlayer") -- Example
    local infiniteDuration = math.huge

    -- ClientInfoRemote:FireServer(someData, targetEnemy, infiniteDuration)

    print("Exploit: Stunned enemy permanently")
    print("Result: Enemy cannot move, attack, or defend")
    print("Effect: Easy kills, griefing potential")
end

-- ============================================
-- EXPLOIT 4: Server Thread Blocking
-- ============================================
local function exploitServerWait()
    -- Line 91: task.wait(arg4 + 0.25)
    -- The server waits based on client value!

    -- Sending a large value could:
    -- 1. Block the skill processing thread
    -- 2. Cause server resource issues
    -- 3. Create timing exploits

    local blockingDuration = 3600 -- 1 hour

    print("Exploit: task.wait(3600 + 0.25) = server waits 1 hour")
    print("Result: Skill thread blocked, potential DoS")
end

-- ============================================
-- DEMONSTRATION
-- ============================================
local function demonstrateVulnerability()
    print("=== V08: Client Duration Control Demonstration ===")

    print("\nVulnerable Code Pattern:")
    print("  OnServerEvent:Connect(function(arg1_2, arg2_2, arg3, arg4)")
    print("      var3_upvw.applyStatus(arg1, \"IFrames\", arg4 + 1)")
    print("  -- arg4 is sent by client, no validation!")

    print("\nExploit Payloads:")
    print("  1. arg4 = math.huge       -> Permanent effects")
    print("  2. arg4 = 999999999       -> 31 year duration")
    print("  3. arg4 = -1              -> Duration becomes 0 (may cause issues)")
    print("  4. arg4 = 0/0 (NaN)       -> Undefined behavior")

    print("\nAffected Status Effects:")
    print("  - Freeze (self): Duration = arg4 + 1")
    print("  - GlobalCD (self): Duration = arg4 + 1")
    print("  - IFrames (self): Duration = arg4 + 1 -> INVINCIBILITY")
    print("  - Stunned (enemy): Duration = arg4 + 1 -> PERMASTUN")
    print("  - IFrames (enemy): Duration = arg4 + 1")

    print("\nServer Thread Impact:")
    print("  - task.wait(arg4 + 0.25) blocks based on client value")

    print("\nFile: RiseModule_ID84.luau")
    print("Lines: 81-85 (status effects), 91 (task.wait)")
end

demonstrateVulnerability()

-- ============================================
-- DETECTION METHOD
-- ============================================
--[[
    Server-side validation for client durations:

    local MAX_ALLOWED_DURATION = 10.0  -- Maximum 10 seconds

    ReplicatedStorage.Remotes.ClientInfo.OnServerEvent:Connect(function(player, arg2, arg3, arg4)
        -- Type check
        if type(arg4) ~= "number" then
            warn("EXPLOIT: Non-number duration from " .. player.Name)
            arg4 = 1.0
        end

        -- NaN check
        if arg4 ~= arg4 then
            warn("EXPLOIT: NaN duration from " .. player.Name)
            arg4 = 1.0
        end

        -- Infinity check
        if arg4 == math.huge or arg4 == -math.huge then
            warn("EXPLOIT: Infinite duration from " .. player.Name)
            arg4 = 1.0
        end

        -- Range check
        if arg4 < 0 or arg4 > MAX_ALLOWED_DURATION then
            warn("EXPLOIT: Out-of-range duration (" .. arg4 .. ") from " .. player.Name)
            arg4 = math.clamp(arg4, 0, MAX_ALLOWED_DURATION)
        end

        -- Now safe to use arg4
        processSkill(player, arg2, arg3, arg4)
    end)
]]

print("\nV08 PoC: Client controls duration values - can send math.huge for permanent effects")

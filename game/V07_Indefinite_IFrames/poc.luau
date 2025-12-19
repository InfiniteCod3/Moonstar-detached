--[[
    V07: Indefinite IFrames - Proof of Concept

    SEVERITY: HIGH

    DESCRIPTION:
    This PoC demonstrates how applyStatus(arg1, "IFrames") is called
    without a duration parameter, creating IFrames that rely on
    external cleanup mechanisms that can fail or be bypassed.

    VULNERABILITY PATTERN:
    var3_upvw.applyStatus(arg1, "IFrames")  -- No duration!
    vs proper usage:
    var3_upvw.applyStatus(arg1, "IFrames", 1.9)  -- With duration
]]

-- ============================================
-- VULNERABLE CODE PATTERNS FROM SOURCE FILES
-- ============================================

-- From BladeStormModule_ID98.luau (Lines 121-127):
--[[
    if not arg1.Head:FindFirstChild("LockBV") then
        local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
        BodyVelocity.Name = "LockBV"
        BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        table.insert(tbl_upvr_2, var3_upvw.applyStatus(arg1, "IFrames"))  -- NO DURATION!
    end
]]

-- From BladeStormModule_ID98.luau (Lines 199-202):
--[[
    table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "GlobalCD"))
    table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "Freeze"))
    table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames"))  -- NO DURATION!
    table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "AutoRotate"))
]]

-- From BlinkStrikeModule_ID106.luau (Lines 166-172):
--[[
    if not arg1.Head:FindFirstChild("LockBV") then
        local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
        BodyVelocity.Name = "LockBV"
        BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames"))  -- NO DURATION!
    end
]]

-- CLEANUP MECHANISM THAT CAN FAIL
-- From BladeStormModule_ID98.luau (Lines 128-146):
--[[
    task.delay(0.3, function()
        var33_upvw -= 1
        if var33_upvw <= 0 then
            for _, v in tbl_upvr_2 do
                var3_upvw.applyDebris(v, 0)  -- Cleanup depends on this running
            end
            for _, v_2 in arg1.Head:GetChildren() do
                if v_2.Name == "LockBV" then
                    v_2:Destroy()
                end
            end
        end
    end)
]]

-- ============================================
-- PROOF OF CONCEPT - INDEFINITE IFRAMES EXPLOIT
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Method 1: Exploit the counter-based cleanup
local function exploitCounterBypass()
    --[[
        The cleanup mechanism uses a counter (var33_upvw):
        - teleport_upvr is called, increments counter
        - task.delay(0.3, ...) decrements counter and cleans up when <= 0

        EXPLOIT: If we can make the counter stay above 0, cleanup never happens

        Attack vectors:
        1. Call teleport rapidly to keep incrementing before decrements happen
        2. Interrupt the task.delay callback
        3. Exploit race conditions in async execution
    ]]

    print("Counter bypass: Spam skill to keep counter elevated")
end

-- Method 2: Disconnect during skill execution
local function exploitDisconnectTiming()
    --[[
        1. Trigger skill that applies indefinite IFrames
        2. IFrames are added to table: table.insert(tbl_upvr_2, ...)
        3. Disconnect before task.delay cleanup runs
        4. On reconnect, IFrames may still be active but cleanup table is lost

        This works because:
        - IFrames are applied immediately
        - Cleanup is scheduled for later via task.delay
        - Disconnect interrupts the cleanup
    ]]

    print("Disconnect exploit: Trigger skill, disconnect before cleanup")
end

-- Method 3: Interfere with the cleanup table
local function exploitTableManipulation()
    --[[
        The code stores IFrame references in tables (tbl_upvr_2, tbl_upvr)
        Cleanup iterates these tables to remove IFrames

        If the table reference is lost or modified:
        - Cleanup loop has nothing to iterate
        - IFrames persist

        Attack: Trigger errors in the skill code after IFrames applied
        but before table is used for cleanup
    ]]

    print("Table manipulation: Cause error to skip cleanup loop")
end

-- ============================================
-- DEMONSTRATION
-- ============================================

local function demonstrateVulnerability()
    print("=== V07: Indefinite IFrames Demonstration ===")

    print("\nVulnerable Pattern:")
    print("  var3_upvw.applyStatus(arg1, \"IFrames\")  -- No duration!")

    print("\nProper Pattern (used elsewhere):")
    print("  var3_upvw.applyStatus(arg1, \"IFrames\", 1.9)  -- With duration")

    print("\nExploit Methods:")
    print("  1. Counter bypass - Keep counter elevated to prevent cleanup")
    print("  2. Disconnect timing - Disconnect before cleanup callback runs")
    print("  3. Table manipulation - Corrupt cleanup table references")
    print("  4. Race condition - Exploit async execution order")

    print("\nImpact:")
    print("  - Permanent invincibility")
    print("  - Cannot take damage from any source")
    print("  - Complete combat immunity")

    print("\nAffected Files: 7+ modules have this pattern")
end

demonstrateVulnerability()

-- ============================================
-- DETECTION METHOD
-- ============================================
--[[
    Server-side detection for indefinite IFrames:

    local function monitorIFrames()
        local iframeTracking = {}

        -- Hook into status application
        local originalApplyStatus = var3_upvw.applyStatus
        var3_upvw.applyStatus = function(character, statusName, duration)
            if statusName == "IFrames" then
                local player = game.Players:GetPlayerFromCharacter(character)
                if player then
                    if not duration then
                        warn("WARNING: IFrames applied without duration for " .. player.Name)
                        duration = 5.0  -- Force a maximum duration
                    end

                    iframeTracking[player.UserId] = tick()

                    -- Backup cleanup
                    task.delay(10, function()
                        if iframeTracking[player.UserId] then
                            local elapsed = tick() - iframeTracking[player.UserId]
                            if elapsed > 10 then
                                warn("EXPLOIT: IFrames persisted " .. elapsed .. "s for " .. player.Name)
                                forceRemoveIFrames(character)
                            end
                        end
                    end)
                end
            end
            return originalApplyStatus(character, statusName, duration)
        end
    end
]]

print("\nV07 PoC: IFrames without duration can persist indefinitely")

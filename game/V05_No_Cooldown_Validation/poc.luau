--[[
    V05: No Cooldown Validation - Proof of Concept

    SEVERITY: HIGH

    DESCRIPTION:
    This PoC demonstrates how skill remotes can be spammed without
    cooldown enforcement because cooldowns are only defined client-side.

    VULNERABILITY PATTERN:
    - module_upvr.Cooldown = X is defined in skill modules
    - This value is never validated server-side
    - Server processes skill requests immediately without rate limiting
]]

-- Vulnerable code pattern from BladeStormModule_ID98.luau (Line 11):
-- module_upvr.Cooldown = 19
-- This cooldown is never enforced server-side

-- Vulnerable code pattern from BlinkStrikeModule_ID106.luau (Line 11):
-- module_upvr.Cooldown = 30
-- This cooldown is never enforced server-side

-- Vulnerable code pattern from RiseModule_ID84.luau (Line 11):
-- module_upvr.Cooldown = 18
-- This cooldown is never enforced server-side

-- ============================================
-- PROOF OF CONCEPT - SKILL SPAM EXPLOIT
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Get the skill remote (example paths)
local SkillRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Skills")

-- Function to spam a skill ignoring cooldown
local function spamSkill(skillName, targetCFrame)
    -- Normal cooldown would be 19-30 seconds
    -- But server doesn't validate, so we can spam

    while true do
        -- Fire skill every 0.1 seconds instead of waiting for cooldown
        SkillRemote:FireServer(skillName, targetCFrame)

        -- Bypass the client-side cooldown entirely
        -- Server has no mechanism to reject rapid requests
        task.wait(0.1) -- 10x per second instead of once per 19-30 seconds
    end
end

-- Example: Spam BladeStorm ultimate (normally 19 second cooldown)
-- spamSkill("BladeStorm", LocalPlayer.Character.HumanoidRootPart.CFrame)

-- Example: Spam BlinkStrike (normally 30 second cooldown)
-- spamSkill("BlinkStrike", LocalPlayer.Character.HumanoidRootPart.CFrame)

-- Example: Spam Rise ultimate (normally 18 second cooldown)
-- spamSkill("Rise", LocalPlayer.Character.HumanoidRootPart.CFrame)

-- ============================================
-- DETECTION INDICATORS
-- ============================================
--[[
    Server-side detection could look for:
    1. Same skill used multiple times within cooldown window
    2. Skill usage rate exceeding expected limits
    3. Missing client-side cooldown state synchronization

    Example detection:
    local lastSkillUse = {}
    local SKILL_COOLDOWNS = {
        BladeStorm = 19,
        BlinkStrike = 30,
        Rise = 18
    }

    remote.OnServerEvent:Connect(function(player, skillName, ...)
        local userId = player.UserId
        local cooldown = SKILL_COOLDOWNS[skillName]

        if lastSkillUse[userId] and lastSkillUse[userId][skillName] then
            local timeSinceLastUse = tick() - lastSkillUse[userId][skillName]
            if timeSinceLastUse < cooldown then
                warn("EXPLOIT DETECTED: Player " .. player.Name ..
                     " attempting to use " .. skillName ..
                     " before cooldown (" .. timeSinceLastUse .. "s < " .. cooldown .. "s)")
                return -- Reject the request
            end
        end

        -- Track this usage
        lastSkillUse[userId] = lastSkillUse[userId] or {}
        lastSkillUse[userId][skillName] = tick()

        -- Process the skill...
    end)
]]

print("V05 PoC: Cooldown validation is missing - skills can be spammed indefinitely")

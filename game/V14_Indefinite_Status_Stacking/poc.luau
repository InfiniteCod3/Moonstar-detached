--[[
    V14 - Indefinite Status Stacking
    Proof of Concept Exploit

    This exploit abuses skills that apply IFrames without duration,
    allowing permanent invincibility through rapid skill spam.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ClientInfo = ReplicatedStorage.Remotes.ClientInfo

-- Exploit: Spam teleport-based skills to stack IFrames indefinitely
local function stackIFrames()
    -- Skills that apply IFrames without duration during teleport
    local teleportSkills = {
        "Siphon",
        "BladeStorm",
        "FlashOverdrive",
        "QuickSteps",
        "RapidBlinks"
    }

    -- Rapidly fire multiple skills to stack status effects
    for i = 1, 10 do
        for _, skillName in ipairs(teleportSkills) do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- Each call potentially adds IFrames without proper cleanup
                ClientInfo:FireServer(skillName, char.HumanoidRootPart.CFrame)
            end
        end
        task.wait(0.05) -- Small delay to avoid rate limiting
    end
end

-- Continuous IFrame stacking for permanent invincibility
local function permanentInvincibility()
    while true do
        stackIFrames()
        task.wait(0.2) -- Refresh before they could possibly expire
    end
end

-- Exploit the counter manipulation
local function exploitCounterReset()
    --[[
        The cleanup code uses a counter:
        var33_upvw += 1 on teleport start
        var33_upvw -= 1 after delay

        By interrupting/disconnecting mid-teleport, counter never reaches 0
        and IFrames are never removed
    ]]

    local char = LocalPlayer.Character
    if not char then return end

    -- Start teleport (adds IFrame, increments counter)
    ClientInfo:FireServer("Siphon", char.HumanoidRootPart.CFrame)

    -- Immediately trigger another action that might interrupt cleanup
    task.wait(0.1)
    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame -- Force position update

    -- The delay-based cleanup may fail, leaving IFrames active
end

return {
    stackIFrames = stackIFrames,
    permanentInvincibility = permanentInvincibility,
    exploitCounterReset = exploitCounterReset
}

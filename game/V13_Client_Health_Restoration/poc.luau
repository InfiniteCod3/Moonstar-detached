--[[
    V13 - Client-Controlled Health Restoration
    Proof of Concept Exploit

    This exploit abuses the siphon/lifesteal mechanics that trust
    client-provided health values.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- The remote used for skill communication
local ClientInfo = ReplicatedStorage.Remotes.ClientInfo

-- Exploit: Send massive health restoration value
local function instantFullHeal()
    -- For BladeStorm siphon mechanic
    -- The third parameter controls health restoration amount
    local MASSIVE_HEAL = 999999

    -- Fire the siphon event with manipulated health value
    -- Normal value would be ~5-10, we send 999999
    ClientInfo:FireServer("Siphon", LocalPlayer.Character.HumanoidRootPart.CFrame, MASSIVE_HEAL)
end

-- Continuous healing exploit
local function infiniteHealth()
    while true do
        task.wait(0.1)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            instantFullHeal()
        end
    end
end

-- Usage:
-- instantFullHeal()  -- Single massive heal
-- infiniteHealth()   -- Continuous healing loop

return {
    instantFullHeal = instantFullHeal,
    infiniteHealth = infiniteHealth
}

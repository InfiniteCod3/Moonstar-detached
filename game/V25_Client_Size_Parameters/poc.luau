--[[
    V25 - Client-Controlled Size Parameters
    Proof of Concept Exploit
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientInfo = ReplicatedStorage.Remotes.ClientInfo

local function extendedRange(skillName)
    ClientInfo:FireServer(skillName, {
        SizeZ = 99999 -- Massive hitbox
    })
end

return { extendedRange = extendedRange }

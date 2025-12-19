--[[
    V27 - Animation-Marker Hijacking
    Proof of Concept Exploit
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function instantMarker()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    if humanoid then
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            track.TimePosition = track.Length -- Skip to end
        end
    end
end

return { instantMarker = instantMarker }

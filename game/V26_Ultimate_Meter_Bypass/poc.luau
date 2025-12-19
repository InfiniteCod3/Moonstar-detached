--[[
    V26 - Ultimate Meter Drain Bypass
    Proof of Concept Exploit
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function freezeUltimateMeter()
    local info = LocalPlayer.Character:FindFirstChild("Info")
    if info and info:FindFirstChild("UltimateMeter") then
        info.UltimateMeter.Value = 100 -- Keep meter full
    end
end

return { freezeUltimateMeter = freezeUltimateMeter }

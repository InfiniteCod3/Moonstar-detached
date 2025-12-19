--[[
    V23 - Client-Dictated Ability Branching
    Proof of Concept Exploit
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientInfo = ReplicatedStorage.Remotes.ClientInfo

-- Skip directly to damage phase
local function skipToPhase(skillName, targetPhase)
    ClientInfo:FireServer(skillName .. targetPhase)
end

-- Example: Skip Anguish charge time
local function instantAnguish()
    -- Skip straight to the hit phase
    ClientInfo:FireServer("Anguish", {enemyHit = true})
end

return {
    skipToPhase = skipToPhase,
    instantAnguish = instantAnguish
}

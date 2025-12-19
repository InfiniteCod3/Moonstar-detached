--[[
    V21 - Raycast Filter Bypass
    Proof of Concept Exploit

    This exploit manipulates raycast parameters to allow skills
    to hit through walls and terrain.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Find and modify the shared raycast params
local function findRaycastParams()
    -- The params are typically in the Skills utility module
    local skillsModule = nil

    -- Try to find it through character
    local char = LocalPlayer.Character
    if char then
        local serverScript = char:FindFirstChild("ServerScript")
        if serverScript then
            local skills = serverScript:FindFirstChild("Skills")
            if skills then
                skillsModule = require(skills)
            end
        end
    end

    return skillsModule
end

-- Add all map geometry to filter list (raycast ignores them)
local function enableWallhack()
    local skills = findRaycastParams()
    if not skills or not skills.raycastParams then
        print("Could not find raycastParams")
        return
    end

    -- Get current filter list
    local currentFilter = skills.raycastParams.FilterDescendantsInstances or {}

    -- Add all terrain and map parts to filter
    local newFilter = {}
    for _, item in ipairs(currentFilter) do
        table.insert(newFilter, item)
    end

    -- Add terrain
    table.insert(newFilter, Workspace.Terrain)

    -- Add map geometry (adjust folder name as needed)
    local mapFolder = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Environment")
    if mapFolder then
        table.insert(newFilter, mapFolder)
    end

    -- Add all non-character parts
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            local isCharacterPart = false
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and obj:IsDescendantOf(player.Character) then
                    isCharacterPart = true
                    break
                end
            end
            if not isCharacterPart then
                table.insert(newFilter, obj)
            end
        end
    end

    -- Apply modified filter
    skills.raycastParams.FilterDescendantsInstances = newFilter
    print("Wallhack enabled - raycasts now ignore walls")
end

-- Override raycast entirely
local function hookRaycastNoclip()
    local originalRaycast = Workspace.Raycast

    Workspace.Raycast = function(self, origin, direction, params)
        -- Create params that filter out everything except characters
        local noclipParams = RaycastParams.new()
        noclipParams.FilterType = Enum.RaycastFilterType.Whitelist

        -- Only whitelist enemy characters (so we can still hit them)
        local whitelist = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                table.insert(whitelist, player.Character)
            end
        end
        noclipParams.FilterDescendantsInstances = whitelist

        return originalRaycast(self, origin, direction, noclipParams)
    end
end

-- Restore normal raycast
local originalRaycast = Workspace.Raycast
local function restoreRaycast()
    Workspace.Raycast = originalRaycast
end

return {
    enableWallhack = enableWallhack,
    hookRaycastNoclip = hookRaycastNoclip,
    restoreRaycast = restoreRaycast,
    findRaycastParams = findRaycastParams
}

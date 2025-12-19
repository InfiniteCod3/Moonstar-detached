--[[
    V28 - Raycast Distance Spoofing
    Proof of Concept Exploit
]]

local Workspace = game:GetService("Workspace")
local originalRaycast = Workspace.Raycast

local function spoofRaycast(targetPosition)
    Workspace.Raycast = function(self, origin, direction, params)
        return {
            Position = targetPosition,
            Normal = Vector3.new(0, 1, 0),
            Instance = Workspace.Terrain
        }
    end
end

return { spoofRaycast = spoofRaycast }

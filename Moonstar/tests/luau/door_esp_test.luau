-- tests/luau/door_esp_test.luau

local CoreGui = game:GetService("CoreGui")
local existing = CoreGui:FindFirstChild("DoorESP_Menu")
if existing then
    existing:Destroy()
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local espFolder = Instance.new("Folder")
espFolder.Name = "DoorESP_Objects"
espFolder.Parent = workspace

local doorModel = Instance.new("Model")
doorModel.Name = "DoorModel"
doorModel.Parent = workspace

local doorPart = Instance.new("Part")
doorPart.Name = "Door"
doorPart.Parent = doorModel
doorPart.Attributes = {
    DoorType = "Candy"
}

local highlight = Instance.new("Highlight")
highlight.Name = "DoorESP_Highlight"
highlight.Adornee = doorPart
highlight.OutlineColor = Color3.fromRGB(255, 170, 0)
highlight.Parent = espFolder

print("ESP created for " .. doorPart:GetAttribute("DoorType") .. " door.")

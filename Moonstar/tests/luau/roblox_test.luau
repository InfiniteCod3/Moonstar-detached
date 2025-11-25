-- tests/luau/roblox_test.luau

local part = Instance.new("Part")
part.Name = "MyPart"
part.Parent = workspace

local child = game.Workspace:FindFirstChild("MyPart")
if child then
    print("Found child: " .. child.Name)
else
    print("Child not found")
end

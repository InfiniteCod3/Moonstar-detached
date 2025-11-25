-- tests/luau/remote_logger_test.luau

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function describeInstance(inst)
    local success, full = pcall(function()
        return inst.Name
    end)
    local path = success and full or inst.Name or "?"
    return string.format("%s (%s)", path, inst.ClassName)
end

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "TestEvent"
print("Created remote event: " .. describeInstance(remoteEvent))

local remoteFunction = Instance.new("RemoteFunction")
remoteFunction.Name = "TestFunction"
print("Created remote function: " .. describeInstance(remoteFunction))

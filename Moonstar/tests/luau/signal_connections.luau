-- tests/luau/signal_connections.luau
-- Tests event/signal connection patterns commonly used in Roblox

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Connection management table
local Connections = {}

local function cleanupConnections()
    for _, connection in pairs(Connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(Connections)
end

-- Player added/removed pattern
local function onPlayerAdded(player)
    print("Player joined:", player.Name)
    
    -- Nested character connection
    local charConn
    charConn = player.CharacterAdded:Connect(function(character)
        print("Character spawned:", player.Name)
        
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            local diedConn
            diedConn = humanoid.Died:Connect(function()
                print("Player died:", player.Name)
                diedConn:Disconnect()
            end)
        end
    end)
    
    Connections["char_" .. player.UserId] = charConn
end

local function onPlayerRemoving(player)
    print("Player leaving:", player.Name)
    
    local charConn = Connections["char_" .. player.UserId]
    if charConn then
        charConn:Disconnect()
        Connections["char_" .. player.UserId] = nil
    end
end

Connections.playerAdded = Players.PlayerAdded:Connect(onPlayerAdded)
Connections.playerRemoving = Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle existing players
for _, player in Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end

-- Heartbeat counter pattern
local frameCount = 0
local lastUpdate = 0

Connections.heartbeat = RunService.Heartbeat:Connect(function(deltaTime)
    frameCount = frameCount + 1
    lastUpdate = lastUpdate + deltaTime
    
    if lastUpdate >= 1 then
        print("FPS:", math.floor(frameCount / lastUpdate))
        frameCount = 0
        lastUpdate = 0
    end
end)

-- Input handling pattern
local keysPressed = {}

Connections.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysPressed[input.KeyCode] = true
        print("Key pressed:", input.KeyCode.Name)
    end
end)

Connections.inputEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysPressed[input.KeyCode] = nil
        print("Key released:", input.KeyCode.Name)
    end
end)

-- Auto-cleanup after 5 seconds (for testing)
task.delay(5, function()
    cleanupConnections()
    print("All connections cleaned up")
end)

print("Signal connection test initialized")

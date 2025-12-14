-- Lunarity Player Teleporter
-- Advanced teleportation tool with spoofing and map manipulation
-- Integrated with the Lunarity loader authentication system

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = nil
local HumanoidRootPart = nil

local LOADER_SCRIPT_ID = "teleport"
local LoaderAccess = rawget(getgenv(), "LunarityAccess")

-- Load shared UI module
local LunarityUI = loadstring(game:HttpGet("https://api.relayed.network/ui"))()
local Theme = LunarityUI.Theme
local AccentGradientSequence = LunarityUI.AccentGradientSequence
local BackgroundGradientSequence = LunarityUI.BackgroundGradientSequence
local DangerGradientSequence = LunarityUI.DangerGradientSequence

-- XOR encryption/decryption for payload obfuscation (matches loader)
local function xorCrypt(input, key)
    local output = {}
    local keyLen = #key
    for i = 1, #input do
        local keyByte = string.byte(key, ((i - 1) % keyLen) + 1)
        local inputByte = string.byte(input, i)
        output[i] = string.char(bit32.bxor(inputByte, keyByte))
    end
    return table.concat(output)
end

local function base64Encode(data)
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = {}
    local bytes = { string.byte(data, 1, #data) }
    local i = 1
    while i <= #bytes do
        local b1 = bytes[i] or 0
        local b2 = bytes[i + 1] or 0
        local b3 = bytes[i + 2] or 0
        local combined = bit32.bor(
            bit32.lshift(b1, 16),
            bit32.lshift(b2, 8),
            b3
        )
        table.insert(result, string.sub(b64chars, bit32.rshift(combined, 18) % 64 + 1, bit32.rshift(combined, 18) % 64 + 1))
        table.insert(result, string.sub(b64chars, bit32.rshift(combined, 12) % 64 + 1, bit32.rshift(combined, 12) % 64 + 1))
        if i + 1 <= #bytes then
            table.insert(result, string.sub(b64chars, bit32.rshift(combined, 6) % 64 + 1, bit32.rshift(combined, 6) % 64 + 1))
        else
            table.insert(result, "=")
        end
        if i + 2 <= #bytes then
            table.insert(result, string.sub(b64chars, combined % 64 + 1, combined % 64 + 1))
        else
            table.insert(result, "=")
        end
        i = i + 3
    end
    return table.concat(result)
end

local function encryptPayload(plainText, key)
    local encrypted = xorCrypt(plainText, key)
    return base64Encode(encrypted)
end

local HttpRequestInvoker

if typeof(http_request) == "function" then
    HttpRequestInvoker = http_request
elseif typeof(syn) == "table" and typeof(syn.request) == "function" then
    HttpRequestInvoker = syn.request
elseif typeof(request) == "function" then
    HttpRequestInvoker = request
elseif typeof(http) == "table" and typeof(http.request) == "function" then
    HttpRequestInvoker = http.request
elseif HttpService and HttpService.RequestAsync then
    HttpRequestInvoker = function(options)
        return HttpService:RequestAsync(options)
    end
end

local function setupCharacter(char)
    LocalCharacter = char
    if LocalCharacter then
        HumanoidRootPart = LocalCharacter:WaitForChild("HumanoidRootPart")
    end
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
else
    setupCharacter(LocalPlayer.CharacterAdded:Wait())
end

-- Loader whitelist validation
local function buildValidateUrl()
    if not LoaderAccess or not LoaderAccess.validatePath or not LoaderAccess.baseUrl then
        return nil
    end
    local base = LoaderAccess.baseUrl
    if base:sub(-1) == "/" then
        base = base:sub(1, -2)
    end
    return base .. LoaderAccess.validatePath
end

local function requestLoaderValidation(refresh)
    if not HttpRequestInvoker then
        return false, "No HTTP request method available"
    end

    local validateUrl = buildValidateUrl()
    if not validateUrl then
        return false, "No validation endpoint configured"
    end

    local payload = {
        token = LoaderAccess.token,
        scriptId = LOADER_SCRIPT_ID,
        refresh = refresh
    }

    local bodyJson = HttpService:JSONEncode(payload)

    -- Encrypt the payload if encryption key is available
    local requestBody = bodyJson
    if LoaderAccess.encryptionKey then
        requestBody = encryptPayload(bodyJson, LoaderAccess.encryptionKey)
    end

    local success, response = pcall(HttpRequestInvoker, {
        Url = validateUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["User-Agent"] = LoaderAccess.userAgent or "LunarityLoader/1.0",
        },
        Body = requestBody
    })

    if not success or not response or not response.Body then
        return false, "No response from validation endpoint"
    end

    local decodeOk, decoded = pcall(HttpService.JSONDecode, HttpService, response.Body)
    if not decodeOk or not decoded.ok then
        return false, decoded and decoded.reason or "Validation failed"
    end

    -- Dynamic token rotation: update the token if a new one was provided
    if decoded.newToken and typeof(decoded.newToken) == "string" then
        LoaderAccess.token = decoded.newToken
    end

    return true, decoded
end

local function enforceLoaderWhitelist()
    if not LoaderAccess then
        warn("[Teleport] Not loaded via official loader - executing anyway")
        return true
    end

    if LoaderAccess.scriptId ~= LOADER_SCRIPT_ID then
        warn("[Teleport] Loader access token mismatch")
    end

    task.spawn(function()
        while true do
            local ok, result = requestLoaderValidation(true)
            if not ok then
                warn("[Teleport] Session validation failed:", result)
            end
            task.wait(30)
        end
    end)

    return true
end

if not enforceLoaderWhitelist() then
    return
end

local Welds = ReplicatedStorage.Remotes.Welds

local selectedPlayer = nil
local spoofPlayer = nil
local teleportCount = 0
local useSpoofing = false

-- Create main window using LunarityUI
local window = LunarityUI.CreateWindow({
    Name = "LunarityTeleportGUI",
    Title = "Lunarity",
    Subtitle = "Teleporter",
    Size = UDim2.new(0, 380, 0, 520),
    Position = UDim2.new(0.5, -190, 0.5, -260),
})

local Theme = LunarityUI.Theme

-- Forward declarations
local updatePlayerList
local teleportEveryone
local teleportMapParts

-- Spoofing Toggle
local spoofToggle = window.createLargeToggle("Spoofing", false, function(state)
    useSpoofing = state
    if not state then
        spoofPlayer = nil
    end
    updatePlayerList()
end)

-- Spoof Label
local spoofLabel = window.createLabelValue("Spoof as", "None", Theme.TextDim)

window.createSeparator()

-- Target Label
local targetLabel = window.createLabelValue("Target", "None (Press E to teleport everyone)", Theme.TextDim)

window.createSeparator()

-- Teleport Everyone Button
window.createActionButton("TELEPORT EVERYONE (E)", nil, function()
    teleportEveryone()
end)

-- Teleport Map Parts Button
window.createButton("Teleport Map Parts", function()
    teleportMapParts()
end, false)

window.createSeparator()
window.createSection("Select Player")

-- Player List
local playerList = window.createPlayerList("Players", 220, 
    function(player)  -- Left click = select target
        if selectedPlayer == player then
            selectedPlayer = nil
        else
            selectedPlayer = player
        end
        updatePlayerList()
    end,
    function(player)  -- Right click = select spoof target
        if useSpoofing then
            if spoofPlayer == player then
                spoofPlayer = nil
            else
                spoofPlayer = player
            end
            updatePlayerList()
        end
    end
)

window.createSeparator()
window.createInfoLabel("Left-click: target. Right-click (spoof ON): spoof identity. E: teleport.")

-- Function to update player list
updatePlayerList = function()
    -- Update labels
    if selectedPlayer and selectedPlayer.Parent then
        targetLabel.setValue(selectedPlayer.Name .. " (Press E)", Theme.Success)
    else
        selectedPlayer = nil
        targetLabel.setValue("None (Press E for everyone)", Theme.TextDim)
    end
    
    if useSpoofing and spoofPlayer and spoofPlayer.Parent then
        spoofLabel.setValue(spoofPlayer.Name, Theme.Accent)
    else
        spoofPlayer = nil
        spoofLabel.setValue("None", Theme.TextDim)
    end
    
    -- Refresh player list
    playerList.refresh(
        function(player) return selectedPlayer == player end,
        function(player) return useSpoofing and spoofPlayer == player end
    )
end

local function teleportPlayerToYou(targetPlayer, useSpoof)
    if not HumanoidRootPart or not HumanoidRootPart.Parent then
        return false
    end

    if not targetPlayer or not targetPlayer.Character then
        return false
    end
    
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then
        return false
    end
    
    local TARGET_CFRAME = HumanoidRootPart.CFrame
    local sourceHRP = HumanoidRootPart
    
    if useSpoof and useSpoofing and spoofPlayer and spoofPlayer.Parent and spoofPlayer.Character then
        local spoofHRP = spoofPlayer.Character:FindFirstChild("HumanoidRootPart")
        if spoofHRP then
            sourceHRP = spoofHRP
        end
    end
    
    local success = pcall(function()
        Welds:FireServer(
            sourceHRP,
            targetHRP,
            TARGET_CFRAME,
            Vector3.new(0, 0, 0),
            CFrame.new(0, 0, 0)
        )
    end)
    
    if success then
        teleportCount = teleportCount + 1
        return true
    else
        return false
    end
end

teleportEveryone = function()
    local count = 0
    local failed = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if teleportPlayerToYou(player, true) then
                count = count + 1
            else
                failed = failed + 1
            end
            task.wait(0.1)
        end
    end
end

teleportMapParts = function()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then
        return
    end

    local targetCFrame = HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
    local partsMoved = 0
    local sourceHRP = HumanoidRootPart

    for _, instance in pairs(Workspace:GetChildren()) do
        if not (Players:GetPlayerFromCharacter(instance) or 
           instance:IsA("Terrain") or 
           instance.Name == "Camera" or 
           instance == LocalCharacter or
           instance.Name:lower() == "baseplate") then
        
            local targetPart = nil

            if instance:IsA("BasePart") then
                targetPart = instance
            elseif instance:IsA("Model") and instance.PrimaryPart and instance.PrimaryPart:IsA("BasePart") then
                targetPart = instance.PrimaryPart
            end

            if targetPart then
                local success = pcall(function()
                    Welds:FireServer(
                        sourceHRP,
                        targetPart,
                        targetCFrame,
                        Vector3.new(0, 0, 0),
                        CFrame.new(0, 0, 0)
                    )
                end)
                
                if success then
                    partsMoved = partsMoved + 1
                end
                task.wait(0.05)
            end
        end
    end
end

-- Auto-refresh player list
task.spawn(function()
    while task.wait(2) do
        updatePlayerList()
    end
end)

-- Keybind handler
window.addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        if selectedPlayer then
            teleportPlayerToYou(selectedPlayer, true)
        else
            teleportEveryone()
        end
    end
end))

-- Initial refresh
updatePlayerList()
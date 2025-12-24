local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local LoaderAccess = rawget(getgenv(), "LunarityAccess")
local LOADER_SCRIPT_ID = (LoaderAccess and LoaderAccess.scriptId) or "lunarity"

-- // ============================
-- // AUTHENTICATION / LOADER PROTECTION
-- // ============================

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

do
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

    local function buildValidateUrl()
        if not LoaderAccess then
            return nil
        end
        if typeof(LoaderAccess.validateUrl) == "string" then
            return LoaderAccess.validateUrl
        elseif typeof(LoaderAccess.baseUrl) == "string" then
            return LoaderAccess.baseUrl .. "/validate"
        end
        return nil
    end

    local function requestLoaderValidation(refresh)
        if not LoaderAccess then
            return false, "Loader access token missing"
        end
        if not HttpRequestInvoker then
            return false, "Executor lacks HTTP support"
        end
        local validateUrl = buildValidateUrl()
        if not validateUrl then
            return false, "Validation endpoint unavailable"
        end

        local payload = {
            token = LoaderAccess.token,
            scriptId = LOADER_SCRIPT_ID,
            refresh = refresh ~= false,
        }

        local encodedOk, encodedPayload = pcall(HttpService.JSONEncode, HttpService, payload)
        if not encodedOk then
            return false, "Failed to encode validation payload"
        end

        -- Encrypt the payload if encryption key is available
        local requestBody = encodedPayload
        if LoaderAccess.encryptionKey then
            requestBody = encryptPayload(encodedPayload, LoaderAccess.encryptionKey)
        end

        local success, response = pcall(HttpRequestInvoker, {
            Url = validateUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Accept"] = "application/json",
                ["User-Agent"] = LoaderAccess.userAgent or "LunarityLoader/1.0",
            },
            Body = requestBody,
        })

        if not success then
            return false, tostring(response)
        end

        local statusCode = response.StatusCode or response.Status or response.status_code
        local bodyText = response.Body or response.body or ""
        if statusCode and (statusCode < 200 or statusCode >= 300) then
            return false, bodyText ~= "" and bodyText or ("HTTP " .. tostring(statusCode))
        end

        local decodeOk, decoded = pcall(HttpService.JSONDecode, HttpService, bodyText)
        if not decodeOk then
            return false, "Invalid JSON from worker"
        end

        if decoded.ok ~= true then
            return false, decoded.reason or "Validation denied"
        end

        -- Dynamic token rotation: update the token if a new one was provided
        if decoded.newToken and typeof(decoded.newToken) == "string" then
            LoaderAccess.token = decoded.newToken
        end

        return true, decoded
    end

    local function enforceLoaderWhitelist()
        -- Skip check if running in studio or specific test environments if needed, but here we enforce
        if not LoaderAccess then
            warn("[Lunarity] This build must be launched via the official loader.")
            return false
        end

        local ok, response = requestLoaderValidation(true)
        if not ok then
            warn("[Lunarity] Loader validation failed: " .. tostring(response))
            return false
        end

        if response.killSwitch then
            warn("[Lunarity] Loader kill switch active. Aborting.")
            return false
        end

        local refreshInterval = math.clamp(LoaderAccess.refreshInterval or 90, 30, 240)
        task.spawn(function()
            while scriptActive do
                task.wait(refreshInterval)
                local valid, data = requestLoaderValidation(true)
                if not valid or (data and data.killSwitch) then
                    warn("[Lunarity] Access revoked or kill switch activated. Shutting down.")
                    scriptActive = false
                    autofarmEnabled = false
                    -- Trigger full unload via global function if available
                    local unloadFunc = rawget(getgenv(), "_AutofarmUnload")
                    if typeof(unloadFunc) == "function" then
                        pcall(unloadFunc)
                    end
                    break
                end
            end
        end)

        getgenv().LunarityAccess = nil
        return true
    end

    if not enforceLoaderWhitelist() then
        return
    end
end

-- // ============================
-- // AUTOFARM LOGIC
-- // ============================

local autofarmEnabled = false
local antiAfkEnabled = true
local isRunning = false
local targetPlayer = nil
local targetPlayerName = "InfiniteCod3" -- Default target
local scriptActive = true

-- Performance Settings (Optional: Can be toggled via GUI later, kept static for now)
pcall(function()
    setfpscap(30) -- Set FPS cap to 30

    local UserGameSettings = UserSettings():GetService("UserGameSettings")
    UserGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    UserGameSettings.GraphicsQualityLevel = 1

    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.Technology = Enum.Technology.Compatibility
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then effect.Enabled = false end
    end

    workspace.StreamingEnabled = false
    workspace.Terrain.WaterWaveSize = 0
    workspace.Terrain.WaterWaveSpeed = 0
    workspace.Terrain.WaterReflectance = 0
    workspace.Terrain.WaterTransparency = 1

    -- Disable 3D Rendering to save resources
    RunService:Set3dRenderingEnabled(false)
end)

-- Variables for Autofarm
local VOID_POSITION = Vector3.new(-22517, -130, -10235)
local TELEPORT_DELAY = 2
local MAX_TIMEOUT = 30
local DAMAGE_THRESHOLD = 5
local AFK_PREVENTION_INTERVAL = 15
local VOID_DEATH_TIMEOUT = 2
local MAX_VOID_RETRIES = 3

local damageRemote = ReplicatedStorage:FindFirstChild("Damage")
local knockbackRemote = ReplicatedStorage:FindFirstChild("Knockback")
local statusRemote = ReplicatedStorage:FindFirstChild("Status")

-- State variables
local hasBeenHit = false
local damageDetected = false
local healthConnection = nil
local damageConnection = nil
local knockbackConnection = nil
local lastAfkAction = 0

-- Helper Functions
local function getCharacterAndHumanoid(player)
    if not player or not player.Character then return nil, nil, nil end
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoid and rootPart then return character, humanoid, rootPart end
    return nil, nil, nil
end

local function teleportTo(position)
    local character, humanoid, rootPart = getCharacterAndHumanoid(LocalPlayer)
    if rootPart then
        rootPart.CFrame = CFrame.new(position)
        return true
    end
    return false
end

local function findTargetPlayer()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == targetPlayerName then
            return player
        end
    end
    return nil
end

-- Anti-AFK (Replaced with method from brah.lua)
local VirtualUser = game:GetService("VirtualUser")
local function performAntiAfkAction()
    if not antiAfkEnabled then return end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

LocalPlayer.Idled:Connect(function()
    if antiAfkEnabled then
        performAntiAfkAction()
    end
end)

-- Legacy Anti-AFK Loop removal
-- spawn(function()
--     while scriptActive do
--         wait(AFK_PREVENTION_INTERVAL)
--         if antiAfkEnabled then performAntiAfkAction() end
--     end
-- end)

-- Damage Detection
local function setupDamageDetection()
    local character, humanoid, rootPart = getCharacterAndHumanoid(LocalPlayer)
    if not humanoid then return false end

    local initialHealth = humanoid.Health

    healthConnection = humanoid.HealthChanged:Connect(function(health)
        if initialHealth and health < initialHealth - DAMAGE_THRESHOLD then
            hasBeenHit = true
            damageDetected = true
        end
    end)

    if damageRemote then
        damageConnection = damageRemote.OnClientEvent:Connect(function()
            hasBeenHit = true
            damageDetected = true
        end)
    end

    if knockbackRemote then
        knockbackConnection = knockbackRemote.OnClientEvent:Connect(function()
            hasBeenHit = true
            damageDetected = true
        end)
    end
    return true
end

local function cleanupDamageDetection()
    if healthConnection then healthConnection:Disconnect(); healthConnection = nil end
    if damageConnection then damageConnection:Disconnect(); damageConnection = nil end
    if knockbackConnection then knockbackConnection:Disconnect(); knockbackConnection = nil end
end

local function teleportToTarget()
    if not targetPlayer then return false end
    local targetCharacter, targetHumanoid, targetRootPart = getCharacterAndHumanoid(targetPlayer)
    if not targetRootPart then return false end
    return teleportTo(targetRootPart.Position + Vector3.new(0, 5, 0))
end

local function teleportToVoidWithRetry()
    local retryCount = 0
    while retryCount < MAX_VOID_RETRIES do
        teleportTo(VOID_POSITION)
        local character, humanoid, rootPart = getCharacterAndHumanoid(LocalPlayer)
        if not humanoid then return end

        local startHealth = humanoid.Health
        local startTime = tick()
        while tick() - startTime < VOID_DEATH_TIMEOUT do
            wait(0.1)
            if humanoid.Health <= 0 or not LocalPlayer.Character then return end
        end
        retryCount = retryCount + 1
    end
end

local function autofarm()
    if not autofarmEnabled then return end

    hasBeenHit = false
    damageDetected = false

    if isRunning then return end
    isRunning = true

    targetPlayer = findTargetPlayer()

    -- Wait for target if not found
    if not targetPlayer then
        local found = false
        local connection
        connection = Players.PlayerAdded:Connect(function(player)
            if player.Name == targetPlayerName then
                targetPlayer = player
                found = true
                connection:Disconnect()
            end
        end)

        local waitTime = 0
        repeat
            wait(1)
            waitTime = waitTime + 1
            if not targetPlayer then targetPlayer = findTargetPlayer() end
        until targetPlayer or not autofarmEnabled or waitTime > 60

        if connection then connection:Disconnect() end
    end

    if not targetPlayer or not autofarmEnabled then
        isRunning = false
        return
    end

    -- Wait for target character
    repeat
        wait(0.5)
    until (targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")) or not autofarmEnabled

    if not autofarmEnabled then isRunning = false; return end

    if not teleportToTarget() then
        isRunning = false
        return
    end

    wait(TELEPORT_DELAY)

    if not setupDamageDetection() then
        isRunning = false
        return
    end

    local timeoutCounter = 0
    repeat
        wait(0.1)
        timeoutCounter = timeoutCounter + 0.1
    until hasBeenHit or timeoutCounter >= MAX_TIMEOUT or not autofarmEnabled

    cleanupDamageDetection()

    if autofarmEnabled then
        wait(0.5)
        teleportToVoidWithRetry()
    end

    isRunning = false
end

-- Respawn loop
local function onRespawn(character)
    if not autofarmEnabled then return end
    wait(2)
    pcall(autofarm)
end

LocalPlayer.CharacterAdded:Connect(onRespawn)
if LocalPlayer.Character and autofarmEnabled then
    onRespawn(LocalPlayer.Character)
end

-- // ============================
-- // GUI IMPLEMENTATION
-- // ============================

-- Load shared UI module
local LunarityUI = loadstring(game:HttpGet("https://api.relayed.network/ui"))()
local Theme = LunarityUI.Theme

local loadingScreen = LunarityUI.CreateLoadingScreen({
    Name = "LunarityAutofarmLoading",
    Title = "Lunarity Autofarm"
})

-- Create the main window
local mainWindow = LunarityUI.CreateWindow({
    Name = "LunarityAutofarmGUI",
    Title = "Lunarity",
    Subtitle = "Autofarm",
    Size = UDim2.new(0, 320, 0, 400),
    Position = UDim2.new(0.5, -160, 0.5, -200),
    Closable = true,
    Minimizable = true,
    OnClose = function()
        scriptActive = false
        autofarmEnabled = false
        cleanupDamageDetection()
    end
})

mainWindow.ScreenGui.Enabled = false -- Hide initially

-- Create Status Panel
local statusPanel = LunarityUI.CreatePanel({
    Name = "LunarityStatusPanel",
    Size = UDim2.new(0, 200, 0, 80),
    Position = UDim2.new(1, -210, 0, 10)
})
statusPanel.ScreenGui.Enabled = false

local autofarmRow = statusPanel.addKeybindRow(Enum.KeyCode.Unknown, "Autofarm", autofarmEnabled)
local antiAfkRow = statusPanel.addKeybindRow(Enum.KeyCode.Unknown, "Anti-AFK", antiAfkEnabled)

-- Autofarm Section
mainWindow.createSection("Controls")

local autofarmToggle = mainWindow.createLargeToggle("Autofarm", autofarmEnabled, function(state)
    autofarmEnabled = state
    autofarmRow.setStatus(state)
    if state and LocalPlayer.Character then
        task.spawn(function()
            if not isRunning then
                autofarm()
            end
        end)
    else
        isRunning = false
        cleanupDamageDetection()
    end
end)

local antiAfkToggle = mainWindow.createToggle("Anti-AFK", antiAfkEnabled, function(state)
    antiAfkEnabled = state
    antiAfkRow.setStatus(state)
end)

mainWindow.createSeparator()

-- Target Section
mainWindow.createSection("Target Settings")

local targetInput = mainWindow.createTextBox(targetPlayerName, function(text)
    if text and text ~= "" then
        targetPlayerName = text
        -- If running, maybe restart or just let it pick up next cycle
        targetPlayer = findTargetPlayer()
    end
end)
targetInput.setText(targetPlayerName)

mainWindow.createLabelValue("Current Target", targetPlayerName).setValue(targetPlayerName)

-- Player List for selection
mainWindow.createSection("Select Target")

local playerList
playerList = mainWindow.createPlayerList("Players", 150, function(player)
    targetPlayerName = player.Name
    targetInput.setText(player.Name)
    targetPlayer = player
    -- Refresh list to show selection
    playerList.refresh(
        function(p) return p.Name == targetPlayerName end
    )
end)

-- Initial refresh of player list
playerList.refresh(function(p) return p.Name == targetPlayerName end)

-- Refresh list occasionally or on button press
mainWindow.createButton("Refresh Player List", function()
    playerList.refresh(function(p) return p.Name == targetPlayerName end)
end)

mainWindow.createSeparator()

-- Settings / Info
mainWindow.createSection("Status")
local statusLabel = mainWindow.createLabelValue("State", "Idle", Theme.TextDim)

-- Update status label loop
task.spawn(function()
    while scriptActive do
        local stateText = "Idle"
        local color = Theme.TextDim

        if autofarmEnabled then
            if isRunning then
                stateText = "Running"
                color = Theme.Success
            else
                stateText = "Waiting..."
                color = Theme.Warning
            end
        else
            stateText = "Disabled"
            color = Theme.Error
        end

        statusLabel.setValue(stateText, color)
        wait(0.5)
    end
end)


-- Animate loading screen
loadingScreen.animate({
    {text = "Authenticating...", progress = 0.3, time = 0.5},
    {text = "Loading Autofarm...", progress = 0.6, time = 0.5},
    {text = "Initializing GUI...", progress = 0.9, time = 0.5},
    {text = "Ready!", progress = 1.0, time = 0.3}
}, function()
    mainWindow.ScreenGui.Enabled = true
    statusPanel.ScreenGui.Enabled = true
end)

-- Register global unload function for killswitch cleanup
rawset(getgenv(), "_AutofarmUnload", function()
    scriptActive = false
    autofarmEnabled = false
    cleanupDamageDetection()
    pcall(function() mainWindow.destroy() end)
    pcall(function() statusPanel.destroy() end)
    rawset(getgenv(), "_AutofarmUnload", nil)
end)

-- Clean up on player removing
Players.PlayerRemoving:Connect(function(player)
    if player.Name == targetPlayerName then
        targetPlayer = nil
    end
end)

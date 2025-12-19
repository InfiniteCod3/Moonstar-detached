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
local LOADER_SCRIPT_ID = "autofarm"
local LoaderAccess = rawget(getgenv(), "LunarityAccess")
local ScriptActive = true

-- // ===========================
-- // AUTHENTICATION & BOILERPLATE
-- // ===========================

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
        if not LoaderAccess or LoaderAccess.scriptId ~= LOADER_SCRIPT_ID then
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
            while ScriptActive do
                task.wait(refreshInterval)
                local valid, data = requestLoaderValidation(true)
                if not valid or (data and data.killSwitch) then
                    warn("[Lunarity] Access revoked or kill switch activated. Shutting down.")
                    ScriptActive = false
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

-- // ===========================
-- // SCRIPT LOGIC
-- // ===========================

-- Load shared UI module
local LunarityUI = loadstring(game:HttpGet("https://api.relayed.network/ui"))()
local Theme = LunarityUI.Theme

-- Performance Optimization (Optional)
pcall(function()
    setfpscap(60)
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.Technology = Enum.Technology.Compatibility
end)

local VOID_POSITION = Vector3.new(-22517, -130, -10235)
local damageRemote = ReplicatedStorage:FindFirstChild("Damage")
local knockbackRemote = ReplicatedStorage:FindFirstChild("Knockback")
local statusRemote = ReplicatedStorage:FindFirstChild("Status")

local TELEPORT_DELAY = 2
local MAX_TIMEOUT = 30
local DAMAGE_THRESHOLD = 5
local AFK_PREVENTION_INTERVAL = 15
local VOID_DEATH_TIMEOUT = 2
local MAX_VOID_RETRIES = 3

local isRunning = false
local targetPlayer = nil
local targetPlayerName = ""
local initialHealth = nil
local hasBeenHit = false
local damageDetected = false
local healthConnection = nil
local damageConnection = nil
local knockbackConnection = nil
local autofarmEnabled = false
local antiAfkEnabled = true
local lastAfkAction = 0

-- UI Variables
local statusLabel
local targetLabel
local toggleBtn
local mainWindow

local function getCharacterAndHumanoid(player)
    if not player or not player.Character then
        return nil, nil
    end

    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if humanoid and rootPart then
        return character, humanoid, rootPart
    end

    return nil, nil, nil
end

local function performAntiAfkAction()
    if not antiAfkEnabled then return end

    local currentTime = tick()
    if currentTime - lastAfkAction < AFK_PREVENTION_INTERVAL then return end

    pcall(function()
        local character, humanoid, rootPart = getCharacterAndHumanoid(LocalPlayer)
        if not character or not humanoid or not rootPart then return end

        local currentCFrame = rootPart.CFrame
        local randomOffset = Vector3.new(
            math.random(-1, 1) * 0.1,
            0,
            math.random(-1, 1) * 0.1
        )
        rootPart.CFrame = currentCFrame + randomOffset
        task.wait(0.1)
        rootPart.CFrame = currentCFrame

        if humanoid and humanoid.Health > 0 then
            humanoid.Jump = true
            task.wait(0.1)
            humanoid.Jump = false
        end

        pcall(function()
            if statusRemote then
                statusRemote:FireServer()
            end
        end)

        lastAfkAction = currentTime
    end)
end

task.spawn(function()
    while ScriptActive do
        task.wait(AFK_PREVENTION_INTERVAL)
        if antiAfkEnabled and ScriptActive then
            performAntiAfkAction()
        end
    end
end)

local function teleportTo(position)
    local character, humanoid, rootPart = getCharacterAndHumanoid(LocalPlayer)
    if rootPart then
        rootPart.CFrame = CFrame.new(position)
        return true
    else
        return false
    end
end

local function findTargetPlayer()
    if targetPlayerName == "" then return nil end
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == targetPlayerName or player.DisplayName == targetPlayerName then
            return player
        end
        -- Partial match support
        if string.find(string.lower(player.Name), string.lower(targetPlayerName)) then
            targetPlayerName = player.Name -- Auto-correct name
            return player
        end
    end
    return nil
end

local function setupDamageDetection()
    local character, humanoid, rootPart = getCharacterAndHumanoid(LocalPlayer)
    if not humanoid then
        return false
    end

    initialHealth = humanoid.Health

    healthConnection = humanoid.HealthChanged:Connect(function(health)
        if initialHealth and health < initialHealth - DAMAGE_THRESHOLD then
            hasBeenHit = true
            damageDetected = true
        end
    end)

    if damageRemote then
        damageConnection = damageRemote.OnClientEvent:Connect(function(...)
            hasBeenHit = true
            damageDetected = true
        end)
    end

    if knockbackRemote then
        knockbackConnection = knockbackRemote.OnClientEvent:Connect(function(...)
            hasBeenHit = true
            damageDetected = true
        end)
    end

    return true
end

local function cleanupDamageDetection()
    if healthConnection then
        healthConnection:Disconnect()
        healthConnection = nil
    end
    if damageConnection then
        damageConnection:Disconnect()
        damageConnection = nil
    end
    if knockbackConnection then
        knockbackConnection:Disconnect()
        knockbackConnection = nil
    end
end

local function teleportToTarget()
    if not targetPlayer then
        return false
    end

    local targetCharacter, targetHumanoid, targetRootPart = getCharacterAndHumanoid(targetPlayer)
    if not targetRootPart then
        return false
    end

    local targetPosition = targetRootPart.Position + Vector3.new(0, 5, 0)
    return teleportTo(targetPosition)
end

local function teleportToVoidWithRetry()
    local retryCount = 0
    local died = false

    while retryCount < MAX_VOID_RETRIES do
        updateStatusText("Voiding (Attempt " .. (retryCount + 1) .. ")", Theme.Danger)
        teleportTo(VOID_POSITION)

        local character, humanoid, rootPart = getCharacterAndHumanoid(LocalPlayer)
        if not humanoid then
            return
        end

        local startTime = tick()

        while tick() - startTime < VOID_DEATH_TIMEOUT do
            task.wait(0.1)
            if humanoid.Health <= 0 or not LocalPlayer.Character then
                died = true
                break
            end
        end

        if died then
            return
        end

        retryCount = retryCount + 1
    end

    if not died then
        updateStatusText("Void Failed, Returning to Target", Theme.Warning)
        teleportToTarget()
    end
end

local function updateStatusText(text, color)
    if statusLabel then
        statusLabel.setValue(text, color)
    end
end

local function autofarm()
    if not autofarmEnabled then
        return
    end

    hasBeenHit = false
    damageDetected = false

    if isRunning then
        return
    end

    isRunning = true
    updateStatusText("Running", Theme.Accent)

    targetPlayer = findTargetPlayer()

    if not targetPlayer then
        updateStatusText("Waiting for Target...", Theme.Warning)
        local playerAddedConnection
        playerAddedConnection = Players.PlayerAdded:Connect(function(player)
            if player.Name == targetPlayerName then
                targetPlayer = player
                playerAddedConnection:Disconnect()
            end
        end)

        repeat
            task.wait(1)
            if not targetPlayer then
                targetPlayer = findTargetPlayer()
            end
            if not autofarmEnabled or not ScriptActive then
                isRunning = false
                return
            end
        until targetPlayer
    end

    if targetLabel then
        targetLabel.setValue(targetPlayer.Name, Theme.Text)
    end

    updateStatusText("Waiting for Target Character", Theme.Warning)
    repeat
        task.wait(0.5)
        if not autofarmEnabled or not ScriptActive then
            isRunning = false
            return
        end
    until targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")

    updateStatusText("Teleporting to Target", Theme.Accent)
    if not teleportToTarget() then
        isRunning = false
        updateStatusText("Teleport Failed", Theme.Error)
        return
    end

    task.wait(TELEPORT_DELAY)

    updateStatusText("Waiting for Hit", Theme.Warning)
    if not setupDamageDetection() then
        isRunning = false
        updateStatusText("Setup Failed", Theme.Error)
        return
    end

    local timeoutCounter = 0
    repeat
        task.wait(0.1)
        timeoutCounter = timeoutCounter + 0.1
    until hasBeenHit or timeoutCounter >= MAX_TIMEOUT or not autofarmEnabled or not ScriptActive

    cleanupDamageDetection()

    if not autofarmEnabled or not ScriptActive then
        isRunning = false
        return
    end

    updateStatusText("Voiding...", Theme.Danger)
    task.wait(0.5)
    teleportToVoidWithRetry()

    updateStatusText("Cycle Complete", Theme.Success)
    isRunning = false
end

Players.PlayerRemoving:Connect(function(player)
    if player.Name == targetPlayerName then
        targetPlayer = nil
        if targetLabel then
            targetLabel.setValue("None", Theme.TextDim)
        end
    end
end)

local function onRespawn(character)
    if not autofarmEnabled or not ScriptActive then
        return
    end

    task.wait(2)
    local humanoid = character:WaitForChild("Humanoid", 10)
    pcall(autofarm)
end

LocalPlayer.CharacterAdded:Connect(onRespawn)

-- // ===========================
-- // GUI CREATION
-- // ===========================

mainWindow = LunarityUI.CreateWindow({
    Name = "LunarityAutofarm",
    Title = "Lunarity",
    Subtitle = "Autofarm",
    Size = UDim2.new(0, 320, 0, 420),
    Position = UDim2.new(0.5, -160, 0.5, -210),
    Closable = true,
    OnClose = function()
        ScriptActive = false
        autofarmEnabled = false
        cleanupDamageDetection()
    end
})

mainWindow.createSection("Target Selection")

local targetInput = mainWindow.createTextBox("Enter username...", function(text)
    targetPlayerName = text
    local player = findTargetPlayer()
    if player then
        targetPlayer = player
        targetLabel.setValue(player.Name, Theme.Text)
    else
        targetLabel.setValue("Not Found", Theme.Warning)
    end
end)

targetLabel = mainWindow.createLabelValue("Current Target", "None", Theme.TextDim)

mainWindow.createSection("Controls")

toggleBtn = mainWindow.createLargeToggle("Autofarm", false, function(state)
    autofarmEnabled = state
    if state then
        if targetPlayerName == "" then
            autofarmEnabled = false
            toggleBtn.setState(false)
            updateStatusText("Set Target First", Theme.Error)
            return
        end
        if LocalPlayer.Character then
            task.spawn(autofarm)
        end
    else
        isRunning = false
        cleanupDamageDetection()
        updateStatusText("Stopped", Theme.TextDim)
    end
end)

mainWindow.createToggle("Anti-AFK", antiAfkEnabled, function(state)
    antiAfkEnabled = state
end)

mainWindow.createSection("Status")
statusLabel = mainWindow.createLabelValue("Status", "Idle", Theme.TextDim)

mainWindow.createSeparator()

mainWindow.createButton("Emergency Stop", function()
    autofarmEnabled = false
    toggleBtn.setState(false)
    isRunning = false
    cleanupDamageDetection()
    updateStatusText("Emergency Stop", Theme.Error)
end, false)

mainWindow.createButton("Unload", function()
    ScriptActive = false
    autofarmEnabled = false
    cleanupDamageDetection()
    if mainWindow then
        mainWindow.destroy()
    end
end, false)

updateStatusText("Ready", Theme.TextDim)

if LocalPlayer.Character and autofarmEnabled then
    onRespawn(LocalPlayer.Character)
end

print("[Lunarity] Autofarm script loaded successfully")

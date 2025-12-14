local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local LOADER_SCRIPT_ID = "lunarity"
local LoaderAccess = rawget(getgenv(), "LunarityAccess")

local StatusRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Status")

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

-- Persistent Settings System
local SETTINGS_KEY = "Lunarity_Settings_V1"

local function getKeyNameOrDefault(keyCode, defaultName)
    if typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode then
        return keyCode.Name
    end
    return defaultName
end

local function resolveKeyCode(value, defaultKeyCode)
    if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
        return value
    elseif typeof(value) == "string" then
        local enumValue = Enum.KeyCode[value]
        if enumValue then
            return enumValue
        end
    end
    return defaultKeyCode
end

local function saveSettings()
    local settings = {
        IFramesEnabled = IFramesEnabled,
        AntiDebuffEnabled = AntiDebuffEnabled,
        IFramesKeybind = getKeyNameOrDefault(IFramesKeybind, "One"),
        AntiDebuffKeybind = getKeyNameOrDefault(AntiDebuffKeybind, "Two"),
        ToggleKeybindUIKeybind = getKeyNameOrDefault(ToggleKeybindUIKeybind, "F1"),
        IFramesDuration = IFramesDuration,
        isInfiniteDuration = isInfiniteDuration
    }
    
    local HttpService = game:GetService("HttpService")
    local success, err = pcall(function()
        local jsonData = HttpService:JSONEncode(settings)
        if writefile then
            writefile(SETTINGS_KEY .. ".json", jsonData)
        end
    end)
    
    if not success then
        warn("Failed to save settings:", err)
    end
end

local function loadSettings()
    local HttpService = game:GetService("HttpService")
    local success, result = pcall(function()
        if isfile and readfile and isfile(SETTINGS_KEY .. ".json") then
            local jsonData = readfile(SETTINGS_KEY .. ".json")
            return HttpService:JSONDecode(jsonData)
        end
        return nil
    end)
    
    if success and result then
        return result
    end
    return nil
end

-- Load saved settings or use defaults
local savedSettings = loadSettings()

local IFramesEnabled = false
local AntiDebuffEnabled = true
local ScriptActive = true
local GuiVisible = true
local KeybindUIVisible = true

local IFramesKeybind = Enum.KeyCode.One
local AntiDebuffKeybind = Enum.KeyCode.Two
local ToggleGuiKeybind = Enum.KeyCode.P
local ToggleKeybindUIKeybind = Enum.KeyCode.F1

local IFramesDuration = 2
local isInfiniteDuration = true

-- Apply saved settings
if savedSettings then
    IFramesEnabled = savedSettings.IFramesEnabled or false
    AntiDebuffEnabled = savedSettings.AntiDebuffEnabled ~= nil and savedSettings.AntiDebuffEnabled or true
    IFramesDuration = savedSettings.IFramesDuration or 2
    isInfiniteDuration = savedSettings.isInfiniteDuration ~= nil and savedSettings.isInfiniteDuration or true

    -- Load keybinds
    IFramesKeybind = resolveKeyCode(savedSettings.IFramesKeybind, Enum.KeyCode.One)
    AntiDebuffKeybind = resolveKeyCode(savedSettings.AntiDebuffKeybind, Enum.KeyCode.Two)
    ToggleKeybindUIKeybind = resolveKeyCode(savedSettings.ToggleKeybindUIKeybind, Enum.KeyCode.F1)
end

local ScriptActive = true

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

-- // ============================
-- // SCRIPT FUNCTIONALITY STARTS HERE
-- // ============================

local Authorized = true
local AuthorizationMessage = "Loaded via official loader"

local StatusRemoteConnection = nil

local DEBUFF_BLACKLIST = {
    ["Stunned"] = true,
    ["Freeze"] = true,
    ["Ragdoll"] = true,
    ["Slowed"] = true,
}

local function apply_status(statusName, duration)
    if not StatusRemote then return end
    
    local args = {
        ApplyStatus = true,
        Status = statusName,
        Length = duration
    }
    StatusRemote:FireServer(args)
end

local function remove_status(statusIndex)
    if not StatusRemote then return end
    
    local args = {
        RemoveStatus = true,
        StatusIndex = statusIndex
    }
    StatusRemote:FireServer(args)
end

spawn(function()
    while ScriptActive do
        if IFramesEnabled and ScriptActive then
            if isInfiniteDuration then
                apply_status("IFrames", 2)
                task.wait(1.5)
            else
                apply_status("IFrames", IFramesDuration)

                task.wait(IFramesDuration)
                if IFramesEnabled and ScriptActive then
                    IFramesEnabled = false
                    updateIFramesButton()

                end
            end
        else
            task.wait(0.1)
        end
    end
end)

StatusRemoteConnection = StatusRemote.OnClientEvent:Connect(function(statusTable)
    if not AntiDebuffEnabled or not ScriptActive then return end
    
    if type(statusTable) == "table" then
        for index, statusName in pairs(statusTable) do
            if DEBUFF_BLACKLIST[statusName] then
                remove_status(index)
            end
        end
    end
end)

-- =============================================
-- GUI CREATION USING LunarityUI MODULE
-- =============================================

-- Forward declarations for UI update functions
local iframesRow, antiDebuffRow, toggleGuiRow
local iframesToggle, antiDebuffToggle, durationSlider, durationModeToggle

-- Create the loading screen
local loadingScreen = LunarityUI.CreateLoadingScreen({
    Name = "LunarityLoading",
    Title = "Lunarity"
})

-- Create the keybind display panel (floating in top-right)
local keybindPanel = LunarityUI.CreatePanel({
    Name = "LunarityKeybindPanel",
    Size = UDim2.new(0, 200, 0, 100),
    Position = UDim2.new(1, -210, 0, 10),
    Visible = false
})

iframesRow = keybindPanel.addKeybindRow(IFramesKeybind, "IFrames", IFramesEnabled)
antiDebuffRow = keybindPanel.addKeybindRow(AntiDebuffKeybind, "Anti-Debuff", AntiDebuffEnabled)
toggleGuiRow = keybindPanel.addKeybindRow(ToggleKeybindUIKeybind, "Toggle UI", true)

-- Create the main window
local mainWindow = LunarityUI.CreateWindow({
    Name = "LunarityGUI",
    Title = "Lunarity",
    Subtitle = "IFrames & Anti-Debuff",
    Size = UDim2.new(0, 320, 0, 380),
    Position = UDim2.new(0.5, -160, 0.5, -190),
    Closable = true,
    Minimizable = true,
    OnClose = function()
        -- Self destruct
        ScriptActive = false
        IFramesEnabled = false
        AntiDebuffEnabled = false
        
        pcall(function()
            apply_status("IFrames", 1)
        end)
        
        if StatusRemoteConnection then
            StatusRemoteConnection:Disconnect()
            StatusRemoteConnection = nil
        end
        
        keybindPanel.destroy()
    end
})

-- Hide initially (show after loading)
mainWindow.ScreenGui.Enabled = false

-- IFrames Section
mainWindow.createSection("IFrames")

iframesToggle = mainWindow.createLargeToggle("Infinite IFrames", IFramesEnabled, function(state)
    IFramesEnabled = state
    iframesRow.setStatus(state)
    saveSettings()
end)

local iframesKeybindBtn = mainWindow.createKeybindButton("IFrames Keybind", IFramesKeybind, function(newKey)
    IFramesKeybind = newKey
    iframesRow.setKey(newKey)
    saveSettings()
end)

mainWindow.createSeparator()

-- Duration Mode
durationModeToggle = mainWindow.createToggle("Infinite Duration", isInfiniteDuration, function(state)
    isInfiniteDuration = state
    if durationSlider then
        -- Hide/show the slider holder based on mode
        if durationSlider.holder then
            durationSlider.holder.Visible = not state
        end
    end
    saveSettings()
end)

durationSlider = mainWindow.createSlider("Duration (seconds)", 1, 10, IFramesDuration, 0, function(val)
    IFramesDuration = val
    saveSettings()
end)

-- Hide slider if infinite mode is on
if isInfiniteDuration and durationSlider.holder then
    durationSlider.holder.Visible = false
end

mainWindow.createSeparator()

-- Anti-Debuff Section
mainWindow.createSection("Anti-Debuff")

antiDebuffToggle = mainWindow.createLargeToggle("Anti-Debuff", AntiDebuffEnabled, function(state)
    AntiDebuffEnabled = state
    antiDebuffRow.setStatus(state)
    saveSettings()
end)

local antiDebuffKeybindBtn = mainWindow.createKeybindButton("Anti-Debuff Keybind", AntiDebuffKeybind, function(newKey)
    AntiDebuffKeybind = newKey
    antiDebuffRow.setKey(newKey)
    saveSettings()
end)

mainWindow.createSeparator()

-- Settings Section
mainWindow.createSection("Settings")

local toggleUIKeybindBtn = mainWindow.createKeybindButton("Toggle Keybind UI", ToggleKeybindUIKeybind, function(newKey)
    ToggleKeybindUIKeybind = newKey
    toggleGuiRow.setKey(newKey)
    saveSettings()
end)

local statusLabel = mainWindow.createLabelValue("Status", "Active", Theme.Success)

mainWindow.createSeparator()

-- Self Destruct Button
mainWindow.createButton("Self Destruct", function()
    ScriptActive = false
    IFramesEnabled = false
    AntiDebuffEnabled = false
    
    pcall(function()
        apply_status("IFrames", 1)
    end)
    
    if StatusRemoteConnection then
        StatusRemoteConnection:Disconnect()
        StatusRemoteConnection = nil
    end
    
    keybindPanel.destroy()
    mainWindow.destroy()
end, false)

-- Animate loading screen and show main GUI after
loadingScreen.animate({
    {text = "Loading modules...", progress = 0.3, time = 1.0},
    {text = "Connecting to services...", progress = 0.6, time = 1.2},
    {text = "Finalizing...", progress = 0.9, time = 1.0},
    {text = "Ready!", progress = 1.0, time = 0.5}
}, function()
    -- Show main window after loading completes
    mainWindow.ScreenGui.Enabled = true
    keybindPanel.ScreenGui.Enabled = true
end)

-- Keybind input handling
mainWindow.addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == IFramesKeybind then
            IFramesEnabled = not IFramesEnabled
            iframesToggle.setState(IFramesEnabled)
            iframesRow.setStatus(IFramesEnabled)
            saveSettings()
        elseif input.KeyCode == AntiDebuffKeybind then
            AntiDebuffEnabled = not AntiDebuffEnabled
            antiDebuffToggle.setState(AntiDebuffEnabled)
            antiDebuffRow.setStatus(AntiDebuffEnabled)
            saveSettings()
        elseif input.KeyCode == ToggleKeybindUIKeybind then
            KeybindUIVisible = not KeybindUIVisible
            if KeybindUIVisible then
                keybindPanel.show()
            else
                keybindPanel.hide()
            end
        elseif input.KeyCode == ToggleGuiKeybind then
            GuiVisible = not GuiVisible
            mainWindow.ScreenGui.Enabled = GuiVisible
        end
    end
end))


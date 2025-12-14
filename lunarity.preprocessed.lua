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

local Theme = {
    Background = Color3.fromRGB(14, 14, 16),
    BackgroundGradientStart = Color3.fromRGB(28, 28, 32),
    BackgroundGradientEnd = Color3.fromRGB(12, 12, 14),
    Panel = Color3.fromRGB(20, 20, 24),
    PanelStroke = Color3.fromRGB(52, 52, 62),
    PanelHover = Color3.fromRGB(28, 28, 34),
    NeutralButton = Color3.fromRGB(30, 30, 36),
    NeutralButtonHover = Color3.fromRGB(38, 38, 46),
    NeutralDark = Color3.fromRGB(24, 24, 30),
    AccentLight = Color3.fromRGB(228, 216, 255),
    Accent = Color3.fromRGB(184, 150, 255),
    AccentHover = Color3.fromRGB(206, 182, 255),
    AccentDark = Color3.fromRGB(144, 110, 255),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(210, 210, 218),
    TextMuted = Color3.fromRGB(160, 160, 170),
    Success = Color3.fromRGB(214, 198, 255),
    Danger = Color3.fromRGB(226, 170, 255),
    DangerDark = Color3.fromRGB(148, 84, 222),
    DangerHover = Color3.fromRGB(200, 150, 255),
    Separator = Color3.fromRGB(48, 48, 58)
}

local AccentGradientSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Theme.AccentLight),
    ColorSequenceKeypoint.new(0.5, Theme.Accent),
    ColorSequenceKeypoint.new(1, Theme.AccentDark)
}

local BackgroundGradientSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Theme.BackgroundGradientStart),
    ColorSequenceKeypoint.new(1, Theme.BackgroundGradientEnd)
}

local DangerGradientSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 150, 255)),
    ColorSequenceKeypoint.new(1, Theme.DangerDark)
}

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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LunarityGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Keybind Display in Top Right
local KeybindDisplay = Instance.new("Frame")
KeybindDisplay.Size = UDim2.new(0, 200, 0, 110)
KeybindDisplay.Position = UDim2.new(1, -210, 0, 10)
KeybindDisplay.BackgroundColor3 = Theme.Background
KeybindDisplay.BorderSizePixel = 0
KeybindDisplay.BackgroundTransparency = 0.1
KeybindDisplay.Visible = false
KeybindDisplay.Active = true
KeybindDisplay.Parent = ScreenGui

local KeybindDisplayGradient = Instance.new("UIGradient")
KeybindDisplayGradient.Color = BackgroundGradientSequence
KeybindDisplayGradient.Rotation = 135
KeybindDisplayGradient.Parent = KeybindDisplay

local KeybindDisplayCorner = Instance.new("UICorner")
KeybindDisplayCorner.CornerRadius = UDim.new(0, 8)
KeybindDisplayCorner.Parent = KeybindDisplay

local KeybindDisplayStroke = Instance.new("UIStroke")
KeybindDisplayStroke.Color = Theme.PanelStroke
KeybindDisplayStroke.Thickness = 1
KeybindDisplayStroke.Transparency = 0.3
KeybindDisplayStroke.Parent = KeybindDisplay

local KeybindAccentLine = Instance.new("Frame")
KeybindAccentLine.Size = UDim2.new(1, 0, 0, 2)
KeybindAccentLine.Position = UDim2.new(0, 0, 0, 0)
KeybindAccentLine.BackgroundColor3 = Theme.Accent
KeybindAccentLine.BorderSizePixel = 0
KeybindAccentLine.Parent = KeybindDisplay

local KeybindAccentGradient = Instance.new("UIGradient")
KeybindAccentGradient.Color = AccentGradientSequence
KeybindAccentGradient.Parent = KeybindAccentLine

local KeybindAccentCorner = Instance.new("UICorner")
KeybindAccentCorner.CornerRadius = UDim.new(0, 8)
KeybindAccentCorner.Parent = KeybindAccentLine

-- IFrames Keybind Row
local IFramesKeybindRow = Instance.new("Frame")
IFramesKeybindRow.Size = UDim2.new(1, -16, 0, 28)
IFramesKeybindRow.Position = UDim2.new(0, 8, 0, 10)
IFramesKeybindRow.BackgroundTransparency = 1
IFramesKeybindRow.Parent = KeybindDisplay

local IFramesKeybindKey = Instance.new("TextLabel")
IFramesKeybindKey.Size = UDim2.new(0, 50, 1, 0)
IFramesKeybindKey.Position = UDim2.new(0, 0, 0, 0)
IFramesKeybindKey.BackgroundColor3 = Theme.NeutralDark
IFramesKeybindKey.BorderSizePixel = 0
IFramesKeybindKey.Text = getKeyNameOrDefault(IFramesKeybind, "One")
IFramesKeybindKey.TextColor3 = Theme.TextPrimary
IFramesKeybindKey.TextSize = 12
IFramesKeybindKey.Font = Enum.Font.GothamBold
IFramesKeybindKey.Parent = IFramesKeybindRow

local IFramesKeybindKeyCorner = Instance.new("UICorner")
IFramesKeybindKeyCorner.CornerRadius = UDim.new(0, 4)
IFramesKeybindKeyCorner.Parent = IFramesKeybindKey

local IFramesKeybindKeyStroke = Instance.new("UIStroke")
IFramesKeybindKeyStroke.Color = Theme.PanelStroke
IFramesKeybindKeyStroke.Thickness = 1
IFramesKeybindKeyStroke.Transparency = 0.5
IFramesKeybindKeyStroke.Parent = IFramesKeybindKey

local IFramesKeybindLabel = Instance.new("TextLabel")
IFramesKeybindLabel.Size = UDim2.new(1, -115, 1, 0)
IFramesKeybindLabel.Position = UDim2.new(0, 58, 0, 0)
IFramesKeybindLabel.BackgroundTransparency = 1
IFramesKeybindLabel.Text = "IFrames"
IFramesKeybindLabel.TextColor3 = Theme.TextSecondary
IFramesKeybindLabel.TextSize = 11
IFramesKeybindLabel.Font = Enum.Font.Gotham
IFramesKeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
IFramesKeybindLabel.Parent = IFramesKeybindRow

local IFramesKeybindStatus = Instance.new("Frame")
IFramesKeybindStatus.Size = UDim2.new(0, 40, 0, 20)
IFramesKeybindStatus.Position = UDim2.new(1, -40, 0, 4)
IFramesKeybindStatus.BackgroundColor3 = Theme.NeutralButton
IFramesKeybindStatus.BorderSizePixel = 0
IFramesKeybindStatus.Parent = IFramesKeybindRow

local IFramesKeybindStatusCorner = Instance.new("UICorner")
IFramesKeybindStatusCorner.CornerRadius = UDim.new(0, 4)
IFramesKeybindStatusCorner.Parent = IFramesKeybindStatus

local IFramesKeybindStatusText = Instance.new("TextLabel")
IFramesKeybindStatusText.Size = UDim2.new(1, 0, 1, 0)
IFramesKeybindStatusText.BackgroundTransparency = 1
IFramesKeybindStatusText.Text = "OFF"
IFramesKeybindStatusText.TextColor3 = Theme.TextMuted
IFramesKeybindStatusText.TextSize = 9
IFramesKeybindStatusText.Font = Enum.Font.GothamBold
IFramesKeybindStatusText.Parent = IFramesKeybindStatus

-- AntiDebuff Keybind Row
local AntiDebuffKeybindRow = Instance.new("Frame")
AntiDebuffKeybindRow.Size = UDim2.new(1, -16, 0, 28)
AntiDebuffKeybindRow.Position = UDim2.new(0, 8, 0, 42)
AntiDebuffKeybindRow.BackgroundTransparency = 1
AntiDebuffKeybindRow.Parent = KeybindDisplay

local AntiDebuffKeybindKey = Instance.new("TextLabel")
AntiDebuffKeybindKey.Size = UDim2.new(0, 50, 1, 0)
AntiDebuffKeybindKey.Position = UDim2.new(0, 0, 0, 0)
AntiDebuffKeybindKey.BackgroundColor3 = Theme.NeutralDark
AntiDebuffKeybindKey.BorderSizePixel = 0
AntiDebuffKeybindKey.Text = getKeyNameOrDefault(AntiDebuffKeybind, "Two")
AntiDebuffKeybindKey.TextColor3 = Theme.TextPrimary
AntiDebuffKeybindKey.TextSize = 12
AntiDebuffKeybindKey.Font = Enum.Font.GothamBold
AntiDebuffKeybindKey.Parent = AntiDebuffKeybindRow

local AntiDebuffKeybindKeyCorner = Instance.new("UICorner")
AntiDebuffKeybindKeyCorner.CornerRadius = UDim.new(0, 4)
AntiDebuffKeybindKeyCorner.Parent = AntiDebuffKeybindKey

local AntiDebuffKeybindKeyStroke = Instance.new("UIStroke")
AntiDebuffKeybindKeyStroke.Color = Theme.PanelStroke
AntiDebuffKeybindKeyStroke.Thickness = 1
AntiDebuffKeybindKeyStroke.Transparency = 0.5
AntiDebuffKeybindKeyStroke.Parent = AntiDebuffKeybindKey

local AntiDebuffKeybindLabel = Instance.new("TextLabel")
AntiDebuffKeybindLabel.Size = UDim2.new(1, -115, 1, 0)
AntiDebuffKeybindLabel.Position = UDim2.new(0, 58, 0, 0)
AntiDebuffKeybindLabel.BackgroundTransparency = 1
AntiDebuffKeybindLabel.Text = "Anti-Debuff"
AntiDebuffKeybindLabel.TextColor3 = Theme.TextSecondary
AntiDebuffKeybindLabel.TextSize = 11
AntiDebuffKeybindLabel.Font = Enum.Font.Gotham
AntiDebuffKeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
AntiDebuffKeybindLabel.Parent = AntiDebuffKeybindRow

local AntiDebuffKeybindStatus = Instance.new("Frame")
AntiDebuffKeybindStatus.Size = UDim2.new(0, 40, 0, 20)
AntiDebuffKeybindStatus.Position = UDim2.new(1, -40, 0, 4)
AntiDebuffKeybindStatus.BackgroundColor3 = Theme.Accent
AntiDebuffKeybindStatus.BorderSizePixel = 0
AntiDebuffKeybindStatus.Parent = AntiDebuffKeybindRow

local AntiDebuffKeybindStatusCorner = Instance.new("UICorner")
AntiDebuffKeybindStatusCorner.CornerRadius = UDim.new(0, 4)
AntiDebuffKeybindStatusCorner.Parent = AntiDebuffKeybindStatus

local AntiDebuffKeybindStatusGradient = Instance.new("UIGradient")
AntiDebuffKeybindStatusGradient.Color = AccentGradientSequence
AntiDebuffKeybindStatusGradient.Parent = AntiDebuffKeybindStatus

local AntiDebuffKeybindStatusText = Instance.new("TextLabel")
AntiDebuffKeybindStatusText.Size = UDim2.new(1, 0, 1, 0)
AntiDebuffKeybindStatusText.BackgroundTransparency = 1
AntiDebuffKeybindStatusText.Text = "ON"
AntiDebuffKeybindStatusText.TextColor3 = Theme.TextPrimary
AntiDebuffKeybindStatusText.TextSize = 9
AntiDebuffKeybindStatusText.Font = Enum.Font.GothamBold
AntiDebuffKeybindStatusText.Parent = AntiDebuffKeybindStatus

-- Toggle GUI Keybind Row
local ToggleGuiKeybindRow = Instance.new("Frame")
ToggleGuiKeybindRow.Size = UDim2.new(1, -16, 0, 28)
ToggleGuiKeybindRow.Position = UDim2.new(0, 8, 0, 74)
ToggleGuiKeybindRow.BackgroundTransparency = 1
ToggleGuiKeybindRow.Parent = KeybindDisplay

local ToggleGuiKeybindKey = Instance.new("TextLabel")
ToggleGuiKeybindKey.Size = UDim2.new(0, 50, 1, 0)
ToggleGuiKeybindKey.Position = UDim2.new(0, 0, 0, 0)
ToggleGuiKeybindKey.BackgroundColor3 = Theme.NeutralDark
ToggleGuiKeybindKey.BorderSizePixel = 0
ToggleGuiKeybindKey.Text = ToggleGuiKeybind.Name
ToggleGuiKeybindKey.TextColor3 = Theme.TextPrimary
ToggleGuiKeybindKey.TextSize = 12
ToggleGuiKeybindKey.Font = Enum.Font.GothamBold
ToggleGuiKeybindKey.Parent = ToggleGuiKeybindRow

local ToggleGuiKeybindKeyCorner = Instance.new("UICorner")
ToggleGuiKeybindKeyCorner.CornerRadius = UDim.new(0, 4)
ToggleGuiKeybindKeyCorner.Parent = ToggleGuiKeybindKey

local ToggleGuiKeybindKeyStroke = Instance.new("UIStroke")
ToggleGuiKeybindKeyStroke.Color = Theme.PanelStroke
ToggleGuiKeybindKeyStroke.Thickness = 1
ToggleGuiKeybindKeyStroke.Transparency = 0.5
ToggleGuiKeybindKeyStroke.Parent = ToggleGuiKeybindKey

local ToggleGuiKeybindLabel = Instance.new("TextLabel")
ToggleGuiKeybindLabel.Size = UDim2.new(1, -58, 1, 0)
ToggleGuiKeybindLabel.Position = UDim2.new(0, 58, 0, 0)
ToggleGuiKeybindLabel.BackgroundTransparency = 1
ToggleGuiKeybindLabel.Text = "Toggle GUI"
ToggleGuiKeybindLabel.TextColor3 = Theme.TextMuted
ToggleGuiKeybindLabel.TextSize = 10
ToggleGuiKeybindLabel.Font = Enum.Font.Gotham
ToggleGuiKeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleGuiKeybindLabel.Parent = ToggleGuiKeybindRow

-- Loading Screen
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(0, 300, 0, 150)
LoadingFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
LoadingFrame.BackgroundColor3 = Theme.Background
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = ScreenGui

local LoadingFrameGradient = Instance.new("UIGradient")
LoadingFrameGradient.Color = BackgroundGradientSequence
LoadingFrameGradient.Rotation = 45
LoadingFrameGradient.Parent = LoadingFrame

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 8)
LoadingCorner.Parent = LoadingFrame

local LoadingShadow = Instance.new("ImageLabel")
LoadingShadow.Name = "Shadow"
LoadingShadow.Size = UDim2.new(1, 40, 1, 40)
LoadingShadow.Position = UDim2.new(0, -20, 0, -20)
LoadingShadow.BackgroundTransparency = 1
LoadingShadow.Image = "rbxassetid://1316045217"
LoadingShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
LoadingShadow.ImageTransparency = 0.3
LoadingShadow.ScaleType = Enum.ScaleType.Slice
LoadingShadow.SliceCenter = Rect.new(10, 10, 118, 118)
LoadingShadow.ZIndex = 0
LoadingShadow.Parent = LoadingFrame

local LoadingAccent = Instance.new("Frame")
LoadingAccent.Size = UDim2.new(1, 0, 0, 3)
LoadingAccent.Position = UDim2.new(0, 0, 0, 0)
LoadingAccent.BackgroundColor3 = Theme.Accent
LoadingAccent.BorderSizePixel = 0
LoadingAccent.Parent = LoadingFrame

local LoadingAccentGradient = Instance.new("UIGradient")
LoadingAccentGradient.Color = AccentGradientSequence
LoadingAccentGradient.Parent = LoadingAccent

local LoadingAccentCorner = Instance.new("UICorner")
LoadingAccentCorner.CornerRadius = UDim.new(0, 8)
LoadingAccentCorner.Parent = LoadingAccent

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Size = UDim2.new(1, -40, 0, 40)
LoadingTitle.Position = UDim2.new(0, 20, 0, 20)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = "Lunarity"
LoadingTitle.TextColor3 = Theme.TextPrimary
LoadingTitle.TextSize = 22
LoadingTitle.Font = Enum.Font.GothamBold
LoadingTitle.TextXAlignment = Enum.TextXAlignment.Center
LoadingTitle.TextStrokeTransparency = 0.8
LoadingTitle.TextStrokeColor3 = Theme.AccentDark
LoadingTitle.Parent = LoadingFrame

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, -40, 0, 20)
LoadingText.Position = UDim2.new(0, 20, 0, 65)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Initializing..."
LoadingText.TextColor3 = Theme.TextMuted
LoadingText.TextSize = 12
LoadingText.Font = Enum.Font.Gotham
LoadingText.TextXAlignment = Enum.TextXAlignment.Center
LoadingText.Parent = LoadingFrame

local LoadingBarBg = Instance.new("Frame")
LoadingBarBg.Size = UDim2.new(1, -40, 0, 6)
LoadingBarBg.Position = UDim2.new(0, 20, 0, 100)
LoadingBarBg.BackgroundColor3 = Theme.NeutralButton
LoadingBarBg.BorderSizePixel = 0
LoadingBarBg.Parent = LoadingFrame

local LoadingBarBgCorner = Instance.new("UICorner")
LoadingBarBgCorner.CornerRadius = UDim.new(0, 3)
LoadingBarBgCorner.Parent = LoadingBarBg

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0, 0, 1, 0)
LoadingBar.BackgroundColor3 = Theme.Accent
LoadingBar.BorderSizePixel = 0
LoadingBar.Parent = LoadingBarBg

local LoadingBarGradient = Instance.new("UIGradient")
LoadingBarGradient.Color = AccentGradientSequence
LoadingBarGradient.Parent = LoadingBar

local LoadingBarCorner = Instance.new("UICorner")
LoadingBarCorner.CornerRadius = UDim.new(0, 3)
LoadingBarCorner.Parent = LoadingBar

-- Animate loading bar
spawn(function()
    local stages = {
        {progress = 0.3, text = "Loading modules...", time = 1.2},
        {progress = 0.6, text = "Connecting to services...", time = 1.5},
        {progress = 0.9, text = "Finalizing...", time = 1.3},
        {progress = 1.0, text = "Ready!", time = 0.8}
    }
    
    for _, stage in ipairs(stages) do
        LoadingText.Text = stage.text
        TweenService:Create(LoadingBar, TweenInfo.new(stage.time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(stage.progress, 0, 1, 0)
        }):Play()
        task.wait(stage.time)
    end
    
    task.wait(0.5)
    
    -- Fade out loading screen
    TweenService:Create(LoadingFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0.5, -200)
    }):Play()
    
    local fadeTween = TweenService:Create(LoadingFrame, TweenInfo.new(0.4), {
        BackgroundTransparency = 1
    })
    fadeTween:Play()
    
    TweenService:Create(LoadingTitle, TweenInfo.new(0.4), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
    TweenService:Create(LoadingText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(LoadingAccent, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadingBarBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadingBar, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadingShadow, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
    
    fadeTween.Completed:Wait()
    LoadingFrame:Destroy()
end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 445)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Animate main frame entrance after loading
spawn(function()
    task.wait(5.3) -- Wait for loading to complete
    
    -- Make frame visible and set initial position
    MainFrame.Visible = true
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -280)
    
    -- Slide in animation
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0.3, 0)
    }):Play()
    
    -- Show keybind display with fade in
    task.wait(0.3)
    KeybindDisplay.Visible = true
    KeybindDisplay.Position = UDim2.new(1, -210, 0, -10)
    
    TweenService:Create(KeybindDisplay, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -210, 0, 10)
    }):Play()
end)

local MainFrameGradient = Instance.new("UIGradient")
MainFrameGradient.Color = BackgroundGradientSequence
MainFrameGradient.Rotation = 45
MainFrameGradient.Parent = MainFrame

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.3
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 3)
AccentLine.Position = UDim2.new(0, 0, 0, 0)
AccentLine.BackgroundColor3 = Theme.Accent
AccentLine.BorderSizePixel = 0
AccentLine.Parent = MainFrame

local AccentGradient = Instance.new("UIGradient")
AccentGradient.Color = AccentGradientSequence
AccentGradient.Parent = AccentLine

local AccentCorner = Instance.new("UICorner")
AccentCorner.CornerRadius = UDim.new(0, 6)
AccentCorner.Parent = AccentLine

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 0, 35)
TitleLabel.Position = UDim2.new(0, 10, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Lunarity"
TitleLabel.TextColor3 = Theme.TextPrimary
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextStrokeTransparency = 0.8
TitleLabel.TextStrokeColor3 = Theme.AccentDark
TitleLabel.Parent = MainFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.BackgroundColor3 = Theme.NeutralButton
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "–"
MinimizeButton.TextColor3 = Theme.TextSecondary
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.ZIndex = 3
MinimizeButton.Parent = MainFrame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeButton

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Theme.DangerDark
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Theme.Danger
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 3
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(1, -20, 0, 15)
SubtitleLabel.Position = UDim2.new(0, 10, 0, 30)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "Advanced Combat Enhancement"
SubtitleLabel.TextColor3 = Theme.TextMuted
SubtitleLabel.TextSize = 11
SubtitleLabel.Font = Enum.Font.Gotham
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.Parent = MainFrame

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -20, 0, 1)
Separator.Position = UDim2.new(0, 10, 0, 50)
Separator.BackgroundColor3 = Theme.Separator
Separator.BorderSizePixel = 0
Separator.Parent = MainFrame

local IFramesContainer = Instance.new("Frame")
IFramesContainer.Size = UDim2.new(1, -20, 0, 45)
IFramesContainer.Position = UDim2.new(0, 10, 0, 60)
IFramesContainer.BackgroundColor3 = Theme.Panel
IFramesContainer.BorderSizePixel = 0
IFramesContainer.Parent = MainFrame

local IFramesContainerStroke = Instance.new("UIStroke")
IFramesContainerStroke.Color = Theme.PanelStroke
IFramesContainerStroke.Thickness = 1
IFramesContainerStroke.Transparency = 0.5
IFramesContainerStroke.Parent = IFramesContainer

local IFramesContainerCorner = Instance.new("UICorner")
IFramesContainerCorner.CornerRadius = UDim.new(0, 6)
IFramesContainerCorner.Parent = IFramesContainer

local IFramesButton = Instance.new("TextButton")
IFramesButton.Size = UDim2.new(1, -10, 1, -10)
IFramesButton.Position = UDim2.new(0, 5, 0, 5)
IFramesButton.BackgroundColor3 = Theme.NeutralButton
IFramesButton.BorderSizePixel = 0
IFramesButton.Text = "Infinite IFrames: OFF"
IFramesButton.TextColor3 = Theme.TextSecondary
IFramesButton.TextSize = 14
IFramesButton.Font = Enum.Font.GothamBold
IFramesButton.AutoButtonColor = false
IFramesButton.Parent = IFramesContainer

local IFramesButtonCorner = Instance.new("UICorner")
IFramesButtonCorner.CornerRadius = UDim.new(0, 6)
IFramesButtonCorner.Parent = IFramesButton

local IFramesKeybindDisplayLabel = Instance.new("TextLabel")
IFramesKeybindDisplayLabel.Size = UDim2.new(1, -20, 0, 20)
IFramesKeybindDisplayLabel.Position = UDim2.new(0, 10, 0, 112)
IFramesKeybindDisplayLabel.BackgroundTransparency = 1
IFramesKeybindDisplayLabel.Text = "IFrames Keybind: " .. getKeyNameOrDefault(IFramesKeybind, "One")
IFramesKeybindDisplayLabel.TextColor3 = Theme.TextSecondary
IFramesKeybindDisplayLabel.TextSize = 12
IFramesKeybindDisplayLabel.Font = Enum.Font.Gotham
IFramesKeybindDisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
IFramesKeybindDisplayLabel.Parent = MainFrame

local IFramesKeybindButton = Instance.new("TextButton")
IFramesKeybindButton.Size = UDim2.new(0, 120, 0, 25)
IFramesKeybindButton.Position = UDim2.new(1, -130, 0, 110)
IFramesKeybindButton.BackgroundColor3 = Theme.NeutralDark
IFramesKeybindButton.BorderSizePixel = 0
IFramesKeybindButton.Text = "Set Keybind"
IFramesKeybindButton.TextColor3 = Theme.TextSecondary
IFramesKeybindButton.TextSize = 11
IFramesKeybindButton.Font = Enum.Font.GothamBold
IFramesKeybindButton.Parent = MainFrame

local IFramesKeybindCorner = Instance.new("UICorner")
IFramesKeybindCorner.CornerRadius = UDim.new(0, 3)
IFramesKeybindCorner.Parent = IFramesKeybindButton

local DurationLabel = Instance.new("TextLabel")
DurationLabel.Size = UDim2.new(1, -20, 0, 20)
DurationLabel.Position = UDim2.new(0, 10, 0, 143)
DurationLabel.BackgroundTransparency = 1
DurationLabel.Text = "IFrames Duration: Infinite"
DurationLabel.TextColor3 = Theme.TextSecondary
DurationLabel.TextSize = 12
DurationLabel.Font = Enum.Font.Gotham
DurationLabel.TextXAlignment = Enum.TextXAlignment.Left
DurationLabel.Parent = MainFrame

local DurationModeButton = Instance.new("TextButton")
DurationModeButton.Size = UDim2.new(0, 80, 0, 25)
DurationModeButton.Position = UDim2.new(1, -130, 0, 141)
DurationModeButton.BackgroundColor3 = Theme.AccentDark
DurationModeButton.BorderSizePixel = 0
DurationModeButton.Text = "Infinite"
DurationModeButton.TextColor3 = Theme.TextPrimary
DurationModeButton.TextSize = 11
DurationModeButton.Font = Enum.Font.GothamBold
DurationModeButton.Parent = MainFrame

local DurationModeCorner = Instance.new("UICorner")
DurationModeCorner.CornerRadius = UDim.new(0, 3)
DurationModeCorner.Parent = DurationModeButton

local DurationSlider = Instance.new("Frame")
DurationSlider.Size = UDim2.new(1, -20, 0, 30)
DurationSlider.Position = UDim2.new(0, 10, 0, 173)
DurationSlider.BackgroundColor3 = Theme.Panel
DurationSlider.BorderSizePixel = 0
DurationSlider.Visible = false
DurationSlider.Parent = MainFrame

local DurationSliderStroke = Instance.new("UIStroke")
DurationSliderStroke.Color = Theme.PanelStroke
DurationSliderStroke.Thickness = 1
DurationSliderStroke.Transparency = 0.5
DurationSliderStroke.Parent = DurationSlider

local DurationSliderCorner = Instance.new("UICorner")
DurationSliderCorner.CornerRadius = UDim.new(0, 6)
DurationSliderCorner.Parent = DurationSlider

local DurationSliderBar = Instance.new("Frame")
DurationSliderBar.Size = UDim2.new(1, -20, 0, 6)
DurationSliderBar.Position = UDim2.new(0, 10, 0, 12)
DurationSliderBar.BackgroundColor3 = Theme.NeutralButton
DurationSliderBar.BorderSizePixel = 0
DurationSliderBar.Parent = DurationSlider

local DurationSliderBarCorner = Instance.new("UICorner")
DurationSliderBarCorner.CornerRadius = UDim.new(0, 3)
DurationSliderBarCorner.Parent = DurationSliderBar

local DurationSliderFill = Instance.new("Frame")
DurationSliderFill.Size = UDim2.new(0.2, 0, 1, 0)
DurationSliderFill.BackgroundColor3 = Theme.Accent
DurationSliderFill.BorderSizePixel = 0
DurationSliderFill.Parent = DurationSliderBar

local DurationSliderFillGradient = Instance.new("UIGradient")
DurationSliderFillGradient.Color = AccentGradientSequence
DurationSliderFillGradient.Parent = DurationSliderFill

local DurationSliderFillCorner = Instance.new("UICorner")
DurationSliderFillCorner.CornerRadius = UDim.new(0, 3)
DurationSliderFillCorner.Parent = DurationSliderFill

local DurationSliderButton = Instance.new("TextButton")
DurationSliderButton.Size = UDim2.new(0, 16, 0, 16)
DurationSliderButton.Position = UDim2.new(0.2, -8, 0.5, -8)
DurationSliderButton.BackgroundColor3 = Theme.AccentLight
DurationSliderButton.BorderSizePixel = 0
DurationSliderButton.Text = ""
DurationSliderButton.AutoButtonColor = false
DurationSliderButton.Parent = DurationSliderBar

local DurationSliderButtonStroke = Instance.new("UIStroke")
DurationSliderButtonStroke.Color = Color3.fromRGB(228, 216, 255)
DurationSliderButtonStroke.Thickness = 2
DurationSliderButtonStroke.Transparency = 0.3
DurationSliderButtonStroke.Parent = DurationSliderButton

local DurationSliderButtonCorner = Instance.new("UICorner")
DurationSliderButtonCorner.CornerRadius = UDim.new(1, 0)
DurationSliderButtonCorner.Parent = DurationSliderButton

local DurationValueLabel = Instance.new("TextLabel")
DurationValueLabel.Size = UDim2.new(0, 40, 0, 12)
DurationValueLabel.Position = UDim2.new(1, -45, 0, 1)
DurationValueLabel.BackgroundTransparency = 1
DurationValueLabel.Text = "2s"
DurationValueLabel.TextColor3 = Theme.AccentLight
DurationValueLabel.TextSize = 10
DurationValueLabel.Font = Enum.Font.GothamBold
DurationValueLabel.TextXAlignment = Enum.TextXAlignment.Right
DurationValueLabel.Parent = DurationSlider

local AntiDebuffContainer = Instance.new("Frame")
AntiDebuffContainer.Size = UDim2.new(1, -20, 0, 45)
AntiDebuffContainer.Position = UDim2.new(0, 10, 0, 213)
AntiDebuffContainer.BackgroundColor3 = Theme.Panel
AntiDebuffContainer.BorderSizePixel = 0
AntiDebuffContainer.Parent = MainFrame

local AntiDebuffContainerStroke = Instance.new("UIStroke")
AntiDebuffContainerStroke.Color = Theme.PanelStroke
AntiDebuffContainerStroke.Thickness = 1
AntiDebuffContainerStroke.Transparency = 0.5
AntiDebuffContainerStroke.Parent = AntiDebuffContainer

local AntiDebuffContainerCorner = Instance.new("UICorner")
AntiDebuffContainerCorner.CornerRadius = UDim.new(0, 6)
AntiDebuffContainerCorner.Parent = AntiDebuffContainer

local AntiDebuffButton = Instance.new("TextButton")
AntiDebuffButton.Size = UDim2.new(1, -10, 1, -10)
AntiDebuffButton.Position = UDim2.new(0, 5, 0, 5)
AntiDebuffButton.BackgroundColor3 = Theme.Accent
AntiDebuffButton.BorderSizePixel = 0
AntiDebuffButton.Text = "Anti-Debuff: ON"
AntiDebuffButton.TextColor3 = Theme.TextPrimary
AntiDebuffButton.TextSize = 14
AntiDebuffButton.Font = Enum.Font.GothamBold
AntiDebuffButton.AutoButtonColor = false
AntiDebuffButton.Parent = AntiDebuffContainer

local AntiDebuffButtonCorner = Instance.new("UICorner")
AntiDebuffButtonCorner.CornerRadius = UDim.new(0, 6)
AntiDebuffButtonCorner.Parent = AntiDebuffButton

local AntiDebuffKeybindDisplayLabel = Instance.new("TextLabel")
AntiDebuffKeybindDisplayLabel.Size = UDim2.new(1, -20, 0, 20)
AntiDebuffKeybindDisplayLabel.Position = UDim2.new(0, 10, 0, 265)
AntiDebuffKeybindDisplayLabel.BackgroundTransparency = 1
AntiDebuffKeybindDisplayLabel.Text = "Anti-Debuff Keybind: " .. getKeyNameOrDefault(AntiDebuffKeybind, "Two")
AntiDebuffKeybindDisplayLabel.TextColor3 = Theme.TextSecondary
AntiDebuffKeybindDisplayLabel.TextSize = 12
AntiDebuffKeybindDisplayLabel.Font = Enum.Font.Gotham
AntiDebuffKeybindDisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
AntiDebuffKeybindDisplayLabel.Parent = MainFrame

local ToggleKeybindUIKeybindDisplayLabel = Instance.new("TextLabel")
ToggleKeybindUIKeybindDisplayLabel.Size = UDim2.new(1, -20, 0, 20)
ToggleKeybindUIKeybindDisplayLabel.Position = UDim2.new(0, 10, 0, 290)
ToggleKeybindUIKeybindDisplayLabel.BackgroundTransparency = 1
ToggleKeybindUIKeybindDisplayLabel.Text = "Keybind UI Toggle: " .. getKeyNameOrDefault(ToggleKeybindUIKeybind, "F1")
ToggleKeybindUIKeybindDisplayLabel.TextColor3 = Theme.TextSecondary
ToggleKeybindUIKeybindDisplayLabel.TextSize = 12
ToggleKeybindUIKeybindDisplayLabel.Font = Enum.Font.Gotham
ToggleKeybindUIKeybindDisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleKeybindUIKeybindDisplayLabel.Parent = MainFrame

local ToggleKeybindUIKeybindButton = Instance.new("TextButton")
ToggleKeybindUIKeybindButton.Size = UDim2.new(0, 120, 0, 25)
ToggleKeybindUIKeybindButton.Position = UDim2.new(1, -130, 0, 288)
ToggleKeybindUIKeybindButton.BackgroundColor3 = Theme.NeutralDark
ToggleKeybindUIKeybindButton.BorderSizePixel = 0
ToggleKeybindUIKeybindButton.Text = "Set Keybind"
ToggleKeybindUIKeybindButton.TextColor3 = Theme.TextSecondary
ToggleKeybindUIKeybindButton.TextSize = 11
ToggleKeybindUIKeybindButton.Font = Enum.Font.GothamBold
ToggleKeybindUIKeybindButton.Parent = MainFrame

local ToggleKeybindUIKeybindCorner = Instance.new("UICorner")
ToggleKeybindUIKeybindCorner.CornerRadius = UDim.new(0, 3)
ToggleKeybindUIKeybindCorner.Parent = ToggleKeybindUIKeybindButton

local AntiDebuffKeybindButton = Instance.new("TextButton")
AntiDebuffKeybindButton.Size = UDim2.new(0, 120, 0, 25)
AntiDebuffKeybindButton.Position = UDim2.new(1, -130, 0, 263)
AntiDebuffKeybindButton.BackgroundColor3 = Theme.NeutralDark
AntiDebuffKeybindButton.BorderSizePixel = 0
AntiDebuffKeybindButton.Text = "Set Keybind"
AntiDebuffKeybindButton.TextColor3 = Theme.TextSecondary
AntiDebuffKeybindButton.TextSize = 11
AntiDebuffKeybindButton.Font = Enum.Font.GothamBold
AntiDebuffKeybindButton.Parent = MainFrame

local AntiDebuffKeybindCorner = Instance.new("UICorner")
AntiDebuffKeybindCorner.CornerRadius = UDim.new(0, 3)
AntiDebuffKeybindCorner.Parent = AntiDebuffKeybindButton

local Separator2 = Instance.new("Frame")
Separator2.Size = UDim2.new(1, -20, 0, 1)
Separator2.Position = UDim2.new(0, 10, 0, 323)
Separator2.BackgroundColor3 = Theme.Separator
Separator2.BorderSizePixel = 0
Separator2.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 80, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 333)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status:"
StatusLabel.TextColor3 = Theme.TextSecondary
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local StatusValue = Instance.new("TextLabel")
StatusValue.Size = UDim2.new(0, 200, 0, 20)
StatusValue.Position = UDim2.new(0, 70, 0, 333)
StatusValue.BackgroundTransparency = 1
StatusValue.Text = "Active"
StatusValue.TextColor3 = Theme.Success
StatusValue.TextSize = 13
StatusValue.Font = Enum.Font.GothamBold
StatusValue.TextXAlignment = Enum.TextXAlignment.Left
StatusValue.Parent = MainFrame

local SelfDestructContainer = Instance.new("Frame")
SelfDestructContainer.Size = UDim2.new(1, -20, 0, 28)
SelfDestructContainer.Position = UDim2.new(0, 10, 0, 363)
SelfDestructContainer.BackgroundColor3 = Theme.Panel
SelfDestructContainer.BorderSizePixel = 0
SelfDestructContainer.Parent = MainFrame

local DestructContainerStroke = Instance.new("UIStroke")
DestructContainerStroke.Color = Color3.fromRGB(148, 84, 222)
DestructContainerStroke.Thickness = 1
DestructContainerStroke.Transparency = 0.5
DestructContainerStroke.Parent = SelfDestructContainer

local DestructContainerCorner = Instance.new("UICorner")
DestructContainerCorner.CornerRadius = UDim.new(0, 6)
DestructContainerCorner.Parent = SelfDestructContainer

local SelfDestructButton = Instance.new("TextButton")
SelfDestructButton.Size = UDim2.new(1, -8, 1, -8)
SelfDestructButton.Position = UDim2.new(0, 4, 0, 4)
SelfDestructButton.BackgroundColor3 = Theme.DangerDark
SelfDestructButton.BorderSizePixel = 0
SelfDestructButton.Text = "Self Destruct"
SelfDestructButton.TextColor3 = Theme.Danger
SelfDestructButton.TextSize = 12
SelfDestructButton.Font = Enum.Font.GothamBold
SelfDestructButton.AutoButtonColor = false
SelfDestructButton.ZIndex = 2
SelfDestructButton.Parent = SelfDestructContainer

local DestructButtonGradient = Instance.new("UIGradient")
DestructButtonGradient.Color = DangerGradientSequence
DestructButtonGradient.Rotation = 45
DestructButtonGradient.Parent = SelfDestructButton

local DestructButtonCorner = Instance.new("UICorner")
DestructButtonCorner.CornerRadius = UDim.new(0, 5)
DestructButtonCorner.Parent = SelfDestructButton

local isSettingKeybind = false
local currentKeybindTarget = nil
local isDraggingSlider = false
local draggingKeybindDisplay = false
local keybindDragInput, keybindMousePos, keybindFramePos

local function updateDurationDisplay()
    if isInfiniteDuration then
        DurationLabel.Text = "IFrames Duration: Infinite"
        DurationSlider.Visible = false
        DurationModeButton.Text = "Infinite"
        DurationModeButton.BackgroundColor3 = Theme.AccentDark
    else
        DurationLabel.Text = "IFrames Duration: " .. IFramesDuration .. "s"
        DurationSlider.Visible = true
        DurationModeButton.Text = "Custom"
        DurationModeButton.BackgroundColor3 = Theme.Accent
        DurationValueLabel.Text = IFramesDuration .. "s"
        
        local minDuration = 1
        local maxDuration = 10
        local percentage = (IFramesDuration - minDuration) / (maxDuration - minDuration)
        DurationSliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        DurationSliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
    end
end

local function updateIFramesButton()
    if IFramesEnabled then
        local buttonText = isInfiniteDuration and "Infinite IFrames: ON" or ("IFrames (" .. IFramesDuration .. "s): ON")
        IFramesButton.Text = buttonText
        IFramesButton.BackgroundColor3 = Theme.Accent
        IFramesButton.TextColor3 = Theme.TextPrimary
        
        local existingGradient = IFramesButton:FindFirstChildOfClass("UIGradient")
        if existingGradient then
            existingGradient:Destroy()
        end
        
        -- Update keybind display
        IFramesKeybindStatusText.Text = "ON"
        IFramesKeybindStatusText.TextColor3 = Theme.TextPrimary
        TweenService:Create(IFramesKeybindStatus, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
        
        if not IFramesKeybindStatus:FindFirstChildOfClass("UIGradient") then
            local gradient = Instance.new("UIGradient")
            gradient.Color = AccentGradientSequence
            gradient.Parent = IFramesKeybindStatus
        end
    else
        local buttonText = isInfiniteDuration and "Infinite IFrames: OFF" or ("IFrames (" .. IFramesDuration .. "s): OFF")
        IFramesButton.Text = buttonText
        IFramesButton.BackgroundColor3 = Theme.NeutralButton
        IFramesButton.TextColor3 = Theme.TextSecondary
        
        local existingGradient = IFramesButton:FindFirstChildOfClass("UIGradient")
        if existingGradient then
            existingGradient:Destroy()
        end
        
        -- Update keybind display
        IFramesKeybindStatusText.Text = "OFF"
        IFramesKeybindStatusText.TextColor3 = Theme.TextMuted
        TweenService:Create(IFramesKeybindStatus, TweenInfo.new(0.2), {BackgroundColor3 = Theme.NeutralButton}):Play()
        
        local existingGradient2 = IFramesKeybindStatus:FindFirstChildOfClass("UIGradient")
        if existingGradient2 then
            existingGradient2:Destroy()
        end
    end
    saveSettings()
end

local function updateAntiDebuffButton()
    if AntiDebuffEnabled then
        AntiDebuffButton.Text = "Anti-Debuff: ON"
        AntiDebuffButton.BackgroundColor3 = Theme.Accent
        AntiDebuffButton.TextColor3 = Theme.TextPrimary
        
        local existingGradient = AntiDebuffButton:FindFirstChildOfClass("UIGradient")
        if existingGradient then
            existingGradient:Destroy()
        end
        
        -- Update keybind display
        AntiDebuffKeybindStatusText.Text = "ON"
        AntiDebuffKeybindStatusText.TextColor3 = Theme.TextPrimary
        TweenService:Create(AntiDebuffKeybindStatus, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
        
        if not AntiDebuffKeybindStatus:FindFirstChildOfClass("UIGradient") then
            local gradient = Instance.new("UIGradient")
            gradient.Color = AccentGradientSequence
            gradient.Parent = AntiDebuffKeybindStatus
        end
    else
        AntiDebuffButton.Text = "Anti-Debuff: OFF"
        AntiDebuffButton.BackgroundColor3 = Theme.NeutralButton
        AntiDebuffButton.TextColor3 = Theme.TextSecondary
        
        local existingGradient = AntiDebuffButton:FindFirstChildOfClass("UIGradient")
        if existingGradient then
            existingGradient:Destroy()
        end
        
        -- Update keybind display
        AntiDebuffKeybindStatusText.Text = "OFF"
        AntiDebuffKeybindStatusText.TextColor3 = Theme.TextMuted
        TweenService:Create(AntiDebuffKeybindStatus, TweenInfo.new(0.2), {BackgroundColor3 = Theme.NeutralButton}):Play()
        
        local existingGradient2 = AntiDebuffKeybindStatus:FindFirstChildOfClass("UIGradient")
        if existingGradient2 then
            existingGradient2:Destroy()
        end
    end
    saveSettings()
end

IFramesButton.MouseEnter:Connect(function()
    if not IFramesEnabled then
        TweenService:Create(IFramesButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.NeutralButtonHover}):Play()
    else
        TweenService:Create(IFramesButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.AccentHover}):Play()
    end
end)

IFramesButton.MouseLeave:Connect(function()
    if not IFramesEnabled then
        TweenService:Create(IFramesButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.NeutralButton}):Play()
    else
        TweenService:Create(IFramesButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
    end
end)

AntiDebuffButton.MouseEnter:Connect(function()
    if AntiDebuffEnabled then
        TweenService:Create(AntiDebuffButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.AccentHover}):Play()
    else
        TweenService:Create(AntiDebuffButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.NeutralButtonHover}):Play()
    end
end)

AntiDebuffButton.MouseLeave:Connect(function()
    if AntiDebuffEnabled then
        TweenService:Create(AntiDebuffButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
    else
        TweenService:Create(AntiDebuffButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.NeutralButton}):Play()
    end
end)

SelfDestructButton.MouseEnter:Connect(function()
    TweenService:Create(SelfDestructButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.DangerHover}):Play()
    TweenService:Create(SelfDestructButton, TweenInfo.new(0.2), {TextColor3 = Theme.TextPrimary}):Play()
end)

SelfDestructButton.MouseLeave:Connect(function()
    TweenService:Create(SelfDestructButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.DangerDark}):Play()
    TweenService:Create(SelfDestructButton, TweenInfo.new(0.2), {TextColor3 = Theme.Danger}):Play()
end)

IFramesKeybindButton.MouseEnter:Connect(function()
    IFramesKeybindButton.BackgroundColor3 = Theme.NeutralButtonHover
end)

IFramesKeybindButton.MouseLeave:Connect(function()
    if not isSettingKeybind or currentKeybindTarget ~= "IFrames" then
        IFramesKeybindButton.BackgroundColor3 = Theme.NeutralDark
    end
end)

AntiDebuffKeybindButton.MouseEnter:Connect(function()
    AntiDebuffKeybindButton.BackgroundColor3 = Theme.NeutralButtonHover
end)

AntiDebuffKeybindButton.MouseLeave:Connect(function()
    if not isSettingKeybind or currentKeybindTarget ~= "AntiDebuff" then
        AntiDebuffKeybindButton.BackgroundColor3 = Theme.NeutralDark
    end
end)

ToggleKeybindUIKeybindButton.MouseEnter:Connect(function()
    ToggleKeybindUIKeybindButton.BackgroundColor3 = Theme.NeutralButtonHover
end)

ToggleKeybindUIKeybindButton.MouseLeave:Connect(function()
    if not isSettingKeybind or currentKeybindTarget ~= "ToggleKeybindUI" then
        ToggleKeybindUIKeybindButton.BackgroundColor3 = Theme.NeutralDark
    end
end)

DurationModeButton.MouseEnter:Connect(function()
    if isInfiniteDuration then
        DurationModeButton.BackgroundColor3 = Theme.Accent
    else
        DurationModeButton.BackgroundColor3 = Theme.AccentHover
    end
end)

DurationModeButton.MouseLeave:Connect(function()
    if isInfiniteDuration then
        DurationModeButton.BackgroundColor3 = Theme.AccentDark
    else
        DurationModeButton.BackgroundColor3 = Theme.Accent
    end
end)

DurationModeButton.MouseButton1Click:Connect(function()
    isInfiniteDuration = not isInfiniteDuration
    updateDurationDisplay()
    saveSettings()
end)

DurationSliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingSlider = true
    end
end)

DurationSliderButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local barPosition = DurationSliderBar.AbsolutePosition.X
        local barSize = DurationSliderBar.AbsoluteSize.X
        local mouseX = input.Position.X
        
        local relativeX = math.clamp(mouseX - barPosition, 0, barSize)
        local percentage = relativeX / barSize
        
        local minDuration = 1
        local maxDuration = 10
        IFramesDuration = math.floor(minDuration + (percentage * (maxDuration - minDuration)) + 0.5)
        
        updateDurationDisplay()
        saveSettings()
    end
end)

DurationSliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local barPosition = DurationSliderBar.AbsolutePosition.X
        local barSize = DurationSliderBar.AbsoluteSize.X
        local mouseX = input.Position.X
        
        local relativeX = math.clamp(mouseX - barPosition, 0, barSize)
        local percentage = relativeX / barSize
        
        local minDuration = 1
        local maxDuration = 10
        IFramesDuration = math.floor(minDuration + (percentage * (maxDuration - minDuration)) + 0.5)
        
        updateDurationDisplay()
        saveSettings()
    end
end)

IFramesButton.MouseButton1Click:Connect(function()
    IFramesEnabled = not IFramesEnabled
    updateIFramesButton()
end)

AntiDebuffButton.MouseButton1Click:Connect(function()
    AntiDebuffEnabled = not AntiDebuffEnabled
    updateAntiDebuffButton()
end)

IFramesKeybindButton.MouseButton1Click:Connect(function()
    if isSettingKeybind then return end
    
    isSettingKeybind = true
    currentKeybindTarget = "IFrames"
    IFramesKeybindButton.Text = "Press a key..."
    IFramesKeybindButton.BackgroundColor3 = Theme.AccentDark
end)

AntiDebuffKeybindButton.MouseButton1Click:Connect(function()
    if isSettingKeybind then return end

    isSettingKeybind = true
    currentKeybindTarget = "AntiDebuff"
    AntiDebuffKeybindButton.Text = "Press a key..."
    AntiDebuffKeybindButton.BackgroundColor3 = Theme.AccentDark
end)

ToggleKeybindUIKeybindButton.MouseButton1Click:Connect(function()
    if isSettingKeybind then return end

    isSettingKeybind = true
    currentKeybindTarget = "ToggleKeybindUI"
    ToggleKeybindUIKeybindButton.Text = "Press a key..."
    ToggleKeybindUIKeybindButton.BackgroundColor3 = Theme.AccentDark
end)

-- Initialize buttons with saved state immediately (GUI elements are already created)
updateIFramesButton()
updateAntiDebuffButton()
updateDurationDisplay()

SelfDestructButton.MouseButton1Click:Connect(function()
    -- Prevent multiple clicks
    if not ScriptActive then return end
    
    -- Disable the script immediately
    ScriptActive = false
    
    -- Disable both features
    IFramesEnabled = false
    AntiDebuffEnabled = false


    
    -- Apply a short IFrames duration to cancel any ongoing infinite IFrames
    pcall(function()
        apply_status("IFrames", 1)
    end)
    
    -- Disconnect the status remote connection
    if StatusRemoteConnection then
        StatusRemoteConnection:Disconnect()
        StatusRemoteConnection = nil
    end
    
    -- Update UI to show deactivated state
    if StatusValue then
        StatusValue.Text = "Deactivated"
        StatusValue.TextColor3 = Theme.Danger
    end
    
    -- Wait a moment to ensure the loop stops
    task.wait(0.2)
    
    -- Safely destroy the GUI
    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end)

updateDurationDisplay()

MinimizeButton.MouseEnter:Connect(function()
    MinimizeButton.BackgroundColor3 = Theme.NeutralButtonHover
end)

MinimizeButton.MouseLeave:Connect(function()
    MinimizeButton.BackgroundColor3 = Theme.NeutralButton
end)

MinimizeButton.MouseButton1Click:Connect(function()
    GuiVisible = false
    
    -- Fade out animation
    local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    for _, child in ipairs(MainFrame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            TweenService:Create(child, fadeInfo, {TextTransparency = 1}):Play()
            pcall(function()
                TweenService:Create(child, fadeInfo, {TextStrokeTransparency = 1}):Play()
            end)
        elseif child:IsA("Frame") and child.Name ~= "Shadow" then
            TweenService:Create(child, fadeInfo, {BackgroundTransparency = 1}):Play()
        elseif child:IsA("UIStroke") then
            TweenService:Create(child, fadeInfo, {Transparency = 1}):Play()
        end
    end
    
    TweenService:Create(Shadow, fadeInfo, {ImageTransparency = 1}):Play()
    
    local mainFadeTween = TweenService:Create(MainFrame, fadeInfo, {BackgroundTransparency = 1})
    mainFadeTween:Play()
    
    mainFadeTween.Completed:Connect(function()
        MainFrame.Visible = false
    end)
end)

CloseButton.MouseEnter:Connect(function()
    CloseButton.BackgroundColor3 = Theme.DangerHover
    CloseButton.TextColor3 = Theme.TextPrimary
end)

CloseButton.MouseLeave:Connect(function()
    CloseButton.BackgroundColor3 = Theme.DangerDark
    CloseButton.TextColor3 = Theme.Danger
end)

CloseButton.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    
    -- Disable the script immediately
    ScriptActive = false
    IFramesEnabled = false
    AntiDebuffEnabled = false


    
    -- Apply a short IFrames duration to cancel any ongoing infinite IFrames
    pcall(function()
        apply_status("IFrames", 1)
    end)
    
    -- Disconnect the status remote connection
    if StatusRemoteConnection then
        StatusRemoteConnection:Disconnect()
        StatusRemoteConnection = nil
    end
    
    -- Wait a moment to ensure the loop stops
    task.wait(0.2)
    
    -- Safely destroy the GUI
    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if isSettingKeybind then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if currentKeybindTarget == "IFrames" then
                IFramesKeybind = input.KeyCode
                IFramesKeybindDisplayLabel.Text = "IFrames Keybind: " .. input.KeyCode.Name
                IFramesKeybindButton.Text = "Set Keybind"
                IFramesKeybindButton.BackgroundColor3 = Theme.NeutralDark
                IFramesKeybindKey.Text = input.KeyCode.Name
                saveSettings()
            elseif currentKeybindTarget == "AntiDebuff" then
                AntiDebuffKeybind = input.KeyCode
                AntiDebuffKeybindDisplayLabel.Text = "Anti-Debuff Keybind: " .. input.KeyCode.Name
                AntiDebuffKeybindButton.Text = "Set Keybind"
                AntiDebuffKeybindButton.BackgroundColor3 = Theme.NeutralDark
                AntiDebuffKeybindKey.Text = input.KeyCode.Name
                saveSettings()
            elseif currentKeybindTarget == "ToggleKeybindUI" then
                ToggleKeybindUIKeybind = input.KeyCode
                ToggleKeybindUIKeybindDisplayLabel.Text = "Keybind UI Toggle: " .. input.KeyCode.Name
                ToggleKeybindUIKeybindButton.Text = "Set Keybind"
                ToggleKeybindUIKeybindButton.BackgroundColor3 = Theme.NeutralDark
                saveSettings()
            end

            isSettingKeybind = false
            currentKeybindTarget = nil
        end
    else
        if input.KeyCode == IFramesKeybind then
            IFramesEnabled = not IFramesEnabled
            updateIFramesButton()
        elseif input.KeyCode == AntiDebuffKeybind then
            AntiDebuffEnabled = not AntiDebuffEnabled
            updateAntiDebuffButton()
        elseif input.KeyCode == ToggleKeybindUIKeybind then
            KeybindUIVisible = not KeybindUIVisible
            KeybindDisplay.Visible = KeybindUIVisible
        elseif input.KeyCode == ToggleGuiKeybind then
            GuiVisible = not GuiVisible
            
            if GuiVisible then
                -- Fade in animation
                MainFrame.Visible = true
                MainFrame.BackgroundTransparency = 1
                
                local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                TweenService:Create(MainFrame, fadeInfo, {BackgroundTransparency = 0}):Play()
                TweenService:Create(Shadow, fadeInfo, {ImageTransparency = 0.3}):Play()
                
                for _, child in ipairs(MainFrame:GetDescendants()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        child.TextTransparency = 1
                        TweenService:Create(child, fadeInfo, {TextTransparency = 0}):Play()
                        pcall(function()
                            TweenService:Create(child, fadeInfo, {TextStrokeTransparency = 0.8}):Play()
                        end)
                    elseif child:IsA("Frame") and child.Name ~= "Shadow" then
                        child.BackgroundTransparency = 1
                        TweenService:Create(child, fadeInfo, {BackgroundTransparency = 0}):Play()
                    elseif child:IsA("UIStroke") then
                        child.Transparency = 1
                        TweenService:Create(child, fadeInfo, {Transparency = 0.5}):Play()
                    end
                end
            else
                -- Fade out animation
                local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                for _, child in ipairs(MainFrame:GetDescendants()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        TweenService:Create(child, fadeInfo, {TextTransparency = 1}):Play()
                        pcall(function()
                            TweenService:Create(child, fadeInfo, {TextStrokeTransparency = 1}):Play()
                        end)
                    elseif child:IsA("Frame") and child.Name ~= "Shadow" then
                        TweenService:Create(child, fadeInfo, {BackgroundTransparency = 1}):Play()
                    elseif child:IsA("UIStroke") then
                        TweenService:Create(child, fadeInfo, {Transparency = 1}):Play()
                    end
                end
                
                TweenService:Create(Shadow, fadeInfo, {ImageTransparency = 1}):Play()
                
                local mainFadeTween = TweenService:Create(MainFrame, fadeInfo, {BackgroundTransparency = 1})
                mainFadeTween:Play()
                
                mainFadeTween.Completed:Connect(function()
                    MainFrame.Visible = false
                end)
            end
        end
    end
end)

local dragging = false
local dragInput, mousePos, framePos

TitleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    elseif input == keybindDragInput and draggingKeybindDisplay then
        local delta = input.Position - keybindMousePos
        KeybindDisplay.Position = UDim2.new(
            keybindFramePos.X.Scale,
            keybindFramePos.X.Offset + delta.X,
            keybindFramePos.Y.Scale,
            keybindFramePos.Y.Offset + delta.Y
        )
    end
end)

-- Make KeybindDisplay draggable
KeybindDisplay.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingKeybindDisplay = true
        keybindMousePos = input.Position
        keybindFramePos = KeybindDisplay.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingKeybindDisplay = false
            end
        end)
    end
end)

KeybindDisplay.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        keybindDragInput = input
    end
end)

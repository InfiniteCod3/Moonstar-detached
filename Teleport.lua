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
    ColorSequenceKeypoint.new(0, Theme.Danger),
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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LunarityTeleportGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 580)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -290)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.PanelStroke
MainStroke.Thickness = 1
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = BackgroundGradientSequence
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 3)
AccentLine.BackgroundColor3 = Theme.Accent
AccentLine.BorderSizePixel = 0
AccentLine.Parent = MainFrame

local AccentGrad = Instance.new("UIGradient")
AccentGrad.Color = AccentGradientSequence
AccentGrad.Parent = AccentLine

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -50, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 6)
Title.Font = Enum.Font.GothamBold
Title.Text = "Lunarity Teleporter"
Title.TextSize = 20
Title.TextColor3 = Theme.TextPrimary
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local ExitButton = Instance.new("TextButton")
ExitButton.Size = UDim2.new(0, 30, 0, 30)
ExitButton.Position = UDim2.new(1, -40, 0, 6)
ExitButton.Text = "×"
ExitButton.Font = Enum.Font.GothamBold
ExitButton.TextSize = 24
ExitButton.TextColor3 = Theme.TextPrimary
ExitButton.BackgroundColor3 = Theme.Danger
ExitButton.BorderSizePixel = 0
ExitButton.Parent = MainFrame

local ExitCorner = Instance.new("UICorner")
ExitCorner.CornerRadius = UDim.new(0, 6)
ExitCorner.Parent = ExitButton

ExitButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

ExitButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Size = UDim2.new(1, -20, 0, 16)
Subtitle.Position = UDim2.new(0, 10, 0, 32)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Advanced player and map teleportation"
Subtitle.TextSize = 12
Subtitle.TextColor3 = Theme.TextMuted
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = MainFrame

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -20, 0, 1)
Divider.Position = UDim2.new(0, 10, 0, 54)
Divider.BackgroundColor3 = Theme.Separator
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- Spoofing Toggle
local SpoofToggle = Instance.new("TextButton")
SpoofToggle.Size = UDim2.new(1, -20, 0, 36)
SpoofToggle.Position = UDim2.new(0, 10, 0, 66)
SpoofToggle.BackgroundColor3 = Theme.NeutralDark
SpoofToggle.BorderSizePixel = 0
SpoofToggle.Text = "Spoofing: OFF"
SpoofToggle.Font = Enum.Font.GothamBold
SpoofToggle.TextSize = 14
SpoofToggle.TextColor3 = Theme.TextSecondary
SpoofToggle.Parent = MainFrame

local SpoofToggleCorner = Instance.new("UICorner")
SpoofToggleCorner.CornerRadius = UDim.new(0, 6)
SpoofToggleCorner.Parent = SpoofToggle

local SpoofToggleStroke = Instance.new("UIStroke")
SpoofToggleStroke.Color = Theme.PanelStroke
SpoofToggleStroke.Thickness = 1
SpoofToggleStroke.Transparency = 0.5
SpoofToggleStroke.Parent = SpoofToggle

-- Spoof Player Label
local SpoofLabel = Instance.new("TextLabel")
SpoofLabel.Size = UDim2.new(1, -20, 0, 24)
SpoofLabel.Position = UDim2.new(0, 10, 0, 108)
SpoofLabel.BackgroundColor3 = Theme.Panel
SpoofLabel.BorderSizePixel = 0
SpoofLabel.Text = "Spoof as: None"
SpoofLabel.TextColor3 = Theme.TextMuted
SpoofLabel.TextSize = 11
SpoofLabel.Font = Enum.Font.Gotham
SpoofLabel.Visible = false
SpoofLabel.Parent = MainFrame

local SpoofLabelCorner = Instance.new("UICorner")
SpoofLabelCorner.CornerRadius = UDim.new(0, 4)
SpoofLabelCorner.Parent = SpoofLabel

-- Selected Target Label
local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Size = UDim2.new(1, -20, 0, 32)
SelectedLabel.Position = UDim2.new(0, 10, 0, 138)
SelectedLabel.BackgroundColor3 = Theme.Panel
SelectedLabel.BorderSizePixel = 0
SelectedLabel.Text = "Target: None (Press E to teleport everyone)"
SelectedLabel.TextColor3 = Theme.TextSecondary
SelectedLabel.TextSize = 12
SelectedLabel.Font = Enum.Font.Gotham
SelectedLabel.Parent = MainFrame

local SelectedLabelCorner = Instance.new("UICorner")
SelectedLabelCorner.CornerRadius = UDim.new(0, 6)
SelectedLabelCorner.Parent = SelectedLabel

local SelectedLabelStroke = Instance.new("UIStroke")
SelectedLabelStroke.Color = Theme.PanelStroke
SelectedLabelStroke.Thickness = 1
SelectedLabelStroke.Transparency = 0.6
SelectedLabelStroke.Parent = SelectedLabel

-- Teleport Everyone Button
local TeleportAllButton = Instance.new("TextButton")
TeleportAllButton.Size = UDim2.new(1, -20, 0, 38)
TeleportAllButton.Position = UDim2.new(0, 10, 0, 176)
TeleportAllButton.BackgroundColor3 = Theme.AccentDark
TeleportAllButton.BorderSizePixel = 0
TeleportAllButton.Text = "TELEPORT EVERYONE (E)"
TeleportAllButton.TextColor3 = Theme.TextPrimary
TeleportAllButton.TextSize = 14
TeleportAllButton.Font = Enum.Font.GothamBold
TeleportAllButton.Parent = MainFrame

local TeleportAllCorner = Instance.new("UICorner")
TeleportAllCorner.CornerRadius = UDim.new(0, 6)
TeleportAllCorner.Parent = TeleportAllButton

local TeleportAllGradient = Instance.new("UIGradient")
TeleportAllGradient.Color = AccentGradientSequence
TeleportAllGradient.Rotation = 90
TeleportAllGradient.Parent = TeleportAllButton

-- Teleport Map Parts Button
local TeleportMapButton = Instance.new("TextButton")
TeleportMapButton.Size = UDim2.new(1, -20, 0, 38)
TeleportMapButton.Position = UDim2.new(0, 10, 0, 220)
TeleportMapButton.BackgroundColor3 = Theme.NeutralButton
TeleportMapButton.BorderSizePixel = 0
TeleportMapButton.Text = "TELEPORT MAP PARTS"
TeleportMapButton.TextColor3 = Theme.TextPrimary
TeleportMapButton.TextSize = 14
TeleportMapButton.Font = Enum.Font.GothamBold
TeleportMapButton.Parent = MainFrame

local TeleportMapCorner = Instance.new("UICorner")
TeleportMapCorner.CornerRadius = UDim.new(0, 6)
TeleportMapCorner.Parent = TeleportMapButton

local TeleportMapStroke = Instance.new("UIStroke")
TeleportMapStroke.Color = Theme.PanelStroke
TeleportMapStroke.Thickness = 1
TeleportMapStroke.Transparency = 0.5
TeleportMapStroke.Parent = TeleportMapButton

-- Separator
local Separator2 = Instance.new("Frame")
Separator2.Size = UDim2.new(1, -20, 0, 1)
Separator2.Position = UDim2.new(0, 10, 0, 268)
Separator2.BackgroundColor3 = Theme.Separator
Separator2.BorderSizePixel = 0
Separator2.Parent = MainFrame

-- Player List Label
local ListLabel = Instance.new("TextLabel")
ListLabel.Size = UDim2.new(1, -20, 0, 24)
ListLabel.Position = UDim2.new(0, 10, 0, 276)
ListLabel.BackgroundTransparency = 1
ListLabel.Text = "Select Individual Player:"
ListLabel.TextColor3 = Theme.TextSecondary
ListLabel.TextSize = 13
ListLabel.Font = Enum.Font.GothamSemibold
ListLabel.TextXAlignment = Enum.TextXAlignment.Left
ListLabel.Parent = MainFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 0, 270)
ScrollFrame.Position = UDim2.new(0, 10, 0, 300)
ScrollFrame.BackgroundColor3 = Theme.Panel
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Theme.Accent
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = ScrollFrame

local ScrollStroke = Instance.new("UIStroke")
ScrollStroke.Color = Theme.PanelStroke
ScrollStroke.Thickness = 1
ScrollStroke.Transparency = 0.5
ScrollStroke.Parent = ScrollFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 6)
UIPadding.PaddingLeft = UDim.new(0, 6)
UIPadding.PaddingRight = UDim.new(0, 6)
UIPadding.PaddingBottom = UDim.new(0, 6)
UIPadding.Parent = ScrollFrame

-- Make frame draggable
local dragging = false
local dragInput, mousePos, framePos

Title.InputBegan:Connect(function(input)
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

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

local function updatePlayerList()
    if selectedPlayer and selectedPlayer.Parent then
        SelectedLabel.Text = "Target: " .. selectedPlayer.Name .. " (Press E to teleport)"
        SelectedLabel.TextColor3 = Theme.Success
    else
        selectedPlayer = nil
        SelectedLabel.Text = "Target: None (Press E to teleport everyone)"
        SelectedLabel.TextColor3 = Theme.TextSecondary
    end

    if useSpoofing and spoofPlayer and spoofPlayer.Parent then
        SpoofLabel.Text = "Spoof as: " .. spoofPlayer.Name
        SpoofLabel.TextColor3 = Theme.Accent
    else
        spoofPlayer = nil
        SpoofLabel.Text = "Spoof as: None"
        SpoofLabel.TextColor3 = Theme.TextMuted
    end
    
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerButton = Instance.new("TextButton")
            PlayerButton.Size = UDim2.new(1, -12, 0, 36)
            PlayerButton.BackgroundColor3 = Theme.NeutralButton
            PlayerButton.BorderSizePixel = 0
            PlayerButton.Text = player.Name
            PlayerButton.TextColor3 = Theme.TextPrimary
            PlayerButton.TextSize = 13
            PlayerButton.Font = Enum.Font.Gotham
            PlayerButton.Parent = ScrollFrame
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = PlayerButton
            
            local ButtonStroke = Instance.new("UIStroke")
            ButtonStroke.Color = Theme.PanelStroke
            ButtonStroke.Thickness = 1
            ButtonStroke.Transparency = 0.6
            ButtonStroke.Parent = PlayerButton
            
            local isTarget = selectedPlayer == player
            local isSpoof = spoofPlayer == player and useSpoofing
            
            if isTarget then
                PlayerButton.BackgroundColor3 = Theme.Success
                ButtonStroke.Color = Theme.Accent
                ButtonStroke.Transparency = 0.3
                PlayerButton.Text = player.Name .. (isSpoof and " [TARGET+SPOOF]" or " [TARGET]")
                PlayerButton.Font = Enum.Font.GothamBold
            elseif isSpoof then
                PlayerButton.BackgroundColor3 = Theme.AccentDark
                ButtonStroke.Color = Theme.Accent
                ButtonStroke.Transparency = 0.3
                PlayerButton.Text = player.Name .. " [SPOOF]"
                PlayerButton.Font = Enum.Font.GothamSemibold
            end
            
            PlayerButton.MouseEnter:Connect(function()
                if not isTarget and not isSpoof then
                    PlayerButton.BackgroundColor3 = Theme.NeutralButtonHover
                end
            end)
            
            PlayerButton.MouseLeave:Connect(function()
                if not isTarget and not isSpoof then
                    PlayerButton.BackgroundColor3 = Theme.NeutralButton
                end
            end)
            
            PlayerButton.MouseButton1Click:Connect(function()
                if selectedPlayer == player then
                    selectedPlayer = nil
                else
                    selectedPlayer = player
                end
                updatePlayerList()
            end)
            
            PlayerButton.MouseButton2Click:Connect(function()
                if useSpoofing then
                    if spoofPlayer == player then
                        spoofPlayer = nil
                    else
                        spoofPlayer = player
                    end
                    updatePlayerList()
                end
            end)
        end
    end
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 12)
end


-- Spoofing Toggle Logic 
SpoofToggle.MouseButton1Click:Connect(function()
    useSpoofing = not useSpoofing
    if useSpoofing then
        SpoofToggle.Text = "Spoofing: ON"
        SpoofToggle.BackgroundColor3 = Theme.Success
        SpoofToggle.TextColor3 = Theme.TextPrimary
        SpoofLabel.Visible = true
    else
        SpoofToggle.Text = "Spoofing: OFF"
        SpoofToggle.BackgroundColor3 = Theme.NeutralDark
        SpoofToggle.TextColor3 = Theme.TextSecondary
        SpoofLabel.Visible = false
        spoofPlayer = nil 
        SpoofLabel.Text = "Spoof as: None"
    end
    updatePlayerList() 
end)

SpoofToggle.MouseEnter:Connect(function()
    if useSpoofing then
        SpoofToggle.BackgroundColor3 = Theme.AccentHover
    else
        SpoofToggle.BackgroundColor3 = Theme.NeutralButtonHover
    end
end)

SpoofToggle.MouseLeave:Connect(function()
    if useSpoofing then
        SpoofToggle.BackgroundColor3 = Theme.Success
    else
        SpoofToggle.BackgroundColor3 = Theme.NeutralDark
    end
end)

TeleportAllButton.MouseEnter:Connect(function()
    TeleportAllButton.BackgroundColor3 = Theme.AccentHover
end)

TeleportAllButton.MouseLeave:Connect(function()
    TeleportAllButton.BackgroundColor3 = Theme.AccentDark
end)

TeleportMapButton.MouseEnter:Connect(function()
    TeleportMapButton.BackgroundColor3 = Theme.NeutralButtonHover
end)

TeleportMapButton.MouseLeave:Connect(function()
    TeleportMapButton.BackgroundColor3 = Theme.NeutralButton
end)

TeleportMapButton.MouseLeave:Connect(function()
    TeleportMapButton.BackgroundColor3 = Theme.NeutralButton
end)

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

local function teleportEveryone()
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

local function teleportMapParts()
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

TeleportAllButton.MouseButton1Click:Connect(teleportEveryone)
TeleportMapButton.MouseButton1Click:Connect(teleportMapParts)

task.spawn(function()
    while task.wait(2) do
        updatePlayerList()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        if selectedPlayer then
            teleportPlayerToYou(selectedPlayer, true)
        else
            teleportEveryone()
        end
    end
end)
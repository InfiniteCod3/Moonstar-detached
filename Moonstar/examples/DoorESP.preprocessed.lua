-- Door ESP for Halloween Event with In-Game Menu + Console + Unload + Auto Candy Trigger
-- Uses DoorType attribute on each Door under:
-- Workspace/World/Trick or Treat/Map/Halloween Map/Doors
--
-- Types:
--  - "Evil"
--  - "Nothing"
--  - "Souls"
--  - "Candy"
--
-- Intended for client-side execution (LocalScript / executor).
-- UI is placed in CoreGui to minimize detection by game UIs.
-- Auto trigger logic follows the same door structure/attributes used in Halloweenevent.lua
-- (replication there uses DoorActivation with Door + DoorType; here we simulate local trigger
--  by using the Door models and their DoorType attributes client-side).

-- // Duplicate protection: clean up old instance if re-executed
local CoreGui = game:GetService("CoreGui")
local existing = CoreGui:FindFirstChild("DoorESP_Menu")
if existing then
    existing:Destroy()
end
local existingConsole = CoreGui:FindFirstChild("DoorESP_Console")
if existingConsole then
    existingConsole:Destroy()
end
local existingFolder = workspace:FindFirstChild("DoorESP_Objects")
if existingFolder then
    existingFolder:Destroy()
end

-- // CONFIG (defaults, can be changed from menu)
local REFRESH_INTERVAL_DEFAULT = 2
local USE_BILLBOARD_DEFAULT = true
local SHOW_TRACERS_DEFAULT = false
local MAX_DISTANCE_DEFAULT = 1000
local UI_TOGGLE_KEY = Enum.KeyCode.RightControl -- toggle menu visibility
local CONSOLE_TOGGLE_KEY = Enum.KeyCode.RightAlt -- toggle console visibility

local TYPE_COLORS_DEFAULT = {
    Evil = Color3.fromRGB(255, 60, 60),
    Candy = Color3.fromRGB(255, 170, 0),
    Souls = Color3.fromRGB(0, 255, 255),
    Nothing = Color3.fromRGB(160, 160, 160),
}

local UNKNOWN_COLOR_DEFAULT = Color3.fromRGB(255, 255, 255)

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LOADER_SCRIPT_ID = "doorEsp"
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

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Try to grab the same style remote setup as Halloweenevent / Replicator
local ReplicatorRemotesFolder = nil
local HallowRemote = nil
do
    -- Halloweenevent.lua is required by Replicator.lua via script.Remotes / ReplicatedStorage.Remotes.Replicator
    -- We mirror that pattern if available to send proper "DoorActivation" events instead of purely local interaction.
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes and remotes:FindFirstChild("Replicator") then
        HallowRemote = remotes.Replicator
    end
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

-- // State (runtime, synced with menu)
local Settings = {
    Enabled = true,
    RefreshInterval = REFRESH_INTERVAL_DEFAULT,
    UseBillboard = USE_BILLBOARD_DEFAULT,
    ShowTracers = SHOW_TRACERS_DEFAULT,
    MaxDistance = MAX_DISTANCE_DEFAULT,
    TypeColors = table.clone(TYPE_COLORS_DEFAULT),
    UnknownColor = UNKNOWN_COLOR_DEFAULT,

    AutoCandy = false,           -- NEW: auto trigger Candy doors
    AutoCandyRadius = 80,        -- Only auto trigger candy doors within this radius of player
    AutoCandyDelay = 0.2,        -- Delay between individual candy door triggers
}

-- ESP container
local espFolder = Instance.new("Folder")
espFolder.Name = "DoorESP_Objects"
espFolder.Parent = workspace

-- Console state
local ConsoleGui -- assigned later
local logListFrame
local logLayout
local MAX_LOGS = 200

-- Connections for cleanup
local Connections = {}
local TracerObjects = {}

local unloaded = false

-- Forward declarations
local scanDoors
local autoTriggerCandyDoors

-- // Utility: logging to console GUI
local function addConnection(conn)
    if conn then
        table.insert(Connections, conn)
    end
end

local function logMessage(text)
    if unloaded then
        return
    end
    if not ConsoleGui or not logListFrame or not logLayout then
        return
    end

    local children = logListFrame:GetChildren()
    local count = 0
    for _, c in ipairs(children) do
        if c:IsA("TextLabel") then
            count = count + (1)
        end
    end
    if count >= MAX_LOGS then
        for _, c in ipairs(children) do
            if c:IsA("TextLabel") then
                c:Destroy()
                count = count - (1)
                if count < MAX_LOGS then
                    break
                end
            end
        end
    end

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -4, 0, 16)
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextSize = 12
    label.TextWrapped = false
    label.TextColor3 = Theme.TextSecondary
    label.Text = os.date("[%H:%M:%S] ") .. tostring(text)
    label.Parent = logListFrame
end

-- // Utility: safely get character root
local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function removeAllESP()
    if espFolder then
        espFolder:ClearAllChildren()
    end

    for _, obj in ipairs(TracerObjects) do
        if obj then
            pcall(function() obj:Remove() end)
        end
    end
    TracerObjects = {}
end

-- // Full unload: like script never ran
local function unloadAll()
    if unloaded then
        return
    end
    unloaded = true

    for _, conn in ipairs(Connections) do
        pcall(function()
            if conn and conn.Disconnect then
                conn:Disconnect()
            end
        end)
    end
    Connections = {}

    removeAllESP()
    if espFolder and espFolder.Parent then
        espFolder:Destroy()
    end

    if ConsoleGui and ConsoleGui.Parent then
        ConsoleGui:Destroy()
    end
    local menuGui = CoreGui:FindFirstChild("DoorESP_Menu")
    if menuGui then
        menuGui:Destroy()
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
        return false, "Missing loader token"
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

    local success, response = pcall(HttpRequestInvoker, {
        Url = validateUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json",
        },
        Body = encodedPayload,
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

    return true, decoded
end

local function enforceLoaderWhitelist()
    if not LoaderAccess or LoaderAccess.scriptId ~= LOADER_SCRIPT_ID then
        warn("[DoorESP] This script must be loaded via the official loader.")
        unloadAll()
        return false
    end

    local ok, response = requestLoaderValidation(true)
    if not ok then
        warn("[DoorESP] Loader validation failed: " .. tostring(response))
        unloadAll()
        return false
    end

    if response.killSwitch then
        warn("[DoorESP] Loader kill switch active. Aborting.")
        unloadAll()
        return false
    end

    local refreshInterval = math.clamp(LoaderAccess.refreshInterval or 90, 30, 240)
    task.spawn(function()
        while not unloaded do
            task.wait(refreshInterval)
            local valid, data = requestLoaderValidation(true)
            if not valid or (data and data.killSwitch) then
                warn("[DoorESP] Access revoked or kill switch triggered. Unloading.")
                unloadAll()
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

-- // UI Helpers
local function createDraggable(frame, dragArea)
    dragArea = dragArea or frame
    local dragging = false
    local dragStart, startPos

    local function inputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if conn then
                        conn:Disconnect()
                    end
                end
            end)
        end
    end

    local function inputChanged(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end

    addConnection(dragArea.InputBegan:Connect(inputBegan))
    addConnection(dragArea.InputChanged:Connect(inputChanged))
end

-- // Console GUI
local function createConsole()
    local oldConsole = CoreGui:FindFirstChild("DoorESP_Console")
    if oldConsole then
        oldConsole:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DoorESP_Console"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = CoreGui
    ConsoleGui = screenGui

    local frame = Instance.new("Frame")
    frame.Name = "ConsoleMain"
    frame.Size = UDim2.new(0, 360, 0, 220)
    frame.Position = UDim2.new(1, -380, 0.15, 0)
    frame.BackgroundColor3 = Theme.Background
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Theme.PanelStroke
    stroke.Transparency = 0.2
    stroke.Parent = frame

    local grad = Instance.new("UIGradient")
    grad.Color = BackgroundGradientSequence
    grad.Rotation = 90
    grad.Parent = frame

    local accentLine = Instance.new("Frame")
    accentLine.Name = "Accent"
    accentLine.Size = UDim2.new(1, 0, 0, 3)
    accentLine.Position = UDim2.new(0, 0, 0, 0)
    accentLine.BackgroundColor3 = Theme.Accent
    accentLine.BorderSizePixel = 0
    accentLine.Parent = frame

    local accentGradient = Instance.new("UIGradient")
    accentGradient.Color = AccentGradientSequence
    accentGradient.Parent = accentLine

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 24)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = frame

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 6, 0, 0)
    title.Font = Enum.Font.GothamSemibold
    title.Text = "Lunarity · Door Console"
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Theme.TextPrimary
    title.Parent = titleBar

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "LogFrame"
    scroll.BackgroundTransparency = 1
    scroll.Size = UDim2.new(1, -8, 1, -32)
    scroll.Position = UDim2.new(0, 4, 0, 26)
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.BottomImage = "rbxassetid://7445543667"
    scroll.TopImage = "rbxassetid://7445543667"
    scroll.MidImage = "rbxassetid://7445543667"
    scroll.ScrollBarImageColor3 = Theme.Accent
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
        scroll.CanvasPosition = Vector2.new(0, math.max(0, layout.AbsoluteContentSize.Y - scroll.AbsoluteWindowSize.Y + 4))
    end)

    logListFrame = scroll
    logLayout = layout

    createDraggable(frame, titleBar)

    addConnection(UserInputService.InputBegan:Connect(function(input, gp)
        if gp or unloaded then
            return
        end
        if input.KeyCode == CONSOLE_TOGGLE_KEY then
            screenGui.Enabled = not screenGui.Enabled
        end
    end))

    logMessage("Lunarity console initialized")
    return screenGui
end

-- // Main menu GUI in CoreGui
local function createMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DoorESP_Menu"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = CoreGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 320, 0, 320)
    main.Position = UDim2.new(0, 40, 0.5, -160)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = main

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Thickness = 1
    mainStroke.Color = Theme.PanelStroke
    mainStroke.Transparency = 0.2
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent = main

    local gradient = Instance.new("UIGradient")
    gradient.Color = BackgroundGradientSequence
    gradient.Rotation = 45
    gradient.Parent = main

    local accentLine = Instance.new("Frame")
    accentLine.Name = "Accent"
    accentLine.Size = UDim2.new(1, 0, 0, 3)
    accentLine.Position = UDim2.new(0, 0, 0, 0)
    accentLine.BackgroundColor3 = Theme.Accent
    accentLine.BorderSizePixel = 0
    accentLine.Parent = main

    local accentGradient = Instance.new("UIGradient")
    accentGradient.Color = AccentGradientSequence
    accentGradient.Parent = accentLine

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = main

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -90, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.Text = "Lunarity · Door ESP"
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.TextStrokeTransparency = 0.85
    titleLabel.TextStrokeColor3 = Theme.AccentDark
    titleLabel.Parent = titleBar

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(0, 80, 1, 0)
    subtitle.Position = UDim2.new(1, -85, 0, 0)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "Ops Toolkit"
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Right
    subtitle.TextColor3 = Theme.TextSecondary
    subtitle.Parent = titleBar

    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.BackgroundColor3 = Theme.Separator
    divider.BorderSizePixel = 0
    divider.Size = UDim2.new(1, -20, 0, 1)
    divider.Position = UDim2.new(0, 10, 0, 30)
    divider.Parent = main

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 38)
    content.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    local function createToggle(text, initial, onChanged)
        local holder = Instance.new("Frame")
        holder.Name = text .. "_Toggle"
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, 0, 0, 22)
        holder.Parent = content

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -40, 1, 0)
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Theme.TextSecondary
        label.Parent = holder

        local button = Instance.new("TextButton")
        button.Name = "Toggle"
        button.Size = UDim2.new(0, 32, 0, 18)
        button.Position = UDim2.new(1, -34, 0.5, -9)
        button.AutoButtonColor = false
        button.BackgroundColor3 = initial and Theme.Accent or Theme.NeutralButton
        button.Text = initial and "ON" or "OFF"
        button.Font = Enum.Font.GothamSemibold
        button.TextSize = 10
        button.TextColor3 = initial and Theme.TextPrimary or Theme.TextMuted
        button.BorderSizePixel = 0
        button.Parent = holder

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = button

        local function updateVisual(state)
            button.Text = state and "ON" or "OFF"
            button.BackgroundColor3 = state and Theme.Accent or Theme.NeutralButton
            button.TextColor3 = state and Theme.TextPrimary or Theme.TextMuted
        end

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = initial and Theme.AccentHover or Theme.NeutralButtonHover
        end)

        button.MouseLeave:Connect(function()
            updateVisual(initial)
        end)

        button.MouseButton1Click:Connect(function()
            if unloaded then
                return
            end
            initial = not initial
            updateVisual(initial)
            onChanged(initial)
        end)

        updateVisual(initial)
    end

    local function createNumberBox(text, initial, minValue, maxValue, onChanged)
        local holder = Instance.new("Frame")
        holder.Name = text .. "_Number"
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, 0, 0, 24)
        holder.Parent = content

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -70, 1, 0)
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Theme.TextSecondary
        label.Parent = holder

        local box = Instance.new("TextBox")
        box.Name = "Input"
        box.Size = UDim2.new(0, 60, 0, 18)
        box.Position = UDim2.new(1, -62, 0.5, -9)
        box.BackgroundColor3 = Theme.NeutralDark
        box.BorderSizePixel = 0
        box.Font = Enum.Font.Gotham
        box.Text = tostring(initial)
        box.TextSize = 11
        box.TextColor3 = Theme.TextPrimary
        box.ClearTextOnFocus = false
        box.Parent = holder

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = box

        box.Focused:Connect(function()
            box.BackgroundColor3 = Theme.NeutralButtonHover
        end)

        box.FocusLost:Connect(function(enterPressed)
            if unloaded then
                return
            end
            box.BackgroundColor3 = Theme.NeutralDark
            if not enterPressed then
                box.Text = tostring(initial)
                return
            end
            local n = tonumber(box.Text)
            if not n then
                box.Text = tostring(initial)
                return
            end
            n = math.clamp(n, minValue, maxValue)
            initial = n
            box.Text = tostring(n)
            onChanged(n)
        end)
    end

    local function createButton(text, color, onClick)
        local btn = Instance.new("TextButton")
        btn.Name = text .. "_Button"
        btn.BackgroundColor3 = color
        btn.Size = UDim2.new(0.5, -4, 0, 24)
        btn.Text = text
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 12
        btn.TextColor3 = Theme.TextPrimary
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = btn

        local gradient = Instance.new("UIGradient")
        gradient.Color = (color == Theme.DangerDark) and DangerGradientSequence or AccentGradientSequence
        gradient.Parent = btn

        btn.MouseEnter:Connect(function()
            if color == Theme.DangerDark then
                btn.BackgroundColor3 = Theme.DangerHover
            else
                btn.BackgroundColor3 = Theme.AccentHover
            end
        end)

        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = color
        end)

        btn.MouseButton1Click:Connect(function()
            if unloaded then
                return
            end
            onClick()
        end)

        return btn
    end

    -- Core toggles
    createToggle("ESP Enabled", Settings.Enabled, function(value)
        Settings.Enabled = value
        logMessage("ESP Enabled set to " .. tostring(value))
        if not value then
            removeAllESP()
        end
    end)

    createToggle("Billboard Labels", Settings.UseBillboard, function(value)
        Settings.UseBillboard = value
        logMessage("Billboard Labels set to " .. tostring(value))
        removeAllESP()
    end)

    createToggle("Tracers", Settings.ShowTracers, function(value)
        Settings.ShowTracers = value
        logMessage("Tracers set to " .. tostring(value))
        removeAllESP()
    end)

    -- New: Auto Candy Door trigger toggle
    createToggle("Auto Candy Doors", Settings.AutoCandy, function(value)
        Settings.AutoCandy = value
        logMessage("Auto Candy Doors set to " .. tostring(value))
    end)

    -- Number boxes
    createNumberBox("Max Distance", Settings.MaxDistance or 9999, 50, 9999, function(value)
        Settings.MaxDistance = value
        logMessage("Max Distance set to " .. tostring(value))
        removeAllESP()
    end)

    createNumberBox("Refresh (sec)", Settings.RefreshInterval, 0.2, 10, function(value)
        Settings.RefreshInterval = value
        logMessage("Refresh Interval set to " .. tostring(value))
    end)

    createNumberBox("Auto Candy Radius", Settings.AutoCandyRadius, 10, 500, function(value)
        Settings.AutoCandyRadius = value
        logMessage("Auto Candy Radius set to " .. tostring(value))
    end)

    -- Control buttons row (Manual Refresh + Unload)
    local row = Instance.new("Frame")
    row.Name = "ButtonsRow"
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, 0, 0, 26)
    row.Parent = content

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Padding = UDim.new(0, 6)
    rowLayout.Parent = row

    local manualRefreshButton = createButton("Manual Refresh", Theme.Accent, function()
        logMessage("Manual refresh triggered")
        pcall(scanDoors)
    end)
    manualRefreshButton.Parent = row

    local unloadButton = createButton("Unload", Theme.DangerDark, function()
        logMessage("Unload requested from menu")
        unloadAll()
    end)
    unloadButton.Parent = row

    local hint = Instance.new("TextLabel")
    hint.Name = "Hint"
    hint.BackgroundTransparency = 1
    hint.Size = UDim2.new(1, 0, 0, 30)
    hint.Font = Enum.Font.Gotham
    hint.Text = "Menu: " .. UI_TOGGLE_KEY.Name .. "  |  Console: " .. CONSOLE_TOGGLE_KEY.Name
    hint.TextSize = 11
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.TextYAlignment = Enum.TextYAlignment.Top
    hint.TextColor3 = Theme.TextMuted
    hint.TextWrapped = true
    hint.Parent = content

    createDraggable(main, titleBar)

    addConnection(UserInputService.InputBegan:Connect(function(input, gp)
        if gp or unloaded then
            return
        end
        if input.KeyCode == UI_TOGGLE_KEY then
            screenGui.Enabled = not screenGui.Enabled
        end
    end))

    logMessage("Lunarity DoorESP menu initialized")
    return screenGui
end

-- // ESP primitives
local function createBillboard(parentPart, labelText, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DoorESP_Billboard"
    billboard.Adornee = parentPart
    billboard.Size = UDim2.new(0, 110, 0, 30)
    billboard.StudsOffset = Vector3.new(0, parentPart.Size.Y + 1.5, 0)
    billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Name = "Background"
    frame.BackgroundTransparency = 0.15
    frame.BackgroundColor3 = Theme.Panel
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Parent = billboard

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = color
    stroke.Transparency = 0
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = BackgroundGradientSequence
    gradient.Parent = frame

    local text = Instance.new("TextLabel")
    text.Name = "Label"
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, -6, 1, -4)
    text.Position = UDim2.new(0, 3, 0, 2)
    text.Font = Enum.Font.GothamBold
    text.Text = labelText
    text.TextColor3 = color
    text.TextStrokeTransparency = 0.3
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.TextSize = 13
    text.TextWrapped = true
    text.Parent = frame

    billboard.Parent = espFolder
    return billboard
end

local function createHighlight(targetPart, color)
    local highlight = Instance.new("Highlight")
    highlight.Name = "DoorESP_Highlight"
    highlight.Adornee = targetPart
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = espFolder
    return highlight
end

local function createTracer()
    if not Settings.ShowTracers or not Drawing then
        return nil
    end
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Transparency = 1
    line.Visible = true
    table.insert(TracerObjects, line)
    return line
end

-- // Main ESP application for one door
local function applyESPToDoor(doorModel)
    if not Settings.Enabled or unloaded then
        return
    end
    if not doorModel then
        return
    end

    local doorPart = doorModel:FindFirstChild("Door") or doorModel:FindFirstChildWhichIsA("BasePart")
    if not doorPart or not doorPart:IsA("BasePart") then
        return
    end

    local doorType = doorPart:GetAttribute("DoorType") or doorModel:GetAttribute("DoorType") or "Unknown"
    local color = Settings.TypeColors[doorType] or Settings.UnknownColor
    local label = doorType

    local hrp = getRoot()
    if hrp and Settings.MaxDistance and (doorPart.Position - hrp.Position).Magnitude > Settings.MaxDistance then
        return
    end

    if Settings.UseBillboard then
        createBillboard(doorPart, ("[%s] Door"):format(label), color)
    end

    createHighlight(doorPart, color)

    if Settings.ShowTracers and Drawing then
        local tracer = createTracer()
        if tracer then
            tracer.Color = color
            local conn
            conn = RunService.RenderStepped:Connect(function()
                if unloaded or not Settings.Enabled or not Settings.ShowTracers then
                    if tracer then tracer:Remove() end
                    if conn then conn:Disconnect() end
                    return
                end

                if not doorPart or not doorPart.Parent then
                    if tracer then tracer:Remove() end
                    if conn then conn:Disconnect() end
                    return
                end

                local hrpNow = getRoot()
                if not hrpNow then
                    tracer.Visible = false
                    return
                end

                local doorPos, doorOnScreen = camera:WorldToViewportPoint(doorPart.Position)
                local rootPos, rootOnScreen = camera:WorldToViewportPoint(hrpNow.Position)

                if doorOnScreen and rootOnScreen then
                    tracer.Visible = true
                    tracer.From = Vector2.new(rootPos.X, rootPos.Y)
                    tracer.To = Vector2.new(doorPos.X, doorPos.Y)
                else
                    tracer.Visible = false
                end
            end)
            addConnection(conn)
        end
    end
end

-- // Scan all doors
scanDoors = function()
    if unloaded then
        return
    end
    removeAllESP()
    if not Settings.Enabled then
        return
    end

    local world = workspace:FindFirstChild("World")
    if not world then
        logMessage("World not found")
        return
    end

    local trickOrTreat = world:FindFirstChild("Trick or Treat")
    if not trickOrTreat then
        logMessage("Trick or Treat not found")
        return
    end

    local map = trickOrTreat:FindFirstChild("Map")
    if not map then
        logMessage("Map not found")
        return
    end

    local halloweenMap = map:FindFirstChild("Halloween Map")
    if not halloweenMap then
        logMessage("Halloween Map not found")
        return
    end

    local doorsFolder = halloweenMap:FindFirstChild("Doors")
    if not doorsFolder then
        logMessage("Doors folder not found")
        return
    end

    local count = 0
    for _, doorModel in ipairs(doorsFolder:GetChildren()) do
        applyESPToDoor(doorModel)
        count = count + (1)
    end

    logMessage("Scan complete - processed " .. tostring(count) .. " door(s)")
end

-- // Auto-trigger Candy doors (client-side based on DoorType)
autoTriggerCandyDoors = function()
    if unloaded or not Settings.AutoCandy then
        return
    end

    local world = workspace:FindFirstChild("World")
    if not world then
        return
    end
    local trickOrTreat = world:FindFirstChild("Trick or Treat")
    if not trickOrTreat then
        return
    end
    local map = trickOrTreat:FindFirstChild("Map")
    if not map then
        return
    end
    local halloweenMap = map:FindFirstChild("Halloween Map")
    if not halloweenMap then
        return
    end
    local doorsFolder = halloweenMap:FindFirstChild("Doors")
    if not doorsFolder then
        return
    end

    local hrp = getRoot()
    if not hrp then
        return
    end

    local triggered = 0
    for _, doorModel in ipairs(doorsFolder:GetChildren()) do
        if unloaded or not Settings.AutoCandy then
            break
        end

        local doorPart = doorModel:FindFirstChild("Door") or doorModel:FindFirstChildWhichIsA("BasePart")
        if doorPart and doorPart:IsA("BasePart") then
            local doorType = doorPart:GetAttribute("DoorType") or doorModel:GetAttribute("DoorType")
            if doorType == "Candy" then
                local dist = (doorPart.Position - hrp.Position).Magnitude
                if dist <= (Settings.AutoCandyRadius or 80) then
                    triggered = triggered + (1)

                    -- Preferred: use same style remote replication if available
                    if HallowRemote and HallowRemote.FireServer then
                        -- Following pattern from Halloweenevent.lua: Replication == "DoorActivation"
                        -- with Door and DoorType.
                        pcall(function()
                            HallowRemote:FireServer("Halloweenevent", {
                                Replication = "DoorActivation",
                                Door = doorPart.Parent or doorPart,
                                DoorType = "Candy",
                            })
                        end)
                    else
                        -- Fallback: try firing door click detectors / ProximityPrompts
                        local fired = false
                        for _, d in ipairs(doorPart:GetDescendants()) do
                            if d:IsA("ClickDetector") then
                                pcall(function()
                                    fireclickdetector(d)
                                end)
                                fired = true
                                break
                            elseif d:IsA("ProximityPrompt") then
                                pcall(function()
                                    fireproximityprompt(d)
                                end)
                                fired = true
                                break
                            end
                        end
                        if not fired then
                            -- Try on main doorPart too
                            for _, d in ipairs(doorPart:GetChildren()) do
                                if d:IsA("ClickDetector") then
                                    pcall(function()
                                        fireclickdetector(d)
                                    end)
                                    break
                                elseif d:IsA("ProximityPrompt") then
                                    pcall(function()
                                        fireproximityprompt(d)
                                    end)
                                    break
                                end
                            end
                        end
                    end

                    if Settings.AutoCandyDelay and Settings.AutoCandyDelay > 0 then
                        task.wait(Settings.AutoCandyDelay)
                    end
                end
            end
        end
    end

    if triggered > 0 then
        logMessage("AutoCandy: attempted to trigger " .. tostring(triggered) .. " Candy door(s)")
    end
end

-- // Initialize UIs
local menuGui = createMenu()
local consoleGui = createConsole()

-- // Keep a dummy connection so we track for cleanup
addConnection(RunService.Heartbeat:Connect(function() end))

-- // Auto-refresh + AutoCandy loop
task.spawn(function()
    while not unloaded do
        local interval = Settings.RefreshInterval or REFRESH_INTERVAL_DEFAULT
        if interval < 0.05 then
            interval = 0.05
        end

        pcall(scanDoors)
        pcall(autoTriggerCandyDoors)

        local t = tick() + interval
        while tick() < t and not unloaded do
            task.wait(0.05)
        end
    end
end)

-- // Initial scan
pcall(scanDoors)
logMessage("Lunarity DoorESP initialized with Auto Candy support")
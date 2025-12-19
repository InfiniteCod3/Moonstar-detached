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

-- // Console GUI using LunarityUI
local function createConsole()
    local oldConsole = CoreGui:FindFirstChild("DoorESP_Console")
    if oldConsole then
        oldConsole:Destroy()
    end

    local window = LunarityUI.CreateWindow({
        Name = "DoorESP_Console",
        Title = "Lunarity",
        Subtitle = "Console",
        Size = UDim2.new(0, 360, 0, 220),
        Position = UDim2.new(1, -380, 0.15, 0),
        Minimizable = true,
        Closable = false,
    })
    
    ConsoleGui = window.ScreenGui
    logListFrame = window.Content
    
    -- Get the layout from content
    local layout = window.Content:FindFirstChildOfClass("UIListLayout")
    if layout then
        logLayout = layout
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            window.Content.CanvasPosition = Vector2.new(0, math.max(0, layout.AbsoluteContentSize.Y - window.Content.AbsoluteWindowSize.Y + 4))
        end)
    end

    window.addConnection(UserInputService.InputBegan:Connect(function(input, gp)
        if gp or unloaded then
            return
        end
        if input.KeyCode == CONSOLE_TOGGLE_KEY then
            window.ScreenGui.Enabled = not window.ScreenGui.Enabled
        end
    end))

    logMessage("Lunarity console initialized")
    return window.ScreenGui
end

-- // Main menu GUI using LunarityUI
local function createMenu()
    local window = LunarityUI.CreateWindow({
        Name = "DoorESP_Menu",
        Title = "Lunarity",
        Subtitle = "Door ESP",
        Size = UDim2.new(0, 320, 0, 380),
        Position = UDim2.new(0, 40, 0.5, -190),
        OnClose = function()
            unloadAll()
        end
    })
    
    local Theme = LunarityUI.Theme

    window.createSection("ESP Settings")
    
    -- Core toggles
    window.createToggle("ESP Enabled", Settings.Enabled, function(value)
        Settings.Enabled = value
        logMessage("ESP Enabled set to " .. tostring(value))
        if not value then
            removeAllESP()
        end
    end)

    window.createToggle("Billboard Labels", Settings.UseBillboard, function(value)
        Settings.UseBillboard = value
        logMessage("Billboard Labels set to " .. tostring(value))
        removeAllESP()
    end)

    window.createToggle("Tracers", Settings.ShowTracers, function(value)
        Settings.ShowTracers = value
        logMessage("Tracers set to " .. tostring(value))
        removeAllESP()
    end)

    window.createToggle("Auto Candy Doors", Settings.AutoCandy, function(value)
        Settings.AutoCandy = value
        logMessage("Auto Candy Doors set to " .. tostring(value))
    end)

    window.createSeparator()
    window.createSection("Distance & Timing")

    -- Number inputs
    window.createNumberBox("Max Distance", Settings.MaxDistance or 9999, 50, 9999, function(value)
        Settings.MaxDistance = value
        logMessage("Max Distance set to " .. tostring(value))
        removeAllESP()
    end)

    window.createNumberBox("Refresh (sec)", Settings.RefreshInterval, 0.2, 10, function(value)
        Settings.RefreshInterval = value
        logMessage("Refresh Interval set to " .. tostring(value))
    end)

    window.createNumberBox("Auto Candy Radius", Settings.AutoCandyRadius, 10, 500, function(value)
        Settings.AutoCandyRadius = value
        logMessage("Auto Candy Radius set to " .. tostring(value))
    end)

    window.createSeparator()
    window.createSection("Controls")

    -- Control buttons
    window.createButton("Manual Refresh", function()
        logMessage("Manual refresh triggered")
        pcall(scanDoors)
    end, true)

    window.createButton("Unload Script", function()
        logMessage("Unload requested from menu")
        unloadAll()
    end, false)

    window.createSeparator()
    
    -- Hint label
    window.createInfoLabel("Menu: " .. UI_TOGGLE_KEY.Name .. "  |  Console: " .. CONSOLE_TOGGLE_KEY.Name)

    window.addConnection(UserInputService.InputBegan:Connect(function(input, gp)
        if gp or unloaded then
            return
        end
        if input.KeyCode == UI_TOGGLE_KEY then
            window.ScreenGui.Enabled = not window.ScreenGui.Enabled
        end
    end))

    logMessage("Lunarity DoorESP menu initialized")
    return window.ScreenGui
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
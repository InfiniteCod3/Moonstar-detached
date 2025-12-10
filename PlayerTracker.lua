-- // Player Tracker // --
-- // Lunarity UI Style // --
-- // Hold Right Click to Track Closest Player with Prediction // --

local LOADER_SCRIPT_ID = "playerTracker"
local LoaderAccess = rawget(getgenv(), "LunarityAccess")
local HttpService = game:GetService("HttpService")

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

local function buildValidateUrl()
    if not LoaderAccess then return nil end
    if typeof(LoaderAccess.validateUrl) == "string" then
        return LoaderAccess.validateUrl
    elseif typeof(LoaderAccess.baseUrl) == "string" then
        return LoaderAccess.baseUrl .. "/validate"
    end
    return nil
end

local function requestLoaderValidation(refresh)
    if not LoaderAccess then return false, "Missing loader token" end
    if not HttpRequestInvoker then return false, "Executor lacks HTTP support" end
    local validateUrl = buildValidateUrl()
    if not validateUrl then return false, "Validation endpoint unavailable" end

    local payload = {
        token = LoaderAccess.token,
        scriptId = LOADER_SCRIPT_ID,
        refresh = refresh ~= false,
    }

    local encodedOk, encodedPayload = pcall(HttpService.JSONEncode, HttpService, payload)
    if not encodedOk then return false, "Failed to encode validation payload" end

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

    if not success then return false, tostring(response) end

    local statusCode = response.StatusCode or response.Status or response.status_code
    local bodyText = response.Body or response.body or ""
    if statusCode and (statusCode < 200 or statusCode >= 300) then
        return false, bodyText ~= "" and bodyText or ("HTTP " .. tostring(statusCode))
    end

    local decodeOk, decoded = pcall(HttpService.JSONDecode, HttpService, bodyText)
    if not decodeOk then return false, "Invalid JSON from worker" end

    if decoded.ok ~= true then return false, decoded.reason or "Validation denied" end

    if decoded.newToken and typeof(decoded.newToken) == "string" then
        LoaderAccess.token = decoded.newToken
    end

    return true, decoded
end

local function enforceLoaderWhitelist()
    if not LoaderAccess or LoaderAccess.scriptId ~= LOADER_SCRIPT_ID then
        warn("[PlayerTracker] This script must be loaded via the official loader.")
        return false
    end

    local ok, response = requestLoaderValidation(true)
    if not ok then
        warn("[PlayerTracker] Loader validation failed: " .. tostring(response))
        return false
    end

    if response.killSwitch then
        warn("[PlayerTracker] Loader kill switch active. Aborting.")
        return false
    end

    local refreshInterval = math.clamp(LoaderAccess.refreshInterval or 90, 30, 240)
    task.spawn(function()
        while true do
            task.wait(refreshInterval)
            local valid, data = requestLoaderValidation(true)
            if not valid or (data and data.killSwitch) then
                warn("[PlayerTracker] Access revoked or kill switch triggered. Unloading.")
                local CoreGui = game:GetService("CoreGui")
                local existing = CoreGui:FindFirstChild("PlayerTracker_Menu")
                if existing then existing:Destroy() end
                break
            end
        end
    end)

    getgenv().LunarityAccess = nil
    return true
end

if not enforceLoaderWhitelist() then return end

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // UI Theme (Lunarity Style)
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

-- // Duplicate Protection
local EXISTING_GUI = CoreGui:FindFirstChild("PlayerTracker_Menu")
if EXISTING_GUI then EXISTING_GUI:Destroy() end

-- // State
local Settings = {
    Enabled = true,
    PredictionMode = 4, -- 1 = Linear, 2 = Quadratic, 3 = Kalman, 4 = Auto
    Smoothness = 0.15, -- Camera smoothness (lower = smoother)
    MaxDistance = 1000,
    TargetPart = "Head", -- "Head", "HumanoidRootPart", "Torso"
    ShowIndicator = true,
    PredictionStrength = 1.0, -- Multiplier for prediction
}

-- Auto mode state
local AutoModeSelection = "Linear" -- Current auto-selected algorithm name
local LastAutoAnalysis = 0
local AUTO_ANALYSIS_INTERVAL = 0.2 -- How often to re-analyze movement pattern

local Connections = {}
local Unloaded = false
local IsTracking = false
local CurrentTarget = nil

-- Position history for prediction algorithms
local PositionHistory = {}
local MAX_HISTORY = 10
local HISTORY_INTERVAL = 0.05 -- seconds between samples

-- // Utility Functions
local function addConnection(conn)
    table.insert(Connections, conn)
end

local function notify(msg)
    print("[PlayerTracker]: " .. tostring(msg))
end

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
                    if conn then conn:Disconnect() end
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

-- // Prediction Algorithms

-- Algorithm 1: Linear Velocity Prediction
-- Predicts position based on current velocity (simple and fast)
local function predictLinear(history)
    if #history < 2 then return nil end
    
    local latest = history[#history]
    local previous = history[#history - 1]
    
    local velocity = (latest.position - previous.position) / (latest.time - previous.time)
    local deltaTime = tick() - latest.time
    
    return latest.position + velocity * deltaTime * Settings.PredictionStrength
end

-- Algorithm 2: Quadratic/Parabolic Prediction
-- Uses acceleration for curved movement prediction (good for jumping/falling)
local function predictQuadratic(history)
    if #history < 3 then return predictLinear(history) end
    
    local p1 = history[#history - 2]
    local p2 = history[#history - 1]
    local p3 = history[#history]
    
    local dt1 = p2.time - p1.time
    local dt2 = p3.time - p2.time
    
    if dt1 <= 0 or dt2 <= 0 then return predictLinear(history) end
    
    local v1 = (p2.position - p1.position) / dt1
    local v2 = (p3.position - p2.position) / dt2
    
    local acceleration = (v2 - v1) / ((dt1 + dt2) / 2)
    local currentVelocity = v2
    local deltaTime = tick() - p3.time
    
    -- s = s0 + v*t + 0.5*a*t^2
    local predictedPos = p3.position + 
        currentVelocity * deltaTime * Settings.PredictionStrength + 
        0.5 * acceleration * deltaTime * deltaTime * Settings.PredictionStrength
    
    return predictedPos
end

-- Algorithm 3: Kalman Filter Prediction
-- Optimal estimation combining prediction and observation (most accurate)
local KalmanState = {
    position = Vector3.new(0, 0, 0),
    velocity = Vector3.new(0, 0, 0),
    positionVariance = 1,
    velocityVariance = 1,
}

local function resetKalman()
    KalmanState = {
        position = Vector3.new(0, 0, 0),
        velocity = Vector3.new(0, 0, 0),
        positionVariance = 1,
        velocityVariance = 1,
    }
end

local function predictKalman(history)
    if #history < 2 then return nil end
    
    local latest = history[#history]
    local previous = history[#history - 1]
    local dt = latest.time - previous.time
    
    if dt <= 0 then dt = 0.016 end
    
    -- Process noise (how much we expect the state to change unpredictably)
    local processNoise = 0.1
    -- Measurement noise (how noisy our observations are)
    local measurementNoise = 0.05
    
    -- Prediction step
    local predictedPosition = KalmanState.position + KalmanState.velocity * dt
    local predictedVelocity = KalmanState.velocity
    local predictedPosVariance = KalmanState.positionVariance + dt * KalmanState.velocityVariance + processNoise
    local predictedVelVariance = KalmanState.velocityVariance + processNoise
    
    -- Update step (incorporate new measurement)
    local measurement = latest.position
    local measurementVelocity = (latest.position - previous.position) / dt
    
    -- Kalman gain for position
    local kalmanGainPos = predictedPosVariance / (predictedPosVariance + measurementNoise)
    local kalmanGainVel = predictedVelVariance / (predictedVelVariance + measurementNoise)
    
    -- Update state
    KalmanState.position = predictedPosition + (measurement - predictedPosition) * kalmanGainPos
    KalmanState.velocity = predictedVelocity + (measurementVelocity - predictedVelocity) * kalmanGainVel
    KalmanState.positionVariance = (1 - kalmanGainPos) * predictedPosVariance
    KalmanState.velocityVariance = (1 - kalmanGainVel) * predictedVelVariance
    
    -- Predict future position
    local deltaTime = tick() - latest.time
    return KalmanState.position + KalmanState.velocity * deltaTime * Settings.PredictionStrength
end

-- Algorithm 4: Auto Mode - Intelligently selects best algorithm based on movement analysis
local function analyzeMovementPattern(history)
    if #history < 4 then return 1 end -- Default to Linear if not enough data
    
    local now = tick()
    if now - LastAutoAnalysis < AUTO_ANALYSIS_INTERVAL then
        -- Return cached selection
        if AutoModeSelection == "Linear" then return 1
        elseif AutoModeSelection == "Quadratic" then return 2
        else return 3 end
    end
    LastAutoAnalysis = now
    
    -- Calculate movement metrics
    local velocities = {}
    local accelerations = {}
    local verticalChanges = {}
    
    for i = 2, #history do
        local dt = history[i].time - history[i-1].time
        if dt > 0 then
            local vel = (history[i].position - history[i-1].position) / dt
            table.insert(velocities, vel)
            
            -- Track vertical movement
            local vertChange = math.abs(history[i].position.Y - history[i-1].position.Y)
            table.insert(verticalChanges, vertChange)
        end
    end
    
    -- Calculate accelerations
    for i = 2, #velocities do
        local acc = (velocities[i] - velocities[i-1])
        table.insert(accelerations, acc)
    end
    
    if #velocities < 2 then return 1 end
    
    -- Metric 1: Velocity variance (how erratic is the movement?)
    local avgVel = Vector3.new(0, 0, 0)
    for _, v in ipairs(velocities) do
        avgVel = avgVel + v
    end
    avgVel = avgVel / #velocities
    
    local velocityVariance = 0
    for _, v in ipairs(velocities) do
        velocityVariance = velocityVariance + (v - avgVel).Magnitude
    end
    velocityVariance = velocityVariance / #velocities
    
    -- Metric 2: Vertical acceleration (is the player jumping/falling?)
    local avgVertChange = 0
    for _, vc in ipairs(verticalChanges) do
        avgVertChange = avgVertChange + vc
    end
    avgVertChange = avgVertChange / #verticalChanges
    
    -- Metric 3: Horizontal acceleration (is movement curved?)
    local avgAccMagnitude = 0
    if #accelerations > 0 then
        for _, a in ipairs(accelerations) do
            avgAccMagnitude = avgAccMagnitude + a.Magnitude
        end
        avgAccMagnitude = avgAccMagnitude / #accelerations
    end
    
    -- Decision logic:
    -- High velocity variance = erratic movement = Kalman (best at filtering noise)
    -- High vertical change = jumping/falling = Quadratic (handles parabolic motion)
    -- Low variance, low vertical = straight line = Linear (fast and accurate)
    
    local ERRATIC_THRESHOLD = 15 -- studs/sec variance
    local VERTICAL_THRESHOLD = 2 -- studs per sample
    local ACCELERATION_THRESHOLD = 20 -- studs/sec^2
    
    if velocityVariance > ERRATIC_THRESHOLD then
        AutoModeSelection = "Kalman"
        return 3
    elseif avgVertChange > VERTICAL_THRESHOLD or avgAccMagnitude > ACCELERATION_THRESHOLD then
        AutoModeSelection = "Quadratic"
        return 2
    else
        AutoModeSelection = "Linear"
        return 1
    end
end

local function getPredictedPosition(history)
    local mode = Settings.PredictionMode
    
    -- Auto mode: analyze and select best algorithm
    if mode == 4 then
        mode = analyzeMovementPattern(history)
    end
    
    if mode == 1 then
        return predictLinear(history)
    elseif mode == 2 then
        return predictQuadratic(history)
    elseif mode == 3 then
        return predictKalman(history)
    end
    return nil
end

local function getPredictionModeName()
    if Settings.PredictionMode == 1 then
        return "Linear"
    elseif Settings.PredictionMode == 2 then
        return "Quadratic"
    elseif Settings.PredictionMode == 3 then
        return "Kalman"
    elseif Settings.PredictionMode == 4 then
        return "Auto (" .. AutoModeSelection .. ")"
    end
    return "Unknown"
end

-- Record position history for a target
local lastHistoryTime = 0
local function recordPosition(target)
    local now = tick()
    if now - lastHistoryTime < HISTORY_INTERVAL then return end
    lastHistoryTime = now
    
    if not target or not target.Character then return end
    
    local part = target.Character:FindFirstChild(Settings.TargetPart)
        or target.Character:FindFirstChild("HumanoidRootPart")
        or target.Character:FindFirstChild("Head")
    
    if not part then return end
    
    table.insert(PositionHistory, {
        position = part.Position,
        time = now
    })
    
    -- Keep history limited
    while #PositionHistory > MAX_HISTORY do
        table.remove(PositionHistory, 1)
    end
end

-- // Tracking Logic
local function getClosestPlayer()
    local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localHRP then return nil end
    
    local closest = nil
    local minDist = Settings.MaxDistance
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if hrp and humanoid and humanoid.Health > 0 then
                local dist = (hrp.Position - localHRP.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = player
                end
            end
        end
    end
    
    return closest
end

local function getTargetPosition(target)
    if not target or not target.Character then return nil end
    
    local part = target.Character:FindFirstChild(Settings.TargetPart)
        or target.Character:FindFirstChild("HumanoidRootPart")
        or target.Character:FindFirstChild("Head")
    
    if not part then return nil end
    
    -- Try to get predicted position
    local predicted = getPredictedPosition(PositionHistory)
    if predicted then
        return predicted
    end
    
    return part.Position
end

local function lookAtPosition(position)
    if not position then return end
    
    local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localHRP then return end
    
    local targetCFrame = CFrame.new(Camera.CFrame.Position, position)
    
    -- Smooth interpolation
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
end

-- // Main Tracking Loop
local TrackingConnection = nil

local function startTracking()
    if TrackingConnection then return end
    
    TrackingConnection = RunService.RenderStepped:Connect(function()
        if not IsTracking or Unloaded or not Settings.Enabled then return end
        
        -- Get or update target
        local target = getClosestPlayer()
        
        if target ~= CurrentTarget then
            CurrentTarget = target
            PositionHistory = {} -- Reset history for new target
            resetKalman()
        end
        
        if not target then return end
        
        -- Record position for prediction
        recordPosition(target)
        
        -- Get predicted position and look at it
        local targetPos = getTargetPosition(target)
        if targetPos then
            lookAtPosition(targetPos)
        end
    end)
    
    addConnection(TrackingConnection)
end

-- Start the tracking system
startTracking()

-- Right-click detection
addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or Unloaded then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsTracking = true
    end
end))

addConnection(UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if Unloaded then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsTracking = false
        CurrentTarget = nil
        PositionHistory = {}
        resetKalman()
    end
end))

-- // UI Creation
local function createMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlayerTracker_Menu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = CoreGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 280, 0, 340)
    main.Position = UDim2.new(0, 40, 0.5, -170)
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
    titleLabel.Text = "Lunarity · Player Tracker"
    titleLabel.TextSize = 14
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
    subtitle.Text = "RMB Lock"
    subtitle.TextSize = 10
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

    -- Helper: Create Toggle
    local function createToggle(text, initial, onChanged)
        local holder = Instance.new("Frame")
        holder.Name = text .. "_Toggle"
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, 0, 0, 24)
        holder.Parent = content

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Theme.TextSecondary
        label.Parent = holder

        local button = Instance.new("TextButton")
        button.Name = "Toggle"
        button.Size = UDim2.new(0, 40, 0, 20)
        button.Position = UDim2.new(1, -42, 0.5, -10)
        button.AutoButtonColor = false
        button.BackgroundColor3 = initial and Theme.Accent or Theme.NeutralButton
        button.Text = initial and "ON" or "OFF"
        button.Font = Enum.Font.GothamSemibold
        button.TextSize = 9
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

        button.MouseButton1Click:Connect(function()
            if Unloaded then return end
            initial = not initial
            updateVisual(initial)
            onChanged(initial)
        end)

        updateVisual(initial)
        return holder, button, updateVisual
    end

    -- Helper: Create Dropdown
    local function createDropdown(text, options, initialIndex, onChanged)
        local holder = Instance.new("Frame")
        holder.Name = text .. "_Dropdown"
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, 0, 0, 24)
        holder.Parent = content

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -90, 1, 0)
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Theme.TextSecondary
        label.Parent = holder

        local button = Instance.new("TextButton")
        button.Name = "Select"
        button.Size = UDim2.new(0, 80, 0, 20)
        button.Position = UDim2.new(1, -82, 0.5, -10)
        button.AutoButtonColor = false
        button.BackgroundColor3 = Theme.NeutralButton
        button.Text = options[initialIndex]
        button.Font = Enum.Font.Gotham
        button.TextSize = 10
        button.TextColor3 = Theme.TextPrimary
        button.BorderSizePixel = 0
        button.Parent = holder

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = button

        local currentIndex = initialIndex

        button.MouseButton1Click:Connect(function()
            if Unloaded then return end
            currentIndex = currentIndex % #options + 1
            button.Text = options[currentIndex]
            onChanged(currentIndex, options[currentIndex])
        end)

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Theme.NeutralButtonHover
        end)

        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Theme.NeutralButton
        end)

        return holder, button
    end

    -- Helper: Create Slider
    local function createSlider(text, minVal, maxVal, initial, decimals, onChanged)
        local holder = Instance.new("Frame")
        holder.Name = text .. "_Slider"
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, 0, 0, 36)
        holder.Parent = content

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -50, 0, 16)
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Theme.TextSecondary
        label.Parent = holder

        local valueLabel = Instance.new("TextLabel")
        valueLabel.BackgroundTransparency = 1
        valueLabel.Size = UDim2.new(0, 40, 0, 16)
        valueLabel.Position = UDim2.new(1, -42, 0, 0)
        valueLabel.Font = Enum.Font.GothamSemibold
        valueLabel.Text = tostring(initial)
        valueLabel.TextSize = 11
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.TextColor3 = Theme.Accent
        valueLabel.Parent = holder

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 6)
        sliderBg.Position = UDim2.new(0, 0, 0, 22)
        sliderBg.BackgroundColor3 = Theme.NeutralDark
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = holder

        local sliderBgCorner = Instance.new("UICorner")
        sliderBgCorner.CornerRadius = UDim.new(0, 3)
        sliderBgCorner.Parent = sliderBg

        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((initial - minVal) / (maxVal - minVal), 0, 1, 0)
        sliderFill.BackgroundColor3 = Theme.Accent
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg

        local sliderFillCorner = Instance.new("UICorner")
        sliderFillCorner.CornerRadius = UDim.new(0, 3)
        sliderFillCorner.Parent = sliderFill

        local sliderFillGradient = Instance.new("UIGradient")
        sliderFillGradient.Color = AccentGradientSequence
        sliderFillGradient.Parent = sliderFill

        local dragging = false

        local function updateSlider(input)
            local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = minVal + relativeX * (maxVal - minVal)
            
            if decimals then
                value = math.floor(value * (10 ^ decimals) + 0.5) / (10 ^ decimals)
            else
                value = math.floor(value + 0.5)
            end
            
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            valueLabel.Text = tostring(value)
            onChanged(value)
        end

        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)

        sliderBg.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        addConnection(UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end))

        return holder
    end

    -- Status Indicator
    local statusHolder = Instance.new("Frame")
    statusHolder.Name = "Status"
    statusHolder.BackgroundTransparency = 1
    statusHolder.Size = UDim2.new(1, 0, 0, 20)
    statusHolder.Parent = content

    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0, 0, 0.5, -4)
    statusDot.BackgroundColor3 = Theme.TextMuted
    statusDot.BorderSizePixel = 0
    statusDot.Parent = statusHolder

    local statusDotCorner = Instance.new("UICorner")
    statusDotCorner.CornerRadius = UDim.new(1, 0)
    statusDotCorner.Parent = statusDot

    local statusLabel = Instance.new("TextLabel")
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, -14, 1, 0)
    statusLabel.Position = UDim2.new(0, 14, 0, 0)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Hold RMB to track closest player"
    statusLabel.TextSize = 11
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextColor3 = Theme.TextMuted
    statusLabel.Parent = statusHolder

    -- Update status indicator
    task.spawn(function()
        while not Unloaded do
            if IsTracking and CurrentTarget then
                statusDot.BackgroundColor3 = Theme.Accent
                statusLabel.Text = "Tracking: " .. CurrentTarget.Name
                statusLabel.TextColor3 = Theme.TextPrimary
            elseif IsTracking then
                statusDot.BackgroundColor3 = Theme.Danger
                statusLabel.Text = "Searching for target..."
                statusLabel.TextColor3 = Theme.TextSecondary
            else
                statusDot.BackgroundColor3 = Theme.TextMuted
                statusLabel.Text = "Hold RMB to track closest player"
                statusLabel.TextColor3 = Theme.TextMuted
            end
            task.wait(0.1)
        end
    end)

    -- Separator
    local sep1 = Instance.new("Frame")
    sep1.BackgroundColor3 = Theme.Separator
    sep1.BorderSizePixel = 0
    sep1.Size = UDim2.new(1, 0, 0, 1)
    sep1.Parent = content

    -- Create UI elements
    createToggle("Enabled", Settings.Enabled, function(value)
        Settings.Enabled = value
    end)

    createDropdown("Prediction Mode", {"Linear", "Quadratic", "Kalman", "Auto"}, Settings.PredictionMode, function(index, name)
        Settings.PredictionMode = index
        PositionHistory = {}
        resetKalman()
        AutoModeSelection = "Linear"
        LastAutoAnalysis = 0
        notify("Prediction mode: " .. name)
    end)

    createDropdown("Target Part", {"Head", "HumanoidRootPart", "Torso"}, 1, function(index, name)
        Settings.TargetPart = name
    end)

    createSlider("Smoothness", 0.05, 0.5, Settings.Smoothness, 2, function(value)
        Settings.Smoothness = value
    end)

    createSlider("Prediction Strength", 0.5, 2.0, Settings.PredictionStrength, 1, function(value)
        Settings.PredictionStrength = value
    end)

    createSlider("Max Distance", 100, 2000, Settings.MaxDistance, 0, function(value)
        Settings.MaxDistance = value
    end)

    -- Separator
    local sep2 = Instance.new("Frame")
    sep2.BackgroundColor3 = Theme.Separator
    sep2.BorderSizePixel = 0
    sep2.Size = UDim2.new(1, 0, 0, 1)
    sep2.Parent = content

    -- Info Section
    local infoLabel = Instance.new("TextLabel")
    infoLabel.BackgroundTransparency = 1
    infoLabel.Size = UDim2.new(1, 0, 0, 50)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Text = "• Linear: Fast, straight-line motion\n• Quadratic: Curved paths/jumps\n• Kalman: Erratic/combat movement\n• Auto: Intelligent selection (best)"
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextColor3 = Theme.TextMuted
    infoLabel.TextWrapped = true
    infoLabel.Parent = content

    createDraggable(main, titleBar)

    -- Toggle visibility with RightControl
    addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or Unloaded then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            screenGui.Enabled = not screenGui.Enabled
        end
    end))

    return screenGui
end

-- Create the menu
createMenu()

notify("Player Tracker loaded! Hold Right Click to track. Press RightControl to toggle menu.")

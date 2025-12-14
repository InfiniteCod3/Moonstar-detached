-- // Player Tracker // --
-- // Lunarity UI Style // --
-- // Hold Right Click to Track Closest Player with Prediction // --

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

-- Load shared UI module
local LunarityUI = loadstring(game:HttpGet("https://api.relayed.network/ui"))()
local Theme = LunarityUI.Theme
local AccentGradientSequence = LunarityUI.AccentGradientSequence
local BackgroundGradientSequence = LunarityUI.BackgroundGradientSequence
local DangerGradientSequence = LunarityUI.DangerGradientSequence

-- // Duplicate Protection
local EXISTING_GUI = CoreGui:FindFirstChild("PlayerTracker_Menu")
if EXISTING_GUI then EXISTING_GUI:Destroy() end

-- // State
local Settings = {
    Enabled = true,
    PredictionMode = 4, -- 1 = Linear, 2 = Quadratic, 3 = Kalman, 4 = Auto
    Smoothness = 0.8, -- Camera smoothness (lower = smoother)
    MaxDistance = 1000,
    TargetPart = "Head", -- "Head", "HumanoidRootPart", "Torso"
    ShowIndicator = true,
    ShowPrediction = true, -- Show visual prediction indicator
    PredictionStrength = 3.0, -- Multiplier for prediction
    LookaheadTime = 0.15, -- Extra time (seconds) to look ahead into the future
    -- Dash Detection (Anti-180 bypass)
    DashDetection = true, -- Enable dash detection
    DashThreshold = 50, -- Acceleration threshold to detect a dash (studs/sec²)
    DashSnapSpeed = 1.0, -- How fast to snap when dash detected (1.0 = instant)
    DashCooldown = 0.3, -- Cooldown between dash detections (seconds)
}

-- Auto mode state
local AutoModeSelection = "Linear" -- Current auto-selected algorithm name
local LastAutoAnalysis = 0
local AUTO_ANALYSIS_INTERVAL = 0.2 -- How often to re-analyze movement pattern

-- Dash detection state
local DashState = {
    isDashing = false,
    lastDashTime = 0,
    dashDirection = Vector3.new(0, 0, 0),
    preDashPosition = Vector3.new(0, 0, 0),
    lastVelocity = Vector3.new(0, 0, 0),
}

local Connections = {}
local Unloaded = false
local IsTracking = false
local CurrentTarget = nil
local ScreenGuiRef = nil

-- // Unload Function
local function unload()
    if Unloaded then return end
    Unloaded = true
    
    -- Disconnect all connections
    for _, conn in ipairs(Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    Connections = {}
    
    -- Clean up prediction visuals
    if PredictionVisuals then
        if PredictionVisuals.PredictionSphere then
            PredictionVisuals.PredictionSphere:Destroy()
        end
        if PredictionVisuals.PredictionPart then
            PredictionVisuals.PredictionPart:Destroy()
        end
        if PredictionVisuals.ConnectionBeam then
            PredictionVisuals.ConnectionBeam:Destroy()
        end
        if PredictionVisuals.AttachmentCurrent then
            PredictionVisuals.AttachmentCurrent:Destroy()
        end
        if PredictionVisuals.AttachmentPredicted then
            PredictionVisuals.AttachmentPredicted:Destroy()
        end
    end
    
    -- Destroy GUI
    if ScreenGuiRef and ScreenGuiRef.Parent then
        ScreenGuiRef:Destroy()
    end
    
    -- Also check for duplicate GUI cleanup
    local existingGui = CoreGui:FindFirstChild("PlayerTracker_Menu")
    if existingGui then
        existingGui:Destroy()
    end
    
    notify("Player Tracker unloaded!")
end

-- Prediction visualization objects
local PredictionVisuals = {
    PredictionSphere = nil,
    ConnectionBeam = nil,
    AttachmentCurrent = nil,
    AttachmentPredicted = nil,
    PredictionPart = nil,
}

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
    local deltaTime = (tick() - latest.time) + Settings.LookaheadTime
    
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
    local deltaTime = (tick() - p3.time) + Settings.LookaheadTime
    
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
    local deltaTime = (tick() - latest.time) + Settings.LookaheadTime
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

-- // Dash Detection System
-- Detects sudden acceleration (dash) and predicts player going behind you

local function detectDash(history)
    if not Settings.DashDetection then return false, nil end
    if #history < 3 then return false, nil end
    
    local now = tick()
    
    -- Calculate current and previous velocities
    local p1 = history[#history - 2]
    local p2 = history[#history - 1]
    local p3 = history[#history]
    
    local dt1 = p2.time - p1.time
    local dt2 = p3.time - p2.time
    
    if dt1 <= 0 or dt2 <= 0 then return false, nil end
    
    local v1 = (p2.position - p1.position) / dt1
    local v2 = (p3.position - p2.position) / dt2
    
    -- Calculate acceleration
    local acceleration = (v2 - v1) / dt2
    local accelMagnitude = acceleration.Magnitude
    
    -- Determine if valid dash
    local isHighAccel = accelMagnitude > Settings.DashThreshold
    
    -- State management: Enter dash mode on high accel, exit after cooldown
    if isHighAccel then
        DashState.isDashing = true
        DashState.lastDashTime = now
    elseif now - DashState.lastDashTime > Settings.DashCooldown then
        DashState.isDashing = false
    end
    
    -- If in dash mode, continuously calculate and smooth the target
    if DashState.isDashing then
        -- Calculate where they're dashing TO based on LATEST velocity
        local dashDistance = v2.Magnitude * 0.5 -- Predict ~0.5 seconds of dash travel
        local rawTarget = p3.position + v2.Unit * dashDistance
        
        -- Smooth the transition to prevent jittering
        if DashState.dashDirection then
            -- Lerp towards the new target (0.3 = smooth, 1.0 = instant)
            DashState.dashDirection = DashState.dashDirection:Lerp(rawTarget, 0.25)
        else
            DashState.dashDirection = rawTarget
        end
        
        return true, DashState.dashDirection
    end
    
    -- Reset stored direction when not dashing
    DashState.dashDirection = nil
    return false, nil
end

local function getPredictedPosition(history)
    -- Check for dash first - this takes priority
    local isDashing, dashTarget = detectDash(history)
    if isDashing and dashTarget then
        -- Return the dash prediction point (where they're heading)
        return dashTarget
    end
    
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
    -- Show dash state if active
    if DashState.isDashing then
        return "DASH DETECTED!"
    end
    
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

-- // Prediction Visualization System

local function cleanupPredictionVisuals()
    if PredictionVisuals.PredictionSphere then
        PredictionVisuals.PredictionSphere:Destroy()
        PredictionVisuals.PredictionSphere = nil
    end
    if PredictionVisuals.PredictionPart then
        PredictionVisuals.PredictionPart:Destroy()
        PredictionVisuals.PredictionPart = nil
    end
    if PredictionVisuals.ConnectionBeam then
        PredictionVisuals.ConnectionBeam:Destroy()
        PredictionVisuals.ConnectionBeam = nil
    end
    if PredictionVisuals.AttachmentCurrent then
        PredictionVisuals.AttachmentCurrent:Destroy()
        PredictionVisuals.AttachmentCurrent = nil
    end
    if PredictionVisuals.AttachmentPredicted then
        PredictionVisuals.AttachmentPredicted:Destroy()
        PredictionVisuals.AttachmentPredicted = nil
    end
end

local function createPredictionVisuals()
    cleanupPredictionVisuals()
    
    -- Create the predicted position marker (invisible part to hold attachment)
    local predictionPart = Instance.new("Part")
    predictionPart.Name = "PredictionMarker"
    predictionPart.Anchored = true
    predictionPart.CanCollide = false
    predictionPart.CanQuery = false
    predictionPart.Transparency = 1
    predictionPart.Size = Vector3.new(0.5, 0.5, 0.5)
    predictionPart.Parent = Workspace
    PredictionVisuals.PredictionPart = predictionPart
    
    -- Create glowing sphere at predicted position using BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PredictionSphere"
    billboard.Size = UDim2.new(0, 60, 0, 60)
    billboard.AlwaysOnTop = true
    billboard.Parent = predictionPart
    PredictionVisuals.PredictionSphere = billboard
    
    -- Outer glow ring
    local outerGlow = Instance.new("ImageLabel")
    outerGlow.Name = "OuterGlow"
    outerGlow.Size = UDim2.new(1, 0, 1, 0)
    outerGlow.BackgroundTransparency = 1
    outerGlow.Image = "rbxassetid://3570695787" -- Circular gradient
    outerGlow.ImageColor3 = Theme.Accent
    outerGlow.ImageTransparency = 0.3
    outerGlow.Parent = billboard
    
    -- Inner core
    local innerCore = Instance.new("ImageLabel")
    innerCore.Name = "InnerCore"
    innerCore.Size = UDim2.new(0.5, 0, 0.5, 0)
    innerCore.Position = UDim2.new(0.25, 0, 0.25, 0)
    innerCore.BackgroundTransparency = 1
    innerCore.Image = "rbxassetid://3570695787"
    innerCore.ImageColor3 = Theme.AccentLight
    innerCore.ImageTransparency = 0
    innerCore.Parent = billboard
    
    -- Crosshair horizontal
    local crossH = Instance.new("Frame")
    crossH.Name = "CrossH"
    crossH.Size = UDim2.new(0.6, 0, 0, 2)
    crossH.Position = UDim2.new(0.2, 0, 0.5, -1)
    crossH.BackgroundColor3 = Theme.AccentLight
    crossH.BackgroundTransparency = 0.2
    crossH.BorderSizePixel = 0
    crossH.Parent = billboard
    
    -- Crosshair vertical
    local crossV = Instance.new("Frame")
    crossV.Name = "CrossV"
    crossV.Size = UDim2.new(0, 2, 0.6, 0)
    crossV.Position = UDim2.new(0.5, -1, 0.2, 0)
    crossV.BackgroundColor3 = Theme.AccentLight
    crossV.BackgroundTransparency = 0.2
    crossV.BorderSizePixel = 0
    crossV.Parent = billboard
    
    -- Prediction mode label
    local modeLabel = Instance.new("TextLabel")
    modeLabel.Name = "ModeLabel"
    modeLabel.Size = UDim2.new(1, 0, 0, 12)
    modeLabel.Position = UDim2.new(0, 0, 1, 4)
    modeLabel.BackgroundTransparency = 1
    modeLabel.Font = Enum.Font.GothamSemibold
    modeLabel.TextSize = 10
    modeLabel.Text = ""
    modeLabel.TextColor3 = Theme.Accent
    modeLabel.TextStrokeTransparency = 0.5
    modeLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    modeLabel.Parent = billboard
    
    -- Create attachments for beam
    local attachmentPredicted = Instance.new("Attachment")
    attachmentPredicted.Name = "PredictedAttachment"
    attachmentPredicted.Parent = predictionPart
    PredictionVisuals.AttachmentPredicted = attachmentPredicted
    
    return predictionPart, billboard
end

local function updatePredictionVisuals(currentPos, predictedPos)
    if not Settings.ShowPrediction then
        cleanupPredictionVisuals()
        return
    end
    
    if not predictedPos or not currentPos then
        if PredictionVisuals.PredictionSphere then
            PredictionVisuals.PredictionSphere.Enabled = false
        end
        if PredictionVisuals.ConnectionBeam then
            PredictionVisuals.ConnectionBeam.Enabled = false
        end
        return
    end
    
    -- Create visuals if they don't exist
    if not PredictionVisuals.PredictionPart or not PredictionVisuals.PredictionPart.Parent then
        createPredictionVisuals()
    end
    
    -- Update prediction marker position
    PredictionVisuals.PredictionPart.Position = predictedPos
    
    -- Enable sphere
    if PredictionVisuals.PredictionSphere then
        PredictionVisuals.PredictionSphere.Enabled = true
        
        -- Update mode label
        local modeLabel = PredictionVisuals.PredictionSphere:FindFirstChild("ModeLabel")
        if modeLabel then
            modeLabel.Text = getPredictionModeName()
        end
        
        -- Animate glow (pulsing effect)
        local outerGlow = PredictionVisuals.PredictionSphere:FindFirstChild("OuterGlow")
        if outerGlow then
            local pulse = 0.3 + math.sin(tick() * 4) * 0.15
            outerGlow.ImageTransparency = pulse
        end
        
        -- Dynamic size based on distance from current to predicted
        local predictionDistance = (predictedPos - currentPos).Magnitude
        local scaleFactor = math.clamp(predictionDistance / 10, 0.5, 2)
        PredictionVisuals.PredictionSphere.Size = UDim2.new(0, 60 * scaleFactor, 0, 60 * scaleFactor)
    end
    
    -- Create/update beam connection from current to predicted position
    if not PredictionVisuals.ConnectionBeam then
        -- We need an attachment on the target player
        local beam = Instance.new("Beam")
        beam.Name = "PredictionBeam"
        beam.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.AccentDark),
            ColorSequenceKeypoint.new(0.5, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentLight)
        }
        beam.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.7),
            NumberSequenceKeypoint.new(0.5, 0.4),
            NumberSequenceKeypoint.new(1, 0.2)
        }
        beam.Width0 = 0.15
        beam.Width1 = 0.3
        beam.FaceCamera = true
        beam.Segments = 20
        beam.LightEmission = 0.5
        beam.LightInfluence = 0.2
        beam.Parent = Workspace
        PredictionVisuals.ConnectionBeam = beam
    end
    
    -- Create temporary attachment for current position if needed
    local target = CurrentTarget
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(Settings.TargetPart)
            or target.Character:FindFirstChild("HumanoidRootPart")
            or target.Character:FindFirstChild("Head")
        
        if targetPart then
            -- Create or move attachment on target
            if not PredictionVisuals.AttachmentCurrent or PredictionVisuals.AttachmentCurrent.Parent ~= targetPart then
                if PredictionVisuals.AttachmentCurrent then
                    PredictionVisuals.AttachmentCurrent:Destroy()
                end
                local att = Instance.new("Attachment")
                att.Name = "CurrentPosAttachment"
                att.Parent = targetPart
                PredictionVisuals.AttachmentCurrent = att
            end
            
            -- Update beam attachments
            PredictionVisuals.ConnectionBeam.Attachment0 = PredictionVisuals.AttachmentCurrent
            PredictionVisuals.ConnectionBeam.Attachment1 = PredictionVisuals.AttachmentPredicted
            PredictionVisuals.ConnectionBeam.Enabled = true
            
            -- Add curve to beam for visual interest
            local direction = (predictedPos - currentPos).Unit
            local perpendicular = Vector3.new(-direction.Z, 0, direction.X) * 0.5
            PredictionVisuals.ConnectionBeam.CurveSize0 = perpendicular.Magnitude * 2
            PredictionVisuals.ConnectionBeam.CurveSize1 = -perpendicular.Magnitude * 2
        end
    end
end

local function hidePredictionVisuals()
    if PredictionVisuals.PredictionSphere then
        PredictionVisuals.PredictionSphere.Enabled = false
    end
    if PredictionVisuals.ConnectionBeam then
        PredictionVisuals.ConnectionBeam.Enabled = false
    end
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
        if not IsTracking or Unloaded or not Settings.Enabled then
            hidePredictionVisuals()
            return
        end
        
        -- Get or update target
        local target = getClosestPlayer()
        
        if target ~= CurrentTarget then
            CurrentTarget = target
            PositionHistory = {} -- Reset history for new target
            resetKalman()
            hidePredictionVisuals()
        end
        
        if not target then
            hidePredictionVisuals()
            return
        end
        
        -- Record position for prediction
        recordPosition(target)
        
        -- Get current actual position
        local part = target.Character:FindFirstChild(Settings.TargetPart)
            or target.Character:FindFirstChild("HumanoidRootPart")
            or target.Character:FindFirstChild("Head")
        local currentPos = part and part.Position or nil
        
        -- Get predicted position
        local predictedPos = getPredictedPosition(PositionHistory)
        
        -- Update prediction visualization
        if currentPos and predictedPos then
            updatePredictionVisuals(currentPos, predictedPos)
        else
            hidePredictionVisuals()
        end
        
        -- Look at predicted position (or current if no prediction)
        local targetPos = predictedPos or currentPos
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
        hidePredictionVisuals()
    end
end))

-- Smooth 180 Turn
addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or Unloaded then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        local character = LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Calculate target rotation (180 degrees)
                local targetCFrame = hrp.CFrame * CFrame.Angles(0, math.pi, 0)
                
                -- Smooth transition using TweenService
                local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
                tween:Play()
            end
        end
    end
end))

-- // UI Creation using LunarityUI Module
local function createMenu()
    -- Create window using shared UI module
    local window = LunarityUI.CreateWindow({
        Name = "PlayerTracker_Menu",
        Title = "Lunarity",
        Subtitle = "Player Tracker",
        Size = UDim2.new(0, 300, 0, 420),
        Position = UDim2.new(0, 40, 0.5, -210),
        OnClose = function()
            unload()
        end
    })
    
    local Theme = LunarityUI.Theme
    
    -- Status bar at top
    local statusBar = window.createStatusBar("Hold RMB to track closest player", Theme.TextDim)
    
    -- Update status indicator in background
    task.spawn(function()
        while not Unloaded do
            if IsTracking and CurrentTarget then
                statusBar.setColor(Theme.Accent)
                statusBar.setText("Tracking: " .. CurrentTarget.Name)
                statusBar.setTextColor(Theme.Text)
            elseif IsTracking then
                statusBar.setColor(Theme.Error)
                statusBar.setText("Searching for target...")
                statusBar.setTextColor(Theme.TextDim)
            else
                statusBar.setColor(Theme.TextDim)
                statusBar.setText("Hold RMB to track closest player")
                statusBar.setTextColor(Theme.TextDim)
            end
            task.wait(0.1)
        end
    end)
    
    window.createSeparator()
    window.createSection("Settings")
    
    -- Toggles
    window.createToggle("Enabled", Settings.Enabled, function(value)
        Settings.Enabled = value
        if not value then
            hidePredictionVisuals()
        end
    end)
    
    window.createToggle("Show Prediction", Settings.ShowPrediction, function(value)
        Settings.ShowPrediction = value
        if not value then
            cleanupPredictionVisuals()
        end
    end)
    
    window.createToggle("Dash Detection (Anti-180)", Settings.DashDetection, function(value)
        Settings.DashDetection = value
    end)
    
    -- Dropdowns
    window.createDropdown("Prediction Mode", {"Linear", "Quadratic", "Kalman", "Auto"}, Settings.PredictionMode, function(index, name)
        Settings.PredictionMode = index
        PositionHistory = {}
        resetKalman()
        AutoModeSelection = "Linear"
        LastAutoAnalysis = 0
        notify("Prediction mode: " .. name)
    end)
    
    window.createDropdown("Target Part", {"Head", "HumanoidRootPart", "Torso"}, 1, function(index, name)
        Settings.TargetPart = name
    end)
    
    window.createSeparator()
    window.createSection("Tuning")
    
    -- Sliders
    window.createSlider("Smoothness", 0.05, 1.0, Settings.Smoothness, 2, function(value)
        Settings.Smoothness = value
    end)
    
    window.createSlider("Prediction Strength", 0.5, 5.0, Settings.PredictionStrength, 1, function(value)
        Settings.PredictionStrength = value
    end)
    
    window.createSlider("Lookahead (ms)", 0, 300, Settings.LookaheadTime * 1000, 0, function(value)
        Settings.LookaheadTime = value / 1000
    end)
    
    window.createSlider("Max Distance", 100, 2000, Settings.MaxDistance, 0, function(value)
        Settings.MaxDistance = value
    end)
    
    window.createSlider("Dash Sensitivity", 20, 100, Settings.DashThreshold, 0, function(value)
        Settings.DashThreshold = value
    end)
    
    window.createSeparator()
    window.createSection("Info")
    
    -- Info label
    window.createInfoLabel("• Linear: Fast, straight-line motion\n• Quadratic: Curved paths/jumps\n• Kalman: Erratic/combat movement\n• Auto: Intelligent selection (best)")
    
    window.createSeparator()
    
    -- Unload button
    window.createButton("Unload Script", function()
        unload()
    end, false)
    
    -- Toggle visibility with RightControl
    window.addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or Unloaded then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            window.ScreenGui.Enabled = not window.ScreenGui.Enabled
        end
    end))
    
    ScreenGuiRef = window.ScreenGui
    return window.ScreenGui
end

-- Create the menu
createMenu()

notify("Player Tracker loaded! Hold Right Click to track. Press RightControl to toggle menu.")

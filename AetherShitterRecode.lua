--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                    AETHERFALL SHITTER                        ║
    ║                     Recode Edition                           ║
    ║                                                               ║
    ║  Features:                                                    ║
    ║  • Enemy Debuffs (Stun/Ragdoll/Freeze/Slow)                 ║
    ║  • Mass Attacks (Affect all non-whitelisted players)        ║
    ║  • Auto Attack & Mouse Aimbot                               ║
    ║  • Welds Exploits (Fling/Void/Bring)                        ║
    ║  • Anti-Knockback, IFrames, Anti-Debuff                     ║
    ║  • Input Spoofing (Force Dash/Ultimate/Block/Transform)     ║
    ╚═══════════════════════════════════════════════════════════════╝
]]--

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local LOADER_SCRIPT_ID = "aetherShitter"
local LoaderAccess = rawget(getgenv(), "LunarityAccess")
local ScriptActive = true

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
            warn("[AetherShitter] This build must be launched via the official loader.")
            return false
        end

        local ok, response = requestLoaderValidation(true)
        if not ok then
            warn("[AetherShitter] Loader validation failed: " .. tostring(response))
            return false
        end

        if response.killSwitch then
            warn("[AetherShitter] Loader kill switch active. Aborting.")
            return false
        end

        local refreshInterval = math.clamp(LoaderAccess.refreshInterval or 90, 30, 240)
        task.spawn(function()
            while ScriptActive do
                task.wait(refreshInterval)
                local valid, data = requestLoaderValidation(true)
                if not valid or (data and data.killSwitch) then
                    warn("[AetherShitter] Access revoked or kill switch activated. Shutting down.")
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

-- // Remotes
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local WeldsRemote = Remotes and Remotes:FindFirstChild("Welds")
local ToolEquipRemote = Remotes and Remotes:FindFirstChild("ToolEquip")

-- // UI Theme
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
local EXISTING_GUI = CoreGui:FindFirstChild("AetherShitter_Menu")
if EXISTING_GUI then EXISTING_GUI:Destroy() end

local EXISTING_SELECTOR = CoreGui:FindFirstChild("AetherShitter_Selector")
if EXISTING_SELECTOR then EXISTING_SELECTOR:Destroy() end

-- // State
local Settings = {
    ClickFling = false,
    Orbit = false,
    IFrames = false,
    AntiDebuff = false,
    AutoRemoveSkills = false,
    AttacherVisible = false,
    LoopVoid = false,
    -- Input/Aimbot Settings
    AutoAttack = false,
    MouseSpoof = false,
    -- Troll Features (Affect Others via Welds - these still work)
    SpinTarget = false,
    TrapUnderground = false,
    AttachToTarget = false,
    PlayerCentipede = false, -- Chain all players in a line
    PuppetMode = false, -- Control target like a puppet
    CentipedeSpacing = 4, -- Space between players in centipede
    -- Fakery
    SelectedTrait = nil,
    SelectedTitle = nil,
    Whitelist = {[LocalPlayer.Name] = true},
    TargetName = nil, -- For Attacher/Orbit
    -- Self Ragdoll (uses RagdollTrigger BoolValue - no remote needed)
    SelfRagdoll = false
}

local DEBUG_MODE = false -- Set to true for debug output
local DEBUFF_BLACKLIST = {
    ["Stunned"] = true,
    ["Freeze"] = true,
    ["Ragdoll"] = true,
    ["Slowed"] = true,
}

local Connections = {}
local Unloaded = false

-- // Utility Functions
local function addConnection(conn)
    table.insert(Connections, conn)
end

local function remove_status(statusIndex)
    local statusRemote = Remotes and Remotes:FindFirstChild("Status")
    if statusRemote then
        statusRemote:FireServer({
            RemoveStatus = true,
            StatusIndex = statusIndex
        })
    end
end

-- Anti-Debuff Listener
if Remotes and Remotes:FindFirstChild("Status") then
    addConnection(Remotes.Status.OnClientEvent:Connect(function(statusTable)
        if not Settings.AntiDebuff or Unloaded then return end
        
        if type(statusTable) == "table" then
            for index, statusName in pairs(statusTable) do
                if DEBUFF_BLACKLIST[statusName] then
                    remove_status(index)
                    debugLog("Removed debuff: " .. tostring(statusName))
                end
            end
        end
    end))
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

local function notify(msg)
    -- Simple print for now, could add toast later
    print("[AetherShitter]: " .. tostring(msg))
end

local function debugLog(msg)
    if DEBUG_MODE then
        warn("[AS-Debug]: " .. tostring(msg))
    end
end

-- // Logic Functions
local function GetUnwhitelistedPlayers()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if not Settings.Whitelist[player.Name] then
            table.insert(list, player)
        end
    end
    return list
end

-- Loop Void Logic
task.spawn(function()
    while not Unloaded do
        if Settings.LoopVoid and WeldsRemote then
             for _, player in pairs(GetUnwhitelistedPlayers()) do
                if player.Character then
                    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    
                    if targetHRP and localHRP then
                         local cf1 = CFrame.new(0, -10000, 0)
                         local vecInf = Vector3.new(0, -10000, 0)
                         local cf2 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1)
                         
                         WeldsRemote:FireServer(targetHRP, localHRP, cf1, vecInf, cf2)
                    end
                end
             end
             task.wait(0.2)
        else
             task.wait(1)
        end
    end
end)

-- Auto Attack Logic
task.spawn(function()
    local inputRemote = Remotes and Remotes:FindFirstChild("Input")
    while not Unloaded do
        if Settings.AutoAttack and inputRemote then
            inputRemote:FireServer("Click")
            task.wait(0.1)
        else
            task.wait(0.5)
        end
    end
end)

-- Mouse Position Spoof (Aimbot) - Sends enemy position as mouse target
task.spawn(function()
    local mousePosRemote = Remotes and Remotes:FindFirstChild("mousePos")
    while not Unloaded do
        if Settings.MouseSpoof and mousePosRemote and Settings.TargetName then
            local target = Players:FindFirstChild(Settings.TargetName)
            if target and target.Character then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    mousePosRemote:FireServer(targetHRP.Position)
                end
            end
            task.wait(0.05)
        else
            task.wait(0.5)
        end
    end
end)

-- Spin Target Logic (Rotates target using Welds)
task.spawn(function()
    local spinAngle = 0
    while not Unloaded do
        if Settings.SpinTarget and WeldsRemote and Settings.TargetName then
            local target = Players:FindFirstChild(Settings.TargetName)
            if target and target.Character then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and localHRP then
                    spinAngle = spinAngle + 0.5
                    local spinCF = CFrame.Angles(0, spinAngle, 0)
                    local cf1 = CFrame.new(0, 0, 0)
                    local offset = Vector3.new(0, 0, 0)
                    WeldsRemote:FireServer(targetHRP, targetHRP, cf1, offset, spinCF)
                end
            end
            task.wait(0.05)
        else
            spinAngle = 0
            task.wait(0.5)
        end
    end
end)

-- Trap Underground Logic (Welds target below ground)
local function TrapTargetUnderground()
    if not WeldsRemote then return notify("Welds Remote not found") end
    if not Settings.TargetName then return notify("No target selected!") end
    
    local target = Players:FindFirstChild(Settings.TargetName)
    if target and target.Character then
        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP and localHRP then
            local cf1 = CFrame.new(0, -50, 0)
            local offset = Vector3.new(0, -50, 0)
            local cf2 = CFrame.new(0, 0, 0)
            WeldsRemote:FireServer(targetHRP, localHRP, cf1, offset, cf2)
            notify("Trapped " .. Settings.TargetName .. " underground")
        end
    end
end

-- Attach to Target Logic (Parasite mode - you follow them)
task.spawn(function()
    while not Unloaded do
        if Settings.AttachToTarget and WeldsRemote and Settings.TargetName then
            local target = Players:FindFirstChild(Settings.TargetName)
            if target and target.Character then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and localHRP then
                    local cf1 = CFrame.new(0, 0, 0)
                    local offset = Vector3.new(0, 3, -2) -- Behind and above them
                    local cf2 = CFrame.new(0, 0, 0)
                    WeldsRemote:FireServer(localHRP, targetHRP, cf1, offset, cf2)
                end
            end
            task.wait(0.1)
        else
            task.wait(0.5)
        end
    end
end)

-- Player Centipede Logic (Chain all players in a line following you)
local lastLocalCFrame = nil
task.spawn(function()
    while not Unloaded do
        if Settings.PlayerCentipede and WeldsRemote then
            local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localHRP then
                local players = GetUnwhitelistedPlayers()
                local spacing = Settings.CentipedeSpacing or 4
                
                -- Chain each player behind the previous one
                for i, player in ipairs(players) do
                    if player.Character then
                        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                        if targetHRP then
                            -- Calculate position: behind the local player in a line
                            local behindOffset = Vector3.new(0, 0, spacing * i)
                            local cf1 = CFrame.new(0, 0, 0)
                            local cf2 = CFrame.new(0, 0, 0)
                            
                            -- Weld each player to your HRP with increasing Z offset
                            WeldsRemote:FireServer(targetHRP, localHRP, cf1, behindOffset, cf2)
                        end
                    end
                end
            end
            task.wait(0.15) -- Smooth update
        else
            task.wait(0.5)
        end
    end
end)

-- Puppet Mode Logic (Target mirrors your movement like a puppet)
local puppetLastCFrame = nil
task.spawn(function()
    while not Unloaded do
        if Settings.PuppetMode and WeldsRemote and Settings.TargetName then
            local target = Players:FindFirstChild(Settings.TargetName)
            local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if target and target.Character and localHRP then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    -- Get current local position and movement delta
                    local currentCFrame = localHRP.CFrame
                    
                    if puppetLastCFrame then
                        -- Calculate how much we moved
                        local delta = currentCFrame.Position - puppetLastCFrame.Position
                        
                        -- Mirror the movement: same direction but on their position
                        -- They move in the same direction as you (puppet follows)
                        local mirrorOffset = delta
                        
                        -- Keep them at a fixed offset but make them "move with" you
                        local cf1 = CFrame.new(0, 0, 0)
                        local offset = Vector3.new(3, 0, 3) -- 3 studs to the side and front
                        local cf2 = CFrame.new(0, 0, 0)
                        
                        WeldsRemote:FireServer(targetHRP, localHRP, cf1, offset, cf2)
                    end
                    
                    puppetLastCFrame = currentCFrame
                end
            else
                puppetLastCFrame = nil
            end
            task.wait(0.05) -- Very fast updates for smooth puppeting
        else
            puppetLastCFrame = nil
            task.wait(0.5)
        end
    end
end)

-- Get All Weapons from Game
local function GetAllWeapons()
    local weapons = {}
    local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
    if weaponsFolder then
        for _, weapon in pairs(weaponsFolder:GetChildren()) do
            table.insert(weapons, weapon.Name)
        end
    end
    table.sort(weapons)
    return weapons
end

-- Get All Traits from Game
local function GetAllTraits()
    local traits = {}
    local traitsFolder = ReplicatedStorage:FindFirstChild("Traits")
    if traitsFolder then
        for _, trait in pairs(traitsFolder:GetChildren()) do
            local displayName = trait:GetAttribute("DisplayName") or trait.Name
            table.insert(traits, {
                Name = trait.Name,
                DisplayName = displayName,
                Cost = trait:GetAttribute("Cost") or 0,
                Info = trait:GetAttribute("Information") or "No info"
            })
        end
    end
    table.sort(traits, function(a, b) return a.Cost < b.Cost end)
    return traits
end

-- Get All Titles from Game
local function GetAllTitles()
    local titles = {}
    local titlesFolder = ReplicatedStorage:FindFirstChild("Titles")
    if titlesFolder then
        for _, title in pairs(titlesFolder:GetChildren()) do
            table.insert(titles, {
                Name = title.Name,
                Value = title.Value, -- The actual title text
                Kills = title:GetAttribute("Kills") or 0
            })
        end
    end
    table.sort(titles, function(a, b) return a.Kills < b.Kills end)
    return titles
end

local function BlowEveryone()
    if not WeldsRemote then return notify("Welds Remote not found") end
    
    debugLog("BlowEveryone called")
    local count = 0
    for _, player in pairs(GetUnwhitelistedPlayers()) do
        if player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHRP and localHRP then
                local cf1 = CFrame.new(-3028.23, 3101.88, 308.06, -0.91, 0, 0.4, 0, 1, 0, -0.4, 0, -0.91)
                local vecInf = Vector3.new(math.huge, math.huge, math.huge)
                local cf2 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1)
                
                WeldsRemote:FireServer(localHRP, targetHRP, cf1, vecInf, cf2)
                count = count + 1
                debugLog("Fired weld for " .. player.Name)
            end
        end
    end
    notify("Blew " .. count .. " players")
end

local function VoidEveryone()
    if not WeldsRemote then return notify("Welds Remote not found") end
    
    debugLog("VoidEveryone called")
    local count = 0
    for _, player in pairs(GetUnwhitelistedPlayers()) do
        if player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHRP and localHRP then
                -- Teleport deep into the void
                local cf1 = CFrame.new(0, -10000, 0)
                local vecInf = Vector3.new(0, -10000, 0)
                local cf2 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1)
                
                WeldsRemote:FireServer(localHRP, targetHRP, cf1, vecInf, cf2)
                count = count + 1
                debugLog("Voided " .. player.Name)
            end
        end
    end
    notify("Sent " .. count .. " players to Void")
end

local function BringAll()
    if not WeldsRemote then return notify("Welds Remote not found") end
    
    debugLog("BringAll called")
    local count = 0
    for _, player in pairs(GetUnwhitelistedPlayers()) do
        if player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHRP and localHRP then
                -- Bring to local player
                local cfZero = CFrame.new(0, 0, 0)
                local vecZero = Vector3.new(0, 0, 0)
                
                WeldsRemote:FireServer(localHRP, targetHRP, localHRP.CFrame, vecZero, cfZero)
                count = count + 1
                debugLog("Brought " .. player.Name)
            end
        end
    end
    notify("Brought " .. count .. " players")
end

local function SpamTools()
    if not ToolEquipRemote then return notify("ToolEquip Remote not found") end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    local tools = backpack:GetChildren()
    if #tools == 0 then return notify("No tools in backpack to spam") end
    
    notify("Spamming tools (5s)...")
    local endTime = tick() + 5
    task.spawn(function()
        while tick() < endTime and not Unloaded do
            for _, tool in ipairs(tools) do
                ToolEquipRemote:FireServer(tool, LocalPlayer.Character)
                task.wait(0.05)
                ToolEquipRemote:FireServer(tool, backpack)
            end
            task.wait()
        end
    end)
end

local function TargetAction(action)
    local targetName = Settings.TargetName
    if not targetName then return notify("No target selected!") end
    
    local target = Players:FindFirstChild(targetName)
    if not target then return notify("Target not found!") end
    
    if not WeldsRemote then return notify("Welds Remote not found") end
    
    local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not (targetHRP and localHRP) then return notify("Target or Local HRP missing") end
    
    if action == "Void" then
         local cf1 = CFrame.new(0, -10000, 0)
         local vecInf = Vector3.new(0, -10000, 0)
         local cf2 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1)
         WeldsRemote:FireServer(localHRP, targetHRP, cf1, vecInf, cf2)
         notify("Voided " .. targetName)
         
    elseif action == "Fling" then
         local cf1 = CFrame.new(-3028.23, 3101.88, 308.06, -0.91, 0, 0.4, 0, 1, 0, -0.4, 0, -0.91)
         local vecInf = Vector3.new(math.huge, math.huge, math.huge)
         local cf2 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1)
         WeldsRemote:FireServer(localHRP, targetHRP, cf1, vecInf, cf2)
         notify("Flung " .. targetName)
         
    elseif action == "Bring" then
         local cfZero = CFrame.new(0, 0, 0)
         local vecZero = Vector3.new(0, 0, 0)
         -- Using LocalPlayer's CFrame as the weld C0 seems to be the trick in Teleport.lua
         WeldsRemote:FireServer(localHRP, targetHRP, localHRP.CFrame, vecZero, cfZero)
         notify("Brought " .. targetName)
    end
end

-- Auto Remove Skills Loop
task.spawn(function()
    while not Unloaded do
        if Settings.AutoRemoveSkills then
            if ToolEquipRemote then
                 for _, player in pairs(GetUnwhitelistedPlayers()) do
                    if player.Character then
                        -- Try firing for each tool in backpack
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then
                            for _, tool in pairs(backpack:GetChildren()) do
                                if tool:IsA("Tool") then
                                    ToolEquipRemote:FireServer(tool)
                                    debugLog("AutoRemove: Backpack tool " .. tool.Name .. " from " .. player.Name)
                                end
                            end
                        end
                        -- Try firing for equipped tools
                        for _, tool in pairs(player.Character:GetChildren()) do
                             if tool:IsA("Tool") then
                                ToolEquipRemote:FireServer(tool)
                                debugLog("AutoRemove: Equipped tool " .. tool.Name .. " from " .. player.Name)
                            end
                        end
                    end
                end
                task.wait(0.2)
            else
                debugLog("AutoRemoveSkills: Remote not found")
                task.wait(2)
            end
        else
            task.wait(1)
        end
    end
end)

local function GetClosestPlayer()
    local mouse = LocalPlayer:GetMouse()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local closest, maxDist = nil, 100
    
    for _, player in ipairs(GetUnwhitelistedPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(vector.X, vector.Y) - mousePos).Magnitude
                    if dist <= maxDist then
                        maxDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- // Logic Loops
-- Click Fling
addConnection(LocalPlayer:GetMouse().Button1Down:Connect(function()
    if not Settings.ClickFling or Unloaded then return end
    if not WeldsRemote then return end

    local target = GetClosestPlayer()
    if target then
        debugLog("ClickFling target found: " .. target.Name)
        local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        
        if localHRP and targetHRP then
            local cf1 = CFrame.new(-3028.23, 3101.88, 308.06, -0.91, 0, 0.4, 0, 1, 0, -0.4, 0, -0.91)
            local vecInf = Vector3.new(math.huge, math.huge, math.huge)
            local cf2 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1)
            
            WeldsRemote:FireServer(localHRP, targetHRP, cf1, vecInf, cf2)
            notify("Flung " .. target.Name)
            debugLog("Fired fling weld on " .. target.Name)
        else
            debugLog("ClickFling failed: HRP missing")
        end
    end
end))

-- Orbit
task.spawn(function()
    local offsetTable = {}
    while not Unloaded do
        if Settings.Orbit then
            local children = Players:GetChildren()
            local targetName = Settings.TargetName
            local index = 0
            
            -- Assign offsets
            for _, player in pairs(children) do
                if player.Name ~= targetName then
                    if not offsetTable[player.Name] then
                        offsetTable[player.Name] = Vector3.new(index * 15, 0, index * 15)
                    end
                end
                index = index + 1
            end
            
            -- Orbit Logic
            local i = 0
            for _, player in pairs(children) do
                i = i + 1
                if player.Name ~= targetName and not Settings.Whitelist[player.Name] and player.Character then
                    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    
                    if targetHRP and localHRP and WeldsRemote then
                        local baseOffset = offsetTable[player.Name] or Vector3.new(0,0,0)
                        local t = tick()
                        
                        local radius = i * 5 + 35
                        local speed = i * 0.1 + 0.5
                        local angle = t * speed + i
                        
                        local x = math.cos(angle) * radius
                        local z = math.sin(angle) * radius
                        local y = math.sin(t * 2 + i) * 8
                        
                        local orbitVec = Vector3.new(x, y, z)
                        local totalVec = baseOffset + orbitVec
                        
                        local cf1 = CFrame.new(-3028.2375, 3101.888, 308.063, -0.9139, 0, 0.4057, 0, 1, 0, -0.4057, 0, -0.9139)
                        local cf2 = CFrame.new(0, 0, 0, -1, 0, -8.742e-08, 0, 1, 0, 8.742e-08, 0, -1)
                        
                        WeldsRemote:FireServer(localHRP, targetHRP, cf1, totalVec, cf2)
                    end
                end
            end
        end
        task.wait()
    end
end)

-- IFrames
-- NOTE: Exploits cannot require() Roblox modules directly.
-- Instead, we fire the Status remote directly using the same protocol.
local StatusRemote = Remotes and Remotes:FindFirstChild("Status")

local function ApplyStatus(statusName, duration)
    -- This fires the remote using the same format the game's PlayerStatus module uses on the client
    -- See: ReplicatedStorage.Modules.PlayerStatus.ApplyStatus (lines 119-126 in the original module)
    if StatusRemote then
        StatusRemote:FireServer({
            ApplyStatus = true,
            Status = statusName,
            Length = duration or false
        })
    end
end

-- Fake PlayerStatus table for backwards compatibility with existing code
local PlayerStatus = {
    ApplyStatus = function(self, character, statusName, duration)
        -- The remote doesn't need the character - it applies to LocalPlayer anyway
        -- For affecting others, this is server-validated - the client request is just for self
        ApplyStatus(statusName, duration)
    end
}

task.spawn(function()
    while not Unloaded do
        if Settings.IFrames and PlayerStatus and LocalPlayer.Character then
            pcall(function()
                PlayerStatus:ApplyStatus(LocalPlayer.Character, "IFrames", 1)
            end)
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

-- // Selector UI (Player List)
local UpdateSelectorVisuals = nil -- Exposed for Main Menu
local function createSelectorUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AetherShitter_Selector"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = CoreGui
    
    -- Protect GUI from detection if possible
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    elseif protect_gui then
        protect_gui(screenGui)
    end
    
    screenGui.Enabled = false -- Hidden by default

    local frame = Instance.new("Frame")
    frame.Name = "SelectorFrame"
    frame.Size = UDim2.new(0, 200, 0, 300)
    frame.Position = UDim2.new(0, 20, 0.5, -150)
    frame.BackgroundColor3 = Theme.Background
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.PanelStroke
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    stroke.Parent = frame
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Target Selector"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local divider = Instance.new("Frame")
    divider.BackgroundColor3 = Theme.Accent
    divider.BorderSizePixel = 0
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 0, 30)
    divider.Parent = frame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.BackgroundTransparency = 1
    scroll.Size = UDim2.new(1, -10, 1, -40)
    scroll.Position = UDim2.new(0, 5, 0, 35)
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = Theme.Accent
    scroll.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.Name
    layout.Parent = scroll
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
    end)
    
    local playerButtons = {}

    UpdateSelectorVisuals = function()
        for pName, b in pairs(playerButtons) do
             if pName == Settings.TargetName then
                b.BackgroundColor3 = Theme.Accent
                b.TextColor3 = Theme.TextPrimary
             else
                b.BackgroundColor3 = Theme.NeutralButton
                b.TextColor3 = Theme.TextSecondary
             end
        end
    end
    
    local function updateList()
        for _, btn in pairs(playerButtons) do btn:Destroy() end
        playerButtons = {}
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 24)
                btn.BackgroundColor3 = (player.Name == Settings.TargetName) and Theme.Accent or Theme.NeutralButton
                btn.Text = player.Name
                btn.TextColor3 = (player.Name == Settings.TargetName) and Theme.TextPrimary or Theme.TextSecondary
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = false
                btn.Parent = scroll
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = btn
                
                btn.MouseButton1Click:Connect(function()
                    if Settings.TargetName == player.Name then
                        Settings.TargetName = nil
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                             Camera.CameraSubject = LocalPlayer.Character.Humanoid
                        end
                    else
                        Settings.TargetName = player.Name
                        if player.Character and player.Character:FindFirstChild("Humanoid") then
                             Camera.CameraSubject = player.Character.Humanoid
                        end
                    end
                    UpdateSelectorVisuals()
                end)
                
                playerButtons[player.Name] = btn
            end
        end
    end
    
    addConnection(Players.PlayerAdded:Connect(updateList))
    addConnection(Players.PlayerRemoving:Connect(updateList))
    updateList()
    
    createDraggable(frame, titleBar)
    
    return screenGui
end

-- // Main Menu UI
local function createMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AetherShitter_Menu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = CoreGui
    
    -- Protect GUI from detection if possible
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    elseif protect_gui then
        protect_gui(screenGui)
    end

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 340, 0, 450)
    main.Position = UDim2.new(0.5, -170, 0.5, -225)
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

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = main

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "AetherShitter · Recode"
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.Parent = titleBar
    
    local divider = Instance.new("Frame")
    divider.BackgroundColor3 = Theme.Separator
    divider.Size = UDim2.new(1, -20, 0, 1)
    divider.Position = UDim2.new(0, 10, 0, 32)
    divider.BorderSizePixel = 0
    divider.Parent = main

    local content = Instance.new("ScrollingFrame")
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -20, 1, -40)
    content.Position = UDim2.new(0, 10, 0, 38)
    content.ScrollBarThickness = 2
    content.ScrollBarImageColor3 = Theme.Accent
    content.Parent = main
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    -- Helpers
    local function createSection(title)
        local label = Instance.new("TextLabel")
        label.Text = title
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextColor3 = Theme.TextMuted
        label.Size = UDim2.new(1, 0, 0, 14)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = content
    end

    local function createButton(text, color, onClick)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 12
        btn.TextColor3 = Theme.TextPrimary
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = content

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = (color == Theme.DangerDark) and Theme.DangerHover or Theme.AccentHover
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = color
        end)
        btn.MouseButton1Click:Connect(onClick)
        return btn
    end

    local function createToggle(text, initial, onChanged)
        local holder = Instance.new("Frame")
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, 0, 0, 28)
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

        button.MouseButton1Click:Connect(function()
            initial = not initial
            updateVisual(initial)
            onChanged(initial)
        end)
    end
    
    local function createInput(placeholder, onEnter)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, 0, 0, 30)
        holder.BackgroundTransparency = 1
        holder.Parent = content
        
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -60, 1, 0)
        box.BackgroundColor3 = Theme.NeutralDark
        box.Font = Enum.Font.Gotham
        box.Text = ""
        box.PlaceholderText = placeholder
        box.PlaceholderColor3 = Theme.TextMuted
        box.TextColor3 = Theme.TextPrimary
        box.TextSize = 12
        box.BorderSizePixel = 0
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.Parent = holder
        
        local boxPadding = Instance.new("UIPadding")
        boxPadding.PaddingLeft = UDim.new(0, 8)
        boxPadding.Parent = box
        
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 6)
        boxCorner.Parent = box
        
        local actionBtn = Instance.new("TextButton")
        actionBtn.Size = UDim2.new(0, 55, 1, 0)
        actionBtn.Position = UDim2.new(1, -55, 0, 0)
        actionBtn.BackgroundColor3 = Theme.NeutralButton
        actionBtn.Text = "Enter"
        actionBtn.TextColor3 = Theme.TextSecondary
        actionBtn.Font = Enum.Font.GothamBold
        actionBtn.TextSize = 11
        actionBtn.BorderSizePixel = 0
        actionBtn.Parent = holder
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = actionBtn
        
        actionBtn.MouseButton1Click:Connect(function()
             if box.Text ~= "" then
                onEnter(box.Text)
                box.Text = ""
             end
        end)
        
        box.FocusLost:Connect(function(enter)
            if enter and box.Text ~= "" then
                onEnter(box.Text)
                box.Text = ""
            end
        end)
    end

    -- [ Trolling Section ] --
    createSection("Trolling")
    createButton("Blow Everyone (Fling)", Theme.Danger, BlowEveryone)
    createButton("Void Everyone", Theme.Danger, VoidEveryone)
    createButton("Bring Everyone", Theme.Accent, BringAll)
    createButton("Spam Tools (5s)", Theme.NeutralButton, SpamTools)

    -- [ Target Actions ] --
    createSection("Target Actions")
    createButton("Void Target", Theme.Danger, function() TargetAction("Void") end)
    createButton("Fling Target", Theme.Danger, function() TargetAction("Fling") end)
    createButton("Bring Target", Theme.Accent, function() TargetAction("Bring") end)
    
    -- [ Attack Exploits ] --
    createSection("Attack Exploits")
    
    createToggle("Auto Attack (Click Spam)", Settings.AutoAttack, function(val)
        Settings.AutoAttack = val
        if val then notify("Auto Attack Enabled") end
    end)
    
    createToggle("Mouse Aimbot (Target)", Settings.MouseSpoof, function(val)
        Settings.MouseSpoof = val
        if val then 
            if not Settings.TargetName then
                notify("Select a target first!")
            else
                notify("Aimbot Enabled for: " .. Settings.TargetName) 
            end
        end
    end)
    
    createButton("Force Input: Dash", Theme.NeutralButton, function()
        local inputRemote = Remotes and Remotes:FindFirstChild("Input")
        if inputRemote then
            inputRemote:FireServer("Q")
            notify("Fired Dash Input")
        end
    end)
    
    createButton("Force Input: Ultimate", Theme.Accent, function()
        local inputRemote = Remotes and Remotes:FindFirstChild("Input")
        if inputRemote then
            inputRemote:FireServer("G")
            notify("Fired Ultimate Input")
        end
    end)
    
    createButton("Force Input: Block", Theme.NeutralButton, function()
        local inputRemote = Remotes and Remotes:FindFirstChild("Input")
        if inputRemote then
            inputRemote:FireServer("F")
            notify("Fired Block Input")
        end
    end)
    
    createButton("Force Input: Transform", Theme.Success, function()
        local inputRemote = Remotes and Remotes:FindFirstChild("Input")
        if inputRemote then
            inputRemote:FireServer("T")
            notify("Fired Transform Input")
        end
    end)
    
    -- [ Troll Features ] --
    createSection("Troll Features")
    
    createToggle("Spin Target", Settings.SpinTarget, function(val)
        Settings.SpinTarget = val
        if val then 
            if not Settings.TargetName then
                notify("Select a target first!")
            else
                notify("Spinning " .. Settings.TargetName)
            end
        end
    end)
    
    createButton("Trap Underground", Theme.DangerDark, TrapTargetUnderground)
    
    createToggle("Attach to Target (Parasite)", Settings.AttachToTarget, function(val)
        Settings.AttachToTarget = val
        if val then 
            if not Settings.TargetName then
                notify("Select a target first!")
            else
                notify("Attached to " .. Settings.TargetName)
            end
        end
    end)
    
    createToggle("Player Centipede", Settings.PlayerCentipede, function(val)
        Settings.PlayerCentipede = val
        if val then 
            notify("Centipede Mode! Everyone follows you in a line!")
        else
            notify("Centipede Disabled")
        end
    end)
    
    createToggle("Puppet Mode (Target)", Settings.PuppetMode, function(val)
        Settings.PuppetMode = val
        if val then 
            if not Settings.TargetName then
                notify("Select a target first!")
            else
                notify("Puppeting " .. Settings.TargetName .. "!")
            end
        else
            notify("Puppet Mode Disabled")
        end
    end)
    
    -- [ Trait & Title Faker ] --
    createSection("Trait & Title Faker")
    
    -- Trait Faker
    local traitLabel = Instance.new("TextLabel")
    traitLabel.Text = "Selected Trait: None"
    traitLabel.Font = Enum.Font.Gotham
    traitLabel.TextSize = 11
    traitLabel.TextColor3 = Theme.TextSecondary
    traitLabel.Size = UDim2.new(1, 0, 0, 16)
    traitLabel.BackgroundTransparency = 1
    traitLabel.TextXAlignment = Enum.TextXAlignment.Left
    traitLabel.Parent = content
    
    -- Trait Dropdown
    local traitDropdownHolder = Instance.new("Frame")
    traitDropdownHolder.Size = UDim2.new(1, 0, 0, 28)
    traitDropdownHolder.BackgroundTransparency = 1
    traitDropdownHolder.ClipsDescendants = false
    traitDropdownHolder.Parent = content
    
    local traitDropdownBtn = Instance.new("TextButton")
    traitDropdownBtn.Size = UDim2.new(1, 0, 1, 0)
    traitDropdownBtn.BackgroundColor3 = Theme.NeutralButton
    traitDropdownBtn.Text = "Select Trait..."
    traitDropdownBtn.TextColor3 = Theme.TextSecondary
    traitDropdownBtn.Font = Enum.Font.Gotham
    traitDropdownBtn.TextSize = 12
    traitDropdownBtn.BorderSizePixel = 0
    traitDropdownBtn.Parent = traitDropdownHolder
    
    local traitDropCorner = Instance.new("UICorner")
    traitDropCorner.CornerRadius = UDim.new(0, 6)
    traitDropCorner.Parent = traitDropdownBtn
    
    -- Trait List Frame
    local traitListFrame = Instance.new("Frame")
    traitListFrame.Size = UDim2.new(1, 0, 0, 150)
    traitListFrame.Position = UDim2.new(0, 0, 1, 2)
    traitListFrame.BackgroundColor3 = Theme.Panel
    traitListFrame.BorderSizePixel = 0
    traitListFrame.Visible = false
    traitListFrame.ZIndex = 50
    traitListFrame.Parent = traitDropdownHolder
    
    local traitListCorner = Instance.new("UICorner")
    traitListCorner.CornerRadius = UDim.new(0, 6)
    traitListCorner.Parent = traitListFrame
    
    local traitListStroke = Instance.new("UIStroke")
    traitListStroke.Color = Theme.PanelStroke
    traitListStroke.Thickness = 1
    traitListStroke.Parent = traitListFrame
    
    local traitScroll = Instance.new("ScrollingFrame")
    traitScroll.Size = UDim2.new(1, -4, 1, -4)
    traitScroll.Position = UDim2.new(0, 2, 0, 2)
    traitScroll.BackgroundTransparency = 1
    traitScroll.ScrollBarThickness = 3
    traitScroll.ScrollBarImageColor3 = Theme.Accent
    traitScroll.ZIndex = 51
    traitScroll.Parent = traitListFrame
    
    local traitListLayout = Instance.new("UIListLayout")
    traitListLayout.Padding = UDim.new(0, 2)
    traitListLayout.Parent = traitScroll
    
    -- Populate traits
    local allTraits = GetAllTraits()
    for _, traitData in pairs(allTraits) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 22)
        btn.BackgroundColor3 = Theme.NeutralDark
        btn.Text = traitData.DisplayName .. " (" .. traitData.Cost .. " souls)"
        btn.TextColor3 = Theme.TextSecondary
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.ZIndex = 52
        btn.Parent = traitScroll
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            Settings.SelectedTrait = traitData.Name
            traitDropdownBtn.Text = traitData.DisplayName
            traitLabel.Text = "Selected: " .. traitData.DisplayName .. " (" .. traitData.Info .. ")"
            traitListFrame.Visible = false
        end)
    end
    
    traitListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        traitScroll.CanvasSize = UDim2.new(0, 0, 0, traitListLayout.AbsoluteContentSize.Y + 4)
    end)
    
    traitDropdownBtn.MouseButton1Click:Connect(function()
        traitListFrame.Visible = not traitListFrame.Visible
    end)
    
    createButton("Equip Selected Trait", Theme.Success, function()
        if not Settings.SelectedTrait then
            return notify("Select a trait first!")
        end
        
        local traitsRemote = Remotes and Remotes:FindFirstChild("Traits")
        if traitsRemote then
            traitsRemote:FireServer({
                Equip = true,
                Trait = Settings.SelectedTrait
            })
            notify("Equipped Trait: " .. Settings.SelectedTrait)
        else
            notify("Traits remote not found!")
        end
    end)
    
    -- Title Faker
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "Selected Title: None"
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextSize = 11
    titleLabel.TextColor3 = Theme.TextSecondary
    titleLabel.Size = UDim2.new(1, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = content
    
    -- Title Dropdown
    local titleDropdownHolder = Instance.new("Frame")
    titleDropdownHolder.Size = UDim2.new(1, 0, 0, 28)
    titleDropdownHolder.BackgroundTransparency = 1
    titleDropdownHolder.ClipsDescendants = false
    titleDropdownHolder.Parent = content
    
    local titleDropdownBtn = Instance.new("TextButton")
    titleDropdownBtn.Size = UDim2.new(1, 0, 1, 0)
    titleDropdownBtn.BackgroundColor3 = Theme.NeutralButton
    titleDropdownBtn.Text = "Select Title..."
    titleDropdownBtn.TextColor3 = Theme.TextSecondary
    titleDropdownBtn.Font = Enum.Font.Gotham
    titleDropdownBtn.TextSize = 12
    titleDropdownBtn.BorderSizePixel = 0
    titleDropdownBtn.Parent = titleDropdownHolder
    
    local titleDropCorner = Instance.new("UICorner")
    titleDropCorner.CornerRadius = UDim.new(0, 6)
    titleDropCorner.Parent = titleDropdownBtn
    
    -- Title List Frame
    local titleListFrame = Instance.new("Frame")
    titleListFrame.Size = UDim2.new(1, 0, 0, 150)
    titleListFrame.Position = UDim2.new(0, 0, 1, 2)
    titleListFrame.BackgroundColor3 = Theme.Panel
    titleListFrame.BorderSizePixel = 0
    titleListFrame.Visible = false
    titleListFrame.ZIndex = 50
    titleListFrame.Parent = titleDropdownHolder
    
    local titleListCorner = Instance.new("UICorner")
    titleListCorner.CornerRadius = UDim.new(0, 6)
    titleListCorner.Parent = titleListFrame
    
    local titleListStroke = Instance.new("UIStroke")
    titleListStroke.Color = Theme.PanelStroke
    titleListStroke.Thickness = 1
    titleListStroke.Parent = titleListFrame
    
    local titleScroll = Instance.new("ScrollingFrame")
    titleScroll.Size = UDim2.new(1, -4, 1, -4)
    titleScroll.Position = UDim2.new(0, 2, 0, 2)
    titleScroll.BackgroundTransparency = 1
    titleScroll.ScrollBarThickness = 3
    titleScroll.ScrollBarImageColor3 = Theme.Accent
    titleScroll.ZIndex = 51
    titleScroll.Parent = titleListFrame
    
    local titleListLayout = Instance.new("UIListLayout")
    titleListLayout.Padding = UDim.new(0, 2)
    titleListLayout.Parent = titleScroll
    
    -- Populate titles
    local allTitles = GetAllTitles()
    for _, titleData in pairs(allTitles) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 22)
        btn.BackgroundColor3 = Theme.NeutralDark
        btn.Text = titleData.Value .. " (" .. titleData.Kills .. " kills)"
        btn.TextColor3 = Theme.TextSecondary
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.ZIndex = 52
        btn.Parent = titleScroll
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            Settings.SelectedTitle = titleData.Value
            titleDropdownBtn.Text = titleData.Value
            titleLabel.Text = "Selected: " .. titleData.Value
            titleListFrame.Visible = false
        end)
    end
    
    titleListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        titleScroll.CanvasSize = UDim2.new(0, 0, 0, titleListLayout.AbsoluteContentSize.Y + 4)
    end)
    
    titleDropdownBtn.MouseButton1Click:Connect(function()
        titleListFrame.Visible = not titleListFrame.Visible
    end)
    
    createButton("Equip Selected Title", Theme.Success, function()
        if not Settings.SelectedTitle then
            return notify("Select a title first!")
        end
        
        local titleRemote = Remotes and Remotes:FindFirstChild("TitleChange")
        if titleRemote then
            titleRemote:FireServer({
                TitleName = Settings.SelectedTitle
            })
            notify("Equipped Title: " .. Settings.SelectedTitle)
        else
            notify("TitleChange remote not found!")
        end
    end)
    
    -- [ Toggles Section ] --
    createSection("Toggles")
    createToggle("Loop Void (Kill Aura)", Settings.LoopVoid, function(val)
        Settings.LoopVoid = val
        if val then notify("Loop Void Enabled") else notify("Loop Void Disabled") end
    end)

    createToggle("Auto Remove Skills", Settings.AutoRemoveSkills, function(val)
        Settings.AutoRemoveSkills = val
        if val then notify("Auto Remove Skills Enabled") else notify("Auto Remove Skills Disabled") end
    end)
    
    createToggle("Click Fling (Left Mouse)", Settings.ClickFling, function(val)
        Settings.ClickFling = val
    end)
    
    createToggle("Orbit", Settings.Orbit, function(val)
        Settings.Orbit = val
        if not val and WeldsRemote and LocalPlayer.Character then
            -- Stop orbiting immediate effect if needed
        end
    end)
    
    createToggle("God Mode / IFrames", Settings.IFrames, function(val)
        Settings.IFrames = val
    end)

    createToggle("Anti-Debuff", Settings.AntiDebuff, function(val)
        Settings.AntiDebuff = val
        if val then notify("Anti-Debuff Enabled") else notify("Anti-Debuff Disabled") end
    end)
    
    createToggle("Self Ragdoll", Settings.SelfRagdoll, function(val)
        Settings.SelfRagdoll = val
        -- Toggle ragdoll state directly via the character's RagdollTrigger BoolValue
        -- This is what the game's MovementClient checks for ragdoll state (no remote needed!)
        local character = LocalPlayer.Character
        if character then
            local ragdollTrigger = character:FindFirstChild("RagdollTrigger")
            if ragdollTrigger then
                ragdollTrigger.Value = val
                notify("Self Ragdoll: " .. (val and "ON" or "OFF"))
            else
                notify("RagdollTrigger not found - respawn first?")
            end
        end
    end)
    
    -- [ Exploits ] --
    createSection("Exploits")
    
    createToggle("Anti-Knockback", false, function(val)
        if not getconnections then return notify("Executor missing 'getconnections'") end
        
        local velocityRemote = Remotes and Remotes:FindFirstChild("Velocity")
        if not velocityRemote then return notify("Velocity remote not found") end
        
        for _, conn in pairs(getconnections(velocityRemote.OnClientEvent)) do
            if val then
                conn:Disable()
            else
                conn:Enable()
            end
        end
        notify("Anti-Knockback: " .. (val and "ON" or "OFF"))
    end)



    createToggle("Infinite Jump", false, function(val)
        if val then
            local jumpConnection
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            getgenv().InfiniteJumpConnection = jumpConnection
        else
            if getgenv().InfiniteJumpConnection then
                getgenv().InfiniteJumpConnection:Disconnect()
                getgenv().InfiniteJumpConnection = nil
            end
        end
    end)
    
    createButton("Force Recover (Anti-Stun)", Theme.Success, function()
        local recover = Remotes:FindFirstChild("Recover")
        if recover then
            recover:FireServer(0.1, 0.1)
            notify("Fired Recover")
        else
            notify("Recover remote not found")
        end
    end)
    
    createButton("Flash Step (Forward)", Theme.NeutralButton, function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(100000, 0, 100000)
            bv.Velocity = hrp.CFrame.LookVector * 150
            game.Debris:AddItem(bv, 0.15)
        end
    end)



    -- [ Target Selector ] --
    createSection("Target Selector")
    local SelectorGui = createSelectorUI()
    createToggle("Show Target List", Settings.AttacherVisible, function(val)
        Settings.AttacherVisible = val
        if SelectorGui then SelectorGui.Enabled = val end
    end)
    
    createButton("Reset Target (Self)", Theme.NeutralButton, function()
        Settings.TargetName = nil
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
        if UpdateSelectorVisuals then UpdateSelectorVisuals() end
        notify("Target reset to Self")
    end)

    -- [ Whitelist Section ] --
    createSection("Whitelist Manager")
    
    local whitelistLabel = Instance.new("TextLabel")
    whitelistLabel.Text = "Current Whitelist: " .. LocalPlayer.Name
    whitelistLabel.Font = Enum.Font.Gotham
    whitelistLabel.TextSize = 11
    whitelistLabel.TextColor3 = Theme.TextSecondary
    whitelistLabel.Size = UDim2.new(1, 0, 0, 14)
    whitelistLabel.BackgroundTransparency = 1
    whitelistLabel.TextXAlignment = Enum.TextXAlignment.Left
    whitelistLabel.Parent = content
    
    local function updateWhitelistLabel()
        local names = {}
        for name, _ in pairs(Settings.Whitelist) do
            table.insert(names, name)
        end
        whitelistLabel.Text = "Whitelisted: " .. table.concat(names, ", ")
    end
    
    createInput("Add to Whitelist...", function(text)
        Settings.Whitelist[text] = true
        updateWhitelistLabel()
        notify("Added " .. text .. " to whitelist")
    end)
    
    createInput("Remove from Whitelist...", function(text)
        if text ~= LocalPlayer.Name then
            Settings.Whitelist[text] = nil
            updateWhitelistLabel()
            notify("Removed " .. text .. " from whitelist")
        end
    end)
    
    -- [ Unload ] --
    createSection("Settings")
    createButton("Unload Script", Theme.DangerDark, function()
        Unloaded = true
        screenGui:Destroy()
        if SelectorGui then SelectorGui:Destroy() end
        for _, c in pairs(Connections) do c:Disconnect() end
        notify("Unloaded.")
    end)

    createDraggable(main, titleBar)
    return screenGui
end

-- // Initialize
createMenu()
notify("Loaded successfully.")

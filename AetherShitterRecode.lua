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

-- Load shared UI module
local LunarityUI = loadstring(game:HttpGet("https://api.relayed.network/ui"))()
local Theme = LunarityUI.Theme
local AccentGradientSequence = LunarityUI.AccentGradientSequence
local BackgroundGradientSequence = LunarityUI.BackgroundGradientSequence
local DangerGradientSequence = LunarityUI.DangerGradientSequence

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
    -- Defaults
    Settings.OrbitRange = Settings.OrbitRange or 35
    Settings.OrbitSpeed = Settings.OrbitSpeed or 1
    
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
                        
                        local radius = i * 5 + Settings.OrbitRange
                        local speed = (i * 0.1 + 0.5) * Settings.OrbitSpeed
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
    local selectorWindow = LunarityUI.CreateWindow({
        Name = "AetherShitter_Selector",
        Title = "Target",
        Subtitle = "Selector",
        Size = UDim2.new(0, 200, 0, 300),
        Position = UDim2.new(0, 20, 0.5, -150),
        Closable = false,
        Minimizable = false
    })
    
    selectorWindow.ScreenGui.Enabled = false -- Hidden by default
    
    if syn and syn.protect_gui then
        syn.protect_gui(selectorWindow.ScreenGui)
    end
    
    local playerList = selectorWindow.createPlayerList("Players", 220,
        function(player)
            Settings.TargetName = player.Name
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                Camera.CameraSubject = hum
            end
            notify("Target: " .. player.Name)
            if UpdateSelectorVisuals then UpdateSelectorVisuals() end
        end,
        nil
    )
    
    UpdateSelectorVisuals = function()
        playerList.refresh(
            function(p) return Settings.TargetName == p.Name end,
            function(p) return Settings.Whitelist[p.Name] end
        )
    end
    
    -- Auto-refresh loop
    task.spawn(function()
        while not Unloaded do
            UpdateSelectorVisuals()
            task.wait(2)
        end
    end)
    
    return selectorWindow
end

-- // Main Menu UI
local function createMenu()
    local window = LunarityUI.CreateWindow({
        Name = "AetherShitter_Menu",
        Title = "AetherShitter",
        Subtitle = "Recode",
        Size = UDim2.new(0, 340, 0, 500),
        Position = UDim2.new(0.5, -170, 0.5, -250),
    })
    
    if syn and syn.protect_gui then
        syn.protect_gui(window.ScreenGui)
    end
    
    -- [ Combat Section ] --
    window.createSection("Combat")
    
    window.createToggle("Click Fling", Settings.ClickFling, function(val)
        Settings.ClickFling = val
        notify("Click Fling: " .. (val and "ON" or "OFF"))
    end)
    
    window.createToggle("Auto Attack", Settings.AutoAttack, function(val)
        Settings.AutoAttack = val
        notify("Auto Attack: " .. (val and "ON" or "OFF"))
    end)
    
    window.createToggle("Loop Void Target", Settings.LoopVoid, function(val)
        Settings.LoopVoid = val
        notify("Loop Void: " .. (val and "ON" or "OFF"))
    end)
    
    window.createToggle("Auto Remove Skills", Settings.AutoRemoveSkills, function(val)
        Settings.AutoRemoveSkills = val
        notify("Auto Remove Skills: " .. (val and "ON" or "OFF"))
    end)
    
    window.createButton("Spam Tools (5s)", false, SpamTools)
    
    -- [ Movement Section ] --
    window.createSection("Movement")
    
    window.createToggle("Orbit Target", Settings.Orbit, function(val)
        Settings.Orbit = val
        notify("Orbit: " .. (val and "ON" or "OFF"))
    end)
    
    window.createSlider("Orbit Range", 5, 50, Settings.OrbitRange or 35, 0, function(val)
        Settings.OrbitRange = val
    end)
    
    window.createSlider("Orbit Speed", 0.5, 5, Settings.OrbitSpeed or 1, 1, function(val)
        Settings.OrbitSpeed = val
    end)
    
    window.createToggle("Infinite Jump", false, function(val)
        if val then
            local jumpConn = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            getgenv().InfiniteJumpConnection = jumpConn
        else
            if getgenv().InfiniteJumpConnection then
                getgenv().InfiniteJumpConnection:Disconnect()
                getgenv().InfiniteJumpConnection = nil
            end
        end
    end)
    
    window.createButton("Flash Step (Forward)", false, function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(100000, 0, 100000)
            bv.Velocity = hrp.CFrame.LookVector * 150
            game.Debris:AddItem(bv, 0.15)
        end
    end)
    
    -- [ Protection Section ] --
    window.createSection("Protection")
    
    window.createToggle("IFrames", Settings.IFrames, function(val)
        Settings.IFrames = val
        notify("IFrames: " .. (val and "ON" or "OFF"))
    end)
    
    window.createToggle("Anti-Debuff", Settings.AntiDebuff, function(val)
        Settings.AntiDebuff = val
        notify("Anti-Debuff: " .. (val and "ON" or "OFF"))
    end)
    
    window.createToggle("Anti-Knockback", false, function(val)
        if not getconnections then return notify("Executor missing 'getconnections'") end
        local velocityRemote = Remotes and Remotes:FindFirstChild("Velocity")
        if not velocityRemote then return notify("Velocity remote not found") end
        for _, conn in pairs(getconnections(velocityRemote.OnClientEvent)) do
            if val then conn:Disable() else conn:Enable() end
        end
        notify("Anti-Knockback: " .. (val and "ON" or "OFF"))
    end)
    
    window.createToggle("Self Ragdoll", Settings.SelfRagdoll, function(val)
        Settings.SelfRagdoll = val
        local character = LocalPlayer.Character
        if character then
            local ragdollTrigger = character:FindFirstChild("RagdollTrigger")
            if ragdollTrigger then
                ragdollTrigger.Value = val
                notify("Self Ragdoll: " .. (val and "ON" or "OFF"))
            end
        end
    end)
    
    window.createButton("Force Recover (Anti-Stun)", true, function()
        local recover = Remotes:FindFirstChild("Recover")
        if recover then
            recover:FireServer(0.1, 0.1)
            notify("Fired Recover")
        else
            notify("Recover remote not found")
        end
    end)
    
    -- [ Trolling Section ] --
    window.createSection("Trolling")
    window.createButton("Blow Everyone", true, BlowEveryone)
    window.createButton("Void Everyone", true, VoidEveryone)
    window.createButton("Bring Everyone", false, BringAll)
    
    window.createToggle("Player Centipede", Settings.PlayerCentipede, function(val)
        Settings.PlayerCentipede = val
        notify("Centipede: " .. (val and "ON" or "OFF"))
    end)
    
    -- [ Target Actions ] --
    window.createSection("Target Actions")
    
    local selectorWindow = createSelectorUI()
    
    window.createToggle("Show Target List", Settings.AttacherVisible, function(val)
        Settings.AttacherVisible = val
        if selectorWindow then selectorWindow.ScreenGui.Enabled = val end
    end)
    
    window.createButton("Reset Target (Self)", false, function()
        Settings.TargetName = nil
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
        if UpdateSelectorVisuals then UpdateSelectorVisuals() end
        notify("Target reset to Self")
    end)
    
    window.createButton("Void Target", true, function() TargetAction("Void") end)
    window.createButton("Fling Target", true, function() TargetAction("Fling") end)
    window.createButton("Bring Target", false, function() TargetAction("Bring") end)
    
    window.createToggle("Spin Target", Settings.SpinTarget, function(val)
        Settings.SpinTarget = val
    end)
    
    window.createButton("Trap Underground", true, TrapTargetUnderground)
    
    window.createToggle("Attach to Target", Settings.AttachToTarget, function(val)
        Settings.AttachToTarget = val
    end)
    
    window.createToggle("Puppet Mode", Settings.PuppetMode, function(val)
        Settings.PuppetMode = val
    end)
    
    window.createToggle("Mouse Aimbot", Settings.MouseSpoof, function(val)
        Settings.MouseSpoof = val
    end)
    
    -- [ Input Spoofing ] --
    window.createSection("Input Spoofing")
    local inputs = {{"Dash", "Q"}, {"Ultimate", "G"}, {"Block", "F"}, {"Transform", "T"}}
    for _, inp in ipairs(inputs) do
        window.createButton("Force " .. inp[1], false, function()
            local inputRemote = Remotes and Remotes:FindFirstChild("Input")
            if inputRemote then
                inputRemote:FireServer(inp[2])
                notify("Fired " .. inp[1])
            end
        end)
    end
    
    -- [ Fakers ] --
    window.createSection("Fakers")
    
    -- Trait Faker
    local traitLabel = window.createLabelValue("Trait", "None")
    local traitToggleBtn = window.createButton("Select Trait...", false, function() end) -- Placeholder callback
    
    local traitNames = {}
    local traitDataMap = {}
    for _, t in ipairs(GetAllTraits()) do
        table.insert(traitNames, t.DisplayName)
        traitDataMap[t.DisplayName] = t
    end
    
    local traitList = window.createDropdownList("Traits", 150)
    traitList.frame.Visible = false
    
    for _, name in ipairs(traitNames) do
        traitList.addItem(name, function()
            local tData = traitDataMap[name]
            Settings.SelectedTrait = tData.Name
            traitLabel.setValue(name)
            traitToggleBtn.Text = "Select Trait... (" .. name .. ")"
            traitList.frame.Visible = false
        end)
    end
    
    traitToggleBtn.MouseButton1Click:Connect(function()
        traitList.frame.Visible = not traitList.frame.Visible
    end)
    
    window.createButton("Equip Trait", true, function()
        if Settings.SelectedTrait then
            local traitsRemote = Remotes and Remotes:FindFirstChild("Traits")
            if traitsRemote then
                traitsRemote:FireServer({Equip = true, Trait = Settings.SelectedTrait})
                notify("Equipped: " .. Settings.SelectedTrait)
            end
        else
            notify("Select a trait first!")
        end
    end)
    
    -- Title Faker
    window.createSeparator()
    local titleLabel = window.createLabelValue("Title", "None")
    local titleToggleBtn = window.createButton("Select Title...", false, function() end)
    
    local titleNames = {}
    local titleDataMap = {}
    for _, t in ipairs(GetAllTitles()) do
        table.insert(titleNames, t.Value)
        titleDataMap[t.Value] = t
    end
    
    local titleList = window.createDropdownList("Titles", 150)
    titleList.frame.Visible = false
    
    for _, name in ipairs(titleNames) do
        titleList.addItem(name, function()
            local tData = titleDataMap[name]
            Settings.SelectedTitle = tData.Value
            titleLabel.setValue(name)
            titleToggleBtn.Text = "Select Title... (" .. name .. ")"
            titleList.frame.Visible = false
        end)
    end
    
    titleToggleBtn.MouseButton1Click:Connect(function()
        titleList.frame.Visible = not titleList.frame.Visible
    end)
    
    window.createButton("Equip Title", true, function()
        if Settings.SelectedTitle then
            local titleRemote = Remotes and Remotes:FindFirstChild("TitleChange")
            if titleRemote then
                titleRemote:FireServer({TitleName = Settings.SelectedTitle})
                notify("Equipped: " .. Settings.SelectedTitle)
            end
        else
            notify("Select a title first!")
        end
    end)
    
    -- [ Whitelist ] --
    window.createSection("Whitelist")
    
    local whitelistLabel = window.createLabelValue("Whitelisted", LocalPlayer.Name)
    local function updateWhitelistLabel()
        local names = {}
        for name, _ in pairs(Settings.Whitelist) do
            table.insert(names, name)
        end
        whitelistLabel.setValue(table.concat(names, ", "))
    end
    
    window.createTextBox("Add to Whitelist...", function(text)
        Settings.Whitelist[text] = true
        updateWhitelistLabel()
        notify("Added " .. text)
    end)
    
    window.createTextBox("Remove from Whitelist...", function(text)
        if text ~= LocalPlayer.Name then
            Settings.Whitelist[text] = nil
            updateWhitelistLabel()
            notify("Removed " .. text)
        end
    end)
    
    -- [ Settings ] --
    window.createSection("Settings")
    
    window.createButton("Unload Script", true, function()
        Unloaded = true
        if selectorWindow then selectorWindow.destroy() end
        window.destroy()
        for _, c in pairs(Connections) do c:Disconnect() end
        notify("Unloaded.")
    end)
    
    return window.ScreenGui
end

-- // Initialize
createMenu()
notify("Loaded successfully.")

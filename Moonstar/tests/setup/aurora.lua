-- Aurora: A Roblox Environment Emulator
-- Compatibility wrapper - loads the modular Aurora system

-- Determine script directory
local info = debug.getinfo(1, "S")
local scriptPath = info.source:sub(2)
local scriptDir = scriptPath:match("(.*/)" ) or scriptPath:match("(.*\\)") or "./"

-- Load the modular Aurora system
local auroraPath = scriptDir .. "aurora/init.lua"
local chunk, err = loadfile(auroraPath)

if chunk then
    local Aurora = chunk()
    
    -- Set up the global environment
    Aurora.setup(_G)
    
    -- Export Aurora module for advanced usage
    _G.Aurora = Aurora
    
    return Aurora
else
    -- Fallback: Minimal legacy implementation if modular system fails
    warn("Failed to load modular Aurora: " .. tostring(err))
    warn("Using minimal fallback implementation")
    
    -- Minimal Instance implementation
    local Instance = {}
    Instance.__index = Instance

    function Instance.new(className)
        local self = setmetatable({}, Instance)
        self.ClassName = className
        self.Children = {}
        self.Parent = nil
        self.Name = className
        self.Attributes = {}
        return self
    end

    function Instance:GetChildren()
        return self.Children
    end

    function Instance:FindFirstChild(name)
        for _, child in ipairs(self.Children) do
            if child.Name == name then
                return child
            end
        end
        return nil
    end

    function Instance:GetAttribute(attribute)
        return self.Attributes and self.Attributes[attribute]
    end

    function Instance:SetAttribute(attribute, value)
        self.Attributes = self.Attributes or {}
        self.Attributes[attribute] = value
    end

    function Instance:ClearAllChildren()
        self.Children = {}
    end

    function Instance:Destroy()
        self.Parent = nil
        self.Children = nil
    end

    -- Mock game
    local game = Instance.new("DataModel")
    local workspace = Instance.new("Workspace")
    workspace.Name = "Workspace"
    workspace.Parent = game
    game.Workspace = workspace

    -- Services
    local services = {
        CoreGui = Instance.new("CoreGui"),
        Players = Instance.new("Players"),
        ReplicatedStorage = Instance.new("ReplicatedStorage"),
        UserInputService = Instance.new("UserInputService"),
        RunService = Instance.new("RunService"),
        HttpService = Instance.new("HttpService"),
    }

    -- LocalPlayer
    local LocalPlayer = Instance.new("Player")
    LocalPlayer.Name = "LocalPlayer"
    services.Players.LocalPlayer = LocalPlayer

    -- Camera
    local Camera = Instance.new("Camera")
    workspace.CurrentCamera = Camera

    function game:GetService(serviceName)
        return services[serviceName]
    end

    -- Basic data types
    local Vector3 = { new = function(...) return {...} end }
    local CFrame = { new = function(...) return {...} end }
    local Color3 = { 
        new = function(...) return {...} end,
        fromRGB = function(...) return {...} end 
    }
    local UDim2 = { new = function(...) return {...} end }

    -- Basic Enum
    local Enum = {
        KeyCode = { RightControl = "RightControl", RightAlt = "RightAlt" },
        Font = { Gotham = "Gotham", GothamSemibold = "GothamSemibold" },
        TextXAlignment = { Left = "Left", Right = "Right" },
        HighlightDepthMode = { AlwaysOnTop = "AlwaysOnTop" },
        ZIndexBehavior = { Global = "Global" },
        FillDirection = { Vertical = "Vertical" },
        HorizontalAlignment = { Left = "Left" },
        SortOrder = { LayoutOrder = "LayoutOrder" },
        UserInputType = { MouseButton1 = "MouseButton1" }
    }

    -- Set globals
    _G.game = game
    _G.workspace = workspace
    _G.Instance = Instance
    _G.Vector3 = Vector3
    _G.CFrame = CFrame
    _G.Color3 = Color3
    _G.UDim2 = UDim2
    _G.Enum = Enum
    _G.printidentity = print
end

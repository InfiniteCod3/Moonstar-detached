-- Aurora: A Roblox Environment Emulator

-- Mock Instance
local Instance = {}
Instance.__index = Instance

function Instance.new(className)
    local self = setmetatable({}, Instance)
    self.ClassName = className
    self.Children = {}
    self.Parent = nil
    self.Name = ""
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
    if self.Attributes and self.Attributes[attribute] then
        return self.Attributes[attribute]
    end
    return nil
end

function Instance:ClearAllChildren()
    self.Children = {}
end

function Instance:Destroy()
    self.Parent = nil
    self.Children = nil
end

-- Mock Services
local game = Instance.new("DataModel")
local workspace = Instance.new("Workspace")
workspace.Name = "Workspace"
workspace.Parent = game
game.Workspace = workspace

local CoreGui = Instance.new("CoreGui")
local Players = Instance.new("Players")
local ReplicatedStorage = Instance.new("ReplicatedStorage")
local UserInputService = Instance.new("UserInputService")
local RunService = Instance.new("RunService")
local HttpService = Instance.new("HttpService")

game:GetService = function(serviceName)
    if serviceName == "CoreGui" then return CoreGui end
    if serviceName == "Players" then return Players end
    if serviceName == "ReplicatedStorage" then return ReplicatedStorage end
    if serviceName == "UserInputService" then return UserInputService end
    if serviceName == "RunService" then return RunService end
    if serviceName == "HttpService" then return HttpService end
    return nil
end

-- Mock Player
local LocalPlayer = Instance.new("Player")
LocalPlayer.Name = "LocalPlayer"
Players.LocalPlayer = LocalPlayer

-- Mock Camera
local Camera = Instance.new("Camera")
workspace.CurrentCamera = Camera

-- Mock DataTypes
local Vector3 = {}
function Vector3.new(...) return {...} end

local CFrame = {}
function CFrame.new(...) return {...} end

local Color3 = {}
function Color3.fromRGB(...) return {...} end

local UDim2 = {}
function UDim2.new(...) return {...} end

local Enum = {
    KeyCode = {
        RightControl = "RightControl",
        RightAlt = "RightAlt",
    },
    Font = {
        Gotham = "Gotham",
        GothamSemibold = "GothamSemibold",
    },
    TextXAlignment = {
        Left = "Left",
        Right = "Right",
    },
    HighlightDepthMode = {
        AlwaysOnTop = "AlwaysOnTop",
    },
    ZIndexBehavior = {
        Global = "Global",
    },
    FillDirection = {
        Vertical = "Vertical",
    },
    HorizontalAlignment = {
        Left = "Left",
    },
    SortOrder = {
        LayoutOrder = "LayoutOrder",
    },
    UserInputType = {
        MouseButton1 = "MouseButton1",
    }
}

-- Globals
_G.game = game
_G.workspace = workspace
_G.Instance = Instance
_G.Vector3 = Vector3
_G.CFrame = CFrame
_G.Color3 = Color3
_G.UDim2 = UDim2
_G.Enum = Enum
_G.printidentity = print

function _G.print(...)
    local args = {...}
    local strings = {}
    for i = 1, #args do
        strings[i] = tostring(args[i])
    end
    printidentity(table.concat(strings, "\t"))
end

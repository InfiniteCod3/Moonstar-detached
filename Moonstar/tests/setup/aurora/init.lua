-- Aurora: A Roblox Environment Emulator
-- Main initialization module

local Aurora = {}
Aurora._VERSION = "2.0.0"
Aurora._DESCRIPTION = "Roblox environment emulator for testing Lua/Luau scripts"

-- ============================================================================
-- Module Loading Helper
-- ============================================================================

-- Get the directory of this script
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local scriptDir = scriptPath:match("(.*/)" ) or scriptPath:match("(.*\\)") or "./"

-- Custom require for loading Aurora modules
local function auroraRequire(moduleName)
    local path = scriptDir .. moduleName .. ".lua"
    local chunk, err = loadfile(path)
    if not chunk then
        error("Failed to load Aurora module '" .. moduleName .. "': " .. tostring(err))
    end
    return chunk()
end

-- ============================================================================
-- Load Core Modules
-- ============================================================================

local Signal = auroraRequire("signal")
local TypeofModule = auroraRequire("typeof")
local DataTypes = auroraRequire("datatypes")
local InstanceModule = auroraRequire("instance")
local Services = auroraRequire("services")
local Executor = auroraRequire("executor")
local Task = auroraRequire("task")
local Enum = auroraRequire("enum")

-- ============================================================================
-- Extract Types
-- ============================================================================

local Instance = InstanceModule.Instance
local typeof = TypeofModule.typeof
local registerType = TypeofModule.registerType

-- Register Instance type
registerType(Instance, "Instance")

-- ============================================================================
-- Create Game Structure
-- ============================================================================

-- Create the DataModel (game)
local game = Instance.new("DataModel")
game.Name = "Game"
game.PlaceId = 0
game.GameId = 0
game.JobId = ""
game.CreatorId = 0
game.CreatorType = "User"
game.PrivateServerId = ""
game.PrivateServerOwnerId = 0

-- Create Workspace
local workspace = Instance.new("Workspace")
workspace.Name = "Workspace"
workspace.Parent = game
workspace.Gravity = 196.2
workspace.FallenPartsDestroyHeight = -500
workspace.StreamingEnabled = false

-- Create Camera for workspace
local camera = Instance.new("Camera")
camera.Name = "CurrentCamera"
camera.Parent = workspace
workspace.CurrentCamera = camera

-- Initialize services with dependencies
Services.init({
    Instance = Instance,
    game = game,
    workspace = workspace
})

-- ============================================================================
-- Service Access
-- ============================================================================

-- GetService implementation for game
function game:GetService(serviceName)
    if Services[serviceName] then
        return Services[serviceName]
    end
    
    -- Create service instance if not exists
    local service = Instance.new(serviceName)
    service.Name = serviceName
    service.Parent = game
    Services[serviceName] = service
    return service
end

-- FindService implementation
function game:FindService(serviceName)
    return Services[serviceName]
end

-- GetChildren for game
function game:GetChildren()
    local children = {}
    for name, service in pairs(Services) do
        if type(service) == "table" and service.ClassName then
            table.insert(children, service)
        end
    end
    -- Add workspace
    table.insert(children, workspace)
    return children
end

-- FindFirstChild for game
function game:FindFirstChild(name)
    if name == "Workspace" then return workspace end
    return Services[name]
end

-- Direct service access via game.ServiceName
setmetatable(game, {
    __index = function(self, key)
        -- Check for Workspace special case
        if key == "Workspace" then
            return workspace
        end
        
        -- Check services
        if Services[key] then
            return Services[key]
        end
        
        -- Fall back to Instance methods
        return Instance[key]
    end
})

-- ============================================================================
-- Global Functions
-- ============================================================================

--- Roblox-style print
local function rbxPrint(...)
    local args = {...}
    local strings = {}
    for i = 1, select("#", ...) do
        strings[i] = tostring(args[i])
    end
    print(table.concat(strings, " "))
end

--- Roblox-style warn
local function rbxWarn(...)
    local args = {...}
    local strings = {}
    for i = 1, select("#", ...) do
        strings[i] = tostring(args[i])
    end
    io.stderr:write("[WARN] " .. table.concat(strings, " ") .. "\n")
end

--- Roblox-style error (non-fatal)
local function rbxError(message, level)
    error(message, (level or 1) + 1)
end

--- Wait function (yields for duration)
local function wait(duration)
    return Task.wait(duration or 0)
end

--- Delay function
local function delay(duration, callback)
    Task.delay(duration, callback)
end

--- Spawn function
local function spawn(callback)
    Task.spawn(callback)
end

--- Tick function (time since epoch)
local function tick()
    return os.time() + (os.clock() % 1)
end

--- Time function (time since game start)
local gameStartTime = os.clock()
local function time()
    return os.clock() - gameStartTime
end

--- ElapsedTime function
local function elapsedTime()
    return os.clock()
end

--- PrintIdentity function
local function printidentity(prefix)
    print((prefix or "") .. "Current identity is 2")
end

--- Settings function (mock)
local function settings()
    return {
        Rendering = {
            QualityLevel = 10
        },
        Physics = {
            AllowSleep = true
        },
        Studio = {
            Theme = "Dark"
        }
    }
end

--- UserSettings function (mock)
local function UserSettings()
    return {
        GetService = function(self, name)
            return {}
        end,
        GameSettings = {
            VideoQuality = 10
        }
    }
end

--- Stats function (mock)
local function stats()
    return {
        GetTotalMemoryUsageMb = function() return 256 end,
        GetMemoryUsageMbForTag = function() return 64 end,
    }
end

--- PluginManager (mock)
local function PluginManager()
    return {}
end

--- Version function
local function version()
    return "0.0.0.0"
end

--- Shared table
local shared = {}

-- ============================================================================
-- Set Up Global Environment
-- ============================================================================

function Aurora.setup(env)
    env = env or _G
    
    -- Core globals
    env.game = game
    env.Game = game
    env.workspace = workspace
    env.Workspace = workspace
    env.Instance = Instance
    env.Enum = Enum
    
    -- Data types
    env.Vector2 = DataTypes.Vector2
    env.Vector3 = DataTypes.Vector3
    env.CFrame = DataTypes.CFrame
    env.Color3 = DataTypes.Color3
    env.UDim = DataTypes.UDim
    env.UDim2 = DataTypes.UDim2
    env.ColorSequence = DataTypes.ColorSequence
    env.ColorSequenceKeypoint = DataTypes.ColorSequenceKeypoint
    env.NumberSequence = DataTypes.NumberSequence
    env.NumberSequenceKeypoint = DataTypes.NumberSequenceKeypoint
    env.NumberRange = DataTypes.NumberRange
    env.Ray = DataTypes.Ray
    env.BrickColor = DataTypes.BrickColor
    env.TweenInfo = DataTypes.TweenInfo
    env.Rect = DataTypes.Rect
    env.RaycastParams = DataTypes.RaycastParams
    env.Axes = DataTypes.Axes
    env.Faces = DataTypes.Faces
    
    -- Functions
    env.typeof = typeof
    env.print = rbxPrint
    env.warn = rbxWarn
    env.wait = wait
    env.Wait = wait
    env.delay = delay
    env.Delay = delay
    env.spawn = spawn
    env.Spawn = spawn
    env.tick = tick
    env.time = time
    env.elapsedTime = elapsedTime
    env.printidentity = printidentity
    env.settings = settings
    env.UserSettings = UserSettings
    env.stats = stats
    env.PluginManager = PluginManager
    env.version = version
    
    -- Task library
    env.task = Task
    
    -- Shared table
    env.shared = shared
    
    -- Executor functions
    env.getgenv = Executor.getgenv
    env.getrenv = Executor.getrenv
    env.getreg = Executor.getreg
    env.getfenv = Executor.getfenv
    env.setfenv = Executor.setfenv
    env.getgc = Executor.getgc
    env.getinstances = Executor.getinstances
    env.getnilinstances = Executor.getnilinstances
    env.getscripts = Executor.getscripts
    env.getloadedmodules = Executor.getloadedmodules
    env.getconnections = Executor.getconnections
    env.newcclosure = Executor.newcclosure
    env.newlclosure = Executor.newlclosure
    env.iscclosure = Executor.iscclosure
    env.islclosure = Executor.islclosure
    env.hookfunction = Executor.hookfunction
    env.hookmetamethod = Executor.hookmetamethod
    env.getrawmetatable = Executor.getrawmetatable
    env.setrawmetatable = Executor.setrawmetatable
    env.isreadonly = Executor.isreadonly
    env.setreadonly = Executor.setreadonly
    env.getinfo = Executor.getinfo
    env.getconstants = Executor.getconstants
    env.setconstant = Executor.setconstant
    env.getconstant = Executor.getconstant
    env.getupvalues = Executor.getupvalues
    env.getupvalue = Executor.getupvalue
    env.setupvalue = Executor.setupvalue
    env.getprotos = Executor.getprotos
    env.getproto = Executor.getproto
    env.getstack = Executor.getstack
    env.setstack = Executor.setstack
    
    -- File operations
    env.isfile = Executor.isfile
    env.isfolder = Executor.isfolder
    env.readfile = Executor.readfile
    env.writefile = Executor.writefile
    env.appendfile = Executor.appendfile
    env.delfile = Executor.delfile
    env.makefolder = Executor.makefolder
    env.delfolder = Executor.delfolder
    env.listfiles = Executor.listfiles
    env.loadfile = Executor.loadfile
    env.dofile = Executor.dofile
    
    -- Console functions
    env.rconsolecreate = Executor.rconsolecreate
    env.rconsoleopen = Executor.rconsoleopen
    env.rconsoleprint = Executor.rconsoleprint
    env.rconsoleinfo = Executor.rconsoleinfo
    env.rconsolewarn = Executor.rconsolewarn
    env.rconsoleerr = Executor.rconsoleerr
    env.rconsoleclear = Executor.rconsoleclear
    env.rconsoletitle = Executor.rconsoletitle
    env.rconsoledestroy = Executor.rconsoledestroy
    env.rconsoleclose = Executor.rconsoleclose
    env.rconsoleinput = Executor.rconsoleinput
    env.rconsolename = Executor.rconsolename
    
    -- Clipboard
    env.setclipboard = Executor.setclipboard
    env.toclipboard = Executor.toclipboard
    env.getclipboard = Executor.getclipboard
    
    -- HTTP
    env.request = Executor.request
    env.http_request = Executor.http_request
    env.httpget = Executor.httpget
    env.httppost = Executor.httppost
    
    -- Misc
    env.identifyexecutor = Executor.identifyexecutor
    env.getexecutorname = Executor.getexecutorname
    env.gethwid = Executor.gethwid
    env.gethardwareid = Executor.gethardwareid
    env.queue_on_teleport = Executor.queue_on_teleport
    env.queueonteleport = Executor.queueonteleport
    env.checkcaller = Executor.checkcaller
    env.setthreadidentity = Executor.setthreadidentity
    env.getthreadidentity = Executor.getthreadidentity
    env.setidentity = Executor.setidentity
    env.getidentity = Executor.getidentity
    env.loadstring = Executor.loadstring
    env.checkclosure = Executor.checkclosure
    env.compareinstances = Executor.compareinstances
    env.cloneref = Executor.cloneref
    env.gethiddenproperty = Executor.gethiddenproperty
    env.sethiddenproperty = Executor.sethiddenproperty
    env.fireclickdetector = Executor.fireclickdetector
    env.fireproximityprompt = Executor.fireproximityprompt
    env.firetouchinterest = Executor.firetouchinterest
    env.firesignal = Executor.firesignal
    env.decompile = Executor.decompile
    env.saveinstance = Executor.saveinstance
    env.Drawing = Executor.Drawing
    
    return env
end

-- ============================================================================
-- Run Script Helper
-- ============================================================================

--- Runs a script string in the Aurora environment
function Aurora.run(scriptContent, scriptName)
    local env = Aurora.setup({})
    setmetatable(env, {__index = _G})
    
    local fn, err = load(scriptContent, scriptName or "AuroraScript", "t", env)
    if not fn then
        error("Script compilation error: " .. tostring(err))
    end
    
    return fn()
end

--- Runs a script file in the Aurora environment
function Aurora.runFile(filePath)
    local file = io.open(filePath, "r")
    if not file then
        error("Could not open file: " .. filePath)
    end
    
    local content = file:read("*a")
    file:close()
    
    return Aurora.run(content, "@" .. filePath)
end

-- ============================================================================
-- Exports
-- ============================================================================

Aurora.Signal = Signal
Aurora.Instance = Instance
Aurora.DataTypes = DataTypes
Aurora.Services = Services
Aurora.Executor = Executor
Aurora.Task = Task
Aurora.Enum = Enum
Aurora.typeof = typeof
Aurora.game = game
Aurora.workspace = workspace

return Aurora

-- Aurora Instance System
-- Roblox Instance class emulation with full parent-child relationship handling

local Signal = require("signal")

-- ============================================================================
-- Instance Class Registry (for IsA checks)
-- ============================================================================
local classHierarchy = {
    Instance = {},
    
    -- Core classes
    DataModel = {"Instance"},
    Workspace = {"Instance"},
    ServiceProvider = {"Instance"},
    
    -- Services
    CoreGui = {"Instance"},
    Players = {"Instance"},
    ReplicatedStorage = {"Instance"},
    UserInputService = {"Instance"},
    RunService = {"Instance"},
    HttpService = {"Instance"},
    TweenService = {"Instance"},
    Debris = {"Instance"},
    Lighting = {"Instance"},
    SoundService = {"Instance"},
    StarterGui = {"Instance"},
    StarterPack = {"Instance"},
    StarterPlayer = {"Instance"},
    Teams = {"Instance"},
    Chat = {"Instance"},
    
    -- Player related
    Player = {"Instance"},
    Humanoid = {"Instance"},
    Character = {"Model"},
    Backpack = {"Instance"},
    PlayerGui = {"Instance"},
    PlayerScripts = {"Instance"},
    
    -- Base parts
    BasePart = {"Instance"},
    Part = {"BasePart", "Instance"},
    MeshPart = {"BasePart", "Instance"},
    WedgePart = {"BasePart", "Instance"},
    CornerWedgePart = {"BasePart", "Instance"},
    TrussPart = {"BasePart", "Instance"},
    SpawnLocation = {"BasePart", "Instance"},
    Seat = {"BasePart", "Instance"},
    VehicleSeat = {"BasePart", "Instance"},
    SkateboardPlatform = {"BasePart", "Instance"},
    Terrain = {"BasePart", "Instance"},
    UnionOperation = {"BasePart", "Instance"},
    NegateOperation = {"BasePart", "Instance"},
    
    -- GUI
    GuiBase = {"Instance"},
    GuiObject = {"GuiBase", "Instance"},
    Frame = {"GuiObject", "GuiBase", "Instance"},
    TextLabel = {"GuiObject", "GuiBase", "Instance"},
    TextButton = {"GuiObject", "GuiBase", "Instance"},
    TextBox = {"GuiObject", "GuiBase", "Instance"},
    ImageLabel = {"GuiObject", "GuiBase", "Instance"},
    ImageButton = {"GuiObject", "GuiBase", "Instance"},
    ViewportFrame = {"GuiObject", "GuiBase", "Instance"},
    ScrollingFrame = {"GuiObject", "GuiBase", "Instance"},
    CanvasGroup = {"GuiObject", "GuiBase", "Instance"},
    BillboardGui = {"GuiBase", "Instance"},
    SurfaceGui = {"GuiBase", "Instance"},
    ScreenGui = {"GuiBase", "Instance"},
    UIBase = {"Instance"},
    UIComponent = {"UIBase", "Instance"},
    UILayout = {"UIComponent", "UIBase", "Instance"},
    UIListLayout = {"UILayout", "UIComponent", "UIBase", "Instance"},
    UIGridLayout = {"UILayout", "UIComponent", "UIBase", "Instance"},
    UIPageLayout = {"UILayout", "UIComponent", "UIBase", "Instance"},
    UITableLayout = {"UILayout", "UIComponent", "UIBase", "Instance"},
    UIConstraint = {"UIComponent", "UIBase", "Instance"},
    UISizeConstraint = {"UIConstraint", "UIComponent", "UIBase", "Instance"},
    UITextSizeConstraint = {"UIConstraint", "UIComponent", "UIBase", "Instance"},
    UIAspectRatioConstraint = {"UIConstraint", "UIComponent", "UIBase", "Instance"},
    UICorner = {"UIComponent", "UIBase", "Instance"},
    UIGradient = {"UIComponent", "UIBase", "Instance"},
    UIPadding = {"UIComponent", "UIBase", "Instance"},
    UIScale = {"UIComponent", "UIBase", "Instance"},
    UIStroke = {"UIComponent", "UIBase", "Instance"},
    
    -- 3D Objects
    Model = {"Instance"},
    Folder = {"Instance"},
    Camera = {"Instance"},
    Attachment = {"Instance"},
    Bone = {"Attachment", "Instance"},
    
    -- Physics
    BodyMover = {"Instance"},
    BodyPosition = {"BodyMover", "Instance"},
    BodyVelocity = {"BodyMover", "Instance"},
    BodyForce = {"BodyMover", "Instance"},
    BodyGyro = {"BodyMover", "Instance"},
    BodyAngularVelocity = {"BodyMover", "Instance"},
    RocketPropulsion = {"BodyMover", "Instance"},
    Constraint = {"Instance"},
    BallSocketConstraint = {"Constraint", "Instance"},
    HingeConstraint = {"Constraint", "Instance"},
    PrismaticConstraint = {"Constraint", "Instance"},
    RopeConstraint = {"Constraint", "Instance"},
    SpringConstraint = {"Constraint", "Instance"},
    WeldConstraint = {"Constraint", "Instance"},
    Weld = {"Instance"},
    Motor = {"Instance"},
    Motor6D = {"Motor", "Instance"},
    
    -- Visual effects
    Decal = {"Instance"},
    Texture = {"Decal", "Instance"},
    Highlight = {"Instance"},
    Beam = {"Instance"},
    Trail = {"Instance"},
    ParticleEmitter = {"Instance"},
    Fire = {"Instance"},
    Smoke = {"Instance"},
    Sparkles = {"Instance"},
    Explosion = {"Instance"},
    PointLight = {"Instance"},
    SpotLight = {"Instance"},
    SurfaceLight = {"Instance"},
    
    -- Audio
    Sound = {"Instance"},
    SoundGroup = {"Instance"},
    
    -- Animation
    Animation = {"Instance"},
    AnimationTrack = {"Instance"},
    Animator = {"Instance"},
    
    -- Scripting
    Script = {"Instance"},
    LocalScript = {"Script", "Instance"},
    ModuleScript = {"Instance"},
    
    -- Values
    ValueBase = {"Instance"},
    BoolValue = {"ValueBase", "Instance"},
    IntValue = {"ValueBase", "Instance"},
    NumberValue = {"ValueBase", "Instance"},
    StringValue = {"ValueBase", "Instance"},
    ObjectValue = {"ValueBase", "Instance"},
    CFrameValue = {"ValueBase", "Instance"},
    Vector3Value = {"ValueBase", "Instance"},
    Color3Value = {"ValueBase", "Instance"},
    BrickColorValue = {"ValueBase", "Instance"},
    RayValue = {"ValueBase", "Instance"},
    
    -- Remote
    RemoteEvent = {"Instance"},
    RemoteFunction = {"Instance"},
    BindableEvent = {"Instance"},
    BindableFunction = {"Instance"},
    
    -- Tools
    Tool = {"Instance"},
    HopperBin = {"Instance"},
    
    -- Other
    ClickDetector = {"Instance"},
    ProximityPrompt = {"Instance"},
    Dialog = {"Instance"},
    DialogChoice = {"Instance"},
    TouchTransmitter = {"Instance"},
    ForceField = {"Instance"},
    SelectionBox = {"Instance"},
    SelectionSphere = {"Instance"},
    ArcHandles = {"Instance"},
    Handles = {"Instance"},
    SurfaceSelection = {"Instance"},
}

--- Checks if a class inherits from another
---@param className string The class to check
---@param ancestorName string The ancestor class name
---@return boolean
local function classIsA(className, ancestorName)
    if className == ancestorName then
        return true
    end
    
    local parents = classHierarchy[className]
    if not parents then
        return false
    end
    
    for _, parent in ipairs(parents) do
        if parent == ancestorName then
            return true
        end
    end
    
    return false
end

-- ============================================================================
-- Instance Class
-- ============================================================================
local Instance = {}
Instance.__index = function(self, key)
    -- Check for properties first
    local rawValue = rawget(self, key)
    if rawValue ~= nil then
        return rawValue
    end
    
    -- Check metatable methods
    local mtValue = rawget(Instance, key)
    if mtValue ~= nil then
        return mtValue
    end
    
    -- Try to find child by name
    local children = rawget(self, "_children")
    if children then
        for _, child in ipairs(children) do
            if child.Name == key then
                return child
            end
        end
    end
    
    return nil
end

Instance.__newindex = function(self, key, value)
    if key == "Parent" then
        local oldParent = rawget(self, "_parent")
        
        -- Remove from old parent
        if oldParent then
            local oldChildren = rawget(oldParent, "_children")
            if oldChildren then
                for i = #oldChildren, 1, -1 do
                    if oldChildren[i] == self then
                        table.remove(oldChildren, i)
                        break
                    end
                end
            end
            -- Fire ChildRemoved on old parent
            local childRemoved = rawget(oldParent, "ChildRemoved")
            if childRemoved then
                childRemoved:Fire(self)
            end
        end
        
        -- Set new parent
        rawset(self, "_parent", value)
        
        -- Add to new parent
        if value then
            local newChildren = rawget(value, "_children")
            if not newChildren then
                newChildren = {}
                rawset(value, "_children", newChildren)
            end
            table.insert(newChildren, self)
            
            -- Fire ChildAdded on new parent
            local childAdded = rawget(value, "ChildAdded")
            if childAdded then
                childAdded:Fire(self)
            end
        end
        
        -- Fire AncestryChanged
        local ancestryChanged = rawget(self, "AncestryChanged")
        if ancestryChanged then
            ancestryChanged:Fire(self, value)
        end
    else
        rawset(self, key, value)
        
        -- Fire Changed event if it exists
        local changed = rawget(self, "Changed")
        if changed and key ~= "_children" and key ~= "_parent" and key ~= "_attributes" then
            changed:Fire(key)
        end
    end
end

Instance.__tostring = function(self)
    return self.Name or self.ClassName
end

--- Creates a new Instance
---@param className string The class name of the instance
---@param parent table Optional parent instance
---@return table Instance object
function Instance.new(className, parent)
    local self = setmetatable({}, Instance)
    
    -- Core properties
    self.ClassName = className or "Instance"
    self.Name = className or "Instance"
    self._children = {}
    self._parent = nil
    self._attributes = {}
    self.Archivable = true
    
    -- Signals
    self.Changed = Signal.new()
    self.ChildAdded = Signal.new()
    self.ChildRemoved = Signal.new()
    self.AncestryChanged = Signal.new()
    self.Destroying = Signal.new()
    self.AttributeChanged = Signal.new()
    
    -- Class-specific properties
    if className == "Part" or className == "MeshPart" or className == "WedgePart" or 
       className == "SpawnLocation" or className == "Seat" or className == "VehicleSeat" or
       className == "UnionOperation" or classIsA(className, "BasePart") then
        self.Position = {X = 0, Y = 0, Z = 0}
        self.CFrame = {X = 0, Y = 0, Z = 0}
        self.Size = {X = 4, Y = 1, Z = 2}
        self.Anchored = false
        self.CanCollide = true
        self.Transparency = 0
        self.BrickColor = nil
        self.Color = nil
        self.Material = "Plastic"
        self.Reflectance = 0
        self.CanQuery = true
        self.CanTouch = true
        self.Massless = false
        self.Locked = false
        
        self.Touched = Signal.new()
        self.TouchEnded = Signal.new()
    end
    
    if className == "Model" or className == "Folder" then
        self.PrimaryPart = nil
    end
    
    if className == "Player" then
        self.UserId = 0
        self.DisplayName = ""
        self.Character = nil
        self.Team = nil
        self.TeamColor = nil
        self.Backpack = nil
        self.PlayerGui = nil
        self.PlayerScripts = nil
        self.CharacterAdded = Signal.new()
        self.CharacterRemoving = Signal.new()
        self.Chatted = Signal.new()
    end
    
    if className == "Humanoid" then
        self.Health = 100
        self.MaxHealth = 100
        self.WalkSpeed = 16
        self.JumpPower = 50
        self.JumpHeight = 7.2
        self.HipHeight = 2
        self.Died = Signal.new()
        self.Running = Signal.new()
        self.Jumping = Signal.new()
        self.HealthChanged = Signal.new()
    end
    
    if className == "Camera" then
        self.CameraType = "Custom"
        self.CameraSubject = nil
        self.FieldOfView = 70
        self.ViewportSize = {X = 1920, Y = 1080}
        self.Focus = {X = 0, Y = 0, Z = 0}
    end
    
    if className == "Highlight" then
        self.Adornee = nil
        self.FillColor = nil
        self.OutlineColor = nil
        self.FillTransparency = 0.5
        self.OutlineTransparency = 0
        self.DepthMode = "AlwaysOnTop"
        self.Enabled = true
    end
    
    if className == "RemoteEvent" then
        self.OnServerEvent = Signal.new()
        self.OnClientEvent = Signal.new()
    end
    
    if className == "RemoteFunction" then
        self.OnServerInvoke = nil
        self.OnClientInvoke = nil
    end
    
    if className == "BindableEvent" then
        self.Event = Signal.new()
    end
    
    if className == "BindableFunction" then
        self.OnInvoke = nil
    end
    
    if className == "ScreenGui" or className == "BillboardGui" or className == "SurfaceGui" then
        self.Enabled = true
        self.ResetOnSpawn = true
        self.ZIndexBehavior = "Sibling"
        self.DisplayOrder = 0
        self.IgnoreGuiInset = false
    end
    
    if classIsA(className, "GuiObject") then
        self.Position = nil
        self.Size = nil
        self.AnchorPoint = {X = 0, Y = 0}
        self.BackgroundColor3 = nil
        self.BackgroundTransparency = 0
        self.BorderColor3 = nil
        self.BorderSizePixel = 1
        self.Visible = true
        self.ZIndex = 1
        self.LayoutOrder = 0
        self.Active = false
        self.ClipsDescendants = false
        self.Rotation = 0
        
        self.MouseEnter = Signal.new()
        self.MouseLeave = Signal.new()
        self.MouseButton1Click = Signal.new()
        self.MouseButton1Down = Signal.new()
        self.MouseButton1Up = Signal.new()
        self.MouseButton2Click = Signal.new()
        self.MouseButton2Down = Signal.new()
        self.MouseButton2Up = Signal.new()
        self.InputBegan = Signal.new()
        self.InputEnded = Signal.new()
        self.InputChanged = Signal.new()
    end
    
    if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
        self.Text = ""
        self.TextColor3 = nil
        self.TextSize = 14
        self.Font = "SourceSans"
        self.TextXAlignment = "Center"
        self.TextYAlignment = "Center"
        self.TextWrapped = false
        self.TextScaled = false
        self.RichText = false
        self.TextTransparency = 0
        self.TextStrokeColor3 = nil
        self.TextStrokeTransparency = 1
        self.MaxVisibleGraphemes = -1
    end
    
    if className == "TextBox" then
        self.PlaceholderText = ""
        self.PlaceholderColor3 = nil
        self.ClearTextOnFocus = true
        self.MultiLine = false
        self.FocusLost = Signal.new()
        self.Focused = Signal.new()
    end
    
    if className == "ImageLabel" or className == "ImageButton" then
        self.Image = ""
        self.ImageColor3 = nil
        self.ImageTransparency = 0
        self.ScaleType = "Stretch"
        self.SliceCenter = nil
        self.TileSize = nil
    end
    
    if className == "Sound" then
        self.SoundId = ""
        self.Volume = 0.5
        self.Pitch = 1
        self.PlaybackSpeed = 1
        self.Playing = false
        self.Looped = false
        self.TimePosition = 0
        self.TimeLength = 0
        self.IsPlaying = false
        self.Ended = Signal.new()
        self.Played = Signal.new()
        self.Paused = Signal.new()
        self.Resumed = Signal.new()
        self.Stopped = Signal.new()
    end
    
    if className == "UIListLayout" or className == "UIGridLayout" then
        self.FillDirection = "Vertical"
        self.HorizontalAlignment = "Left"
        self.VerticalAlignment = "Top"
        self.SortOrder = "LayoutOrder"
        self.Padding = nil
    end
    
    if className == "UIGridLayout" then
        self.CellSize = nil
        self.CellPadding = nil
        self.FillDirectionMaxCells = 0
        self.StartCorner = "TopLeft"
    end
    
    if className == "UICorner" then
        self.CornerRadius = nil
    end
    
    if className == "UIPadding" then
        self.PaddingTop = nil
        self.PaddingBottom = nil
        self.PaddingLeft = nil
        self.PaddingRight = nil
    end
    
    if className == "UIStroke" then
        self.Color = nil
        self.Thickness = 1
        self.Transparency = 0
        self.ApplyStrokeMode = "Contextual"
        self.LineJoinMode = "Round"
    end
    
    if className == "UIGradient" then
        self.Color = nil
        self.Transparency = nil
        self.Offset = {X = 0, Y = 0}
        self.Rotation = 0
        self.Enabled = true
    end
    
    -- Set parent after initialization
    if parent then
        self.Parent = parent
    end
    
    return self
end

-- ============================================================================
-- Instance Methods
-- ============================================================================

--- Gets the parent of the instance
---@return table|nil
function Instance:GetParent()
    return self._parent
end

-- Parent property getter (for direct access)
rawset(Instance, "Parent", nil)

--- Gets all children of the instance
---@return table Array of child instances
function Instance:GetChildren()
    return self._children or {}
end

--- Gets all descendants of the instance recursively
---@return table Array of all descendant instances
function Instance:GetDescendants()
    local descendants = {}
    
    local function collect(parent)
        for _, child in ipairs(parent._children or {}) do
            table.insert(descendants, child)
            collect(child)
        end
    end
    
    collect(self)
    return descendants
end

--- Finds the first child with the given name
---@param name string The name to search for
---@param recursive boolean Optional: search recursively
---@return table|nil
function Instance:FindFirstChild(name, recursive)
    for _, child in ipairs(self._children or {}) do
        if child.Name == name then
            return child
        end
    end
    
    if recursive then
        for _, child in ipairs(self._children or {}) do
            local found = child:FindFirstChild(name, true)
            if found then
                return found
            end
        end
    end
    
    return nil
end

--- Finds the first child of the given class
---@param className string The class name to search for
---@return table|nil
function Instance:FindFirstChildOfClass(className)
    for _, child in ipairs(self._children or {}) do
        if child.ClassName == className then
            return child
        end
    end
    return nil
end

--- Finds the first child that is a given class (including inheritance)
---@param className string The class name to check
---@return table|nil
function Instance:FindFirstChildWhichIsA(className)
    for _, child in ipairs(self._children or {}) do
        if child:IsA(className) then
            return child
        end
    end
    return nil
end

--- Finds the first ancestor with the given name
---@param name string The name to search for
---@return table|nil
function Instance:FindFirstAncestor(name)
    local parent = self._parent
    while parent do
        if parent.Name == name then
            return parent
        end
        parent = parent._parent
    end
    return nil
end

--- Finds the first ancestor of the given class
---@param className string The class name to search for
---@return table|nil
function Instance:FindFirstAncestorOfClass(className)
    local parent = self._parent
    while parent do
        if parent.ClassName == className then
            return parent
        end
        parent = parent._parent
    end
    return nil
end

--- Finds the first ancestor that is a given class (including inheritance)
---@param className string The class name to check
---@return table|nil
function Instance:FindFirstAncestorWhichIsA(className)
    local parent = self._parent
    while parent do
        if parent:IsA(className) then
            return parent
        end
        parent = parent._parent
    end
    return nil
end

--- Finds the first descendant with the given name
---@param name string The name to search for
---@return table|nil
function Instance:FindFirstDescendant(name)
    return self:FindFirstChild(name, true)
end

--- Waits for a child with the given name
---@param name string The name to wait for
---@param timeout number Optional timeout in seconds
---@return table|nil
function Instance:WaitForChild(name, timeout)
    -- First check if child already exists
    local child = self:FindFirstChild(name)
    if child then
        return child
    end
    
    -- In emulator, we can't truly wait, so just return nil after "timeout"
    -- In real usage, this would yield
    if timeout then
        return nil
    end
    
    -- Without timeout, we'd wait indefinitely - just return nil in emulator
    return nil
end

--- Checks if instance is of a given class or inherits from it
---@param className string The class name to check
---@return boolean
function Instance:IsA(className)
    return classIsA(self.ClassName, className)
end

--- Checks if instance is an ancestor of another instance
---@param descendant table The potential descendant
---@return boolean
function Instance:IsAncestorOf(descendant)
    local parent = descendant._parent
    while parent do
        if parent == self then
            return true
        end
        parent = parent._parent
    end
    return false
end

--- Checks if instance is a descendant of another instance
---@param ancestor table The potential ancestor
---@return boolean
function Instance:IsDescendantOf(ancestor)
    return ancestor:IsAncestorOf(self)
end

--- Gets the full path name of the instance
---@return string
function Instance:GetFullName()
    local parts = {self.Name}
    local parent = self._parent
    
    while parent do
        table.insert(parts, 1, parent.Name)
        parent = parent._parent
    end
    
    return table.concat(parts, ".")
end

--- Gets an attribute value
---@param name string The attribute name
---@return any
function Instance:GetAttribute(name)
    return self._attributes[name]
end

--- Sets an attribute value
---@param name string The attribute name
---@param value any The value to set
function Instance:SetAttribute(name, value)
    local oldValue = self._attributes[name]
    self._attributes[name] = value
    
    if oldValue ~= value then
        self.AttributeChanged:Fire(name)
    end
end

--- Gets all attributes
---@return table Dictionary of attribute names to values
function Instance:GetAttributes()
    local copy = {}
    for k, v in pairs(self._attributes) do
        copy[k] = v
    end
    return copy
end

--- Clears all children
function Instance:ClearAllChildren()
    for i = #self._children, 1, -1 do
        self._children[i]:Destroy()
    end
    self._children = {}
end

--- Destroys the instance
function Instance:Destroy()
    self.Destroying:Fire()
    
    -- Destroy all children first
    for i = #(self._children or {}), 1, -1 do
        self._children[i]:Destroy()
    end
    
    -- Remove from parent
    self.Parent = nil
    
    -- Disconnect all signals
    if self.Changed then self.Changed:Destroy() end
    if self.ChildAdded then self.ChildAdded:Destroy() end
    if self.ChildRemoved then self.ChildRemoved:Destroy() end
    if self.AncestryChanged then self.AncestryChanged:Destroy() end
    if self.Destroying then self.Destroying:Destroy() end
    if self.AttributeChanged then self.AttributeChanged:Destroy() end
    
    -- Clear metatable
    setmetatable(self, nil)
end

--- Clones the instance
---@return table New cloned instance
function Instance:Clone()
    if not self.Archivable then
        return nil
    end
    
    local clone = Instance.new(self.ClassName)
    
    -- Copy properties
    for key, value in pairs(self) do
        if key ~= "_children" and key ~= "_parent" and key ~= "ClassName" and
           not (type(value) == "table" and value.Connect) then -- Skip signals
            if type(value) == "table" then
                -- Shallow copy tables
                local copy = {}
                for k, v in pairs(value) do
                    copy[k] = v
                end
                rawset(clone, key, copy)
            else
                rawset(clone, key, value)
            end
        end
    end
    
    -- Clone children
    for _, child in ipairs(self._children or {}) do
        local childClone = child:Clone()
        if childClone then
            childClone.Parent = clone
        end
    end
    
    return clone
end

-- ============================================================================
-- Instance-specific methods
-- ============================================================================

--- RemoteEvent:FireServer (client to server)
function Instance:FireServer(...)
    if self.ClassName == "RemoteEvent" then
        self.OnServerEvent:Fire(...)
    end
end

--- RemoteEvent:FireClient (server to client)
function Instance:FireClient(player, ...)
    if self.ClassName == "RemoteEvent" then
        self.OnClientEvent:Fire(...)
    end
end

--- RemoteEvent:FireAllClients (server to all clients)
function Instance:FireAllClients(...)
    if self.ClassName == "RemoteEvent" then
        self.OnClientEvent:Fire(...)
    end
end

--- RemoteFunction:InvokeServer
function Instance:InvokeServer(...)
    if self.ClassName == "RemoteFunction" and self.OnServerInvoke then
        return self.OnServerInvoke(...)
    end
    return nil
end

--- RemoteFunction:InvokeClient
function Instance:InvokeClient(player, ...)
    if self.ClassName == "RemoteFunction" and self.OnClientInvoke then
        return self.OnClientInvoke(...)
    end
    return nil
end

--- BindableEvent:Fire
function Instance:Fire(...)
    if self.ClassName == "BindableEvent" then
        self.Event:Fire(...)
    end
end

--- BindableFunction:Invoke
function Instance:Invoke(...)
    if self.ClassName == "BindableFunction" and self.OnInvoke then
        return self.OnInvoke(...)
    end
    return nil
end

--- Sound:Play
function Instance:Play()
    if self.ClassName == "Sound" then
        self.Playing = true
        self.IsPlaying = true
        self.Played:Fire()
    end
end

--- Sound:Stop
function Instance:Stop()
    if self.ClassName == "Sound" then
        self.Playing = false
        self.IsPlaying = false
        self.TimePosition = 0
        self.Stopped:Fire()
    end
end

--- Sound:Pause
function Instance:Pause()
    if self.ClassName == "Sound" then
        self.Playing = false
        self.IsPlaying = false
        self.Paused:Fire()
    end
end

--- Sound:Resume
function Instance:Resume()
    if self.ClassName == "Sound" then
        self.Playing = true
        self.IsPlaying = true
        self.Resumed:Fire()
    end
end

--- Humanoid:TakeDamage
function Instance:TakeDamage(amount)
    if self.ClassName == "Humanoid" then
        self.Health = math.max(0, self.Health - amount)
        self.HealthChanged:Fire(self.Health)
        if self.Health <= 0 then
            self.Died:Fire()
        end
    end
end

--- Model:GetPrimaryPartCFrame / Model:SetPrimaryPartCFrame
function Instance:GetPrimaryPartCFrame()
    if self.ClassName == "Model" and self.PrimaryPart then
        return self.PrimaryPart.CFrame
    end
    return nil
end

function Instance:SetPrimaryPartCFrame(cframe)
    if self.ClassName == "Model" and self.PrimaryPart then
        self.PrimaryPart.CFrame = cframe
    end
end

--- Model:MoveTo
function Instance:MoveTo(position)
    if self.ClassName == "Model" and self.PrimaryPart then
        self.PrimaryPart.Position = position
    elseif classIsA(self.ClassName, "BasePart") then
        self.Position = position
    end
end

--- Model:GetBoundingBox
function Instance:GetBoundingBox()
    -- Simplified bounding box
    return {X = 0, Y = 0, Z = 0}, {X = 4, Y = 4, Z = 4}
end

--- Model:GetExtentsSize  
function Instance:GetExtentsSize()
    return {X = 4, Y = 4, Z = 4}
end

--- Model:PivotTo
function Instance:PivotTo(cframe)
    if self.ClassName == "Model" then
        self:SetPrimaryPartCFrame(cframe)
    elseif classIsA(self.ClassName, "BasePart") then
        self.CFrame = cframe
    end
end

--- Model:GetPivot
function Instance:GetPivot()
    if self.ClassName == "Model" then
        return self:GetPrimaryPartCFrame()
    elseif classIsA(self.ClassName, "BasePart") then
        return self.CFrame
    end
    return nil
end

return {
    Instance = Instance,
    classIsA = classIsA,
    classHierarchy = classHierarchy,
}

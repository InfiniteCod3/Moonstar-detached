-- Aurora Enum System
-- Roblox Enum emulation

local Enum = {}

-- Helper to create enum items
local function createEnumItem(enumType, name, value)
    return {
        Name = name,
        Value = value,
        EnumType = enumType,
    }
end

-- Helper to create an enum type
local function createEnumType(name, items)
    local enumType = {
        _name = name,
        _items = {}
    }
    
    for itemName, value in pairs(items) do
        local item = createEnumItem(name, itemName, value)
        enumType[itemName] = item
        enumType._items[itemName] = item
    end
    
    function enumType:GetEnumItems()
        local result = {}
        for _, item in pairs(self._items) do
            table.insert(result, item)
        end
        return result
    end
    
    return enumType
end

-- ============================================================================
-- Input Enums
-- ============================================================================

Enum.KeyCode = createEnumType("KeyCode", {
    Unknown = 0,
    Backspace = 8,
    Tab = 9,
    Clear = 12,
    Return = 13,
    Pause = 19,
    Escape = 27,
    Space = 32,
    QuotedDouble = 34,
    Hash = 35,
    Dollar = 36,
    Percent = 37,
    Ampersand = 38,
    Quote = 39,
    LeftParenthesis = 40,
    RightParenthesis = 41,
    Asterisk = 42,
    Plus = 43,
    Comma = 44,
    Minus = 45,
    Period = 46,
    Slash = 47,
    Zero = 48,
    One = 49,
    Two = 50,
    Three = 51,
    Four = 52,
    Five = 53,
    Six = 54,
    Seven = 55,
    Eight = 56,
    Nine = 57,
    Colon = 58,
    Semicolon = 59,
    LessThan = 60,
    Equals = 61,
    GreaterThan = 62,
    Question = 63,
    At = 64,
    LeftBracket = 91,
    BackSlash = 92,
    RightBracket = 93,
    Caret = 94,
    Underscore = 95,
    Backquote = 96,
    A = 97,
    B = 98,
    C = 99,
    D = 100,
    E = 101,
    F = 102,
    G = 103,
    H = 104,
    I = 105,
    J = 106,
    K = 107,
    L = 108,
    M = 109,
    N = 110,
    O = 111,
    P = 112,
    Q = 113,
    R = 114,
    S = 115,
    T = 116,
    U = 117,
    V = 118,
    W = 119,
    X = 120,
    Y = 121,
    Z = 122,
    LeftCurly = 123,
    Pipe = 124,
    RightCurly = 125,
    Tilde = 126,
    Delete = 127,
    KeypadZero = 256,
    KeypadOne = 257,
    KeypadTwo = 258,
    KeypadThree = 259,
    KeypadFour = 260,
    KeypadFive = 261,
    KeypadSix = 262,
    KeypadSeven = 263,
    KeypadEight = 264,
    KeypadNine = 265,
    KeypadPeriod = 266,
    KeypadDivide = 267,
    KeypadMultiply = 268,
    KeypadMinus = 269,
    KeypadPlus = 270,
    KeypadEnter = 271,
    KeypadEquals = 272,
    Up = 273,
    Down = 274,
    Right = 275,
    Left = 276,
    Insert = 277,
    Home = 278,
    End = 279,
    PageUp = 280,
    PageDown = 281,
    F1 = 282,
    F2 = 283,
    F3 = 284,
    F4 = 285,
    F5 = 286,
    F6 = 287,
    F7 = 288,
    F8 = 289,
    F9 = 290,
    F10 = 291,
    F11 = 292,
    F12 = 293,
    F13 = 294,
    F14 = 295,
    F15 = 296,
    NumLock = 300,
    CapsLock = 301,
    ScrollLock = 302,
    RightShift = 303,
    LeftShift = 304,
    RightControl = 305,
    LeftControl = 306,
    RightAlt = 307,
    LeftAlt = 308,
    RightMeta = 309,
    LeftMeta = 310,
    LeftSuper = 311,
    RightSuper = 312,
    Mode = 313,
    Compose = 314,
    Help = 315,
    Print = 316,
    SysReq = 317,
    Break = 318,
    Menu = 319,
    Power = 320,
    Euro = 321,
    Undo = 322,
    ButtonX = 1000,
    ButtonY = 1001,
    ButtonA = 1002,
    ButtonB = 1003,
    ButtonR1 = 1004,
    ButtonL1 = 1005,
    ButtonR2 = 1006,
    ButtonL2 = 1007,
    ButtonR3 = 1008,
    ButtonL3 = 1009,
    ButtonStart = 1010,
    ButtonSelect = 1011,
    DPadLeft = 1012,
    DPadRight = 1013,
    DPadUp = 1014,
    DPadDown = 1015,
    Thumbstick1 = 1016,
    Thumbstick2 = 1017,
})

Enum.UserInputType = createEnumType("UserInputType", {
    MouseButton1 = 0,
    MouseButton2 = 1,
    MouseButton3 = 2,
    MouseWheel = 3,
    MouseMovement = 4,
    Touch = 7,
    Keyboard = 8,
    Focus = 9,
    Accelerometer = 10,
    Gyro = 11,
    Gamepad1 = 12,
    Gamepad2 = 13,
    Gamepad3 = 14,
    Gamepad4 = 15,
    Gamepad5 = 16,
    Gamepad6 = 17,
    Gamepad7 = 18,
    Gamepad8 = 19,
    TextInput = 20,
    InputMethod = 21,
    None = 22,
})

Enum.UserInputState = createEnumType("UserInputState", {
    Begin = 0,
    Change = 1,
    End = 2,
    Cancel = 3,
    None = 4,
})

-- ============================================================================
-- GUI Enums
-- ============================================================================

Enum.Font = createEnumType("Font", {
    Legacy = 0,
    Arial = 1,
    ArialBold = 2,
    SourceSans = 3,
    SourceSansBold = 4,
    SourceSansSemibold = 16,
    SourceSansLight = 5,
    SourceSansItalic = 6,
    Bodoni = 7,
    Garamond = 8,
    Cartoon = 9,
    Code = 10,
    Highway = 11,
    SciFi = 12,
    Arcade = 13,
    Fantasy = 14,
    Antique = 15,
    Gotham = 17,
    GothamMedium = 18,
    GothamBold = 19,
    GothamBlack = 20,
    AmaticSC = 21,
    Bangers = 22,
    Creepster = 23,
    DenkOne = 24,
    Fondamento = 25,
    FredokaOne = 26,
    GrenzeGotisch = 27,
    IndieFlower = 28,
    JosefinSans = 29,
    Jura = 30,
    Kalam = 31,
    LuckiestGuy = 32,
    Merriweather = 33,
    Michroma = 34,
    Nunito = 35,
    Oswald = 36,
    PatrickHand = 37,
    PermanentMarker = 38,
    Roboto = 39,
    RobotoCondensed = 40,
    RobotoMono = 41,
    Sarpanch = 42,
    SpecialElite = 43,
    TitilliumWeb = 44,
    Ubuntu = 45,
    BuilderSans = 46,
    BuilderSansMedium = 47,
    BuilderSansBold = 48,
    BuilderSansExtraBold = 49,
})

Enum.TextXAlignment = createEnumType("TextXAlignment", {
    Left = 0,
    Center = 1,
    Right = 2,
})

Enum.TextYAlignment = createEnumType("TextYAlignment", {
    Top = 0,
    Center = 1,
    Bottom = 2,
})

Enum.HorizontalAlignment = createEnumType("HorizontalAlignment", {
    Center = 0,
    Left = 1,
    Right = 2,
})

Enum.VerticalAlignment = createEnumType("VerticalAlignment", {
    Center = 0,
    Top = 1,
    Bottom = 2,
})

Enum.FillDirection = createEnumType("FillDirection", {
    Horizontal = 0,
    Vertical = 1,
})

Enum.SortOrder = createEnumType("SortOrder", {
    LayoutOrder = 0,
    Name = 1,
    Custom = 2,
})

Enum.ZIndexBehavior = createEnumType("ZIndexBehavior", {
    Global = 0,
    Sibling = 1,
})

Enum.ScaleType = createEnumType("ScaleType", {
    Stretch = 0,
    Slice = 1,
    Tile = 2,
    Fit = 3,
    Crop = 4,
})

Enum.ScrollingDirection = createEnumType("ScrollingDirection", {
    X = 0,
    Y = 1,
    XY = 2,
})

Enum.AutomaticSize = createEnumType("AutomaticSize", {
    None = 0,
    X = 1,
    Y = 2,
    XY = 3,
})

-- ============================================================================
-- Part/Physics Enums
-- ============================================================================

Enum.Material = createEnumType("Material", {
    Plastic = 256,
    SmoothPlastic = 272,
    Neon = 288,
    Wood = 512,
    WoodPlanks = 528,
    Marble = 784,
    Slate = 800,
    Concrete = 816,
    Granite = 832,
    Brick = 848,
    Pebble = 864,
    Cobblestone = 880,
    Rock = 896,
    Sandstone = 912,
    Basalt = 788,
    CrackedLava = 804,
    Limestone = 820,
    Pavement = 836,
    CorrodedMetal = 1040,
    DiamondPlate = 1056,
    Foil = 1072,
    Metal = 1088,
    Grass = 1280,
    LeafyGrass = 1284,
    Sand = 1296,
    Fabric = 1312,
    Snow = 1328,
    Mud = 1344,
    Ground = 1360,
    Asphalt = 1376,
    Salt = 1392,
    Ice = 1536,
    Glacier = 1552,
    Glass = 1568,
    ForceField = 1584,
    Air = 1792,
    Water = 2048,
    Cardboard = 2080,
    Carpet = 2096,
    CeramicTiles = 2112,
    ClayRoofTiles = 2128,
    RoofShingles = 2144,
    Leather = 2160,
    Plaster = 2176,
    Rubber = 2192,
})

Enum.PartType = createEnumType("PartType", {
    Ball = 0,
    Block = 1,
    Cylinder = 2,
    Wedge = 3,
    CornerWedge = 4,
})

Enum.SurfaceType = createEnumType("SurfaceType", {
    Smooth = 0,
    Glue = 1,
    Weld = 2,
    Studs = 3,
    Inlet = 4,
    Universal = 5,
    Hinge = 6,
    Motor = 7,
    SteppingMotor = 8,
    SmoothNoOutlines = 10,
})

Enum.NormalId = createEnumType("NormalId", {
    Top = 1,
    Bottom = 4,
    Back = 2,
    Front = 5,
    Right = 0,
    Left = 3,
})

-- ============================================================================
-- Tween Enums
-- ============================================================================

Enum.EasingStyle = createEnumType("EasingStyle", {
    Linear = 0,
    Sine = 1,
    Back = 2,
    Quad = 3,
    Quart = 4,
    Quint = 5,
    Bounce = 6,
    Elastic = 7,
    Exponential = 8,
    Circular = 9,
    Cubic = 10,
})

Enum.EasingDirection = createEnumType("EasingDirection", {
    In = 0,
    Out = 1,
    InOut = 2,
})

Enum.PlaybackState = createEnumType("PlaybackState", {
    Begin = 0,
    Delayed = 1,
    Playing = 2,
    Paused = 3,
    Completed = 4,
    Cancelled = 5,
})

-- ============================================================================
-- Camera Enums
-- ============================================================================

Enum.CameraType = createEnumType("CameraType", {
    Fixed = 0,
    Watch = 1,
    Attach = 2,
    Track = 3,
    Follow = 4,
    Custom = 5,
    Scriptable = 6,
    Orbital = 7,
})

Enum.CameraMode = createEnumType("CameraMode", {
    Classic = 0,
    LockFirstPerson = 1,
})

-- ============================================================================
-- Highlight Enums
-- ============================================================================

Enum.HighlightDepthMode = createEnumType("HighlightDepthMode", {
    AlwaysOnTop = 0,
    Occluded = 1,
})

-- ============================================================================
-- Raycast Enums
-- ============================================================================

Enum.RaycastFilterType = createEnumType("RaycastFilterType", {
    Exclude = 0,
    Include = 1,
})

-- ============================================================================
-- Humanoid Enums
-- ============================================================================

Enum.HumanoidStateType = createEnumType("HumanoidStateType", {
    FallingDown = 0,
    Running = 8,
    RunningNoPhysics = 10,
    Climbing = 12,
    StrafingNoPhysics = 11,
    Ragdoll = 1,
    GettingUp = 2,
    Jumping = 3,
    Landed = 7,
    Flying = 6,
    Freefall = 5,
    Seated = 13,
    PlatformStanding = 14,
    Dead = 15,
    Swimming = 4,
    Physics = 16,
    None = 18,
})

Enum.HumanoidRigType = createEnumType("HumanoidRigType", {
    R6 = 0,
    R15 = 1,
})

-- ============================================================================
-- Rendering Enums
-- ============================================================================

Enum.RenderPriority = createEnumType("RenderPriority", {
    First = 0,
    Input = 100,
    Camera = 200,
    Character = 300,
    Last = 2000,
})

-- ============================================================================
-- Sound Enums
-- ============================================================================

Enum.RollOffMode = createEnumType("RollOffMode", {
    Inverse = 0,
    Linear = 1,
    LinearSquare = 2,
    InverseTapered = 3,
})

-- ============================================================================
-- Context Action Enums
-- ============================================================================

Enum.ContextActionPriority = createEnumType("ContextActionPriority", {
    Low = 1000,
    Medium = 2000,
    Default = 2000,
    High = 3000,
})

Enum.ContextActionResult = createEnumType("ContextActionResult", {
    Sink = 0,
    Pass = 1,
})

-- ============================================================================
-- Product Enums
-- ============================================================================

Enum.ProductPurchaseDecision = createEnumType("ProductPurchaseDecision", {
    NotProcessedYet = 0,
    PurchaseGranted = 1,
})

-- ============================================================================
-- Misc Enums
-- ============================================================================

Enum.ThumbnailType = createEnumType("ThumbnailType", {
    HeadShot = 0,
    AvatarBust = 1,
    AvatarThumbnail = 2,
})

Enum.ThumbnailSize = createEnumType("ThumbnailSize", {
    Size48x48 = 0,
    Size60x60 = 1,
    Size100x100 = 2,
    Size150x150 = 3,
    Size180x180 = 4,
    Size352x352 = 5,
    Size420x420 = 6,
})

Enum.AvatarItemType = createEnumType("AvatarItemType", {
    Asset = 1,
    Bundle = 2,
})

Enum.AnimationPriority = createEnumType("AnimationPriority", {
    Idle = 0,
    Movement = 1,
    Action = 2,
    Action2 = 3,
    Action3 = 4,
    Action4 = 5,
    Core = 1000,
})

return Enum

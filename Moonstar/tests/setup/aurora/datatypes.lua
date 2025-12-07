-- Aurora Data Types
-- Roblox data type implementations

local typeofModule = require(script.Parent.typeof or "typeof")
local registerType = typeofModule.registerType

-- ============================================================================
-- Vector2
-- ============================================================================
local Vector2 = {}
Vector2.__index = Vector2
Vector2.__type = "Vector2"

function Vector2.new(x, y)
    local self = setmetatable({}, Vector2)
    self.X = x or 0
    self.Y = y or 0
    self.Magnitude = math.sqrt(self.X^2 + self.Y^2)
    self.Unit = nil -- Set lazily
    return self
end

Vector2.zero = Vector2.new(0, 0)
Vector2.one = Vector2.new(1, 1)
Vector2.xAxis = Vector2.new(1, 0)
Vector2.yAxis = Vector2.new(0, 1)

function Vector2:__add(other)
    return Vector2.new(self.X + other.X, self.Y + other.Y)
end

function Vector2:__sub(other)
    return Vector2.new(self.X - other.X, self.Y - other.Y)
end

function Vector2:__mul(other)
    if type(other) == "number" then
        return Vector2.new(self.X * other, self.Y * other)
    end
    return Vector2.new(self.X * other.X, self.Y * other.Y)
end

function Vector2:__div(other)
    if type(other) == "number" then
        return Vector2.new(self.X / other, self.Y / other)
    end
    return Vector2.new(self.X / other.X, self.Y / other.Y)
end

function Vector2:__unm()
    return Vector2.new(-self.X, -self.Y)
end

function Vector2:__eq(other)
    return self.X == other.X and self.Y == other.Y
end

function Vector2:__tostring()
    return string.format("%g, %g", self.X, self.Y)
end

function Vector2:Dot(other)
    return self.X * other.X + self.Y * other.Y
end

function Vector2:Cross(other)
    return self.X * other.Y - self.Y * other.X
end

function Vector2:Lerp(goal, alpha)
    return self + (goal - self) * alpha
end

registerType(Vector2, "Vector2")

-- ============================================================================
-- Vector3
-- ============================================================================
local Vector3 = {}
Vector3.__index = Vector3
Vector3.__type = "Vector3"

function Vector3.new(x, y, z)
    local self = setmetatable({}, Vector3)
    self.X = x or 0
    self.Y = y or 0
    self.Z = z or 0
    self.Magnitude = math.sqrt(self.X^2 + self.Y^2 + self.Z^2)
    return self
end

Vector3.zero = Vector3.new(0, 0, 0)
Vector3.one = Vector3.new(1, 1, 1)
Vector3.xAxis = Vector3.new(1, 0, 0)
Vector3.yAxis = Vector3.new(0, 1, 0)
Vector3.zAxis = Vector3.new(0, 0, 1)

function Vector3:__add(other)
    return Vector3.new(self.X + other.X, self.Y + other.Y, self.Z + other.Z)
end

function Vector3:__sub(other)
    return Vector3.new(self.X - other.X, self.Y - other.Y, self.Z - other.Z)
end

function Vector3:__mul(other)
    if type(other) == "number" then
        return Vector3.new(self.X * other, self.Y * other, self.Z * other)
    end
    return Vector3.new(self.X * other.X, self.Y * other.Y, self.Z * other.Z)
end

function Vector3:__div(other)
    if type(other) == "number" then
        return Vector3.new(self.X / other, self.Y / other, self.Z / other)
    end
    return Vector3.new(self.X / other.X, self.Y / other.Y, self.Z / other.Z)
end

function Vector3:__unm()
    return Vector3.new(-self.X, -self.Y, -self.Z)
end

function Vector3:__eq(other)
    return self.X == other.X and self.Y == other.Y and self.Z == other.Z
end

function Vector3:__tostring()
    return string.format("%g, %g, %g", self.X, self.Y, self.Z)
end

function Vector3:Dot(other)
    return self.X * other.X + self.Y * other.Y + self.Z * other.Z
end

function Vector3:Cross(other)
    return Vector3.new(
        self.Y * other.Z - self.Z * other.Y,
        self.Z * other.X - self.X * other.Z,
        self.X * other.Y - self.Y * other.X
    )
end

function Vector3:Lerp(goal, alpha)
    return self + (goal - self) * alpha
end

registerType(Vector3, "Vector3")

-- ============================================================================
-- CFrame
-- ============================================================================
local CFrame = {}
CFrame.__index = CFrame
CFrame.__type = "CFrame"

function CFrame.new(x, y, z, ...)
    local self = setmetatable({}, CFrame)
    
    if type(x) == "table" and x.X then
        -- CFrame.new(Vector3)
        self.Position = x
        self.X = x.X
        self.Y = x.Y
        self.Z = x.Z
    else
        self.X = x or 0
        self.Y = y or 0
        self.Z = z or 0
        self.Position = Vector3.new(self.X, self.Y, self.Z)
    end
    
    -- Rotation matrix (identity by default)
    local args = {...}
    if #args == 9 then
        self.R00, self.R01, self.R02 = args[1], args[2], args[3]
        self.R10, self.R11, self.R12 = args[4], args[5], args[6]
        self.R20, self.R21, self.R22 = args[7], args[8], args[9]
    else
        self.R00, self.R01, self.R02 = 1, 0, 0
        self.R10, self.R11, self.R12 = 0, 1, 0
        self.R20, self.R21, self.R22 = 0, 0, 1
    end
    
    self.LookVector = Vector3.new(-self.R02, -self.R12, -self.R22)
    self.RightVector = Vector3.new(self.R00, self.R10, self.R20)
    self.UpVector = Vector3.new(self.R01, self.R11, self.R21)
    
    return self
end

CFrame.identity = CFrame.new(0, 0, 0)

function CFrame.lookAt(position, target, up)
    up = up or Vector3.yAxis
    local forward = (target - position)
    if forward.Magnitude > 0 then
        forward = forward / forward.Magnitude
    end
    return CFrame.new(position.X, position.Y, position.Z)
end

function CFrame.Angles(rx, ry, rz)
    -- Simplified rotation CFrame
    return CFrame.new(0, 0, 0)
end

function CFrame.fromEulerAnglesXYZ(rx, ry, rz)
    return CFrame.Angles(rx, ry, rz)
end

function CFrame:__mul(other)
    if type(other) == "table" and other.X and other.Y and other.Z then
        if getmetatable(other) == Vector3 then
            -- CFrame * Vector3
            return Vector3.new(
                self.X + self.R00 * other.X + self.R01 * other.Y + self.R02 * other.Z,
                self.Y + self.R10 * other.X + self.R11 * other.Y + self.R12 * other.Z,
                self.Z + self.R20 * other.X + self.R21 * other.Y + self.R22 * other.Z
            )
        else
            -- CFrame * CFrame
            return CFrame.new(self.X + other.X, self.Y + other.Y, self.Z + other.Z)
        end
    end
    return self
end

function CFrame:__add(other)
    return CFrame.new(self.X + other.X, self.Y + other.Y, self.Z + other.Z)
end

function CFrame:__tostring()
    return string.format("%g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g",
        self.X, self.Y, self.Z,
        self.R00, self.R01, self.R02,
        self.R10, self.R11, self.R12,
        self.R20, self.R21, self.R22
    )
end

function CFrame:Inverse()
    return CFrame.new(-self.X, -self.Y, -self.Z)
end

function CFrame:Lerp(goal, alpha)
    return CFrame.new(
        self.X + (goal.X - self.X) * alpha,
        self.Y + (goal.Y - self.Y) * alpha,
        self.Z + (goal.Z - self.Z) * alpha
    )
end

function CFrame:ToWorldSpace(cf)
    return self * cf
end

function CFrame:ToObjectSpace(cf)
    return self:Inverse() * cf
end

function CFrame:PointToWorldSpace(v3)
    return self * v3
end

function CFrame:PointToObjectSpace(v3)
    return self:Inverse() * v3
end

function CFrame:GetComponents()
    return self.X, self.Y, self.Z,
           self.R00, self.R01, self.R02,
           self.R10, self.R11, self.R12,
           self.R20, self.R21, self.R22
end

registerType(CFrame, "CFrame")

-- ============================================================================
-- Color3
-- ============================================================================
local Color3 = {}
Color3.__index = Color3
Color3.__type = "Color3"

function Color3.new(r, g, b)
    local self = setmetatable({}, Color3)
    self.R = r or 0
    self.G = g or 0
    self.B = b or 0
    return self
end

function Color3.fromRGB(r, g, b)
    return Color3.new((r or 0) / 255, (g or 0) / 255, (b or 0) / 255)
end

function Color3.fromHSV(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h * 6) % 2 - 1))
    local m = v - c
    local r, g, b
    
    if h < 1/6 then r, g, b = c, x, 0
    elseif h < 2/6 then r, g, b = x, c, 0
    elseif h < 3/6 then r, g, b = 0, c, x
    elseif h < 4/6 then r, g, b = 0, x, c
    elseif h < 5/6 then r, g, b = x, 0, c
    else r, g, b = c, 0, x
    end
    
    return Color3.new(r + m, g + m, b + m)
end

function Color3.fromHex(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return Color3.new(r, g, b)
end

function Color3:ToHSV()
    local max = math.max(self.R, self.G, self.B)
    local min = math.min(self.R, self.G, self.B)
    local delta = max - min
    
    local h, s, v
    v = max
    
    if max == 0 then
        s = 0
    else
        s = delta / max
    end
    
    if delta == 0 then
        h = 0
    elseif max == self.R then
        h = ((self.G - self.B) / delta) % 6
    elseif max == self.G then
        h = (self.B - self.R) / delta + 2
    else
        h = (self.R - self.G) / delta + 4
    end
    
    h = h / 6
    
    return h, s, v
end

function Color3:ToHex()
    return string.format("%02X%02X%02X",
        math.floor(self.R * 255 + 0.5),
        math.floor(self.G * 255 + 0.5),
        math.floor(self.B * 255 + 0.5)
    )
end

function Color3:Lerp(goal, alpha)
    return Color3.new(
        self.R + (goal.R - self.R) * alpha,
        self.G + (goal.G - self.G) * alpha,
        self.B + (goal.B - self.B) * alpha
    )
end

function Color3:__eq(other)
    return self.R == other.R and self.G == other.G and self.B == other.B
end

function Color3:__tostring()
    return string.format("%g, %g, %g", self.R, self.G, self.B)
end

registerType(Color3, "Color3")

-- ============================================================================
-- UDim
-- ============================================================================
local UDim = {}
UDim.__index = UDim
UDim.__type = "UDim"

function UDim.new(scale, offset)
    local self = setmetatable({}, UDim)
    self.Scale = scale or 0
    self.Offset = offset or 0
    return self
end

function UDim:__add(other)
    return UDim.new(self.Scale + other.Scale, self.Offset + other.Offset)
end

function UDim:__sub(other)
    return UDim.new(self.Scale - other.Scale, self.Offset - other.Offset)
end

function UDim:__eq(other)
    return self.Scale == other.Scale and self.Offset == other.Offset
end

function UDim:__tostring()
    return string.format("%g, %d", self.Scale, self.Offset)
end

registerType(UDim, "UDim")

-- ============================================================================
-- UDim2
-- ============================================================================
local UDim2 = {}
UDim2.__index = UDim2
UDim2.__type = "UDim2"

function UDim2.new(xScale, xOffset, yScale, yOffset)
    local self = setmetatable({}, UDim2)
    self.X = UDim.new(xScale or 0, xOffset or 0)
    self.Y = UDim.new(yScale or 0, yOffset or 0)
    self.Width = self.X
    self.Height = self.Y
    return self
end

function UDim2.fromScale(xScale, yScale)
    return UDim2.new(xScale, 0, yScale, 0)
end

function UDim2.fromOffset(xOffset, yOffset)
    return UDim2.new(0, xOffset, 0, yOffset)
end

function UDim2:__add(other)
    return UDim2.new(
        self.X.Scale + other.X.Scale,
        self.X.Offset + other.X.Offset,
        self.Y.Scale + other.Y.Scale,
        self.Y.Offset + other.Y.Offset
    )
end

function UDim2:__sub(other)
    return UDim2.new(
        self.X.Scale - other.X.Scale,
        self.X.Offset - other.X.Offset,
        self.Y.Scale - other.Y.Scale,
        self.Y.Offset - other.Y.Offset
    )
end

function UDim2:__eq(other)
    return self.X == other.X and self.Y == other.Y
end

function UDim2:__tostring()
    return string.format("{%s}, {%s}", tostring(self.X), tostring(self.Y))
end

function UDim2:Lerp(goal, alpha)
    return UDim2.new(
        self.X.Scale + (goal.X.Scale - self.X.Scale) * alpha,
        self.X.Offset + (goal.X.Offset - self.X.Offset) * alpha,
        self.Y.Scale + (goal.Y.Scale - self.Y.Scale) * alpha,
        self.Y.Offset + (goal.Y.Offset - self.Y.Offset) * alpha
    )
end

registerType(UDim2, "UDim2")

-- ============================================================================
-- ColorSequenceKeypoint
-- ============================================================================
local ColorSequenceKeypoint = {}
ColorSequenceKeypoint.__index = ColorSequenceKeypoint
ColorSequenceKeypoint.__type = "ColorSequenceKeypoint"

function ColorSequenceKeypoint.new(time, color)
    local self = setmetatable({}, ColorSequenceKeypoint)
    self.Time = time or 0
    self.Value = color or Color3.new(1, 1, 1)
    return self
end

function ColorSequenceKeypoint:__eq(other)
    return self.Time == other.Time and self.Value == other.Value
end

function ColorSequenceKeypoint:__tostring()
    return string.format("%g %s", self.Time, tostring(self.Value))
end

registerType(ColorSequenceKeypoint, "ColorSequenceKeypoint")

-- ============================================================================
-- ColorSequence
-- ============================================================================
local ColorSequence = {}
ColorSequence.__index = ColorSequence
ColorSequence.__type = "ColorSequence"

function ColorSequence.new(...)
    local self = setmetatable({}, ColorSequence)
    local args = {...}
    
    if #args == 1 and type(args[1]) == "table" and args[1].R then
        -- Single Color3
        self.Keypoints = {
            ColorSequenceKeypoint.new(0, args[1]),
            ColorSequenceKeypoint.new(1, args[1])
        }
    elseif #args == 2 and type(args[1]) == "table" and args[1].R then
        -- Two Color3s
        self.Keypoints = {
            ColorSequenceKeypoint.new(0, args[1]),
            ColorSequenceKeypoint.new(1, args[2])
        }
    elseif #args == 1 and type(args[1]) == "table" then
        -- Array of ColorSequenceKeypoints
        self.Keypoints = args[1]
    else
        self.Keypoints = {}
    end
    
    return self
end

function ColorSequence:__eq(other)
    if #self.Keypoints ~= #other.Keypoints then
        return false
    end
    for i, kp in ipairs(self.Keypoints) do
        if kp ~= other.Keypoints[i] then
            return false
        end
    end
    return true
end

function ColorSequence:__tostring()
    local parts = {}
    for _, kp in ipairs(self.Keypoints) do
        table.insert(parts, tostring(kp))
    end
    return table.concat(parts, " ")
end

registerType(ColorSequence, "ColorSequence")

-- ============================================================================
-- NumberSequenceKeypoint
-- ============================================================================
local NumberSequenceKeypoint = {}
NumberSequenceKeypoint.__index = NumberSequenceKeypoint
NumberSequenceKeypoint.__type = "NumberSequenceKeypoint"

function NumberSequenceKeypoint.new(time, value, envelope)
    local self = setmetatable({}, NumberSequenceKeypoint)
    self.Time = time or 0
    self.Value = value or 0
    self.Envelope = envelope or 0
    return self
end

function NumberSequenceKeypoint:__eq(other)
    return self.Time == other.Time and self.Value == other.Value and self.Envelope == other.Envelope
end

function NumberSequenceKeypoint:__tostring()
    return string.format("%g %g %g", self.Time, self.Value, self.Envelope)
end

registerType(NumberSequenceKeypoint, "NumberSequenceKeypoint")

-- ============================================================================
-- NumberSequence
-- ============================================================================
local NumberSequence = {}
NumberSequence.__index = NumberSequence
NumberSequence.__type = "NumberSequence"

function NumberSequence.new(...)
    local self = setmetatable({}, NumberSequence)
    local args = {...}
    
    if #args == 1 and type(args[1]) == "number" then
        -- Single number
        self.Keypoints = {
            NumberSequenceKeypoint.new(0, args[1]),
            NumberSequenceKeypoint.new(1, args[1])
        }
    elseif #args == 2 and type(args[1]) == "number" then
        -- Two numbers
        self.Keypoints = {
            NumberSequenceKeypoint.new(0, args[1]),
            NumberSequenceKeypoint.new(1, args[2])
        }
    elseif #args == 1 and type(args[1]) == "table" then
        -- Array of NumberSequenceKeypoints
        self.Keypoints = args[1]
    else
        self.Keypoints = {}
    end
    
    return self
end

function NumberSequence:__eq(other)
    if #self.Keypoints ~= #other.Keypoints then
        return false
    end
    for i, kp in ipairs(self.Keypoints) do
        if kp ~= other.Keypoints[i] then
            return false
        end
    end
    return true
end

function NumberSequence:__tostring()
    local parts = {}
    for _, kp in ipairs(self.Keypoints) do
        table.insert(parts, tostring(kp))
    end
    return table.concat(parts, " ")
end

registerType(NumberSequence, "NumberSequence")

-- ============================================================================
-- NumberRange
-- ============================================================================
local NumberRange = {}
NumberRange.__index = NumberRange
NumberRange.__type = "NumberRange"

function NumberRange.new(min, max)
    local self = setmetatable({}, NumberRange)
    self.Min = min or 0
    self.Max = max or min or 0
    return self
end

function NumberRange:__eq(other)
    return self.Min == other.Min and self.Max == other.Max
end

function NumberRange:__tostring()
    return string.format("%g %g", self.Min, self.Max)
end

registerType(NumberRange, "NumberRange")

-- ============================================================================
-- Ray
-- ============================================================================
local Ray = {}
Ray.__index = Ray
Ray.__type = "Ray"

function Ray.new(origin, direction)
    local self = setmetatable({}, Ray)
    self.Origin = origin or Vector3.new()
    self.Direction = direction or Vector3.new()
    self.Unit = nil -- Computed lazily
    return self
end

function Ray:ClosestPoint(point)
    local offset = point - self.Origin
    local t = offset:Dot(self.Direction) / self.Direction:Dot(self.Direction)
    t = math.max(0, t)
    return self.Origin + self.Direction * t
end

function Ray:Distance(point)
    local closest = self:ClosestPoint(point)
    return (point - closest).Magnitude
end

function Ray:__tostring()
    return string.format("{%s}, {%s}", tostring(self.Origin), tostring(self.Direction))
end

registerType(Ray, "Ray")

-- ============================================================================
-- BrickColor
-- ============================================================================
local BrickColor = {}
BrickColor.__index = BrickColor
BrickColor.__type = "BrickColor"

local brickColorPalette = {
    ["White"] = {255, 255, 255},
    ["Grey"] = {163, 162, 165},
    ["Light yellow"] = {249, 233, 153},
    ["Brick yellow"] = {215, 197, 154},
    ["Light green (Mint)"] = {194, 218, 184},
    ["Light reddish violet"] = {232, 186, 200},
    ["Pastel Blue"] = {128, 187, 219},
    ["Light orange brown"] = {203, 132, 66},
    ["Nougat"] = {204, 142, 105},
    ["Bright red"] = {196, 40, 28},
    ["Med. reddish violet"] = {200, 80, 155},
    ["Bright blue"] = {13, 105, 172},
    ["Bright yellow"] = {245, 205, 48},
    ["Earth orange"] = {102, 62, 39},
    ["Black"] = {27, 42, 53},
    ["Dark grey"] = {99, 95, 98},
    ["Dark green"] = {39, 70, 45},
    ["Medium green"] = {161, 196, 140},
    ["Lig. Yellowich orange"] = {254, 243, 187},
    ["Bright green"] = {75, 151, 75},
    ["Dark orange"] = {169, 85, 0},
    ["Light bluish violet"] = {180, 210, 228},
    ["Transparent"] = {238, 238, 238},
    ["Tr. Red"] = {205, 84, 75},
    ["Tr. Lg blue"] = {193, 223, 240},
    ["Tr. Blue"] = {165, 207, 231},
    ["Tr. Yellow"] = {247, 241, 141},
    ["Light blue"] = {180, 210, 227},
    ["Tr. Flu. Reddish orange"] = {217, 133, 108},
    ["Tr. Green"] = {132, 182, 141},
    ["Tr. Flu. Green"] = {248, 241, 132},
    ["Phosph. White"] = {236, 232, 222},
    ["Light red"] = {238, 196, 182},
    ["Medium red"] = {218, 134, 122},
    ["Medium blue"] = {110, 153, 202},
    ["Light grey"] = {199, 193, 183},
    ["Bright violet"] = {107, 50, 124},
    ["Br. yellowish orange"] = {226, 155, 64},
    ["Bright orange"] = {218, 133, 65},
    ["Bright bluish green"] = {0, 143, 156},
    ["Earth yellow"] = {104, 92, 67},
    ["Bright bluish violet"] = {104, 116, 202},
    ["Tr. Brown"] = {191, 183, 177},
    ["Medium bluish violet"] = {110, 128, 199},
    ["Tr. Medi. reddish violet"] = {229, 173, 200},
    ["Med. yellowish green"] = {199, 210, 60},
    ["Med. bluish green"] = {85, 165, 175},
    ["Light bluish green"] = {183, 215, 213},
    ["Br. yellowish green"] = {164, 189, 71},
    ["Lig. yellowish green"] = {217, 228, 167},
    ["Med. yellowish orange"] = {255, 167, 26},
    ["Br. reddish orange"] = {208, 80, 63},
    ["Bright reddish violet"] = {144, 31, 118},
    ["Light orange"] = {246, 169, 122},
    ["Tr. Bright bluish violet"] = {165, 165, 203},
    ["Gold"] = {220, 188, 129},
    ["Dark nougat"] = {174, 122, 89},
    ["Silver"] = {156, 163, 168},
    ["Neon orange"] = {213, 115, 61},
    ["Neon green"] = {216, 221, 86},
    ["Sand blue"] = {116, 134, 157},
    ["Sand violet"] = {135, 124, 144},
    ["Medium orange"] = {224, 152, 100},
    ["Sand yellow"] = {149, 138, 115},
    ["Earth blue"] = {32, 58, 86},
    ["Earth green"] = {39, 70, 45},
    ["Tr. Flu. Blue"] = {207, 226, 247},
    ["Sand blue metallic"] = {121, 136, 161},
    ["Sand violet metallic"] = {149, 142, 163},
    ["Sand yellow metallic"] = {147, 135, 103},
    ["Dark grey metallic"] = {87, 88, 87},
    ["Black metallic"] = {22, 29, 50},
    ["Light grey metallic"] = {171, 173, 172},
    ["Sand green"] = {120, 144, 130},
    ["Sand red"] = {149, 121, 119},
    ["Dark red"] = {123, 46, 47},
    ["Tr. Flu. Yellow"] = {255, 246, 123},
    ["Tr. Flu. Red"] = {225, 164, 194},
    ["Gun metallic"] = {117, 108, 98},
    ["Red flip/flop"] = {151, 105, 91},
    ["Yellow flip/flop"] = {180, 132, 85},
    ["Silver flip/flop"] = {137, 135, 136},
    ["Curry"] = {221, 152, 46},
    ["Fire Yellow"] = {249, 214, 46},
    ["Flame yellowish orange"] = {232, 171, 45},
    ["Reddish brown"] = {105, 64, 40},
    ["Flame reddish orange"] = {207, 96, 36},
    ["Medium stone grey"] = {163, 162, 165},
    ["Royal blue"] = {70, 103, 164},
    ["Dark Royal blue"] = {35, 71, 139},
    ["Bright reddish lilac"] = {142, 66, 133},
    ["Dark stone grey"] = {99, 95, 98},
    ["Lemon metalic"] = {145, 154, 102},
    ["Light stone grey"] = {229, 228, 223},
    ["Dark Curry"] = {179, 132, 13},
    ["Faded green"] = {104, 188, 143},
    ["Turquoise"] = {59, 189, 191},
    ["Light Royal blue"] = {157, 195, 247},
    ["Medium Royal blue"] = {106, 145, 206},
    ["Rust"] = {143, 76, 42},
    ["Brown"] = {124, 92, 70},
    ["Reddish lilac"] = {150, 103, 102},
    ["Lilac"] = {107, 98, 155},
    ["Light lilac"] = {205, 173, 200},
    ["Bright purple"] = {205, 98, 152},
    ["Light purple"] = {228, 173, 200},
    ["Light pink"] = {220, 144, 149},
    ["Light brick yellow"] = {233, 218, 180},
    ["Warm yellowish orange"] = {250, 188, 135},
    ["Cool yellow"] = {253, 234, 141},
    ["Dove blue"] = {125, 187, 221},
    ["Medium lilac"] = {52, 43, 117},
    ["Slime green"] = {80, 109, 84},
    ["Smoky grey"] = {91, 93, 105},
    ["Dark blue"] = {0, 32, 96},
    ["Parsley green"] = {44, 101, 29},
    ["Steel blue"] = {130, 138, 93},
    ["Storm blue"] = {33, 84, 185},
    ["Lapis"] = {16, 66, 153},
    ["Dark indigo"] = {23, 35, 35},
    ["Sea green"] = {105, 195, 172},
    ["Shamrock"] = {70, 154, 132},
    ["Fossil"] = {99, 108, 102},
    ["Mulberry"] = {89, 34, 89},
    ["Forest green"] = {31, 128, 29},
    ["Cadet blue"] = {159, 173, 192},
    ["Electric blue"] = {9, 137, 207},
    ["Eggplant"] = {123, 0, 123},
    ["Moss"] = {124, 156, 107},
    ["Artichoke"] = {138, 171, 133},
    ["Sage green"] = {180, 210, 114},
    ["Ghost grey"] = {202, 203, 209},
    ["Lilac"] = {170, 126, 159},
    ["Plum"] = {123, 47, 123},
    ["Olivine"] = {148, 190, 129},
    ["Laurel green"] = {168, 189, 153},
    ["Quill grey"] = {223, 223, 222},
    ["Crimson"] = {151, 0, 0},
    ["Mint"] = {177, 229, 166},
    ["Baby blue"] = {152, 194, 219},
    ["Carnation pink"] = {255, 152, 220},
    ["Persimmon"] = {255, 89, 89},
    ["Maroon"] = {117, 0, 0},
    ["Gold"] = {239, 184, 56},
    ["Daisy orange"] = {248, 217, 109},
    ["Pearl"] = {231, 231, 236},
    ["Fog"] = {199, 212, 228},
    ["Salmon"] = {255, 148, 148},
    ["Terra Cotta"] = {190, 104, 98},
    ["Cocoa"] = {86, 36, 36},
    ["Wheat"] = {241, 231, 199},
    ["Buttermilk"] = {254, 243, 187},
    ["Mauve"] = {224, 178, 208},
    ["Sunrise"] = {215, 142, 108},
    ["Tawny"] = {150, 85, 85},
    ["Rust"] = {143, 76, 42},
    ["Cashmere"] = {211, 190, 150},
    ["Khaki"] = {226, 220, 188},
    ["Lily white"] = {237, 234, 234},
    ["Seashell"] = {233, 218, 218},
    ["Burgundy"] = {136, 62, 62},
    ["Cork"] = {188, 155, 93},
    ["Burlap"] = {199, 172, 120},
    ["Beige"] = {202, 191, 163},
    ["Oyster"] = {187, 179, 178},
    ["Pine Cone"] = {108, 88, 75},
    ["Fawn brown"] = {160, 132, 79},
    ["Hurricane grey"] = {149, 137, 136},
    ["Cloudy grey"] = {171, 168, 158},
    ["Linen"] = {175, 148, 131},
    ["Copper"] = {150, 103, 102},
    ["Dirt brown"] = {86, 66, 54},
    ["Bronze"] = {126, 104, 63},
    ["Flint"] = {105, 102, 92},
    ["Dark taupe"] = {90, 76, 66},
    ["Burnt Sienna"] = {70, 46, 39},
    ["Institutional white"] = {248, 248, 248},
    ["Mid gray"] = {205, 205, 205},
    ["Really black"] = {17, 17, 17},
    ["Really red"] = {255, 0, 0},
    ["Deep orange"] = {255, 176, 0},
    ["Alder"] = {181, 137, 104},
    ["Dusty Rose"] = {163, 75, 75},
    ["Olive"] = {193, 190, 66},
    ["New Yeller"] = {255, 255, 0},
    ["Really blue"] = {0, 0, 255},
    ["Navy blue"] = {0, 32, 96},
    ["Deep blue"] = {33, 84, 185},
    ["Cyan"] = {4, 175, 236},
    ["CGA brown"] = {170, 85, 0},
    ["Magenta"] = {170, 0, 170},
    ["Pink"] = {255, 102, 204},
    ["Deep orange"] = {255, 176, 0},
    ["Teal"] = {18, 238, 212},
    ["Toothpaste"] = {0, 255, 255},
    ["Lime green"] = {0, 255, 0},
    ["Camo"] = {58, 125, 21},
    ["Grime"] = {127, 142, 100},
    ["Lavender"] = {140, 91, 159},
    ["Pastel light blue"] = {175, 221, 255},
    ["Pastel orange"] = {255, 201, 201},
    ["Pastel violet"] = {177, 167, 255},
    ["Pastel blue-green"] = {159, 243, 233},
    ["Pastel green"] = {204, 255, 204},
    ["Pastel yellow"] = {255, 255, 204},
    ["Pastel brown"] = {255, 204, 153},
    ["Royal purple"] = {98, 37, 209},
    ["Hot pink"] = {255, 0, 191},
}

function BrickColor.new(value)
    local self = setmetatable({}, BrickColor)
    
    if type(value) == "string" then
        self.Name = value
        local rgb = brickColorPalette[value]
        if rgb then
            self.Color = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
        else
            self.Color = Color3.new(0.5, 0.5, 0.5)
        end
    elseif type(value) == "number" then
        -- BrickColor number - simplified
        self.Name = "Medium stone grey"
        self.Color = Color3.fromRGB(163, 162, 165)
    else
        self.Name = "Medium stone grey"
        self.Color = Color3.fromRGB(163, 162, 165)
    end
    
    self.Number = 0 -- Simplified
    self.r = self.Color.R
    self.g = self.Color.G
    self.b = self.Color.B
    
    return self
end

function BrickColor.Random()
    local names = {}
    for name in pairs(brickColorPalette) do
        table.insert(names, name)
    end
    return BrickColor.new(names[math.random(#names)])
end

function BrickColor.White() return BrickColor.new("White") end
function BrickColor.Gray() return BrickColor.new("Medium stone grey") end
function BrickColor.DarkGray() return BrickColor.new("Dark stone grey") end
function BrickColor.Black() return BrickColor.new("Black") end
function BrickColor.Red() return BrickColor.new("Bright red") end
function BrickColor.Yellow() return BrickColor.new("Bright yellow") end
function BrickColor.Green() return BrickColor.new("Bright green") end
function BrickColor.Blue() return BrickColor.new("Bright blue") end

function BrickColor:__tostring()
    return self.Name
end

function BrickColor:__eq(other)
    return self.Name == other.Name
end

registerType(BrickColor, "BrickColor")

-- ============================================================================
-- TweenInfo
-- ============================================================================
local TweenInfo = {}
TweenInfo.__index = TweenInfo
TweenInfo.__type = "TweenInfo"

function TweenInfo.new(time, easingStyle, easingDirection, repeatCount, reverses, delayTime)
    local self = setmetatable({}, TweenInfo)
    self.Time = time or 1
    self.EasingStyle = easingStyle or "Quad"
    self.EasingDirection = easingDirection or "Out"
    self.RepeatCount = repeatCount or 0
    self.Reverses = reverses or false
    self.DelayTime = delayTime or 0
    return self
end

function TweenInfo:__tostring()
    return string.format("TweenInfo(%g, %s, %s, %d, %s, %g)",
        self.Time, self.EasingStyle, self.EasingDirection,
        self.RepeatCount, tostring(self.Reverses), self.DelayTime
    )
end

registerType(TweenInfo, "TweenInfo")

-- ============================================================================
-- Rect
-- ============================================================================
local Rect = {}
Rect.__index = Rect
Rect.__type = "Rect"

function Rect.new(minX, minY, maxX, maxY)
    local self = setmetatable({}, Rect)
    
    if type(minX) == "table" and minX.X then
        -- Rect.new(Vector2, Vector2)
        self.Min = minX
        self.Max = minY
    else
        self.Min = Vector2.new(minX or 0, minY or 0)
        self.Max = Vector2.new(maxX or 0, maxY or 0)
    end
    
    self.Width = self.Max.X - self.Min.X
    self.Height = self.Max.Y - self.Min.Y
    
    return self
end

function Rect:__eq(other)
    return self.Min == other.Min and self.Max == other.Max
end

function Rect:__tostring()
    return string.format("%g, %g, %g, %g", self.Min.X, self.Min.Y, self.Max.X, self.Max.Y)
end

registerType(Rect, "Rect")

-- ============================================================================
-- RaycastParams
-- ============================================================================
local RaycastParams = {}
RaycastParams.__index = RaycastParams
RaycastParams.__type = "RaycastParams"

function RaycastParams.new()
    local self = setmetatable({}, RaycastParams)
    self.FilterType = "Exclude"
    self.FilterDescendantsInstances = {}
    self.IgnoreWater = false
    self.CollisionGroup = "Default"
    return self
end

function RaycastParams:AddToFilter(instances)
    if type(instances) == "table" then
        for _, inst in ipairs(instances) do
            table.insert(self.FilterDescendantsInstances, inst)
        end
    else
        table.insert(self.FilterDescendantsInstances, instances)
    end
end

registerType(RaycastParams, "RaycastParams")

-- ============================================================================
-- RaycastResult (returned by workspace:Raycast)
-- ============================================================================
local RaycastResult = {}
RaycastResult.__index = RaycastResult
RaycastResult.__type = "RaycastResult"

function RaycastResult.new(instance, position, normal, material, distance)
    local self = setmetatable({}, RaycastResult)
    self.Instance = instance
    self.Position = position or Vector3.new()
    self.Normal = normal or Vector3.new(0, 1, 0)
    self.Material = material or "Plastic"
    self.Distance = distance or 0
    return self
end

registerType(RaycastResult, "RaycastResult")

-- ============================================================================
-- Axes
-- ============================================================================
local Axes = {}
Axes.__index = Axes
Axes.__type = "Axes"

function Axes.new(...)
    local self = setmetatable({}, Axes)
    local args = {...}
    self.X = false
    self.Y = false
    self.Z = false
    self.Top = false
    self.Bottom = false
    self.Left = false
    self.Right = false
    self.Back = false
    self.Front = false
    
    for _, axis in ipairs(args) do
        if axis == "X" or axis == "Right" or axis == "Left" then
            self.X = true
        elseif axis == "Y" or axis == "Top" or axis == "Bottom" then
            self.Y = true
        elseif axis == "Z" or axis == "Front" or axis == "Back" then
            self.Z = true
        end
    end
    
    return self
end

registerType(Axes, "Axes")

-- ============================================================================
-- Faces
-- ============================================================================
local Faces = {}
Faces.__index = Faces
Faces.__type = "Faces"

function Faces.new(...)
    local self = setmetatable({}, Faces)
    local args = {...}
    self.Top = false
    self.Bottom = false
    self.Left = false
    self.Right = false
    self.Back = false
    self.Front = false
    
    for _, face in ipairs(args) do
        if self[face] ~= nil then
            self[face] = true
        end
    end
    
    return self
end

registerType(Faces, "Faces")

-- ============================================================================
-- Return all data types
-- ============================================================================
return {
    Vector2 = Vector2,
    Vector3 = Vector3,
    CFrame = CFrame,
    Color3 = Color3,
    UDim = UDim,
    UDim2 = UDim2,
    ColorSequenceKeypoint = ColorSequenceKeypoint,
    ColorSequence = ColorSequence,
    NumberSequenceKeypoint = NumberSequenceKeypoint,
    NumberSequence = NumberSequence,
    NumberRange = NumberRange,
    Ray = Ray,
    BrickColor = BrickColor,
    TweenInfo = TweenInfo,
    Rect = Rect,
    RaycastParams = RaycastParams,
    RaycastResult = RaycastResult,
    Axes = Axes,
    Faces = Faces,
}

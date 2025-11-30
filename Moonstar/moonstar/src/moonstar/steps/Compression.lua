-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- Compression.lua
--
-- This Script provides a Compression Step using LZW algorithm with Variable-Width Bit Packing,
-- Keyword Pre-seeding, and Dictionary Reset.

local Step = require("moonstar.step");
local Ast = require("moonstar.ast");
local util = require("moonstar.util");
local logger = require("logger");

local Compression = Step:extend();
Compression.Description = "Compresses the script using Smart LZW (Keywords + Var-Width + Reset)";
Compression.Name = "Compression";

Compression.SettingsDescriptor = {
    Enabled = {
        type = "boolean",
        default = false,
    },
}

function Compression:init(settings)

end

function Compression:apply(ast, pipeline)
    logger:info("Compressing Code ...");

    -- 1. Unparse current AST to get source code
    local source = pipeline:unparse(ast)

    if #source == 0 then
        return ast
    end

    -- 2. Compress
    local compressed = self:lzw_compress(source)

    -- 3. Generate Decompressor AST
    local decompressor_code = self:get_decompressor(compressed)

    -- Parse the decompressor code into a new AST
    local new_ast = pipeline.parser:parse(decompressor_code)

    -- Replace the AST
    ast.body = new_ast.body
    ast.globalScope = new_ast.globalScope

    return ast
end

-- Common Lua & Roblox/Luau keywords to pre-seed the dictionary
local KEYWORDS = {
    -- Lua Keywords
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function", 
    "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", 
    "true", "until", "while",
    -- Standard Lua Globals
    "math", "string", "table", "os", "io", "debug", "coroutine", "package",
    "_G", "getfenv", "setfenv", "ipairs", "pairs", "next", "pcall", "xpcall",
    "select", "tonumber", "tostring", "type", "unpack", "print", "warn", "error",
    "assert", "collectgarbage", "dofile", "load", "loadfile", "loadstring",
    "module", "require", "rawget", "rawset", "rawequal", "setmetatable", "getmetatable",
    "newproxy",
    -- Roblox/Luau Services & Globals
    "game", "workspace", "Workspace", "script", "shared", "getgenv", "getrenv",
    "getreg", "getgc", "getinstances", "getnilinstances",
    "Instance", "Vector3", "Vector2", "CFrame", "Color3", "UDim2", "UDim", "Enum",
    "Ray", "RaycastParams", "OverlapParams", "Region3", "Rect", "Faces", "Axes",
    "BrickColor", "ColorSequence", "NumberSequence", "PhysicalProperties",
    "Random", "TweenInfo", "DockWidgetPluginGuiInfo", "PathWaypoint",
    "task", "utf8", "bit32",
    -- Common Methods
    "GetService", "FindFirstChild", "WaitForChild", "GetChildren", "GetDescendants",
    "Connect", "Disconnect", "Wait", "Destroy", "Clone", "ClearAllChildren",
    "IsA", "IsDescendantOf", "GetAttribute", "SetAttribute",
    "FireServer", "InvokeServer", "FireClient", "InvokeClient", "FireAllClients",
    -- Common Properties
    "Parent", "Name", "ClassName", "Value", "Position", "Size", "Color",
    "Transparency", "Anchored", "CanCollide", "Material", "Reflectance",
    "Archivable", "Locked", "Visible", "Enabled", "Active",
    -- Events
    "Changed", "ChildAdded", "ChildRemoved", "DescendantAdded", "DescendantRemoving",
    "InputBegan", "InputChanged", "InputEnded", "MouseButton1Click",
    -- Common Names
    "Players", "Lighting", "ReplicatedStorage", "ServerScriptService", "ServerStorage",
    "StarterGui", "StarterPack", "StarterPlayer", "SoundService", "Chat",
    "ContentProvider", "HttpService", "RunService", "TweenService", "UserInputService",
    "ContextActionService", "MarketplaceService", "BadgeService", "TeleportService",
    "LocalPlayer", "Character", "Humanoid", "HumanoidRootPart", "RootPart", "Torso",
    "Head", "new", "fromRGB", "fromHSV", "fromMatrix", "fromAxisAngle"
}

function Compression:lzw_compress(input)
    local dict = {}
    local next_code
    local code_width
    local max_code_for_width
    
    local function init_dict()
        dict = {}
        for i = 0, 255 do
            dict[string.char(i)] = i
        end
        -- 256 is reserved for CLEAR code
        for i, kw in ipairs(KEYWORDS) do
            dict[kw] = 256 + i
        end
        next_code = 257 + #KEYWORDS
        code_width = 9
        max_code_for_width = 511
    end

    init_dict()

    local current_sequence = ""
    local result = {}
    
    -- Bit packing state
    local bit_buf = 0
    local bit_cnt = 0
    local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    local function write_bits(val, width)
        local p = 2 ^ width
        bit_buf = bit_buf * p + val
        bit_cnt = bit_cnt + width
        
        while bit_cnt >= 6 do
            local shift = bit_cnt - 6
            local p6 = 2 ^ shift
            local chunk = math.floor(bit_buf / p6)
            bit_buf = bit_buf % p6
            bit_cnt = shift
            table.insert(result, b64:sub(chunk+1, chunk+1))
        end
    end

    for i = 1, #input do
        local c = input:sub(i, i)
        local next_sequence = current_sequence .. c
        if dict[next_sequence] then
            current_sequence = next_sequence
        else
            write_bits(dict[current_sequence], code_width)
            
            if next_code >= 65536 then
                -- Dictionary full, emit CLEAR code and reset
                write_bits(256, code_width)
                init_dict()
                -- current_sequence remains just 'c', which is in the fresh dict
            else
                dict[next_sequence] = next_code
                next_code = next_code + 1
                if next_code > max_code_for_width and code_width < 16 then
                    code_width = code_width + 1
                    max_code_for_width = 2^code_width - 1
                end
            end
            current_sequence = c
        end
    end
    
    if #current_sequence > 0 then
        write_bits(dict[current_sequence], code_width)
    end
    
    -- Flush remaining bits
    if bit_cnt > 0 then
        local shift = 6 - bit_cnt
        bit_buf = bit_buf * (2^shift)
        table.insert(result, b64:sub(bit_buf+1, bit_buf+1))
    end

    return table.concat(result)
end

function Compression:get_decompressor(compressed_data)
    -- Minified Decompressor with Keywords and Reset support
    -- Variables:
    -- b: Base64 string
    -- d: Compressed data
    -- k: Keywords table
    -- m: Base64 map
    -- t: Dictionary
    -- n: Next code
    -- w: Bit width
    -- I: Init function
    -- g: Get bits function
    -- z: Bit buffer
    -- y: Bit count
    -- x: Data index
    -- l: Data length
    -- o: Output buffer
    -- p: Previous code
    -- c: First char of sequence
    -- e: Current sequence string
    
    local keywords_str = table.concat(KEYWORDS, '","')
    
    local template = [[
local b="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local d="%s"
local k={"%s"}
local m={}for i=1,64 do m[string.sub(b,i,i)]=i-1 end
local t,n,w
local function I()
t={}
for i=0,255 do t[i]=string.char(i)end
for i=1,#k do t[256+i]=k[i]end
n=257+#k
w=9
end
I()
local x,y,z,l=1,0,0,#d
local function g()
if x>l and y<w then return nil end
while y<w do
local c=m[string.sub(d,x,x)]
z=z*64+c
y=y+6
x=x+1
end
local s=y-w
local v=math.floor(z/2^s)
z=z%%2^s
y=s
return v
end
local o={}
local p=g()
if p==256 then I() p=g() end
table.insert(o,t[p])
local c=t[p]
while true do
local v=g()
if not v then break end
if v==256 then
I()
v=g()
if not v then break end
p=v
table.insert(o,t[p])
c=t[p]
else
local e=t[v] or(t[p]..string.sub(c,1,1))
table.insert(o,e)
c=e
if n<65536 then
t[n]=t[p]..string.sub(e,1,1)
n=n+1
if n>2^w-1 and w<16 then w=w+1 end
end
p=v
end
end
local f=loadstring and loadstring(table.concat(o))or load(table.concat(o))
return f(...)
]]
    return string.format(template, compressed_data, keywords_str)
end

return Compression;

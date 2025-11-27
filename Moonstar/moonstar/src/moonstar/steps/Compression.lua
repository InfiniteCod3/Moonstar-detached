-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- Compression.lua
--
-- This Script provides a Compression Step using LZW algorithm

local Step = require("moonstar.step");
local Ast = require("moonstar.ast");
local util = require("moonstar.util");
local logger = require("logger");

local Compression = Step:extend();
Compression.Description = "Compresses the script using LZW and wraps it in a decompressor";
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

function Compression:lzw_compress(input)
    local dict = {}
    for i = 0, 255 do
        dict[string.char(i)] = i
    end

    local next_code = 256
    local current_sequence = ""
    local result = {}

    local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    local function emit(code)
        -- Emit 3 chars (Base64-like encoding of 18-bit block, covering 16-bit code)
        local c3 = code % 64
        local tmp = math.floor(code / 64)
        local c2 = tmp % 64
        local c1 = math.floor(tmp / 64)
        table.insert(result, b64:sub(c1+1, c1+1) .. b64:sub(c2+1, c2+1) .. b64:sub(c3+1, c3+1))
    end

    for i = 1, #input do
        local c = input:sub(i, i)
        local next_sequence = current_sequence .. c
        if dict[next_sequence] then
            current_sequence = next_sequence
        else
            emit(dict[current_sequence])
            if next_code < 65536 then
                dict[next_sequence] = next_code
                next_code = next_code + 1
            end
            current_sequence = c
        end
    end
    if #current_sequence > 0 then
        emit(dict[current_sequence])
    end

    return table.concat(result)
end

function Compression:get_decompressor(compressed_data)
    -- compressed_data contains only Base64 characters, so no escaping is needed.

    local template = [[
local d="%s"
local b="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local m={}
for i=1,64 do m[string.sub(b,i,i)]=i-1 end
local t={}
for i=0,255 do t[i]=string.char(i) end
local n=256
local r={}
local i=1
local function rc()
if i>#d then return nil end
local c1=m[string.sub(d,i,i)]
local c2=m[string.sub(d,i+1,i+1)]
local c3=m[string.sub(d,i+2,i+2)]
i=i+3
return c1*4096+c2*64+c3
end
local o=rc()
table.insert(r,t[o])
local c=t[o]
while true do
local x=rc()
if not x then break end
local s
if t[x] then s=t[x] else s=t[o]..c end
table.insert(r,s)
c=string.sub(s,1,1)
if n<65536 then t[n]=t[o]..c;n=n+1 end
o=x
end
local f=loadstring and loadstring(table.concat(r)) or load(table.concat(r))
return f(...)
]]
    return string.format(template, compressed_data)
end

return Compression;

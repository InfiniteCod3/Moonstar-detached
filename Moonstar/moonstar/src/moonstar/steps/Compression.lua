-- This Script is Part of the Moonstar Obfuscator by Aurologic
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
    logger:info("Compressing Code (LZSS + Base92) ...");

    -- 1. Minify (Rename Variables) BEFORE compression to reduce payload size.
    if pipeline.renameVariables then
        pipeline:renameVariables(ast)
    end

    -- 2. Unparse current AST to get source code
    local source = pipeline:unparse(ast)

    if #source == 0 then
        return ast
    end

    -- 3. Compress (LZSS)
    local compressed = self:lzss_compress(source)

    -- 4. Generate Decompressor AST
    local decompressor_code = self:get_decompressor(compressed)

    -- Parse the decompressor code into a new AST
    local new_ast = pipeline.parser:parse(decompressor_code)

    -- Replace the AST
    ast.body = new_ast.body
    ast.globalScope = new_ast.globalScope

    return ast
end

function Compression:lzss_compress(input)
    local result = {}
    
    -- Base92 Alphabet: ASCII 33-126, excluding 34 (") and 92 (\)
    local b92 = "!#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_abcdefghijklmnopqrstuvwxyz{|}~"
    
    -- Bit packing state
    local bit_buf = 0
    local bit_cnt = 0

    local function write_bits(val, width)
        for i = 0, width - 1 do
            -- Extract bit i from val
            local bit = math.floor(val / (2 ^ i)) % 2
            
            -- Add to buffer
            bit_buf = bit_buf + bit * (2 ^ bit_cnt)
            bit_cnt = bit_cnt + 1
            
            -- Flush 13 bits -> 2 Base92 chars
            if bit_cnt == 13 then
                local v = bit_buf
                local c1 = v % 92
                local c2 = math.floor(v / 92)
                table.insert(result, b92:sub(c1 + 1, c1 + 1) .. b92:sub(c2 + 1, c2 + 1))
                bit_buf = 0
                bit_cnt = 0
            end
        end
    end

    local WINDOW_SIZE = 4095 -- 12 bits
    local MIN_MATCH = 3
    local MAX_MATCH = 18 -- 3 + 15 (4 bits)
    
    local i = 1
    local len = #input
    local byte = string.byte
    
    -- Optimization: Hash Chain for O(1) match finding
    local head = {}  -- Maps hash -> last position
    local chain = {} -- Maps position -> previous position with same hash
    
    local function add_to_dict(pos)
        if pos + 2 > len then return end
        -- Simple hash for 3 bytes: b1*65536 + b2*256 + b3
        local h = byte(input, pos) * 65536 + byte(input, pos + 1) * 256 + byte(input, pos + 2)
        local prev = head[h]
        head[h] = pos
        chain[pos] = prev -- Link back to previous occurrence
    end

    local last_progress = -1
    local MAX_CHAIN_CHECKS = 32 -- Limit search depth for speed
    
    while i <= len do
        local progress = math.floor((i / len) * 100)
        if progress > last_progress + 4 then
            last_progress = progress
            io.write(string.format("\r    Compressing: %d%%", progress))
            io.flush()
        end

        local best_match_dist = 0
        local best_match_len = 0
        
        -- Try to find match if we have at least 3 bytes left
        if i + 2 <= len then
            local h = byte(input, i) * 65536 + byte(input, i + 1) * 256 + byte(input, i + 2)
            local match_pos = head[h]
            local checks = 0
            
            -- Traverse the chain of matches
            while match_pos and checks < MAX_CHAIN_CHECKS do
                local dist = i - match_pos
                if dist <= WINDOW_SIZE then
                    -- We already know the first 3 bytes match because of the hash
                    local match_len = 3
                    while match_len < MAX_MATCH and (i + match_len <= len) do
                        if byte(input, match_pos + match_len) == byte(input, i + match_len) then
                            match_len = match_len + 1
                        else
                            break
                        end
                    end
                    
                    if match_len > best_match_len then
                        best_match_len = match_len
                        best_match_dist = dist
                        if best_match_len == MAX_MATCH then break end
                    end
                else
                    -- If we are out of window, older matches in the chain will also be out of window
                    -- (Since chain goes backwards in time)
                    break 
                end
                
                match_pos = chain[match_pos]
                checks = checks + 1
            end
        end
        
        if best_match_len >= MIN_MATCH then
            -- Write Match: Flag 1 (1 bit) + Dist (12 bits) + Len-3 (4 bits)
            write_bits(1, 1) 
            write_bits(best_match_dist, 12)
            write_bits(best_match_len - MIN_MATCH, 4)
            
            -- Update dictionary for the bytes we are skipping
            for k = 0, best_match_len - 1 do
                add_to_dict(i + k)
            end
            
            i = i + best_match_len
        else
            -- Write Literal: Flag 0 (1 bit) + Char (8 bits)
            write_bits(0, 1)
            write_bits(byte(input, i), 8)
            
            -- Update dictionary
            add_to_dict(i)
            
            i = i + 1
        end
    end
    
    -- Clear progress line
    io.write("\r    Compressing: Done!   \n")
    
    -- Flush bits
    if bit_cnt > 0 then
        -- Pad with zeros to 13 bits
        local v = bit_buf -- remaining bits are already in place, upper bits are 0
        local c1 = v % 92
        local c2 = math.floor(v / 92)
        table.insert(result, b92:sub(c1 + 1, c1 + 1) .. b92:sub(c2 + 1, c2 + 1))
    end

    return table.concat(result)
end

function Compression:get_decompressor(compressed_data)
    -- LZSS + Base92 Decompressor
    -- b: Base92 Alphabet
    -- d: Data string
    -- m: Base92 map
    -- o: Output table
    -- R: Read bits function
    -- B: Bit buffer
    -- N: Bit count
    -- P: Pointer
    
    local template = [[
local b="!#$%%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_abcdefghijklmnopqrstuvwxyz{|}~"
local d="%s"
local m={}for i=1,92 do m[string.sub(b,i,i)]=i-1 end
local S,C,T=string.sub,string.char,table.insert
local B,N,P=0,0,1
local function R(n)
local v=0
for i=0,n-1 do
if N==0 then
local c1=m[S(d,P,P)]
local c2=m[S(d,P+1,P+1)]
B=c1+(c2*92)
N=13
P=P+2
end
local bit=B%%2
B=(B-bit)/2
N=N-1
v=v+bit*(2^i)
end
return v
end
local o={}
while P<=#d or N>0 do
if R(1)==1 then
local dist=R(12)
local len=R(4)+3
local s=#o-dist+1
for i=0,len-1 do
o[#o+1]=o[s+i]
end
else
o[#o+1]=C(R(8))
end
if P>#d and N==0 then break end
end
return(loadstring or load)(table.concat(o))(...)
]]
    return string.format(template, compressed_data)
end

return Compression;

-- This Script is Part of the Moonstar Obfuscator by Aurologic
--
-- Compression.lua
--
-- This Script provides a Compression Step using LZW algorithm with Variable-Width Bit Packing,
-- Keyword Pre-seeding, and Dictionary Reset.

local Step = require("moonstar.step");
local logger = require("logger");

local Compression = Step:extend();
Compression.Description = "Compresses the script using LZSS, Huffman, BWT, and Base92";
Compression.Name = "Compression";

Compression.SettingsDescriptor = {
    Enabled = { type = "boolean", default = false },
    Bytecode = { type = "boolean", default = false },
    BWT = { type = "boolean", default = true },
    Huffman = { type = "boolean", default = true },
    Preseed = { type = "boolean", default = true },
}

local PRESEED_KEYWORDS = "localfunctionreturnendthenifelseelseif"

function Compression:init(settings)
end

-- BWT Encoding
local function bwt_encode(s)
    local n = #s
    if n == 0 then return "", 0 end
    
    local bytes = {}
    for i = 1, n do bytes[i] = string.byte(s, i) end
    
    local rotations = {}
    for i = 1, n do rotations[i] = i end
    
    table.sort(rotations, function(a, b)
        if a == b then return false end
        for i = 0, n - 1 do
            local ia = (a + i - 1) % n + 1
            local ib = (b + i - 1) % n + 1
            local va = bytes[ia]
            local vb = bytes[ib]
            if va ~= vb then return va < vb end
        end
        return a < b -- Stable sort
    end)
    
    local last_col = {}
    local primary = 0
    for i, r in ipairs(rotations) do
        local idx = r - 1
        if idx == 0 then idx = n end
        table.insert(last_col, string.char(bytes[idx]))
        if r == 1 then primary = i end
    end
    return table.concat(last_col), primary - 1
end

-- MTF Encoding
local function mtf_encode(s)
    local n = #s
    if n == 0 then return "" end

    local alphabet = {}
    for i = 0, 255 do alphabet[i+1] = i end

    local bytes = {}
    local byte = string.byte
    local char = string.char
    local t_insert = table.insert
    local t_remove = table.remove

    for i = 1, n do
        local b = byte(s, i)
        local index = 1
        -- Linear search is acceptable for 256 size and typical file sizes
        for j = 1, 256 do
            if alphabet[j] == b then
                index = j
                break
            end
        end

        bytes[i] = char(index - 1)

        if index > 1 then
            t_remove(alphabet, index)
            t_insert(alphabet, 1, b)
        end
    end
    return table.concat(bytes)
end

-- LZSS Compression
local function lzss_compress_tokens(input, use_preseed)
    local tokens = {}
    local WINDOW_SIZE = 4095
    local MIN_MATCH = 3
    local MAX_MATCH = 18
    local len = #input
    local byte = string.byte
    local head = {}
    local chain = {}
    
    local function add_to_dict(pos, b1, b2, b3)
        local h = b1 * 65536 + b2 * 256 + b3
        local prev = head[h]
        head[h] = pos
        chain[pos] = prev
    end
    
    local start_pos = 1
    if use_preseed then
        local kw = PRESEED_KEYWORDS
        local kw_len = #kw
        for k = 1, kw_len - 2 do
            local b1, b2, b3 = byte(kw, k), byte(kw, k+1), byte(kw, k+2)
            add_to_dict(k, b1, b2, b3)
        end
        start_pos = kw_len + 1
    end
    
    local idx = 1
    while idx <= len do
        local b1 = byte(input, idx)
        local best_match_len = 0
        local best_match_dist = 0
        
        if idx + 2 <= len then
            local b2 = byte(input, idx + 1)
            local b3 = byte(input, idx + 2)
            local h = b1 * 65536 + b2 * 256 + b3
            local match_pos = head[h]
            local checks = 0
            
            local virt_current = use_preseed and (idx + #PRESEED_KEYWORDS) or idx
            
            while match_pos and checks < 32 do
                local dist = virt_current - match_pos
                if dist <= WINDOW_SIZE then
                    local m_len = 0
                    while m_len < MAX_MATCH and (idx + m_len <= len) do
                        local in_char = byte(input, idx + m_len)
                        local m_virt = match_pos + m_len
                        local match_char
                        if use_preseed and m_virt <= #PRESEED_KEYWORDS then
                             match_char = byte(PRESEED_KEYWORDS, m_virt)
                        else
                             local mp = use_preseed and (m_virt - #PRESEED_KEYWORDS) or m_virt
                             match_char = byte(input, mp)
                        end
                        
                        if in_char == match_char then
                            m_len = m_len + 1
                        else
                            break
                        end
                    end
                    if m_len > best_match_len then
                        best_match_len = m_len
                        best_match_dist = dist
                        if best_match_len == MAX_MATCH then break end
                    end
                else
                    break
                end
                match_pos = chain[match_pos]
                checks = checks + 1
            end
        end
        
        if best_match_len >= MIN_MATCH then
            table.insert(tokens, { type = 1, dist = best_match_dist, len = best_match_len - MIN_MATCH })
            for k = 0, best_match_len - 1 do
                if idx + k + 2 <= len then
                   local p = idx + k
                   local v_p = use_preseed and (p + #PRESEED_KEYWORDS) or p
                   add_to_dict(v_p, byte(input, p), byte(input, p+1), byte(input, p+2))
                end
            end
            idx = idx + best_match_len
        else
            table.insert(tokens, { type = 0, val = b1 })
            local v_p = use_preseed and (idx + #PRESEED_KEYWORDS) or idx
            if idx + 2 <= len then
                add_to_dict(v_p, b1, byte(input, idx+1), byte(input, idx+2))
            end
            idx = idx + 1
        end
    end
    
    -- Append EOF Token (type 2)
    table.insert(tokens, { type = 2 })
    
    return tokens
end

-- Huffman Coding
local function huffman_encode(tokens)
    local counts = {}
    for i = 0, 256 do counts[i] = 0 end
    
    for _, t in ipairs(tokens) do
        if t.type == 0 then counts[t.val] = counts[t.val] + 1
        else counts[256] = counts[256] + 1 end -- Match (type 1) or EOF (type 2)
    end
    
    local nodes = {}
    for i = 0, 256 do
        if counts[i] > 0 then
            table.insert(nodes, { symbol = i, weight = counts[i], id = i })
        end
    end
    
    local next_id = 257
    while #nodes > 1 do
        table.sort(nodes, function(a,b)
            if a.weight == b.weight then return a.id < b.id end
            return a.weight < b.weight
        end)
        local left = table.remove(nodes, 1)
        local right = table.remove(nodes, 1)
        table.insert(nodes, { left = left, right = right, weight = left.weight + right.weight, id = next_id })
        next_id = next_id + 1
    end
    
    local root = nodes[1]
    local codes = {}
    local function traverse(node, code, len)
        if node.symbol then
            codes[node.symbol] = { code = code, len = len }
        else
            traverse(node.left, code * 2, len + 1)
            traverse(node.right, code * 2 + 1, len + 1)
        end
    end
    traverse(root, 0, 0)
    return codes, root
end

function Compression:run_compression(source, config)
    local processed = source
    local bwt_idx

    if config.BWT then
        processed, bwt_idx = bwt_encode(processed)
        processed = mtf_encode(processed)
    end

    local use_preseed = config.Preseed and not config.BWT
    local tokens = lzss_compress_tokens(processed, use_preseed)

    local bit_stream = {}
    local bit_buf = 0
    local bit_cnt = 0
    local function emit(val, n)
        for i = 0, n - 1 do
            local bit = math.floor(val / (2^i)) % 2
            bit_buf = bit_buf + bit * (2^bit_cnt)
            bit_cnt = bit_cnt + 1
            if bit_cnt == 13 then
                table.insert(bit_stream, bit_buf)
                bit_buf = 0
                bit_cnt = 0
            end
        end
    end
    
    local use_huffman = config.Huffman
    if use_huffman then
        local codes, root = huffman_encode(tokens)
        
        local function emit_tree(node)
            if node.symbol then
                emit(1, 1); emit(node.symbol, 9)
            else
                emit(0, 1); emit_tree(node.left); emit_tree(node.right)
            end
        end
        emit_tree(root)
        
        for _, t in ipairs(tokens) do
            local sym = (t.type == 0) and t.val or 256
            local c = codes[sym]
            for i = c.len - 1, 0, -1 do
                emit(math.floor(c.code / (2^i)) % 2, 1)
            end
            if t.type == 1 then
                emit(t.dist, 12); emit(t.len, 4)
            elseif t.type == 2 then
                -- EOF: Emit dist 0
                emit(0, 12)
            end
        end
    else
        for _, t in ipairs(tokens) do
            if t.type == 0 then
                emit(0, 1); emit(t.val, 8)
            elseif t.type == 1 then
                emit(1, 1); emit(t.dist, 12); emit(t.len, 4)
            elseif t.type == 2 then
                emit(1, 1); emit(0, 12) -- EOF
            end
        end
    end
    
    if bit_cnt > 0 then table.insert(bit_stream, bit_buf) end
    
    local b92 = "!#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    local res_str = {}
    for _, v in ipairs(bit_stream) do
        local c1 = v % 92
        local c2 = math.floor(v / 92)
        table.insert(res_str, b92:sub(c1+1, c1+1) .. b92:sub(c2+1, c2+1))
    end
    
    return self:get_decompressor(table.concat(res_str), config.BWT and bwt_idx or nil, use_huffman, use_preseed)
end

function Compression:apply(ast, pipeline)
    logger:info("Compressing Code ...");

    if pipeline.renameVariables then
        pipeline:renameVariables(ast)
    end

    local source
    if self.Bytecode then
        local src = pipeline:unparse(ast)
        local fn = loadstring(src)
        if fn then source = string.dump(fn) else source = src end
    else
        source = pipeline:unparse(ast)
    end
    if #source == 0 then return ast end

    local configs = {
        { BWT = true, Huffman = self.Huffman, Preseed = false },
        { BWT = false, Huffman = self.Huffman, Preseed = self.Preseed }
    }

    local best_code = nil
    local best_len = math.huge
    local best_config = nil

    for _, cfg in ipairs(configs) do
        local code = self:run_compression(source, cfg)
        if #code < best_len then
            best_len = #code
            best_code = code
            best_config = cfg
        end
    end

    logger:info("Best Compression: BWT=" .. tostring(best_config.BWT) .. " Size=" .. best_len)

    local new_ast = pipeline.parser:parse(best_code)
    ast.body = new_ast.body
    ast.globalScope = new_ast.globalScope
    return ast
end

function Compression:get_decompressor(payload, bwt_idx, use_huffman, use_preseed)
    local parts = {}
    table.insert(parts, 'local c="!#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"')
    table.insert(parts, 'local d="' .. payload .. '"')
    table.insert(parts, 'local T={}for i=1,92 do T[string.sub(c,i,i)]=i-1 end')
    table.insert(parts, 'local h,A,Q,J=string.sub,string.char,table.insert,table.concat')
    table.insert(parts, 'local B,N,P=0,0,1')
    table.insert(parts, 'local function R(n)local v=0 for i=0,n-1 do if N==0 then local c1=T[h(d,P,P)]local c2=T[h(d,P+1,P+1)]B=c1+c2*92 N=13 P=P+2 end local b=B%2 B=(B-b)/2 N=N-1 v=v+b*2^i end return v end')
    
    if use_huffman then
       table.insert(parts, 'local function D() if R(1)==1 then return R(9) end local l=D() local r=D() return {l,r} end local tr=D()')
    end
    
    table.insert(parts, 'local o={} local k="'..PRESEED_KEYWORDS..'"')
    if use_preseed then
        table.insert(parts, 'for i=1,#k do o[i]=h(k,i,i) end')
    end
    
    if use_huffman then
        table.insert(parts, 'while 1 do local n=tr while type(n)=="table" do n=n[R(1)+1] end')
        -- Match is 256. No more 257 check.
        table.insert(parts, 'if n==256 then local d=R(12) if d==0 then break end local l=R(4)+3 local s=#o-d+1 for i=0,l-1 do o[#o+1]=o[s+i] end')
        table.insert(parts, 'else o[#o+1]=A(n) end end')
    else
        table.insert(parts, 'while 1 do if R(1)==1 then local d=R(12) if d==0 then break end local l=R(4)+3 local s=#o-d+1 for i=0,l-1 do o[#o+1]=o[s+i] end else o[#o+1]=A(R(8)) end end')
    end
    
    local res_var = use_preseed and 'J(o,"",#k+1)' or 'J(o)'
    
    if bwt_idx then
        table.insert(parts, 'local S='..res_var)
        -- Inverse MTF
        table.insert(parts, 'local G={} for i=0,255 do G[i+1]=i end local K={} for i=1,#S do local x=S:byte(i) local v=G[x+1] K[i]=A(v) table.remove(G,x+1) table.insert(G,1,v) end S=J(K)')

        table.insert(parts, 'local L={} for i=1,#S do L[i]=S:byte(i) end local C={} for i=1,#L do local b=L[i] C[b]=(C[b]or 0)+1 end')
        table.insert(parts, 'local Z,t={},1 for i=0,255 do if C[i] then Z[i]=t t=t+C[i] C[i]=0 end end')
        table.insert(parts, 'local M={} for i=1,#L do local b=L[i] M[i]=Z[b]+C[b] C[b]=C[b]+1 end')
        table.insert(parts, 'local Y={} local p='..(bwt_idx+1)..' for i=#L,1,-1 do Y[i]=A(L[p]) p=M[p] end')
        res_var = 'J(Y)'
    end
    
    table.insert(parts, 'return(loadstring or load)('..res_var..')(...)')
    return table.concat(parts, " ")
end

return Compression;

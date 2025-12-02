-- This Script is Part of the Moonstar Obfuscator by Aurologic
--
-- Compression.lua
--
-- This Script provides a Compression Step using multiple algorithms:
-- - LZSS dictionary compression
-- - Huffman/Arithmetic entropy coding  
-- - BWT+MTF+RLE (bzip2-style) transform
-- - PPM (Prediction by Partial Matching) context modeling
-- - Base92 encoding
--
-- PPM uses order-0/1/2 context models to predict bytes based on previous bytes,
-- achieving excellent compression on structured text like Lua code.

local Step = require("moonstar.step");
local logger = require("logger");

local Compression = Step:extend();
Compression.Description = "Compresses the script using LZSS, Huffman/Arithmetic/PPM, BWT, and Base92";
Compression.Name = "Compression";

Compression.SettingsDescriptor = {
    Enabled = { type = "boolean", default = false },
    Bytecode = { type = "boolean", default = false },
    BWT = { type = "boolean", default = true },
    RLE = { type = "boolean", default = true },
    Huffman = { type = "boolean", default = false },
    ArithmeticCoding = { type = "boolean", default = true },
    PPM = { type = "boolean", default = true },
    PPMOrder = { type = "number", default = 2 },
    ParallelTests = { type = "number", default = 4 },
}

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

-- Zero Run-Length Encoding (RLE) - bzip2 style
-- Encodes runs of zeros using RUNA (symbol 0) and RUNB (symbol 1) in a bijective base-2 system
-- This is very effective after MTF since zeros are extremely common
local function zero_rle_encode(s)
    local n = #s
    if n == 0 then return "" end
    
    local output = {}
    local byte = string.byte
    local char = string.char
    local i = 1
    
    while i <= n do
        local b = byte(s, i)
        if b == 0 then
            -- Count consecutive zeros
            local run_len = 0
            while i <= n and byte(s, i) == 0 do
                run_len = run_len + 1
                i = i + 1
            end
            -- Encode run length using bijective base-2 (RUNA=0, RUNB=1)
            -- run_len 1 -> A, 2 -> B, 3 -> AA, 4 -> BA, 5 -> AB, 6 -> BB, 7 -> AAA, etc.
            -- Formula: (run_len + 1) in bijective base-2
            run_len = run_len + 1
            local rle_codes = {}
            while run_len > 0 do
                run_len = run_len - 1
                table.insert(rle_codes, 1, run_len % 2) -- 0 = RUNA, 1 = RUNB
                run_len = math.floor(run_len / 2)
            end
            for _, code in ipairs(rle_codes) do
                table.insert(output, char(code)) -- 0x00 = RUNA, 0x01 = RUNB
            end
        else
            -- Non-zero byte: shift by 1 to make room for RUNA/RUNB symbols
            table.insert(output, char(b + 1))
            i = i + 1
        end
    end
    
    return table.concat(output)
end

-- Zero Run-Length Decoding
local function zero_rle_decode(s)
    local n = #s
    if n == 0 then return "" end
    
    local output = {}
    local byte = string.byte
    local char = string.char
    local i = 1
    
    while i <= n do
        local b = byte(s, i)
        if b == 0 or b == 1 then
            -- Decode RUNA/RUNB sequence
            local run_len = 0
            local power = 1
            while i <= n and (byte(s, i) == 0 or byte(s, i) == 1) do
                local sym = byte(s, i)
                run_len = run_len + (sym + 1) * power
                power = power * 2
                i = i + 1
            end
            -- Output run_len zeros
            for _ = 1, run_len do
                table.insert(output, char(0))
            end
        else
            -- Non-zero: shift back by 1
            table.insert(output, char(b - 1))
            i = i + 1
        end
    end
    
    return table.concat(output)
end

-- LZSS Compression
local function lzss_compress_tokens(input)
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
            
            while match_pos and checks < 32 do
                local dist = idx - match_pos
                if dist <= WINDOW_SIZE then
                    local m_len = 0
                    while m_len < MAX_MATCH and (idx + m_len <= len) do
                        local in_char = byte(input, idx + m_len)
                        local match_char = byte(input, match_pos + m_len)
                        
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
                   add_to_dict(p, byte(input, p), byte(input, p+1), byte(input, p+2))
                end
            end
            idx = idx + best_match_len
        else
            table.insert(tokens, { type = 0, val = b1 })
            if idx + 2 <= len then
                add_to_dict(idx, b1, byte(input, idx+1), byte(input, idx+2))
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

-- Arithmetic Coding
local ARITH_PRECISION = 32
local ARITH_FULL = 2^ARITH_PRECISION
local ARITH_HALF = 2^(ARITH_PRECISION - 1)
local ARITH_QUARTER = 2^(ARITH_PRECISION - 2)

local function arithmetic_encode(tokens)
    -- Build frequency table (0-255 for literals, 256 for match/EOF)
    local counts = {}
    local total = 0
    for i = 0, 256 do counts[i] = 1 end -- Start with 1 for smoothing
    total = 257
    
    for _, t in ipairs(tokens) do
        if t.type == 0 then 
            counts[t.val] = counts[t.val] + 1
        else 
            counts[256] = counts[256] + 1
        end
        total = total + 1
    end
    
    -- Build cumulative frequency table
    local cum_freq = {}
    cum_freq[0] = 0
    for i = 0, 256 do
        cum_freq[i + 1] = cum_freq[i] + counts[i]
    end
    
    -- Encode
    local low = 0
    local high = ARITH_FULL - 1
    local pending_bits = 0
    local output_bits = {}
    
    local function output_bit(bit)
        table.insert(output_bits, bit)
        while pending_bits > 0 do
            table.insert(output_bits, 1 - bit)
            pending_bits = pending_bits - 1
        end
    end
    
    for _, t in ipairs(tokens) do
        local sym = (t.type == 0) and t.val or 256
        local range = high - low + 1
        high = low + math.floor(range * cum_freq[sym + 1] / total) - 1
        low = low + math.floor(range * cum_freq[sym] / total)
        
        while true do
            if high < ARITH_HALF then
                output_bit(0)
                low = low * 2
                high = high * 2 + 1
            elseif low >= ARITH_HALF then
                output_bit(1)
                low = (low - ARITH_HALF) * 2
                high = (high - ARITH_HALF) * 2 + 1
            elseif low >= ARITH_QUARTER and high < 3 * ARITH_QUARTER then
                pending_bits = pending_bits + 1
                low = (low - ARITH_QUARTER) * 2
                high = (high - ARITH_QUARTER) * 2 + 1
            else
                break
            end
        end
    end
    
    -- Flush remaining bits
    pending_bits = pending_bits + 1
    if low < ARITH_QUARTER then
        output_bit(0)
    else
        output_bit(1)
    end
    
    return output_bits, counts, total
end

-- PPM (Prediction by Partial Matching) Context Model
-- Uses order-0, order-1, and order-2 contexts with escape mechanism
local function ppm_encode(input, max_order)
    local n = #input
    if n == 0 then return {}, {}, 0 end
    
    local byte = string.byte
    max_order = max_order or 2
    
    -- Context tables: ctx[order][context_key] = {counts = {}, total = 0, esc = 0}
    local ctx = {}
    for order = 0, max_order do
        ctx[order] = {}
    end
    
    -- Order-0 is special - just global counts
    ctx[0][""] = { counts = {}, total = 0, esc = 0 }
    for i = 0, 256 do ctx[0][""].counts[i] = 0 end -- 256 = escape
    
    local output_syms = {} -- {sym, low, high, total} for arithmetic coding
    
    -- Get context key for given order at position
    local function get_context(pos, order)
        if order == 0 then return "" end
        if pos <= order then return nil end
        local key = {}
        for i = order, 1, -1 do
            key[#key + 1] = byte(input, pos - i)
        end
        return table.concat(key, ",")
    end
    
    -- Initialize context if needed
    local function ensure_context(order, key)
        if not ctx[order][key] then
            ctx[order][key] = { counts = {}, total = 0, esc = 0 }
            for i = 0, 256 do ctx[order][key].counts[i] = 0 end
        end
    end
    
    -- Encode with exclusion
    local function encode_symbol(pos, sym)
        local excluded = {}
        
        for order = max_order, 0, -1 do
            local key = get_context(pos, order)
            if key then
                ensure_context(order, key)
                local c = ctx[order][key]
                
                -- Calculate total excluding already-excluded symbols
                local adj_total = c.total
                local adj_count = c.counts[sym] or 0
                for ex, _ in pairs(excluded) do
                    adj_total = adj_total - (c.counts[ex] or 0)
                    if ex == sym then adj_count = 0 end
                end
                
                -- Add escape probability (for novel symbols)
                local esc_count = c.esc + 1
                adj_total = adj_total + esc_count
                
                if adj_count > 0 then
                    -- Symbol found in this context
                    local low = 0
                    for i = 0, sym - 1 do
                        if not excluded[i] then
                            low = low + (c.counts[i] or 0)
                        end
                    end
                    table.insert(output_syms, {
                        low = low,
                        high = low + adj_count,
                        total = adj_total,
                        order = order
                    })
                    
                    -- Update counts
                    c.counts[sym] = (c.counts[sym] or 0) + 1
                    c.total = c.total + 1
                    return
                else
                    -- Escape to lower order
                    local esc_low = adj_total - esc_count
                    table.insert(output_syms, {
                        low = esc_low,
                        high = adj_total,
                        total = adj_total,
                        order = order,
                        escape = true
                    })
                    
                    -- Mark seen symbols as excluded
                    for i = 0, 255 do
                        if c.counts[i] and c.counts[i] > 0 then
                            excluded[i] = true
                        end
                    end
                    
                    -- Update escape count
                    c.esc = c.esc + 1
                end
            end
        end
        
        -- Fallback: uniform distribution for completely novel symbol
        local num_remaining = 256
        for _ in pairs(excluded) do num_remaining = num_remaining - 1 end
        local idx = 0
        for i = 0, sym - 1 do
            if not excluded[i] then idx = idx + 1 end
        end
        table.insert(output_syms, {
            low = idx,
            high = idx + 1,
            total = num_remaining,
            order = -1
        })
        
        -- Update order-0
        local c = ctx[0][""]
        c.counts[sym] = (c.counts[sym] or 0) + 1
        c.total = c.total + 1
    end
    
    -- Update all context levels after encoding a symbol
    local function update_contexts(pos, sym)
        for order = 1, max_order do
            local key = get_context(pos, order)
            if key then
                ensure_context(order, key)
                local c = ctx[order][key]
                c.counts[sym] = (c.counts[sym] or 0) + 1
                c.total = c.total + 1
            end
        end
    end
    
    -- Encode all symbols
    for i = 1, n do
        local sym = byte(input, i)
        encode_symbol(i, sym)
        update_contexts(i, sym)
    end
    
    -- Add EOF
    encode_symbol(n + 1, 256)
    
    return output_syms, ctx, max_order
end

-- PPM Arithmetic encoder - converts symbols to bits
local function ppm_to_bits(output_syms)
    local PRECISION = 32
    local FULL = 2^PRECISION
    local HALF = 2^(PRECISION - 1)
    local QUARTER = 2^(PRECISION - 2)
    
    local low = 0
    local high = FULL - 1
    local pending = 0
    local bits = {}
    
    local function output_bit(bit)
        table.insert(bits, bit)
        while pending > 0 do
            table.insert(bits, 1 - bit)
            pending = pending - 1
        end
    end
    
    for _, sym in ipairs(output_syms) do
        local range = high - low + 1
        high = low + math.floor(range * sym.high / sym.total) - 1
        low = low + math.floor(range * sym.low / sym.total)
        
        while true do
            if high < HALF then
                output_bit(0)
                low = low * 2
                high = high * 2 + 1
            elseif low >= HALF then
                output_bit(1)
                low = (low - HALF) * 2
                high = (high - HALF) * 2 + 1
            elseif low >= QUARTER and high < 3 * QUARTER then
                pending = pending + 1
                low = (low - QUARTER) * 2
                high = (high - QUARTER) * 2 + 1
            else
                break
            end
        end
    end
    
    pending = pending + 1
    if low < QUARTER then
        output_bit(0)
    else
        output_bit(1)
    end
    
    return bits
end

function Compression:run_compression(source, config)
    local processed = source
    local bwt_idx
    local use_ppm = config.PPM and not config.BWT  -- PPM works best on raw text, not BWT output

    if config.BWT then
        processed, bwt_idx = bwt_encode(processed)
        processed = mtf_encode(processed)
        if config.RLE then
            processed = zero_rle_encode(processed)
        end
    end

    -- PPM mode: directly compress without LZSS (PPM handles redundancy)
    if use_ppm then
        local ppm_order = config.PPMOrder or 2
        local output_syms = ppm_encode(processed, ppm_order)
        local ppm_bits = ppm_to_bits(output_syms)
        
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
        
        -- Emit PPM order
        emit(ppm_order, 4)
        
        -- Emit number of bits
        local num_bits = #ppm_bits
        emit(num_bits % 65536, 16)
        emit(math.floor(num_bits / 65536), 16)
        
        -- Emit all bits
        for _, b in ipairs(ppm_bits) do
            emit(b, 1)
        end
        
        if bit_cnt > 0 then table.insert(bit_stream, bit_buf) end
        
        local b92 = "!#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"
        local res_str = {}
        for _, v in ipairs(bit_stream) do
            local c1 = v % 92
            local c2 = math.floor(v / 92)
            table.insert(res_str, b92:sub(c1+1, c1+1) .. b92:sub(c2+1, c2+1))
        end
        
        return self:get_decompressor_ppm(table.concat(res_str), ppm_order)
    end
    
    local tokens = lzss_compress_tokens(processed)

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
    local use_arithmetic = config.ArithmeticCoding
    
    if use_arithmetic then
        -- Arithmetic coding mode
        local arith_bits, counts, total = arithmetic_encode(tokens)
        
        -- Emit frequency table (257 counts, each as 16-bit value)
        for i = 0, 256 do
            emit(counts[i], 16)
        end
        
        -- Emit total count (32-bit)
        emit(total % 65536, 16)
        emit(math.floor(total / 65536), 16)
        
        -- Emit number of arithmetic bits (32-bit)
        local num_bits = #arith_bits
        emit(num_bits % 65536, 16)
        emit(math.floor(num_bits / 65536), 16)
        
        -- Emit arithmetic coded bits
        for _, b in ipairs(arith_bits) do
            emit(b, 1)
        end
        
        -- Emit match/EOF data separately
        for _, t in ipairs(tokens) do
            if t.type == 1 then
                emit(t.dist, 12); emit(t.len, 4)
            elseif t.type == 2 then
                emit(0, 12) -- EOF marker
            end
        end
    elseif use_huffman then
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
    
    return self:get_decompressor(table.concat(res_str), config.BWT and bwt_idx or nil, use_huffman, use_arithmetic, config.RLE)
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
        { BWT = true, RLE = self.RLE, Huffman = false, ArithmeticCoding = self.ArithmeticCoding, PPM = false },
        { BWT = true, RLE = self.RLE, Huffman = self.Huffman, ArithmeticCoding = false, PPM = false },
        { BWT = true, RLE = false, Huffman = false, ArithmeticCoding = self.ArithmeticCoding, PPM = false },
        { BWT = false, RLE = false, Huffman = false, ArithmeticCoding = self.ArithmeticCoding, PPM = false },
        { BWT = false, RLE = false, Huffman = self.Huffman, ArithmeticCoding = false, PPM = false },
        -- PPM configurations (works on raw source, no BWT)
        { BWT = false, RLE = false, Huffman = false, ArithmeticCoding = false, PPM = self.PPM, PPMOrder = 2 },
        { BWT = false, RLE = false, Huffman = false, ArithmeticCoding = false, PPM = self.PPM, PPMOrder = 1 },
    }

    -- Filter valid configs
    local valid_configs = {}
    for _, cfg in ipairs(configs) do
        if cfg.Huffman or cfg.ArithmeticCoding or cfg.PPM or (not cfg.Huffman and not cfg.ArithmeticCoding and not cfg.PPM) then
            table.insert(valid_configs, cfg)
        end
    end

    local parallel_count = self.ParallelTests or 4
    local results = {}
    local coroutines = {}
    
    -- Create coroutines for parallel compression testing
    for i, cfg in ipairs(valid_configs) do
        coroutines[i] = coroutine.create(function()
            local ok, code = pcall(function() return self:run_compression(source, cfg) end)
            if ok and code then
                return { code = code, len = #code, config = cfg }
            end
            return nil
        end)
    end
    
    -- Run coroutines in batches of parallel_count
    local idx = 1
    while idx <= #coroutines do
        local batch_end = math.min(idx + parallel_count - 1, #coroutines)
        
        -- Resume batch
        for i = idx, batch_end do
            if coroutines[i] and coroutine.status(coroutines[i]) == "suspended" then
                local ok, result = coroutine.resume(coroutines[i])
                if ok and result then
                    results[i] = result
                end
            end
        end
        
        idx = batch_end + 1
    end
    
    -- Find best result
    local best_code = nil
    local best_len = math.huge
    local best_config = nil
    
    for _, result in pairs(results) do
        if result and result.len < best_len then
            best_len = result.len
            best_code = result.code
            best_config = result.config
        end
    end
    
    if not best_config then
        -- Fallback to first valid config
        best_config = valid_configs[1]
        best_code = self:run_compression(source, best_config)
        best_len = #best_code
    end

    local method = best_config.PPM and ("PPM-" .. (best_config.PPMOrder or 2)) or 
                   (best_config.ArithmeticCoding and "Arithmetic" or (best_config.Huffman and "Huffman" or "Raw"))
    local rle_str = best_config.RLE and "+RLE" or ""
    logger:info("Best Compression: BWT=" .. tostring(best_config.BWT) .. rle_str .. " Method=" .. method .. " Size=" .. best_len .. " (tested " .. #valid_configs .. " configs)")

    local new_ast = pipeline.parser:parse(best_code)
    ast.body = new_ast.body
    ast.globalScope = new_ast.globalScope
    return ast
end

function Compression:get_decompressor(payload, bwt_idx, use_huffman, use_arithmetic, use_rle)
    local parts = {}
    -- Optimized: pre-built lookup table as numeric array indexed by byte value
    table.insert(parts, 'local T={}')
    table.insert(parts, 'local c="!#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"')
    table.insert(parts, 'for i=1,92 do T[c:byte(i)]=i-1 end')
    table.insert(parts, 'local d="' .. payload .. '"')
    -- Optimized: use string.byte directly, cache math functions locally
    table.insert(parts, 'local sb,A,J,fl=string.byte,string.char,table.concat,math.floor')
    table.insert(parts, 'local B,N,P=0,0,1')
    -- Optimized bit reader: uses multiplication instead of 2^i, avoids repeated function calls
    table.insert(parts, 'local function R(n)local v,m=0,1 for _=1,n do if N==0 then B=T[sb(d,P)]+T[sb(d,P+1)]*92 N=13 P=P+2 end v=v+(B%2)*m B=fl(B/2) N=N-1 m=m*2 end return v end')
    
    if use_arithmetic then
        -- Arithmetic decoder with binary search optimization
        table.insert(parts, 'local F={} for i=0,256 do F[i]=R(16) end')
        table.insert(parts, 'local W=R(16)+R(16)*65536')
        table.insert(parts, 'local nb=R(16)+R(16)*65536')
        table.insert(parts, 'local cf={} cf[0]=0 for i=0,256 do cf[i+1]=cf[i]+F[i] end')
        -- Optimized: read bits in chunks where possible
        table.insert(parts, 'local ab={} for i=1,nb do ab[i]=R(1) end local ai=1')
        table.insert(parts, 'local AF,AH,AQ=4294967296,2147483648,1073741824')
        table.insert(parts, 'local al,ah=0,AF-1 local av=0 for i=1,32 do av=av*2+(ab[ai]or 0) ai=ai+1 end')
        -- Optimized: binary search for symbol lookup instead of linear O(257) scan
        table.insert(parts, [[local function AD()
local r=ah-al+1
local sv=fl(((av-al+1)*W-1)/r)
local lo,hi,sym=0,257,0
while lo<hi do local mid=fl((lo+hi)/2) if cf[mid]<=sv then lo=mid+1 else hi=mid end end
sym=lo-1
ah=al+fl(r*cf[sym+1]/W)-1 al=al+fl(r*cf[sym]/W)
while true do if ah<AH then al=al*2 ah=ah*2+1 av=av*2+(ab[ai]or 0) ai=ai+1
elseif al>=AH then al=(al-AH)*2 ah=(ah-AH)*2+1 av=(av-AH)*2+(ab[ai]or 0) ai=ai+1
elseif al>=AQ and ah<3*AQ then al=(al-AQ)*2 ah=(ah-AQ)*2+1 av=(av-AQ)*2+(ab[ai]or 0) ai=ai+1
else break end end return sym end]])
    elseif use_huffman then
       table.insert(parts, 'local function D() if R(1)==1 then return R(9) end local l=D() local r=D() return {l,r} end local tr=D()')
    end
    
    table.insert(parts, 'local o={} local oc=0')
    
    -- Optimized main loop: track count explicitly to avoid #o overhead
    if use_arithmetic then
        table.insert(parts, 'while 1 do local n=AD()')
        table.insert(parts, 'if n==256 then local dt=R(12) if dt==0 then break end local l=R(4)+3 local s=oc-dt+1 for i=0,l-1 do oc=oc+1 o[oc]=o[s+i] end')
        table.insert(parts, 'else oc=oc+1 o[oc]=A(n) end end')
    elseif use_huffman then
        table.insert(parts, 'while 1 do local n=tr while type(n)=="table" do n=n[R(1)+1] end')
        table.insert(parts, 'if n==256 then local dt=R(12) if dt==0 then break end local l=R(4)+3 local s=oc-dt+1 for i=0,l-1 do oc=oc+1 o[oc]=o[s+i] end')
        table.insert(parts, 'else oc=oc+1 o[oc]=A(n) end end')
    else
        table.insert(parts, 'while 1 do if R(1)==1 then local dt=R(12) if dt==0 then break end local l=R(4)+3 local s=oc-dt+1 for i=0,l-1 do oc=oc+1 o[oc]=o[s+i] end else oc=oc+1 o[oc]=A(R(8)) end end')
    end
    
    local res_var = 'J(o)'
    
    if bwt_idx then
        table.insert(parts, 'local S='..res_var)
        
        -- Optimized Inverse Zero RLE
        if use_rle then
            table.insert(parts, 'local E={} local ei=0 local si=1 local sn=#S while si<=sn do local b=sb(S,si) if b<2 then local rl,pw=0,1 while si<=sn do local bb=sb(S,si) if bb>1 then break end rl=rl+(bb+1)*pw pw=pw*2 si=si+1 end local z=A(0) for _=1,rl do ei=ei+1 E[ei]=z end else ei=ei+1 E[ei]=A(b-1) si=si+1 end end S=J(E)')
        end
        
        -- Optimized Inverse MTF: avoid table.remove/insert with direct swap approach
        table.insert(parts, 'local G={} for i=0,255 do G[i+1]=i end local K={} local sn=#S for i=1,sn do local x=sb(S,i)+1 local v=G[x] K[i]=A(v) if x>1 then for j=x,2,-1 do G[j]=G[j-1] end G[1]=v end end S=J(K)')

        -- Optimized BWT inverse: use single-pass byte extraction
        table.insert(parts, 'local sn=#S local L={} for i=1,sn do L[i]=sb(S,i) end')
        table.insert(parts, 'local C={} for i=0,255 do C[i]=0 end for i=1,sn do local b=L[i] C[b]=C[b]+1 end')
        table.insert(parts, 'local Z,t={},1 for i=0,255 do Z[i]=t t=t+C[i] C[i]=0 end')
        table.insert(parts, 'local M={} for i=1,sn do local b=L[i] M[i]=Z[b]+C[b] C[b]=C[b]+1 end')
        table.insert(parts, 'local Y={} local p='..(bwt_idx+1)..' for i=sn,1,-1 do Y[i]=A(L[p]) p=M[p] end')
        res_var = 'J(Y)'
    end
    
    table.insert(parts, 'return(loadstring or load)('..res_var..')(...)')
    return table.concat(parts, " ")
end

-- PPM Decompressor generator (optimized)
function Compression:get_decompressor_ppm(payload, ppm_order)
    local parts = {}
    -- Optimized: byte-indexed lookup table
    table.insert(parts, 'local T={}')
    table.insert(parts, 'local c="!#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"')
    table.insert(parts, 'for i=1,92 do T[c:byte(i)]=i-1 end')
    table.insert(parts, 'local d="' .. payload .. '"')
    -- Optimized: localize all functions, use string.byte directly
    table.insert(parts, 'local sb,A,J,fl=string.byte,string.char,table.concat,math.floor')
    table.insert(parts, 'local B,N,P=0,0,1')
    -- Optimized bit reader with multiplication
    table.insert(parts, 'local function R(n)local v,m=0,1 for _=1,n do if N==0 then B=T[sb(d,P)]+T[sb(d,P+1)]*92 N=13 P=P+2 end v=v+(B%2)*m B=fl(B/2) N=N-1 m=m*2 end return v end')
    
    -- Read PPM order and bit count
    table.insert(parts, 'local MO=R(4)')
    table.insert(parts, 'local nb=R(16)+R(16)*65536')
    
    -- Read all bits into buffer
    table.insert(parts, 'local ab={} for i=1,nb do ab[i]=R(1) end local ai=1')
    
    -- Arithmetic decoder state - use numeric literals for speed
    table.insert(parts, 'local AF,AH,AQ=4294967296,2147483648,1073741824')
    table.insert(parts, 'local TQ=3*AQ')
    table.insert(parts, 'local al,ah=0,AF-1 local av=0 for i=1,32 do av=av*2+(ab[ai]or 0) ai=ai+1 end')
    
    -- Context tables
    table.insert(parts, 'local ctx={} for o=0,MO do ctx[o]={} end')
    table.insert(parts, 'local c0={}for i=0,256 do c0[i]=0 end c0.t=0 c0.e=0 ctx[0][""]=c0')
    
    -- Optimized: pre-allocate empty context template, inline context key building
    table.insert(parts, 'local function gk(out,pos,ord) if ord==0 then return "" end if pos<=ord then return nil end if ord==1 then return sb(out[pos-1],1) end if ord==2 then return sb(out[pos-2],1)*256+sb(out[pos-1],1) end local k={} for i=ord,1,-1 do k[#k+1]=sb(out[pos-i],1) end return J(k,",") end')
    
    -- Optimized ensure context: lazy initialization only when needed
    table.insert(parts, 'local function ec(ord,key) if not ctx[ord][key] then local nc={} for i=0,256 do nc[i]=0 end nc.t=0 nc.e=0 ctx[ord][key]=nc end end')
    
    -- Optimized normalize function to reduce code duplication
    table.insert(parts, [[local function norm()
while true do
if ah<AH then al=al*2 ah=ah*2+1 av=av*2+(ab[ai]or 0) ai=ai+1
elseif al>=AH then al=(al-AH)*2 ah=(ah-AH)*2+1 av=(av-AH)*2+(ab[ai]or 0) ai=ai+1
elseif al>=AQ and ah<TQ then al=(al-AQ)*2 ah=(ah-AQ)*2+1 av=(av-AQ)*2+(ab[ai]or 0) ai=ai+1
else break end end end]])
    
    -- Optimized decode function: reduced pairs() usage, faster exclusion tracking
    table.insert(parts, [[local function decode(out,pos)
local ex,exc={},0
for ord=MO,0,-1 do
local key=gk(out,pos,ord)
if key then
ec(ord,key)
local ct=ctx[ord][key]
local at=ct.t local ec_cnt=ct.e+1
for i=0,256 do if ex[i] then at=at-(ct[i]or 0) end end
at=at+ec_cnt
if at>0 then
local r=ah-al+1
local sv=fl(((av-al+1)*at-1)/r)
local cum,sym,sc=0,nil,0
for i=0,256 do
if not ex[i] then
local cnt=ct[i]or 0
if cum+cnt>sv then sym=i sc=cnt break end
cum=cum+cnt
end
end
if not sym then
sym=256 sc=ec_cnt
for i=0,255 do if not ex[i] and (ct[i]or 0)==0 then ex[i]=true exc=exc+1 end end
ct.e=ct.e+1
ah=al+fl(r*(cum+sc)/at)-1
al=al+fl(r*cum/at)
norm()
else
ah=al+fl(r*(cum+sc)/at)-1
al=al+fl(r*cum/at)
norm()
ct[sym]=(ct[sym]or 0)+1 ct.t=ct.t+1
return sym
end
end
end
end
local nr=256-exc
local r=ah-al+1
local sv=fl(((av-al+1)*nr-1)/r)
local idx,sym=0,0
for i=0,255 do if not ex[i] then if idx==sv then sym=i break end idx=idx+1 end end
ah=al+fl(r*(idx+1)/nr)-1
al=al+fl(r*idx/nr)
norm()
local cc=ctx[0][""]cc[sym]=(cc[sym]or 0)+1 cc.t=cc.t+1
return sym
end]])
    
    -- Optimized update contexts
    table.insert(parts, 'local function upd(out,pos,sym) for ord=1,MO do local key=gk(out,pos,ord) if key then ec(ord,key) local ct=ctx[ord][key] ct[sym]=(ct[sym]or 0)+1 ct.t=ct.t+1 end end end')
    
    -- Main decode loop
    table.insert(parts, 'local o={} local pos=1 while true do local sym=decode(o,pos) if sym==256 then break end o[pos]=A(sym) upd(o,pos,sym) pos=pos+1 end')
    
    table.insert(parts, 'return(loadstring or load)(J(o))(...)')
    return table.concat(parts, " ")
end

return Compression;

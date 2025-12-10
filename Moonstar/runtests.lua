-- runtests.lua - AI-Agent Optimized Test Runner
-- Output format: Concise, structured, machine-readable
-- Results saved to tests.txt to avoid Moonstar's verbose console output

package.path = "moonstar/src/?.lua;" .. package.path

local moonstar = require("moonstar")
local Pipeline = moonstar.Pipeline
local Presets = moonstar.Presets

-- Output buffer (writes to file at end, also prints to console)
local output_lines = {}
local function log(text)
    text = text or ""
    table.insert(output_lines, text)
    print(text)  -- Also show in console
end

local function save_output()
    local f = io.open("tests.txt", "w")
    if f then
        f:write(table.concat(output_lines, "\n"))
        f:close()
        print("[TESTS] Results saved to tests.txt")
    else
        print("[ERROR] Could not write to tests.txt")
    end
end

-- Deep Copy Helper
local function deepCopy(value, cache)
    if type(value) ~= "table" then return value end
    cache = cache or {}
    if cache[value] then return cache[value] end
    local copy = {}
    cache[value] = copy
    for k, v in pairs(value) do
        copy[deepCopy(k, cache)] = deepCopy(v, cache)
    end
    return copy
end

-- Parse Arguments
local target_preset = nil
local compression_mode = nil  -- nil, "default", "balanced", or "fast"
local file_filter = nil
local parallel_tests = 4
local verbose = false

for i = 1, #arg do
    local a = arg[i]
    if a:match("^--preset=") then
        target_preset = a:match("^--preset=(.+)$")
    elseif a == "--compress" then
        compression_mode = "default"
    elseif a == "--compress-balanced" then
        compression_mode = "balanced"
    elseif a == "--compress-fast" then
        compression_mode = "fast"
    elseif a == "--verbose" or a == "-v" then
        verbose = true
    elseif a:match("^--parallel=") then
        parallel_tests = tonumber(a:match("^--parallel=(.+)$")) or 4
    elseif not a:match("^-") then
        file_filter = a
    end
end

-- Helper to run command and get output
local function run_command(cmd)
    local handle = io.popen(cmd)
    if not handle then return "", "popen failed" end
    local result = handle:read("*a")
    handle:close()
    return result or ""
end

-- Helper to list test files
local function get_test_files()
    local files = {}
    local separator = package.config:sub(1,1)
    local cmd
    if separator == '\\' then
        cmd = 'dir /s /b "tests\\*.lua" "tests\\*.luau"'
    else
        cmd = 'find tests -type f \\( -name "*.lua" -o -name "*.luau" \\)'
    end
    
    local handle = io.popen(cmd)
    if handle then
        for line in handle:lines() do
            line = line:gsub("^%s*(.-)%s*$", "%1")
            line = line:gsub("\\", "/")
            if line ~= "" and not line:match("^tests/setup/") then
                table.insert(files, line)
            end
        end
        handle:close()
    end
    return files
end

-- Helper to run lua code
local function run_lua_code(code)
    local tmp_file = "temp_test_exec.lua"
    local f = io.open(tmp_file, "w")
    if not f then return nil, "Could not open temp file" end
    f:write(code)
    f:close()
    local output = run_command("lua5.1 " .. tmp_file .. " 2>&1")
    os.remove(tmp_file)
    return output
end

-- Load emulator
local AURORA_EMULATOR_PATH = "tests/setup/aurora.lua"
local aurora_emulator_code = nil
local f = io.open(AURORA_EMULATOR_PATH, "r")
if f then
    aurora_emulator_code = f:read("*a")
    f:close()
end

-- Results tracking
local results = {
    passed = {},
    failed = {},
    errors = {},
    skipped = {}
}

local function short_name(path)
    return path:match("([^/]+)$") or path
end

local function run_single_test(file_path, pipeline, preset_name)
    local test_id = preset_name .. ":" .. short_name(file_path)
    
    local f = io.open(file_path, "r")
    if not f then
        table.insert(results.errors, {id = test_id, reason = "file_not_found"})
        return "error"
    end
    local original_code = f:read("*a")
    f:close()

    local code_to_run = original_code
    if file_path:match("%.luau$") then
        if not aurora_emulator_code then
            table.insert(results.skipped, {id = test_id, reason = "no_emulator"})
            return "skip"
        end
        code_to_run = aurora_emulator_code .. "\n" .. original_code
    end

    -- Run original
    local expected_output = run_lua_code(code_to_run)

    -- Obfuscate
    local status, obfuscated_code = pcall(function()
        return pipeline:apply(original_code, file_path)
    end)

    if not status then
        local err_msg = tostring(obfuscated_code):sub(1, 100)
        table.insert(results.failed, {
            id = test_id,
            stage = "obfuscation",
            error = err_msg
        })
        return "fail"
    end

    -- Run obfuscated
    local obfuscated_code_to_run = obfuscated_code
    if file_path:match("%.luau$") and aurora_emulator_code then
        obfuscated_code_to_run = aurora_emulator_code .. "\n" .. obfuscated_code
    end
    local actual_output = run_lua_code(obfuscated_code_to_run)

    -- Compare
    local expected_clean = expected_output:gsub("%s+$", ""):gsub("\r\n", "\n")
    local actual_clean = actual_output:gsub("%s+$", ""):gsub("\r\n", "\n")

    if expected_clean == actual_clean then
        table.insert(results.passed, test_id)
        return "pass"
    else
        -- Save failed code
        local f_fail = io.open("failed_code.lua", "w")
        if f_fail then
            f_fail:write(obfuscated_code)
            f_fail:close()
        end
        
        -- Truncate outputs for readability
        local exp_short = expected_clean:sub(1, 80):gsub("\n", "\\n")
        local act_short = actual_clean:sub(1, 80):gsub("\n", "\\n")
        
        table.insert(results.failed, {
            id = test_id,
            stage = "output_mismatch",
            expected = exp_short,
            actual = act_short
        })
        return "fail"
    end
end

-- Get test files and presets
local test_files = get_test_files()
table.sort(test_files)

local preset_names = {}
for name, _ in pairs(Presets) do
    table.insert(preset_names, name)
end
table.sort(preset_names)

-- Header
log("=== MOONSTAR TEST RUN ===")
log(string.format("Files: %d | Presets: %s | Filter: %s", 
    #test_files,
    target_preset or "all",
    file_filter or "none"
))
log("")

-- Run tests
local total = 0
for _, preset_name in ipairs(preset_names) do
    if not target_preset or target_preset == preset_name then
        local preset_config = deepCopy(Presets[preset_name])

        if compression_mode then
            if compression_mode == "fast" then
                -- Fast: Only RLE + Huffman (fastest, lower ratio)
                preset_config.Compression = {
                    Enabled = true,
                    BWT = false,
                    RLE = true,
                    Huffman = true,
                    ArithmeticCoding = false,
                    PPM = false,
                    PPMOrder = 0,
                    Preseed = false,
                    ParallelTests = parallel_tests
                }
            elseif compression_mode == "balanced" then
                -- Balanced: BWT + RLE + Huffman (good balance)
                preset_config.Compression = {
                    Enabled = true,
                    BWT = true,
                    RLE = true,
                    Huffman = true,
                    ArithmeticCoding = false,
                    PPM = false,
                    PPMOrder = 0,
                    Preseed = true,
                    ParallelTests = parallel_tests
                }
            else
                -- Default (--compress): All algorithms (best ratio, slowest)
                preset_config.Compression = {
                    Enabled = true,
                    BWT = true,
                    RLE = true,
                    Huffman = true,
                    ArithmeticCoding = true,
                    PPM = true,
                    PPMOrder = 2,
                    Preseed = true,
                    ParallelTests = parallel_tests
                }
            end
        end

        local pipeline = Pipeline:fromConfig(preset_config)
        local preset_pass, preset_fail = 0, 0

        for _, file_path in ipairs(test_files) do
            if not file_filter or file_path:find(file_filter, 1, true) then
                total = total + 1
                local result = run_single_test(file_path, pipeline, preset_name)
                
                if result == "pass" then
                    preset_pass = preset_pass + 1
                else
                    preset_fail = preset_fail + 1
                end
            end
        end
        
        -- Preset summary line
        local status = preset_fail == 0 and "OK" or "FAIL"
        log(string.format("[%s] %s: %d/%d passed", 
            status, preset_name, preset_pass, preset_pass + preset_fail))
    end
end

-- Final Summary
log("")
log("=== SUMMARY ===")
log(string.format("TOTAL: %d | PASS: %d | FAIL: %d | SKIP: %d | ERROR: %d",
    total,
    #results.passed,
    #results.failed,
    #results.skipped,
    #results.errors
))

-- Only show failures (most important for AI agents)
if #results.failed > 0 then
    log("")
    log("=== FAILURES ===")
    for i, fail in ipairs(results.failed) do
        if i > 10 then
            log(string.format("... and %d more failures", #results.failed - 10))
            break
        end
        if fail.stage == "obfuscation" then
            log(string.format("  [%s] Obfuscation error: %s", fail.id, fail.error))
        else
            log(string.format("  [%s] Output mismatch", fail.id))
            if verbose then
                log(string.format("    Expected: %s", fail.expected))
                log(string.format("    Actual:   %s", fail.actual))
            end
        end
    end
end

-- Show errors if any
if #results.errors > 0 then
    log("")
    log("=== ERRORS ===")
    for _, err in ipairs(results.errors) do
        log(string.format("  [%s] %s", err.id, err.reason))
    end
end

-- Status
log("")
if #results.failed > 0 or #results.errors > 0 then
    log("STATUS: FAILED")
else
    log("STATUS: PASSED")
end

-- Save results to file
save_output()

-- Exit code
if #results.failed > 0 or #results.errors > 0 then
    os.exit(1)
else
    os.exit(0)
end


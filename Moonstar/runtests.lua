-- runtests.lua

-- Add moonstar/src to package.path so we can require modules
package.path = "moonstar/src/?.lua;" .. package.path

local moonstar = require("moonstar")
local Pipeline = moonstar.Pipeline
local Presets = moonstar.Presets

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
local enable_compression = false
local file_filter = nil

for i = 1, #arg do
    local a = arg[i]
    if a:match("^--preset=") then
        target_preset = a:match("^--preset=(.+)$")
    elseif a == "--compress" then
        enable_compression = true
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
    -- Cross-platform command to list files in tests folder
    -- Try to detect OS
    local separator = package.config:sub(1,1)
    local cmd
    if separator == '\\' then
        -- Windows
        cmd = 'dir /s /b "tests\\*.lua" "tests\\*.luau"'
    else
        -- Unix-like (Linux, macOS)
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

-- Helper to run lua code and capture output
local function run_lua_code(code)
    local tmp_file = "temp_test_exec.lua"
    
    local f = io.open(tmp_file, "w")
    if not f then return nil, "Could not open temp file" end
    f:write(code)
    f:close()

    -- Capture stderr as well
    local output = run_command("lua5.1 " .. tmp_file .. " 2>&1")
    os.remove(tmp_file)
    return output
end

-- Main test loop
local test_files = get_test_files()
table.sort(test_files)
local failed_tests = 0
local total_tests = 0

print("Starting Moonstar Test Runner...")
print("Found " .. #test_files .. " test files.")

if file_filter then
    print("Filtering files by: " .. file_filter)
end

local AURORA_EMULATOR_PATH = "tests/setup/aurora.lua"
local aurora_emulator_code = nil
local f = io.open(AURORA_EMULATOR_PATH, "r")
if f then
    aurora_emulator_code = f:read("*a")
    f:close()
else
    print("[ERROR] Could not read emulator file: " .. AURORA_EMULATOR_PATH)
end

local function run_single_test(file_path, pipeline)
    total_tests = total_tests + 1
    print("  Running test: " .. file_path)

    local f = io.open(file_path, "r")
    if not f then
        print("    [ERROR] Could not read file: " .. file_path)
        failed_tests = failed_tests + 1
        return
    end
    local original_code = f:read("*a")
    f:close()

    local code_to_run = original_code
    if file_path:match("%.luau$") then
        if not aurora_emulator_code then
            print("    [ERROR] Aurora emulator not loaded, skipping " .. file_path)
            failed_tests = failed_tests + 1
            return
        end
        code_to_run = aurora_emulator_code .. "\n" .. original_code
    end

    -- 1. Run original code
    local expected_output = run_lua_code(code_to_run)

    -- 2. Obfuscate
    local status, obfuscated_code = pcall(function()
        return pipeline:apply(original_code, file_path)
    end)

    if not status then
        print("    [FAIL] Obfuscation error: " .. tostring(obfuscated_code))
        failed_tests = failed_tests + 1
        return
    end

    -- 3. Run obfuscated code
    local obfuscated_code_to_run = obfuscated_code
    if file_path:match("%.luau$") then
        if aurora_emulator_code then
            obfuscated_code_to_run = aurora_emulator_code .. "\n" .. obfuscated_code
        end
    end
    local actual_output = run_lua_code(obfuscated_code_to_run)

    -- 4. Compare
    -- Trim whitespace for comparison
    local expected_clean = expected_output:gsub("%s+$", ""):gsub("\r\n", "\n")
    local actual_clean = actual_output:gsub("%s+$", ""):gsub("\r\n", "\n")

    if expected_clean == actual_clean then
        print("    [PASS] Output matches")
    else
        print("    [FAIL] Output mismatch")
        print("      Expected: " .. string.format("%q", expected_clean))
        print("      Actual:   " .. string.format("%q", actual_clean))
        failed_tests = failed_tests + 1

        -- Save failed code
        local f_fail = io.open("failed_code.lua", "w")
        if f_fail then
            f_fail:write(obfuscated_code)
            f_fail:close()
            print("    [INFO] Saved failed code to failed_code.lua")
        end
    end
end

-- Sort presets to have a consistent order
local preset_names = {}
for name, _ in pairs(Presets) do
    table.insert(preset_names, name)
end
table.sort(preset_names)

for _, preset_name in ipairs(preset_names) do
    if not target_preset or target_preset == preset_name then
        local preset_config = deepCopy(Presets[preset_name])

        if enable_compression then
            preset_config.Compression = { Enabled = true }
        end

        print("\n========================================")
        print("Testing Preset: " .. preset_name .. (enable_compression and " (Compressed)" or ""))
        print("========================================")

        local pipeline = Pipeline:fromConfig(preset_config)

        for _, file_path in ipairs(test_files) do
            if not file_filter or file_path:find(file_filter, 1, true) then
                run_single_test(file_path, pipeline)
            end
        end
    end
end

print("\n------------------------------------------------")
print("Tests completed.")
print("Total: " .. total_tests)
print("Failed: " .. failed_tests)

if failed_tests > 0 then
    os.exit(1)
else
    os.exit(0)
end

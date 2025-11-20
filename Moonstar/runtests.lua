-- runtests.lua

-- Add moonstar/src to package.path so we can require modules
package.path = "moonstar/src/?.lua;" .. package.path

local moonstar = require("moonstar")
local Pipeline = moonstar.Pipeline
local Presets = moonstar.Presets

-- Helper to run command and get output
local function run_command(cmd)
    local handle = io.popen(cmd)
    if not handle then return "" end
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
        cmd = 'dir /b "tests\\*.lua"'
    else
        -- Unix-like (Linux, macOS)
        cmd = 'ls tests/*.lua 2>/dev/null'
    end
    
    local handle = io.popen(cmd)
    if handle then
        for line in handle:lines() do
            -- Trim whitespace just in case
            line = line:gsub("^%s*(.-)%s*$", "%1")
            if line ~= "" then
                -- On Unix, ls returns full path, on Windows just filename
                if separator == '\\' then
                    table.insert(files, "tests/" .. line)
                else
                    -- Already has path from ls
                    table.insert(files, line)
                end
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
    local output = run_command("lua " .. tmp_file .. " 2>&1")
    os.remove(tmp_file)
    return output
end

-- Main test loop
local test_files = get_test_files()
local failed_tests = 0
local total_tests = 0

print("Starting Moonstar Test Runner...")
print("Found " .. #test_files .. " test files.")

-- Sort presets to have a consistent order
local preset_names = {}
for name, _ in pairs(Presets) do
    table.insert(preset_names, name)
end
table.sort(preset_names)

for _, preset_name in ipairs(preset_names) do
    local preset_config = Presets[preset_name]
    print("\n========================================")
    print("Testing Preset: " .. preset_name)
    print("========================================")
    
    local pipeline = Pipeline:fromConfig(preset_config)
    
    for _, file_path in ipairs(test_files) do
        total_tests = total_tests + 1
        print("  Running test: " .. file_path)
        
        local f = io.open(file_path, "r")
        if not f then
            print("    [ERROR] Could not read file: " .. file_path)
            failed_tests = failed_tests + 1
        else
            local original_code = f:read("*a")
            f:close()
            
            -- 1. Run original code
            local expected_output = run_lua_code(original_code)
            
            -- 2. Obfuscate
            local status, obfuscated_code = pcall(function() 
                return pipeline:apply(original_code, file_path) 
            end)
            
            if not status then
                print("    [FAIL] Obfuscation error: " .. tostring(obfuscated_code))
                failed_tests = failed_tests + 1
            else
                -- 3. Run obfuscated code
                local actual_output = run_lua_code(obfuscated_code)
                
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

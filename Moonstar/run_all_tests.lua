#!/usr/bin/env lua
--[[
    Comprehensive test runner for Moonstar
    
    Runs all tests with all presets and reports results.
    
    Usage: lua run_all_tests.lua
    
    This script will run all 8 tests with all 5 presets:
    - Minify
    - Weak
    - Medium
    - Strong
    - Panic
    
    Total: 40 test combinations (8 tests × 5 presets)
]]

-- Define all tests
local tests = {
    "test_simple",
    "test_comprehensive",
    "test_metamethod",
    "test_advanced",
    "test_strings",
    "test_control_flow",
    "test_functions",
    "test_tables"
}

-- Define all presets
local presets = {
    "Minify",
    "Weak",
    "Medium",
    "Strong",
    "Panic"
}

print("╔════════════════════════════════════════════════════════╗")
print("║     Moonstar Comprehensive Test Suite                 ║")
print("║     Running all tests with all presets                ║")
print("╚════════════════════════════════════════════════════════╝")
print("")

-- Track overall results
local totalTests = 0
local totalPassed = 0
local totalFailed = 0
local results = {}

-- Determine lua command
local luaCmd = "lua5.1"
if os.execute("which lua5.1 >/dev/null 2>&1") ~= 0 then
    luaCmd = "lua"
end

-- Run tests for each preset
for _, preset in ipairs(presets) do
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("PRESET: " .. preset)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    results[preset] = {}
    
    -- Run the test runner with this preset
    local cmd = string.format('%s run_tests.lua all %s > /tmp/test_%s.log 2>&1', 
                             luaCmd, preset, preset:lower())
    local exitCode = os.execute(cmd)
    
    -- Parse the results from the log file
    local logFile = io.open("/tmp/test_" .. preset:lower() .. ".log", "r")
    if logFile then
        local logContent = logFile:read("*all")
        logFile:close()
        
        -- Count passed and failed tests from the log
        local passed = 0
        local failed = 0
        
        for line in logContent:gmatch("[^\r\n]+") do
            if line:match("✓ PASSED") then
                passed = passed + 1
            elseif line:match("✗ FAILED") then
                failed = failed + 1
            end
        end
        
        results[preset].passed = passed
        results[preset].failed = failed
        results[preset].success = (exitCode == 0 or exitCode == true)
        
        totalTests = totalTests + passed + failed
        totalPassed = totalPassed + passed
        totalFailed = totalFailed + failed
        
        print(string.format("  Passed: %d/%d", passed, passed + failed))
        if failed > 0 then
            print("  Status: ✗ FAILED")
        else
            print("  Status: ✓ PASSED")
        end
    else
        results[preset].passed = 0
        results[preset].failed = 0
        results[preset].success = false
        print("  Status: ✗ ERROR - Could not read log file")
    end
    print("")
end

-- Print summary
print("╔════════════════════════════════════════════════════════╗")
print("║                    FINAL SUMMARY                       ║")
print("╚════════════════════════════════════════════════════════╝")
print("")

for _, preset in ipairs(presets) do
    local result = results[preset]
    local status = result.success and "✓" or "✗"
    print(string.format("  %s %-10s: %d passed, %d failed", 
                       status, preset, result.passed, result.failed))
end

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print(string.format("TOTAL: %d passed, %d failed out of %d tests", 
                   totalPassed, totalFailed, totalTests))
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Exit with appropriate code
os.exit(totalFailed == 0 and 0 or 1)

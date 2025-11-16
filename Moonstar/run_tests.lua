#!/usr/bin/env lua
--[[
    Test runner for Moonstar
    
    Tests obfuscation by running functional Lua programs through the obfuscator
    and verifying they produce the same output.
]]

-- If no arguments, show available tests
if #arg == 0 then
    print("Usage: lua run_tests.lua [test_name] [preset]")
    print("")
    print("Available tests:")
    print("  test_simple           - Basic arithmetic and control flow")
    print("  test_comprehensive    - Fibonacci and table operations")
    print("  test_metamethod       - Metamethod and table features")
    print("  test_advanced         - Closures, metatables, complex logic")
    print("  test_strings          - String manipulation")
    print("  test_control_flow     - Loops and conditionals")
    print("  test_functions        - Function features")
    print("  test_tables           - Table operations")
    print("  test_luau             - Luau-specific features")
    print("  test_luau_comprehensive - Comprehensive Luau features")
    print("  all                   - Run all tests")
    print("")
    print("Presets: Minify, Weak, Medium, Strong, Panic (default: Minify)")
    print("")
    print("Examples:")
    print("  lua run_tests.lua test_simple")
    print("  lua run_tests.lua test_advanced Medium")
    print("  lua run_tests.lua all Strong")
    os.exit(0)
end

local testName = arg[1]
local preset = arg[2] or "Minify"

-- Available tests
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

-- Run a single test
local function runTest(name)
    local testFile = "tests/" .. name .. ".lua"
    
    -- Check if file exists
    local f = io.open(testFile, "r")
    if not f then
        print("✗ Test file not found: " .. testFile)
        return false
    end
    f:close()
    
    -- Ensure output directory exists (cross-platform, idempotent)
    local output_dir = "./output"
    local is_windows = package.config:sub(1,1) == "\\"
    if is_windows then
        os.execute('mkdir "' .. output_dir .. '" >nul 2>nul')
    else
        os.execute('mkdir -p "' .. output_dir .. '"')
    end
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("Testing: " .. name .. " (Preset: " .. preset .. ")")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    -- Run original file
    print("\n[1/3] Running original file...")
    local originalOutput = "./output/" .. name .. "_original_output.txt"
    local luaCmd = "lua5.1"
    -- Fallback to 'lua' if lua5.1 is not available
    if os.execute("which lua5.1 >/dev/null 2>&1") ~= 0 then
        luaCmd = "lua"
    end
    os.execute(luaCmd .. " " .. testFile .. " > " .. originalOutput .. " 2>&1")
    
    -- Obfuscate
    print("[2/3] Obfuscating with " .. preset .. " preset...")
    local obfuscatedFile = "./output/" .. name .. "_obfuscated.lua"
    local obfCmd = luaCmd .. " moonstar.lua " .. testFile .. " " .. obfuscatedFile .. " --preset=" .. preset
    os.execute(obfCmd .. " > ./output/obf_log.txt 2>&1")
    
    -- Run obfuscated file
    print("[3/3] Running obfuscated file...")
    local obfuscatedOutput = "./output/" .. name .. "_obfuscated_output.txt"
    os.execute(luaCmd .. " " .. obfuscatedFile .. " > " .. obfuscatedOutput .. " 2>&1")
    
    -- Compare outputs
    local origF = io.open(originalOutput, "r")
    local obfF = io.open(obfuscatedOutput, "r")
    
    if not origF or not obfF then
        print("✗ FAILED: Could not read output files")
        return false
    end
    
    local origContent = origF:read("*all")
    local obfContent = obfF:read("*all")
    origF:close()
    obfF:close()
    
    if origContent == obfContent then
        print("✓ PASSED: Output matches!")
        print("")
        return true
    else
        print("✗ FAILED: Output mismatch!")
        print("\nOriginal output:")
        print(origContent:sub(1, 500))
        print("\nObfuscated output:")
        print(obfContent:sub(1, 500))
        print("")
        return false
    end
end

-- Run tests
if testName == "all" then
    local passed = 0
    local failed = 0
    
    for _, name in ipairs(tests) do
        if runTest(name) then
            passed = passed + 1
        else
            failed = failed + 1
        end
    end
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    os.exit(failed == 0 and 0 or 1)
else
    local success = runTest(testName)
    os.exit(success and 0 or 1)
end

-- runtests.lua
-- Moonstar Test Runner with clean console output and LLM-friendly report generation

-- Add moonstar/src to package.path so we can require modules
package.path = "moonstar/src/?.lua;" .. package.path

local moonstar = require("moonstar")
local Pipeline = moonstar.Pipeline
local Presets = moonstar.Presets
local Logger = moonstar.Logger

-- Suppress Moonstar's verbose logging during test runs
Logger.logLevel = Logger.LogLevel.Error

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

local CONFIG = {
    REPORT_FILE = "test_results.txt",
    AURORA_EMULATOR_PATH = "tests/setup/aurora.lua",
    TEMP_FILE = "temp_test_exec.lua",
    FAILED_CODE_FILE = "failed_code.lua",
}

--------------------------------------------------------------------------------
-- ANSI Colors (for console)
--------------------------------------------------------------------------------

local Colors = {
    reset   = "\27[0m",
    bold    = "\27[1m",
    dim     = "\27[2m",
    red     = "\27[31m",
    green   = "\27[32m",
    yellow  = "\27[33m",
    blue    = "\27[34m",
    magenta = "\27[35m",
    cyan    = "\27[36m",
    white   = "\27[37m",
}

-- Check if colors are supported (disable on Windows cmd without ANSI support)
local function supportsColors()
    local term = os.getenv("TERM")
    local colorterm = os.getenv("COLORTERM")
    -- Windows Terminal and modern terminals support ANSI
    if os.getenv("WT_SESSION") or colorterm then return true end
    if term and (term:match("xterm") or term:match("256color") or term:match("color")) then
        return true
    end
    -- Try enabling ANSI on Windows
    local separator = package.config:sub(1,1)
    if separator == '\\' then
        os.execute("") -- This can enable ANSI in some Windows terminals
        return true
    end
    return term ~= nil
end

local USE_COLORS = supportsColors()

local function c(color, text)
    if USE_COLORS then
        return color .. text .. Colors.reset
    end
    return text
end

--------------------------------------------------------------------------------
-- Report Builder (for LLM-friendly .txt output)
--------------------------------------------------------------------------------

local Report = {
    lines = {},
    summary = {
        total = 0,
        passed = 0,
        failed = 0,
        skipped = 0,
        errors = {},
    },
    current_preset = nil,
    start_time = os.time(),
}

function Report:add(line)
    table.insert(self.lines, line or "")
end

function Report:header(text)
    self:add("")
    self:add(string.rep("=", 80))
    self:add(text)
    self:add(string.rep("=", 80))
end

function Report:section(text)
    self:add("")
    self:add(string.rep("-", 60))
    self:add(text)
    self:add(string.rep("-", 60))
end

function Report:testResult(file, status, details)
    self.summary.total = self.summary.total + 1
    
    local status_str
    if status == "PASS" then
        self.summary.passed = self.summary.passed + 1
        status_str = "[PASS]"
    elseif status == "FAIL" then
        self.summary.failed = self.summary.failed + 1
        status_str = "[FAIL]"
        table.insert(self.summary.errors, {
            preset = self.current_preset,
            file = file,
            details = details
        })
    elseif status == "SKIP" then
        self.summary.skipped = self.summary.skipped + 1
        status_str = "[SKIP]"
    else
        status_str = "[" .. status .. "]"
    end
    
    self:add(string.format("%-8s %s", status_str, file))
    if details then
        for line in details:gmatch("[^\n]+") do
            self:add("         " .. line)
        end
    end
end

function Report:save()
    self:add("")
    self:header("SUMMARY")
    self:add("")
    self:add(string.format("Total Tests:   %d", self.summary.total))
    self:add(string.format("Passed:        %d", self.summary.passed))
    self:add(string.format("Failed:        %d", self.summary.failed))
    self:add(string.format("Skipped:       %d", self.summary.skipped))
    self:add(string.format("Success Rate:  %.1f%%", 
        self.summary.total > 0 and (self.summary.passed / self.summary.total * 100) or 0))
    self:add(string.format("Duration:      %ds", os.time() - self.start_time))
    
    if #self.summary.errors > 0 then
        self:add("")
        self:section("FAILED TESTS DETAILS")
        for i, err in ipairs(self.summary.errors) do
            self:add("")
            self:add(string.format("Failure #%d:", i))
            self:add(string.format("  Preset: %s", err.preset or "unknown"))
            self:add(string.format("  File:   %s", err.file))
            if err.details then
                self:add("  Details:")
                for line in err.details:gmatch("[^\n]+") do
                    self:add("    " .. line)
                end
            end
        end
    end
    
    self:add("")
    self:add(string.rep("=", 80))
    self:add("END OF REPORT")
    self:add(string.rep("=", 80))
    
    local f = io.open(CONFIG.REPORT_FILE, "w")
    if f then
        f:write(table.concat(self.lines, "\n"))
        f:close()
        return true
    end
    return false
end

--------------------------------------------------------------------------------
-- Console Output Helpers
--------------------------------------------------------------------------------

local Console = {}

function Console:header(text)
    print("")
    print(c(Colors.cyan .. Colors.bold, "╔" .. string.rep("═", 58) .. "╗"))
    print(c(Colors.cyan .. Colors.bold, "║") .. c(Colors.white .. Colors.bold, string.format(" %-56s ", text)) .. c(Colors.cyan .. Colors.bold, "║"))
    print(c(Colors.cyan .. Colors.bold, "╚" .. string.rep("═", 58) .. "╝"))
end

function Console:preset(name, compressed)
    local suffix = compressed and " (Compressed)" or ""
    print("")
    print(c(Colors.blue .. Colors.bold, "▶ Preset: ") .. c(Colors.white .. Colors.bold, name .. suffix))
    print(c(Colors.dim, "  " .. string.rep("─", 50)))
end

function Console:testPass(file)
    print(c(Colors.green, "  ✓ ") .. c(Colors.dim, file))
end

function Console:testFail(file, reason)
    print(c(Colors.red .. Colors.bold, "  ✗ ") .. c(Colors.white, file))
    if reason then
        print(c(Colors.red .. Colors.dim, "    └─ " .. reason:sub(1, 60)))
    end
end

function Console:testSkip(file, reason)
    print(c(Colors.yellow, "  ○ ") .. c(Colors.dim, file .. " (skipped)"))
end

function Console:progress(current, total)
    local width = 30
    local filled = math.floor((current / total) * width)
    local bar = string.rep("█", filled) .. string.rep("░", width - filled)
    local pct = math.floor((current / total) * 100)
    io.write(string.format("\r  %s %3d%% (%d/%d)", 
        c(Colors.cyan, bar), pct, current, total))
    io.flush()
end

function Console:clearLine()
    io.write("\r" .. string.rep(" ", 60) .. "\r")
    io.flush()
end

function Console:summary(total, passed, failed, skipped, duration)
    print("")
    print(c(Colors.cyan .. Colors.bold, "╔" .. string.rep("═", 40) .. "╗"))
    print(c(Colors.cyan .. Colors.bold, "║") .. c(Colors.white .. Colors.bold, "            TEST RESULTS                ") .. c(Colors.cyan .. Colors.bold, "║"))
    print(c(Colors.cyan .. Colors.bold, "╠" .. string.rep("═", 40) .. "╣"))
    
    local pass_color = passed == total and Colors.green or Colors.white
    print(c(Colors.cyan .. Colors.bold, "║") .. 
          string.format("  Total:   %-28d", total) .. 
          c(Colors.cyan .. Colors.bold, "║"))
    print(c(Colors.cyan .. Colors.bold, "║") .. 
          "  Passed:  " .. c(Colors.green, string.format("%-28d", passed)) .. 
          c(Colors.cyan .. Colors.bold, "║"))
    
    if failed > 0 then
        print(c(Colors.cyan .. Colors.bold, "║") .. 
              "  Failed:  " .. c(Colors.red .. Colors.bold, string.format("%-28d", failed)) .. 
              c(Colors.cyan .. Colors.bold, "║"))
    else
        print(c(Colors.cyan .. Colors.bold, "║") .. 
              string.format("  Failed:  %-28d", failed) .. 
              c(Colors.cyan .. Colors.bold, "║"))
    end
    
    if skipped > 0 then
        print(c(Colors.cyan .. Colors.bold, "║") .. 
              "  Skipped: " .. c(Colors.yellow, string.format("%-28d", skipped)) .. 
              c(Colors.cyan .. Colors.bold, "║"))
    end
    
    print(c(Colors.cyan .. Colors.bold, "║") .. 
          string.format("  Time:    %-28s", duration .. "s") .. 
          c(Colors.cyan .. Colors.bold, "║"))
    print(c(Colors.cyan .. Colors.bold, "╚" .. string.rep("═", 40) .. "╝"))
    
    if failed == 0 then
        print("")
        print(c(Colors.green .. Colors.bold, "  ★ All tests passed! ★"))
    else
        print("")
        print(c(Colors.red .. Colors.bold, "  ✗ Some tests failed. Check " .. CONFIG.REPORT_FILE .. " for details."))
    end
end

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

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

local function run_command(cmd)
    local handle = io.popen(cmd)
    if not handle then return "", "popen failed" end
    local result = handle:read("*a")
    handle:close()
    return result or ""
end

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

-- Enhanced test harness that wraps the code with assertion tracking and timing
local TEST_HARNESS = [[
-- Test Harness: Assertion Tracking & Performance Measurement
local __test_harness = {
    assertions_passed = 0,
    assertions_failed = 0,
    assertion_errors = {},
    start_time = nil,
    end_time = nil,
}

-- Override assert to track assertions
-- We track all assertions but still allow failed ones to error (original behavior)
local _original_assert = assert
_G.assert = function(condition, message)
    if condition then
        __test_harness.assertions_passed = __test_harness.assertions_passed + 1
        return condition
    else
        __test_harness.assertions_failed = __test_harness.assertions_failed + 1
        local err_msg = message or "assertion failed"
        table.insert(__test_harness.assertion_errors, err_msg)
        -- Call original assert to trigger the error (original behavior)
        return _original_assert(condition, message)
    end
end

-- Start timing
__test_harness.start_time = os.clock()

-- Run test in protected mode (so we can capture assertion failures)
local __test_ok, __test_err = pcall(function()
-- BEGIN USER CODE
]]

local TEST_HARNESS_END = [[
-- END USER CODE
end)

-- End timing
__test_harness.end_time = os.clock()

-- Output test results in structured format
print("__TEST_HARNESS_RESULTS__")
print("ASSERTIONS_PASSED=" .. __test_harness.assertions_passed)
print("ASSERTIONS_FAILED=" .. __test_harness.assertions_failed)
print("EXECUTION_TIME=" .. string.format("%.6f", __test_harness.end_time - __test_harness.start_time))
if __test_ok then
    print("STATUS=OK")
else
    print("STATUS=ERROR")
    print("ERROR_MESSAGE=" .. tostring(__test_err))
end
for i, err in ipairs(__test_harness.assertion_errors) do
    print("ASSERTION_ERROR_" .. i .. "=" .. tostring(err))
end
print("__TEST_HARNESS_END__")
]]

-- Parse test harness results from output
local function parse_test_results(output)
    local results = {
        assertions_passed = 0,
        assertions_failed = 0,
        execution_time = 0,
        status = "UNKNOWN",
        error_message = nil,
        assertion_errors = {},
        raw_output = "",
    }
    
    -- Find harness results section
    local harness_start = output:find("__TEST_HARNESS_RESULTS__")
    local harness_end = output:find("__TEST_HARNESS_END__")
    
    if harness_start and harness_end then
        -- Extract raw output (before harness)
        results.raw_output = output:sub(1, harness_start - 1):gsub("%s+$", "")
        
        -- Parse harness data
        local harness_data = output:sub(harness_start, harness_end)
        
        results.assertions_passed = tonumber(harness_data:match("ASSERTIONS_PASSED=(%d+)")) or 0
        results.assertions_failed = tonumber(harness_data:match("ASSERTIONS_FAILED=(%d+)")) or 0
        results.execution_time = tonumber(harness_data:match("EXECUTION_TIME=([%d%.]+)")) or 0
        results.status = harness_data:match("STATUS=(%w+)") or "UNKNOWN"
        results.error_message = harness_data:match("ERROR_MESSAGE=([^\n]+)")
        
        -- Parse assertion errors
        for err in harness_data:gmatch("ASSERTION_ERROR_%d+=([^\n]+)") do
            table.insert(results.assertion_errors, err)
        end
    else
        -- Fallback: no harness output found
        results.raw_output = output:gsub("%s+$", "")
        results.status = "NO_HARNESS"
    end
    
    return results
end

local function run_lua_code(code, use_harness)
    local f = io.open(CONFIG.TEMP_FILE, "w")
    if not f then return nil, "Could not open temp file" end
    
    if use_harness then
        f:write(TEST_HARNESS)
        f:write(code)
        f:write(TEST_HARNESS_END)
    else
        f:write(code)
    end
    
    f:close()
    -- Prefer Lua 5.1 for Moonstar compatibility
    -- lua5.1 > luajit > lua5.2 > lua
    local lua_cmd = "lua"
    local separator = package.config:sub(1,1)
    if separator == '/' then  -- Unix-like
        -- Check for available interpreters (prefer 5.1)
        local check_lua = io.popen("which lua5.1 luajit lua5.2 2>/dev/null | head -1")
        if check_lua then
            local found = check_lua:read("*l")
            check_lua:close()
            if found and found ~= "" then
                lua_cmd = found
            end
        end
    end
    local output = run_command(lua_cmd .. " " .. CONFIG.TEMP_FILE .. " 2>&1")
    os.remove(CONFIG.TEMP_FILE)
    return output
end

local function truncate(str, max_len)
    if #str <= max_len then return str end
    return str:sub(1, max_len - 3) .. "..."
end

-- Get file size
local function get_code_size(code)
    return #code
end

-- Helper to find diff
local function get_string_diff(s1, s2, context)
    context = context or 20
    if s1 == s2 then return nil end

    local min_len = math.min(#s1, #s2)
    for i = 1, min_len do
        if s1:sub(i, i) ~= s2:sub(i, i) then
            local start_idx = math.max(1, i - context)
            local end_idx = math.min(math.max(#s1, #s2), i + context)

            local s1_sub = s1:sub(start_idx, end_idx)
            local s2_sub = s2:sub(start_idx, end_idx)

            -- Highlight difference point (crudely)
            return string.format("Difference at index %d:\nExpected context: ...%s...\nActual context:   ...%s...",
                i, s1_sub:gsub("\n", "\\n"), s2_sub:gsub("\n", "\\n"))
        end
    end

    if #s1 ~= #s2 then
        return string.format("Lengths differ: Expected %d chars, Actual %d chars. Strings identical up to index %d.",
            #s1, #s2, min_len)
    end

    return "Unknown difference"
end

--------------------------------------------------------------------------------
-- Parse Arguments
--------------------------------------------------------------------------------

local target_preset = nil
local enable_compression = false
local file_filter = nil
local parallel_tests = 4
local verbose = false

for i = 1, #arg do
    local a = arg[i]
    if a:match("^--preset=") then
        target_preset = a:match("^--preset=(.+)$")
    elseif a == "--compress" then
        enable_compression = true
    elseif a:match("^--parallel=") then
        parallel_tests = tonumber(a:match("^--parallel=(.+)$")) or 4
    elseif a == "--verbose" or a == "-v" then
        verbose = true
    elseif not a:match("^-") then
        file_filter = a
    end
end

--------------------------------------------------------------------------------
-- Main Test Runner
--------------------------------------------------------------------------------

-- Load Aurora emulator
local aurora_emulator_code = nil
local f = io.open(CONFIG.AURORA_EMULATOR_PATH, "r")
if f then
    aurora_emulator_code = f:read("*a")
    f:close()
end

-- Get test files
local test_files = get_test_files()
table.sort(test_files)

-- Initialize report
Report:add("MOONSTAR OBFUSCATOR - TEST RESULTS")
Report:add("Generated: " .. os.date("%Y-%m-%d %H:%M:%S"))
Report:add("Test Files: " .. #test_files)
if file_filter then
    Report:add("Filter: " .. file_filter)
end
if target_preset then
    Report:add("Target Preset: " .. target_preset)
end
Report:add("Compression: " .. (enable_compression and "enabled" or "disabled"))

-- Console header
Console:header("MOONSTAR TEST RUNNER")
print(c(Colors.dim, "  Found " .. #test_files .. " test files"))
if file_filter then
    print(c(Colors.dim, "  Filter: " .. file_filter))
end

-- Track stats
local total_tests = 0
local passed_tests = 0
local failed_tests = 0
local skipped_tests = 0
local start_time = os.time()

-- Additional metrics
local total_assertions_passed = 0
local total_assertions_failed = 0
local total_size_original = 0
local total_size_obfuscated = 0
local total_time_original = 0
local total_time_obfuscated = 0

-- Test runner function with enhanced validation
local function run_single_test(file_path, pipeline, test_index, total_count)
    total_tests = total_tests + 1
    
    if not verbose then
        Console:progress(test_index, total_count)
    end
    
    -- Read file
    local f = io.open(file_path, "r")
    if not f then
        skipped_tests = skipped_tests + 1
        Report:testResult(file_path, "SKIP", "Could not read file")
        if verbose then Console:testSkip(file_path, "Could not read file") end
        return
    end
    local original_code = f:read("*a")
    f:close()
    
    -- Track original code size
    local original_size = get_code_size(original_code)
    total_size_original = total_size_original + original_size
    
    -- Prepare code for execution
    local code_to_run = original_code
    if file_path:match("%.luau$") then
        if not aurora_emulator_code then
            skipped_tests = skipped_tests + 1
            Report:testResult(file_path, "SKIP", "Aurora emulator not loaded")
            if verbose then Console:testSkip(file_path, "Aurora emulator not loaded") end
            return
        end
        code_to_run = aurora_emulator_code .. "\n" .. original_code
    end
    
    -- Run original with test harness
    local original_output_raw = run_lua_code(code_to_run, true)
    local original_results = parse_test_results(original_output_raw)
    
    -- Check if original code runs successfully
    if original_results.status == "ERROR" then
        skipped_tests = skipped_tests + 1
        Report:testResult(file_path, "SKIP", "Original code error: " .. (original_results.error_message or "unknown"))
        if verbose then Console:testSkip(file_path, "Original code error") end
        return
    end
    
    total_time_original = total_time_original + original_results.execution_time
    
    -- Obfuscate
    local status, obfuscated_code = pcall(function()
        return pipeline:apply(original_code, file_path)
    end)
    
    if not status then
        failed_tests = failed_tests + 1
        local err_msg = "Obfuscation error: " .. truncate(tostring(obfuscated_code), 200)
        Report:testResult(file_path, "FAIL", err_msg)
        if verbose then 
            Console:clearLine()
            Console:testFail(file_path, "Obfuscation error") 
        end
        return
    end
    
    -- Track obfuscated code size
    local obfuscated_size = get_code_size(obfuscated_code)
    total_size_obfuscated = total_size_obfuscated + obfuscated_size
    
    -- Run obfuscated WITHOUT test harness (harness breaks vararg compatibility)
    -- The obfuscated code uses '...' which doesn't work inside pcall(function() ... end)
    local obfuscated_code_to_run = obfuscated_code
    if file_path:match("%.luau$") and aurora_emulator_code then
        obfuscated_code_to_run = aurora_emulator_code .. "\n" .. obfuscated_code
    end
    
    -- Time the obfuscated execution manually
    local obf_start_time = os.clock()
    local obfuscated_output_raw = run_lua_code(obfuscated_code_to_run, false)  -- No harness!
    local obf_end_time = os.clock()
    
    local obfuscated_execution_time = obf_end_time - obf_start_time
    total_time_obfuscated = total_time_obfuscated + obfuscated_execution_time
    
    -- Enhanced validation
    local test_passed = true
    local failure_reasons = {}
    
    -- Clean outputs for comparison (normalize all whitespace variations)
    local function normalize_output(s)
        return s:gsub("\r\n", "\n")   -- Normalize line endings
                :gsub("\r", "\n")     -- Handle old Mac line endings
                :gsub("\t", " ")      -- Tabs to spaces
                :gsub(" +\n", "\n")   -- Trailing spaces on lines
                :gsub("%s+$", "")     -- Trailing whitespace at end
                :gsub("table: 0x%x+", "table: 0xADDR")         -- Normalize table addresses
                :gsub("function: 0x%x+", "function: 0xADDR")   -- Normalize function addresses
                :gsub("userdata: 0x%x+", "userdata: 0xADDR")   -- Normalize userdata addresses
    end
    
    local expected_clean = normalize_output(original_results.raw_output)
    local actual_clean = normalize_output(obfuscated_output_raw)
    
    -- 1. Check for runtime errors (look for error patterns in output)
    if actual_clean:match("^[^:]+:%d+:") or actual_clean:match("^lua[^:]*:") then
        test_passed = false
        table.insert(failure_reasons, "Runtime error: " .. truncate(actual_clean, 100))
    end
    
    -- 2. Compare outputs
    if expected_clean ~= actual_clean then
        test_passed = false
        local diff_msg = get_string_diff(expected_clean, actual_clean)

        table.insert(failure_reasons, string.format("Output mismatch:\n%s", diff_msg or "Unknown difference"))
    end
    
    -- Update totals (use original assertion count since we can't track obfuscated)
    total_assertions_passed = total_assertions_passed + original_results.assertions_passed
    -- We can't track obfuscated assertions without harness, so we assume they match if output matches
    
    if test_passed then
        passed_tests = passed_tests + 1
        -- Include metrics in pass report
        local metrics = string.format("(assertions: %d, size: %d→%d, time: %.3fs→%.3fs)",
            original_results.assertions_passed,
            original_size, obfuscated_size,
            original_results.execution_time, obfuscated_execution_time)
        Report:testResult(file_path, "PASS", verbose and metrics or nil)
        if verbose then 
            Console:clearLine()
            Console:testPass(file_path) 
        end
    else
        failed_tests = failed_tests + 1
        local details = table.concat(failure_reasons, "\n")
        Report:testResult(file_path, "FAIL", details)
        
        if verbose then 
            Console:clearLine()
            Console:testFail(file_path, failure_reasons[1] or "Unknown error") 
        end
        
        -- Save failed code
        local f_fail = io.open(CONFIG.FAILED_CODE_FILE, "w")
        if f_fail then
            f_fail:write(obfuscated_code)
            f_fail:close()
        end
    end
end

-- Get sorted preset names
local preset_names = {}
for name, _ in pairs(Presets) do
    table.insert(preset_names, name)
end
table.sort(preset_names)

-- Run tests for each preset
for _, preset_name in ipairs(preset_names) do
    if not target_preset or target_preset == preset_name then
        local preset_config = deepCopy(Presets[preset_name])
        
        if enable_compression then
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
        
        Report.current_preset = preset_name
        Report:section("PRESET: " .. preset_name .. (enable_compression and " (Compressed)" or ""))
        
        Console:preset(preset_name, enable_compression)
        
        local pipeline = Pipeline:fromConfig(preset_config)
        
        -- Filter and count tests
        local filtered_files = {}
        for _, file_path in ipairs(test_files) do
            if not file_filter or file_path:find(file_filter, 1, true) then
                table.insert(filtered_files, file_path)
            end
        end
        
        -- Run tests
        for i, file_path in ipairs(filtered_files) do
            run_single_test(file_path, pipeline, i, #filtered_files)
        end
        
        if not verbose and #filtered_files > 0 then
            Console:clearLine()
            print(c(Colors.dim, "  Completed " .. #filtered_files .. " tests"))
        end
    end
end

-- Calculate duration
local duration = os.time() - start_time

-- Add enhanced metrics to report
Report:add("")
Report:section("PERFORMANCE METRICS")
Report:add(string.format("Total Assertions Passed: %d", total_assertions_passed))
Report:add(string.format("Total Assertions Failed: %d", total_assertions_failed))
Report:add(string.format("Original Code Size:      %d bytes", total_size_original))
Report:add(string.format("Obfuscated Code Size:    %d bytes", total_size_obfuscated))
if total_size_original > 0 then
    local size_change = ((total_size_obfuscated - total_size_original) / total_size_original) * 100
    Report:add(string.format("Size Change:             %+.1f%%", size_change))
end
Report:add(string.format("Original Execution:      %.3fs", total_time_original))
Report:add(string.format("Obfuscated Execution:    %.3fs", total_time_obfuscated))
if total_time_original > 0 then
    local time_ratio = total_time_obfuscated / total_time_original
    Report:add(string.format("Performance Ratio:       %.2fx", time_ratio))
end

-- Save report
Report:save()

-- Print summary
Console:summary(total_tests, passed_tests, failed_tests, skipped_tests, duration)

-- Print enhanced metrics to console
print("")
print(c(Colors.cyan .. Colors.bold, "  ═══════════════════════════════════════"))
print(c(Colors.cyan, "  ENHANCED METRICS"))
print(c(Colors.cyan .. Colors.bold, "  ═══════════════════════════════════════"))
print(c(Colors.dim, string.format("  Assertions:  %d passed, %d failed", 
    total_assertions_passed, total_assertions_failed)))

if total_size_original > 0 then
    local size_change = ((total_size_obfuscated - total_size_original) / total_size_original) * 100
    local size_color = size_change > 0 and Colors.yellow or Colors.green
    print(c(Colors.dim, string.format("  Code Size:   %d → %d bytes (", total_size_original, total_size_obfuscated)) ..
          c(size_color, string.format("%+.1f%%", size_change)) ..
          c(Colors.dim, ")"))
end

if total_time_original > 0 then
    local time_ratio = total_time_obfuscated / total_time_original
    local time_color = time_ratio > 2 and Colors.yellow or Colors.green
    print(c(Colors.dim, string.format("  Exec Time:   %.3fs → %.3fs (", total_time_original, total_time_obfuscated)) ..
          c(time_color, string.format("%.2fx", time_ratio)) ..
          c(Colors.dim, ")"))
end

print("")
print(c(Colors.dim, "  Report saved to: " .. CONFIG.REPORT_FILE))
print("")

-- Exit with appropriate code
if failed_tests > 0 then
    os.exit(1)
else
    os.exit(0)
end

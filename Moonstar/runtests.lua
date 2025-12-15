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

local function run_lua_code(code)
    local f = io.open(CONFIG.TEMP_FILE, "w")
    if not f then return nil, "Could not open temp file" end
    f:write(code)
    f:close()
    local output = run_command("lua5.1 " .. CONFIG.TEMP_FILE .. " 2>&1")
    os.remove(CONFIG.TEMP_FILE)
    return output
end

local function truncate(str, max_len)
    if #str <= max_len then return str end
    return str:sub(1, max_len - 3) .. "..."
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

-- Test runner function
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
    
    -- Run original
    local expected_output = run_lua_code(code_to_run)
    
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
    
    -- Run obfuscated
    local obfuscated_code_to_run = obfuscated_code
    if file_path:match("%.luau$") and aurora_emulator_code then
        obfuscated_code_to_run = aurora_emulator_code .. "\n" .. obfuscated_code
    end
    local actual_output = run_lua_code(obfuscated_code_to_run)
    
    -- Compare outputs
    local expected_clean = expected_output:gsub("%s+$", ""):gsub("\r\n", "\n")
    local actual_clean = actual_output:gsub("%s+$", ""):gsub("\r\n", "\n")
    
    if expected_clean == actual_clean then
        passed_tests = passed_tests + 1
        Report:testResult(file_path, "PASS")
        if verbose then 
            Console:clearLine()
            Console:testPass(file_path) 
        end
    else
        failed_tests = failed_tests + 1
        local details = string.format("Expected: %s\nActual: %s",
            truncate(string.format("%q", expected_clean), 100),
            truncate(string.format("%q", actual_clean), 100))
        Report:testResult(file_path, "FAIL", details)
        
        if verbose then 
            Console:clearLine()
            Console:testFail(file_path, "Output mismatch") 
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

-- Save report
Report:save()

-- Print summary
Console:summary(total_tests, passed_tests, failed_tests, skipped_tests, duration)
print("")
print(c(Colors.dim, "  Report saved to: " .. CONFIG.REPORT_FILE))
print("")

-- Exit with appropriate code
if failed_tests > 0 then
    os.exit(1)
else
    os.exit(0)
end

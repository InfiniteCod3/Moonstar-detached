local SCRIPTS = {
    { id = "loader", label = "Loader", needsPreprocess = false },
    { id = "LunarityUI", label = "LunarityUI (Shared)", needsPreprocess = false },
    { id = "lunarity", label = "Lunarity", needsPreprocess = true },
    { id = "DoorESP", label = "DoorESP", needsPreprocess = true },
    { id = "Teleport", label = "Teleport", needsPreprocess = false },
    { id = "RemoteLogger", label = "RemoteLogger", needsPreprocess = true },
    { id = "AetherShitterRecode", label = "AetherShitter", needsPreprocess = false },
    { id = "PlayerTracker", label = "PlayerTracker", needsPreprocess = false },
    { id = "GamepassUnlocker", label = "GamepassUnlocker", needsPreprocess = false },
}

-- Obfuscation preset: Minify, Weak, Medium, Strong, or custom preset file name
local OBFUSCATION_PRESET = "Strong"

-- Check for command line arguments
local ENABLE_COMPRESSION = false

for _, v in ipairs(arg or {}) do
    if v == "--compress" or v == "--compression" then
        ENABLE_COMPRESSION = true
    elseif v:match("^--preset=") then
        OBFUSCATION_PRESET = v:match("^--preset=(.+)$")
    end
end

local isWindows = package.config:sub(1,1) == "\\"
local PARALLEL_TEMP_DIR = ".parallel_jobs"

local function run_command(cmd)
    print("\n> " .. cmd)
    local success, exit_type, exit_code = os.execute(cmd)
    if not success then
        print("Error running command: " .. cmd)
        return false
    end
    return true
end

-- Run a command in the background (async)
local function run_command_async(cmd, jobId)
    local markerFile = PARALLEL_TEMP_DIR .. "/" .. jobId .. ".done"
    local logFile = PARALLEL_TEMP_DIR .. "/" .. jobId .. ".log"
    local batchFile = PARALLEL_TEMP_DIR .. "/" .. jobId .. ".bat"
    
    -- Get current working directory (pwd for Unix, cd for Windows)
    local cwdCmd = isWindows and "cd" or "pwd"
    local cwdHandle = io.popen(cwdCmd)
    local cwd = cwdHandle and cwdHandle:read("*l") or "."
    if cwdHandle then cwdHandle:close() end
    
    if isWindows then
        -- Write a batch file that runs the command, logs output, and creates marker
        local f = io.open(batchFile, "w")
        if f then
            f:write("@echo off\r\n")
            f:write("cd /d \"" .. cwd .. "\"\r\n")
            f:write("(" .. cmd .. ") > \"" .. logFile .. "\" 2>&1\r\n")
            f:write("echo done > \"" .. markerFile .. "\"\r\n")
            f:close()
        end
        
        -- Convert forward slashes to backslashes for Windows
        local batchPath = batchFile:gsub("/", "\\")
        
        -- Use wmic to truly spawn a detached process (never waits)
        local wmicCmd = 'wmic process call create "cmd.exe /c \\"' .. batchPath .. '\\""'
        os.execute(wmicCmd .. " > nul 2>&1")
    else
        -- Unix: use & to background the process
        local shellFile = PARALLEL_TEMP_DIR .. "/" .. jobId .. ".sh"
        local f = io.open(shellFile, "w")
        if f then
            f:write("#!/bin/bash\n")
            f:write("cd \"" .. cwd .. "\"\n")
            f:write("(" .. cmd .. ") > \"" .. logFile .. "\" 2>&1\n")
            f:write("echo done > \"" .. markerFile .. "\"\n")
            f:close()
        end
        os.execute("chmod +x \"" .. shellFile .. "\" && nohup \"" .. shellFile .. "\" > /dev/null 2>&1 &")
    end
    
    print("  [ASYNC] Starting: " .. jobId)
    return jobId
end



-- Check if a job has completed
local function is_job_done(jobId)
    local markerFile = PARALLEL_TEMP_DIR .. "/" .. jobId .. ".done"
    local f = io.open(markerFile, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Read job output log
local function get_job_log(jobId)
    local logFile = PARALLEL_TEMP_DIR .. "/" .. jobId .. ".log"
    local f = io.open(logFile, "r")
    if f then
        local content = f:read("*all")
        f:close()
        return content
    end
    return ""
end

-- Setup parallel temp directory
local function setup_parallel_dir()
    if isWindows then
        os.execute('if not exist "' .. PARALLEL_TEMP_DIR .. '" mkdir "' .. PARALLEL_TEMP_DIR .. '"')
    else
        os.execute('mkdir -p "' .. PARALLEL_TEMP_DIR .. '"')
    end
end

-- Cleanup parallel temp directory
local function cleanup_parallel_dir()
    if isWindows then
        os.execute('if exist "' .. PARALLEL_TEMP_DIR .. '" rmdir /s /q "' .. PARALLEL_TEMP_DIR .. '" 2>nul')
    else
        os.execute('rm -rf "' .. PARALLEL_TEMP_DIR .. '" 2>/dev/null')
    end
end

-- Wait for all jobs to complete with a spinner
local function wait_for_jobs(jobIds, timeout)
    timeout = timeout or 600 -- 10 minute default timeout
    local startTime = os.time()
    local spinChars = {"|", "/", "-", "\\"}
    local spinIdx = 1
    
    while true do
        local allDone = true
        local completed = 0
        
        for _, jobId in ipairs(jobIds) do
            if is_job_done(jobId) then
                completed = completed + 1
            else
                allDone = false
            end
        end
        
        if allDone then
            print(string.format("\n  [✓] All %d jobs completed!", #jobIds))
            return true
        end
        
        -- Check timeout
        if os.time() - startTime > timeout then
            print("\n  [!] Timeout waiting for jobs!")
            return false
        end
        
        -- Show progress spinner
        io.write(string.format("\r  [%s] Waiting... (%d/%d complete)", 
            spinChars[spinIdx], completed, #jobIds))
        io.flush()
        spinIdx = (spinIdx % #spinChars) + 1
        
        -- Sleep a bit (Lua doesn't have built-in sleep, so we use a busy wait or socket)
        -- For Windows, use a ping trick; for Unix, use sleep
        if isWindows then
            os.execute("ping -n 2 127.0.0.1 > nul")
        else
            os.execute("sleep 1")
        end
    end
end

-- Print all job logs
local function print_job_logs(jobIds)
    print("\n========== Job Logs ==========")
    for _, jobId in ipairs(jobIds) do
        local log = get_job_log(jobId)
        print(string.format("\n--- [%s] ---", jobId))
        print(log)
    end
    print("==============================\n")
end

local function preprocess(scriptName)
    print("  [+] Preprocessing " .. scriptName .. "...")
    local input = scriptName .. ".lua"
    local output = scriptName .. ".preprocessed.lua"
    return run_command("lua preprocess.lua " .. input .. " " .. output)
end

local function obfuscate(scriptName, usePreprocessed)
    print("  [+] Obfuscating " .. scriptName .. " (" .. OBFUSCATION_PRESET .. " Preset)...")
    if ENABLE_COMPRESSION then
        print("      (Compression Enabled)")
    end
    local input = usePreprocessed and ("../" .. scriptName .. ".preprocessed.lua") or ("../" .. scriptName .. ".lua")
    local output = "../" .. scriptName .. ".obfuscated.lua"
    
    -- We cd into Moonstar because it depends on relative paths for its modules
    local cmd = "cd Moonstar && lua moonstar.lua " .. input .. " " .. output .. " --preset=" .. OBFUSCATION_PRESET
    
    if ENABLE_COMPRESSION then
        cmd = cmd .. " --compress"
    end
    
    return run_command(cmd)
end

-- Build command for async execution (returns the full pipeline command string)
local function build_full_pipeline_cmd(scriptObj)
    local name = scriptObj.id
    local needsPreprocess = scriptObj.needsPreprocess
    local input = needsPreprocess and ("../" .. name .. ".preprocessed.lua") or ("../" .. name .. ".lua")
    local output = "../" .. name .. ".obfuscated.lua"
    
    local cmds = {}
    
    -- Preprocess step (if needed)
    if needsPreprocess then
        table.insert(cmds, "lua preprocess.lua " .. name .. ".lua " .. name .. ".preprocessed.lua")
    end
    
    -- Obfuscate step (needs to cd into Moonstar first, use subshell to avoid changing cwd)
    local obfCmd = "(cd Moonstar && lua moonstar.lua " .. input .. " " .. output .. " --preset=" .. OBFUSCATION_PRESET
    if ENABLE_COMPRESSION then
        obfCmd = obfCmd .. " --compress"
    end
    obfCmd = obfCmd .. ")"  -- Close the subshell
    table.insert(cmds, obfCmd)
    
    -- Upload step
    local key = name .. ".lua"
    local path = name .. ".obfuscated.lua"
    local uploadCmd = 'wrangler kv key put "' .. key .. '" --binding=SCRIPTS --path="' .. path .. '" --config wrangler.toml --remote'
    table.insert(cmds, uploadCmd)
    
    -- Join commands with && for sequential execution within this job
    return table.concat(cmds, " && ")
end

local function upload(scriptName)
    print("  [+] Uploading " .. scriptName .. " to Cloudflare KV...")
    local key = scriptName .. ".lua"
    local path = scriptName .. ".obfuscated.lua"
    -- Using --remote to ensure it goes to the real KV
    local cmd = 'wrangler kv key put "' .. key .. '" --binding=SCRIPTS --path="' .. path .. '" --config wrangler.toml --remote'
    return run_command(cmd)
end

local function cleanup(scriptName)
    print("  [+] Cleaning up temp files for " .. scriptName .. "...")
    local preprocessed = scriptName .. ".preprocessed.lua"
    local obfuscated = scriptName .. ".obfuscated.lua"
    
    -- Check if files exist and delete them
    local isWindows = package.config:sub(1,1) == "\\"
    
    if isWindows then
        os.execute('if exist "' .. preprocessed .. '" del "' .. preprocessed .. '" 2>nul')
        os.execute('if exist "' .. obfuscated .. '" del "' .. obfuscated .. '" 2>nul')
    else
        os.execute('rm -f "' .. preprocessed .. '" 2>/dev/null')
        os.execute('rm -f "' .. obfuscated .. '" 2>/dev/null')
    end
    
    return true
end

local function cleanup_all()
    print("\n----------------------------------------")
    print(" Action: CLEANUP ALL TEMP FILES")
    print("----------------------------------------")
    
    for _, s in ipairs(SCRIPTS) do
        cleanup(s.id)
    end
    
    print("  [+] Cleanup complete!")
    return true
end

local function perform_action(action, scriptObj)
    local name = scriptObj.id
    local needsPreprocess = scriptObj.needsPreprocess
    
    print("\n----------------------------------------")
    print(" Action: " .. action:upper() .. " [" .. name .. "]")
    print("----------------------------------------")
    
    if action == "preprocess" then
        if needsPreprocess then
            if not preprocess(name) then return false end
        else
            print("  [i] Skipping preprocess (not required for " .. name .. ")")
        end
        
    elseif action == "obfuscate" then
        if not obfuscate(name, needsPreprocess) then return false end
        
    elseif action == "upload" then
        if not upload(name) then return false end
        
    elseif action == "full" then
        if needsPreprocess then
            if not preprocess(name) then return false end
        end
        if not obfuscate(name, needsPreprocess) then return false end
        if not upload(name) then return false end
        cleanup(name) -- Clean up temp files after successful upload
    end
    
    return true
end

local function clear_screen()
    if package.config:sub(1,1) == "\\" then
        os.execute("cls")
    else
        os.execute("clear")
    end
end

local function get_script_selection()
    print("\nSelect Target:")
    print("1. ALL Scripts")
    for i, s in ipairs(SCRIPTS) do
        print(tostring(i + 1) .. ". " .. s.label)
    end
    print(tostring(#SCRIPTS + 2) .. ". Back to Main Menu")
    
    io.write("\nChoice: ")
    local choice = tonumber(io.read())
    if not choice then return nil end
    
    if choice == 1 then return "all" end
    if choice >= 2 and choice <= #SCRIPTS + 1 then
        return SCRIPTS[choice - 1]
    end
    return "back"
end

-- Execute all scripts in parallel for a given action
local function execute_all_parallel(action)
    setup_parallel_dir()
    
    print("\n============================================")
    print(" PARALLEL EXECUTION: " .. action:upper() .. " (" .. #SCRIPTS .. " scripts)")
    print("============================================")
    
    local jobIds = {}
    
    for _, s in ipairs(SCRIPTS) do
        local cmd
        local jobId = action .. "_" .. s.id
        
        if action == "full" then
            cmd = build_full_pipeline_cmd(s)
        elseif action == "preprocess" then
            if s.needsPreprocess then
                cmd = "lua preprocess.lua " .. s.id .. ".lua " .. s.id .. ".preprocessed.lua"
            end
        elseif action == "obfuscate" then
            local input = s.needsPreprocess and ("../" .. s.id .. ".preprocessed.lua") or ("../" .. s.id .. ".lua")
            local output = "../" .. s.id .. ".obfuscated.lua"
            cmd = "cd Moonstar && lua moonstar.lua " .. input .. " " .. output .. " --preset=" .. OBFUSCATION_PRESET
            if ENABLE_COMPRESSION then
                cmd = cmd .. " --compress"
            end
        elseif action == "upload" then
            local key = s.id .. ".lua"
            local path = s.id .. ".obfuscated.lua"
            cmd = 'wrangler kv key put "' .. key .. '" --binding=SCRIPTS --path="' .. path .. '" --config wrangler.toml --remote'
        end
        
        if cmd then
            run_command_async(cmd, jobId)
            table.insert(jobIds, jobId)
        else
            print("  [SKIP] " .. s.id .. " (not applicable for " .. action .. ")")
        end
    end
    
    if #jobIds > 0 then
        local success = wait_for_jobs(jobIds)
        print_job_logs(jobIds)
        
        -- Cleanup temp files if full deployment
        if action == "full" then
            print("\n  [+] Cleaning up temp files...")
            for _, s in ipairs(SCRIPTS) do
                cleanup(s.id)
            end
        end
    end
    
    cleanup_parallel_dir()
end

local function execute_task(action)
    local selection = get_script_selection()
    if selection == "back" or selection == nil then return end
    
    if selection == "all" then
        -- Use parallel execution for ALL scripts
        execute_all_parallel(action)
    else
        -- Single script - run sequentially as before
        perform_action(action, selection)
    end
    
    print("\n>>> Operation Complete")
    print("Press Enter to continue...")
    io.read()
    clear_screen()
end

local function show_main_menu()
    print("")
    print("#############################################")
    print("#      LUNARITY DEPLOYMENT MANAGER          #")
    print("#      (" .. OBFUSCATION_PRESET .. " Preset + KV Upload)          #")
    print("#############################################")
    print("")
    print("1. Full Deployment (Preprocess -> Obfuscate -> Upload -> Cleanup)")
    print("2. Preprocess Only")
    print("3. Obfuscate Only")
    print("4. Upload Only")
    print("5. Cleanup Temp Files")
    print("6. Exit")
    print("")
    io.write("Select Option (1-6): ")
end

-- Main Loop
clear_screen()
while true do
    show_main_menu()
    local choice = io.read()
    
    if choice == "1" then
        execute_task("full")
    elseif choice == "2" then
        execute_task("preprocess")
    elseif choice == "3" then
        execute_task("obfuscate")
    elseif choice == "4" then
        execute_task("upload")
    elseif choice == "5" then
        cleanup_all()
        print("\nPress Enter to continue...")
        io.read()
        clear_screen()
    elseif choice == "6" then
        print("\nExiting...")
        break
    else
        print("\nInvalid option. Please try again.")
        print("Press Enter to continue...")
        io.read()
        clear_screen()
    end
end

local SCRIPTS = {
    { id = "loader", label = "Loader", needsPreprocess = false },
    { id = "lunarity", label = "Lunarity", needsPreprocess = true },
    { id = "DoorESP", label = "DoorESP", needsPreprocess = true },
    { id = "Teleport", label = "Teleport", needsPreprocess = false },
    { id = "RemoteLogger", label = "RemoteLogger", needsPreprocess = true },
    { id = "AetherShitterRecode", label = "AetherShitter", needsPreprocess = false },
}

-- Check for compression flag and parallel setting
local USE_COMPRESSION = false
local PARALLEL_TESTS = 4

for _, v in ipairs(arg or {}) do
    if v == "--compress" or v == "--compression" then
        USE_COMPRESSION = true
    elseif v:match("^--parallel=") then
        PARALLEL_TESTS = tonumber(v:match("^--parallel=(.+)$")) or 4
    end
end

local function run_command(cmd)
    print("\n> " .. cmd)
    local success, exit_type, exit_code = os.execute(cmd)
    if not success then
        print("Error running command: " .. cmd)
        return false
    end
    return true
end

local function preprocess(scriptName)
    print("  [+] Preprocessing " .. scriptName .. "...")
    local input = scriptName .. ".lua"
    local output = scriptName .. ".preprocessed.lua"
    return run_command("lua preprocess.lua " .. input .. " " .. output)
end

local function obfuscate(scriptName, usePreprocessed)
    print("  [+] Obfuscating " .. scriptName .. " (Strong Preset)...")
    if USE_COMPRESSION then
        print("      (Compression Enabled)")
    end
    local input = usePreprocessed and ("../" .. scriptName .. ".preprocessed.lua") or ("../" .. scriptName .. ".lua")
    local output = "../" .. scriptName .. ".obfuscated.lua"
    
    -- We cd into Moonstar because it likely depends on relative paths for its modules
    local cmd = "cd Moonstar && lua moonstar.lua " .. input .. " " .. output .. " --preset=Strong"
    
    if USE_COMPRESSION then
        cmd = cmd .. " --compress --parallel=" .. tostring(PARALLEL_TESTS)
    end
    
    return run_command(cmd)
end

local function upload(scriptName)
    print("  [+] Uploading " .. scriptName .. " to Cloudflare KV...")
    local key = scriptName .. ".lua"
    local path = scriptName .. ".obfuscated.lua"
    -- Using --remote to ensure it goes to the real KV
    local cmd = 'wrangler kv key put "' .. key .. '" --binding=SCRIPTS --path="' .. path .. '" --config wrangler.toml --remote'
    return run_command(cmd)
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

local function execute_task(action)
    local selection = get_script_selection()
    if selection == "back" or selection == nil then return end
    
    if selection == "all" then
        for _, s in ipairs(SCRIPTS) do
            perform_action(action, s)
        end
    else
        perform_action(action, selection)
    end
    
    print("\n>>> Operation Complete")
    print("Press Enter to continue...")
    io.read()
    clear_screen()
end

local function show_main_menu()
    print([[

#############################################
#      LUNARITY DEPLOYMENT MANAGER          #
#      (Strong Preset + KV Upload)          #
#############################################

1. Full Deployment (Preprocess -> Obfuscate -> Upload)
2. Preprocess Only
3. Obfuscate Only
4. Upload Only
5. Exit
]])
    io.write("Select Option (1-5): ")
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
        print("\nExiting...")
        break
    else
        print("\nInvalid option. Please try again.")
        print("Press Enter to continue...")
        io.read()
        clear_screen()
    end
end

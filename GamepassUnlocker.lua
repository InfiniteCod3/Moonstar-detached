--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                     GAMEPASS BYPASS PROOF OF CONCEPT                       ║
    ║                         Exploit-Compatible Version                         ║
    ╠═══════════════════════════════════════════════════════════════════════════╣
    ║  Author: Security Researcher                                               ║
    ║  Target: Aether Game                                                       ║
    ║  Date: 2025-12-14                                                          ║
    ║                                                                            ║
    ║  PURPOSE: Demonstrates gamepass verification vulnerabilities               ║
    ║  METHODS USED:                                                             ║
    ║    - Namecall hooking (MarketplaceService spoofing)                        ║
    ║    - Direct remote firing (WeaponEquip bypass)                             ║
    ║    - Attribute reading (finding tester weapons)                            ║
    ║                                                                            ║
    ║  VULNERABILITIES EXPLOITED:                                                ║
    ║  1. MarketplaceService:UserOwnsGamePassAsync is called client-side         ║
    ║  2. WeaponEquip remote may lack server-side gamepass verification          ║
    ║  3. All weapon data (including tester weapons) is replicated to clients    ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local LOADER_SCRIPT_ID = "gamepassUnlocker"
local LoaderAccess = rawget(getgenv(), "LunarityAccess")
local ScriptActive = true

-- XOR encryption/decryption for payload obfuscation (matches loader)
local function xorCrypt(input, key)
    local output = {}
    local keyLen = #key
    for i = 1, #input do
        local keyByte = string.byte(key, ((i - 1) % keyLen) + 1)
        local inputByte = string.byte(input, i)
        output[i] = string.char(bit32.bxor(inputByte, keyByte))
    end
    return table.concat(output)
end

local function base64Encode(data)
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = {}
    local bytes = { string.byte(data, 1, #data) }
    local i = 1
    while i <= #bytes do
        local b1 = bytes[i] or 0
        local b2 = bytes[i + 1] or 0
        local b3 = bytes[i + 2] or 0
        local combined = bit32.bor(
            bit32.lshift(b1, 16),
            bit32.lshift(b2, 8),
            b3
        )
        table.insert(result, string.sub(b64chars, bit32.rshift(combined, 18) % 64 + 1, bit32.rshift(combined, 18) % 64 + 1))
        table.insert(result, string.sub(b64chars, bit32.rshift(combined, 12) % 64 + 1, bit32.rshift(combined, 12) % 64 + 1))
        if i + 1 <= #bytes then
            table.insert(result, string.sub(b64chars, bit32.rshift(combined, 6) % 64 + 1, bit32.rshift(combined, 6) % 64 + 1))
        else
            table.insert(result, "=")
        end
        if i + 2 <= #bytes then
            table.insert(result, string.sub(b64chars, combined % 64 + 1, combined % 64 + 1))
        else
            table.insert(result, "=")
        end
        i = i + 3
    end
    return table.concat(result)
end

local function encryptPayload(plainText, key)
    local encrypted = xorCrypt(plainText, key)
    return base64Encode(encrypted)
end

local HttpRequestInvoker

do
    if typeof(http_request) == "function" then
        HttpRequestInvoker = http_request
    elseif typeof(syn) == "table" and typeof(syn.request) == "function" then
        HttpRequestInvoker = syn.request
    elseif typeof(request) == "function" then
        HttpRequestInvoker = request
    elseif typeof(http) == "table" and typeof(http.request) == "function" then
        HttpRequestInvoker = http.request
    elseif HttpService and HttpService.RequestAsync then
        HttpRequestInvoker = function(options)
            return HttpService:RequestAsync(options)
        end
    end

    local function buildValidateUrl()
        if not LoaderAccess then
            return nil
        end
        if typeof(LoaderAccess.validateUrl) == "string" then
            return LoaderAccess.validateUrl
        elseif typeof(LoaderAccess.baseUrl) == "string" then
            return LoaderAccess.baseUrl .. "/validate"
        end
        return nil
    end

    local function requestLoaderValidation(refresh)
        if not LoaderAccess then
            return false, "Loader access token missing"
        end
        if not HttpRequestInvoker then
            return false, "Executor lacks HTTP support"
        end
        local validateUrl = buildValidateUrl()
        if not validateUrl then
            return false, "Validation endpoint unavailable"
        end

        local payload = {
            token = LoaderAccess.token,
            scriptId = LOADER_SCRIPT_ID,
            refresh = refresh ~= false,
        }

        local encodedOk, encodedPayload = pcall(HttpService.JSONEncode, HttpService, payload)
        if not encodedOk then
            return false, "Failed to encode validation payload"
        end

        -- Encrypt the payload if encryption key is available
        local requestBody = encodedPayload
        if LoaderAccess.encryptionKey then
            requestBody = encryptPayload(encodedPayload, LoaderAccess.encryptionKey)
        end

        local success, response = pcall(HttpRequestInvoker, {
            Url = validateUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Accept"] = "application/json",
                ["User-Agent"] = LoaderAccess.userAgent or "LunarityLoader/1.0",
            },
            Body = requestBody,
        })

        if not success then
            return false, tostring(response)
        end

        local statusCode = response.StatusCode or response.Status or response.status_code
        local bodyText = response.Body or response.body or ""
        if statusCode and (statusCode < 200 or statusCode >= 300) then
            return false, bodyText ~= "" and bodyText or ("HTTP " .. tostring(statusCode))
        end

        local decodeOk, decoded = pcall(HttpService.JSONDecode, HttpService, bodyText)
        if not decodeOk then
            return false, "Invalid JSON from worker"
        end

        if decoded.ok ~= true then
            return false, decoded.reason or "Validation denied"
        end

        -- Dynamic token rotation: update the token if a new one was provided
        if decoded.newToken and typeof(decoded.newToken) == "string" then
            LoaderAccess.token = decoded.newToken
        end

        return true, decoded
    end

    local function enforceLoaderWhitelist()
        if not LoaderAccess or LoaderAccess.scriptId ~= LOADER_SCRIPT_ID then
            warn("[GamepassUnlocker] This build must be launched via the official loader.")
            return false
        end

        local ok, response = requestLoaderValidation(true)
        if not ok then
            warn("[GamepassUnlocker] Loader validation failed: " .. tostring(response))
            return false
        end

        if response.killSwitch then
            warn("[GamepassUnlocker] Loader kill switch active. Aborting.")
            return false
        end

        local refreshInterval = math.clamp(LoaderAccess.refreshInterval or 90, 30, 240)
        task.spawn(function()
            while ScriptActive do
                task.wait(refreshInterval)
                local valid, data = requestLoaderValidation(true)
                if not valid or (data and data.killSwitch) then
                    warn("[GamepassUnlocker] Access revoked or kill switch activated. Shutting down.")
                    ScriptActive = false
                    break
                end
            end
        end)

        getgenv().LunarityAccess = nil
        return true
    end

    if not enforceLoaderWhitelist() then
        return
    end
end

-- // ============================
-- // SCRIPT FUNCTIONALITY STARTS HERE
-- // ============================

-- Configuration
local CONFIG = {
    -- Known Gamepass IDs from game analysis
    GAMEPASSES = {
        226976702,      -- Tester Access Gamepass 1
        1470484530,     -- Tester Access Gamepass 2
    },
    
    -- Known tester usernames (from Testers.luau analysis)
    KNOWN_TESTERS = {
        "Gynaus", "cccccrusher", "htlr_diff", "Inner_darkness", "Madooxs", 
        "FonBoom", "JustSa_v", "redrockergaming", "mrtouie", "NicozONYT",
        "Martin_man26", "ChurtaSiaJr", "cooljayzf", "SYCOStudios", "ForeverMillennium",
        "nxsebloodd", "Kraydome", "Hyperialy", "TiccoTacco3", "Nevil0004",
        "sulaamonstersAlt", "Guest_67076", "EL_OCURLDAD", "VickzyZY", "Is_yupd",
        "ShanShan_bBAy", "Rune_Valkyrie", "sulaamonster", "noobthewarrior4",
        "Rastek36", "rebal", "MAJ1NN", "gaslight3r", "Takayoni", "impurgory"
    }
}

-- State
local State = {
    GamepassHookEnabled = false,
    OriginalNamecall = nil,
    TesterWeapons = {},
    UnreleasedWeapons = {},
    AllWeapons = {},
}

--[[
    ═══════════════════════════════════════════════════════════════════════════
    EXPLOIT METHOD #1: Namecall Hook - Spoof Gamepass Ownership
    
    The game calls MarketplaceService:UserOwnsGamePassAsync() on the CLIENT
    to check if the player owns tester gamepasses. By hooking __namecall,
    we can intercept this call and return true.
    
    This works because:
    1. The check happens client-side in UiController/init.luau lines 60-65
    2. The result is stored in a local variable that controls weapon access
    3. No server-side re-verification occurs for displaying weapons
    
    FIX FOR GAME OWNER: Never trust client-side gamepass checks!
    ═══════════════════════════════════════════════════════════════════════════
]]

local function enableGamepassHook()
    if State.GamepassHookEnabled then
        print("[Lunarity] Hook already active")
        return true
    end
    
    -- Method 1: hookmetamethod (Synapse X, Script-Ware, Fluxus, etc.)
    if hookmetamethod and getnamecallmethod then
        local success, result = pcall(function()
            State.OriginalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                
                if method == "UserOwnsGamePassAsync" and self == MarketplaceService then
                    local args = {...}
                    local gamepassId = args[2]
                    
                    if table.find(CONFIG.GAMEPASSES, gamepassId) then
                        print("[Lunarity] Spoofed gamepass: " .. tostring(gamepassId))
                        return true
                    end
                end
                
                return State.OriginalNamecall(self, ...)
            end))
        end)
        
        if success then
            State.GamepassHookEnabled = true
            print("[Lunarity] Hook enabled (hookmetamethod)")
            return true
        end
    end
    
    -- Method 2: getrawmetatable + setreadonly (Krnl, Oxygen, etc.)
    if getrawmetatable and setreadonly and getnamecallmethod then
        local success, result = pcall(function()
            local mt = getrawmetatable(game)
            local oldNamecall = mt.__namecall
            
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                
                if method == "UserOwnsGamePassAsync" and self == MarketplaceService then
                    local args = {...}
                    local gamepassId = args[2]
                    
                    if table.find(CONFIG.GAMEPASSES, gamepassId) then
                        print("[Lunarity] Spoofed gamepass: " .. tostring(gamepassId))
                        return true
                    end
                end
                
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
            
            State.OriginalNamecall = oldNamecall
        end)
        
        if success then
            State.GamepassHookEnabled = true
            print("[Lunarity] Hook enabled (getrawmetatable)")
            return true
        end
    end
    
    -- Method 3: hookfunction on specific method (some executors)
    if hookfunction then
        local success, result = pcall(function()
            local originalFunc = MarketplaceService.UserOwnsGamePassAsync
            
            State.OriginalNamecall = hookfunction(originalFunc, newcclosure(function(self, userId, gamepassId)
                if table.find(CONFIG.GAMEPASSES, gamepassId) then
                    print("[Lunarity] Spoofed gamepass: " .. tostring(gamepassId))
                    return true
                end
                return State.OriginalNamecall(self, userId, gamepassId)
            end))
        end)
        
        if success then
            State.GamepassHookEnabled = true
            print("[Lunarity] Hook enabled (hookfunction)")
            return true
        end
    end
    
    -- Method 4: Direct metatable manipulation (fallback)
    local success = pcall(function()
        local mt = getmetatable(game)
        if mt and mt.__namecall then
            -- Some executors allow this without setreadonly
            local oldNamecall = mt.__namecall
            mt.__namecall = function(self, ...)
                local args = {...}
                local method = args[#args] -- Last arg is often the method name
                
                if tostring(self) == "MarketplaceService" then
                    -- Try to detect UserOwnsGamePassAsync call
                    for _, v in ipairs(args) do
                        if table.find(CONFIG.GAMEPASSES, v) then
                            print("[Lunarity] Spoofed gamepass: " .. tostring(v))
                            return true
                        end
                    end
                end
                
                return oldNamecall(self, ...)
            end
            State.OriginalNamecall = oldNamecall
        end
    end)
    
    if success then
        State.GamepassHookEnabled = true
        print("[Lunarity] Hook enabled (metatable)")
        return true
    end
    
    -- No hook method available
    print("[Lunarity] Warning: No hook method available")
    print("[Lunarity] The gamepass check already ran at game load")
    print("[Lunarity] Use 'Inject Weapons to Game Menu' instead!")
    print("[Lunarity] You can still equip weapons directly from the list")
    return false
end

local function disableGamepassHook()
    if not State.GamepassHookEnabled then
        print("[Lunarity] Hook not active")
        return
    end
    
    -- Try to restore original function
    pcall(function()
        if hookmetamethod and State.OriginalNamecall then
            hookmetamethod(game, "__namecall", State.OriginalNamecall)
        elseif getrawmetatable and setreadonly and State.OriginalNamecall then
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            mt.__namecall = State.OriginalNamecall
            setreadonly(mt, true)
        end
    end)
    
    State.GamepassHookEnabled = false
    State.OriginalNamecall = nil
    print("[Lunarity] Hook disabled")
end

--[[
    ═══════════════════════════════════════════════════════════════════════════
    EXPLOIT METHOD #2: Direct Weapon Data Access
    
    All weapon data including tester-exclusive weapons is stored in
    ReplicatedStorage.Weapons and replicated to ALL clients.
    
    We can read weapon attributes directly without any module requires.
    
    FIX FOR GAME OWNER: Don't replicate tester weapon data to non-testers!
    ═══════════════════════════════════════════════════════════════════════════
]]

local function scanWeapons()
    print("\n[SCAN] Scanning weapon data...")
    print("=" .. string.rep("=", 60))
    
    State.TesterWeapons = {}
    State.UnreleasedWeapons = {}
    State.AllWeapons = {}
    
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if not weapons then
        print("[-] Could not find Weapons folder")
        return
    end
    
    for _, weapon in ipairs(weapons:GetChildren()) do
        local weaponKey = weapon:GetAttribute("WeaponKey")
        local released = weapon:GetAttribute("Released")
        local displayName = weapon:GetAttribute("DisplayName") or weapon.Name
        local spec = weapon:GetAttribute("Spec")
        
        local weaponData = {
            name = weapon.Name,
            displayName = displayName,
            weaponKey = weaponKey,
            released = released,
            spec = spec,
        }
        
        table.insert(State.AllWeapons, weaponData)
        
        if weaponKey == "TesterWeapon" then
            table.insert(State.TesterWeapons, weaponData)
        end
        
        if released == false then
            table.insert(State.UnreleasedWeapons, weaponData)
        end
    end
    
    print("[+] Total weapons found: " .. #State.AllWeapons)
    print("[+] Tester weapons: " .. #State.TesterWeapons)
    print("[+] Unreleased weapons: " .. #State.UnreleasedWeapons)
    
    if #State.TesterWeapons > 0 then
        print("\n[TESTER WEAPONS]")
        for _, w in ipairs(State.TesterWeapons) do
            print("    ⚔️ " .. w.name .. " (" .. (w.displayName or "no display name") .. ")")
        end
    end
    
    if #State.UnreleasedWeapons > 0 then
        print("\n[UNRELEASED WEAPONS]")
        for _, w in ipairs(State.UnreleasedWeapons) do
            print("    🔒 " .. w.name .. " (" .. (w.displayName or "no display name") .. ")")
        end
    end
    
    return State.TesterWeapons, State.UnreleasedWeapons
end

--[[
    ═══════════════════════════════════════════════════════════════════════════
    EXPLOIT METHOD #3: Direct Remote Firing - Equip Any Weapon
    
    The WeaponEquip remote can be fired directly to attempt equipping
    any weapon. The server SHOULD validate gamepass ownership, but
    based on the decompiled code, it may not properly do so.
    
    FIX FOR GAME OWNER: Always verify gamepass/ownership server-side!
    ═══════════════════════════════════════════════════════════════════════════
]]

local function getWeaponEquipRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        return remotes:FindFirstChild("WeaponEquip")
    end
    return nil
end

local function equipWeapon(weaponName)
    print("\n[EQUIP] Attempting to equip: " .. weaponName)
    print("=" .. string.rep("=", 60))
    
    local remote = getWeaponEquipRemote()
    if not remote then
        print("[-] WeaponEquip remote not found")
        return false
    end
    
    local success, err = pcall(function()
        remote:FireServer(weaponName)
    end)
    
    if success then
        print("[+] WeaponEquip:FireServer('" .. weaponName .. "') - SENT!")
        print("[!] Check if weapon equipped in-game")
        return true
    else
        print("[-] Error: " .. tostring(err))
        return false
    end
end

local function equipAllTesterWeapons()
    if #State.TesterWeapons == 0 then
        scanWeapons()
    end
    
    print("\n[MASS EQUIP] Attempting to equip all tester weapons...")
    for _, weapon in ipairs(State.TesterWeapons) do
        equipWeapon(weapon.name)
        task.wait(0.5)
    end
end

--[[
    ═══════════════════════════════════════════════════════════════════════════
    EXPLOIT METHOD #4: Spoof Tester Name (Alternative)
    
    If the game checks username against a whitelist, we can try to find
    and modify that check. However, since we can't require modules,
    the namecall hook method is more reliable.
    
    This function just demonstrates reading the known testers.
    ═══════════════════════════════════════════════════════════════════════════
]]

local function showKnownTesters()
    print("\n[INFO] Known Testers (from game analysis):")
    print("=" .. string.rep("=", 60))
    for i, name in ipairs(CONFIG.KNOWN_TESTERS) do
        local marker = ""
        if name == LocalPlayer.Name then
            marker = " ← YOU ARE A TESTER!"
        end
        print("    " .. i .. ". " .. name .. marker)
    end
    
    if table.find(CONFIG.KNOWN_TESTERS, LocalPlayer.Name) then
        print("\n[!] You're already on the tester list!")
        return true
    else
        print("\n[-] You're NOT on the tester list")
        print("[+] Use the gamepass hook to bypass this check")
        return false
    end
end

--[[
    ═══════════════════════════════════════════════════════════════════════════
    EXPLOIT METHOD #5: Inject Tester Weapons into Game UI
    
    The gamepass check runs ONCE when the UI loads. By the time we inject,
    the weapon menu is already populated without tester weapons.
    
    This function manually adds tester weapon buttons to the game's
    existing weapon menu, making them appear and be clickable.
    
    FIX FOR GAME OWNER: Validate on server, don't show weapons client-side!
    ═══════════════════════════════════════════════════════════════════════════
]]

local function getWeaponMenuScrollingFrame()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local mainUI = playerGui:FindFirstChild("MainUI")
    if not mainUI then return nil end
    
    local display = mainUI:FindFirstChild("Display")
    if not display then return nil end
    
    local menus = display:FindFirstChild("Menus")
    if not menus then return nil end
    
    local weaponMenu = menus:FindFirstChild("WeaponMenu")
    if not weaponMenu then return nil end
    
    local scrollingFrame = weaponMenu:FindFirstChild("ScrollingFrame")
    return scrollingFrame
end

local function injectTesterWeaponsIntoUI()
    print("\n[INJECT] Injecting tester weapons into game UI...")
    print("=" .. string.rep("=", 60))
    
    -- Scan weapons first if not done
    if #State.AllWeapons == 0 then
        scanWeapons()
    end
    
    local scrollingFrame = getWeaponMenuScrollingFrame()
    if not scrollingFrame then
        print("[-] Could not find weapon menu ScrollingFrame")
        print("[-] Make sure you're in-game and the UI is loaded")
        return false
    end
    
    print("[+] Found weapon menu ScrollingFrame")
    
    -- Find the template button (Configuration/ClassButton)
    local config = scrollingFrame:FindFirstChild("Configuration")
    local templateButton = nil
    if config then
        templateButton = config:FindFirstChild("ClassButton")
    end
    
    -- If no template, we'll create our own style
    local injectedCount = 0
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if not weapons then
        print("[-] Could not find Weapons folder")
        return false
    end
    
    for _, weapon in ipairs(weapons:GetChildren()) do
        local weaponKey = weapon:GetAttribute("WeaponKey")
        local released = weapon:GetAttribute("Released")
        local displayName = weapon:GetAttribute("DisplayName") or weapon.Name
        
        -- Check if this is a tester or unreleased weapon
        local shouldInject = (weaponKey == "TesterWeapon") or (released == false)
        
        if shouldInject then
            -- Check if button already exists
            local existingButton = scrollingFrame:FindFirstChild(displayName) or scrollingFrame:FindFirstChild(weapon.Name)
            if existingButton then
                print("[~] " .. weapon.Name .. " already in menu")
            else
                -- Create new button
                local newButton
                
                if templateButton then
                    -- Clone the template
                    newButton = templateButton:Clone()
                    newButton.Name = displayName
                    newButton.Visible = true
                    
                    -- Update text
                    local textLabel = newButton:FindFirstChild("TextLabel")
                    if textLabel then
                        textLabel.Text = string.upper(weapon.Name)
                        -- Color based on weapon type
                        if weaponKey == "TesterWeapon" then
                            textLabel.TextColor3 = Color3.fromRGB(255, 100, 100)  -- Red for tester
                        else
                            textLabel.TextColor3 = Color3.fromRGB(255, 200, 100)  -- Orange for unreleased
                        end
                    end
                    
                    -- Set attributes
                    newButton:SetAttribute("OriginalName", weapon.Name)
                    newButton:SetAttribute("WeaponKey", weaponKey)
                    
                    -- Set layout order
                    if weaponKey == "TesterWeapon" then
                        newButton.LayoutOrder = 20001 + injectedCount
                    else
                        newButton.LayoutOrder = 1 + injectedCount
                    end
                    
                    -- Hide cost frame if exists
                    local costFrame = newButton:FindFirstChild("CostFrame")
                    if costFrame then
                        costFrame.Visible = false
                    end
                else
                    -- Create simple button from scratch
                    newButton = Instance.new("TextButton")
                    newButton.Name = displayName
                    newButton.Size = UDim2.new(1, -10, 0, 35)
                    newButton.BackgroundColor3 = weaponKey == "TesterWeapon" 
                        and Color3.fromRGB(80, 30, 30) 
                        or Color3.fromRGB(80, 60, 30)
                    newButton.BorderSizePixel = 0
                    newButton.Text = "  " .. string.upper(weapon.Name)
                    newButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    newButton.TextSize = 14
                    newButton.Font = Enum.Font.GothamBold
                    newButton.TextXAlignment = Enum.TextXAlignment.Left
                    newButton.LayoutOrder = 20001 + injectedCount
                    
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 6)
                    corner.Parent = newButton
                    
                    newButton:SetAttribute("OriginalName", weapon.Name)
                    newButton:SetAttribute("WeaponKey", weaponKey)
                end
                
                -- Parent to scrolling frame
                newButton.Parent = scrollingFrame
                
                -- Connect click handler to equip weapon
                newButton.MouseButton1Click:Connect(function()
                    print("[CLICK] Attempting to equip: " .. weapon.Name)
                    local remote = getWeaponEquipRemote()
                    if remote then
                        remote:FireServer(weapon.Name)
                        print("[+] Sent equip request for: " .. weapon.Name)
                    end
                end)
                
                injectedCount = injectedCount + 1
                print("[+] Injected: " .. weapon.Name .. " (" .. (weaponKey or "unreleased") .. ")")
            end
        end
    end
    
    if injectedCount > 0 then
        print("\n[!] Successfully injected " .. injectedCount .. " weapons into game UI!")
        print("[!] Open the weapon menu to see tester weapons")
        return true
    else
        print("[~] No new weapons to inject (may already be injected)")
        return false
    end
end

local function removeInjectedWeapons()
    print("\n[CLEANUP] Removing injected weapons from game UI...")
    
    local scrollingFrame = getWeaponMenuScrollingFrame()
    if not scrollingFrame then
        print("[-] Could not find weapon menu")
        return
    end
    
    local removedCount = 0
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            local weaponKey = child:GetAttribute("WeaponKey")
            if weaponKey == "TesterWeapon" then
                child:Destroy()
                removedCount = removedCount + 1
            end
        end
    end
    
    print("[+] Removed " .. removedCount .. " injected weapons")
end

--[[
    ═══════════════════════════════════════════════════════════════════════════
    UI CREATION - Lunarity Theme (ImGUI Style)
    ═══════════════════════════════════════════════════════════════════════════
]]

-- Load shared UI module
local LunarityUI = loadstring(game:HttpGet("https://api.relayed.network/ui"))()
local Theme = LunarityUI.Theme

local function createUI()
    -- Create main window using LunarityUI
    local window = LunarityUI.CreateWindow({
        Name = "LunarityGamepassUI",
        Title = "Lunarity",
        Subtitle = "Gamepass",
        Size = UDim2.new(0, 340, 0, 520),
        Position = UDim2.new(0.5, -170, 0.5, -260),
    })
    
    local Theme = LunarityUI.Theme
    
    -- Status indicator
    local statusBar = window.createStatusBar("Hook: Disabled")
    
    local function updateStatus()
        if State.GamepassHookEnabled then
            statusBar.setText("Hook: Active")
            statusBar.setColor(Theme.Success)
        else
            statusBar.setText("Hook: Disabled")
            statusBar.setColor(Theme.Error)
        end
    end
    
    -- Gamepass Hook section
    window.createSection("Gamepass Hook")
    
    window.createButton("Enable Hook", function()
        enableGamepassHook()
        updateStatus()
    end, true)
    
    window.createButton("Disable Hook", function()
        disableGamepassHook()
        updateStatus()
    end, false)
    
    -- Weapon Scanner section
    window.createSection("Weapon Scanner")
    
    window.createButton("Scan All Weapons", function()
        scanWeapons()
        populateWeaponList()
    end, false)
    
    window.createButton("Show Known Testers", function()
        showKnownTesters()
    end, false)
    
    -- Weapon Equip section
    window.createSection("Weapon Equip")
    
    window.createButton("Equip First Tester Weapon", function()
        if #State.TesterWeapons == 0 then
            scanWeapons()
        end
        if #State.TesterWeapons > 0 then
            equipWeapon(State.TesterWeapons[1].name)
        else
            print("[!] No tester weapons found")
        end
    end, true)
    
    window.createButton("Equip All Tester Weapons", function()
        equipAllTesterWeapons()
    end, false)
    
    -- UI Injection section
    window.createSection("UI Injection")
    
    window.createButton("Inject Weapons to Game Menu", function()
        injectTesterWeaponsIntoUI()
    end, true)
    
    window.createButton("Remove Injected Weapons", function()
        removeInjectedWeapons()
    end, false)
    
    -- Weapon List section
    window.createSection("Weapon List")
    
    -- Create weapon dropdown list within the window Content
    local WeaponDropdown = Instance.new("Frame")
    WeaponDropdown.Name = "WeaponDropdown"
    WeaponDropdown.Size = UDim2.new(1, 0, 0, 140)
    WeaponDropdown.BackgroundColor3 = Theme.BackgroundLight
    WeaponDropdown.BorderSizePixel = 0
    WeaponDropdown.LayoutOrder = window.nextLayoutOrder()
    WeaponDropdown.Parent = window.Content
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 3)
    DropdownCorner.Parent = WeaponDropdown
    
    local WeaponList = Instance.new("ScrollingFrame")
    WeaponList.Name = "WeaponList"
    WeaponList.Size = UDim2.new(1, -4, 1, -4)
    WeaponList.Position = UDim2.new(0, 2, 0, 2)
    WeaponList.BackgroundTransparency = 1
    WeaponList.ScrollBarThickness = 3
    WeaponList.ScrollBarImageColor3 = Theme.Accent
    WeaponList.CanvasSize = UDim2.new(0, 0, 0, 0)
    WeaponList.Parent = WeaponDropdown
    
    local WeaponListLayout = Instance.new("UIListLayout")
    WeaponListLayout.Padding = UDim.new(0, 2)
    WeaponListLayout.Parent = WeaponList
    
    -- Populate weapon list function
    function populateWeaponList()
        -- Clear existing
        for _, child in ipairs(WeaponList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        local allWeapons = {}
        for _, w in ipairs(State.TesterWeapons or {}) do
            table.insert(allWeapons, {name = w.name, type = "tester"})
        end
        for _, w in ipairs(State.UnreleasedWeapons or {}) do
            table.insert(allWeapons, {name = w.name, type = "unreleased"})
        end
        
        local canvasHeight = 0
        
        for _, weapon in ipairs(allWeapons) do
            local prefix = weapon.type == "tester" and "[T] " or "[U] "
            local bgColor = weapon.type == "tester" and Theme.BackgroundDark or Theme.BackgroundLight
            local textColor = weapon.type == "tester" and Theme.Success or Theme.Warning
            
            local WeaponBtn = Instance.new("TextButton")
            WeaponBtn.Name = weapon.name
            WeaponBtn.Size = UDim2.new(1, -4, 0, 22)
            WeaponBtn.BackgroundColor3 = bgColor
            WeaponBtn.BorderSizePixel = 0
            WeaponBtn.Text = prefix .. weapon.name
            WeaponBtn.TextColor3 = textColor
            WeaponBtn.TextSize = 10
            WeaponBtn.Font = Enum.Font.Gotham
            WeaponBtn.TextXAlignment = Enum.TextXAlignment.Left
            WeaponBtn.AutoButtonColor = false
            WeaponBtn.Parent = WeaponList
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 2)
            BtnCorner.Parent = WeaponBtn
            
            local Padding = Instance.new("UIPadding")
            Padding.PaddingLeft = UDim.new(0, 6)
            Padding.Parent = WeaponBtn
            
            WeaponBtn.MouseEnter:Connect(function()
                WeaponBtn.BackgroundColor3 = Theme.Separator
            end)
            WeaponBtn.MouseLeave:Connect(function()
                WeaponBtn.BackgroundColor3 = bgColor
            end)
            
            WeaponBtn.MouseButton1Click:Connect(function()
                equipWeapon(weapon.name)
            end)
            
            canvasHeight = canvasHeight + 24
        end
        
        WeaponList.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    end
    
    window.createButton("Refresh List", function()
        scanWeapons()
        populateWeaponList()
    end, false)
    
    -- Info section
    window.createSection("Info")
    window.createInfoLabel("[T] = Tester | [U] = Unreleased\nPress F9 for console logs")
    
    -- Initial population
    task.spawn(function()
        task.wait(0.5)
        scanWeapons()
        populateWeaponList()
    end)
    
    print("[Lunarity] Gamepass module loaded")
end

--[[
    ═══════════════════════════════════════════════════════════════════════════
    INITIALIZATION
    ═══════════════════════════════════════════════════════════════════════════
]]

print("")
print("  Lunarity | Gamepass Bypass")
print("  --------------------------")
print("  [*] Namecall hook for gamepass spoofing")
print("  [*] Remote firing for weapon equipping")
print("  [*] UI injection for hidden weapons")
print("")

createUI()

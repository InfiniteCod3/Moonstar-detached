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

-- Color Scheme (Purple/Violet ImGUI Style)
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    BackgroundLight = Color3.fromRGB(25, 25, 35),
    BackgroundDark = Color3.fromRGB(10, 10, 15),
    Border = Color3.fromRGB(80, 60, 140),
    Accent = Color3.fromRGB(130, 90, 200),
    AccentHover = Color3.fromRGB(150, 110, 220),
    AccentDark = Color3.fromRGB(100, 70, 160),
    Text = Color3.fromRGB(220, 220, 230),
    TextDim = Color3.fromRGB(140, 140, 160),
    Success = Color3.fromRGB(90, 200, 120),
    Error = Color3.fromRGB(200, 90, 90),
    Warning = Color3.fromRGB(200, 160, 90),
    Separator = Color3.fromRGB(50, 45, 70),
}

local function createUI()
    -- Cleanup existing UI
    local existingGui = game:GetService("CoreGui"):FindFirstChild("LunarityUI")
    if existingGui then
        existingGui:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LunarityUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Parent to CoreGui to hide from game detection
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 340, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame
    
    -- Title bar (minimal)
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 28)
    TitleBar.BackgroundColor3 = Theme.BackgroundDark
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 4)
    TitleCorner.Parent = TitleBar
    
    -- Fix bottom corners
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 8)
    TitleFix.Position = UDim2.new(0, 0, 1, -8)
    TitleFix.BackgroundColor3 = Theme.BackgroundDark
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Lunarity"
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0, 100, 1, 0)
    Subtitle.Position = UDim2.new(0, 70, 0, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "| gamepass"
    Subtitle.TextColor3 = Theme.TextDim
    Subtitle.TextSize = 12
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = TitleBar
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -28, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "x"
    CloseBtn.TextColor3 = Theme.TextDim
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.Parent = TitleBar
    
    CloseBtn.MouseEnter:Connect(function()
        CloseBtn.TextColor3 = Theme.Error
    end)
    CloseBtn.MouseLeave:Connect(function()
        CloseBtn.TextColor3 = Theme.TextDim
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(1, -56, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Theme.TextDim
    MinBtn.TextSize = 16
    MinBtn.Font = Enum.Font.Gotham
    MinBtn.Parent = TitleBar
    
    local minimized = false
    local originalSize = MainFrame.Size
    
    MinBtn.MouseEnter:Connect(function()
        MinBtn.TextColor3 = Theme.Accent
    end)
    MinBtn.MouseLeave:Connect(function()
        MinBtn.TextColor3 = Theme.TextDim
    end)
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            MainFrame.Size = UDim2.new(0, 340, 0, 28)
        else
            MainFrame.Size = originalSize
        end
    end)
    
    -- Content area
    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -16, 1, -36)
    Content.Position = UDim2.new(0, 8, 0, 32)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 2
    Content.ScrollBarImageColor3 = Theme.Accent
    Content.CanvasSize = UDim2.new(0, 0, 0, 680)
    Content.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 4)
    UIListLayout.Parent = Content
    
    -- Helper: Create separator/section header
    local function createSection(title, layoutOrder)
        local Section = Instance.new("Frame")
        Section.Name = title
        Section.Size = UDim2.new(1, 0, 0, 22)
        Section.BackgroundTransparency = 1
        Section.LayoutOrder = layoutOrder
        Section.Parent = Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(title)
        Label.TextColor3 = Theme.TextDim
        Label.TextSize = 10
        Label.Font = Enum.Font.GothamBold
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Section
        
        -- Separator line
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(1, 0, 0, 1)
        Line.Position = UDim2.new(0, 0, 1, -1)
        Line.BackgroundColor3 = Theme.Separator
        Line.BorderSizePixel = 0
        Line.Parent = Section
        
        return Section
    end
    
    -- Helper: Create ImGUI-style button
    local function createButton(text, callback, layoutOrder, accent)
        local btnColor = accent and Theme.Accent or Theme.BackgroundLight
        local btnHover = accent and Theme.AccentHover or Theme.Separator
        
        local Button = Instance.new("TextButton")
        Button.Name = text
        Button.Size = UDim2.new(1, 0, 0, 26)
        Button.BackgroundColor3 = btnColor
        Button.BorderSizePixel = 0
        Button.Text = text
        Button.TextColor3 = Theme.Text
        Button.TextSize = 12
        Button.Font = Enum.Font.Gotham
        Button.LayoutOrder = layoutOrder
        Button.AutoButtonColor = false
        Button.Parent = Content
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 3)
        Corner.Parent = Button
        
        Button.MouseButton1Click:Connect(callback)
        
        Button.MouseEnter:Connect(function()
            Button.BackgroundColor3 = btnHover
        end)
        Button.MouseLeave:Connect(function()
            Button.BackgroundColor3 = btnColor
        end)
        
        return Button
    end
    
    -- Status indicator
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Name = "Status"
    StatusFrame.Size = UDim2.new(1, 0, 0, 28)
    StatusFrame.BackgroundColor3 = Theme.BackgroundLight
    StatusFrame.BorderSizePixel = 0
    StatusFrame.LayoutOrder = 0
    StatusFrame.Parent = Content
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 3)
    StatusCorner.Parent = StatusFrame
    
    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.Name = "Indicator"
    StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
    StatusIndicator.Position = UDim2.new(0, 10, 0.5, -4)
    StatusIndicator.BackgroundColor3 = Theme.Error
    StatusIndicator.Parent = StatusFrame
    
    local StatusIndicatorCorner = Instance.new("UICorner")
    StatusIndicatorCorner.CornerRadius = UDim.new(1, 0)
    StatusIndicatorCorner.Parent = StatusIndicator
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Size = UDim2.new(1, -30, 1, 0)
    StatusText.Position = UDim2.new(0, 26, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Hook: Disabled"
    StatusText.TextColor3 = Theme.TextDim
    StatusText.TextSize = 11
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = StatusFrame
    
    local function updateStatus()
        if State.GamepassHookEnabled then
            StatusIndicator.BackgroundColor3 = Theme.Success
            StatusText.Text = "Hook: Active"
            StatusText.TextColor3 = Theme.Success
        else
            StatusIndicator.BackgroundColor3 = Theme.Error
            StatusText.Text = "Hook: Disabled"
            StatusText.TextColor3 = Theme.TextDim
        end
    end
    
    -- Create UI elements
    createSection("Gamepass Hook", 1)
    
    createButton("Enable Hook", function()
        enableGamepassHook()
        updateStatus()
    end, 2, true)
    
    createButton("Disable Hook", function()
        disableGamepassHook()
        updateStatus()
    end, 3)
    
    createSection("Weapon Scanner", 4)
    
    createButton("Scan All Weapons", function()
        scanWeapons()
    end, 5)
    
    createButton("Show Known Testers", function()
        showKnownTesters()
    end, 6)
    
    createSection("Weapon Equip", 7)
    
    createButton("Equip First Tester Weapon", function()
        if #State.TesterWeapons == 0 then
            scanWeapons()
        end
        if #State.TesterWeapons > 0 then
            equipWeapon(State.TesterWeapons[1].name)
        else
            print("[!] No tester weapons found")
        end
    end, 8, true)
    
    createButton("Equip All Tester Weapons", function()
        equipAllTesterWeapons()
    end, 9)
    
    createSection("UI Injection", 10)
    
    createButton("Inject Weapons to Game Menu", function()
        injectTesterWeaponsIntoUI()
    end, 11, true)
    
    createButton("Remove Injected Weapons", function()
        removeInjectedWeapons()
    end, 12)
    
    -- Weapon dropdown
    createSection("Weapon List", 13)
    
    local WeaponDropdown = Instance.new("Frame")
    WeaponDropdown.Name = "WeaponDropdown"
    WeaponDropdown.Size = UDim2.new(1, 0, 0, 140)
    WeaponDropdown.BackgroundColor3 = Theme.BackgroundLight
    WeaponDropdown.BorderSizePixel = 0
    WeaponDropdown.LayoutOrder = 14
    WeaponDropdown.Parent = Content
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 3)
    DropdownCorner.Parent = WeaponDropdown
    
    local WeaponList = Instance.new("ScrollingFrame")
    WeaponList.Name = "WeaponList"
    WeaponList.Size = UDim2.new(1, -8, 1, -8)
    WeaponList.Position = UDim2.new(0, 4, 0, 4)
    WeaponList.BackgroundTransparency = 1
    WeaponList.ScrollBarThickness = 2
    WeaponList.ScrollBarImageColor3 = Theme.Accent
    WeaponList.Parent = WeaponDropdown
    
    local WeaponListLayout = Instance.new("UIListLayout")
    WeaponListLayout.SortOrder = Enum.SortOrder.Name
    WeaponListLayout.Padding = UDim.new(0, 2)
    WeaponListLayout.Parent = WeaponList
    
    local function populateWeaponList()
        -- Clear existing
        for _, child in ipairs(WeaponList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        if #State.AllWeapons == 0 then
            scanWeapons()
        end
        
        local canvasHeight = 0
        for _, weapon in ipairs(State.AllWeapons) do
            local isTester = weapon.weaponKey == "TesterWeapon"
            local isUnreleased = weapon.released == false
            
            local prefix = ""
            local textColor = Theme.Text
            local bgColor = Theme.BackgroundDark
            
            if isTester then
                prefix = "[T] "
                textColor = Theme.Accent
                bgColor = Color3.fromRGB(40, 30, 60)
            elseif isUnreleased then
                prefix = "[U] "
                textColor = Theme.Warning
                bgColor = Color3.fromRGB(40, 35, 25)
            end
            
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
    
    createButton("Refresh List", function()
        scanWeapons()
        populateWeaponList()
    end, 15)
    
    -- Info section
    createSection("Info", 16)
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, 0, 0, 40)
    InfoLabel.BackgroundColor3 = Theme.BackgroundLight
    InfoLabel.BorderSizePixel = 0
    InfoLabel.Text = "[T] = Tester  |  [U] = Unreleased\nPress F9 for console logs"
    InfoLabel.TextColor3 = Theme.TextDim
    InfoLabel.TextSize = 10
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextWrapped = true
    InfoLabel.LayoutOrder = 17
    InfoLabel.Parent = Content
    
    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 3)
    InfoCorner.Parent = InfoLabel
    
    -- Dragging functionality
    local dragging, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
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

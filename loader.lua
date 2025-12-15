--[[
    Lunarity Loader
    Fetches available scripts from the Cloudflare worker, handles key-based auth,
    and launches either Lunarity.lua or DoorESP.lua with a unified GUI.
    Configure the WORKER_BASE_URL constant with your deployed worker URL.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local WORKER_BASE_URL = "https://api.relayed.network"
local AUTHORIZE_ENDPOINT = "/authorize"

-- Load shared UI module
local LunarityUI = loadstring(game:HttpGet("https://api.relayed.network/ui"))()
local Theme = LunarityUI.Theme
local AccentGradientSequence = LunarityUI.AccentGradientSequence
local BackgroundGradientSequence = LunarityUI.BackgroundGradientSequence

-- Encryption configuration (must match worker)
local ENCRYPTION_KEY = "LunarityXOR2025!SecretKey"
local USER_AGENT = "LunarityLoader/1.0"

-- XOR encryption/decryption for payload obfuscation
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
    local padding = 0
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

local function base64Decode(data)
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local lookup = {}
    for i = 1, 64 do
        lookup[string.sub(b64chars, i, i)] = i - 1
    end
    lookup["="] = 0
    local result = {}
    local i = 1
    while i <= #data do
        local c1 = lookup[string.sub(data, i, i)] or 0
        local c2 = lookup[string.sub(data, i + 1, i + 1)] or 0
        local c3 = lookup[string.sub(data, i + 2, i + 2)] or 0
        local c4 = lookup[string.sub(data, i + 3, i + 3)] or 0
        local combined = bit32.bor(
            bit32.lshift(c1, 18),
            bit32.lshift(c2, 12),
            bit32.lshift(c3, 6),
            c4
        )
        table.insert(result, string.char(bit32.rshift(combined, 16) % 256))
        if string.sub(data, i + 2, i + 2) ~= "=" then
            table.insert(result, string.char(bit32.rshift(combined, 8) % 256))
        end
        if string.sub(data, i + 3, i + 3) ~= "=" then
            table.insert(result, string.char(combined % 256))
        end
        i = i + 4
    end
    return table.concat(result)
end

local function encryptPayload(plainText)
    local encrypted = xorCrypt(plainText, ENCRYPTION_KEY)
    return base64Encode(encrypted)
end

local function decryptPayload(base64Cipher)
    local ok, decoded = pcall(base64Decode, base64Cipher)
    if not ok then return nil end
    return xorCrypt(decoded, ENCRYPTION_KEY)
end

local HttpRequestInvoker

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

local function toJson(value)
    -- Try multiple encoding methods for compatibility
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(value)
    end)
    if ok and encoded then
        return encoded
    end
    
    -- Fallback: manual JSON construction for simple objects
    if type(value) == "table" then
        local parts = {}
        for k, v in pairs(value) do
            local key = type(k) == "string" and ('"' .. k .. '"') or tostring(k)
            local val
            if type(v) == "string" then
                val = '"' .. v:gsub('"', '\\"') .. '"'
            elseif type(v) == "number" or type(v) == "boolean" then
                val = tostring(v)
            else
                val = '"' .. tostring(v) .. '"'
            end
            table.insert(parts, key .. ":" .. val)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    
    return nil, "Failed to encode JSON"
end

local function fromJson(text)
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, text)
    if ok then
        return decoded
    end
    return nil, decoded
end

local function normalizeBaseUrl(url)
    url = tostring(url or "")
    url = url:gsub("%s+", "")
    if url:sub(-1) == "/" then
        url = url:sub(1, -2)
    end
    return url
end

local function logHttpError(status, body)
    return string.format("HTTP %s %s", tostring(status or "error"), tostring(body or ""))
end

local BASE_URL = normalizeBaseUrl(WORKER_BASE_URL)

local function requestWorker(payload)
    if not HttpRequestInvoker then
        return false, "Executor does not support HTTP requests."
    end

    local jsonBody, encodeErr = toJson(payload)
    if not jsonBody then
        return false, "Failed to encode payload: " .. tostring(encodeErr)
    end

    -- Encrypt the JSON payload for obfuscation
    local encryptedBody = encryptPayload(jsonBody)

    local success, response = pcall(HttpRequestInvoker, {
        Url = BASE_URL .. AUTHORIZE_ENDPOINT,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json",
            ["User-Agent"] = USER_AGENT,
        },
        Body = encryptedBody,
    })

    if not success then
        return false, tostring(response)
    end

    local statusCode = response.StatusCode or response.Status or response.status_code
    local body = response.Body or response.body or ""

    if statusCode and (statusCode < 200 or statusCode >= 300) then
        return false, logHttpError(statusCode, body)
    end

    if body == "" then
        return false, "Empty response from worker"
    end

    local decoded, decodeErr = fromJson(body)
    if not decoded then
        return false, "Invalid JSON: " .. tostring(decodeErr)
    end

    return true, decoded
end

-- UI + state using LunarityUI Module
local window = LunarityUI.CreateWindow({
    Name = "LunarityLoaderGUI",
    Title = "Lunarity",
    Subtitle = "Loader",
    Size = UDim2.new(0, 360, 0, 420),
    Position = UDim2.new(0.5, -180, 0.5, -210),
})

local Theme = LunarityUI.Theme
local ScreenGui = window.ScreenGui
local TweenService = game:GetService("TweenService")

local scriptButtons = {}
local currentKey = ""
local availableScripts = {}
local busy = false

-- Status bar
local statusBar = window.createStatusBar("Waiting for API key", Theme.TextDim)

local function setStatus(text, color)
    statusBar.setText("Status: " .. text)
    statusBar.setColor(color or Theme.TextDim)
    statusBar.setTextColor(color or Theme.TextDim)
end

window.createSeparator()
window.createSection("Authentication")

-- API Key input
local keyInput = window.createTextBox("Enter your API key")

-- Authenticate button
local authenticateBtn

local function clearScriptButtons()
    for _, btn in ipairs(scriptButtons) do
        btn:Destroy()
    end
    table.clear(scriptButtons)
end

-- Script list section
window.createSeparator()
local scriptListDropdown = window.createDropdownList("Available Scripts", 180)

local function createScriptButton(meta)
    local btn = scriptListDropdown.addItem(
        string.format("%s  ·  v%s", meta.label or meta.id, meta.version or "-"),
        function()
            if busy then
                return
            end
            busy = true
            setStatus("Requesting " .. meta.id .. "...", Theme.TextDim)
            local ok, response = requestWorker({
                apiKey = currentKey,
                scriptId = meta.id,
                userId = LocalPlayer.UserId,
                username = LocalPlayer.Name,
                placeId = game.PlaceId,
            })

            if not ok then
                setStatus(response or "Failed to fetch script", Theme.Error)
                busy = false
                return
            end

            if not response.ok then
                setStatus(response.reason or "Worker denied request", Theme.Error)
                busy = false
                return
            end

            if type(response.script) ~= "string" then
                setStatus("Worker did not return script body", Theme.Error)
                busy = false
                return
            end

            if type(response.accessToken) ~= "string" then
                setStatus("Worker did not supply access token", Theme.Error)
                busy = false
                return
            end

            setStatus("Launching " .. (meta.label or meta.id) .. "...", Theme.Success)
            busy = false

            local validatePath = typeof(response.validatePath) == "string" and response.validatePath or "/validate"
            local expiresIn = tonumber(response.expiresIn) or 120
            local refreshInterval = math.clamp(math.floor(expiresIn / 2), 30, 240)

            -- Use scriptId from response.scriptMeta if available, otherwise fall back to meta.id
            local scriptId = (response.scriptMeta and response.scriptMeta.id) or meta.id

            -- Decrypt script if it was encrypted by the worker
            local scriptSource = response.script
            if response.scriptEncrypted then
                local decrypted = decryptPayload(scriptSource)
                if not decrypted then
                    setStatus("Failed to decrypt script content", Theme.Error)
                    return
                end
                scriptSource = decrypted
            end

            local accessPacket = {
                token = response.accessToken,
                scriptId = scriptId,
                baseUrl = BASE_URL,
                validateUrl = BASE_URL .. validatePath,
                expiresIn = expiresIn,
                refreshInterval = refreshInterval,
                issuedAt = os.clock(),
                encryptionKey = ENCRYPTION_KEY,
                userAgent = USER_AGENT,
            }

            local chunk, loadErr = loadstring(scriptSource, meta.id)
            if not chunk then
                setStatus("loadstring failed: " .. tostring(loadErr), Theme.Error)
                return
            end

            getgenv().LunarityAccess = accessPacket

            task.spawn(function()
                local success, runtimeErr = pcall(chunk)
                if not success then
                    warn("[Lunarity Loader] Script runtime error:", runtimeErr)
                    setStatus("Script error - check console", Theme.Error)
                else
                    setStatus("Script loaded", Theme.Success)
                end
                getgenv().LunarityAccess = nil
            end)
        end
    )
    
    table.insert(scriptButtons, btn)
end

local function refreshScriptButtons()
    scriptListDropdown.clearItems()
    table.clear(scriptButtons)
    
    if #availableScripts == 0 then
        setStatus("No scripts available for this key", Theme.Error)
        return
    end
    for _, meta in ipairs(availableScripts) do
        createScriptButton(meta)
    end
    setStatus("Select a script to launch", Theme.Accent)
end

local function authenticate()
    if busy then
        return
    end
    local keyValue = keyInput.getText():gsub("%s+$", "")
    if keyValue == "" then
        setStatus("Enter a valid API key", Theme.Error)
        return
    end

    busy = true
    setStatus("Contacting worker...", Theme.TextDim)

    local ok, response = requestWorker({
        apiKey = keyValue,
        userId = LocalPlayer.UserId,
        username = LocalPlayer.Name,
        placeId = game.PlaceId,
    })

    if not ok then
        busy = false
        setStatus(response or "Failed to reach worker", Theme.Error)
        return
    end

    if not response.ok then
        busy = false
        setStatus(response.reason or "Access denied", Theme.Error)
        return
    end

    currentKey = keyValue
    availableScripts = response.scripts or {}
    busy = false
    setStatus(response.message or "Authorized", Theme.Success)
    refreshScriptButtons()
end

-- Create authenticate button after defining the function
window.createButton("Authenticate", authenticate, true)

-- Handle enter key in text box
keyInput.textBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        authenticate()
    end
end)

window.createSeparator()
window.createInfoLabel("Enter your API key and click Authenticate to see available scripts.")

setStatus("Waiting for API key", Theme.TextDim)


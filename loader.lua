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

local Theme = {
    Background = Color3.fromRGB(14, 14, 16),
    BackgroundGradientStart = Color3.fromRGB(28, 28, 32),
    BackgroundGradientEnd = Color3.fromRGB(12, 12, 14),
    Panel = Color3.fromRGB(20, 20, 24),
    PanelStroke = Color3.fromRGB(52, 52, 62),
    PanelHover = Color3.fromRGB(28, 28, 34),
    NeutralButton = Color3.fromRGB(30, 30, 36),
    NeutralButtonHover = Color3.fromRGB(38, 38, 46),
    NeutralDark = Color3.fromRGB(24, 24, 30),
    AccentLight = Color3.fromRGB(228, 216, 255),
    Accent = Color3.fromRGB(184, 150, 255),
    AccentHover = Color3.fromRGB(206, 182, 255),
    AccentDark = Color3.fromRGB(144, 110, 255),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(210, 210, 218),
    TextMuted = Color3.fromRGB(160, 160, 170),
    Success = Color3.fromRGB(214, 198, 255),
    Danger = Color3.fromRGB(226, 170, 255),
    Separator = Color3.fromRGB(48, 48, 58)
}

local AccentGradientSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Theme.AccentLight),
    ColorSequenceKeypoint.new(0.5, Theme.Accent),
    ColorSequenceKeypoint.new(1, Theme.AccentDark)
}

local BackgroundGradientSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Theme.BackgroundGradientStart),
    ColorSequenceKeypoint.new(1, Theme.BackgroundGradientEnd)
}

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

-- UI + state
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LunarityLoaderGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 360, 0, 380)
Main.Position = UDim2.new(0.5, -180, 0.5, -190)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.PanelStroke
MainStroke.Thickness = 1
MainStroke.Transparency = 0.3
MainStroke.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = BackgroundGradientSequence
MainGradient.Rotation = 45
MainGradient.Parent = Main

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 3)
AccentLine.BackgroundColor3 = Theme.Accent
AccentLine.BorderSizePixel = 0
AccentLine.Parent = Main

local AccentGrad = Instance.new("UIGradient")
AccentGrad.Color = AccentGradientSequence
AccentGrad.Parent = AccentLine

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 6)
Title.Font = Enum.Font.GothamBold
Title.Text = "Lunarity Loader"
Title.TextSize = 20
Title.TextColor3 = Theme.TextPrimary
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local ExitButton = Instance.new("TextButton")
ExitButton.Size = UDim2.new(0, 30, 0, 30)
ExitButton.Position = UDim2.new(1, -40, 0, 6)
ExitButton.Text = "×"
ExitButton.Font = Enum.Font.GothamBold
ExitButton.TextSize = 24
ExitButton.TextColor3 = Theme.TextPrimary
ExitButton.BackgroundColor3 = Theme.Danger
ExitButton.BorderSizePixel = 0
ExitButton.Parent = Main

local ExitCorner = Instance.new("UICorner")
ExitCorner.CornerRadius = UDim.new(0, 6)
ExitCorner.Parent = ExitButton

ExitButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Size = UDim2.new(1, -20, 0, 16)
Subtitle.Position = UDim2.new(0, 10, 0, 32)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Choose which module to launch"
Subtitle.TextSize = 12
Subtitle.TextColor3 = Theme.TextMuted
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Main

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -20, 0, 1)
Divider.Position = UDim2.new(0, 10, 0, 54)
Divider.BackgroundColor3 = Theme.Separator
Divider.BorderSizePixel = 0
Divider.Parent = Main

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -20, 0, 30)
KeyBox.Position = UDim2.new(0, 10, 0, 66)
KeyBox.Text = ""
KeyBox.PlaceholderText = "Enter your API key"
KeyBox.TextColor3 = Theme.TextPrimary
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 14
KeyBox.BackgroundColor3 = Theme.Panel
KeyBox.BorderSizePixel = 0
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = Main

local KeyBoxCorner = Instance.new("UICorner")
KeyBoxCorner.CornerRadius = UDim.new(0, 6)
KeyBoxCorner.Parent = KeyBox

local KeyBoxStroke = Instance.new("UIStroke")
KeyBoxStroke.Color = Theme.PanelStroke
KeyBoxStroke.Transparency = 0.5
KeyBoxStroke.Parent = KeyBox

local AuthenticateButton = Instance.new("TextButton")
AuthenticateButton.Size = UDim2.new(0, 110, 0, 28)
AuthenticateButton.Position = UDim2.new(1, -120, 0, 104)
AuthenticateButton.Text = "Authenticate"
AuthenticateButton.Font = Enum.Font.GothamBold
AuthenticateButton.TextSize = 13
AuthenticateButton.TextColor3 = Theme.TextPrimary
AuthenticateButton.BackgroundColor3 = Theme.AccentDark
AuthenticateButton.BorderSizePixel = 0
AuthenticateButton.Parent = Main

local AuthCorner = Instance.new("UICorner")
AuthCorner.CornerRadius = UDim.new(0, 6)
AuthCorner.Parent = AuthenticateButton

local ScriptsLabel = Instance.new("TextLabel")
ScriptsLabel.BackgroundTransparency = 1
ScriptsLabel.Size = UDim2.new(1, -20, 0, 18)
ScriptsLabel.Position = UDim2.new(0, 10, 0, 142)
ScriptsLabel.Font = Enum.Font.GothamSemibold
ScriptsLabel.Text = "Available Scripts"
ScriptsLabel.TextSize = 13
ScriptsLabel.TextColor3 = Theme.TextSecondary
ScriptsLabel.TextXAlignment = Enum.TextXAlignment.Left
ScriptsLabel.Parent = Main

local ScriptList = Instance.new("ScrollingFrame")
ScriptList.BackgroundTransparency = 1
ScriptList.Size = UDim2.new(1, -20, 0, 180)
ScriptList.Position = UDim2.new(0, 10, 0, 162)
ScriptList.BorderSizePixel = 0
ScriptList.ScrollBarThickness = 4
ScriptList.ScrollBarImageColor3 = Theme.Accent
ScriptList.CanvasSize = UDim2.new()
ScriptList.Parent = Main

local ScriptLayout = Instance.new("UIListLayout")
ScriptLayout.Padding = UDim.new(0, 6)
ScriptLayout.FillDirection = Enum.FillDirection.Vertical
ScriptLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
ScriptLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScriptLayout.Parent = ScriptList

ScriptLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScriptList.CanvasSize = UDim2.new(0, 0, 0, ScriptLayout.AbsoluteContentSize.Y)
end)

local LogBox = Instance.new("TextLabel")
LogBox.BackgroundTransparency = 1
LogBox.Size = UDim2.new(1, -20, 0, 20)
LogBox.Position = UDim2.new(0, 10, 0, 352)
LogBox.Font = Enum.Font.Gotham
LogBox.Text = "Status: waiting for key"
LogBox.TextSize = 11
LogBox.TextColor3 = Theme.TextMuted
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.Parent = Main

local scriptButtons = {}
local currentKey = ""
local availableScripts = {}
local busy = false

local function setStatus(text, color)
    LogBox.Text = "Status: " .. text
    LogBox.TextColor3 = color or Theme.TextMuted
end

local function clearScriptButtons()
    for _, btn in ipairs(scriptButtons) do
        btn:Destroy()
    end
    table.clear(scriptButtons)
end

local function createScriptButton(meta)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Theme.NeutralButton
    btn.BorderSizePixel = 0
    btn.Text = string.format("%s  ·  v%s", meta.label or meta.id, meta.version or "-")
    btn.TextColor3 = Theme.TextSecondary
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = ScriptList

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.PanelStroke
    stroke.Transparency = 0.6
    stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.NeutralButtonHover }):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.NeutralButton }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        if busy then
            return
        end
        busy = true
        setStatus("Requesting " .. meta.id .. "...", Theme.TextSecondary)
        local ok, response = requestWorker({
            apiKey = currentKey,
            scriptId = meta.id,
            userId = LocalPlayer.UserId,
            username = LocalPlayer.Name,
            placeId = game.PlaceId,
        })

        if not ok then
            setStatus(response or "Failed to fetch script", Theme.Danger)
            busy = false
            return
        end

        if not response.ok then
            setStatus(response.reason or "Worker denied request", Theme.Danger)
            busy = false
            return
        end

        if type(response.script) ~= "string" then
            setStatus("Worker did not return script body", Theme.Danger)
            busy = false
            return
        end

        if type(response.accessToken) ~= "string" then
            setStatus("Worker did not supply access token", Theme.Danger)
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
                setStatus("Failed to decrypt script content", Theme.Danger)
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
            setStatus("loadstring failed: " .. tostring(loadErr), Theme.Danger)
            return
        end

        getgenv().LunarityAccess = accessPacket

        task.spawn(function()
            local success, runtimeErr = pcall(chunk)
            if not success then
                warn("[Lunarity Loader] Script runtime error:", runtimeErr)
                setStatus("Script error - check console", Theme.Danger)
            else
                setStatus("Script loaded", Theme.Success)
            end
            getgenv().LunarityAccess = nil
        end)
    end)

    table.insert(scriptButtons, btn)
end

local function refreshScriptButtons()
    clearScriptButtons()
    if #availableScripts == 0 then
        setStatus("No scripts available for this key", Theme.Danger)
        return
    end
    for _, meta in ipairs(availableScripts) do
        createScriptButton(meta)
    end
    setStatus("Select a script to launch", Theme.TextSecondary)
end

local function authenticate()
    if busy then
        return
    end
    local keyValue = KeyBox.Text:gsub("%s+$", "")
    if keyValue == "" then
        setStatus("Enter a valid API key", Theme.Danger)
        return
    end

    busy = true
    setStatus("Contacting worker...", Theme.TextSecondary)

    local ok, response = requestWorker({
        apiKey = keyValue,
        userId = LocalPlayer.UserId,
        username = LocalPlayer.Name,
        placeId = game.PlaceId,
    })

    if not ok then
        busy = false
        setStatus(response or "Failed to reach worker", Theme.Danger)
        return
    end

    if not response.ok then
        busy = false
        setStatus(response.reason or "Access denied", Theme.Danger)
        return
    end

    currentKey = keyValue
    availableScripts = response.scripts or {}
    busy = false
    setStatus(response.message or "Authorized", Theme.Success)
    refreshScriptButtons()
end

AuthenticateButton.MouseButton1Click:Connect(authenticate)

-- Keyboard shortcut: Enter submits key
KeyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        authenticate()
    end
end)

-- Dragging support
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

setStatus("waiting for key")

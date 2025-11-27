-- Lunarity Remote Logger
-- Developer tool that records incoming/outgoing remote traffic for the local player

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local LOADER_SCRIPT_ID = "remoteLogger"
local LoaderAccess = rawget(getgenv(), "LunarityAccess")

local logFolderName = "LunarityLogs"
local logFilePath
local logBuffer = {}

local function tryMakeFolder()
    if typeof(isfolder) == "function" and not isfolder(logFolderName) then
        pcall(makefolder, logFolderName)
    end
end

local function canAppend()
    return typeof(appendfile) == "function" and typeof(writefile) == "function"
end

local function initLogFile()
    tryMakeFolder()

    local fileName = string.format("%s/Lunarity_RemoteLog_%d_%s.txt", logFolderName, game.PlaceId, os.date("%Y%m%d_%H%M%S"))
    logFilePath = fileName

    if canAppend() then
        local header = string.format("Lunarity Remote Logger\nPlaceId: %d\nPlayer: %s (%d)\nSession: %s\n\n", game.PlaceId, LocalPlayer.Name, LocalPlayer.UserId, os.date("%c"))
        if typeof(writefile) == "function" then
            pcall(writefile, logFilePath, header)
        end
    end
end

local function appendLog(line)
    local text = line .. "\n"
    if logFilePath and canAppend() then
        pcall(appendfile, logFilePath, text)
    else
        table.insert(logBuffer, text)
        if #logBuffer > 50 then
            table.remove(logBuffer, 1)
        end
    end

    if typeof(rconsoleprint) == "function" then
        rconsoleprint(text)
    else
        warn(text)
    end
end

local function describeInstance(inst)
    local success, full = pcall(function()
        return inst:GetFullName()
    end)
    local path = success and full or inst.Name or "?"
    return string.format("%s (%s)", path, inst.ClassName)
end

local function stringify(value, depth)
    depth = depth or 0
    if depth > 2 then
        return "<max depth>"
    end

    local valueType = typeof(value)
    if valueType == "string" then
        local truncated = value
        if #truncated > 200 then
            truncated = truncated:sub(1, 197) .. "..."
        end
        return string.format("\"%s\"", truncated)
    elseif valueType == "Instance" then
        return describeInstance(value)
    elseif valueType == "Vector3" or valueType == "Vector2" or valueType == "CFrame" then
        return tostring(value)
    elseif valueType == "table" then
        local parts = {}
        local count = 0
        for k, v in pairs(value) do
            count = count + (1)
            if count > 5 then
                table.insert(parts, "...")
                break
            end
            table.insert(parts, string.format("[%s]=%s", stringify(k, depth + 1), stringify(v, depth + 1)))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    else
        return tostring(value)
    end
end

local function serializeArgs(args)
    local parts = {}
    for i = 1, math.min(#args, 10) do
        table.insert(parts, string.format("%d=%s", i, stringify(args[i])))
    end
    if #args > 10 then
        table.insert(parts, string.format("... (%d total)", #args))
    end
    return table.concat(parts, "; ")
end

local function logRemote(direction, remote, method, args)
    local remoteDesc = describeInstance(remote)
    local payload = serializeArgs(args)
    local entry = string.format("[%s] [%s] %s :: %s | %s", os.date("%H:%M:%S"), direction, method, remoteDesc, payload)
    appendLog(entry)
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

local function requestLoaderValidation(refresh)
    if not LoaderAccess then
        return false, "Missing loader token"
    end
    if not HttpRequestInvoker then
        return false, "Executor lacks HTTP"
    end
    local validateUrl = buildValidateUrl()
    if not validateUrl then
        return false, "Validation endpoint unavailable"
    end

    local payload = {
        scriptId = LOADER_SCRIPT_ID,
        token = LoaderAccess.token,
        refresh = refresh == true,
        placeId = game.PlaceId,
        userId = LocalPlayer.UserId,
    }

    local encoded = HttpService:JSONEncode(payload)
    local success, response = pcall(HttpRequestInvoker, {
        Url = validateUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json",
        },
        Body = encoded,
    })

    if not success then
        return false, tostring(response)
    end

    local statusCode = response.StatusCode or response.Status or response.status_code
    local body = response.Body or response.body or ""
    if statusCode and (statusCode < 200 or statusCode >= 300) then
        return false, body
    end

    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok or decoded.ok ~= true then
        return false, (decoded and decoded.reason) or "Validation failed"
    end

    return true, decoded
end

local function enforceLoaderWhitelist()
    if not LoaderAccess or LoaderAccess.scriptId ~= LOADER_SCRIPT_ID then
        appendLog("[WARN] RemoteLogger launched outside loader; aborting")
        return false
    end

    local ok, response = requestLoaderValidation(false)
    if not ok then
        appendLog("[ERROR] Loader validation failed: " .. tostring(response))
        return false
    end

    local refreshInterval = math.clamp(LoaderAccess.refreshInterval or 90, 30, 240)
    task.spawn(function()
        while task.wait(refreshInterval) do
            local alive, err = requestLoaderValidation(true)
            if not alive then
                appendLog("[WARN] Validation refresh failed - stopping logger :: " .. tostring(err))
                break
            end
        end
    end)

    getgenv().LunarityAccess = nil
    return true
end

initLogFile()
appendLog("[INFO] RemoteLogger starting up")

if not enforceLoaderWhitelist() then
    return
end

local trackedEvents = setmetatable({}, { __mode = "k" })
local remoteFunctionProxies = setmetatable({}, { __mode = "k" })
local remoteFunctionOriginals = setmetatable({}, { __mode = "k" })
local wrappingRemotes = {}

local function hookRemoteEvent(remote)
    if trackedEvents[remote] then
        return
    end

    local connection
    connection = remote.OnClientEvent:Connect(function(...)
        logRemote("IN", remote, "OnClientEvent", { ... })
    end)

    trackedEvents[remote] = connection
    local destroyingSignal = remote.Destroying
    if typeof(destroyingSignal) == "RBXScriptSignal" then
        destroyingSignal:Connect(function()
            if trackedEvents[remote] then
                trackedEvents[remote]:Disconnect()
                trackedEvents[remote] = nil
            end
        end)
    end
end

if hookmetamethod and getnamecallmethod and typeof(newcclosure) == "function" then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if typeof(self) == "Instance" then
            if method == "FireServer" and self:IsA("RemoteEvent") then
                logRemote("OUT", self, method, { ... })
            elseif method == "InvokeServer" and self:IsA("RemoteFunction") then
                logRemote("OUT", self, method, { ... })
            end
        end
        return oldNamecall(self, ...)
    end))
else
    appendLog("[WARN] hookmetamethod unavailable - outgoing remotes will not be logged")
end

local function wrapRemoteFunction(remote, callback)
    if type(callback) ~= "function" then
        return
    end
    if remoteFunctionOriginals[remote] == callback then
        return
    end

    local function proxy(...)
        logRemote("IN", remote, "OnClientInvoke", { ... })
        return callback(...)
    end

    remoteFunctionProxies[remote] = proxy
    remoteFunctionOriginals[remote] = callback
    wrappingRemotes[remote] = true
    local ok, err = pcall(function()
        remote.OnClientInvoke = proxy
    end)
    wrappingRemotes[remote] = nil

    if not ok then
        appendLog("[ERROR] Failed to hook RemoteFunction " .. remote.Name .. ": " .. tostring(err))
    end
end

local gameMeta = getrawmetatable(game)
local oldNewIndex = gameMeta and gameMeta.__newindex or nil
if gameMeta and oldNewIndex and typeof(setreadonly) == "function" and typeof(newcclosure) == "function" then
    setreadonly(gameMeta, false)
    gameMeta.__newindex = newcclosure(function(self, key, value)
        if key == "OnClientInvoke" and typeof(self) == "Instance" and self:IsA("RemoteFunction") then
            if wrappingRemotes[self] then
                return oldNewIndex(self, key, value)
            end
            if type(value) == "function" and not checkcaller() then
                wrapRemoteFunction(self, value)
                return
            elseif value == nil then
                remoteFunctionProxies[self] = nil
                remoteFunctionOriginals[self] = nil
            end
        end
        return oldNewIndex(self, key, value)
    end)
    setreadonly(gameMeta, true)
else
    appendLog("[WARN] Unable to hook RemoteFunction.OnClientInvoke (missing metatable access)")
end

local function processDescendant(inst)
    if inst:IsA("RemoteEvent") then
        hookRemoteEvent(inst)
    elseif inst:IsA("RemoteFunction") and type(inst.OnClientInvoke) == "function" then
        wrapRemoteFunction(inst, inst.OnClientInvoke)
    end
end

for _, inst in ipairs(game:GetDescendants()) do
    processDescendant(inst)
end
game.DescendantAdded:Connect(processDescendant)

appendLog("[INFO] RemoteLogger active - logging to " .. (logFilePath or "console"))
local storedBuffer = table.concat(logBuffer)
if storedBuffer ~= "" and logFilePath and canAppend() then
    pcall(appendfile, logFilePath, storedBuffer)
    table.clear(logBuffer)
end

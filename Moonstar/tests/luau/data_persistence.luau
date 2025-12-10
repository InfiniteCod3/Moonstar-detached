-- tests/luau/data_persistence.luau
-- Tests DataStore-like patterns for data persistence

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- Data template for new players
local DEFAULT_DATA = {
    coins = 0,
    gems = 0,
    level = 1,
    experience = 0,
    inventory = {},
    settings = {
        musicVolume = 50,
        sfxVolume = 100,
        notifications = true
    },
    stats = {
        totalPlayTime = 0,
        gamesPlayed = 0,
        highScore = 0
    },
    lastLogin = 0
}

-- Deep copy utility
local function deepCopy(original)
    if type(original) ~= "table" then
        return original
    end
    
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = deepCopy(value)
    end
    return copy
end

-- Deep merge utility
local function deepMerge(base, overlay)
    local result = deepCopy(base)
    
    for key, value in pairs(overlay) do
        if type(value) == "table" and type(result[key]) == "table" then
            result[key] = deepMerge(result[key], value)
        else
            result[key] = value
        end
    end
    
    return result
end

-- Data manager class
local DataManager = {}
DataManager.__index = DataManager

function DataManager.new(storeName)
    local self = setmetatable({}, DataManager)
    self.storeName = storeName
    self.cache = {}
    self.saveQueue = {}
    self.retryAttempts = 3
    self.retryDelay = 1
    
    -- Try to get DataStore (may fail in some environments)
    local success, store = pcall(function()
        return DataStoreService:GetDataStore(storeName)
    end)
    
    self.dataStore = success and store or nil
    
    return self
end

function DataManager:load(userId)
    local key = "Player_" .. userId
    
    -- Check cache first
    if self.cache[key] then
        return true, self.cache[key]
    end
    
    -- Try loading from DataStore
    if self.dataStore then
        for attempt = 1, self.retryAttempts do
            local success, data = pcall(function()
                return self.dataStore:GetAsync(key)
            end)
            
            if success then
                local playerData = data and deepMerge(DEFAULT_DATA, data) or deepCopy(DEFAULT_DATA)
                playerData.lastLogin = os.time()
                self.cache[key] = playerData
                return true, playerData
            end
            
            task.wait(self.retryDelay)
        end
    end
    
    -- Fallback to default data
    local playerData = deepCopy(DEFAULT_DATA)
    playerData.lastLogin = os.time()
    self.cache[key] = playerData
    return false, playerData
end

function DataManager:save(userId)
    local key = "Player_" .. userId
    local data = self.cache[key]
    
    if not data then
        return false, "No data to save"
    end
    
    if self.dataStore then
        for attempt = 1, self.retryAttempts do
            local success, err = pcall(function()
                self.dataStore:SetAsync(key, data)
            end)
            
            if success then
                return true
            end
            
            task.wait(self.retryDelay)
        end
    end
    
    return false, "Failed to save after retries"
end

function DataManager:update(userId, path, value)
    local key = "Player_" .. userId
    local data = self.cache[key]
    
    if not data then
        return false, "Player data not loaded"
    end
    
    -- Navigate to nested path
    local parts = string.split(path, ".")
    local target = data
    
    for i = 1, #parts - 1 do
        target = target[parts[i]]
        if not target then
            return false, "Invalid path: " .. path
        end
    end
    
    local finalKey = parts[#parts]
    target[finalKey] = value
    
    return true
end

function DataManager:get(userId, path)
    local key = "Player_" .. userId
    local data = self.cache[key]
    
    if not data then
        return nil
    end
    
    if not path then
        return data
    end
    
    local parts = string.split(path, ".")
    local value = data
    
    for _, part in ipairs(parts) do
        value = value[part]
        if value == nil then
            return nil
        end
    end
    
    return value
end

function DataManager:increment(userId, path, amount)
    local current = self:get(userId, path) or 0
    return self:update(userId, path, current + (amount or 1))
end

-- Initialize data manager
local playerData = DataManager.new("PlayerData")

-- Player connection handlers
local function onPlayerAdded(player)
    local success, data = playerData:load(player.UserId)
    print("Loaded data for", player.Name, "success:", success)
    print("  Coins:", data.coins)
    print("  Level:", data.level)
end

local function onPlayerRemoving(player)
    local success, err = playerData:save(player.UserId)
    if success then
        print("Saved data for", player.Name)
    else
        warn("Failed to save data for", player.Name, err)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle existing players
for _, player in Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end

print("Data persistence test initialized")

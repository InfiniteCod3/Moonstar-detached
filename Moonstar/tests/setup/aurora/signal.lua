-- Aurora Signal System
-- Implements RBXScriptSignal-like event system for Roblox emulation

local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

--- Creates a new Connection
---@param signal table The parent signal
---@param callback function The callback function
---@param once boolean Whether this connection fires only once
---@return table Connection object
function Connection.new(signal, callback, once)
    local self = setmetatable({}, Connection)
    self._signal = signal
    self._callback = callback
    self._once = once or false
    self._connected = true
    return self
end

--- Disconnects this connection from the signal
function Connection:Disconnect()
    if not self._connected then return end
    self._connected = false
    
    local connections = self._signal._connections
    for i = #connections, 1, -1 do
        if connections[i] == self then
            table.remove(connections, i)
            break
        end
    end
end

--- Checks if the connection is still connected
---@return boolean
function Connection:IsConnected()
    return self._connected
end

--- Creates a new Signal
---@return table Signal object
function Signal.new()
    local self = setmetatable({}, Signal)
    self._connections = {}
    self._waiting = {}
    self._lastFiredArgs = nil
    return self
end

--- Connects a callback to this signal
---@param callback function The callback to run when signal fires
---@return table Connection object
function Signal:Connect(callback)
    if type(callback) ~= "function" then
        error("Argument 1 must be a function", 2)
    end
    
    local connection = Connection.new(self, callback, false)
    table.insert(self._connections, connection)
    return connection
end

--- Connects a callback that only fires once
---@param callback function The callback to run when signal fires
---@return table Connection object
function Signal:Once(callback)
    if type(callback) ~= "function" then
        error("Argument 1 must be a function", 2)
    end
    
    local connection = Connection.new(self, callback, true)
    table.insert(self._connections, connection)
    return connection
end

--- Waits for the signal to fire and returns the arguments
---@param timeout number Optional timeout in seconds
---@return ... Arguments passed to Fire
function Signal:Wait(timeout)
    local waitingThread = coroutine.running()
    local timedOut = false
    local result = nil
    
    table.insert(self._waiting, {
        thread = waitingThread,
        callback = function(...)
            result = {...}
        end
    })
    
    -- If timeout specified, set up timeout coroutine
    if timeout then
        local startTime = os.clock()
        while not result and (os.clock() - startTime) < timeout do
            coroutine.yield()
        end
        if not result then
            timedOut = true
        end
    else
        -- Yield until fired
        coroutine.yield()
    end
    
    if timedOut then
        return nil
    end
    
    if result then
        return table.unpack(result)
    end
    
    return nil
end

--- Fires the signal with the given arguments
---@param ... any Arguments to pass to connected callbacks
function Signal:Fire(...)
    local args = {...}
    self._lastFiredArgs = args
    
    -- Process waiting threads
    for _, waiter in ipairs(self._waiting) do
        waiter.callback(...)
        if waiter.thread and coroutine.status(waiter.thread) == "suspended" then
            coroutine.resume(waiter.thread)
        end
    end
    self._waiting = {}
    
    -- Process connections (iterate backwards to handle removals)
    local toRemove = {}
    for i, connection in ipairs(self._connections) do
        if connection._connected then
            -- Protected call to prevent one callback from breaking others
            local success, err = pcall(connection._callback, ...)
            if not success then
                warn("Signal callback error: " .. tostring(err))
            end
            
            if connection._once then
                table.insert(toRemove, i)
                connection._connected = false
            end
        end
    end
    
    -- Remove once connections
    for i = #toRemove, 1, -1 do
        table.remove(self._connections, toRemove[i])
    end
end

--- Disconnects all connections
function Signal:DisconnectAll()
    for _, connection in ipairs(self._connections) do
        connection._connected = false
    end
    self._connections = {}
    self._waiting = {}
end

--- Destroys the signal
function Signal:Destroy()
    self:DisconnectAll()
    setmetatable(self, nil)
end

--- Gets the number of connected callbacks
---@return number
function Signal:GetConnectionCount()
    return #self._connections
end

return Signal

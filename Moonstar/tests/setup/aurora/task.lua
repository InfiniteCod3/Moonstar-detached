-- Aurora Task Library
-- Roblox task library emulation for coroutine management

local Task = {}

-- Active threads and their scheduled times
local scheduledThreads = {}
local deferredThreads = {}
local nextThreadId = 1

-- ============================================================================
-- Core Task Functions
-- ============================================================================

--- Spawns a new thread that runs immediately
---@param callback function|thread The function or thread to run
---@vararg any Arguments to pass to the function
---@return thread The spawned thread
function Task.spawn(callback, ...)
    local thread
    if type(callback) == "thread" then
        thread = callback
    else
        thread = coroutine.create(callback)
    end
    
    local success, err = coroutine.resume(thread, ...)
    if not success then
        warn("task.spawn error: " .. tostring(err))
    end
    
    return thread
end

--- Defers a thread to run at the end of the current resumption cycle
---@param callback function|thread The function or thread to run
---@vararg any Arguments to pass to the function
---@return thread The deferred thread
function Task.defer(callback, ...)
    local thread
    if type(callback) == "thread" then
        thread = callback
    else
        thread = coroutine.create(callback)
    end
    
    local args = {...}
    table.insert(deferredThreads, {
        thread = thread,
        args = args
    })
    
    return thread
end

--- Delays a thread by the specified duration
---@param duration number The delay in seconds
---@param callback function|thread The function or thread to run
---@vararg any Arguments to pass to the function
---@return thread The delayed thread
function Task.delay(duration, callback, ...)
    local thread
    if type(callback) == "thread" then
        thread = callback
    else
        thread = coroutine.create(callback)
    end
    
    local args = {...}
    local id = nextThreadId
    nextThreadId = nextThreadId + 1
    
    scheduledThreads[id] = {
        thread = thread,
        args = args,
        resumeAt = os.clock() + duration
    }
    
    -- In a real implementation, this would be handled by the scheduler
    -- For mock purposes, we'll run it immediately after a simulated delay
    Task.spawn(function()
        local waited = 0
        local startTime = os.clock()
        while os.clock() - startTime < duration do
            coroutine.yield()
        end
        
        if scheduledThreads[id] then
            local scheduled = scheduledThreads[id]
            scheduledThreads[id] = nil
            coroutine.resume(scheduled.thread, table.unpack(scheduled.args))
        end
    end)
    
    return thread
end

--- Waits for the specified duration
---@param duration number The duration to wait in seconds (optional, defaults to one frame)
---@return number The actual time elapsed
---@return number The current time
function Task.wait(duration)
    duration = duration or 0
    
    local startTime = os.clock()
    
    -- In a real Roblox environment, this would yield to the task scheduler
    -- In our mock, we use a busy-wait simulation
    if duration > 0 then
        -- For testing purposes, we just return immediately
        -- A proper implementation would yield the coroutine
        local elapsed = duration
        return elapsed, os.clock()
    end
    
    -- Minimum wait (one frame)
    local elapsed = 1/60
    return elapsed, os.clock()
end

--- Cancels a thread
---@param thread thread The thread to cancel
function Task.cancel(thread)
    if type(thread) ~= "thread" then
        return
    end
    
    -- Remove from scheduled threads
    for id, scheduled in pairs(scheduledThreads) do
        if scheduled.thread == thread then
            scheduledThreads[id] = nil
            return
        end
    end
    
    -- Remove from deferred threads
    for i = #deferredThreads, 1, -1 do
        if deferredThreads[i].thread == thread then
            table.remove(deferredThreads, i)
            return
        end
    end
    
    -- If the thread is running, we can't really cancel it in pure Lua
    -- In Roblox, this would mark it for cancellation
end

--- Synchronizes to the calling thread's context
--- This is a no-op in our emulator since we don't have actual thread contexts
function Task.synchronize()
    -- No-op in emulator
end

--- Desynchronizes from the calling thread's context
--- This is a no-op in our emulator since we don't have actual thread contexts
function Task.desynchronize()
    -- No-op in emulator
end

-- ============================================================================
-- Internal Scheduler (for testing)
-- ============================================================================

--- Processes deferred threads (call this at end of frame)
function Task._processDeferred()
    local toProcess = deferredThreads
    deferredThreads = {}
    
    for _, deferred in ipairs(toProcess) do
        local success, err = coroutine.resume(deferred.thread, table.unpack(deferred.args))
        if not success then
            warn("Deferred thread error: " .. tostring(err))
        end
    end
end

--- Processes scheduled threads (call this each frame with delta time)
function Task._processScheduled(currentTime)
    currentTime = currentTime or os.clock()
    
    local toRemove = {}
    
    for id, scheduled in pairs(scheduledThreads) do
        if currentTime >= scheduled.resumeAt then
            table.insert(toRemove, id)
            
            local success, err = coroutine.resume(scheduled.thread, table.unpack(scheduled.args))
            if not success then
                warn("Scheduled thread error: " .. tostring(err))
            end
        end
    end
    
    for _, id in ipairs(toRemove) do
        scheduledThreads[id] = nil
    end
end

--- Gets count of pending scheduled threads
function Task._getScheduledCount()
    local count = 0
    for _ in pairs(scheduledThreads) do
        count = count + 1
    end
    return count
end

--- Gets count of pending deferred threads
function Task._getDeferredCount()
    return #deferredThreads
end

--- Clears all pending threads
function Task._clear()
    scheduledThreads = {}
    deferredThreads = {}
end

return Task

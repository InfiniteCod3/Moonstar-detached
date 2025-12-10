-- tests/luau/task_async_patterns.luau
-- Tests task library and async patterns in Roblox LuaU

local HttpService = game:GetService("HttpService")

-- Basic task functions
print("Testing task.spawn")
task.spawn(function()
    print("  Spawned task running immediately")
end)
print("  After spawn call")

print("\nTesting task.defer")
task.defer(function()
    print("  Deferred task running after current thread yields")
end)
print("  After defer call")

print("\nTesting task.delay")
task.delay(0.5, function()
    print("  Delayed task after 0.5 seconds")
end)

print("\nTesting task.wait")
local startTime = os.clock()
local elapsed = task.wait(0.1)
print("  Waited for:", elapsed, "seconds")

-- Promise-like pattern
local function createPromise(executor)
    local promise = {
        _state = "pending",
        _value = nil,
        _callbacks = {}
    }
    
    function promise:andThen(callback)
        if self._state == "resolved" then
            task.spawn(callback, self._value)
        elseif self._state == "pending" then
            table.insert(self._callbacks, {type = "resolve", fn = callback})
        end
        return self
    end
    
    function promise:catch(callback)
        if self._state == "rejected" then
            task.spawn(callback, self._value)
        elseif self._state == "pending" then
            table.insert(self._callbacks, {type = "reject", fn = callback})
        end
        return self
    end
    
    function promise:finally(callback)
        if self._state ~= "pending" then
            task.spawn(callback)
        else
            table.insert(self._callbacks, {type = "finally", fn = callback})
        end
        return self
    end
    
    local function resolve(value)
        if promise._state ~= "pending" then return end
        promise._state = "resolved"
        promise._value = value
        
        for _, cb in ipairs(promise._callbacks) do
            if cb.type == "resolve" or cb.type == "finally" then
                task.spawn(cb.fn, value)
            end
        end
    end
    
    local function reject(reason)
        if promise._state ~= "pending" then return end
        promise._state = "rejected"
        promise._value = reason
        
        for _, cb in ipairs(promise._callbacks) do
            if cb.type == "reject" or cb.type == "finally" then
                task.spawn(cb.fn, reason)
            end
        end
    end
    
    task.spawn(executor, resolve, reject)
    
    return promise
end

-- Promise.all simulation
local function promiseAll(promises)
    return createPromise(function(resolve, reject)
        local results = {}
        local remaining = #promises
        
        if remaining == 0 then
            resolve(results)
            return
        end
        
        for i, promise in ipairs(promises) do
            promise:andThen(function(value)
                results[i] = value
                remaining = remaining - 1
                
                if remaining == 0 then
                    resolve(results)
                end
            end):catch(function(reason)
                reject(reason)
            end)
        end
    end)
end

-- Promise.race simulation
local function promiseRace(promises)
    return createPromise(function(resolve, reject)
        for _, promise in ipairs(promises) do
            promise:andThen(resolve):catch(reject)
        end
    end)
end

-- Usage examples
print("\nPromise pattern test:")

local asyncOperation = createPromise(function(resolve, reject)
    task.delay(0.3, function()
        resolve("Operation completed!")
    end)
end)

asyncOperation
    :andThen(function(result)
        print("  Promise resolved:", result)
    end)
    :catch(function(err)
        print("  Promise rejected:", err)
    end)
    :finally(function()
        print("  Promise finally block")
    end)

-- Retry pattern
local function retry(fn, maxAttempts, delayBetween)
    maxAttempts = maxAttempts or 3
    delayBetween = delayBetween or 1
    
    return createPromise(function(resolve, reject)
        local function attempt(attemptNum)
            local success, result = pcall(fn)
            
            if success then
                resolve(result)
            elseif attemptNum < maxAttempts then
                print("  Retry attempt", attemptNum, "failed, retrying...")
                task.delay(delayBetween, function()
                    attempt(attemptNum + 1)
                end)
            else
                reject("Max attempts reached: " .. tostring(result))
            end
        end
        
        attempt(1)
    end)
end

-- Timeout wrapper
local function withTimeout(promise, timeoutSeconds)
    return promiseRace({
        promise,
        createPromise(function(resolve, reject)
            task.delay(timeoutSeconds, function()
                reject("Timeout after " .. timeoutSeconds .. " seconds")
            end)
        end)
    })
end

-- Debounce pattern
local function debounce(fn, waitTime)
    local lastCall = 0
    local scheduled = false
    
    return function(...)
        local args = {...}
        lastCall = os.clock()
        
        if scheduled then return end
        scheduled = true
        
        task.delay(waitTime, function()
            scheduled = false
            fn(table.unpack(args))
        end)
    end
end

-- Throttle pattern
local function throttle(fn, limitTime)
    local lastRun = 0
    
    return function(...)
        local now = os.clock()
        
        if now - lastRun >= limitTime then
            lastRun = now
            return fn(...)
        end
    end
end

-- Test debounce/throttle
local debouncedPrint = debounce(function(msg)
    print("  Debounced:", msg)
end, 0.5)

local throttledPrint = throttle(function(msg)
    print("  Throttled:", msg)
end, 0.3)

print("\nDebounce/Throttle test:")
for i = 1, 5 do
    debouncedPrint("call " .. i)
    throttledPrint("call " .. i)
    task.wait(0.1)
end

-- Cancellable task
local function cancellableTask(fn)
    local cancelled = false
    
    local thread = task.spawn(function()
        fn(function()
            return cancelled
        end)
    end)
    
    return {
        cancel = function()
            cancelled = true
            task.cancel(thread)
        end,
        isCancelled = function()
            return cancelled
        end
    }
end

local controller = cancellableTask(function(isCancelled)
    for i = 1, 10 do
        if isCancelled() then
            print("  Task was cancelled at iteration", i)
            return
        end
        print("  Task iteration", i)
        task.wait(0.2)
    end
end)

task.delay(0.5, function()
    controller.cancel()
    print("  Sent cancel signal")
end)

print("\nAsync patterns test initialized")

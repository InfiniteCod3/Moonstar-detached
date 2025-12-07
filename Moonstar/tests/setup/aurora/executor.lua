-- Aurora Executor Environment
-- Roblox executor/exploit environment emulation

local Executor = {}

-- ============================================================================
-- Global Environment Tables
-- ============================================================================
local globalEnv = {}
local robloxEnv = {}
local registryEnv = {}

-- ============================================================================
-- Environment Access Functions
-- ============================================================================

--- Gets the global environment table (shared across scripts)
function Executor.getgenv()
    return globalEnv
end

--- Gets the Roblox environment table
function Executor.getrenv()
    return robloxEnv
end

--- Gets the registry table
function Executor.getreg()
    return registryEnv
end

--- Gets the function environment
function Executor.getfenv(fn)
    if type(fn) == "function" then
        local env = debug.getfenv and debug.getfenv(fn) or _ENV
        return env
    elseif type(fn) == "number" then
        return _G
    end
    return _G
end

--- Sets the function environment
function Executor.setfenv(fn, env)
    if debug.setfenv then
        debug.setfenv(fn, env)
    end
    return fn
end

--- Gets the garbage collector objects
function Executor.getgc(includeTables)
    -- Mock - would need actual GC access
    return {}
end

--- Gets instances from the garbage collector
function Executor.getinstances()
    return {}
end

--- Gets nil instances (instances with nil parent)
function Executor.getnilinstances()
    return {}
end

--- Gets scripts from the garbage collector
function Executor.getscripts()
    return {}
end

--- Gets loaded modules
function Executor.getloadedmodules()
    return {}
end

--- Gets connections of a signal
function Executor.getconnections(signal)
    if signal and signal._connections then
        local connections = {}
        for _, conn in ipairs(signal._connections) do
            table.insert(connections, {
                Function = conn._callback,
                State = conn._connected and "Connected" or "Disconnected",
                Enabled = conn._connected,
                Disconnect = function() conn:Disconnect() end,
                Disable = function() conn._connected = false end,
                Enable = function() conn._connected = true end,
                Fire = function(...) conn._callback(...) end
            })
        end
        return connections
    end
    return {}
end

-- ============================================================================
-- Function Manipulation
-- ============================================================================

--- Creates a new C closure from a Lua function
function Executor.newcclosure(fn)
    if type(fn) ~= "function" then
        error("Expected function", 2)
    end
    -- In pure Lua, we can't create actual C closures
    -- Just return the function wrapped
    return function(...)
        return fn(...)
    end
end

--- Creates a new Lua closure from a function
function Executor.newlclosure(fn)
    if type(fn) ~= "function" then
        error("Expected function", 2)
    end
    return function(...)
        return fn(...)
    end
end

--- Checks if a function is a C closure
function Executor.iscclosure(fn)
    if type(fn) ~= "function" then
        return false
    end
    local info = debug.getinfo and debug.getinfo(fn) or {}
    return info.what == "C"
end

--- Checks if a function is a Lua closure
function Executor.islclosure(fn)
    if type(fn) ~= "function" then
        return false
    end
    local info = debug.getinfo and debug.getinfo(fn) or {}
    return info.what == "Lua"
end

--- Hooks a function, replacing it with a new one
function Executor.hookfunction(target, hook)
    if type(target) ~= "function" or type(hook) ~= "function" then
        error("Expected function", 2)
    end
    
    local original = target
    -- In pure Lua, we can't truly hook functions
    -- This is a mock that returns the original
    return original
end

--- Hooks a metamethod on a metatable
function Executor.hookmetamethod(object, metamethod, hook)
    local mt = getmetatable(object)
    if not mt then
        mt = {}
        setmetatable(object, mt)
    end
    
    local original = mt[metamethod]
    mt[metamethod] = hook
    
    return original
end

--- Gets the raw metatable (bypassing __metatable)
function Executor.getrawmetatable(object)
    return debug.getmetatable and debug.getmetatable(object) or getmetatable(object)
end

--- Sets the raw metatable (bypassing __metatable)
function Executor.setrawmetatable(object, mt)
    return debug.setmetatable and debug.setmetatable(object, mt) or setmetatable(object, mt)
end

--- Sets a value in a table without triggering __newindex
function Executor.rawset(t, k, v)
    rawset(t, k, v)
    return t
end

--- Gets a value from a table without triggering __index
function Executor.rawget(t, k)
    return rawget(t, k)
end

--- Checks if a table is read-only
function Executor.isreadonly(t)
    local mt = getmetatable(t)
    if mt and mt.__newindex then
        -- Check if __newindex blocks writes
        local success = pcall(function()
            rawset(t, "__test_readonly", true)
            rawset(t, "__test_readonly", nil)
        end)
        return not success
    end
    return false
end

--- Makes a table read-only
function Executor.setreadonly(t, readonly)
    local mt = getmetatable(t) or {}
    if readonly then
        mt.__newindex = function()
            error("Attempt to modify a readonly table", 2)
        end
    else
        mt.__newindex = nil
    end
    setmetatable(t, mt)
    return t
end

--- Gets function info
function Executor.getinfo(fn)
    if type(fn) ~= "function" then
        return {}
    end
    
    local info = debug.getinfo and debug.getinfo(fn, "Slnuf") or {}
    return {
        source = info.source or "[unknown]",
        short_src = info.short_src or "[unknown]",
        what = info.what or "Lua",
        currentline = info.currentline or -1,
        linedefined = info.linedefined or -1,
        lastlinedefined = info.lastlinedefined or -1,
        nups = info.nups or 0,
        nparams = info.nparams or 0,
        isvararg = info.isvararg or false,
        name = info.name,
        namewhat = info.namewhat or "",
        func = fn
    }
end

--- Gets the constants of a function
function Executor.getconstants(fn)
    -- Would require debug library access to bytecode
    return {}
end

--- Sets a constant in a function
function Executor.setconstant(fn, index, value)
    -- Would require debug library access to bytecode
end

--- Gets a constant from a function
function Executor.getconstant(fn, index)
    -- Would require debug library access to bytecode
    return nil
end

--- Gets the upvalues of a function
function Executor.getupvalues(fn)
    local upvalues = {}
    if debug.getupvalue then
        local i = 1
        while true do
            local name, value = debug.getupvalue(fn, i)
            if not name then break end
            upvalues[i] = value
            i = i + 1
        end
    end
    return upvalues
end

--- Gets a specific upvalue
function Executor.getupvalue(fn, index)
    if debug.getupvalue then
        local name, value = debug.getupvalue(fn, index)
        return value
    end
    return nil
end

--- Sets an upvalue
function Executor.setupvalue(fn, index, value)
    if debug.setupvalue then
        debug.setupvalue(fn, index, value)
    end
end

--- Gets the protos (nested functions) of a function
function Executor.getprotos(fn)
    -- Would require bytecode access
    return {}
end

--- Gets a specific proto
function Executor.getproto(fn, index, activated)
    -- Would require bytecode access
    return nil
end

--- Gets the stack
function Executor.getstack(level, index)
    -- Would require debug library stack access
    return nil
end

--- Sets a value on the stack
function Executor.setstack(level, index, value)
    -- Would require debug library stack access
end

-- ============================================================================
-- File System Operations (Mock)
-- ============================================================================

-- Virtual file system for emulation
local virtualFS = {}

--- Checks if a file exists
function Executor.isfile(path)
    return virtualFS[path] ~= nil and type(virtualFS[path]) == "string"
end

--- Checks if a folder exists
function Executor.isfolder(path)
    return virtualFS[path] ~= nil and type(virtualFS[path]) == "table"
end

--- Reads a file
function Executor.readfile(path)
    if virtualFS[path] and type(virtualFS[path]) == "string" then
        return virtualFS[path]
    end
    
    -- Try to read actual file if running in standard Lua
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return content
    end
    
    error("Unable to read file: " .. path, 2)
end

--- Writes to a file
function Executor.writefile(path, content)
    virtualFS[path] = content
    
    -- Try to write actual file if running in standard Lua
    local file = io.open(path, "w")
    if file then
        file:write(content)
        file:close()
        return
    end
end

--- Appends to a file
function Executor.appendfile(path, content)
    if virtualFS[path] then
        virtualFS[path] = virtualFS[path] .. content
    else
        virtualFS[path] = content
    end
    
    -- Try to append to actual file
    local file = io.open(path, "a")
    if file then
        file:write(content)
        file:close()
    end
end

--- Deletes a file
function Executor.delfile(path)
    virtualFS[path] = nil
    os.remove(path)
end

--- Creates a folder
function Executor.makefolder(path)
    virtualFS[path] = {}
    -- Would use os-specific commands for real folder creation
end

--- Deletes a folder
function Executor.delfolder(path)
    virtualFS[path] = nil
end

--- Lists files in a folder
function Executor.listfiles(path)
    local files = {}
    local prefix = path:gsub("/$", "") .. "/"
    
    for filePath in pairs(virtualFS) do
        if filePath:sub(1, #prefix) == prefix then
            local remaining = filePath:sub(#prefix + 1)
            local slashPos = remaining:find("/")
            if slashPos then
                remaining = remaining:sub(1, slashPos - 1)
            end
            
            local fullPath = prefix .. remaining
            local found = false
            for _, f in ipairs(files) do
                if f == fullPath then
                    found = true
                    break
                end
            end
            if not found then
                table.insert(files, fullPath)
            end
        end
    end
    
    return files
end

--- Loads a file as a Lua chunk
function Executor.loadfile(path)
    local content = Executor.readfile(path)
    return loadstring(content, "@" .. path)
end

--- Executes a file
function Executor.dofile(path)
    local fn = Executor.loadfile(path)
    if fn then
        return fn()
    end
end

-- ============================================================================
-- Console Functions (Mock)
-- ============================================================================

local consoleOpen = false
local consoleTitle = "Aurora Console"
local consoleBuffer = {}

--- Opens the console window
function Executor.rconsolecreate()
    consoleOpen = true
    consoleBuffer = {}
    print("[Console Created]")
end

--- Opens the console (alias)
function Executor.rconsoleopen()
    Executor.rconsolecreate()
end

--- Prints to the console
function Executor.rconsoleprint(text)
    if consoleOpen then
        table.insert(consoleBuffer, text)
    end
    io.write(text)
end

--- Prints info to console
function Executor.rconsoleinfo(text)
    Executor.rconsoleprint("[INFO] " .. text .. "\n")
end

--- Prints warning to console
function Executor.rconsolewarn(text)
    Executor.rconsoleprint("[WARN] " .. text .. "\n")
end

--- Prints error to console
function Executor.rconsoleerr(text)
    Executor.rconsoleprint("[ERROR] " .. text .. "\n")
end

--- Clears the console
function Executor.rconsoleclear()
    consoleBuffer = {}
    print("[Console Cleared]")
end

--- Sets the console title
function Executor.rconsoletitle(title)
    consoleTitle = title
end

--- Closes the console
function Executor.rconsoledestroy()
    consoleOpen = false
    consoleBuffer = {}
end

--- Closes the console (alias)
function Executor.rconsoleclose()
    Executor.rconsoledestroy()
end

--- Gets input from console
function Executor.rconsoleinput()
    if io.read then
        return io.read("*l")
    end
    return ""
end

--- Gets console name (alias for title)
function Executor.rconsolename(title)
    Executor.rconsoletitle(title)
end

-- ============================================================================
-- Clipboard Functions
-- ============================================================================

local clipboardContent = ""

--- Sets clipboard content
function Executor.setclipboard(content)
    clipboardContent = tostring(content)
end

--- Alias for setclipboard
function Executor.toclipboard(content)
    Executor.setclipboard(content)
end

--- Gets clipboard content (mock)
function Executor.getclipboard()
    return clipboardContent
end

-- ============================================================================
-- HTTP Functions
-- ============================================================================

--- Performs an HTTP request
function Executor.request(options)
    -- Mock HTTP request
    return {
        Success = false,
        StatusCode = 0,
        StatusMessage = "Mocked - HTTP not available",
        Headers = {},
        Body = ""
    }
end

--- Alias for request
function Executor.http_request(options)
    return Executor.request(options)
end

--- Alias for request
function Executor.httpget(url)
    return ""
end

--- Alias for request
function Executor.httppost(url, data)
    return ""
end

-- ============================================================================
-- Miscellaneous Functions
-- ============================================================================

--- Gets the executor name
function Executor.identifyexecutor()
    return "Aurora", "1.0.0"
end

--- Alias for identifyexecutor
function Executor.getexecutorname()
    return "Aurora"
end

--- Gets the HWID (mock)
function Executor.gethwid()
    return "AURORA-MOCK-HWID-12345"
end

--- Gets the hardware ID (mock)
function Executor.gethardwareid()
    return Executor.gethwid()
end

--- Queues a script to run on the actor
function Executor.queue_on_teleport(script)
    -- Mock - would store script to run after teleport
end

--- Alias for queue_on_teleport
function Executor.queueonteleport(script)
    Executor.queue_on_teleport(script)
end

--- Checks if the executor has the specified capability
function Executor.checkcaller()
    return true
end

--- Locks the current thread identity
function Executor.setthreadidentity(identity)
    -- Mock
end

--- Gets the current thread identity
function Executor.getthreadidentity()
    return 2 -- Script identity
end

--- Alias for thread identity
function Executor.setidentity(identity)
    Executor.setthreadidentity(identity)
end

--- Alias for thread identity
function Executor.getidentity()
    return Executor.getthreadidentity()
end

--- Loads a string as bytecode
function Executor.loadstring(source, chunkname)
    local fn, err = load(source, chunkname or "loadstring")
    if not fn then
        return nil, err
    end
    return fn
end

--- Checks if a Lua closure
function Executor.checkclosure(fn)
    return type(fn) == "function"
end

--- Compares two closures
function Executor.compareinstances(a, b)
    return a == b
end

--- Clones a reference
function Executor.cloneref(object)
    return object
end

--- Gets hidden property
function Executor.gethiddenproperty(instance, property)
    if instance and instance[property] ~= nil then
        return instance[property], true
    end
    return nil, false
end

--- Sets hidden property
function Executor.sethiddenproperty(instance, property, value)
    if instance then
        instance[property] = value
        return true
    end
    return false
end

--- Fires a click detector
function Executor.fireclickdetector(detector, distance, playerName)
    -- Mock
end

--- Fires a proximity prompt
function Executor.fireproximityprompt(prompt, amount, skip)
    -- Mock
end

--- Fires touch interest
function Executor.firetouchinterest(part1, part2, toggle)
    -- Mock
end

--- Fires a signal
function Executor.firesignal(signal, ...)
    if signal and signal.Fire then
        signal:Fire(...)
    end
end

--- Decompiles a function (mock)
function Executor.decompile(fn)
    return "-- Decompilation not available in Aurora emulator"
end

--- Saves an instance to file (mock)
function Executor.saveinstance(options)
    -- Mock
    return true
end

--- Draws text on screen (mock)
function Executor.Drawing()
    return {
        new = function(type)
            return {
                Visible = false,
                Color = nil,
                Thickness = 1,
                Position = nil,
                Size = nil,
                Text = "",
                Font = 0,
                Remove = function() end,
                Destroy = function() end
            }
        end
    }
end

return Executor

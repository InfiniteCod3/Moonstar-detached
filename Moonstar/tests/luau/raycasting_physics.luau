-- tests/luau/raycasting_physics.luau
-- Tests raycasting and physics patterns in Roblox

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Raycast parameters builder
local function createRaycastParams(options)
    local params = RaycastParams.new()
    
    if options.filterType then
        params.FilterType = options.filterType
    end
    
    if options.filterDescendants then
        params.FilterDescendantsInstances = options.filterDescendants
    end
    
    if options.ignoreWater ~= nil then
        params.IgnoreWater = options.ignoreWater
    end
    
    if options.collisionGroup then
        params.CollisionGroup = options.collisionGroup
    end
    
    return params
end

-- Basic raycast helper
local function castRay(origin, direction, params)
    local result = Workspace:Raycast(origin, direction, params)
    
    if result then
        return {
            hit = true,
            instance = result.Instance,
            position = result.Position,
            normal = result.Normal,
            distance = result.Distance,
            material = result.Material
        }
    end
    
    return {
        hit = false,
        position = origin + direction
    }
end

-- Ground detection
local function getGroundInfo(position, maxDistance)
    maxDistance = maxDistance or 100
    
    local params = createRaycastParams({
        filterType = Enum.RaycastFilterType.Exclude,
        filterDescendants = {LocalPlayer.Character},
        ignoreWater = true
    })
    
    local result = castRay(position, Vector3.new(0, -maxDistance, 0), params)
    
    if result.hit then
        return {
            grounded = true,
            groundHeight = result.position.Y,
            groundNormal = result.normal,
            groundMaterial = result.material,
            groundPart = result.instance
        }
    end
    
    return {
        grounded = false
    }
end

-- Mouse raycast
local function getMouseTarget(distance)
    distance = distance or 1000
    
    local mouse = LocalPlayer:GetMouse()
    local camera = Workspace.CurrentCamera
    
    if not camera then return nil end
    
    local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
    
    local params = createRaycastParams({
        filterType = Enum.RaycastFilterType.Exclude,
        filterDescendants = {LocalPlayer.Character}
    })
    
    return castRay(ray.Origin, ray.Direction * distance, params)
end

-- Sphere cast simulation (multiple rays)
local function sphereCast(origin, direction, radius, segments)
    segments = segments or 8
    local results = {}
    
    local params = createRaycastParams({
        filterType = Enum.RaycastFilterType.Exclude,
        filterDescendants = {LocalPlayer.Character}
    })
    
    -- Center ray
    local centerResult = castRay(origin, direction, params)
    table.insert(results, centerResult)
    
    -- Calculate perpendicular vectors
    local forward = direction.Unit
    local right = forward:Cross(Vector3.new(0, 1, 0))
    if right.Magnitude < 0.01 then
        right = forward:Cross(Vector3.new(1, 0, 0))
    end
    right = right.Unit
    local up = right:Cross(forward).Unit
    
    -- Cast rays in a circle
    for i = 1, segments do
        local angle = (i / segments) * math.pi * 2
        local offset = (right * math.cos(angle) + up * math.sin(angle)) * radius
        local rayOrigin = origin + offset
        
        local result = castRay(rayOrigin, direction, params)
        table.insert(results, result)
    end
    
    -- Find closest hit
    local closestResult = nil
    local closestDistance = math.huge
    
    for _, result in ipairs(results) do
        if result.hit and result.distance < closestDistance then
            closestDistance = result.distance
            closestResult = result
        end
    end
    
    return closestResult, results
end

-- Line of sight check
local function hasLineOfSight(from, to, ignoreList)
    local direction = to - from
    
    local params = createRaycastParams({
        filterType = Enum.RaycastFilterType.Exclude,
        filterDescendants = ignoreList or {}
    })
    
    local result = castRay(from, direction, params)
    
    if not result.hit then
        return true
    end
    
    -- Check if we hit close to target
    local hitDistance = result.distance
    local targetDistance = direction.Magnitude
    
    return hitDistance >= targetDistance - 0.1
end

-- Physics prediction
local function predictTrajectory(origin, velocity, steps, timeStep)
    steps = steps or 50
    timeStep = timeStep or 0.05
    
    local gravity = Vector3.new(0, -Workspace.Gravity, 0)
    local points = {origin}
    
    local pos = origin
    local vel = velocity
    
    local params = createRaycastParams({
        filterType = Enum.RaycastFilterType.Exclude,
        filterDescendants = {LocalPlayer.Character}
    })
    
    for i = 1, steps do
        local nextVel = vel + gravity * timeStep
        local nextPos = pos + vel * timeStep + gravity * 0.5 * timeStep * timeStep
        
        -- Check for collision
        local result = castRay(pos, nextPos - pos, params)
        
        if result.hit then
            table.insert(points, result.position)
            return points, result
        end
        
        table.insert(points, nextPos)
        pos = nextPos
        vel = nextVel
    end
    
    return points, nil
end

-- Create debug part
local function createDebugPart(position, color, size)
    local part = Instance.new("Part")
    part.Size = size or Vector3.new(0.5, 0.5, 0.5)
    part.Position = position
    part.Color = color or Color3.new(1, 0, 0)
    part.Anchored = true
    part.CanCollide = false
    part.Parent = workspace
    
    task.delay(5, function()
        part:Destroy()
    end)
    
    return part
end

-- Test the functions
print("Raycasting physics test initialized")

-- Ground check test
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    local rootPart = LocalPlayer.Character.HumanoidRootPart
    local groundInfo = getGroundInfo(rootPart.Position)
    
    if groundInfo.grounded then
        print("Ground detected at height:", groundInfo.groundHeight)
        print("Ground material:", groundInfo.groundMaterial.Name)
    else
        print("Not grounded")
    end
end

-- Trajectory prediction test
local testOrigin = Vector3.new(0, 50, 0)
local testVelocity = Vector3.new(20, 30, 0)
local trajectoryPoints, hitResult = predictTrajectory(testOrigin, testVelocity)

print("Trajectory calculated with", #trajectoryPoints, "points")
if hitResult then
    print("Trajectory lands at:", hitResult.position)
end

--[[
    V17 - Physics Constraint Race Condition
    Proof of Concept Exploit

    This exploit injects custom physics constraints during the cleanup
    window, allowing them to survive and provide fly/speed hacks.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Inject a BodyVelocity that survives cleanup
local function injectSurvivingVelocity()
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Create our custom velocity
    local flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Name = "CustomBV" -- Different name might help survive
    flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyVelocity.Velocity = Vector3.new(0, 50, 0) -- Upward = fly

    -- Parent it during a likely cleanup window
    flyVelocity.Parent = hrp

    return flyVelocity
end

-- Continuously re-inject velocity if destroyed
local function persistentFly()
    local currentVelocity = nil

    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Check if our velocity still exists
        if not currentVelocity or not currentVelocity.Parent then
            currentVelocity = injectSurvivingVelocity()
        end
    end)
end

-- Anti-knockback: Inject zero velocity constraint
local function antiKnockback()
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Monitor for any BodyVelocity being added (knockback)
    hrp.ChildAdded:Connect(function(child)
        if child:IsA("BodyVelocity") and child.Name ~= "AntiBV" then
            -- Immediately counter with zero velocity
            task.defer(function()
                if child.Parent then
                    child.Velocity = Vector3.new(0, 0, 0)
                end
            end)
        end
    end)

    -- Keep a permanent anti-knockback velocity
    local antiBV = Instance.new("BodyVelocity")
    antiBV.Name = "AntiBV"
    antiBV.MaxForce = Vector3.new(math.huge, 0, math.huge) -- Horizontal only
    antiBV.Velocity = Vector3.new(0, 0, 0)
    antiBV.Parent = hrp

    -- Protect it from destruction
    antiBV.AncestryChanged:Connect(function()
        if not antiBV.Parent then
            task.defer(function()
                antiBV = Instance.new("BodyVelocity")
                antiBV.Name = "AntiBV"
                antiBV.MaxForce = Vector3.new(math.huge, 0, math.huge)
                antiBV.Velocity = Vector3.new(0, 0, 0)
                antiBV.Parent = hrp
            end)
        end
    end)
end

-- Speed hack using race condition
local function speedHack(speed)
    speed = speed or 100

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    RunService.Heartbeat:Connect(function()
        -- Inject speed velocity every frame
        local speedBV = hrp:FindFirstChild("SpeedBV")
        if not speedBV then
            speedBV = Instance.new("BodyVelocity")
            speedBV.Name = "SpeedBV"
            speedBV.MaxForce = Vector3.new(math.huge, 0, math.huge)
            speedBV.Parent = hrp
        end

        -- Set velocity based on look direction
        speedBV.Velocity = hrp.CFrame.LookVector * speed
    end)
end

return {
    injectSurvivingVelocity = injectSurvivingVelocity,
    persistentFly = persistentFly,
    antiKnockback = antiKnockback,
    speedHack = speedHack
}

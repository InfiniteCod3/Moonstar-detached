-- tests/luau/tween_animations.luau
-- Tests TweenService patterns commonly used in Roblox

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Create test part
local testPart = Instance.new("Part")
testPart.Name = "TweenTestPart"
testPart.Size = Vector3.new(4, 4, 4)
testPart.Position = Vector3.new(0, 10, 0)
testPart.Anchored = true
testPart.BrickColor = BrickColor.new("Bright red")
testPart.Parent = workspace

-- Basic tween info configurations
local tweenInfos = {
    fast = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    smooth = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
    bouncy = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    elastic = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    loop = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
}

-- Tween position
local function tweenPosition(part, targetPos, tweenInfo)
    local tween = TweenService:Create(part, tweenInfo, {
        Position = targetPos
    })
    tween:Play()
    return tween
end

-- Tween multiple properties
local function tweenMultiple(part, properties, tweenInfo)
    local tween = TweenService:Create(part, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Chained tweens with promises
local function chainTweens(part, tweenQueue)
    local function playNext(index)
        if index > #tweenQueue then
            return
        end
        
        local config = tweenQueue[index]
        local tween = TweenService:Create(part, config.info, config.goals)
        
        tween.Completed:Connect(function()
            playNext(index + 1)
        end)
        
        tween:Play()
    end
    
    playNext(1)
end

-- Animation sequence
local sequence = {
    {
        info = tweenInfos.fast,
        goals = {
            Position = Vector3.new(10, 10, 0),
            BrickColor = BrickColor.new("Bright blue")
        }
    },
    {
        info = tweenInfos.smooth,
        goals = {
            Position = Vector3.new(10, 20, 10),
            Size = Vector3.new(6, 6, 6)
        }
    },
    {
        info = tweenInfos.bouncy,
        goals = {
            Position = Vector3.new(0, 10, 0),
            Size = Vector3.new(4, 4, 4)
        }
    },
    {
        info = tweenInfos.elastic,
        goals = {
            Orientation = Vector3.new(0, 90, 0)
        }
    }
}

-- Value tween for custom properties
local tweenValue = Instance.new("NumberValue")
tweenValue.Value = 0

local valueTween = TweenService:Create(tweenValue, tweenInfos.smooth, {
    Value = 100
})

tweenValue.Changed:Connect(function(newValue)
    print("Value changed:", math.floor(newValue))
end)

-- Color interpolation helper
local function lerpColor(c1, c2, alpha)
    return Color3.new(
        c1.R + (c2.R - c1.R) * alpha,
        c1.G + (c2.G - c1.G) * alpha,
        c1.B + (c2.B - c1.B) * alpha
    )
end

-- Custom spring animation (no tween)
local function springAnimation(part, targetPos, stiffness, damping)
    local velocity = Vector3.new(0, 0, 0)
    local connection
    
    connection = RunService.Heartbeat:Connect(function(dt)
        local displacement = targetPos - part.Position
        local springForce = displacement * stiffness
        local dampingForce = velocity * damping
        
        velocity = velocity + (springForce - dampingForce) * dt
        part.Position = part.Position + velocity * dt
        
        if displacement.Magnitude < 0.01 and velocity.Magnitude < 0.01 then
            part.Position = targetPos
            connection:Disconnect()
            print("Spring animation complete")
        end
    end)
end

-- Run animations
print("Starting tween animations test")
chainTweens(testPart, sequence)
valueTween:Play()

task.delay(5, function()
    springAnimation(testPart, Vector3.new(0, 5, 0), 50, 5)
end)

print("Tween animation test initialized")

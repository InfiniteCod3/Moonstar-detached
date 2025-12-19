--[[
    V15 - Client Animation Speed Control
    Proof of Concept Exploit

    This exploit manipulates animation playback speed to trigger
    damage/effects instantly or freeze at advantageous states.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Hook the Animator to manipulate all loaded animations
local function setupAnimationSpeedHack()
    local char = LocalPlayer.Character
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    local animator = humanoid:FindFirstChild("Animator")
    if not animator then return end

    -- Store original function
    local originalLoadAnimation = animator.LoadAnimation

    -- Hook LoadAnimation to modify returned tracks
    animator.LoadAnimation = function(self, animation)
        local track = originalLoadAnimation(self, animation)

        -- Store original AdjustSpeed
        local originalAdjustSpeed = track.AdjustSpeed

        -- Override AdjustSpeed to always use our speed
        track.AdjustSpeed = function(self, speed)
            -- Use 10x speed for instant damage
            originalAdjustSpeed(self, speed * 10)
        end

        -- Immediately set to high speed
        task.defer(function()
            track:AdjustSpeed(10) -- 10x faster
        end)

        return track
    end
end

-- Alternative: Freeze animation at IFrame state
local function freezeAtIFrames()
    local char = LocalPlayer.Character
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    -- Monitor for IFrame-granting animations
    humanoid.AnimationPlayed:Connect(function(track)
        -- Check if this animation grants IFrames (usually ultimate/teleport anims)
        if track.Animation.Name:find("Ultimate") or track.Animation.Name:find("Teleport") then
            -- Wait for IFrame marker, then freeze
            task.delay(0.1, function()
                track:AdjustSpeed(0) -- Freeze animation
                -- Player now stuck in IFrame state
            end)
        end
    end)
end

-- Instant skill execution
local function instantSkillDamage()
    local char = LocalPlayer.Character
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    -- Set all current animations to max speed
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        track:AdjustSpeed(100) -- Near-instant
    end
end

return {
    setupAnimationSpeedHack = setupAnimationSpeedHack,
    freezeAtIFrames = freezeAtIFrames,
    instantSkillDamage = instantSkillDamage
}

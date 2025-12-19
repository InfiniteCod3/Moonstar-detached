--[[
    V16 - Death Effect Bypass
    Proof of Concept Exploit

    This exploit prevents death effects from applying by adding
    fake objects/attributes that the check looks for.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Prevent death effects from ever applying to your character
local function preventDeathEffects()
    local char = LocalPlayer.Character
    if not char then return end

    -- Method 1: Add fake burnVfx child
    -- The check: not arg1_2:FindFirstChild("burnVfx")
    local fakeBurnVfx = Instance.new("Folder")
    fakeBurnVfx.Name = "burnVfx"
    fakeBurnVfx.Parent = char

    -- Method 2: Set DeathEffect attribute
    -- The check: not arg1_2:GetAttribute("DeathEffect")
    char:SetAttribute("DeathEffect", true)

    print("Death effects will now be bypassed!")
end

-- Continuously ensure bypass is active
local function maintainDeathBypass()
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.1) -- Wait for character to load
        preventDeathEffects()
    end)

    -- Apply to current character
    if LocalPlayer.Character then
        preventDeathEffects()
    end
end

-- Monitor and re-apply if removed
local function persistentBypass()
    local char = LocalPlayer.Character
    if not char then return end

    -- Watch for burnVfx removal
    char.ChildRemoved:Connect(function(child)
        if child.Name == "burnVfx" then
            task.wait()
            preventDeathEffects()
        end
    end)

    -- Watch for attribute removal
    char.AttributeChanged:Connect(function(attrName)
        if attrName == "DeathEffect" then
            if not char:GetAttribute("DeathEffect") then
                char:SetAttribute("DeathEffect", true)
            end
        end
    end)
end

-- Remove death effects if they somehow got applied
local function removeDeathEffects()
    local char = LocalPlayer.Character
    if not char then return end

    -- Reset health display
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
    end

    -- Remove any burn VFX that are actual effects
    for _, desc in ipairs(char:GetDescendants()) do
        if desc:IsA("ParticleEmitter") and desc.Name:find("burn") then
            desc.Enabled = false
        end
    end
end

return {
    preventDeathEffects = preventDeathEffects,
    maintainDeathBypass = maintainDeathBypass,
    persistentBypass = persistentBypass,
    removeDeathEffects = removeDeathEffects
}

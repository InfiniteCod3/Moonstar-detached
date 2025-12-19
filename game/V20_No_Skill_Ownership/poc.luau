--[[
    V20 - No Skill Ownership Verification
    Proof of Concept Exploit

    This exploit allows using any skill in the game regardless of
    whether you own the weapon or have unlocked the skill.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ClientInfo = ReplicatedStorage.Remotes.ClientInfo

-- List of all known skills (extracted from file names)
local ALL_SKILLS = {
    -- Basic Sword
    "Entry", "Concept", "Pierce", "Cleave", "Raise", "FinalStrikes",

    -- Elements
    "DancingFlame", "FieryLeap", "GroundDemolition", "EarthCatastrophe",
    "GlowingHail", "DivineSlash", "CelestialUplift", "HarmonicTwipl",

    -- Cyber Katana
    "Siphon", "BladeStorm", "BlinkStrike", "QuickSteps", "FlashOverdrive",
    "RapidBlinks", "PinpointShuriken",

    -- Gauntlet
    "Berserk", "ExplosiveStrikes", "ExplosiveFinale", "BurningPunches",
    "RapidJabs", "BodySlam", "FinalBlow",

    -- Soul Lantern
    "Consume", "Destroy", "DecayingSoul", "GraspingSoul", "SoulDevastation",
    "GraveDigger", "Anguish",

    -- Cosmic
    "EventHorizon", "CelestialCreation", "CelestialCollide", "Universe",
    "Singularity", "AstralMark", "Cluster", "Kneel",

    -- Ultimates
    "BladeStorm", "Consume", "Universe", "StillRiver"
}

-- Use any skill regardless of ownership
local function useAnySkill(skillName)
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Fire skill remote - server doesn't check if we own it
    ClientInfo:FireServer(skillName, {
        ClientCF = hrp.CFrame,
        TeleportPosition = hrp.Position + hrp.CFrame.LookVector * 10
    })

    print("Attempted to use:", skillName)
end

-- Try all ultimate skills
local function useAllUltimates()
    local ultimates = {
        "BladeStorm", "Consume", "Universe", "StillRiver",
        "GreatGeyser", "EventHorizon", "CelestialCreation"
    }

    for _, ultimate in ipairs(ultimates) do
        useAnySkill(ultimate)
        task.wait(1)
    end
end

-- Spam high-damage skills
local function spamDamageSkills()
    local highDamageSkills = {
        "BladeStorm",    -- 30 damage ultimate
        "Consume",       -- 50+ damage ultimate
        "Destroy",       -- 10 damage per hit
        "FinalBlow",     -- 25 damage
        "EarthCatastrophe" -- 25 damage
    }

    while true do
        for _, skill in ipairs(highDamageSkills) do
            useAnySkill(skill)
        end
        task.wait(0.5)
    end
end

-- List skills from a specific weapon category
local function useWeaponSkills(weaponName)
    local weaponSkills = {
        ["Cyber Katana"] = {"Siphon", "BladeStorm", "BlinkStrike", "QuickSteps"},
        ["Soul Lantern"] = {"Consume", "Destroy", "DecayingSoul", "GraspingSoul"},
        ["Cosmic"] = {"EventHorizon", "Universe", "Singularity", "Cluster"},
        ["Gauntlet"] = {"Berserk", "ExplosiveStrikes", "BodySlam", "FinalBlow"}
    }

    local skills = weaponSkills[weaponName]
    if skills then
        for _, skill in ipairs(skills) do
            useAnySkill(skill)
            task.wait(0.5)
        end
    end
end

return {
    useAnySkill = useAnySkill,
    useAllUltimates = useAllUltimates,
    spamDamageSkills = spamDamageSkills,
    useWeaponSkills = useWeaponSkills,
    ALL_SKILLS = ALL_SKILLS
}

-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:49
-- Luau version 6, Types version 3
-- Time taken: 0.001984 seconds

local module = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[2]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 10)
	local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
	BodyVelocity.Velocity = arg1:FindFirstChild("HumanoidRootPart").CFrame.LookVector * -120 + Vector3.new(0, 60, 0)
	game.Debris:AddItem(BodyVelocity, 0.35)
end
return module
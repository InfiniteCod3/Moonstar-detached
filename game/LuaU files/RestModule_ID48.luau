-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:56
-- Luau version 6, Types version 3
-- Time taken: 0.006726 seconds

local module_upvr = {
	Cooldown = 20;
	GlobalCD = 0.2;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 12
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Harp = ReplicatedStorage_upvr.Skills.Harp
	local Rest = Harp.Rest
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid"):LoadAnimation(Rest.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(0.5)
	task.wait(0.2)
	local clone = Rest.Harp:Clone()
	clone.Parent = HumanoidRootPart
	clone:Play()
	var2_upvw.applyDebris(clone, 5)
	local clone_3 = Rest.Harp2:Clone()
	clone_3.Parent = HumanoidRootPart
	clone_3:Play()
	game.Debris:AddItem(clone_3, 5)
	var2_upvw.camShake(arg1, "Bump")
	local clone_2 = Harp.Rest.RestVFX:Clone()
	clone_2.Parent = Folder
	clone_2.CFrame = HumanoidRootPart.CFrame
	var2_upvw.EmitAllDescendants(clone_2)
	clone_2.Whoosh:Play()
	clone_2.Weld.Part0 = HumanoidRootPart
	clone_2.Weld.Part1 = clone_2
	var2_upvw.changeFov(arg1, 60, 0.12, 1)
	task.wait(0.15)
	clone_2.Weld.Part0 = nil
	clone_2.Anchored = true
	local var16
	for i, v in var2_upvw.findEnemiesMagnitude(clone_2.Position, 25), nil do
		if not var2_upvw.CheckBlock(v) then
			var16 += 1
			var2_upvw.camShake(arg1, "SmallBump")
			var2_upvw.applyDebris(var2_upvw.applyStatus(arg1, "Freeze", 1.25), 0)
			var2_upvw.applyStatus(v, "Stunned", 2)
			var2_upvw.applyDamage(v, 12)
			local clone_4 = Rest.vfx:Clone()
			clone_4.Parent = v.HumanoidRootPart
			clone_4.CFrame = v.HumanoidRootPart.CFrame
			clone_4.weld.Part0 = v.HumanoidRootPart
			var2_upvw.EmitAllDescendants(clone_4)
			game.Debris:AddItem(clone_4, 5)
			local HitSFX = clone_4.HitSFX
			HitSFX.PlaybackSpeed += math.random(-2, 2) * 0.1
			clone_4.HitSFX:Play()
			var2_upvw.applyStatus(v, "Ragdoll", 2)
		end
	end
	if var16 <= 0 then
		i = 0.8
		var2_upvw.applyStatus(arg1, "Stunned", i)
		i = 0.8
		var2_upvw.applyStatus(arg1, "AutoRotate", i)
	end
end
return module_upvr
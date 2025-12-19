-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:09
-- Luau version 6, Types version 3
-- Time taken: 0.004357 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 18
module_upvr.GlobalCD = 1.4
local var3_upvw
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[3]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Leverage_upvr = ReplicatedStorage_upvr.Skills["Titans Edge"].Ultimate.Leverage
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Leverage_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play(0)
	var3_upvw.applyStatus(arg1, "Freeze", 2.5)
	var3_upvw.applyStatus(arg1, "GlobalCD", 2)
	var3_upvw.changeFov(arg1, 60, 1, 1)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function(arg1_2) -- Line 40
		--[[ Upvalues[5]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: Leverage_upvr (readonly)
			[5]: Folder_upvr (readonly)
		]]
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 75, 0.01, 0.3)
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(1000000, 0, 1000000)
		BodyVelocity.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * -25
		var3_upvw.applyDebris(BodyVelocity, 1)
		local clone_2 = Leverage_upvr.LeverageVFX:Clone()
		clone_2.Parent = Folder_upvr
		clone_2.CFrame = HumanoidRootPart_upvr.CFrame
		var3_upvw.EmitAllDescendants(clone_2)
		var3_upvw.applyDebris(clone_2, 6)
		var3_upvw.applySound(Leverage_upvr.ShockwaveSFX, clone_2)
		var3_upvw.applySound(Leverage_upvr["AirSlash"..arg1_2], clone_2)
		for _, v in var3_upvw.findEnemiesPart(clone_2.Hitbox), nil do
			var3_upvw.applyDamage(v, 10)
			var3_upvw.applyStatus(v, "Stunned", 1.1)
			var3_upvw.Knockback(v, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -100, 45, 8)
			local clone = Leverage_upvr.HitVFX.hitVFX:Clone()
			clone.Parent = v.Torso
			var3_upvw.EmitAllDescendants(clone)
			var3_upvw.applyDebris(clone, 7)
		end
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 75
		--[[ Upvalues[3]:
			[1]: var3_upvw (copied, read and write)
			[2]: Leverage_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		var3_upvw.applySound(Leverage_upvr[arg1_3], HumanoidRootPart_upvr)
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 79
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:Stop(0.3)
	end), module_upvr.Cooldown)
end
return module_upvr
-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:40
-- Luau version 6, Types version 3
-- Time taken: 0.009993 seconds

local module_upvr = {
	Cooldown = 15;
	GlobalCD = 1.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Flaming_Dance_upvr = ReplicatedStorage_upvr.Skills.Greatsword["Flaming Dance"]
	local Greatsword_upvr = arg1:FindFirstChild("Greatsword")
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Flaming_Dance_upvr.Animation)
	any_LoadAnimation_result1:Play(0.2)
	any_LoadAnimation_result1:AdjustSpeed(1.7)
	task.delay(0.4, function() -- Line 38
		--[[ Upvalues[1]:
			[1]: Greatsword_upvr (readonly)
		]]
		for _, v in Greatsword_upvr.FireVfx:GetChildren() do
			v.Enabled = true
		end
	end)
	var2_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 44
		--[[ Upvalues[1]:
			[1]: Greatsword_upvr (readonly)
		]]
		task.wait(0.4)
		for _, v_2 in Greatsword_upvr.FireVfx:GetChildren() do
			v_2.Enabled = false
		end
	end), module_upvr.Cooldown)
	var2_upvw.applySound(Flaming_Dance_upvr.BodyPrepare, HumanoidRootPart_upvr, 5)
	local var22_upvw = 0
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 55
		--[[ Upvalues[5]:
			[1]: var22_upvw (read and write)
			[2]: var2_upvw (copied, read and write)
			[3]: Flaming_Dance_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: arg1 (readonly)
		]]
		var22_upvw += 1
		local any_applySound_result1_6 = var2_upvw.applySound(Flaming_Dance_upvr.slash, HumanoidRootPart_upvr, 5)
		local any_applySound_result1 = var2_upvw.applySound(Flaming_Dance_upvr.slash2, HumanoidRootPart_upvr, 5)
		local any_applySound_result1_2 = var2_upvw.applySound(Flaming_Dance_upvr.Fire, HumanoidRootPart_upvr, 5)
		local any_applySound_result1_5 = var2_upvw.applySound(Flaming_Dance_upvr.Swing, HumanoidRootPart_upvr, 5)
		any_applySound_result1_6.PlaybackSpeed += var22_upvw * 0.1
		any_applySound_result1.PlaybackSpeed += var22_upvw * 0.1
		any_applySound_result1_2.PlaybackSpeed += var22_upvw * 0.1
		any_applySound_result1_5.PlaybackSpeed += var22_upvw * 0.05
		if var22_upvw == 4 then
			var2_upvw.changeFov(arg1, 70, 1, 2)
			var2_upvw.applySound(Flaming_Dance_upvr.BodyPrepare2, HumanoidRootPart_upvr, 5)
		end
		var2_upvw.camShake(arg1, "Bump")
		if var22_upvw == 1 then
			var2_upvw.changeFov(arg1, 60, 0.25, 2)
		end
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.647059, 0.509804), 1)
		var2_upvw.Blur(arg1, 8, 0.5)
		local any_findEnemiesMagnitude_result1 = var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 12)
		if 0 < #any_findEnemiesMagnitude_result1 then
			local any_applySound_result1_3 = var2_upvw.applySound(Flaming_Dance_upvr.hitSFX, arg1.Torso, 5)
			any_applySound_result1_3.PlaybackSpeed += var22_upvw * 0.05
			local any_applySound_result1_4 = var2_upvw.applySound(Flaming_Dance_upvr.hitSFX2, arg1.Torso, 5)
			any_applySound_result1_4.PlaybackSpeed += var22_upvw * 0.05
		end
		for _, v_3 in any_findEnemiesMagnitude_result1 do
			local clone_2 = Flaming_Dance_upvr.HitVFX.hitVFX:Clone()
			clone_2.Parent = v_3.Torso
			var2_upvw.EmitAllDescendants(clone_2)
			var2_upvw.applyDebris(clone_2, 5)
			var2_upvw.applyDamage(v_3, 4)
			if var22_upvw == 4 then
				var2_upvw.applyStatus(v_3, "Stunned", 1.1)
			else
				var2_upvw.applyStatus(v_3, "Stunned", 0.8)
			end
			var2_upvw.camShake(v_3, "Bump")
			var2_upvw.changeFov(v_3, 50, 0.01, 0.75)
			var2_upvw.flashScreen(v_3, Color3.new(1, 0.647059, 0.509804), 1)
			var2_upvw.Blur(v_3, 8, 0.5)
		end
	end), module_upvr.Cooldown)
	local any_applyStatus_result1_upvr_2 = var2_upvw.applyStatus(arg1, "Slowed", 3.5)
	local any_applyStatus_result1_upvr = var2_upvw.applyStatus(arg1, "GlobalCD", 3.5)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("BigSlash"):Connect(function() -- Line 110
		--[[ Upvalues[7]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Flaming_Dance_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: any_applyStatus_result1_upvr_2 (readonly)
			[7]: any_applyStatus_result1_upvr (readonly)
		]]
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 40, 0.01, 1)
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.647059, 0.509804), 1)
		var2_upvw.Blur(arg1, 8, 1)
		local clone = Flaming_Dance_upvr.FireSlash:Clone()
		clone.Parent = Folder_upvr
		clone.CFrame = HumanoidRootPart_upvr.CFrame
		var2_upvw.EmitAllDescendants(clone)
		var2_upvw.applySound(Flaming_Dance_upvr.FireSlashSFX, clone, 5)
		var2_upvw.applySound(Flaming_Dance_upvr.FireBurst, clone, 5)
		local var41
		for _, v_4 in var2_upvw.findEnemiesPart(clone.Hitbox), nil do
			if not var2_upvw.CheckBlock(v_4, true) then
				var2_upvw.applyDamage(v_4, 6)
				var2_upvw.applyStatus(v_4, "Ragdoll", 1)
				var2_upvw.Knockback(v_4, HumanoidRootPart_upvr.Position, 35)
				var2_upvw.camShake(v_4, "Bump")
				var2_upvw.changeFov(v_4, 40, 0.01, 1)
				var2_upvw.flashScreen(v_4, Color3.new(1, 0.647059, 0.509804), 1)
				var2_upvw.Blur(v_4, 8, 1)
			end
		end
		if nil then
			var2_upvw.applyDebris(any_applyStatus_result1_upvr_2, 0.3)
			var2_upvw.applyDebris(any_applyStatus_result1_upvr, 0.1)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
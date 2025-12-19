-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:35
-- Luau version 6, Types version 3
-- Time taken: 0.010673 seconds

local module_upvr = {
	Cooldown = 18;
	GlobalCD = 1.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Dancing_Flame_upvr = ReplicatedStorage_upvr.Skills.Greatsword.Ultimate["Dancing Flame"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Dancing_Flame_upvr.Animation)
	any_LoadAnimation_result1:Play(0.2)
	any_LoadAnimation_result1:AdjustSpeed(1.1)
	var2_upvw.applyStatus(arg1, "Slowed", 4)
	var2_upvw.applyStatus(arg1, "GlobalCD", 4)
	var2_upvw.applyStatus(arg1, "IFrames", 3.5)
	local tbl_upvr = {}
	for _, v in arg1:FindFirstChild("Greatsword").DancingFlameTrail:GetDescendants() do
		if v:IsA("Trail") then
			table.insert(tbl_upvr, v)
		end
	end
	var2_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 47
		--[[ Upvalues[3]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: arg2 (readonly)
			[3]: tbl_upvr (readonly)
		]]
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "Dancing Flame")
		task.wait(0.2)
		for _, v_2 in tbl_upvr do
			v_2.Enabled = false
		end
	end), module_upvr.Cooldown)
	var2_upvw.applySound(Dancing_Flame_upvr.BodyPrepare, HumanoidRootPart_upvr, 5)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("DancingFlame"):Connect(function() -- Line 57
		--[[ Upvalues[1]:
			[1]: tbl_upvr (readonly)
		]]
		task.wait(0.18)
		for _, v_3 in tbl_upvr do
			v_3.Enabled = true
		end
	end), module_upvr.Cooldown)
	local var22_upvw = 0
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 65
		--[[ Upvalues[6]:
			[1]: var22_upvw (read and write)
			[2]: var2_upvw (copied, read and write)
			[3]: Dancing_Flame_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: tbl_upvr (readonly)
			[6]: arg1 (readonly)
		]]
		var22_upvw += 1
		local any_applySound_result1_6 = var2_upvw.applySound(Dancing_Flame_upvr.slash, HumanoidRootPart_upvr, 5)
		local any_applySound_result1 = var2_upvw.applySound(Dancing_Flame_upvr.slash2, HumanoidRootPart_upvr, 5)
		local any_applySound_result1_4 = var2_upvw.applySound(Dancing_Flame_upvr.Fire, HumanoidRootPart_upvr, 5)
		local any_applySound_result1_5 = var2_upvw.applySound(Dancing_Flame_upvr.Swing, HumanoidRootPart_upvr, 5)
		any_applySound_result1_6.PlaybackSpeed += var22_upvw * 0.1
		any_applySound_result1.PlaybackSpeed += var22_upvw * 0.1
		any_applySound_result1_4.PlaybackSpeed += var22_upvw * 0.1
		any_applySound_result1_5.PlaybackSpeed += var22_upvw * 0.05
		if var22_upvw == 4 then
			task.delay(0.12, function() -- Line 77
				--[[ Upvalues[1]:
					[1]: tbl_upvr (copied, readonly)
				]]
				for _, v_4 in tbl_upvr do
					v_4.Enabled = false
				end
			end)
			var2_upvw.changeFov(arg1, 70, 1, 2)
			var2_upvw.applySound(Dancing_Flame_upvr.BodyPrepare2, HumanoidRootPart_upvr, 5)
		end
		var2_upvw.camShake(arg1, "Bump")
		if var22_upvw == 1 then
			var2_upvw.changeFov(arg1, 40, 0.25, 2)
		end
		var2_upvw.flashScreen(arg1, Color3.new(0.411765, 0.952941, 1), 1)
		var2_upvw.Blur(arg1, 8, 0.5)
		local clone_3 = Dancing_Flame_upvr.Hitbox:Clone()
		clone_3.Parent = arg1
		clone_3.weld.Part0 = HumanoidRootPart_upvr
		clone_3.weld.Part1 = clone_3
		var2_upvw.applyDebris(clone_3, 2)
		local any_findEnemiesPart_result1 = var2_upvw.findEnemiesPart(clone_3)
		if 0 < #any_findEnemiesPart_result1 then
			local any_applySound_result1_3 = var2_upvw.applySound(Dancing_Flame_upvr.hitSFX, arg1.Torso, 5)
			any_applySound_result1_3.PlaybackSpeed += var22_upvw * 0.05
			local any_applySound_result1_2 = var2_upvw.applySound(Dancing_Flame_upvr.hitSFX2, arg1.Torso, 5)
			any_applySound_result1_2.PlaybackSpeed += var22_upvw * 0.05
		end
		for _, v_5 in any_findEnemiesPart_result1 do
			local clone = Dancing_Flame_upvr.HitVFX.hitVFX:Clone()
			clone.Parent = v_5.Torso
			var2_upvw.EmitAllDescendants(clone)
			var2_upvw.applyDebris(clone, 2)
			var2_upvw.applyDamage(v_5, 5)
			var2_upvw.applyStatus(v_5, "Stunned", 1.25)
			var2_upvw.Knockback(v_5, HumanoidRootPart_upvr.Position, 8, 0)
			var2_upvw.camShake(v_5, "Bump")
			var2_upvw.changeFov(v_5, 50, 0.01, 0.75)
			var2_upvw.flashScreen(v_5, Color3.new(0.329412, 0.964706, 1), 1)
			var2_upvw.Blur(v_5, 8, 0.5)
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("BigSlash"):Connect(function() -- Line 129
		--[[ Upvalues[6]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Dancing_Flame_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
		]]
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 40, 0.01, 1)
		var2_upvw.flashScreen(arg1, Color3.new(0.423529, 0.992157, 1), 1)
		var2_upvw.Blur(arg1, 8, 1)
		local clone_2 = Dancing_Flame_upvr.FireSlash:Clone()
		clone_2.Parent = Folder_upvr
		clone_2.CFrame = HumanoidRootPart_upvr.CFrame
		var2_upvw.EmitAllDescendants(clone_2)
		var2_upvw.applySound(Dancing_Flame_upvr.FireSlashSFX, clone_2, 5)
		TweenService_upvr:Create(var2_upvw.applySound(Dancing_Flame_upvr.FireBurst, clone_2, 5), TweenInfo.new(2.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Volume = 0;
		}):Play()
		for _, v_6 in var2_upvw.findEnemiesPart(clone_2.Hitbox), nil do
			if not var2_upvw.CheckBlock(v_6, true) then
				var2_upvw.applyDamage(v_6, 10)
				var2_upvw.applyStatus(v_6, "Ragdoll", 1)
				var2_upvw.Knockback(v_6, HumanoidRootPart_upvr.Position, 35)
				var2_upvw.camShake(v_6, "Bump")
				var2_upvw.changeFov(v_6, 40, 0.01, 1)
				var2_upvw.flashScreen(v_6, Color3.new(1, 0.647059, 0.509804), 1)
				var2_upvw.Blur(v_6, 8, 1)
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr
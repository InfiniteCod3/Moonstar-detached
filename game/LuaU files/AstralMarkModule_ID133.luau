-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:14
-- Luau version 6, Types version 3
-- Time taken: 0.010072 seconds

local module_upvr = {
	Cooldown = 36;
	GlobalCD = 0.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 12
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
	local Astral_Mark_upvr = ReplicatedStorage_upvr.Skills.Nebula["Astral Mark"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Astral_Mark_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.2)
	var2_upvw.applyStatus(arg1, "Slowed", 1.6)
	local any_applyVFX_result1_3_upvr = var2_upvw.applyVFX(Astral_Mark_upvr.VFX.Charge, HumanoidRootPart_upvr, 5)
	var2_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 33
		--[[ Upvalues[1]:
			[1]: any_applyVFX_result1_3_upvr (readonly)
		]]
		for _, v in any_applyVFX_result1_3_upvr:GetChildren() do
			v.Enabled = false
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 39
		--[[ Upvalues[3]:
			[1]: Astral_Mark_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		for _, v_2 in Astral_Mark_upvr:GetChildren() do
			if v_2:IsA("Sound") and v_2.Name == arg1_2 then
				var2_upvw.applySound(v_2, HumanoidRootPart_upvr)
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.camShake(arg1, "SmallBump")
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Mark"):Connect(function() -- Line 49
		--[[ Upvalues[8]:
			[1]: any_applyVFX_result1_3_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: Astral_Mark_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
		]]
		for _, v_3 in any_applyVFX_result1_3_upvr:GetChildren() do
			v_3.Enabled = false
		end
		var2_upvw.changeFov(arg1, 67, 0.6, 1)
		var2_upvw.camShake(arg1, "SmallBump")
		var2_upvw.Blur(arg1, 15, 0.5)
		local any_findEnemiesMagnitude_result1 = var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 7.5, 9.5)
		if 0 < #any_findEnemiesMagnitude_result1 then
			var2_upvw.camShake(arg1, "Bump")
		end
		for _, v_4_upvr in any_findEnemiesMagnitude_result1 do
			if not var2_upvw.CheckBlock(v_4_upvr, true) then
				var2_upvw.applyDamage(v_4_upvr, 5)
				var2_upvw.applyStatus(v_4_upvr, "Stunned", 1.5)
				var2_upvw.applyStatus(v_4_upvr, "AutoRotate", 1.5)
				var2_upvw.Knockback(v_4_upvr, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -50, 60)
				v_4_upvr.HumanoidRootPart.CFrame = CFrame.lookAt(v_4_upvr.HumanoidRootPart.Position, Vector3.new(HumanoidRootPart_upvr.Position.X, v_4_upvr.HumanoidRootPart.Position.Y, HumanoidRootPart_upvr.Position.Z))
				v_4_upvr.Humanoid:LoadAnimation(Astral_Mark_upvr.TargetAnimation1):Play()
				var2_upvw.applySound(Astral_Mark_upvr.HitSFX, v_4_upvr.Torso)
				var2_upvw.applySound(Astral_Mark_upvr.HitSFX2, v_4_upvr.Torso)
				local clone = Astral_Mark_upvr.RingMesh:Clone()
				clone.Parent = Folder_upvr
				clone.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 5) * CFrame.Angles(math.random((math.pi/2)), 0, 0)
				TweenService_upvr:Create(clone, TweenInfo.new(0.5), {
					Size = Vector3.new(19, 0.20000, 19);
					Transparency = 1;
				}):Play()
				var2_upvw.applyDebris(clone, 1)
				local any_applyVFX_result1 = var2_upvw.applyVFX(Astral_Mark_upvr.SlapVFX, Folder_upvr, 5)
				any_applyVFX_result1.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 5
				var2_upvw.applySound(Astral_Mark_upvr.Shockwave, any_applyVFX_result1)
				local any_applyVFX_result1_2_upvr = var2_upvw.applyVFX(Astral_Mark_upvr.VFX.Star, v_4_upvr.HumanoidRootPart, 6)
				TweenService_upvr:Create(any_applyVFX_result1_2_upvr, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Position = Vector3.new(0, 6, 0);
				}):Play()
				task.delay(0.8, function() -- Line 93
					--[[ Upvalues[7]:
						[1]: var2_upvw (copied, read and write)
						[2]: arg1 (copied, readonly)
						[3]: Astral_Mark_upvr (copied, readonly)
						[4]: v_4_upvr (readonly)
						[5]: any_applyVFX_result1_2_upvr (readonly)
						[6]: TweenService_upvr (copied, readonly)
						[7]: module_upvr (copied, readonly)
					]]
					var2_upvw.camShake(arg1, "SmallBump")
					var2_upvw.Blur(arg1, 15, 0.4)
					var2_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 0.5)
					var2_upvw.applySound(Astral_Mark_upvr.Star, v_4_upvr.Torso)
					var2_upvw.applyVFX(Astral_Mark_upvr.VFX.Shine, any_applyVFX_result1_2_upvr, 5)
					local any_Create_result1 = TweenService_upvr:Create(any_applyVFX_result1_2_upvr, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Position = Vector3.new(0, 0, 0);
					})
					any_Create_result1:Play()
					var2_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 104
						--[[ Upvalues[5]:
							[1]: any_applyVFX_result1_2_upvr (copied, readonly)
							[2]: var2_upvw (copied, read and write)
							[3]: Astral_Mark_upvr (copied, readonly)
							[4]: arg1 (copied, readonly)
							[5]: v_4_upvr (copied, readonly)
						]]
						for _, v_5 in any_applyVFX_result1_2_upvr.StarVFX:GetChildren() do
							v_5.Enabled = false
						end
						var2_upvw.applyVFX(Astral_Mark_upvr.VFX.Explode, any_applyVFX_result1_2_upvr, 5)
						var2_upvw.camShake(arg1, "Bump")
						var2_upvw.Blur(arg1, 15, 0.5)
						var2_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 0.5)
						var2_upvw.applySound(Astral_Mark_upvr.Explode, v_4_upvr.Torso)
						var2_upvw.applyDamage(v_4_upvr, 10)
						var2_upvw.applyStatus(v_4_upvr, "Stunned", 2)
						var2_upvw.applyStatus(v_4_upvr, "AutoRotate", 2)
						v_4_upvr.Humanoid:LoadAnimation(Astral_Mark_upvr.TargetAnimation2):Play()
					end), module_upvr.Cooldown)
				end)
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr
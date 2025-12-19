-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:12
-- Luau version 6, Types version 3
-- Time taken: 0.016439 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 20
module_upvr.GlobalCD = 1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Surge_upvr = ReplicatedStorage_upvr.Skills["Blood Sword"].Ultimate.Surge
	for _, v in Humanoid:GetPlayingAnimationTracks() do
		v:Stop(0)
	end
	local any_LoadAnimation_result1 = Humanoid.Animator:LoadAnimation(Surge_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(1.1)
	any_LoadAnimation_result1.Priority = Enum.AnimationPriority.Action3
	var3_upvw.applyStatus(arg1, "Freeze", 2.5)
	var3_upvw.applyStatus(arg1, "GlobalCD", 2.5)
	var3_upvw.changeFov(arg1, 72, 1, 5)
	var3_upvw.applySound(Surge_upvr.Charge, HumanoidRootPart_upvr)
	local var16_upvw = 0
	local var17_upvw
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("toss"):Connect(function() -- Line 50
		--[[ Upvalues[8]:
			[1]: var16_upvw (read and write)
			[2]: var3_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: Surge_upvr (readonly)
			[6]: var17_upvw (read and write)
			[7]: Folder_upvr (readonly)
			[8]: TweenService_upvr (copied, readonly)
		]]
		var16_upvw += 1
		var3_upvw.applyStatus(arg1, "Freeze", 0.1)
		var3_upvw.applyStatus(arg1, "GlobalCD", 0.1)
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(1000000, 0, 1000000)
		BodyVelocity.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * -50
		var3_upvw.applyDebris(BodyVelocity, 1)
		var3_upvw.applyVelocity(HumanoidRootPart_upvr, BodyVelocity, 0.4)
		local clone_2 = Surge_upvr.BloodEmit.CastVFX:Clone()
		clone_2.Parent = HumanoidRootPart_upvr
		var3_upvw.EmitAllDescendants(clone_2)
		var3_upvw.applyDebris(clone_2, 5)
		local clone = Surge_upvr.BloodEmit.HitVFX:Clone()
		clone.Parent = HumanoidRootPart_upvr
		var3_upvw.EmitAllDescendants(clone)
		var3_upvw.applyDebris(clone, 5)
		var3_upvw.applySound(Surge_upvr.Charge, HumanoidRootPart_upvr)
		var3_upvw.camShake(arg1, "SmallBump")
		var3_upvw.changeFov(arg1, 90, 0, 2)
		var3_upvw.Blur(arg1, 10, 2)
		if not var17_upvw then
			var17_upvw = Surge_upvr.Surge:Clone()
			var17_upvw.Parent = Folder_upvr
			var17_upvw.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 100 + Vector3.new(0, -3, 0)
		end
		if var17_upvw then
			local var27_upvr = var17_upvw[var16_upvw]
			for _, v_2 in var17_upvw:GetChildren() do
				if v_2:IsA("BasePart") then
					v_2:SetAttribute("Enabled", false)
				end
			end
			for _, v_3 in var17_upvw:GetDescendants() do
				if v_3:IsA("ParticleEmitter") then
					v_3.Enabled = false
				elseif v_3:IsA("Sound") and v_3.Name == "rain" then
					v_3:Stop()
				end
			end
			for _, v_4 in var27_upvr:GetDescendants() do
				if v_4:IsA("ParticleEmitter") then
					v_4.Enabled = true
					v_4.Brightness += 0.2
				elseif v_4:IsA("Sound") then
					v_4:Play()
				end
			end
			var27_upvr:SetAttribute("Enabled", true)
			task.delay(3, function() -- Line 111
				--[[ Upvalues[2]:
					[1]: var27_upvr (readonly)
					[2]: TweenService_upvr (copied, readonly)
				]]
				var27_upvr:SetAttribute("Enabled", false)
				for _, v_5 in var27_upvr:GetDescendants() do
					if v_5:IsA("ParticleEmitter") then
						v_5.Enabled = false
					elseif v_5:IsA("Sound") and v_5.Name == "rain" then
						TweenService_upvr:Create(v_5, TweenInfo.new(2), {
							Volume = 0;
						}):Play()
					end
				end
			end)
			var3_upvw.Blur(arg1, 25, 0.5)
			task.spawn(function() -- Line 124
				--[[ Upvalues[6]:
					[1]: var27_upvr (readonly)
					[2]: var3_upvw (copied, read and write)
					[3]: Surge_upvr (copied, readonly)
					[4]: var16_upvw (copied, read and write)
					[5]: arg1 (copied, readonly)
					[6]: var17_upvw (copied, read and write)
				]]
				while task.wait(0.1) and var27_upvr and var27_upvr:GetAttribute("Enabled") do
					local any_applySound_result1 = var3_upvw.applySound(Surge_upvr:FindFirstChild("Laser"..var16_upvw), var27_upvr)
					any_applySound_result1.PlaybackSpeed += math.random(-3, 3) * 0.1
					local any_applySound_result1_2 = var3_upvw.applySound(Surge_upvr:FindFirstChild("splat"..var16_upvw), var27_upvr)
					any_applySound_result1_2.PlaybackSpeed += math.random(-3, 3) * 0.1
					var3_upvw.changeFov(arg1, 69, 0, 0.5)
					var3_upvw.camShake(arg1, "SmallBump")
					for _, v_6 in var3_upvw.findEnemiesPart(var17_upvw[var16_upvw].Hitbox), nil do
						var3_upvw.applyDamage(v_6, 1)
						var3_upvw.applyStatus(v_6, "Stunned", 0.5)
						var3_upvw.applyStatus(v_6, "AutoRotate", 0.5)
					end
				end
			end)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
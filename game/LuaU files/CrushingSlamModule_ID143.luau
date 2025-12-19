-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:46
-- Luau version 6, Types version 3
-- Time taken: 0.017689 seconds

local module_upvr = {
	Cooldown = 25;
	GlobalCD = 1;
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
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Crushing_Slam_upvr = ReplicatedStorage_upvr.Skills["Earth Hammer"]["Crushing Slam"]
	local clone_2_upvr = Crushing_Slam_upvr.Sounds.sounds:Clone()
	clone_2_upvr.Parent = arg1.Torso
	var2_upvw.applyDebris(clone_2_upvr, 10)
	local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Crushing_Slam_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	var2_upvw.applyStatus(arg1, "Slowed", 1)
	var2_upvw.changeFov(arg1, 65, 0.5, 1)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("grab"):Connect(function() -- Line 41
		--[[ Upvalues[10]:
			[1]: var2_upvw (copied, read and write)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: arg1 (readonly)
			[4]: clone_2_upvr (readonly)
			[5]: Crushing_Slam_upvr (readonly)
			[6]: any_LoadAnimation_result1_upvr (readonly)
			[7]: Humanoid_upvr (readonly)
			[8]: TweenService_upvr (copied, readonly)
			[9]: Folder_upvr (readonly)
			[10]: module_upvr (copied, readonly)
		]]
		local any_findEnemiesMagnitude_result1 = var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 4.5, 6.7)
		if 0 < #any_findEnemiesMagnitude_result1 then
			for _, v_upvr in any_findEnemiesMagnitude_result1 do
				var2_upvw.SetRootPriority(arg1, 100, 3)
				var2_upvw.applyStatus(arg1, "GlobalCD", 3.1)
				var2_upvw.applyStatus(v_upvr, "Stunned", 3)
				var2_upvw.applyStatus(v_upvr, "AutoRotate", 3)
				var2_upvw.applyStatus(v_upvr, "IFrames", 3)
				var2_upvw.applyDamage(v_upvr, 5, true, true)
				var2_upvw.camShake(arg1, "SmallBump")
				var2_upvw.camShake(v_upvr, "SmallBump")
				var2_upvw.changeFov(arg1, 90, 0.8, 3)
				var2_upvw.changeFov(v_upvr, 90, 0.8, 3)
				clone_2_upvr.Grab:Play()
				clone_2_upvr.Punch:Play()
				clone_2_upvr.Cloth:Play()
				clone_2_upvr.HammerSlam:Play()
				local any_LoadAnimation_result1_upvr_2 = v_upvr.Humanoid.Animator:LoadAnimation(Crushing_Slam_upvr.AnimationTarget)
				any_LoadAnimation_result1_upvr_2:Play()
				any_LoadAnimation_result1_upvr_2.TimePosition = any_LoadAnimation_result1_upvr.TimePosition
				local any_applyWeld_result1_upvr = var2_upvw.applyWeld(v_upvr, Vector3.new(0, 0, 4), Vector3.new(0, 180, 0), 5)
				local any_applyStatus_result1_upvr = var2_upvw.applyStatus(arg1, "Freeze", 3)
				local any_applyStatus_result1_upvr_3 = var2_upvw.applyStatus(arg1, "IFrames", 3)
				var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slam"):Connect(function() -- Line 73
					--[[ Upvalues[14]:
						[1]: any_applyWeld_result1_upvr (readonly)
						[2]: var2_upvw (copied, read and write)
						[3]: any_applyStatus_result1_upvr (readonly)
						[4]: any_applyStatus_result1_upvr_3 (readonly)
						[5]: clone_2_upvr (copied, readonly)
						[6]: arg1 (copied, readonly)
						[7]: any_LoadAnimation_result1_upvr_2 (readonly)
						[8]: v_upvr (readonly)
						[9]: Humanoid_upvr (copied, readonly)
						[10]: Crushing_Slam_upvr (copied, readonly)
						[11]: TweenService_upvr (copied, readonly)
						[12]: Folder_upvr (copied, readonly)
						[13]: HumanoidRootPart_upvr (copied, readonly)
						[14]: module_upvr (copied, readonly)
					]]
					any_applyWeld_result1_upvr:Destroy()
					var2_upvw.applyDebris(any_applyStatus_result1_upvr, 0)
					var2_upvw.applyDebris(any_applyStatus_result1_upvr_3, 0)
					clone_2_upvr.slam:Play()
					clone_2_upvr.slam2:Play()
					any_LoadAnimation_result1_upvr_2:AdjustSpeed(0.2)
					var2_upvw.applyStatus(v_upvr, "Ragdoll", 2)
					local BodyVelocity_upvr = Instance.new("BodyVelocity", v_upvr.Torso)
					BodyVelocity_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					BodyVelocity_upvr.Velocity = Vector3.new(0, 0, 0)
					var2_upvw.applyDebris(BodyVelocity_upvr, 2)
					var2_upvw.applyStatus(arg1, "Slowed", 2)
					var2_upvw.applyStatus(arg1, "GlobalCD", 2)
					var2_upvw.crater(1, v_upvr.Torso.Position, 2.25, 0.5)
					var2_upvw.CreateDebris(v_upvr.Torso.Position, 5, 0.55, 0.9, 0.2)
					var2_upvw.applyDamage(v_upvr, 5, true, true)
					var2_upvw.camShake(arg1, "SmallBump")
					var2_upvw.camShake(v_upvr, "SmallBump")
					var2_upvw.changeFov(arg1, 60, 0.01, 3)
					var2_upvw.changeFov(v_upvr, 60, 0.01, 3)
					task.wait()
					local any_LoadAnimation_result1_upvr_3 = Humanoid_upvr.Animator:LoadAnimation(Crushing_Slam_upvr.Animation2)
					any_LoadAnimation_result1_upvr_3:Play(0.6)
					any_LoadAnimation_result1_upvr_3:AdjustSpeed(0.15)
					task.delay(1.2, function() -- Line 110
						--[[ Upvalues[1]:
							[1]: any_LoadAnimation_result1_upvr_3 (readonly)
						]]
						any_LoadAnimation_result1_upvr_3:AdjustSpeed(1.5)
					end)
					clone_2_upvr.swingPrep:Play()
					clone_2_upvr.swingPrep2:Play()
					var2_upvw.changeFov(arg1, 92, 1, 3)
					var2_upvw.changeFov(v_upvr, 60, 0.01, 3)
					local any_applyStatus_result1_upvr_4 = var2_upvw.applyStatus(v_upvr, "DashDB", 2)
					local any_applyStatus_result1_upvr_2 = var2_upvw.applyStatus(arg1, "HyperArmor", 2)
					var2_upvw.conTimer(any_LoadAnimation_result1_upvr_3:GetMarkerReachedSignal("smash"):Connect(function() -- Line 120
						--[[ Upvalues[12]:
							[1]: var2_upvw (copied, read and write)
							[2]: arg1 (copied, readonly)
							[3]: v_upvr (copied, readonly)
							[4]: any_applyStatus_result1_upvr_4 (readonly)
							[5]: any_applyStatus_result1_upvr_2 (readonly)
							[6]: any_LoadAnimation_result1_upvr_2 (copied, readonly)
							[7]: BodyVelocity_upvr (readonly)
							[8]: clone_2_upvr (copied, readonly)
							[9]: TweenService_upvr (copied, readonly)
							[10]: Crushing_Slam_upvr (copied, readonly)
							[11]: Folder_upvr (copied, readonly)
							[12]: HumanoidRootPart_upvr (copied, readonly)
						]]
						var2_upvw.camShake(arg1, "Bump")
						var2_upvw.camShake(v_upvr, "Bump")
						var2_upvw.changeFov(arg1, 45, 0.01, 0.6)
						var2_upvw.changeFov(v_upvr, 45, 0.01, 0.6)
						var2_upvw.impactFrame2(arg1, 0.05)
						var2_upvw.impactFrame2(v_upvr, 0.05)
						var2_upvw.Blur(arg1, 24, 0.5)
						var2_upvw.Blur(v_upvr, 24, 0.5)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr_4, 0)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr_2, 0)
						any_LoadAnimation_result1_upvr_2:Stop(1)
						BodyVelocity_upvr:Destroy()
						clone_2_upvr.smash:Play()
						clone_2_upvr.smash2:Play()
						clone_2_upvr.smash3:Play()
						TweenService_upvr:Create(clone_2_upvr.HammerSlam, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
							Volume = 0;
						}):Play()
						local clone = Crushing_Slam_upvr.SmashVfx:Clone()
						clone.Parent = Folder_upvr
						clone.Position = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5 + Vector3.new(0, -2.5, 0)
						clone.Rotation = Vector3.new(0, 0, 0)
						var2_upvw.EmitAllDescendants(clone)
						var2_upvw.applyDebris(clone, 10)
						var2_upvw.crater(1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5, 3, 0.6)
						var2_upvw.crater(1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5, 4.5, 1.2)
						var2_upvw.crater(1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5, 6, 2.4)
						var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5, 15, 1.2, 1, 0.2)
						for _, v_2 in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5 + Vector3.new(0, -2.5, 0), 9, true), nil do
							var2_upvw.applyDamage(v_2, 10, true, false)
						end
						for _, v_3 in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5 + Vector3.new(0, -2.5, 0), 20, true), nil do
							var2_upvw.applyDamage(v_3, 5, true, false)
							var2_upvw.applyStatus(v_3, "Ragdoll", 2)
							var2_upvw.Knockback(v_3, clone.Position, -5, 10)
							var2_upvw.blood(v_3, 5)
						end
					end), module_upvr.Cooldown)
					var2_upvw.conTimer(any_LoadAnimation_result1_upvr_3:GetMarkerReachedSignal("end"):Connect(function() -- Line 173
						--[[ Upvalues[3]:
							[1]: any_LoadAnimation_result1_upvr_3 (readonly)
							[2]: var2_upvw (copied, read and write)
							[3]: arg1 (copied, readonly)
						]]
						any_LoadAnimation_result1_upvr_3:Stop(1)
						var2_upvw.applyStatus(arg1, "Freeze", 0.8)
						var2_upvw.applyStatus(arg1, "GlobalCD", 0.75)
					end), module_upvr.Cooldown)
					var2_upvw.conTimer(any_LoadAnimation_result1_upvr_3:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 179
						--[[ Upvalues[1]:
							[1]: clone_2_upvr (copied, readonly)
						]]
						if clone_2_upvr:FindFirstChild(arg1_2) then
							for _, v_4 in clone_2_upvr:GetChildren() do
								if v_4.Name == arg1_2 then
									v_4:Play()
								end
							end
							return
						end
					end), module_upvr.Cooldown)
				end), module_upvr.Cooldown)
				return
			end
		else
			any_LoadAnimation_result1_upvr:Stop(0.6)
			clone_2_upvr.whoosh:Destroy()
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 202
		--[[ Upvalues[1]:
			[1]: clone_2_upvr (readonly)
		]]
		if clone_2_upvr:FindFirstChild(arg1_3) then
			for _, v_5 in clone_2_upvr:GetChildren() do
				if v_5.Name == arg1_3 then
					v_5:Play()
				end
			end
			return
		end
	end), module_upvr.Cooldown)
end
return module_upvr
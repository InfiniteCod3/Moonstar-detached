-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:43
-- Luau version 6, Types version 3
-- Time taken: 0.016878 seconds

local module_upvr = {
	Cooldown = 25;
	GlobalCD = 1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Crushing_Barrage_upvr = ReplicatedStorage_upvr.Skills["Earth Hammer"].Ultimate["Crushing Barrage"]
	local clone_3_upvr = Crushing_Barrage_upvr.Sounds.sounds:Clone()
	clone_3_upvr.Parent = arg1.Torso
	var2_upvw.applyDebris(clone_3_upvr, 10)
	local any_LoadAnimation_result1_upvr_3 = Humanoid_upvr.Animator:LoadAnimation(Crushing_Barrage_upvr.Animation)
	any_LoadAnimation_result1_upvr_3:Play()
	var2_upvw.applyStatus(arg1, "Slowed", 1)
	var2_upvw.changeFov(arg1, 65, 0.5, 1)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local var11_upvw
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr_3:GetMarkerReachedSignal("grab"):Connect(function() -- Line 41
		--[[ Upvalues[10]:
			[1]: var2_upvw (copied, read and write)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: arg1 (readonly)
			[4]: clone_3_upvr (readonly)
			[5]: Crushing_Barrage_upvr (readonly)
			[6]: any_LoadAnimation_result1_upvr_3 (readonly)
			[7]: var11_upvw (read and write)
			[8]: Humanoid_upvr (readonly)
			[9]: module_upvr (copied, readonly)
			[10]: Folder_upvr (readonly)
		]]
		local any_findEnemiesMagnitude_result1 = var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5, 6)
		if 0 < #any_findEnemiesMagnitude_result1 then
			for _, v_upvr in any_findEnemiesMagnitude_result1 do
				var2_upvw.SetRootPriority(arg1, 100, 3)
				var2_upvw.applyStatus(arg1, "GlobalCD", 3.1)
				var2_upvw.applyDamage(v_upvr, 3, true, true)
				var2_upvw.camShake(arg1, "Bump")
				var2_upvw.camShake(v_upvr, "Bump")
				var2_upvw.changeFov(arg1, 90, 0.8, 3)
				var2_upvw.changeFov(v_upvr, 90, 0.8, 3)
				clone_3_upvr.Grab:Play()
				clone_3_upvr.Punch:Play()
				clone_3_upvr.Cloth:Play()
				local any_LoadAnimation_result1_upvr = v_upvr.Humanoid.Animator:LoadAnimation(Crushing_Barrage_upvr.AnimationTarget)
				any_LoadAnimation_result1_upvr:Play()
				any_LoadAnimation_result1_upvr.TimePosition = any_LoadAnimation_result1_upvr_3.TimePosition
				var11_upvw = v_upvr
				local any_applyWeld_result1_upvr = var2_upvw.applyWeld(v_upvr, Vector3.new(0, 0, 4), Vector3.new(0, 180, 0), 5)
				local any_applyStatus_result1_upvr_3 = var2_upvw.applyStatus(arg1, "Freeze", 3)
				local any_applyStatus_result1_upvr_8 = var2_upvw.applyStatus(arg1, "IFrames", 3)
				local any_applyStatus_result1_upvr_11 = var2_upvw.applyStatus(v_upvr, "AutoRotate", 10)
				local any_applyStatus_result1_upvr_9 = var2_upvw.applyStatus(v_upvr, "Stunned", 10)
				local any_applyStatus_result1_upvr_5 = var2_upvw.applyStatus(v_upvr, "IFrames", 10)
				var2_upvw.conTimer(any_LoadAnimation_result1_upvr_3:GetMarkerReachedSignal("slam"):Connect(function() -- Line 75
					--[[ Upvalues[17]:
						[1]: any_applyWeld_result1_upvr (readonly)
						[2]: var2_upvw (copied, read and write)
						[3]: any_applyStatus_result1_upvr_3 (readonly)
						[4]: any_applyStatus_result1_upvr_8 (readonly)
						[5]: clone_3_upvr (copied, readonly)
						[6]: arg1 (copied, readonly)
						[7]: any_LoadAnimation_result1_upvr (readonly)
						[8]: v_upvr (readonly)
						[9]: Humanoid_upvr (copied, readonly)
						[10]: Crushing_Barrage_upvr (copied, readonly)
						[11]: HumanoidRootPart_upvr (copied, readonly)
						[12]: module_upvr (copied, readonly)
						[13]: var11_upvw (copied, read and write)
						[14]: Folder_upvr (copied, readonly)
						[15]: any_applyStatus_result1_upvr_11 (readonly)
						[16]: any_applyStatus_result1_upvr_9 (readonly)
						[17]: any_applyStatus_result1_upvr_5 (readonly)
					]]
					any_applyWeld_result1_upvr:Destroy()
					var2_upvw.applyDebris(any_applyStatus_result1_upvr_3, 0)
					var2_upvw.applyDebris(any_applyStatus_result1_upvr_8, 0)
					clone_3_upvr.slam:Play()
					clone_3_upvr.slam2:Play()
					any_LoadAnimation_result1_upvr:AdjustSpeed(0.2)
					local BodyVelocity_upvr = Instance.new("BodyVelocity", v_upvr.Torso)
					BodyVelocity_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					BodyVelocity_upvr.Velocity = Vector3.new(0, 0, 0)
					var2_upvw.applyDebris(BodyVelocity_upvr, 10)
					var2_upvw.crater(1, v_upvr.Torso.Position, 2.25, 0.5)
					var2_upvw.CreateDebris(v_upvr.Torso.Position, 5, 0.55, 0.9, 0.2)
					var2_upvw.applyDamage(v_upvr, 3, true, true)
					var2_upvw.camShake(arg1, "BigBump")
					var2_upvw.camShake(v_upvr, "BigBump")
					var2_upvw.changeFov(arg1, 60, 0.01, 3)
					var2_upvw.changeFov(v_upvr, 60, 0.01, 3)
					task.wait()
					local any_LoadAnimation_result1_upvr_2 = Humanoid_upvr.Animator:LoadAnimation(Crushing_Barrage_upvr.Animation2)
					any_LoadAnimation_result1_upvr_2:Play(0.6)
					any_LoadAnimation_result1_upvr_2:AdjustSpeed(0.15)
					task.delay(1.2, function() -- Line 115
						--[[ Upvalues[1]:
							[1]: any_LoadAnimation_result1_upvr_2 (readonly)
						]]
						any_LoadAnimation_result1_upvr_2:AdjustSpeed(1.5)
					end)
					var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("sfxstart"):Connect(function() -- Line 119
						--[[ Upvalues[3]:
							[1]: Crushing_Barrage_upvr (copied, readonly)
							[2]: HumanoidRootPart_upvr (copied, readonly)
							[3]: var2_upvw (copied, read and write)
						]]
						local clone = Crushing_Barrage_upvr.MainSFX:Clone()
						clone.Parent = HumanoidRootPart_upvr
						clone:Play()
						var2_upvw.applyDebris(clone, 12)
					end), module_upvr.Cooldown)
					clone_3_upvr.swingPrep:Play()
					clone_3_upvr.swingPrep2:Play()
					var2_upvw.changeFov(arg1, 92, 1, 3)
					var2_upvw.changeFov(v_upvr, 60, 0.01, 3)
					local any_applyStatus_result1_upvr_7 = var2_upvw.applyStatus(arg1, "HyperArmor", 2)
					var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("smash"):Connect(function() -- Line 133
						--[[ Upvalues[10]:
							[1]: var2_upvw (copied, read and write)
							[2]: arg1 (copied, readonly)
							[3]: v_upvr (copied, readonly)
							[4]: any_applyStatus_result1_upvr_7 (readonly)
							[5]: any_LoadAnimation_result1_upvr (copied, readonly)
							[6]: clone_3_upvr (copied, readonly)
							[7]: var11_upvw (copied, read and write)
							[8]: HumanoidRootPart_upvr (copied, readonly)
							[9]: Crushing_Barrage_upvr (copied, readonly)
							[10]: Folder_upvr (copied, readonly)
						]]
						var2_upvw.camShake(arg1, "Explosion")
						var2_upvw.camShake(v_upvr, "Explosion")
						var2_upvw.changeFov(arg1, 45, 0.01, 0.6)
						var2_upvw.changeFov(v_upvr, 45, 0.01, 0.6)
						var2_upvw.impactFrame2(arg1, 0.05)
						var2_upvw.impactFrame2(v_upvr, 0.05)
						var2_upvw.Blur(arg1, 24, 0.5)
						var2_upvw.Blur(v_upvr, 24, 0.5)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr_7, 0)
						any_LoadAnimation_result1_upvr:Stop(1)
						clone_3_upvr.smash:Play()
						clone_3_upvr.smash2:Play()
						clone_3_upvr.smash3:Play()
						var11_upvw.HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5 + Vector3.new(0, -2.5, 0)) * var11_upvw.HumanoidRootPart.CFrame - var11_upvw.HumanoidRootPart.CFrame.p
						local clone_2 = Crushing_Barrage_upvr.SmashVfx:Clone()
						clone_2.Parent = Folder_upvr
						clone_2.Position = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5 + Vector3.new(0, -2.5, 0)
						clone_2.Rotation = Vector3.new(0, 0, 0)
						var2_upvw.EmitAllDescendants(clone_2)
						var2_upvw.applyDebris(clone_2, 10)
						var2_upvw.crater(1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5, 3, 0.6)
						var2_upvw.crater(1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5, 4.5, 1.2)
						var2_upvw.crater(1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5, 6, 2.4)
						var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5, 15, 1.2, 1, 0.2)
						for _, v_2 in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5 + Vector3.new(0, -2.5, 0), 9, true), nil do
							if v_2 == var11_upvw then
								var2_upvw.applyDamage(v_2, 3, true, false)
							else
								var2_upvw.applyDamage(v_2, 3, false, false)
							end
						end
						for _, v_3 in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5.5 + Vector3.new(0, -2.5, 0), 20, true), nil do
							if v_3 == var11_upvw then
								var2_upvw.applyDamage(v_3, 3, true, false)
							else
								var2_upvw.applyDamage(v_3, 3, false, false)
							end
							var2_upvw.applyStatus(v_3, "Ragdoll", 2)
							var2_upvw.Knockback(v_3, clone_2.Position, -5, 10)
							var2_upvw.blood(v_3, 5)
						end
					end), module_upvr.Cooldown)
					local any_applyStatus_result1_upvr_6 = var2_upvw.applyStatus(arg1, "IFrames", 10)
					local any_applyStatus_result1_upvr_4 = var2_upvw.applyStatus(arg1, "GlobalCD", 10)
					local any_applyStatus_result1_upvr = var2_upvw.applyStatus(arg1, "Slowed", 10)
					local any_applyStatus_result1_upvr_10 = var2_upvw.applyStatus(v_upvr, "Ragdoll", 10)
					local any_applyStatus_result1_upvr_2 = var2_upvw.applyStatus(v_upvr, "DashDB", 10)
					var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("end"):Connect(function() -- Line 196
						--[[ Upvalues[13]:
							[1]: BodyVelocity_upvr (readonly)
							[2]: var2_upvw (copied, read and write)
							[3]: any_applyStatus_result1_upvr_6 (readonly)
							[4]: any_applyStatus_result1_upvr_4 (readonly)
							[5]: any_applyStatus_result1_upvr (readonly)
							[6]: any_applyStatus_result1_upvr_11 (copied, readonly)
							[7]: v_upvr (copied, readonly)
							[8]: any_applyStatus_result1_upvr_9 (copied, readonly)
							[9]: any_applyStatus_result1_upvr_5 (copied, readonly)
							[10]: any_applyStatus_result1_upvr_10 (readonly)
							[11]: any_applyStatus_result1_upvr_2 (readonly)
							[12]: any_LoadAnimation_result1_upvr_2 (readonly)
							[13]: arg1 (copied, readonly)
						]]
						BodyVelocity_upvr:Destroy()
						var2_upvw.applyDebris(any_applyStatus_result1_upvr_6, 0)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr_4, 0)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr, 0)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr_11, 0, v_upvr)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr_9, 0, v_upvr)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr_5, 0, v_upvr)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr_10, 0, v_upvr)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr_2, 0, v_upvr)
						any_LoadAnimation_result1_upvr_2:Stop(1)
						var2_upvw.applyStatus(arg1, "Freeze", 0.8)
						var2_upvw.applyStatus(arg1, "GlobalCD", 0.75)
					end), module_upvr.Cooldown)
					var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 215
						--[[ Upvalues[1]:
							[1]: clone_3_upvr (copied, readonly)
						]]
						if clone_3_upvr:FindFirstChild(arg1_2) then
							for _, v_4 in clone_3_upvr:GetChildren() do
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
			any_LoadAnimation_result1_upvr_3:Stop(0.6)
			clone_3_upvr.whoosh:Destroy()
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr_3:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 238
		--[[ Upvalues[1]:
			[1]: clone_3_upvr (readonly)
		]]
		if clone_3_upvr:FindFirstChild(arg1_3) then
			for _, v_5 in clone_3_upvr:GetChildren() do
				if v_5.Name == arg1_3 then
					v_5:Play()
				end
			end
			return
		end
	end), module_upvr.Cooldown)
end
return module_upvr
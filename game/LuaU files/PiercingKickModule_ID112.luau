-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:18
-- Luau version 6, Types version 3
-- Time taken: 0.011444 seconds

local module_upvr = {
	Cooldown = 19;
	GlobalCD = 0.9;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local RunService_upvr = game:GetService("RunService")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[5]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: RunService_upvr (readonly)
		[5]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Piercing_Kick_upvr = ReplicatedStorage_upvr.Skills.Dagger["Piercing Kick"]
	local clone_upvr = Piercing_Kick_upvr["Animation Dagger"]:Clone()
	clone_upvr.Parent = arg1
	clone_upvr.weld.Part0 = HumanoidRootPart_upvr
	clone_upvr.weld.Part1 = clone_upvr
	game.Debris:AddItem(clone_upvr, 5)
	local any_LoadAnimation_result1_2_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Piercing_Kick_upvr.Animation)
	any_LoadAnimation_result1_2_upvr:Play()
	any_LoadAnimation_result1_2_upvr:AdjustSpeed(0.9)
	var2_upvw.applyStatus(arg1, "Freeze", 1)
	local clone_upvr_2 = Piercing_Kick_upvr.Part.sounds:Clone()
	clone_upvr_2.Parent = arg1.Torso
	game.Debris:AddItem(clone_upvr_2, 10)
	clone_upvr_2.ArmWhoosh:Play()
	task.delay(0.24, function() -- Line 47
		--[[ Upvalues[1]:
			[1]: clone_upvr_2 (readonly)
		]]
		clone_upvr_2.ArmWhoosh2:Play()
	end)
	local var13_upvw
	local var14_upvw
	any_LoadAnimation_result1_2_upvr:GetMarkerReachedSignal("grab"):Connect(function() -- Line 55
		--[[ Upvalues[8]:
			[1]: var2_upvw (copied, read and write)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: any_LoadAnimation_result1_2_upvr (readonly)
			[4]: var13_upvw (read and write)
			[5]: arg1 (readonly)
			[6]: Piercing_Kick_upvr (readonly)
			[7]: var14_upvw (read and write)
			[8]: clone_upvr_2 (readonly)
		]]
		local any_findEnemiesMagnitude_result1 = var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 7.4, 8)
		if #any_findEnemiesMagnitude_result1 <= 0 then
			any_LoadAnimation_result1_2_upvr:Stop(0.3)
		end
		for _, v in any_findEnemiesMagnitude_result1 do
			if var2_upvw.CheckBlock(v, true) then break end
			var13_upvw = v
			var2_upvw.applyStatus(arg1, "GlobalCD", 1.8)
			var2_upvw.applyStatus(arg1, "Freeze", 1.8)
			var2_upvw.applyStatus(arg1, "AutoRotate", 1.8)
			var2_upvw.applyStatus(arg1, "IFrames", 1.8)
			var2_upvw.applyStatus(var13_upvw, "Stunned", 1.8)
			var2_upvw.applyStatus(var13_upvw, "AutoRotate", 1.8)
			var2_upvw.applyStatus(var13_upvw, "IFrames", 1.8)
			var2_upvw.applyDamage(var13_upvw, 2, true, true)
			any_LoadAnimation_result1_2_upvr:AdjustSpeed(1)
			local any_LoadAnimation_result1 = v.Humanoid.Animator:LoadAnimation(Piercing_Kick_upvr.TargetAnimation)
			any_LoadAnimation_result1:Play()
			any_LoadAnimation_result1.TimePosition = any_LoadAnimation_result1_2_upvr.TimePosition
			var14_upvw = var2_upvw.applyWeld(var13_upvw, Vector3.new(0, 0, 5), Vector3.new(0, 180, 0), 1.8)
			var2_upvw.changeFov(arg1, 65, 0.02, 3)
			var2_upvw.changeFov(var13_upvw, 65, 0.02, 3)
			clone_upvr_2.grab:Play()
			clone_upvr_2.EnemyThrow:Play()
			var2_upvw.SetRootPriority(arg1, 100, 1.8)
			return
		end
	end)
	local var20_upvw = true
	any_LoadAnimation_result1_2_upvr:GetMarkerReachedSignal("throw"):Connect(function() -- Line 97
		--[[ Upvalues[9]:
			[1]: var13_upvw (read and write)
			[2]: any_LoadAnimation_result1_2_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: var14_upvw (read and write)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: arg1 (readonly)
			[7]: clone_upvr_2 (readonly)
			[8]: RunService_upvr (copied, readonly)
			[9]: var20_upvw (read and write)
		]]
		if not var13_upvw.Parent then
			any_LoadAnimation_result1_2_upvr:Stop()
		else
			var2_upvw.applyDebris(var14_upvw, 0)
			var2_upvw.applyDamage(var13_upvw, 4, true, true)
			var2_upvw.Knockback(var13_upvw, HumanoidRootPart_upvr.Position, 38, 14, 0.55)
			var2_upvw.applyStatus(var13_upvw, "Ragdoll", 2.5)
			var2_upvw.applyStatus(var13_upvw, "DashDB", 1.8)
			var2_upvw.changeFov(arg1, 95, 0.1, 3)
			var2_upvw.changeFov(var13_upvw, 95, 0.1, 3)
			clone_upvr_2.BigWhoosh:Play()
			any_LoadAnimation_result1_2_upvr:AdjustSpeed(0.96)
			local var23_upvw
			var23_upvw = RunService_upvr.Stepped:Connect(function() -- Line 112
				--[[ Upvalues[4]:
					[1]: var20_upvw (copied, read and write)
					[2]: var23_upvw (read and write)
					[3]: HumanoidRootPart_upvr (copied, readonly)
					[4]: var13_upvw (copied, read and write)
				]]
				if not var20_upvw then
					var23_upvw:Disconnect()
				else
					HumanoidRootPart_upvr.CFrame = CFrame.lookAt(HumanoidRootPart_upvr.Position, var13_upvw.HumanoidRootPart.Position)
				end
			end)
		end
	end)
	any_LoadAnimation_result1_2_upvr:GetMarkerReachedSignal("kick"):Connect(function() -- Line 120
		--[[ Upvalues[11]:
			[1]: var20_upvw (read and write)
			[2]: var13_upvw (read and write)
			[3]: any_LoadAnimation_result1_2_upvr (readonly)
			[4]: clone_upvr (readonly)
			[5]: var2_upvw (copied, read and write)
			[6]: arg1 (readonly)
			[7]: clone_upvr_2 (readonly)
			[8]: Piercing_Kick_upvr (readonly)
			[9]: Folder_upvr (readonly)
			[10]: HumanoidRootPart_upvr (readonly)
			[11]: TweenService_upvr (copied, readonly)
		]]
		var20_upvw = false
		if not var13_upvw.Parent then
			any_LoadAnimation_result1_2_upvr:Stop()
		else
			clone_upvr:Destroy()
			var2_upvw.changeFov(arg1, 70, 0.01, 0.8)
			var2_upvw.camShake(arg1, "Bump")
			clone_upvr_2.daggerkick:Play()
			var2_upvw.Blur(arg1, 8, 0.6)
			local clone_upvr_3 = Piercing_Kick_upvr["Throwing Dagger"]:Clone()
			clone_upvr_3.Parent = Folder_upvr
			clone_upvr_3.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 4
			clone_upvr_3.CFrame = CFrame.lookAt(clone_upvr_3.Position, var13_upvw.HumanoidRootPart.Position)
			game.Debris:AddItem(clone_upvr_3, 6)
			var2_upvw.EmitAllDescendants(clone_upvr_3.shockwave)
			local any_Create_result1 = TweenService_upvr:Create(clone_upvr_3, TweenInfo.new(0.24, Enum.EasingStyle.Linear), {
				CFrame = CFrame.new(var13_upvw.HumanoidRootPart.Position) * clone_upvr_3.CFrame - clone_upvr_3.CFrame.p;
			})
			any_Create_result1:Play()
			any_Create_result1.Completed:Connect(function() -- Line 143
				--[[ Upvalues[4]:
					[1]: var13_upvw (copied, read and write)
					[2]: clone_upvr_3 (readonly)
					[3]: var2_upvw (copied, read and write)
					[4]: arg1 (copied, readonly)
				]]
				if not var13_upvw.Parent then
					clone_upvr_3:Destroy()
				else
					clone_upvr_3.Anchored = false
					clone_upvr_3.weld.Part0 = var13_upvw.Torso
					clone_upvr_3.weld.Part1 = clone_upvr_3
					clone_upvr_3.hitSFX:Play()
					var2_upvw.EmitAllDescendants(clone_upvr_3.HitVfx)
					var2_upvw.blood(var13_upvw, 4)
					var2_upvw.Blur(arg1, 16, 0.45)
					var2_upvw.flashScreen(arg1, Color3.new(1, 0.32549, 0.32549), 0.4)
					var2_upvw.changeFov(arg1, 65, 0.01, 1.5)
					var2_upvw.Blur(var13_upvw, 16, 0.45)
					var2_upvw.flashScreen(var13_upvw, Color3.new(1, 0.32549, 0.32549), 0.4)
					var2_upvw.changeFov(var13_upvw, 65, 0.01, 1.5)
					var2_upvw.applyDamage(var13_upvw, 4, true)
				end
			end)
			delay(5, function() -- Line 165
				--[[ Upvalues[2]:
					[1]: clone_upvr_3 (readonly)
					[2]: TweenService_upvr (copied, readonly)
				]]
				if not clone_upvr_3.Parent then
				else
					TweenService_upvr:Create(clone_upvr_3, TweenInfo.new(1), {
						Transparency = 1;
					}):Play()
					for _, v_2 in clone_upvr_3.DaggerParts:GetChildren() do
						if v_2:IsA("BasePart") then
							TweenService_upvr:Create(v_2, TweenInfo.new(1), {
								Transparency = 1;
							}):Play()
						end
					end
				end
			end)
		end
	end)
end
return module_upvr
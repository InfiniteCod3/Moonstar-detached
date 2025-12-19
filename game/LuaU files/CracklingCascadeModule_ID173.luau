-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:08
-- Luau version 6, Types version 3
-- Time taken: 0.022664 seconds

local module_upvr = {
	Cooldown = 13;
	GlobalCD = 0.1;
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
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Crackling_Cascade_upvr = ReplicatedStorage_upvr.Skills["Firework Rapier"].Ultimate["Crackling Cascade"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Crackling_Cascade_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(0.8)
	local Firework_Rapier_upvr = arg1:FindFirstChild("Firework Rapier")
	local function ToggleTrails_upvr(arg1_2) -- Line 34, Named "ToggleTrails"
		--[[ Upvalues[1]:
			[1]: Firework_Rapier_upvr (readonly)
		]]
		for _, v in Firework_Rapier_upvr:GetDescendants() do
			if v:IsA("Trail") and v.Name == "Trail" then
				v.Enabled = arg1_2
			end
		end
	end
	ToggleTrails_upvr(true)
	var2_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 43
		--[[ Upvalues[1]:
			[1]: ToggleTrails_upvr (readonly)
		]]
		ToggleTrails_upvr(false)
	end), module_upvr.Cooldown)
	local var18_upvw = 0
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("spin"):Connect(function() -- Line 48
		--[[ Upvalues[3]:
			[1]: var18_upvw (read and write)
			[2]: Crackling_Cascade_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		var18_upvw += 1
		local clone = Crackling_Cascade_upvr.SpinSFX:Clone()
		clone.Parent = HumanoidRootPart_upvr
		clone:Play()
		clone.PlaybackSpeed += var18_upvw * 0.1
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("charge"):Connect(function() -- Line 56
		--[[ Upvalues[2]:
			[1]: Crackling_Cascade_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
		]]
		local clone_2 = Crackling_Cascade_upvr.IndicatorSFX:Clone()
		clone_2.Parent = HumanoidRootPart_upvr
		clone_2:Play()
	end), module_upvr.Cooldown)
	var2_upvw.applyStatus(arg1, "AutoRotate", 1.6)
	var2_upvw.applyStatus(arg1, "Freeze", 1.6)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.6)
	var2_upvw.camShake(arg1, "SmallBump")
	var2_upvw.changeFov(arg1, 25, 0.8, 2)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("ability"):Connect(function() -- Line 70
		--[[ Upvalues[8]:
			[1]: Crackling_Cascade_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: RunService_upvr (copied, readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
		]]
		local clone_3 = Crackling_Cascade_upvr.ShockwaveVFX:Clone()
		clone_3.Parent = Folder_upvr
		clone_3.CFrame = HumanoidRootPart_upvr.CFrame + Vector3.new(0, -3, 0)
		var2_upvw.applyDebris(clone_3, 5)
		var2_upvw.EmitAllDescendants(clone_3)
		for _, v_2 in clone_3:GetChildren() do
			if v_2:IsA("Sound") then
				v_2:Play()
			end
		end
		var2_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 1)
		var2_upvw.camShake(arg1, "Explosion")
		var2_upvw.changeFov(arg1, 300, 0.05, 5)
		var2_upvw.Blur(arg1, 25, 0.6)
		for _, v_3_upvr in var2_upvw.findEnemiesPart(clone_3.Hitbox, true), nil do
			if not var2_upvw.CheckBlock(v_3_upvr) then
				var2_upvw.applyDamage(v_3_upvr, 5)
				var2_upvw.Knockback(v_3_upvr, HumanoidRootPart_upvr.Position, 80)
				var2_upvw.applyStatus(v_3_upvr, "Stunned", 1)
				var2_upvw.flashScreen(v_3_upvr, Color3.new(1, 1, 1), 1)
				var2_upvw.camShake(v_3_upvr, "Explosion")
				var2_upvw.changeFov(v_3_upvr, 300, 0.05, 5)
				var2_upvw.Blur(v_3_upvr, 25, 0.6)
				local clone_upvr_2 = Crackling_Cascade_upvr.WhiteFireworkCore:Clone()
				clone_upvr_2.Parent = Folder_upvr
				clone_upvr_2.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 1.2 + Vector3.new(0, -3, 0)
				clone_upvr_2.CFrame *= CFrame.Angles(0, math.rad(math.random(-1, 1) * 75), math.rad(math.random(-1, 0) * 75))
				var2_upvw.applyDebris(clone_upvr_2, 6)
				local var32_upvw = true
				task.spawn(function() -- Line 117
					--[[ Upvalues[10]:
						[1]: var32_upvw (read and write)
						[2]: Crackling_Cascade_upvr (copied, readonly)
						[3]: Folder_upvr (copied, readonly)
						[4]: clone_upvr_2 (readonly)
						[5]: v_3_upvr (readonly)
						[6]: var2_upvw (copied, read and write)
						[7]: RunService_upvr (copied, readonly)
						[8]: TweenService_upvr (copied, readonly)
						[9]: arg1 (copied, readonly)
						[10]: module_upvr (copied, readonly)
					]]
					while task.wait(0.1) and var32_upvw ~= false do
						local clone_upvr = Crackling_Cascade_upvr.WhiteFirework:Clone()
						clone_upvr.Parent = Folder_upvr
						clone_upvr.CFrame = clone_upvr_2.CFrame
						clone_upvr.CFrame = CFrame.lookAt(clone_upvr.Position, v_3_upvr.HumanoidRootPart.Position)
						clone_upvr.CFrame *= CFrame.Angles(0, math.rad(math.random(-1, 1) * 75), math.rad(math.random(-1, 0) * 75))
						var2_upvw.applyDebris(clone_upvr, 6)
						clone_upvr.shoot:Play()
						local var36_upvw
						var36_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 129
							--[[ Upvalues[7]:
								[1]: clone_upvr_2 (copied, readonly)
								[2]: v_3_upvr (copied, readonly)
								[3]: var36_upvw (read and write)
								[4]: var2_upvw (copied, read and write)
								[5]: clone_upvr (readonly)
								[6]: TweenService_upvr (copied, readonly)
								[7]: arg1 (copied, readonly)
							]]
							if not clone_upvr_2.Parent or not v_3_upvr.Parent then
								var36_upvw:Disconnect()
							else
								if not v_3_upvr.Parent then
									var36_upvw:Disconnect()
									var2_upvw.EmitAllDescendants(clone_upvr.ExplosionVFX)
									for _, v_4 in clone_upvr_2.FireworkBall:GetDescendants() do
										if v_4:IsA("ParticleEmitter") then
											v_4:Destroy()
										elseif v_4:IsA("Trail") then
											v_4.Enabled = false
										end
									end
									return
								end
								TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
									Position = clone_upvr.Position + clone_upvr.CFrame.LookVector * 12;
								}):Play()
								local Magnitude = (clone_upvr.Position - v_3_upvr.HumanoidRootPart.Position).Magnitude
								if Magnitude <= 15 then
									TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.1), {
										CFrame = CFrame.lookAt(clone_upvr.Position, v_3_upvr.HumanoidRootPart.Position);
									}):Play()
								else
									TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.4), {
										CFrame = CFrame.lookAt(clone_upvr.Position, v_3_upvr.HumanoidRootPart.Position);
									}):Play()
								end
								if Magnitude <= 4 then
									var36_upvw:Disconnect()
									var2_upvw.EmitAllDescendants(clone_upvr.ExplosionVFX)
									for _, v_5 in clone_upvr.FireworkBall:GetDescendants() do
										if v_5:IsA("ParticleEmitter") then
											v_5:Destroy()
										elseif v_5:IsA("Trail") then
											v_5.Enabled = false
										end
									end
									for _, v_6 in clone_upvr.ExplosionVFX:GetChildren() do
										if v_6:IsA("Sound") then
											v_6.PlaybackSpeed += math.random(-1, 1) * 0.1
											v_6:Play()
										end
									end
									var2_upvw.EmitAllDescendants(clone_upvr.ExplosionVFX)
									var2_upvw.applyDamage(v_3_upvr, 1)
									var2_upvw.applyStatus(v_3_upvr, "Stunned", 1)
									var2_upvw.camShake(v_3_upvr, "SmallBump")
									var2_upvw.flashScreen(v_3_upvr, Color3.new(1, 1, 1), 0.1)
									var2_upvw.camShake(arg1, "SmallBump")
									var2_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 0.1)
								end
							end
						end), module_upvr.Cooldown)
					end
				end)
				local var57_upvw
				var57_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 196
					--[[ Upvalues[6]:
						[1]: clone_upvr_2 (readonly)
						[2]: v_3_upvr (readonly)
						[3]: var32_upvw (read and write)
						[4]: var57_upvw (read and write)
						[5]: var2_upvw (copied, read and write)
						[6]: TweenService_upvr (copied, readonly)
					]]
					if not clone_upvr_2.Parent or not v_3_upvr.Parent then
						var32_upvw = false
						var57_upvw:Disconnect()
					else
						if not v_3_upvr.Parent then
							var32_upvw = false
							var57_upvw:Disconnect()
							clone_upvr_2.Dissapear:Play()
							var2_upvw.EmitAllDescendants(clone_upvr_2.ExplosionVFX)
							for _, v_7 in clone_upvr_2.FireworkBall:GetDescendants() do
								if v_7:IsA("ParticleEmitter") then
									v_7:Destroy()
								elseif v_7:IsA("Trail") then
									v_7.Enabled = false
								end
							end
							return
						end
						TweenService_upvr:Create(clone_upvr_2, TweenInfo.new(4), {
							CFrame = CFrame.lookAt(clone_upvr_2.Position, v_3_upvr.HumanoidRootPart.Position);
						}):Play()
						TweenService_upvr:Create(clone_upvr_2, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
							Position = clone_upvr_2.Position + clone_upvr_2.CFrame.LookVector * 12 + Vector3.new(0, 1, 0);
						}):Play()
					end
				end), module_upvr.Cooldown)
				task.delay(4, function() -- Line 222
					--[[ Upvalues[3]:
						[1]: clone_upvr_2 (readonly)
						[2]: var32_upvw (read and write)
						[3]: var2_upvw (copied, read and write)
					]]
					if not clone_upvr_2 then
					else
						var32_upvw = false
						clone_upvr_2.Dissapear:Play()
						var2_upvw.EmitAllDescendants(clone_upvr_2.ExplosionVFX)
						for _, v_8 in clone_upvr_2.FireworkBall:GetDescendants() do
							if v_8:IsA("ParticleEmitter") then
								v_8:Destroy()
							elseif v_8:IsA("Trail") then
								v_8.Enabled = false
							end
						end
					end
				end)
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr
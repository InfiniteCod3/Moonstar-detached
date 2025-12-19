-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:05
-- Luau version 6, Types version 3
-- Time taken: 0.041187 seconds

local module_upvr = {
	Cooldown = 15;
	GlobalCD = 0.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 19
	--[[ Upvalues[5]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Pinpoint_Shuriken_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"].Ultimate["Pinpoint Shuriken"]
	local function _(arg1_2, arg2_2, arg3) -- Line 33, Named "Siphon"
		--[[ Upvalues[7]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: TweenService_upvr (copied, readonly)
			[5]: Humanoid_upvr (readonly)
			[6]: var2_upvw (copied, read and write)
			[7]: arg1 (readonly)
		]]
		task.spawn(function() -- Line 34
			--[[ Upvalues[10]:
				[1]: arg2_2 (readonly)
				[2]: ReplicatedStorage_upvr (copied, readonly)
				[3]: Folder_upvr (copied, readonly)
				[4]: arg1_2 (readonly)
				[5]: HumanoidRootPart_upvr (copied, readonly)
				[6]: TweenService_upvr (copied, readonly)
				[7]: Humanoid_upvr (copied, readonly)
				[8]: arg3 (readonly)
				[9]: var2_upvw (copied, read and write)
				[10]: arg1 (copied, readonly)
			]]
			for _ = 1, arg2_2 do
				local clone_3_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"].Ultimate.SiphonBall:Clone()
				clone_3_upvr.Parent = Folder_upvr
				clone_3_upvr.CFrame = arg1_2
				clone_3_upvr.CFrame = CFrame.lookAt(clone_3_upvr.Position, HumanoidRootPart_upvr.Position)
				game.Debris:AddItem(clone_3_upvr, 10)
				TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Position = clone_3_upvr.Position:Lerp(HumanoidRootPart_upvr.Position, 0.5) + (clone_3_upvr.CFrame.RightVector) * (math.random(-4, 4) * 1.5) + (clone_3_upvr.CFrame.UpVector) * (math.random(-4, 4) * 1.5);
				}):Play()
				local Appear_2 = clone_3_upvr.Appear
				Appear_2.PlaybackSpeed += math.random(-3, 3) * 0.06
				clone_3_upvr.Appear:Play()
				task.delay(0.3, function() -- Line 48
					--[[ Upvalues[7]:
						[1]: TweenService_upvr (copied, readonly)
						[2]: clone_3_upvr (readonly)
						[3]: HumanoidRootPart_upvr (copied, readonly)
						[4]: Humanoid_upvr (copied, readonly)
						[5]: arg3 (copied, readonly)
						[6]: var2_upvw (copied, read and write)
						[7]: arg1 (copied, readonly)
					]]
					TweenService_upvr:Create(clone_3_upvr, TweenInfo.new((clone_3_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.03, Enum.EasingStyle.Linear), {
						Position = HumanoidRootPart_upvr.Position;
					}):Play()
					task.wait(0.1)
					while task.wait() and clone_3_upvr.Parent and clone_3_upvr.Transparency ~= 1 do
						TweenService_upvr:Create(clone_3_upvr, TweenInfo.new((clone_3_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.01, Enum.EasingStyle.Linear), {
							Position = HumanoidRootPart_upvr.Position;
						}):Play()
						if (clone_3_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude <= 2 then
							TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(0, Enum.EasingStyle.Linear), {
								Position = HumanoidRootPart_upvr.Position;
							}):Play()
							task.wait()
							clone_3_upvr.Position = HumanoidRootPart_upvr.Position
							local HealSFX_2 = clone_3_upvr.HealSFX
							HealSFX_2.PlaybackSpeed += math.random(-1, 1) * 0.1
							clone_3_upvr.HealSFX:Play()
							local var20 = Humanoid_upvr
							var20.Health += arg3
							clone_3_upvr.Transparency = 1
							clone_3_upvr.Trail.Enabled = false
							var2_upvw.camShake(arg1, "SmallBump")
							var2_upvw.changeFov(arg1, 65, 0.05, 0.6)
							var2_upvw.flashScreen(arg1, Color3.new(1, 0.32549, 0.32549), 0.1)
						end
					end
				end)
				task.wait(0.05)
			end
		end)
	end
	local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Pinpoint_Shuriken_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("pause"):Connect(function() -- Line 84
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:AdjustSpeed(0)
	end)
	local CyberKatana_upvr = arg1:FindFirstChild("CyberKatana")
	local function _(arg1_3) -- Line 88, Named "ToggleTrails"
		--[[ Upvalues[1]:
			[1]: CyberKatana_upvr (readonly)
		]]
		for _, v in CyberKatana_upvr:GetDescendants() do
			if v:IsA("Trail") and v.Name == "Trail" then
				v.Enabled = arg1_3
			end
		end
	end
	local function tweenRotation_upvr(arg1_4) -- Line 97, Named "tweenRotation"
		--[[ Upvalues[1]:
			[1]: TweenService_upvr (copied, readonly)
		]]
		TweenService_upvr:Create(arg1_4, TweenInfo.new(0.14, Enum.EasingStyle.Linear), {
			Position = arg1_4.Position + arg1_4.CFrame.LookVector * 12;
		}):Play()
	end
	var2_upvw.camShake(arg1, "SmallBump")
	var2_upvw.changeFov(arg1, 100, 0.5, 5)
	local clone_7 = Pinpoint_Shuriken_upvr.Dash:Clone()
	clone_7.Parent = HumanoidRootPart_upvr
	clone_7:Play()
	var2_upvw.applyDebris(clone_7, 3)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.1)
	var2_upvw.applyStatus(arg1, "Freeze", 1.1)
	var2_upvw.applyStatus(arg1, "IFrames", 1.1)
	local var32_upvw
	var32_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_5, arg2_3, arg3) -- Line 114
		--[[ Upvalues[13]:
			[1]: arg2 (readonly)
			[2]: var32_upvw (read and write)
			[3]: any_LoadAnimation_result1_upvr (readonly)
			[4]: Humanoid_upvr (readonly)
			[5]: Pinpoint_Shuriken_upvr (readonly)
			[6]: var2_upvw (copied, read and write)
			[7]: arg1 (readonly)
			[8]: HumanoidRootPart_upvr (readonly)
			[9]: Folder_upvr (readonly)
			[10]: RunService_upvr (copied, readonly)
			[11]: TweenService_upvr (copied, readonly)
			[12]: tweenRotation_upvr (readonly)
			[13]: ReplicatedStorage_upvr (copied, readonly)
		]]
		if arg2_3 ~= "PinpointShuriken" or arg1_5 ~= arg2 then
		else
			var32_upvw:Disconnect()
			any_LoadAnimation_result1_upvr:Stop()
			if #arg3.enemiesDetected <= 0 then return end
			Humanoid_upvr.Animator:LoadAnimation(Pinpoint_Shuriken_upvr.Animation2):Play()
			var2_upvw.applyStatus(arg1, "Slowed", 0.75)
			var2_upvw.camShake(arg1, "Bump")
			var2_upvw.changeFov(arg1, 50, 0.01, 2)
			var2_upvw.flashScreen(arg1, Color3.new(1, 0.270588, 0.270588), 1)
			var2_upvw.Blur(arg1, 25, 0.5)
			local clone_8 = Pinpoint_Shuriken_upvr.GunShot:Clone()
			clone_8.Parent = HumanoidRootPart_upvr
			clone_8:Play()
			var2_upvw.applyDebris(clone_8, 5)
			local clone = Pinpoint_Shuriken_upvr.GunShot2:Clone()
			clone.Parent = HumanoidRootPart_upvr
			clone:Play()
			var2_upvw.applyDebris(clone, 5)
			for _, v_2_upvr in arg3.enemiesDetected do
				local var41 = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 40
				local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 40, Vector3.new(0, -100000, 0), var2_upvw.raycastParams)
				if workspace_Raycast_result1 then
					var41 = workspace_Raycast_result1.Position
				end
				if (var41 - v_2_upvr.HumanoidRootPart.Position).Magnitude <= 500 then
					for _ = 1, 3 do
						local clone_4_upvr = Pinpoint_Shuriken_upvr.Shuriken:Clone()
						clone_4_upvr.Parent = Folder_upvr
						clone_4_upvr.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 5) * CFrame.Angles(0, math.rad(math.random(-75, 75)), math.rad(math.random(-75, 0)))
						var2_upvw.applyDebris(clone_4_upvr, 12)
						clone_4_upvr.Flying:Play()
						local Flying = clone_4_upvr.Flying
						Flying.PlaybackSpeed += math.random(-3, 3) * 0.05
						local var45_upvw = "Slow"
						task.delay(0.25, function() -- Line 158
							--[[ Upvalues[1]:
								[1]: var45_upvw (read and write)
							]]
							var45_upvw = "Fast"
						end)
						local var48_upvw
						var48_upvw = RunService_upvr.Stepped:Connect(function() -- Line 163
							--[[ Upvalues[13]:
								[1]: clone_4_upvr (readonly)
								[2]: v_2_upvr (readonly)
								[3]: var48_upvw (read and write)
								[4]: var45_upvw (read and write)
								[5]: TweenService_upvr (copied, readonly)
								[6]: tweenRotation_upvr (copied, readonly)
								[7]: var2_upvw (copied, read and write)
								[8]: Pinpoint_Shuriken_upvr (copied, readonly)
								[9]: ReplicatedStorage_upvr (copied, readonly)
								[10]: Folder_upvr (copied, readonly)
								[11]: HumanoidRootPart_upvr (copied, readonly)
								[12]: Humanoid_upvr (copied, readonly)
								[13]: arg1 (copied, readonly)
							]]
							-- KONSTANTERROR: [0] 1. Error Block 67 start (CF ANALYSIS FAILED)
							if not clone_4_upvr.Parent or not v_2_upvr.Parent then
								var48_upvw:Disconnect()
							else
								if not v_2_upvr.Parent then
									clone_4_upvr:Destroy()
									var48_upvw:Disconnect()
									return
								end
								if var45_upvw == "Slow" then
									TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(4), {
										CFrame = CFrame.lookAt(clone_4_upvr.Position, v_2_upvr.HumanoidRootPart.Position);
									}):Play()
									-- KONSTANTWARNING: GOTO [115] #83
								end
								-- KONSTANTERROR: [0] 1. Error Block 67 end (CF ANALYSIS FAILED)
								-- KONSTANTERROR: [56] 42. Error Block 68 start (CF ANALYSIS FAILED)
								if var45_upvw == "Fast" then
									TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(0.3), {
										CFrame = CFrame.lookAt(clone_4_upvr.Position, v_2_upvr.HumanoidRootPart.Position);
									}):Play()
								elseif var45_upvw == "Really Fast" then
									TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(0.15), {
										CFrame = CFrame.lookAt(clone_4_upvr.Position, v_2_upvr.HumanoidRootPart.Position);
									}):Play()
								end
								local Magnitude = (clone_4_upvr.Position - v_2_upvr.HumanoidRootPart.Position).Magnitude
								if Magnitude <= 10 then
									var45_upvw = "Really Fast"
								end
								tweenRotation_upvr(clone_4_upvr)
								for _, v_3 in clone_4_upvr:GetDescendants() do
									if v_3:IsA("BasePart") then
										tweenRotation_upvr(clone_4_upvr)
									end
								end
								if Magnitude <= 2.5 then
									var48_upvw:Disconnect()
									clone_4_upvr.Transparency = 1
									clone_4_upvr.Flying:Stop()
									for _, v_4 in clone_4_upvr:GetDescendants() do
										if v_4:IsA("ParticleEmitter") or v_4:IsA("Trail") then
											v_4.Enabled = false
										end
									end
									clone_4_upvr.Transparency = 1
									for i_7_upvr, v_5 in clone_4_upvr:GetChildren() do
										if v_5:IsA("BasePart") then
											v_5.Transparency = 1
										end
									end
									if not var2_upvw.CheckBlock(v_2_upvr) then
										local clone_6 = Pinpoint_Shuriken_upvr.BulletHit:Clone()
										i_7_upvr = v_2_upvr
										clone_6.Parent = i_7_upvr.HumanoidRootPart
										v_5 = math.random(-2, 2)
										i_7_upvr = v_5 * 0.06
										clone_6.PlaybackSpeed += i_7_upvr
										clone_6:Play()
										i_7_upvr = var2_upvw
										i_7_upvr = clone_6
										v_5 = 5
										i_7_upvr.applyDebris(i_7_upvr, v_5)
										v_5 = Pinpoint_Shuriken_upvr
										i_7_upvr = v_5.HitVFX
										local clone_5 = i_7_upvr.Att:Clone()
										v_5 = v_2_upvr
										i_7_upvr = v_5.Torso
										clone_5.Parent = i_7_upvr
										v_5 = var2_upvw
										i_7_upvr = v_5.EmitAllDescendants
										v_5 = clone_5
										i_7_upvr(v_5)
										v_5 = var2_upvw
										i_7_upvr = v_5.applyDebris
										v_5 = clone_5
										i_7_upvr(v_5, 3)
										i_7_upvr = v_2_upvr:FindFirstChild("CyberCube")
										if not i_7_upvr then
											v_5 = Pinpoint_Shuriken_upvr
											i_7_upvr = v_5.CyberCube:Clone()
											v_5 = v_2_upvr
											i_7_upvr.Parent = v_5
											v_5 = i_7_upvr.weld
											v_5.Part0 = v_2_upvr.HumanoidRootPart
											v_5 = i_7_upvr.weld
											v_5.Part1 = i_7_upvr
											v_5 = i_7_upvr.CyberCubeSFX:Play
											v_5()
											v_5 = var2_upvw.applyStatus(v_2_upvr, "Stunned", 3)
											var2_upvw.applyStatus(v_2_upvr, "AutoRotate", 3)
											task.delay(3, function() -- Line 236
												--[[ Upvalues[3]:
													[1]: var2_upvw (copied, read and write)
													[2]: i_7_upvr (readonly)
													[3]: TweenService_upvr (copied, readonly)
												]]
												var2_upvw.applyDebris(i_7_upvr, 1)
												TweenService_upvr:Create(i_7_upvr, TweenInfo.new(0.25), {
													Size = i_7_upvr.Size * Vector3.new(0.10000, 0.10000, 0.10000);
												}):Play()
												for _, v_6 in i_7_upvr:GetChildren() do
													if v_6:IsA("BasePart") then
														TweenService_upvr:Create(v_6, TweenInfo.new(0.25), {
															Size = i_7_upvr.Size * Vector3.new(0.10000, 0.10000, 0.10000);
														}):Play()
													elseif v_6:IsA("ParticleEmitter") or v_6:IsA("PointLight") then
														v_6.Enabled = false
													end
												end
											end)
										end
										v_5 = var2_upvw
										i_7_upvr = v_5.camShake
										v_5 = v_2_upvr
										i_7_upvr(v_5, "SmallBump")
										v_5 = var2_upvw
										i_7_upvr = v_5.changeFov
										v_5 = v_2_upvr
										i_7_upvr(v_5, 60, 0.01, 1)
										v_5 = var2_upvw
										i_7_upvr = v_5.flashScreen
										v_5 = v_2_upvr
										i_7_upvr(v_5, Color3.new(1, 0.270588, 0.270588), 0.4)
										v_5 = var2_upvw
										i_7_upvr = v_5.Blur
										v_5 = v_2_upvr
										i_7_upvr(v_5, 25, 0.5)
										v_5 = var2_upvw
										i_7_upvr = v_5.applyDamage
										v_5 = v_2_upvr
										i_7_upvr(v_5, 7)
										v_5 = v_2_upvr.Torso
										i_7_upvr = v_5.CFrame
										v_5 = task.spawn
										local const_number_upvr = 1
										local var80_upvr = 2
										v_5(function() -- Line 34
											--[[ Upvalues[10]:
												[1]: const_number_upvr (readonly)
												[2]: ReplicatedStorage_upvr (copied, readonly)
												[3]: Folder_upvr (copied, readonly)
												[4]: i_7_upvr (readonly)
												[5]: HumanoidRootPart_upvr (copied, readonly)
												[6]: TweenService_upvr (copied, readonly)
												[7]: Humanoid_upvr (copied, readonly)
												[8]: var80_upvr (readonly)
												[9]: var2_upvw (copied, read and write)
												[10]: arg1 (copied, readonly)
											]]
											for _ = 1, const_number_upvr do
												local clone_2_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"].Ultimate.SiphonBall:Clone()
												clone_2_upvr.Parent = Folder_upvr
												clone_2_upvr.CFrame = i_7_upvr
												clone_2_upvr.CFrame = CFrame.lookAt(clone_2_upvr.Position, HumanoidRootPart_upvr.Position)
												game.Debris:AddItem(clone_2_upvr, 10)
												TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
													Position = clone_2_upvr.Position:Lerp(HumanoidRootPart_upvr.Position, 0.5) + (clone_2_upvr.CFrame.RightVector) * (math.random(-4, 4) * 1.5) + (clone_2_upvr.CFrame.UpVector) * (math.random(-4, 4) * 1.5);
												}):Play()
												local Appear = clone_2_upvr.Appear
												Appear.PlaybackSpeed += math.random(-3, 3) * 0.06
												clone_2_upvr.Appear:Play()
												task.delay(0.3, function() -- Line 48
													--[[ Upvalues[7]:
														[1]: TweenService_upvr (copied, readonly)
														[2]: clone_2_upvr (readonly)
														[3]: HumanoidRootPart_upvr (copied, readonly)
														[4]: Humanoid_upvr (copied, readonly)
														[5]: var80_upvr (copied, readonly)
														[6]: var2_upvw (copied, read and write)
														[7]: arg1 (copied, readonly)
													]]
													TweenService_upvr:Create(clone_2_upvr, TweenInfo.new((clone_2_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.03, Enum.EasingStyle.Linear), {
														Position = HumanoidRootPart_upvr.Position;
													}):Play()
													task.wait(0.1)
													while task.wait() and clone_2_upvr.Parent and clone_2_upvr.Transparency ~= 1 do
														TweenService_upvr:Create(clone_2_upvr, TweenInfo.new((clone_2_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.01, Enum.EasingStyle.Linear), {
															Position = HumanoidRootPart_upvr.Position;
														}):Play()
														if (clone_2_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude <= 2 then
															TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0, Enum.EasingStyle.Linear), {
																Position = HumanoidRootPart_upvr.Position;
															}):Play()
															task.wait()
															clone_2_upvr.Position = HumanoidRootPart_upvr.Position
															local HealSFX = clone_2_upvr.HealSFX
															HealSFX.PlaybackSpeed += math.random(-1, 1) * 0.1
															clone_2_upvr.HealSFX:Play()
															local var90 = Humanoid_upvr
															var90.Health += var80_upvr
															clone_2_upvr.Transparency = 1
															clone_2_upvr.Trail.Enabled = false
															var2_upvw.camShake(arg1, "SmallBump")
															var2_upvw.changeFov(arg1, 65, 0.05, 0.6)
															var2_upvw.flashScreen(arg1, Color3.new(1, 0.32549, 0.32549), 0.1)
														end
													end
												end)
												task.wait(0.05)
											end
										end)
									end
								end
								-- KONSTANTERROR: [56] 42. Error Block 68 end (CF ANALYSIS FAILED)
							end
						end)
					end
				end
			end
		end
	end)
	task.delay(4, function() -- Line 267
		--[[ Upvalues[1]:
			[1]: var32_upvw (read and write)
		]]
		if not var32_upvw then
		else
			var32_upvw:Disconnect()
		end
	end)
end
return module_upvr
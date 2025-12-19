-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:48
-- Luau version 6, Types version 3
-- Time taken: 0.043195 seconds

local module_upvr = {
	Cooldown = 14;
	GlobalCD = 1.3;
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
	local Rapid_Ice_upvr = ReplicatedStorage_upvr.Skills["Snow Blasters"]["Rapid Ice"]
	local Snow_Blasters_upvr = arg1:FindFirstChild("Snow Blasters")
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Rapid_Ice_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(0.7)
	local function ToggleTrails_upvr(arg1_2) -- Line 34, Named "ToggleTrails"
		--[[ Upvalues[1]:
			[1]: Snow_Blasters_upvr (readonly)
		]]
		for _, v in Snow_Blasters_upvr:GetDescendants() do
			if v:IsA("Trail") and v.Name == "Trail" then
				v.Enabled = arg1_2
			end
		end
	end
	ToggleTrails_upvr(true)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 43
		--[[ Upvalues[2]:
			[1]: Snow_Blasters_upvr (readonly)
			[2]: ToggleTrails_upvr (readonly)
		]]
		for _, v_2 in Snow_Blasters_upvr.RightBlaster.SnowCharge:GetChildren() do
			v_2.Enabled = false
		end
		ToggleTrails_upvr(false)
	end), module_upvr.Cooldown)
	local clone_2 = Rapid_Ice_upvr.Dash:Clone()
	clone_2.Parent = HumanoidRootPart_upvr
	clone_2:Play()
	var2_upvw.applyDebris(clone_2, 3)
	local var24_upvw
	var24_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2, arg3) -- Line 56
		--[[ Upvalues[12]:
			[1]: arg2 (readonly)
			[2]: var24_upvw (read and write)
			[3]: any_LoadAnimation_result1_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: var2_upvw (copied, read and write)
			[6]: arg1 (readonly)
			[7]: Rapid_Ice_upvr (readonly)
			[8]: Folder_upvr (readonly)
			[9]: RunService_upvr (copied, readonly)
			[10]: TweenService_upvr (copied, readonly)
			[11]: ReplicatedStorage_upvr (copied, readonly)
			[12]: module_upvr (copied, readonly)
		]]
		-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
		if arg2_2 ~= "RapidIce" or arg1_3 ~= arg2 then
		else
			var24_upvw:Disconnect()
			if #arg3.enemiesDetected <= 0 then
				any_LoadAnimation_result1_upvr:Stop()
			end
			for _, v_3_upvr in arg3.enemiesDetected do
				local var37 = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 40
				local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 40, Vector3.new(0, -100000, 0), var2_upvw.raycastParams)
				if workspace_Raycast_result1 then
					var37 = workspace_Raycast_result1.Position
				end
				if (var37 - v_3_upvr.HumanoidRootPart.Position).Magnitude <= 25 then
					var2_upvw.applyStatus(arg1, "Slowed", #arg3.enemiesDetected * 0.18 + 0.1)
					for _ = 1, 4 do
						any_LoadAnimation_result1_upvr.TimePosition = 0.65
						var2_upvw.camShake(arg1, "SmallBump")
						local clone_4 = Rapid_Ice_upvr.GunShot:Clone()
						clone_4.Parent = HumanoidRootPart_upvr
						clone_4.PlaybackSpeed += math.random(-2, 2) * 0.06
						clone_4:Play()
						var2_upvw.applyDebris(clone_4, 5)
						local clone_3 = Rapid_Ice_upvr.GunShot2:Clone()
						clone_3.Parent = HumanoidRootPart_upvr
						clone_3.PlaybackSpeed += math.random(-2, 2) * 0.06
						clone_3:Play()
						var2_upvw.applyDebris(clone_3, 5)
						local clone_5_upvr = Rapid_Ice_upvr.IceBullet:Clone()
						clone_5_upvr.Parent = Folder_upvr
						clone_5_upvr.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 5) * CFrame.Angles(0, math.rad(math.random(-75, 75)), math.rad(math.random(-75, 0)))
						var2_upvw.applyDebris(clone_5_upvr, 12)
						clone_5_upvr.Flying:Play()
						local Flying = clone_5_upvr.Flying
						Flying.PlaybackSpeed += math.random(-2, 2) * 0.05
						local var43_upvw = "Slow"
						task.delay(0.4, function() -- Line 97
							--[[ Upvalues[1]:
								[1]: var43_upvw (read and write)
							]]
							var43_upvw = "Fast"
						end)
						local var46_upvw
						local var47_upvw = 0
						var46_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 102
							--[[ Upvalues[9]:
								[1]: clone_5_upvr (readonly)
								[2]: v_3_upvr (readonly)
								[3]: var46_upvw (read and write)
								[4]: var43_upvw (read and write)
								[5]: TweenService_upvr (copied, readonly)
								[6]: var2_upvw (copied, read and write)
								[7]: var47_upvw (read and write)
								[8]: Rapid_Ice_upvr (copied, readonly)
								[9]: ReplicatedStorage_upvr (copied, readonly)
							]]
							-- KONSTANTERROR: [0] 1. Error Block 57 start (CF ANALYSIS FAILED)
							if not clone_5_upvr.Parent or not v_3_upvr.Parent then
								var46_upvw:Disconnect()
							else
								if not v_3_upvr.Parent then
									clone_5_upvr:Destroy()
									var46_upvw:Disconnect()
									return
								end
								if var43_upvw == "Slow" then
									TweenService_upvr:Create(clone_5_upvr, TweenInfo.new(0.8), {
										CFrame = CFrame.lookAt(clone_5_upvr.Position, v_3_upvr.HumanoidRootPart.Position);
									}):Play()
									-- KONSTANTWARNING: GOTO [115] #83
								end
								-- KONSTANTERROR: [0] 1. Error Block 57 end (CF ANALYSIS FAILED)
								-- KONSTANTERROR: [56] 42. Error Block 58 start (CF ANALYSIS FAILED)
								if var43_upvw == "Fast" then
									TweenService_upvr:Create(clone_5_upvr, TweenInfo.new(0.2), {
										CFrame = CFrame.lookAt(clone_5_upvr.Position, v_3_upvr.HumanoidRootPart.Position);
									}):Play()
								elseif var43_upvw == "Really Fast" then
									TweenService_upvr:Create(clone_5_upvr, TweenInfo.new(0.05), {
										CFrame = CFrame.lookAt(clone_5_upvr.Position, v_3_upvr.HumanoidRootPart.Position);
									}):Play()
								end
								local Magnitude = (clone_5_upvr.Position - v_3_upvr.HumanoidRootPart.Position).Magnitude
								if Magnitude <= 9 then
									var43_upvw = "Really Fast"
								end
								TweenService_upvr:Create(clone_5_upvr, TweenInfo.new(0.12, Enum.EasingStyle.Linear), {
									Position = clone_5_upvr.Position + clone_5_upvr.CFrame.LookVector * 13;
								}):Play()
								clone_5_upvr.BulletModel.CFrame = clone_5_upvr.CFrame * CFrame.Angles(0, (-math.pi/2), (math.pi/2))
								if Magnitude <= 2.5 then
									var46_upvw:Disconnect()
									clone_5_upvr.Transparency = 1
									clone_5_upvr.BulletModel.Transparency = 1
									clone_5_upvr.Flying:Stop()
									for i_5, v_4 in clone_5_upvr:GetDescendants() do
										if v_4:IsA("ParticleEmitter") or v_4:IsA("Trail") then
											v_4.Enabled = false
										end
									end
									if not var2_upvw.CheckBlock(v_3_upvr) then
										var47_upvw += 1
										local clone = Rapid_Ice_upvr.BulletHit:Clone()
										i_5 = v_3_upvr
										clone.Parent = i_5.HumanoidRootPart
										v_4 = math.random(-2, 2)
										i_5 = v_4 * 0.06
										clone.PlaybackSpeed += i_5
										clone:Play()
										i_5 = var2_upvw
										i_5 = clone
										v_4 = 5
										i_5.applyDebris(i_5, v_4)
										i_5 = var2_upvw
										v_4 = Rapid_Ice_upvr
										i_5 = v_4.Ping
										v_4 = v_3_upvr.HumanoidRootPart
										v_4 = var47_upvw * 0.1
										i_5 = v_4 + 1.5
										i_5.applySound(i_5, v_4, 3).PlaybackSpeed = i_5
										v_4 = var2_upvw
										i_5 = v_4.applySound
										v_4 = Rapid_Ice_upvr.BulletHit2
										i_5 = i_5(v_4, v_3_upvr.HumanoidRootPart, 3)
										v_4 = var47_upvw * 0.05 + 1.6
										i_5.PlaybackSpeed = v_4
										v_4 = var2_upvw.applyDamage
										v_4(v_3_upvr, 3)
										v_4 = var2_upvw.applyStatus
										v_4(v_3_upvr, "Stunned", 0.6)
										v_4 = var2_upvw.applyStatus
										v_4(v_3_upvr, "Slowed", 0.8)
									end
									if 4 <= var47_upvw then
										v_4 = ReplicatedStorage_upvr.Modules
										i_5 = v_4.PlayerStatus
										i_5 = "IFrames"
										if require(i_5).FindStatus(v_3_upvr, i_5) then return end
										var2_upvw.unragdoll(v_3_upvr)
										local clone_6_upvr = Rapid_Ice_upvr.IceCage:Clone()
										clone_6_upvr.Parent = v_3_upvr
										v_4 = v_3_upvr
										i_5 = v_4.HumanoidRootPart
										clone_6_upvr.weld.Part0 = i_5
										clone_6_upvr.weld.Part1 = clone_6_upvr
										i_5 = game
										v_4 = clone_6_upvr
										i_5.Debris:AddItem(v_4, 2)
										clone_6_upvr["ice explosion"]:Play()
										i_5 = v_3_upvr
										local any_GetPlayingAnimationTracks_result1, any_GetPlayingAnimationTracks_result2, any_GetPlayingAnimationTracks_result3 = i_5.Humanoid:GetPlayingAnimationTracks()
										for _, v_5 in any_GetPlayingAnimationTracks_result1, any_GetPlayingAnimationTracks_result2, any_GetPlayingAnimationTracks_result3 do
											v_5:AdjustSpeed(0)
										end
										any_GetPlayingAnimationTracks_result2 = var2_upvw
										any_GetPlayingAnimationTracks_result2 = v_3_upvr
										any_GetPlayingAnimationTracks_result3 = 3
										any_GetPlayingAnimationTracks_result2.applyDamage(any_GetPlayingAnimationTracks_result2, any_GetPlayingAnimationTracks_result3)
										any_GetPlayingAnimationTracks_result2 = var2_upvw
										any_GetPlayingAnimationTracks_result2 = v_3_upvr
										any_GetPlayingAnimationTracks_result3 = "AutoRotate"
										any_GetPlayingAnimationTracks_result2.applyStatus(any_GetPlayingAnimationTracks_result2, any_GetPlayingAnimationTracks_result3, 2)
										any_GetPlayingAnimationTracks_result2 = var2_upvw
										any_GetPlayingAnimationTracks_result2 = v_3_upvr
										any_GetPlayingAnimationTracks_result3 = "Stunned"
										any_GetPlayingAnimationTracks_result2.applyStatus(any_GetPlayingAnimationTracks_result2, any_GetPlayingAnimationTracks_result3, 2)
										any_GetPlayingAnimationTracks_result2 = 1.5
										function any_GetPlayingAnimationTracks_result3() -- Line 178
											--[[ Upvalues[2]:
												[1]: TweenService_upvr (copied, readonly)
												[2]: clone_6_upvr (readonly)
											]]
											TweenService_upvr:Create(clone_6_upvr, TweenInfo.new(0.5), {
												Transparency = 1;
											}):Play()
										end
										task.delay(any_GetPlayingAnimationTracks_result2, any_GetPlayingAnimationTracks_result3)
									end
								end
								-- KONSTANTERROR: [56] 42. Error Block 58 end (CF ANALYSIS FAILED)
							end
						end), module_upvr.Cooldown)
						task.wait(0.03)
						local _
					end
				end
			end
		end
	end), module_upvr.Cooldown)
	task.delay(4, function() -- Line 193
		--[[ Upvalues[1]:
			[1]: var24_upvw (read and write)
		]]
		if not var24_upvw then
		else
			var24_upvw:Disconnect()
		end
	end)
end
return module_upvr
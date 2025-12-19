-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:00
-- Luau version 6, Types version 3
-- Time taken: 0.011141 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 27
module_upvr.GlobalCD = 1.2
local var3_upvw
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 18
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: PlayerStatus_upvr (readonly)
		[5]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Rapid_Jabs_upvr = ReplicatedStorage_upvr.Skills["Fire Fists"]["Rapid Jabs"]
	local any_LoadAnimation_result1_2_upvr = Humanoid_upvr.Animator:LoadAnimation(Rapid_Jabs_upvr.Animation)
	any_LoadAnimation_result1_2_upvr:Play()
	any_LoadAnimation_result1_2_upvr:AdjustSpeed(0.6)
	var3_upvw.applyStatus(arg1, "Freeze", 1.2)
	var3_upvw.changeFov(arg1, 100, 0.3, 5)
	local clone_7 = Rapid_Jabs_upvr.Dash:Clone()
	clone_7.Parent = HumanoidRootPart_upvr
	clone_7:Play()
	var3_upvw.applyDebris(clone_7, 5)
	local clone_2 = Rapid_Jabs_upvr.Dash2:Clone()
	clone_2.Parent = HumanoidRootPart_upvr
	clone_2:Play()
	var3_upvw.applyDebris(clone_2, 5)
	var3_upvw.camShake(arg1, "Bump")
	var3_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 5, 0.8, 0.4, 0.03)
	local var14_upvw
	local var15_upvw = 0
	var14_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 59
		--[[ Upvalues[14]:
			[1]: arg2 (readonly)
			[2]: var14_upvw (read and write)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: any_LoadAnimation_result1_2_upvr (readonly)
			[5]: var3_upvw (copied, read and write)
			[6]: arg1 (readonly)
			[7]: Rapid_Jabs_upvr (readonly)
			[8]: Folder_upvr (readonly)
			[9]: ReplicatedStorage_upvr (copied, readonly)
			[10]: PlayerStatus_upvr (copied, readonly)
			[11]: Humanoid_upvr (readonly)
			[12]: var15_upvw (read and write)
			[13]: TweenService_upvr (copied, readonly)
			[14]: module_upvr (copied, readonly)
		]]
		if arg2_2 ~= "RapidJab" or arg1_2 ~= arg2 or not var14_upvw then
		else
			var14_upvw:Disconnect()
			if arg3 then
				HumanoidRootPart_upvr.CFrame = arg3
			end
			any_LoadAnimation_result1_2_upvr:Stop()
			var3_upvw.applyStatus(arg1, "IFrames", 0.1)
			var3_upvw.applyStatus(arg1, "GlobalCD", 0.1)
			local clone_3 = Rapid_Jabs_upvr.Hitbox:Clone()
			clone_3.Parent = Folder_upvr
			clone_3.weld.Part1 = clone_3
			clone_3.weld.Part0 = HumanoidRootPart_upvr
			var3_upvw.applyDebris(clone_3, 1)
			clone_3.Transparency = 1
			for _, v_upvr in var3_upvw.findEnemiesPart(clone_3), nil do
				if not var3_upvw.CheckBlock(v_upvr) then
					for _, v_2 in require(ReplicatedStorage_upvr.Modules.PlayerStatus).FindTable(v_upvr), nil do
						if v_2 == "HyperArmor" then
							PlayerStatus_upvr.RemoveStatus(arg1, v_2)
						end
					end
					for _, v_3 in v_upvr.Humanoid:GetPlayingAnimationTracks() do
						v_3:Stop()
					end
					var3_upvw.applyStatus(arg1, "IFrames", 1.2)
					var3_upvw.applyStatus(arg1, "Freeze", 1.2)
					var3_upvw.applyStatus(arg1, "GlobalCD", 1.2)
					var3_upvw.applyStatus(v_upvr, "Stunned", 1.2)
					var3_upvw.applyStatus(v_upvr, "AutoRotate", 1.2)
					var3_upvw.applyStatus(v_upvr, "IFrames", 1.2)
					var3_upvw.SetRootPriority(arg1, 100, 3.2)
					local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Rapid_Jabs_upvr.Animation)
					any_LoadAnimation_result1:Play()
					any_LoadAnimation_result1:AdjustSpeed(1)
					any_LoadAnimation_result1.TimePosition = 0.167
					local clone = Rapid_Jabs_upvr.Whoosh:Clone()
					clone.Parent = HumanoidRootPart_upvr
					clone:Play()
					clone.TimePosition = 0.5
					var3_upvw.applyDebris(clone, 5)
					clone.Volume = 0.75
					local any_applyWeld_result1_upvw = var3_upvw.applyWeld(v_upvr, Vector3.new(0, 0, 4), Vector3.new(0, 180, 0), 3.5)
					var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("punch"):Connect(function() -- Line 126
						--[[ Upvalues[9]:
							[1]: var15_upvw (copied, read and write)
							[2]: var3_upvw (copied, read and write)
							[3]: arg1 (copied, readonly)
							[4]: v_upvr (readonly)
							[5]: any_applyWeld_result1_upvw (read and write)
							[6]: HumanoidRootPart_upvr (copied, readonly)
							[7]: Rapid_Jabs_upvr (copied, readonly)
							[8]: Folder_upvr (copied, readonly)
							[9]: TweenService_upvr (copied, readonly)
						]]
						var15_upvw += 1
						var3_upvw.camShake(arg1, "Bump")
						var3_upvw.flashScreen(arg1, Color3.new(1, 0.615686, 0.423529), 0.6)
						var3_upvw.changeFov(arg1, 62, 0.01, 0.2)
						var3_upvw.camShake(v_upvr, "Bump")
						var3_upvw.changeFov(v_upvr, 62, 0.01, 0.2)
						var3_upvw.flashScreen(v_upvr, Color3.new(1, 0.615686, 0.423529), 0.6)
						if var15_upvw == 2 then
							any_applyWeld_result1_upvw:Destroy()
							any_applyWeld_result1_upvw = var3_upvw.applyWeld(v_upvr, Vector3.new(0, 0, 4), Vector3.new(0, 180, 0), 3)
						end
						var3_upvw.Knockback(arg1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -100, 25)
						local clone_5 = Rapid_Jabs_upvr.FlameM1:Clone()
						clone_5.Parent = v_upvr.HumanoidRootPart
						clone_5:Play()
						clone_5.PlaybackSpeed += math.random(-1, 1) * 0.08
						var3_upvw.applyDebris(clone_5, 2)
						local clone_6 = Rapid_Jabs_upvr["FlameM1(2)"]:Clone()
						clone_6.Parent = v_upvr.HumanoidRootPart
						clone_6:Play()
						var3_upvw.applyDebris(clone_6, 1.5)
						local clone_8 = Rapid_Jabs_upvr.VFX.hitVFX:Clone()
						clone_8.Parent = v_upvr.HumanoidRootPart
						var3_upvw.EmitAllDescendants(clone_8)
						var3_upvw.applyDebris(clone_8, 2)
						local clone_upvr = Rapid_Jabs_upvr.FireFist:Clone()
						clone_upvr.Parent = Folder_upvr
						clone_upvr.Size = Vector3.new(1, 3, 1)
						clone_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.RightVector * math.random(-3, 3) + HumanoidRootPart_upvr.CFrame.UpVector * math.random(-3, 3)
						var3_upvw.applyDebris(clone_upvr, 0.36)
						TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.35), {
							CFrame = clone_upvr.CFrame + clone_upvr.CFrame.LookVector * 30;
							Size = Vector3.new(1.5, 1.5, 25);
						}):Play()
						TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
							Transparency = 1;
						}):Play()
						task.delay(0.35, function() -- Line 170
							--[[ Upvalues[1]:
								[1]: clone_upvr (readonly)
							]]
							for _, v_4 in clone_upvr:GetDescendants() do
								if v_4:IsA("ParticleEmitter") then
									v_4.Enabled = false
								end
							end
						end)
						if var15_upvw == 10 then
							if v_upvr.Humanoid.Health - 1 <= 0 then
								any_applyWeld_result1_upvw:Destroy()
								task.wait()
								var3_upvw.applyDamage(v_upvr, 1, true)
							else
								var3_upvw.applyDamage(v_upvr, 1, true, true)
								game.Debris:AddItem(any_applyWeld_result1_upvw, 0.45)
								var3_upvw.resetm1s()
							end
						end
						local clone_4 = Rapid_Jabs_upvr.Whoosh:Clone()
						clone_4.Parent = HumanoidRootPart_upvr
						clone_4:Play()
						var3_upvw.applyDebris(clone_4, 5)
						var3_upvw.applyStatus(arg1, "IFrames", 0.3)
						var3_upvw.applyStatus(arg1, "Freeze", 0.4)
						var3_upvw.applyStatus(arg1, "GlobalCD", 0.15)
						var3_upvw.applyStatus(v_upvr, "Stunned", 1)
						var3_upvw.applyStatus(v_upvr, "AutoRotate", 1)
						var3_upvw.applyStatus(v_upvr, "IFrames", 0.3)
						var3_upvw.applyDamage(v_upvr, 1, true, true)
					end), module_upvr.Cooldown)
					return
				end
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr
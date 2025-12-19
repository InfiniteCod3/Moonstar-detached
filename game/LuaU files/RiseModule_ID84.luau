-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:12
-- Luau version 6, Types version 3
-- Time taken: 0.028976 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 18
module_upvr.GlobalCD = 1.4
local var3_upvw
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
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
	local Rise_upvr = ReplicatedStorage_upvr.Skills["Titans Edge"].Ultimate.Rise
	local any_LoadAnimation_result1_4_upvr = Humanoid_upvr.Animator:LoadAnimation(Rise_upvr.Animation)
	any_LoadAnimation_result1_4_upvr:Play(0)
	var3_upvw.applyStatus(arg1, "Freeze", 0.9)
	var3_upvw.applyStatus(arg1, "GlobalCD", 0.9)
	local clone_7 = Rise_upvr.DashVFX:Clone()
	clone_7.Parent = Folder_upvr
	clone_7.CFrame = HumanoidRootPart_upvr.CFrame
	var3_upvw.EmitAllDescendants(clone_7)
	var3_upvw.applyDebris(clone_7, 5)
	local clone_3_upvr = Rise_upvr.DashingVFX.DashATT:Clone()
	clone_3_upvr.Parent = HumanoidRootPart_upvr
	var3_upvw.applyDebris(clone_3_upvr, 5)
	var3_upvw.conTimer(any_LoadAnimation_result1_4_upvr.Stopped:Connect(function() -- Line 50
		--[[ Upvalues[1]:
			[1]: clone_3_upvr (readonly)
		]]
		for _, v in clone_3_upvr:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end), module_upvr.Cooldown)
	var3_upvw.applySound(Rise_upvr.DashSFX, HumanoidRootPart_upvr)
	var3_upvw.applySound(Rise_upvr.DashSFX2, HumanoidRootPart_upvr)
	local var20_upvw
	var20_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3, arg4) -- Line 64
		--[[ Upvalues[11]:
			[1]: var20_upvw (read and write)
			[2]: PlayerStatus_upvr (copied, readonly)
			[3]: var3_upvw (copied, read and write)
			[4]: arg1 (readonly)
			[5]: Rise_upvr (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: any_LoadAnimation_result1_4_upvr (readonly)
			[8]: Humanoid_upvr (readonly)
			[9]: Folder_upvr (readonly)
			[10]: TweenService_upvr (copied, readonly)
			[11]: module_upvr (copied, readonly)
		]]
		var20_upvw:Disconnect()
		if PlayerStatus_upvr.FindStatus(arg3, "IFrames") then
		else
			var3_upvw.CheckBlock(arg3, true)
			var3_upvw.unragdoll(arg3)
			for _, v_2 in arg3.Humanoid:GetPlayingAnimationTracks() do
				v_2:AdjustSpeed(0)
			end
			task.wait()
			var3_upvw.camShake(arg1, "SmallBump")
			var3_upvw.changeFov(arg1, 50, 0, 0.5)
			var3_upvw.applyStatus(arg1, "Freeze", arg4 + 1)
			var3_upvw.applyStatus(arg1, "GlobalCD", arg4 + 1)
			var3_upvw.applyStatus(arg1, "IFrames", arg4 + 1)
			var3_upvw.applyStatus(arg3, "Stunned", arg4 + 1)
			var3_upvw.applyStatus(arg3, "IFrames", arg4 + 1)
			var3_upvw.applySound(Rise_upvr.TeleportSFX, HumanoidRootPart_upvr)
			var3_upvw.applySound(Rise_upvr.ChargeSFX, HumanoidRootPart_upvr)
			local any_applyWeld_result1_upvr = var3_upvw.applyWeld(arg3, Vector3.new(0, 0, 6), Vector3.new(0, 180, 0))
			var3_upvw.applyDebris(any_applyWeld_result1_upvr, 3)
			any_LoadAnimation_result1_4_upvr:AdjustSpeed(0)
			task.wait(arg4 + 0.25)
			any_LoadAnimation_result1_4_upvr:Stop(0.5)
			local any_LoadAnimation_result1_2_upvr = Humanoid_upvr.Animator:LoadAnimation(Rise_upvr.Animation2)
			any_LoadAnimation_result1_2_upvr:Play(0)
			any_LoadAnimation_result1_2_upvr:AdjustSpeed(1.2)
			var3_upvw.conTimer(any_LoadAnimation_result1_2_upvr:GetMarkerReachedSignal("slash"):Connect(function() -- Line 99
				--[[ Upvalues[11]:
					[1]: arg3 (readonly)
					[2]: any_LoadAnimation_result1_2_upvr (readonly)
					[3]: any_applyWeld_result1_upvr (readonly)
					[4]: var3_upvw (copied, read and write)
					[5]: Rise_upvr (copied, readonly)
					[6]: HumanoidRootPart_upvr (copied, readonly)
					[7]: arg1 (copied, readonly)
					[8]: Folder_upvr (copied, readonly)
					[9]: TweenService_upvr (copied, readonly)
					[10]: Humanoid_upvr (copied, readonly)
					[11]: module_upvr (copied, readonly)
				]]
				if not arg3.Parent then
				else
					any_LoadAnimation_result1_2_upvr:AdjustSpeed(0.25)
					any_applyWeld_result1_upvr:Destroy()
					var3_upvw.applySound(Rise_upvr.SlashSFX, HumanoidRootPart_upvr)
					var3_upvw.applyDamage(arg3, 10, true, true)
					var3_upvw.camShake(arg1, "Bump")
					var3_upvw.changeFov(arg1, 100, 0, 2)
					local clone = Rise_upvr.SlashVFX:Clone()
					clone.Parent = Folder_upvr
					clone.CFrame = HumanoidRootPart_upvr.CFrame
					var3_upvw.EmitAllDescendants(clone)
					var3_upvw.applyDebris(clone, 5)
					var3_upvw.applyStatus(arg1, "Freeze", 2.5)
					var3_upvw.applyStatus(arg1, "GlobalCD", 2.5)
					var3_upvw.applyStatus(arg1, "AutoRotate", 2.5)
					var3_upvw.applyStatus(arg1, "IFrames", 2.5)
					var3_upvw.applyStatus(arg3, "Stunned", 2.5)
					var3_upvw.applyStatus(arg3, "IFrames", 2)
					local BodyVelocity_upvr_2 = Instance.new("BodyVelocity", arg3.Torso)
					BodyVelocity_upvr_2.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					BodyVelocity_upvr_2.Velocity = Vector3.new(0, 0, 0)
					var3_upvw.applyDebris(BodyVelocity_upvr_2, 4)
					local BodyVelocity_upvr = Instance.new("BodyVelocity", arg1.Torso)
					BodyVelocity_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					BodyVelocity_upvr.Velocity = Vector3.new(0, 0, 0)
					var3_upvw.applyDebris(BodyVelocity_upvr, 4)
					local var32_upvr = HumanoidRootPart_upvr.Position + Vector3.new(0, 80, 0) + HumanoidRootPart_upvr.CFrame.LookVector * 10
					TweenService_upvr:Create(arg3.HumanoidRootPart, TweenInfo.new(0.7), {
						CFrame = CFrame.new(var32_upvr) * arg3.HumanoidRootPart.CFrame - arg3.HumanoidRootPart.CFrame.p;
					}):Play()
					local any_LoadAnimation_result1 = arg3.Humanoid.Animator:LoadAnimation(Rise_upvr.EnemyAnimation)
					any_LoadAnimation_result1:Play()
					any_LoadAnimation_result1:AdjustSpeed(0.5)
					task.delay(0.6, function() -- Line 143
						--[[ Upvalues[13]:
							[1]: arg3 (copied, readonly)
							[2]: var3_upvw (copied, read and write)
							[3]: arg1 (copied, readonly)
							[4]: any_LoadAnimation_result1_2_upvr (copied, readonly)
							[5]: HumanoidRootPart_upvr (copied, readonly)
							[6]: var32_upvr (readonly)
							[7]: TweenService_upvr (copied, readonly)
							[8]: Rise_upvr (copied, readonly)
							[9]: Folder_upvr (copied, readonly)
							[10]: Humanoid_upvr (copied, readonly)
							[11]: BodyVelocity_upvr_2 (readonly)
							[12]: BodyVelocity_upvr (readonly)
							[13]: module_upvr (copied, readonly)
						]]
						if not arg3.Parent then
						else
							var3_upvw.camShake(arg1, "SmallBump")
							var3_upvw.changeFov(arg1, 35, 0, 1)
							any_LoadAnimation_result1_2_upvr:Stop(0)
							HumanoidRootPart_upvr.CFrame = CFrame.new(var32_upvr + Vector3.new(0, 50, 0)) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
							TweenService_upvr:Create(HumanoidRootPart_upvr, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
								CFrame = CFrame.new(var32_upvr + Vector3.new(0, 3, 0)) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p;
							}):Play()
							local clone_2 = Rise_upvr.TeleportVFX:Clone()
							clone_2.Parent = Folder_upvr
							clone_2.CFrame = HumanoidRootPart_upvr.CFrame
							var3_upvw.EmitAllDescendants(clone_2)
							var3_upvw.applyDebris(clone_2, 5)
							var3_upvw.applySound(Rise_upvr.TeleportSFX, HumanoidRootPart_upvr)
							local any_LoadAnimation_result1_3_upvr = Humanoid_upvr.Animator:LoadAnimation(Rise_upvr.Animation3)
							any_LoadAnimation_result1_3_upvr:Play()
							var3_upvw.conTimer(any_LoadAnimation_result1_3_upvr:GetMarkerReachedSignal("slam"):Connect(function() -- Line 163
								--[[ Upvalues[11]:
									[1]: arg3 (copied, readonly)
									[2]: any_LoadAnimation_result1_3_upvr (readonly)
									[3]: var3_upvw (copied, read and write)
									[4]: BodyVelocity_upvr_2 (copied, readonly)
									[5]: BodyVelocity_upvr (copied, readonly)
									[6]: Rise_upvr (copied, readonly)
									[7]: HumanoidRootPart_upvr (copied, readonly)
									[8]: arg1 (copied, readonly)
									[9]: Folder_upvr (copied, readonly)
									[10]: var32_upvr (copied, readonly)
									[11]: TweenService_upvr (copied, readonly)
								]]
								if not arg3.Parent then
								else
									any_LoadAnimation_result1_3_upvr:AdjustSpeed(0.5)
									var3_upvw.applyDebris(BodyVelocity_upvr_2, 1)
									var3_upvw.applyDebris(BodyVelocity_upvr, 1)
									var3_upvw.applySound(Rise_upvr.PunchSFX, HumanoidRootPart_upvr)
									var3_upvw.changeFov(arg1, 64, 0, 0.25)
									local clone_4 = Rise_upvr.PunchVFX:Clone()
									clone_4.Parent = Folder_upvr
									clone_4.CFrame = HumanoidRootPart_upvr.CFrame
									var3_upvw.EmitAllDescendants(clone_4)
									var3_upvw.applyDebris(clone_4, 5)
									local var41 = var32_upvr + Vector3.new(0, -100, 0)
									local workspace_Raycast_result1 = workspace:Raycast(var32_upvr, Vector3.new(0, -100, 0), var3_upvw.raycastParams)
									if workspace_Raycast_result1 then
										var41 = workspace_Raycast_result1.Position
									end
									TweenService_upvr:Create(arg3.HumanoidRootPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
										CFrame = CFrame.new(var41) * arg3.HumanoidRootPart.CFrame - arg3.HumanoidRootPart.CFrame.p;
									}):Play()
									task.spawn(function() -- Line 183
										--[[ Upvalues[5]:
											[1]: Rise_upvr (copied, readonly)
											[2]: Folder_upvr (copied, readonly)
											[3]: arg3 (copied, readonly)
											[4]: TweenService_upvr (copied, readonly)
											[5]: var3_upvw (copied, read and write)
										]]
										for _ = 1, 3 do
											local clone_6 = Rise_upvr.Ring:Clone()
											clone_6.Parent = Folder_upvr
											clone_6.Position = arg3.Torso.Position
											TweenService_upvr:Create(clone_6, TweenInfo.new(0.7), {
												Size = Vector3.new(35, 1, 35);
												Transparency = 1;
											}):Play()
											var3_upvw.applyDebris(clone_6, 2)
											task.wait(0.1)
										end
									end)
									var3_upvw.applyDamage(arg3, 10, true, true)
									var3_upvw.camShake(arg1, "BigBump")
									task.wait(0.25)
									var3_upvw.camShake(arg1, "BigBump")
									var3_upvw.applySound(Rise_upvr.ShockwaveSFX, arg3.Torso)
									var3_upvw.applySound(Rise_upvr.ExplosionSFX, arg3.Torso)
									local clone_5 = Rise_upvr.ShockwaveVFX:Clone()
									clone_5.Parent = Folder_upvr
									clone_5.CFrame = CFrame.new(var41 + Vector3.new(0, 3.09999, 0)) * clone_5.CFrame - clone_5.CFrame.p
									var3_upvw.EmitAllDescendants(clone_5)
									var3_upvw.applyDebris(clone_5, 5)
									var3_upvw.applyDamage(arg3, 10, true)
									var3_upvw.applyStatus(arg3, "Ragdoll", 3)
									var3_upvw.CreateDebris(arg3.Torso.Position, 10, 0.5, 0.5, 0.05)
									var3_upvw.crater(1, arg3.Torso.Position, 5, 1)
								end
							end), module_upvr.Cooldown)
						end
					end)
				end
			end), module_upvr.Cooldown)
		end
	end), module_upvr.Cooldown)
	task.delay(1, function() -- Line 221
		--[[ Upvalues[1]:
			[1]: var20_upvw (read and write)
		]]
		if not var20_upvw then
		else
			var20_upvw:Disconnect()
		end
	end)
end
return module_upvr
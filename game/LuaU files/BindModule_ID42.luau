-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:19
-- Luau version 6, Types version 3
-- Time taken: 0.041716 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 26
module_upvr.GlobalCD = 0.15
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[6]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: RunService_upvr (readonly)
		[6]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local Bind_upvr = ReplicatedStorage_upvr.Skills["Blood Sword"].Bind
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Bind_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(1)
	var3_upvw.applyStatus(arg1, "Slowed", 0.5)
	var3_upvw.applyStatus(arg1, "Freeze", 0.25)
	var3_upvw.applyStatus(arg1, "GlobalCD", 0.3)
	local var11_upvw
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var11_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 48
		--[[ Upvalues[10]:
			[1]: arg2 (readonly)
			[2]: var11_upvw (read and write)
			[3]: var3_upvw (copied, read and write)
			[4]: Bind_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: arg1 (readonly)
			[7]: Folder_upvr (readonly)
			[8]: TweenService_upvr (copied, readonly)
			[9]: RunService_upvr (copied, readonly)
			[10]: PlayerStatus_upvr (copied, readonly)
		]]
		-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
		if arg1_2 ~= arg2 or arg2_2 ~= "Bind" then
		else
			var11_upvw:Disconnect()
			var3_upvw.applySound(Bind_upvr.Snap, HumanoidRootPart_upvr)
			var3_upvw.changeFov(arg1, 65, 0, 2)
			var3_upvw.camShake(arg1, "SmallBump")
			task.wait()
			local clone_2_upvr = Bind_upvr.Indicator:Clone()
			clone_2_upvr.Parent = Folder_upvr
			clone_2_upvr.CFrame = arg3 + arg3.LookVector * 30 + Vector3.new(0, -2.9000, 0)
			var3_upvw.EmitAllDescendants(clone_2_upvr)
			var3_upvw.applyDebris(clone_2_upvr, 3)
			clone_2_upvr.Blood:Play()
			clone_2_upvr.whoosh:Play()
			TweenService_upvr:Create(clone_2_upvr.BallSpawn, TweenInfo.new(0.75), {
				Size = Vector3.new(4, 4, 4);
			}):Play()
			task.delay(1, function() -- Line 68
				--[[ Upvalues[2]:
					[1]: TweenService_upvr (copied, readonly)
					[2]: clone_2_upvr (readonly)
				]]
				TweenService_upvr:Create(clone_2_upvr.BallSpawn, TweenInfo.new(1), {
					Size = Vector3.new(0, 0, 0);
				}):Play()
			end)
			local workspace_Raycast_result1 = workspace:Raycast(clone_2_upvr.Position, Vector3.new(0, -20, 0), var3_upvw.raycastParams)
			if workspace_Raycast_result1 then
				clone_2_upvr.CFrame = CFrame.new(workspace_Raycast_result1.Position) * clone_2_upvr.CFrame - clone_2_upvr.CFrame.p
			end
			for _, v_upvr in var3_upvw.findEnemiesPart(clone_2_upvr.hitbox, true), nil do
				local Position_2_upvr = clone_2_upvr.Position
				task.delay(0.15, function() -- Line 80
					--[[ Upvalues[10]:
						[1]: Bind_upvr (copied, readonly)
						[2]: Folder_upvr (copied, readonly)
						[3]: clone_2_upvr (readonly)
						[4]: RunService_upvr (copied, readonly)
						[5]: v_upvr (readonly)
						[6]: TweenService_upvr (copied, readonly)
						[7]: var3_upvw (copied, read and write)
						[8]: arg1 (copied, readonly)
						[9]: PlayerStatus_upvr (copied, readonly)
						[10]: Position_2_upvr (readonly)
					]]
					local clone_3_upvr = Bind_upvr.bloodBall:Clone()
					clone_3_upvr.Parent = Folder_upvr
					clone_3_upvr.CFrame = clone_2_upvr.BallSpawn.CFrame * CFrame.Angles(0, math.rad(math.random(-75, 75)), math.rad(math.random(-75, 0)))
					local var29_upvw = "Slow"
					task.delay(0.75, function() -- Line 86
						--[[ Upvalues[1]:
							[1]: var29_upvw (read and write)
						]]
						var29_upvw = "Fast"
					end)
					local var32_upvw
					var32_upvw = RunService_upvr.Stepped:Connect(function() -- Line 91
						--[[ Upvalues[10]:
							[1]: clone_3_upvr (readonly)
							[2]: v_upvr (copied, readonly)
							[3]: var32_upvw (read and write)
							[4]: var29_upvw (read and write)
							[5]: TweenService_upvr (copied, readonly)
							[6]: var3_upvw (copied, read and write)
							[7]: arg1 (copied, readonly)
							[8]: Bind_upvr (copied, readonly)
							[9]: PlayerStatus_upvr (copied, readonly)
							[10]: Position_2_upvr (copied, readonly)
						]]
						if not clone_3_upvr.Parent or not v_upvr.Parent then
							var32_upvw:Disconnect()
						else
							if not v_upvr.Parent then
								clone_3_upvr:Destroy()
								var32_upvw:Disconnect()
								return
							end
							if var29_upvw == "Slow" then
								TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(0.9), {
									CFrame = CFrame.lookAt(clone_3_upvr.Position, v_upvr.HumanoidRootPart.Position);
								}):Play()
							elseif var29_upvw == "Fast" then
								TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(0.45), {
									CFrame = CFrame.lookAt(clone_3_upvr.Position, v_upvr.HumanoidRootPart.Position);
								}):Play()
							elseif var29_upvw == "Really Fast" then
								TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(0.15), {
									CFrame = CFrame.lookAt(clone_3_upvr.Position, v_upvr.HumanoidRootPart.Position);
								}):Play()
							end
							local Magnitude = (clone_3_upvr.Position - v_upvr.HumanoidRootPart.Position).Magnitude
							if Magnitude <= 10 then
								var29_upvw = "Really Fast"
							end
							TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
								Position = clone_3_upvr.Position + clone_3_upvr.CFrame.LookVector * 14;
							}):Play()
							if Magnitude <= 2.5 then
								var32_upvw:Disconnect()
								clone_3_upvr.Transparency = 1
								var3_upvw.applyDebris(clone_3_upvr.Aura)
								for _, v_2 in clone_3_upvr:GetChildren() do
									if v_2:IsA("Trail") then
										v_2.Enabled = false
									end
								end
								var3_upvw.changeFov(arg1, 65, 0, 2)
								var3_upvw.camShake(arg1, "SmallBump")
								clone_3_upvr.CFrame = v_upvr.HumanoidRootPart.CFrame
								local clone = Bind_upvr.HitVFX.Att:Clone()
								clone.Parent = v_upvr.Torso
								var3_upvw.EmitAllDescendants(clone)
								var3_upvw.applyDebris(clone, 3)
								var3_upvw.applySound(Bind_upvr["Body Explode"], v_upvr.Torso)
								if not PlayerStatus_upvr.FindStatus(v_upvr, "Blocking") then
									if not PlayerStatus_upvr.FindStatus(v_upvr, "IFrames") then
										var3_upvw.unragdoll(v_upvr)
										local Position_3 = v_upvr.HumanoidRootPart.Position
										v_upvr.HumanoidRootPart.CFrame = CFrame.lookAt(Position_3, Vector3.new(Position_2_upvr.X, Position_3.Y, Position_2_upvr.Z))
										local any_applySound_result1_upvr = var3_upvw.applySound(Bind_upvr["Car Explosion"], v_upvr.Torso)
										task.delay(1, function() -- Line 145
											--[[ Upvalues[2]:
												[1]: TweenService_upvr (copied, readonly)
												[2]: any_applySound_result1_upvr (readonly)
											]]
											TweenService_upvr:Create(any_applySound_result1_upvr, TweenInfo.new(2), {
												Volume = 0;
											}):Play()
										end)
										var3_upvw.applyDamage(v_upvr, 10)
										if PlayerStatus_upvr.FindStatus(v_upvr, "HyperArmor") then return end
										var3_upvw.applyStatus(v_upvr, "Stunned", 2)
										var3_upvw.applyStatus(v_upvr, "AutoRotate", 2)
										for _, v_3 in v_upvr.Humanoid:GetPlayingAnimationTracks() do
											v_3:Stop(0)
										end
										local any_LoadAnimation_result1_upvr = v_upvr.Humanoid:LoadAnimation(Bind_upvr.EnemyAnimation)
										any_LoadAnimation_result1_upvr:Play(0)
										local clone_4_upvr = Bind_upvr.BindModel:Clone()
										clone_4_upvr.Parent = v_upvr
										var3_upvw.applyDebris(clone_4_upvr, 3)
										for _, v_4 in clone_4_upvr:GetChildren() do
											v_4.weld.Part0 = v_upvr[v_4.Name]
											v_4.weld.Part1 = v_4
										end
										task.delay(2, function() -- Line 172
											--[[ Upvalues[3]:
												[1]: any_LoadAnimation_result1_upvr (readonly)
												[2]: clone_4_upvr (readonly)
												[3]: TweenService_upvr (copied, readonly)
											]]
											any_LoadAnimation_result1_upvr:Stop(0.3)
											for _, v_5 in clone_4_upvr:GetChildren() do
												TweenService_upvr:Create(v_5, TweenInfo.new(1), {
													Transparency = 1;
												}):Play()
												v_5.Attachment.explo.Enabled = false
											end
										end)
									end
								end
							end
						end
					end)
				end)
				local _
			end
		end
	end)
	local var100 = var11_upvw
	task.wait(1)
	if var100 then
		var100:Disconnect()
	end
end
return module_upvr
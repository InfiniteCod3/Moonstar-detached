-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:13
-- Luau version 6, Types version 3
-- Time taken: 0.029865 seconds

local module_upvr = {
	Cooldown = 18;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 17
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
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 5)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Siphon_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"].Siphon
	local CyberKatana_upvr = arg1:FindFirstChild("CyberKatana")
	local clone_8_upvr = Siphon_upvr.Charge:Clone()
	clone_8_upvr.Parent = HumanoidRootPart_upvr
	clone_8_upvr:Play()
	var2_upvw.applyDebris(clone_8_upvr, 4)
	local clone_5_upvr = Siphon_upvr.Charge2:Clone()
	clone_5_upvr.Parent = HumanoidRootPart_upvr
	clone_5_upvr:Play()
	var2_upvw.applyDebris(clone_5_upvr, 4)
	local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Siphon_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(1.05)
	any_LoadAnimation_result1.Stopped:Connect(function() -- Line 45
		--[[ Upvalues[4]:
			[1]: CyberKatana_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: clone_8_upvr (readonly)
			[4]: clone_5_upvr (readonly)
		]]
		CyberKatana_upvr.TrailAtt.Trail.Enabled = false
		var2_upvw.applyDebris(clone_8_upvr, 0)
		var2_upvw.applyDebris(clone_5_upvr, 0)
	end)
	local var15_upvw = 0
	local tbl_upvr = {}
	local function _(arg1_2) -- Line 53, Named "teleport"
		--[[ Upvalues[8]:
			[1]: var15_upvw (read and write)
			[2]: arg1 (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: tbl_upvr (readonly)
			[5]: ReplicatedStorage_upvr (copied, readonly)
			[6]: Folder_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: HumanoidRootPart_upvr (readonly)
		]]
		var15_upvw += 1
		if not arg1.Head:FindFirstChild("LockBV") then
			local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
			BodyVelocity.Name = "LockBV"
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = Vector3.new(0, 0, 0)
			table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "IFrames"))
		end
		task.delay(0.3, function() -- Line 67
			--[[ Upvalues[4]:
				[1]: ReplicatedStorage_upvr (copied, readonly)
				[2]: var15_upvw (copied, read and write)
				[3]: arg1 (copied, readonly)
				[4]: var2_upvw (copied, read and write)
			]]
			var15_upvw -= 1
			if var15_upvw <= 0 then
				for _, v in require(ReplicatedStorage_upvr.Modules.PlayerStatus).FindTable(arg1) do
					if v:GetAttribute("TeleportIFrame") then
						var2_upvw.applyDebris(v, 0)
					end
				end
				for _, v_2 in arg1.Head:GetChildren() do
					if v_2.Name == "LockBV" then
						v_2:Destroy()
					end
				end
			end
		end)
		for _, v_3 in arg1:GetChildren() do
			if table.find({"Left Arm", "Right Arm", "Head", "Left Leg", "Right Leg", "Torso"}, v_3.Name) and v_3:IsA("BasePart") then
				local clone_9 = v_3:Clone()
				for _, v_4 in clone_9:GetChildren() do
					if not v_4:IsA("SpecialMesh") or not v_4:IsA("CharacterMesh") or not v_4:IsA("BlockMesh") then
						v_4:Destroy()
					end
				end
				clone_9.Transparency = 0.5
				clone_9.Parent = Folder_upvr
				clone_9.Material = Enum.Material.Neon
				clone_9.Anchored = true
				clone_9.CanCollide = false
				TweenService_upvr:Create(clone_9, TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Transparency = 1;
					Size = Vector3.new(0, 0, 0);
				}):Play()
				game.Debris:AddItem(clone_9, 3)
				clone_9.Color = Color3.new(1, 1, 1)
				TweenService_upvr:Create(clone_9, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Color = Color3.fromRGB(98, 37, 209);
				}):Play()
				if clone_9.Name == "Torso" then
					local clone_3 = ReplicatedStorage_upvr.Skills["Cyber Katana"].TeleportSFX:Clone()
					clone_3.Parent = clone_9
					clone_3.PlaybackSpeed += math.random(-3, 3) * 0.075
					clone_3:Play()
					local clone_2 = ReplicatedStorage_upvr.Skills["Cyber Katana"].TeleportSFX2:Clone()
					clone_2.Parent = clone_9
					clone_2.PlaybackSpeed += math.random(-3, 3) * 0.075
					clone_2:Play()
				end
			end
		end
		if arg1_2 then
			HumanoidRootPart_upvr.CFrame = arg1_2
		end
		for _, v_5_upvr in arg1:GetDescendants() do
			if v_5_upvr:IsA("BasePart") and v_5_upvr.Transparency == 0 then
				v_5_upvr.Transparency = 1
				task.delay(0.05, function() -- Line 131
					--[[ Upvalues[1]:
						[1]: v_5_upvr (readonly)
					]]
					v_5_upvr.Transparency = 0
				end)
			end
		end
	end
	var2_upvw.applyStatus(arg1, "Freeze", 0.5)
	local any_applyStatus_result1_upvr_2 = var2_upvw.applyStatus(arg1, "GlobalCD", 0.5)
	any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 144
		--[[ Upvalues[12]:
			[1]: var2_upvw (copied, read and write)
			[2]: clone_5_upvr (readonly)
			[3]: ReplicatedStorage_upvr (copied, readonly)
			[4]: arg2 (readonly)
			[5]: arg1 (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: Siphon_upvr (readonly)
			[8]: Folder_upvr (readonly)
			[9]: TweenService_upvr (copied, readonly)
			[10]: any_applyStatus_result1_upvr_2 (readonly)
			[11]: Humanoid_upvr (readonly)
			[12]: RunService_upvr (copied, readonly)
		]]
		var2_upvw.applyDebris(clone_5_upvr, 0)
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "Siphon")
		var2_upvw.applyStatus(arg1, "AutoRotate", 0.5)
		var2_upvw.applyStatus(arg1, "Freeze", 0.5)
		task.wait()
		local var53_upvw
		task.delay(1, function() -- Line 156
			--[[ Upvalues[1]:
				[1]: var53_upvw (read and write)
			]]
			if not var53_upvw then
			else
				var53_upvw:Disconnect()
			end
		end)
		local any_applyStatus_result1_upvr = var2_upvw.applyStatus(arg1, "GlobalCD", 0.5)
		var53_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2, arg3) -- Line 162
			--[[ Upvalues[13]:
				[1]: arg2 (copied, readonly)
				[2]: var53_upvw (read and write)
				[3]: HumanoidRootPart_upvr (copied, readonly)
				[4]: var2_upvw (copied, read and write)
				[5]: arg1 (copied, readonly)
				[6]: Siphon_upvr (copied, readonly)
				[7]: Folder_upvr (copied, readonly)
				[8]: TweenService_upvr (copied, readonly)
				[9]: any_applyStatus_result1_upvr_2 (copied, readonly)
				[10]: any_applyStatus_result1_upvr (readonly)
				[11]: Humanoid_upvr (copied, readonly)
				[12]: ReplicatedStorage_upvr (copied, readonly)
				[13]: RunService_upvr (copied, readonly)
			]]
			if arg2_2 ~= "Siphon" or arg1_3 ~= arg2 then
			else
				var53_upvw:Disconnect()
				HumanoidRootPart_upvr.CFrame = arg3
				var2_upvw.camShake(arg1, "Bump")
				var2_upvw.changeFov(arg1, 30, 0.1, 2)
				var2_upvw.flashScreen(arg1, Color3.new(0.694118, 0.164706, 1), 1)
				var2_upvw.impactFrame2(arg1)
				local clone_7_upvr = Siphon_upvr.SiphonVFX:Clone()
				clone_7_upvr.CFrame = HumanoidRootPart_upvr.CFrame * CFrame.Angles(0, -1.4835298641951802, 0) + Vector3.new(0, -3, 0)
				clone_7_upvr.Parent = Folder_upvr
				TweenService_upvr:Create(clone_7_upvr, TweenInfo.new(0.25), {
					CFrame = clone_7_upvr.CFrame * CFrame.Angles(0, 2.0769418098732517, 0);
				}):Play()
				var2_upvw.EmitAllDescendants(clone_7_upvr)
				clone_7_upvr.Slash:Play()
				clone_7_upvr.Slash2:Play()
				task.delay(0.12, function() -- Line 184
					--[[ Upvalues[11]:
						[1]: Siphon_upvr (copied, readonly)
						[2]: Folder_upvr (copied, readonly)
						[3]: arg3 (readonly)
						[4]: var2_upvw (copied, read and write)
						[5]: arg1 (copied, readonly)
						[6]: any_applyStatus_result1_upvr_2 (copied, readonly)
						[7]: any_applyStatus_result1_upvr (copied, readonly)
						[8]: TweenService_upvr (copied, readonly)
						[9]: HumanoidRootPart_upvr (copied, readonly)
						[10]: Humanoid_upvr (copied, readonly)
						[11]: ReplicatedStorage_upvr (copied, readonly)
					]]
					local clone = Siphon_upvr.HitboxCarrier:Clone()
					clone.Parent = Folder_upvr
					clone.CFrame = arg3 + Vector3.new(0, -2.5, 0)
					var2_upvw.applyDebris(clone, 1)
					local any_findEnemiesPart_result1 = var2_upvw.findEnemiesPart(clone.Hitbox, true)
					if 0 < #any_findEnemiesPart_result1 then
						var2_upvw.applyStatus(arg1, "CombatStun", 0.4)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr_2, 0.1)
						var2_upvw.applyDebris(any_applyStatus_result1_upvr, 0.1)
					end
					for _, v_6_upvr in any_findEnemiesPart_result1 do
						task.spawn(function() -- Line 198
							--[[ Upvalues[9]:
								[1]: var2_upvw (copied, read and write)
								[2]: v_6_upvr (readonly)
								[3]: Folder_upvr (copied, readonly)
								[4]: TweenService_upvr (copied, readonly)
								[5]: Siphon_upvr (copied, readonly)
								[6]: HumanoidRootPart_upvr (copied, readonly)
								[7]: Humanoid_upvr (copied, readonly)
								[8]: arg1 (copied, readonly)
								[9]: ReplicatedStorage_upvr (copied, readonly)
							]]
							-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
							local var68 = v_6_upvr
							-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
							-- KONSTANTERROR: [268] 203. Error Block 55 start (CF ANALYSIS FAILED)
							if not var2_upvw.CheckHyperArmor(v_6_upvr) and not var68 then
								var2_upvw.unragdoll(v_6_upvr)
								var2_upvw.applyStatus(v_6_upvr, "Stunned", 1.1)
								v_6_upvr.HumanoidRootPart.CFrame = CFrame.lookAt(v_6_upvr.HumanoidRootPart.Position, v_6_upvr.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
								task.wait()
								local clone_6 = Siphon_upvr.FrontPart:Clone()
								clone_6.Parent = v_6_upvr
								clone_6.Motor6D.Part0 = v_6_upvr.HumanoidRootPart
								clone_6.Motor6D.Part1 = clone_6
								var2_upvw.applyDebris(clone_6, 1)
								local BodyVelocity_2 = Instance.new("BodyVelocity", clone_6)
								BodyVelocity_2.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
								BodyVelocity_2.Velocity = Vector3.new(0, 20, 0)
								var2_upvw.applyDebris(BodyVelocity_2, 0.9)
								TweenService_upvr:Create(BodyVelocity_2, TweenInfo.new(0.75), {
									Velocity = Vector3.new(0, 0, 0);
								}):Play()
								task.wait(0.1)
								for _, v_7 in require(ReplicatedStorage_upvr.Modules.PlayerStatus).FindTable(v_6_upvr) do
									if v_7.Name == "HyperArmor" then
										var2_upvw.applyDebris(v_7, 0)
									end
								end
								var2_upvw.applyStatus(v_6_upvr, "Ragdoll", 0.95)
								for _ = 1, 3 do
									local clone_4_upvr = Siphon_upvr.SiphonBall:Clone()
									clone_4_upvr.Parent = Folder_upvr
									clone_4_upvr.CFrame = v_6_upvr.HumanoidRootPart.CFrame
									clone_4_upvr.CFrame = CFrame.lookAt(clone_4_upvr.Position, HumanoidRootPart_upvr.Position)
									game.Debris:AddItem(clone_4_upvr, 10)
									TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
										Position = clone_4_upvr.Position:Lerp(HumanoidRootPart_upvr.Position, 0.5) + (clone_4_upvr.CFrame.RightVector) * (math.random(-4, 4) * 1.5) + (clone_4_upvr.CFrame.UpVector) * (math.random(-4, 4) * 1.5);
									}):Play()
									-- KONSTANTERROR: Expression was reused, decompilation is incorrect
									clone_4_upvr.Appear.PlaybackSpeed = clone_4_upvr.Appear.PlaybackSpeed + math.random(-3, 3) * 0.06
									clone_4_upvr.Appear:Play()
									task.delay(0.3, function() -- Line 331
										--[[ Upvalues[6]:
											[1]: TweenService_upvr (copied, readonly)
											[2]: clone_4_upvr (readonly)
											[3]: HumanoidRootPart_upvr (copied, readonly)
											[4]: Humanoid_upvr (copied, readonly)
											[5]: var2_upvw (copied, read and write)
											[6]: arg1 (copied, readonly)
										]]
										TweenService_upvr:Create(clone_4_upvr, TweenInfo.new((clone_4_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.03, Enum.EasingStyle.Linear), {
											Position = HumanoidRootPart_upvr.Position;
										}):Play()
										task.wait(0.1)
										while task.wait() and clone_4_upvr.Parent and clone_4_upvr.Transparency ~= 1 do
											TweenService_upvr:Create(clone_4_upvr, TweenInfo.new((clone_4_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.01, Enum.EasingStyle.Linear), {
												Position = HumanoidRootPart_upvr.Position;
											}):Play()
											if (clone_4_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude <= 2 then
												TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(0, Enum.EasingStyle.Linear), {
													Position = HumanoidRootPart_upvr.Position;
												}):Play()
												task.wait()
												clone_4_upvr.Position = HumanoidRootPart_upvr.Position
												local HealSFX = clone_4_upvr.HealSFX
												HealSFX.PlaybackSpeed += math.random(-1, 1) * 0.1
												clone_4_upvr.HealSFX:Play()
												local var82 = Humanoid_upvr
												var82.Health += 3
												clone_4_upvr.Transparency = 1
												clone_4_upvr.Trail.Enabled = false
												var2_upvw.changeFov(arg1, 60, 0.05, 0.6)
												var2_upvw.flashScreen(arg1, Color3.new(0.968627, 0.882353, 1), 0.5)
											end
										end
									end)
									task.wait(0.05)
								end
							end
							-- KONSTANTERROR: [268] 203. Error Block 55 end (CF ANALYSIS FAILED)
							-- KONSTANTERROR: [525] 387. Error Block 41 start (CF ANALYSIS FAILED)
							-- KONSTANTERROR: [525] 387. Error Block 41 end (CF ANALYSIS FAILED)
						end)
					end
				end)
				local var84_upvw
				task.delay(0.15, function() -- Line 368
					--[[ Upvalues[1]:
						[1]: var84_upvw (read and write)
					]]
					var84_upvw:Disconnect()
				end)
				var84_upvw = RunService_upvr.Stepped:Connect(function() -- Line 372
					--[[ Upvalues[2]:
						[1]: clone_7_upvr (readonly)
						[2]: var2_upvw (copied, read and write)
					]]
					if not workspace:Raycast(clone_7_upvr.Att2.WorldPosition + Vector3.new(0, 0.25, 0), Vector3.new(0, -0.75, 0), var2_upvw.raycastParams) then
						for _, v_8 in clone_7_upvr:GetDescendants() do
							if v_8:IsA("Trail") then
								v_8.Enabled = false
							end
						end
					else
						for _, v_9 in clone_7_upvr:GetDescendants() do
							if v_9:IsA("Trail") then
								v_9.Enabled = true
							end
						end
					end
				end)
			end
		end)
	end)
	any_LoadAnimation_result1:GetMarkerReachedSignal("trail"):Connect(function(arg1_4) -- Line 392
		--[[ Upvalues[1]:
			[1]: CyberKatana_upvr (readonly)
		]]
		if arg1_4 == "true" then
			CyberKatana_upvr.TrailAtt.Trail.Enabled = true
		else
			CyberKatana_upvr.TrailAtt.Trail.Enabled = false
		end
	end)
	any_LoadAnimation_result1:GetMarkerReachedSignal("resetidle"):Connect(function() -- Line 400
		--[[ Upvalues[2]:
			[1]: Humanoid_upvr (readonly)
			[2]: ReplicatedStorage_upvr (copied, readonly)
		]]
		Humanoid_upvr.Animator:LoadAnimation(ReplicatedStorage_upvr.Animations.ResetIdle):Play(0.4)
	end)
end
return module_upvr
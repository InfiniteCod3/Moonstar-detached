-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:10
-- Luau version 6, Types version 3
-- Time taken: 0.028309 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 22
module_upvr.GlobalCD = 1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 17
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
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Quick_Steps_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"]["Quick Steps"]
	local CyberKatana_upvr = arg1:FindFirstChild("CyberKatana")
	local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Quick_Steps_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(0.65)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 35
		--[[ Upvalues[1]:
			[1]: CyberKatana_upvr (readonly)
		]]
		CyberKatana_upvr.TrailAtt.Trail.Enabled = false
	end), module_upvr.Cooldown)
	var3_upvw.applyStatus(arg1, "Freeze", 1)
	local var14_upvw = 0
	local tbl_upvr = {}
	local function teleport_upvr(arg1_2) -- Line 43, Named "teleport"
		--[[ Upvalues[8]:
			[1]: var14_upvw (read and write)
			[2]: arg1 (readonly)
			[3]: var3_upvw (copied, read and write)
			[4]: tbl_upvr (readonly)
			[5]: Folder_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
			[7]: ReplicatedStorage_upvr (copied, readonly)
			[8]: HumanoidRootPart_upvr (readonly)
		]]
		var14_upvw += 1
		if not arg1.Head:FindFirstChild("LockBV") then
			local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
			BodyVelocity.Name = "LockBV"
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = Vector3.new(0, 0, 0)
			table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames"))
		end
		task.delay(0.2, function() -- Line 57
			--[[ Upvalues[4]:
				[1]: var14_upvw (copied, read and write)
				[2]: tbl_upvr (copied, readonly)
				[3]: var3_upvw (copied, read and write)
				[4]: arg1 (copied, readonly)
			]]
			var14_upvw -= 1
			if var14_upvw <= 0 then
				for _, v in tbl_upvr do
					var3_upvw.applyDebris(v, 0)
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
				local clone_2 = v_3:Clone()
				for _, v_4 in clone_2:GetChildren() do
					if not v_4:IsA("SpecialMesh") or not v_4:IsA("CharacterMesh") or not v_4:IsA("BlockMesh") then
						v_4:Destroy()
					end
				end
				clone_2.Transparency = 0.5
				clone_2.Parent = Folder_upvr
				clone_2.Material = Enum.Material.Neon
				clone_2.Anchored = true
				clone_2.CanCollide = false
				TweenService_upvr:Create(clone_2, TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Transparency = 1;
					Size = Vector3.new(0, 0, 0);
				}):Play()
				game.Debris:AddItem(clone_2, 3)
				clone_2.Color = Color3.new(1, 1, 1)
				TweenService_upvr:Create(clone_2, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Color = Color3.fromRGB(98, 37, 209);
				}):Play()
				if clone_2.Name == "Torso" then
					local clone_11 = ReplicatedStorage_upvr.Skills["Cyber Katana"].TeleportSFX:Clone()
					clone_11.Parent = clone_2
					clone_11.PlaybackSpeed += math.random(-3, 3) * 0.075
					clone_11:Play()
					local clone_7 = ReplicatedStorage_upvr.Skills["Cyber Katana"].TeleportSFX2:Clone()
					clone_7.Parent = clone_2
					clone_7.PlaybackSpeed += math.random(-3, 3) * 0.075
					clone_7:Play()
				end
			end
		end
		if arg1_2 then
			HumanoidRootPart_upvr.CFrame = arg1_2
		end
		for _, v_5_upvr in arg1:GetDescendants() do
			if v_5_upvr:IsA("BasePart") and v_5_upvr.Transparency == 0 then
				v_5_upvr.Transparency = 1
				task.delay(0.05, function() -- Line 118
					--[[ Upvalues[1]:
						[1]: v_5_upvr (readonly)
					]]
					v_5_upvr.Transparency = 0
				end)
			end
		end
	end
	local clone_upvr = Quick_Steps_upvr.ArmShuriken:Clone()
	clone_upvr.Parent = arg1
	clone_upvr.weld.Part0 = arg1["Left Arm"]
	clone_upvr.weld.Part1 = clone_upvr
	var3_upvw.applyDebris(clone_upvr, 6)
	local clone_5 = Quick_Steps_upvr.PrepareSFX:Clone()
	clone_5.Parent = HumanoidRootPart_upvr
	clone_5:Play()
	var3_upvw.applyDebris(clone_5, 6)
	local clone = Quick_Steps_upvr.ShurikenSFX:Clone()
	clone.Parent = HumanoidRootPart_upvr
	clone:Play()
	var3_upvw.applyDebris(clone, 6)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("teleport"):Connect(function() -- Line 144
		--[[ Upvalues[15]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: arg2 (readonly)
			[3]: Quick_Steps_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: var3_upvw (copied, read and write)
			[6]: any_LoadAnimation_result1_upvr (readonly)
			[7]: arg1 (readonly)
			[8]: RunService_upvr (copied, readonly)
			[9]: teleport_upvr (readonly)
			[10]: PlayerStatus_upvr (copied, readonly)
			[11]: Folder_upvr (readonly)
			[12]: TweenService_upvr (copied, readonly)
			[13]: module_upvr (copied, readonly)
			[14]: Humanoid_upvr (readonly)
			[15]: clone_upvr (readonly)
		]]
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "QuickStep")
		local clone_3_upvr = Quick_Steps_upvr.WhooshSFX:Clone()
		clone_3_upvr.Parent = HumanoidRootPart_upvr
		clone_3_upvr:Play()
		var3_upvw.applyDebris(clone_3_upvr, 6)
		any_LoadAnimation_result1_upvr:AdjustSpeed(0)
		var3_upvw.applyStatus(arg1, "GlobalCD", 1)
		var3_upvw.applyStatus(arg1, "Freeze", 1)
		local clone_9_upvr = Quick_Steps_upvr.VFX.BottomTrail:Clone()
		clone_9_upvr.Parent = HumanoidRootPart_upvr
		var3_upvw.applyDebris(clone_9_upvr, 5)
		local var53_upvw = false
		local var55_upvw
		local any_applyStatus_result1_upvr = var3_upvw.applyStatus(arg1, "IFrames", 1)
		var55_upvw = var3_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 167
			--[[ Upvalues[19]:
				[1]: teleport_upvr (copied, readonly)
				[2]: var3_upvw (copied, read and write)
				[3]: HumanoidRootPart_upvr (copied, readonly)
				[4]: var53_upvw (read and write)
				[5]: var55_upvw (read and write)
				[6]: arg1 (copied, readonly)
				[7]: clone_9_upvr (readonly)
				[8]: any_LoadAnimation_result1_upvr (copied, readonly)
				[9]: PlayerStatus_upvr (copied, readonly)
				[10]: clone_3_upvr (readonly)
				[11]: Quick_Steps_upvr (copied, readonly)
				[12]: Folder_upvr (copied, readonly)
				[13]: TweenService_upvr (copied, readonly)
				[14]: ReplicatedStorage_upvr (copied, readonly)
				[15]: RunService_upvr (copied, readonly)
				[16]: module_upvr (copied, readonly)
				[17]: Humanoid_upvr (copied, readonly)
				[18]: clone_upvr (copied, readonly)
				[19]: any_applyStatus_result1_upvr (readonly)
			]]
			teleport_upvr()
			for _, v_6_upvr in var3_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 8, 12), nil do
				var53_upvw = true
				var55_upvw:Disconnect()
				var3_upvw.applyStatus(arg1, "FoundEnemy", 1)
				var3_upvw.applyDebris(clone_9_upvr, 0)
				any_LoadAnimation_result1_upvr:Stop(1)
				if not PlayerStatus_upvr.FindStatus(v_6_upvr, "Blocking") then
					for _, v_7 in clone_9_upvr:GetDescendants() do
						if v_7:IsA("Trail") then
							v_7.Enabled = false
						end
					end
					clone_3_upvr:Destroy()
					local clone_4 = Quick_Steps_upvr.TpParts:Clone()
					clone_4.Parent = Folder_upvr
					clone_4.weld.Part0 = v_6_upvr.HumanoidRootPart
					clone_4.weld.Part1 = clone_4
					var3_upvw.applyDebris(clone_4, 5)
					var3_upvw.applyStatus(arg1, "GlobalCD", 1.6)
					var3_upvw.applyStatus(arg1, "Freeze", 1.6)
					var3_upvw.applyStatus(arg1, "AutoRotate", 1.6)
					var3_upvw.applyStatus(arg1, "IFrames", 1.6)
					var3_upvw.applyStatus(v_6_upvr, "Stunned", 1.85)
					var3_upvw.applyStatus(v_6_upvr, "AutoRotate", 1.85)
					any_LoadAnimation_result1_upvr:Stop()
					TweenService_upvr:Create(v_6_upvr.HumanoidRootPart, TweenInfo.new(0.8), {
						CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 25) * CFrame.Angles(0, math.pi, 0);
					}):Play()
					local clone_10_upvr = ReplicatedStorage_upvr.CutsceneCamera:Clone()
					clone_10_upvr.Parent = arg1
					clone_10_upvr.Anchored = true
					clone_10_upvr.Position = HumanoidRootPart_upvr.Position + Vector3.new(0, 4, 0)
					clone_10_upvr.CFrame = CFrame.lookAt(clone_10_upvr.Position, v_6_upvr.Torso.Position)
					var3_upvw.applyDebris(clone_10_upvr, 1.5)
					var3_upvw.applyStatus(arg1, "Ultimate", 1.5)
					local var71_upvw
					var71_upvw = var3_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 223
						--[[ Upvalues[3]:
							[1]: clone_10_upvr (readonly)
							[2]: var71_upvw (read and write)
							[3]: v_6_upvr (readonly)
						]]
						if not clone_10_upvr.Parent then
							var71_upvw:Disconnect()
						else
							clone_10_upvr.CFrame = CFrame.lookAt(clone_10_upvr.Position, v_6_upvr.Torso.Position)
						end
					end), module_upvr.Cooldown)
					for _ = 1, 3 do
						for i_9, _ in clone_4:GetChildren() do
							local SOME = clone_4:FindFirstChild(i_9)
							if SOME then
								teleport_upvr(SOME.CFrame)
								Humanoid_upvr.Animator:LoadAnimation(Quick_Steps_upvr.ThrowAnimation):Play(0)
								local clone_6_upvr = Quick_Steps_upvr.Shuriken:Clone()
								clone_6_upvr.Parent = Folder_upvr
								clone_6_upvr.CFrame = SOME.CFrame + SOME.CFrame.LookVector * 0.5
								TweenService_upvr:Create(clone_6_upvr, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
									CFrame = v_6_upvr.HumanoidRootPart.CFrame;
								}):Play()
								var3_upvw.applyDebris(clone_6_upvr, 2)
								local clone_12 = Quick_Steps_upvr.DashSFX:Clone()
								clone_12.Parent = SOME
								clone_12:Play()
								clone_12.PlaybackSpeed += math.random(-2, 2) * 0.1
								task.delay(0.25, function() -- Line 247
									--[[ Upvalues[5]:
										[1]: Quick_Steps_upvr (copied, readonly)
										[2]: v_6_upvr (readonly)
										[3]: var3_upvw (copied, read and write)
										[4]: arg1 (copied, readonly)
										[5]: clone_6_upvr (readonly)
									]]
									local clone_8 = Quick_Steps_upvr.VFX.HitVFX:Clone()
									clone_8.Parent = v_6_upvr.Torso
									var3_upvw.EmitAllDescendants(clone_8)
									for _, v_9 in clone_8:GetChildren() do
										if v_9:IsA("Sound") then
											v_9.PlaybackSpeed += math.random(-3, 3) * 0.1
											v_9:Play()
										end
									end
									var3_upvw.changeFov(arg1, 60, 0.01, 0.1)
									var3_upvw.flashScreen(arg1, Color3.fromRGB(155, 124, 209), 0.2)
									var3_upvw.Blur(arg1, 5, 0.25)
									var3_upvw.blood(v_6_upvr, 2)
									var3_upvw.applyDamage(v_6_upvr, 1, true)
									for _, v_10 in clone_6_upvr:GetDescendants() do
										if v_10:IsA("BasePart") then
											v_10.Transparency = 1
										elseif v_10:IsA("Trail") then
											v_10.Enabled = false
										elseif v_10:IsA("Sound") then
											v_10.PlaybackSpeed += math.random(-3, 3) * 0.06
											v_10:Play()
										end
									end
								end)
								task.wait(0.05)
							end
						end
					end
					teleport_upvr(HumanoidRootPart_upvr.CFrame)
					var3_upvw.applyDebris(clone_upvr, 0)
				else
					var3_upvw.applyStatus(arg1, "Stunned", 1)
					var3_upvw.applyDebris(any_applyStatus_result1_upvr, 0)
				end
			end
		end), module_upvr.Cooldown)
		task.delay(1, function() -- Line 297
			--[[ Upvalues[7]:
				[1]: var53_upvw (read and write)
				[2]: clone_9_upvr (readonly)
				[3]: any_LoadAnimation_result1_upvr (copied, readonly)
				[4]: var55_upvw (read and write)
				[5]: var3_upvw (copied, read and write)
				[6]: arg1 (copied, readonly)
				[7]: clone_upvr (copied, readonly)
			]]
			if var53_upvw then
			else
				for _, v_11 in clone_9_upvr:GetDescendants() do
					if v_11:IsA("Trail") then
						v_11.Enabled = false
					end
				end
				any_LoadAnimation_result1_upvr:Stop(1.5)
				var55_upvw:Disconnect()
				var3_upvw.applyStatus(arg1, "Stunned", 1.5)
				var3_upvw.applyStatus(arg1, "AutoRotate", 1.5)
				var3_upvw.applyDebris(clone_upvr, 0.5)
			end
		end)
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("trail"):Connect(function(arg1_3) -- Line 317
		--[[ Upvalues[1]:
			[1]: CyberKatana_upvr (readonly)
		]]
		if arg1_3 == "true" then
			CyberKatana_upvr.TrailAtt.Trail.Enabled = true
		else
			CyberKatana_upvr.TrailAtt.Trail.Enabled = false
		end
	end), module_upvr.Cooldown)
end
return module_upvr
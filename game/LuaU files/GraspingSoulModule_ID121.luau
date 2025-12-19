-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:03
-- Luau version 6, Types version 3
-- Time taken: 0.027960 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 20
module_upvr.GlobalCD = 1
local var3_upvw
local RunService_upvr = game:GetService("RunService")
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[6]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: RunService_upvr (readonly)
		[5]: TweenService_upvr (readonly)
		[6]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Grasping_Soul_upvr = ReplicatedStorage_upvr.Skills["Soul Lantern"]["Grasping Soul"]
	local any_LoadAnimation_result1_2 = Humanoid_upvr.Animator:LoadAnimation(Grasping_Soul_upvr.Animation)
	any_LoadAnimation_result1_2:Play()
	any_LoadAnimation_result1_2:AdjustSpeed(1)
	var3_upvw.applyStatus(arg1, "Freeze", 1.5)
	var3_upvw.applyStatus(arg1, "GlobalCD", 1.5)
	var3_upvw.changeFov(arg1, 65, 0.25, 5)
	local clone_upvr_2 = Grasping_Soul_upvr.Soul:Clone()
	clone_upvr_2.Parent = Folder_upvr
	clone_upvr_2.Position = arg1:FindFirstChild("Soul Lantern").Vfx.Position + Vector3.new(math.random(-1, 1) * 0.2, math.random(-1, 1) * 0.2, math.random(-1, 1) * 0.2)
	clone_upvr_2.Presence:Play()
	clone_upvr_2.Spawn:Play()
	clone_upvr_2.Anchored = false
	clone_upvr_2:SetNetworkOwner(arg2)
	var3_upvw.applyDebris(clone_upvr_2, 4)
	local BodyPosition_upvr = Instance.new("BodyPosition", clone_upvr_2)
	BodyPosition_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BodyPosition_upvr.Position = arg1["Right Arm"].Position + arg1["Right Arm"].CFrame.LookVector * 1 + arg1["Right Arm"].CFrame.UpVector * -1.5
	BodyPosition_upvr.P += 20000
	local var15_upvw
	var15_upvw = var3_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 54
		--[[ Upvalues[3]:
			[1]: arg1 (readonly)
			[2]: BodyPosition_upvr (readonly)
			[3]: var15_upvw (read and write)
		]]
		if not arg1.Parent or not arg1:FindFirstChild("Right Arm") or not BodyPosition_upvr.Parent then
			var15_upvw:Disconnect()
		else
			BodyPosition_upvr.Position = arg1["Right Arm"].Position + arg1["Right Arm"].CFrame.LookVector * 1 + arg1["Right Arm"].CFrame.UpVector * -1.5 + Vector3.new(math.random(-1, 1) * 1, math.random(-1, 1) * 1, math.random(-1, 1) * 1)
		end
	end), module_upvr.Cooldown)
	var3_upvw.applySound(Grasping_Soul_upvr.WhooshSFX, HumanoidRootPart_upvr, 5)
	any_LoadAnimation_result1_2:GetMarkerReachedSignal("Raise"):Once(function() -- Line 62
		--[[ Upvalues[10]:
			[1]: clone_upvr_2 (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: Grasping_Soul_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: arg1 (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
			[9]: Humanoid_upvr (readonly)
			[10]: PlayerStatus_upvr (copied, readonly)
		]]
		clone_upvr_2.Transparency = 1
		for _, v in clone_upvr_2:GetDescendants() do
			if v:IsA("ParticleEmitter") or v:IsA("Trail") then
				v.Enabled = false
			elseif v:IsA("Sound") and v.Looped then
				v:Stop()
			end
		end
		local any_applyVFX_result1 = var3_upvw.applyVFX(Grasping_Soul_upvr.GraspVFX, Folder_upvr, 5, HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 45 + Vector3.new(0, -3, 0))
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 95, 0.05, 0.25)
		var3_upvw.flashScreen(arg1, Color3.new(0.584314, 1, 1), 0.3)
		var3_upvw.applySound(Grasping_Soul_upvr.RiseSFX, any_applyVFX_result1, 5)
		var3_upvw.applySound(Grasping_Soul_upvr.LiftSFX, HumanoidRootPart_upvr, 5)
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 100, 0.05, 0.4)
		var3_upvw.flashScreen(arg1, Color3.new(0.545098, 1, 0.984314), 0.5)
		for _, v_2_upvr in var3_upvw.findEnemiesPart(any_applyVFX_result1.Hitbox, true), nil do
			local var29 = false
			if (v_2_upvr.Torso.Position - HumanoidRootPart_upvr.Position).Magnitude <= 20 then
				var29 = true
			end
			if not var3_upvw.CheckBlock(v_2_upvr, var29) then
				var3_upvw.unragdoll(v_2_upvr)
				var3_upvw.applyDamage(v_2_upvr, 5, false, true)
				local CFrame_upvr = arg1.HumanoidRootPart.CFrame
				local function Teleport(arg1_2) -- Line 96
					--[[ Upvalues[7]:
						[1]: var3_upvw (copied, read and write)
						[2]: Grasping_Soul_upvr (copied, readonly)
						[3]: Folder_upvr (copied, readonly)
						[4]: CFrame_upvr (readonly)
						[5]: arg1 (copied, readonly)
						[6]: TweenService_upvr (copied, readonly)
						[7]: module_upvr (copied, readonly)
					]]
					var3_upvw.applyStatus(arg1_2, "Stunned", 1.5)
					var3_upvw.applyStatus(arg1_2, "IFrames", 1.5)
					local clone_upvr = Grasping_Soul_upvr.Soul2:Clone()
					clone_upvr.Parent = Folder_upvr
					clone_upvr.CFrame = arg1_2.Torso.CFrame
					var3_upvw.applyDebris(clone_upvr, 3)
					local workspace_Raycast_result1 = workspace:Raycast(arg1_2.HumanoidRootPart.Position, ((CFrame_upvr + CFrame_upvr.LookVector * 100) * CFrame.Angles(0, math.pi, 0)).Position - arg1_2.HumanoidRootPart.Position, var3_upvw.raycastParams)
					local var33_upvw
					if workspace_Raycast_result1 then
						var33_upvw = CFrame.new(workspace_Raycast_result1.Position) * var33_upvw - var33_upvw.p
					end
					if arg1_2 == arg1 then
						var33_upvw = (var33_upvw + CFrame_upvr.LookVector * -5) * CFrame.Angles(0, math.pi, 0)
					end
					clone_upvr.CFrame = CFrame.lookAt(clone_upvr.Position, var33_upvw.Position)
					local any_Create_result1 = TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.5), {
						CFrame = var33_upvw;
					})
					any_Create_result1:Play()
					var3_upvw.applySound(Grasping_Soul_upvr.Travel, arg1_2.Torso)
					local clone_upvr_3 = Grasping_Soul_upvr.TeleportVFX.Att:Clone()
					clone_upvr_3.Parent = arg1_2.Torso
					var3_upvw.applyDebris(clone_upvr_3, 5)
					var3_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 126
						--[[ Upvalues[7]:
							[1]: clone_upvr (readonly)
							[2]: var3_upvw (copied, read and write)
							[3]: arg1 (copied, readonly)
							[4]: clone_upvr_3 (readonly)
							[5]: Grasping_Soul_upvr (copied, readonly)
							[6]: arg1_2 (readonly)
							[7]: var33_upvw (read and write)
						]]
						clone_upvr.Transparency = 1
						for _, v_3 in clone_upvr:GetChildren() do
							if v_3:IsA("ParticleEmitter") or v_3:IsA("Trail") then
								v_3.Enabled = false
							elseif v_3:IsA("Sound") then
								v_3:Stop()
							end
						end
						var3_upvw.changeFov(arg1, 69, 0, 1)
						var3_upvw.camShake(arg1, "SmallBump")
						var3_upvw.EmitAllDescendants(clone_upvr_3)
						var3_upvw.applySound(Grasping_Soul_upvr.Teleport, arg1_2.Torso)
						arg1_2.HumanoidRootPart.CFrame = var33_upvw
					end), module_upvr.Cooldown)
				end
				local tbl_3_upvr = {}
				table.insert(tbl_3_upvr, var3_upvw.applyStatus(arg1, "Stunned", 3.3))
				table.insert(tbl_3_upvr, var3_upvw.applyStatus(arg1, "IFrames", 3.3))
				table.insert(tbl_3_upvr, var3_upvw.applyStatus(arg1, "AutoRotate", 3.3))
				local tbl_2_upvr = {}
				table.insert(tbl_3_upvr, var3_upvw.applyStatus(v_2_upvr, "Stunned", 3.3))
				table.insert(tbl_3_upvr, var3_upvw.applyStatus(v_2_upvr, "IFrames", 3.3))
				table.insert(tbl_2_upvr, var3_upvw.applyStatus(v_2_upvr, "AutoRotate", 3.3))
				Teleport(v_2_upvr)
				Teleport(arg1)
				task.wait(0.6)
				local any_LoadAnimation_result1_3 = Humanoid_upvr.Animator:LoadAnimation(Grasping_Soul_upvr.Animation2)
				any_LoadAnimation_result1_3:Play()
				var3_upvw.conTimer(any_LoadAnimation_result1_3:GetMarkerReachedSignal("Punch"):Connect(function() -- Line 204
					--[[ Upvalues[5]:
						[1]: HumanoidRootPart_upvr (copied, readonly)
						[2]: Grasping_Soul_upvr (copied, readonly)
						[3]: var3_upvw (copied, read and write)
						[4]: v_2_upvr (readonly)
						[5]: arg1 (copied, readonly)
					]]
					local GraspingPunchVFX_4 = HumanoidRootPart_upvr:FindFirstChild("GraspingPunchVFX")
					if not GraspingPunchVFX_4 then
						GraspingPunchVFX_4 = Grasping_Soul_upvr.GraspingPunchVFX:Clone()
					end
					GraspingPunchVFX_4.Parent = HumanoidRootPart_upvr
					GraspingPunchVFX_4.weld.Part0 = HumanoidRootPart_upvr
					GraspingPunchVFX_4.weld.Part1 = GraspingPunchVFX_4
					var3_upvw.EmitAllDescendants(GraspingPunchVFX_4)
					var3_upvw.applyDebris(GraspingPunchVFX_4, 9)
					var3_upvw.applyDamage(v_2_upvr, 5, true, true)
					var3_upvw.camShake(arg1, "Bump")
					var3_upvw.changeFov(arg1, 70, 0.05, 0.25)
					var3_upvw.flashScreen(arg1, Color3.new(0.584314, 1, 1), 0.3)
					local any_applySound_result1_2 = var3_upvw.applySound(Grasping_Soul_upvr.PunchSFX, HumanoidRootPart_upvr, 5)
					any_applySound_result1_2.PlaybackSpeed += math.random(-1, 1) * 0.1
					local any_applySound_result1 = var3_upvw.applySound(Grasping_Soul_upvr.PunchSFX2, HumanoidRootPart_upvr, 5)
					any_applySound_result1.PlaybackSpeed += math.random(-1, 1) * 0.1
					local BodyVelocity_3 = Instance.new("BodyVelocity")
					BodyVelocity_3.MaxForce = Vector3.new(math.huge, 0, math.huge)
					BodyVelocity_3.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 20
					var3_upvw.applyVelocity(HumanoidRootPart_upvr, BodyVelocity_3, 0.3, nil, true, true)
				end), module_upvr.Cooldown)
				local any_applyWeld_result1_upvr = var3_upvw.applyWeld(v_2_upvr, Vector3.new(0, 0, 3), Vector3.new(0, 180, 0), 2.5)
				var3_upvw.conTimer(any_LoadAnimation_result1_3:GetMarkerReachedSignal("Slam"):Connect(function() -- Line 232
					--[[ Upvalues[11]:
						[1]: v_2_upvr (readonly)
						[2]: var3_upvw (copied, read and write)
						[3]: any_applyWeld_result1_upvr (readonly)
						[4]: HumanoidRootPart_upvr (copied, readonly)
						[5]: arg1 (copied, readonly)
						[6]: Grasping_Soul_upvr (copied, readonly)
						[7]: tbl_3_upvr (readonly)
						[8]: tbl_2_upvr (readonly)
						[9]: Humanoid_upvr (copied, readonly)
						[10]: PlayerStatus_upvr (copied, readonly)
						[11]: TweenService_upvr (copied, readonly)
					]]
					if 10 < v_2_upvr.Humanoid.Health then
						var3_upvw.applyDebris(any_applyWeld_result1_upvr, 0)
						task.wait()
						v_2_upvr.HumanoidRootPart.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 3 + Vector3.new(0, -2, 0)) * CFrame.Angles(90, 180, 0)
						local GraspingPunchVFX_3 = HumanoidRootPart_upvr:FindFirstChild("GraspingPunchVFX")
						if GraspingPunchVFX_3 then
							GraspingPunchVFX_3.weld.Enabled = false
							GraspingPunchVFX_3.Anchored = true
						end
						var3_upvw.CreateDebris(v_2_upvr.HumanoidRootPart.Position, 5, 1.2, 0.5, 0.08)
						var3_upvw.crater(1, v_2_upvr.HumanoidRootPart.Position, 3, 0.6)
						var3_upvw.applyStatus(v_2_upvr, "Ragdoll", 2)
						var3_upvw.camShake(arg1, "Bump")
						var3_upvw.changeFov(arg1, 60, 0.05, 0.5)
						var3_upvw.flashScreen(arg1, Color3.new(0.584314, 1, 1), 0.3)
						var3_upvw.applySound(Grasping_Soul_upvr.SlamSFX, v_2_upvr.HumanoidRootPart, 5)
						var3_upvw.applySound(Grasping_Soul_upvr.SlamSFX2, v_2_upvr.HumanoidRootPart, 5)
						var3_upvw.applyStatus(arg1, "Stunned", 0.5)
						var3_upvw.applyStatus(arg1, "AutoRotate", 0.2)
						var3_upvw.applyDamage(v_2_upvr, 5, true, false)
						for _, v_4 in tbl_3_upvr do
							var3_upvw.applyDebris(v_4, 0, arg1)
						end
						for _, v_5 in tbl_2_upvr do
							var3_upvw.applyDebris(v_5, 0, v_2_upvr)
						end
					else
						var3_upvw.applyDebris(any_applyWeld_result1_upvr, 0)
						local GraspingPunchVFX = HumanoidRootPart_upvr:FindFirstChild("GraspingPunchVFX")
						if GraspingPunchVFX then
							GraspingPunchVFX.weld.Enabled = false
							GraspingPunchVFX.Anchored = true
						end
						var3_upvw.CreateDebris(v_2_upvr.HumanoidRootPart.Position, 5, 1.2, 0.5, 0.08)
						var3_upvw.crater(1, v_2_upvr.HumanoidRootPart.Position, 3, 0.6)
						var3_upvw.camShake(arg1, "Bump")
						var3_upvw.changeFov(arg1, 60, 0.05, 0.5)
						var3_upvw.flashScreen(arg1, Color3.new(0.584314, 1, 1), 0.3)
						var3_upvw.applySound(Grasping_Soul_upvr.SlamSFX3, v_2_upvr.HumanoidRootPart, 5)
						var3_upvw.applyDamage(v_2_upvr, 5, true, true)
						for _, v_6 in tbl_3_upvr do
							var3_upvw.applyDebris(v_6, 0, arg1)
						end
						for _, v_7 in tbl_2_upvr do
							var3_upvw.applyDebris(v_7, 0, v_2_upvr)
						end
						var3_upvw.applyStatus(arg1, "Stunned", 3.5)
						var3_upvw.applyStatus(arg1, "AutoRotate", 3.5)
						var3_upvw.applyStatus(arg1, "IFrames", 3.5)
						var3_upvw.applyStatus(v_2_upvr, "Stunned", 3.5)
						var3_upvw.applyStatus(v_2_upvr, "AutoRotate", 3.5)
						var3_upvw.applyStatus(v_2_upvr, "IFrames", 3.5)
						local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Grasping_Soul_upvr.FinishAnimation)
						any_LoadAnimation_result1:Play(0.5)
						v_2_upvr.Humanoid.Animator:LoadAnimation(Grasping_Soul_upvr.FinishAnimationTarget):Play()
						any_LoadAnimation_result1:GetMarkerReachedSignal("Jump"):Once(function() -- Line 317
							--[[ Upvalues[5]:
								[1]: HumanoidRootPart_upvr (copied, readonly)
								[2]: var3_upvw (copied, read and write)
								[3]: Grasping_Soul_upvr (copied, readonly)
								[4]: arg1 (copied, readonly)
								[5]: v_2_upvr (copied, readonly)
							]]
							local BodyVelocity = Instance.new("BodyVelocity")
							BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
							BodyVelocity.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 25
							var3_upvw.applyVelocity(HumanoidRootPart_upvr, BodyVelocity, 0.7, nil, true, true)
							local BodyVelocity_2 = Instance.new("BodyVelocity")
							BodyVelocity_2.MaxForce = Vector3.new(0, 1000000, 0)
							BodyVelocity_2.Velocity = Vector3.new(0, 10, 0)
							var3_upvw.applyVelocity(arg1.Torso, BodyVelocity_2, 0.25, nil, true, true)
							var3_upvw.camShake(arg1, "SmallBump")
							var3_upvw.changeFov(arg1, 100, 0.05, 8)
							var3_upvw.camShake(v_2_upvr, "SmallBump")
							var3_upvw.changeFov(v_2_upvr, 100, 0.05, 8)
						end)
						local any_applyWeld_result1_upvr_2 = var3_upvw.applyWeld(v_2_upvr, Vector3.new(0, 0, 3), Vector3.new(0, 180, 0), 2.5)
						any_LoadAnimation_result1:GetMarkerReachedSignal("Slam"):Once(function() -- Line 337
							--[[ Upvalues[8]:
								[1]: var3_upvw (copied, read and write)
								[2]: any_applyWeld_result1_upvr_2 (readonly)
								[3]: HumanoidRootPart_upvr (copied, readonly)
								[4]: arg1 (copied, readonly)
								[5]: PlayerStatus_upvr (copied, readonly)
								[6]: v_2_upvr (copied, readonly)
								[7]: Grasping_Soul_upvr (copied, readonly)
								[8]: TweenService_upvr (copied, readonly)
							]]
							var3_upvw.applyDebris(any_applyWeld_result1_upvr_2, 0)
							task.wait()
							local BodyVelocity_4 = Instance.new("BodyVelocity")
							BodyVelocity_4.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
							BodyVelocity_4.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 5 + Vector3.new(0, 25, 0)
							var3_upvw.applyVelocity(arg1.Torso, BodyVelocity_4, 0.25, nil, true, true)
							PlayerStatus_upvr.ClearStatus(arg1)
							PlayerStatus_upvr.ClearStatus(v_2_upvr)
							local GraspingPunchVFX_2 = HumanoidRootPart_upvr:FindFirstChild("GraspingPunchVFX")
							if GraspingPunchVFX_2 then
								GraspingPunchVFX_2.weld.Enabled = false
								GraspingPunchVFX_2.Anchored = true
							end
							var3_upvw.CreateDebris(v_2_upvr.HumanoidRootPart.Position, 5, 1.2, 0.5, 0.08)
							var3_upvw.crater(1, v_2_upvr.HumanoidRootPart.Position, 3, 0.6)
							var3_upvw.applyStatus(v_2_upvr, "Ragdoll", 2)
							var3_upvw.camShake(arg1, "Bump")
							var3_upvw.changeFov(arg1, 50, 0.05, 0.5)
							var3_upvw.flashScreen(arg1, Color3.new(0.584314, 1, 1), 0.3)
							var3_upvw.applySound(Grasping_Soul_upvr.SlamSFX, v_2_upvr.HumanoidRootPart, 5)
							var3_upvw.applySound(Grasping_Soul_upvr.SlamSFX2, v_2_upvr.HumanoidRootPart, 5)
							var3_upvw.applyStatus(arg1, "Stunned", 0.9)
							var3_upvw.applyStatus(arg1, "AutoRotate", 0.7)
							var3_upvw.applyDamage(v_2_upvr, v_2_upvr.Humanoid.Health, true, false)
							local var73 = v_2_upvr
							if var73.Humanoid.Health <= 1 and not var73:FindFirstChild("burnVfx") and not var73:GetAttribute("DeathEffect") then
								var73:SetAttribute("DeathEffect", true)
								var73.Humanoid.HealthDisplayType = "AlwaysOff"
								for _, v_8 in var73:GetDescendants() do
									if v_8:IsA("Shirt") or v_8:IsA("Pants") then
										v_8:Destroy()
									else
										local function INLINED() -- Internal function, doesn't exist in bytecode
											TweenService_upvr:Create(v_8, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), tbl):Play()
											tbl.Transparency = 1
											local tbl = {}
											v_8.Color = Color3.new(0.2, 0.988235, 1)
											v_8.Material = "Neon"
											return v_8.Name == "Torso"
										end
										if v_8:IsA("BasePart") and (INLINED() or v_8.Name == "Left Arm" or v_8.Name == "Right Arm" or v_8.Name == "Head" or v_8.Name == "Left Leg" or v_8.Name == "Right Leg") then
											local clone_upvr_4 = Grasping_Soul_upvr.burnVfx:Clone()
											clone_upvr_4.Parent = v_8
											clone_upvr_4.Enabled = true
											task.delay(2, function() -- Line 393
												--[[ Upvalues[1]:
													[1]: clone_upvr_4 (readonly)
												]]
												clone_upvr_4.Enabled = false
											end)
										end
									end
								end
							end
						end)
					end
				end), module_upvr.Cooldown)
				return
			end
		end
	end)
	any_LoadAnimation_result1_2.Stopped:Once(function() -- Line 410
		--[[ Upvalues[2]:
			[1]: var3_upvw (copied, read and write)
			[2]: clone_upvr_2 (readonly)
		]]
		var3_upvw.applyDebris(clone_upvr_2, 0)
	end)
end
return module_upvr
-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:59
-- Luau version 6, Types version 3
-- Time taken: 0.087768 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 80
module_upvr.GlobalCD = 0.1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 19
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 10)
	local HumanoidRootPart_3_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Consume_upvr = ReplicatedStorage_upvr.Skills["Soul Lantern"].Ultimate:FindFirstChild("Consume")
	local function DeathEffects_upvr(arg1_2) -- Line 33, Named "DeathEffects"
		--[[ Upvalues[2]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: Consume_upvr (readonly)
		]]
		if arg1_2.Humanoid.Health <= 1 and not arg1_2:FindFirstChild("burnVfx") and not arg1_2:GetAttribute("DeathEffect") then
			arg1_2:SetAttribute("DeathEffect", true)
			arg1_2.Humanoid.HealthDisplayType = "AlwaysOff"
			for _, v in arg1_2:GetDescendants() do
				if v:IsA("Shirt") or v:IsA("Pants") then
					v:Destroy()
				else
					local function INLINED() -- Internal function, doesn't exist in bytecode
						TweenService_upvr:Create(v, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), tbl_4):Play()
						tbl_4.Transparency = 1
						tbl_4.Color = Color3.new(0, 0, 0)
						local tbl_4 = {}
						v.Color = Color3.new(1, 0.172549, 0.172549)
						v.Material = "Neon"
						return v.Name == "Torso"
					end
					if v:IsA("BasePart") and (INLINED() or v.Name == "Left Arm" or v.Name == "Right Arm" or v.Name == "Head" or v.Name == "Left Leg" or v.Name == "Right Leg") then
						local clone_6_upvr = Consume_upvr.burnVfx:Clone()
						clone_6_upvr.Parent = v
						clone_6_upvr.Enabled = true
						task.delay(2, function() -- Line 52
							--[[ Upvalues[1]:
								[1]: clone_6_upvr (readonly)
							]]
							clone_6_upvr.Enabled = false
						end)
					end
				end
			end
		end
	end
	local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Consume_upvr.LiftAnimation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(0.7)
	var3_upvw.applyStatus(arg1, "Stunned", 0.7)
	var3_upvw.changeFov(arg1, 60, 0.3, 5)
	var3_upvw.applySound(Consume_upvr.MagicCharge, HumanoidRootPart_3_upvr, 5)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("snap"):Connect(function() -- Line 71
		--[[ Upvalues[9]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Consume_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_3_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
			[7]: Humanoid_upvr (readonly)
			[8]: PlayerStatus_upvr (copied, readonly)
			[9]: DeathEffects_upvr (readonly)
		]]
		var3_upvw.changeFov(arg1, 120, 0, 1)
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.flashScreen(arg1, Color3.new(1, 0.1, 0.1), 0.7)
		local clone_upvr = Consume_upvr.Projectile:Clone()
		clone_upvr.Parent = Folder_upvr
		clone_upvr.CFrame = HumanoidRootPart_3_upvr.CFrame + HumanoidRootPart_3_upvr.CFrame.LookVector * 10
		TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {
			CFrame = clone_upvr.CFrame + clone_upvr.CFrame.LookVector * 240;
		}):Play()
		var3_upvw.applyStatus(arg1, "Stunned", 0.8)
		var3_upvw.applySound(Consume_upvr.Explosion1, HumanoidRootPart_3_upvr, 5)
		var3_upvw.applySound(Consume_upvr.Explosion2, HumanoidRootPart_3_upvr, 5)
		var3_upvw.applySound(Consume_upvr.ProjectileSFX, clone_upvr, 5)
		var3_upvw.applySound(Consume_upvr.Projectile2, clone_upvr, 5)
		var3_upvw.applySound(Consume_upvr.Explosion3, clone_upvr, 5)
		local var28_upvw
		local tbl_7_upvr = {}
		for _ = 1, 25 do
			task.spawn(function() -- Line 91
				--[[ Upvalues[12]:
					[1]: var3_upvw (copied, read and write)
					[2]: clone_upvr (readonly)
					[3]: tbl_7_upvr (readonly)
					[4]: var28_upvw (read and write)
					[5]: arg1 (copied, readonly)
					[6]: HumanoidRootPart_3_upvr (copied, readonly)
					[7]: TweenService_upvr (copied, readonly)
					[8]: Consume_upvr (copied, readonly)
					[9]: Humanoid_upvr (copied, readonly)
					[10]: PlayerStatus_upvr (copied, readonly)
					[11]: Folder_upvr (copied, readonly)
					[12]: DeathEffects_upvr (copied, readonly)
				]]
				for _, v_2 in var3_upvw.findEnemiesPart(clone_upvr.Hitbox, true), nil do
					if not table.find(tbl_7_upvr, v_2) then
						table.insert(tbl_7_upvr, v_2)
						if not var3_upvw.CheckBlock(v_2) then
							var3_upvw.unragdoll(v_2)
							if not var28_upvw then
								var28_upvw = v_2
								var3_upvw.applyDamage(var28_upvw, 20, true, true)
								var3_upvw.applyStatus(arg1, "Stunned", 3.6)
								var3_upvw.applyStatus(arg1, "AutoRotate", 3.6)
								var3_upvw.applyStatus(arg1, "IFrames", 3.6)
								var3_upvw.applyStatus(var28_upvw, "Stunned", 3.6)
								var3_upvw.applyStatus(var28_upvw, "AutoRotate", 3.6)
								var3_upvw.applyStatus(var28_upvw, "IFrames", 3.6)
								local BodyVelocity_4 = Instance.new("BodyVelocity", var28_upvw.Torso)
								BodyVelocity_4.MaxForce = Vector3.new(1000000, 1000000, 1000000)
								BodyVelocity_4.Velocity = Vector3.new(0, 0, 0)
								var3_upvw.applyDebris(BodyVelocity_4, 4)
								var28_upvw.HumanoidRootPart.CFrame = CFrame.new(var28_upvw.HumanoidRootPart.Position) * HumanoidRootPart_3_upvr.CFrame - HumanoidRootPart_3_upvr.CFrame.p
								local any_Create_result1_2 = TweenService_upvr:Create(var28_upvw.HumanoidRootPart, TweenInfo.new(1), {
									CFrame = var28_upvw.HumanoidRootPart.CFrame + Vector3.new(0, 50, 0);
								})
								any_Create_result1_2:Play()
								task.wait(0.75)
								var3_upvw.applySound(Consume_upvr.TeleportSFX, HumanoidRootPart_3_upvr, 5)
								local BodyVelocity_3 = Instance.new("BodyVelocity", arg1.Torso)
								BodyVelocity_3.MaxForce = Vector3.new(1000000, 1000000, 1000000)
								BodyVelocity_3.Velocity = Vector3.new(0, 0, 0)
								var3_upvw.applyDebris(BodyVelocity_3, 2.6)
								HumanoidRootPart_3_upvr.CFrame = (var28_upvw.HumanoidRootPart.CFrame + var28_upvw.HumanoidRootPart.CFrame.LookVector * 4.18) * CFrame.Angles(0, math.pi, 0)
								local var169_upvw
								var3_upvw.conTimer(any_Create_result1_2.Completed:Once(function() -- Line 136
									--[[ Upvalues[3]:
										[1]: var169_upvw (read and write)
										[2]: var3_upvw (copied, read and write)
										[3]: var28_upvw (copied, read and write)
									]]
									var169_upvw = var3_upvw.applyWeld(var28_upvw, Vector3.new(0, 0, 4.17999), Vector3.new(0, 180, 0), 2.6)
								end), 5)
								local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Consume_upvr.Animation)
								any_LoadAnimation_result1_upvr:Play()
								local any_LoadAnimation_result1_upvr_2 = var28_upvw.Humanoid.Animator:LoadAnimation(Consume_upvr.AnimationTarget)
								any_LoadAnimation_result1_upvr_2:Play()
								var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Grab"):Once(function() -- Line 146
									--[[ Upvalues[4]:
										[1]: var3_upvw (copied, read and write)
										[2]: var28_upvw (copied, read and write)
										[3]: Consume_upvr (copied, readonly)
										[4]: HumanoidRootPart_3_upvr (copied, readonly)
									]]
									var3_upvw.applyDamage(var28_upvw, 5, true, true)
									var3_upvw.applySound(Consume_upvr.GrabSFX, HumanoidRootPart_3_upvr, 5)
									var3_upvw.applySound(Consume_upvr.ThrowCharge, HumanoidRootPart_3_upvr, 5)
								end), 5)
								var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Throw"):Once(function() -- Line 152
									--[[ Upvalues[12]:
										[1]: var169_upvw (read and write)
										[2]: var3_upvw (copied, read and write)
										[3]: var28_upvw (copied, read and write)
										[4]: Consume_upvr (copied, readonly)
										[5]: HumanoidRootPart_3_upvr (copied, readonly)
										[6]: any_LoadAnimation_result1_upvr_2 (readonly)
										[7]: TweenService_upvr (copied, readonly)
										[8]: arg1 (copied, readonly)
										[9]: PlayerStatus_upvr (copied, readonly)
										[10]: any_LoadAnimation_result1_upvr (readonly)
										[11]: Folder_upvr (copied, readonly)
										[12]: DeathEffects_upvr (copied, readonly)
									]]
									var169_upvw:Destroy()
									var3_upvw.applyDamage(var28_upvw, 5, true, true)
									var3_upvw.applySound(Consume_upvr.ThrowSFX, HumanoidRootPart_3_upvr, 5)
									local var175_upvw = HumanoidRootPart_3_upvr.Position + HumanoidRootPart_3_upvr.CFrame.LookVector * -200 + Vector3.new(0, -70, 0)
									local workspace_Raycast_result1_2 = workspace:Raycast(HumanoidRootPart_3_upvr.Position, HumanoidRootPart_3_upvr.CFrame.LookVector * -200 + Vector3.new(0, -70, 0), var3_upvw.raycastParams)
									if workspace_Raycast_result1_2 then
										var175_upvw = workspace_Raycast_result1_2.Position
										print(workspace_Raycast_result1_2)
									end
									var28_upvw.HumanoidRootPart.CFrame = CFrame.lookAt(var28_upvw.HumanoidRootPart.Position, var175_upvw)
									local HumanoidRootPart = var28_upvw.HumanoidRootPart
									HumanoidRootPart.CFrame *= CFrame.Angles((-math.pi/2), 0, 0)
									any_LoadAnimation_result1_upvr_2:Stop(0)
									local any_Create_result1_6 = TweenService_upvr:Create(var28_upvw.HumanoidRootPart, TweenInfo.new(0.1 + (var175_upvw - var28_upvw.HumanoidRootPart.Position).Magnitude * 0.004), {
										CFrame = CFrame.new(var175_upvw) * var28_upvw.HumanoidRootPart.CFrame - var28_upvw.HumanoidRootPart.CFrame.p;
									})
									any_Create_result1_6:Play()
									var3_upvw.changeFov(arg1, 75, 0, 0.5)
									var3_upvw.camShake(arg1, "SmallBump")
									var3_upvw.changeFov(var28_upvw, 75, 0, 0.5)
									var3_upvw.camShake(var28_upvw, "SmallBump")
									var3_upvw.conTimer(any_Create_result1_6.Completed:Once(function() -- Line 175
										--[[ Upvalues[5]:
											[1]: var3_upvw (copied, read and write)
											[2]: var28_upvw (copied, read and write)
											[3]: PlayerStatus_upvr (copied, readonly)
											[4]: arg1 (copied, readonly)
											[5]: var175_upvw (read and write)
										]]
										var3_upvw.applyDamage(var28_upvw, 10, true, true)
										PlayerStatus_upvr.ClearStatus(var28_upvw)
										var3_upvw.changeFov(arg1, 75, 0, 0.15)
										var3_upvw.camShake(arg1, "Bump")
										var3_upvw.changeFov(var28_upvw, 75, 0, 0.15)
										var3_upvw.camShake(var28_upvw, "Bump")
										var3_upvw.crater(1, var175_upvw + Vector3.new(0, 1, 0), 3, 1.2)
										var3_upvw.CreateDebris(var175_upvw, 5, 0.5, 0.65, 0.2)
										var3_upvw.applyStatus(var28_upvw, "Ragdoll", 2.6)
									end), 5)
									any_LoadAnimation_result1_upvr:AdjustSpeed(0.8)
									local clone_8_upvr = Consume_upvr.GiantBall:Clone()
									clone_8_upvr.Parent = Folder_upvr
									clone_8_upvr.CFrame = HumanoidRootPart_3_upvr.CFrame + Vector3.new(0, 50, 0)
									var3_upvw.applyDebris(clone_8_upvr, 5)
									var3_upvw.applySound(Consume_upvr.BombCharge, clone_8_upvr, 5)
									var3_upvw.applySound(Consume_upvr.BombCharge2, clone_8_upvr, 5)
									var3_upvw.changeFov(arg1, 120, 0, 4)
									var3_upvw.camShake(arg1, "SmallBump")
									var3_upvw.flashScreen(arg1, Color3.new(1, 0.1, 0.1), 0.5)
									var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Bomb"):Once(function() -- Line 205
										--[[ Upvalues[8]:
											[1]: TweenService_upvr (copied, readonly)
											[2]: clone_8_upvr (readonly)
											[3]: var175_upvw (read and write)
											[4]: var3_upvw (copied, read and write)
											[5]: arg1 (copied, readonly)
											[6]: Consume_upvr (copied, readonly)
											[7]: Folder_upvr (copied, readonly)
											[8]: DeathEffects_upvr (copied, readonly)
										]]
										local any_Create_result1_5 = TweenService_upvr:Create(clone_8_upvr, TweenInfo.new(0.1 + (var175_upvw - clone_8_upvr.Position).Magnitude * 0.004, Enum.EasingStyle.Linear), {
											CFrame = CFrame.new(var175_upvw) * clone_8_upvr.CFrame - clone_8_upvr.CFrame.p;
										})
										any_Create_result1_5:Play()
										var3_upvw.changeFov(arg1, 90, 0, 2)
										var3_upvw.camShake(arg1, "SmallBump")
										var3_upvw.flashScreen(arg1, Color3.new(1, 0.1, 0.1), 0.4)
										var3_upvw.applySound(Consume_upvr.BombThrow, clone_8_upvr, 5)
										var3_upvw.applySound(Consume_upvr.BombThrow2, clone_8_upvr, 5)
										var3_upvw.applySound(Consume_upvr.BombThrow3, clone_8_upvr, 5)
										var3_upvw.conTimer(any_Create_result1_5.Completed:Once(function() -- Line 217
											--[[ Upvalues[7]:
												[1]: clone_8_upvr (copied, readonly)
												[2]: var3_upvw (copied, read and write)
												[3]: Consume_upvr (copied, readonly)
												[4]: Folder_upvr (copied, readonly)
												[5]: arg1 (copied, readonly)
												[6]: DeathEffects_upvr (copied, readonly)
												[7]: TweenService_upvr (copied, readonly)
											]]
											-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
											for _, v_3 in clone_8_upvr:GetDescendants() do
												if v_3:IsA("ParticleEmitter") then
													v_3.Enabled = false
												end
											end
											local any_applyVFX_result1_upvr = var3_upvw.applyVFX(Consume_upvr.BallExplosion, Folder_upvr, 5, clone_8_upvr.CFrame)
											var3_upvw.changeFov(arg1, 55, 0, 2)
											var3_upvw.camShake(arg1, "Bump")
											var3_upvw.flashScreen(arg1, Color3.new(1, 0.1, 0.1), 0.75)
											var3_upvw.applySound(Consume_upvr.BombExplosion, any_applyVFX_result1_upvr, 5)
											var3_upvw.applySound(Consume_upvr.BombExplosion2, any_applyVFX_result1_upvr, 5)
											var3_upvw.applySound(Consume_upvr.BombExplosion3, any_applyVFX_result1_upvr, 5)
											for _, v_4_upvr in var3_upvw.findEnemiesMagnitude(any_applyVFX_result1_upvr.Position, 200, true), nil do
												task.spawn(function() -- Line 235
													--[[ Upvalues[2]:
														[1]: var3_upvw (copied, read and write)
														[2]: v_4_upvr (readonly)
													]]
													var3_upvw.changeFov(v_4_upvr, 55, 0, 2)
													var3_upvw.camShake(v_4_upvr, "SmallBump")
													var3_upvw.flashScreen(v_4_upvr, Color3.new(1, 0.1, 0.1), 0.5)
												end)
											end
											task.spawn(function() -- Line 242
												--[[ Upvalues[2]:
													[1]: var3_upvw (copied, read and write)
													[2]: any_applyVFX_result1_upvr (readonly)
												]]
												for _ = 1, 10 do
													for _, v_5 in var3_upvw.findEnemiesPart(any_applyVFX_result1_upvr.Hitbox, true), nil do
														var3_upvw.applyDamage(v_5, 2)
														var3_upvw.applyStatus(v_5, "Ragdoll", 1)
														var3_upvw.applyStatus(v_5, "DashDB", 1)
													end
													wait(0.1)
												end
											end)
											task.wait(1)
											var3_upvw.applySound(Consume_upvr.Blast, any_applyVFX_result1_upvr, 5)
											var3_upvw.applySound(Consume_upvr.Blast3, any_applyVFX_result1_upvr, 5)
											task.spawn(function() -- Line 259
												--[[ Upvalues[2]:
													[1]: var3_upvw (copied, read and write)
													[2]: arg1 (copied, readonly)
												]]
												for _ = 1, 3 do
													var3_upvw.changeFov(arg1, 150, 0, 0.5)
													var3_upvw.camShake(arg1, "Explosion")
													var3_upvw.flashScreen(arg1, Color3.new(1, 0.294118, 0.294118), 0.2)
													wait(0.1)
												end
											end)
											for _, v_6_upvr in var3_upvw.findEnemiesMagnitude(any_applyVFX_result1_upvr.Position, 200, true), nil do
												task.spawn(function() -- Line 270
													--[[ Upvalues[2]:
														[1]: var3_upvw (copied, read and write)
														[2]: v_6_upvr (readonly)
													]]
													for _ = 1, 3 do
														var3_upvw.changeFov(v_6_upvr, 150, 0, 0.5)
														var3_upvw.camShake(v_6_upvr, "Explosion")
														var3_upvw.flashScreen(v_6_upvr, Color3.new(1, 0.294118, 0.294118), 0.2)
														wait(0.1)
													end
												end)
											end
											for _, v_7 in var3_upvw.findEnemiesPart(any_applyVFX_result1_upvr.Hitbox2, true), nil do
												var3_upvw.applyDamage(v_7, 50)
												var3_upvw.applyStatus(v_7, "Ragdoll", 2.5)
												var3_upvw.Knockback(v_7, any_applyVFX_result1_upvr.Position, 25, 120)
												DeathEffects_upvr(v_7)
												local var243_upvr
											end
											for i_12, var248 in var243_upvr:GetChildren() do
												if var248.Name == "Geyser" then
													local any_applySound_result1_2 = var3_upvw.applySound(Consume_upvr.Blast2, var248, 5)
													any_applySound_result1_2.PlaybackSpeed += math.random(-1, 1) * 0.1
												end
											end
											for _ = 1, 2 do
												i_12 = task.spawn
												function var248() -- Line 296
													--[[ Upvalues[5]:
														[1]: Consume_upvr (copied, readonly)
														[2]: Folder_upvr (copied, readonly)
														[3]: var3_upvw (copied, read and write)
														[4]: var243_upvr (readonly)
														[5]: TweenService_upvr (copied, readonly)
													]]
													for _ = 1, 12 do
														local clone_7 = Consume_upvr.Geyser:Clone()
														clone_7.Parent = Folder_upvr
														var3_upvw.applyDebris(clone_7, 5)
														local function _(arg1_5, arg2_4) -- Line 302, Named "GetRandom"
															local randint_8 = math.random(arg1_5, arg2_4)
															if randint_8 == 0 then
																randint_8 = 1
															end
															return randint_8
														end
														local randint = math.random(-8, 8)
														if randint == 0 then
															randint = 1
														end
														local randint_5 = math.random(-8, 8)
														if randint_5 == 0 then
															randint_5 = 1
														end
														clone_7.CFrame = CFrame.new(var243_upvr.Position + Vector3.new(randint * 20, -3, randint_5 * 20)) * clone_7.CFrame - clone_7.CFrame.p
														var3_upvw.EmitAllDescendants(clone_7)
														var3_upvw.CreateDebris(clone_7.Position + Vector3.new(0, 1, 0), 5, 1.5, 1.25, 0.08)
														var3_upvw.crater(1, clone_7.Position + Vector3.new(0, 1, 0), 4, 1.8)
														local Rocks_2 = clone_7.Rocks
														Rocks_2.PlaybackSpeed += math.random(-1, 1) * 0.1
														clone_7.Rocks:Play()
														local Magic = clone_7.Magic
														Magic.PlaybackSpeed += math.random(-1, 1) * 0.1
														clone_7.Magic:Play()
														for _, v_9 in var3_upvw.findEnemiesPart(clone_7.Hitbox, true), nil do
															if not var3_upvw.CheckBlock(v_9, true) then
																var3_upvw.applyDamage(v_9, 10)
																var3_upvw.applyStatus(v_9, "Ragdoll", 3)
																var3_upvw.Knockback(v_9, clone_7.Position, 22, 92)
																var3_upvw.camShake(v_9, "Explosion")
																var3_upvw.impactFrame(v_9)
																if v_9.Humanoid.Health <= 1 and not v_9:FindFirstChild("burnVfx") then
																	v_9.Humanoid.HealthDisplayType = "AlwaysOff"
																	for _, v_10 in v_9:GetDescendants() do
																		if v_10:IsA("Shirt") or v_10:IsA("Pants") then
																			v_10:Destroy()
																		else
																			local function INLINED_4() -- Internal function, doesn't exist in bytecode
																				TweenService_upvr:Create(v_10, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), tbl_2):Play()
																				tbl_2.Transparency = 1
																				local tbl_2 = {}
																				v_10.Color = Color3.new(1, 0.207843, 0.207843)
																				v_10.Material = "Neon"
																				return v_10.Name == "Torso"
																			end
																			if v_10:IsA("BasePart") and (INLINED_4() or v_10.Name == "Left Arm" or v_10.Name == "Right Arm" or v_10.Name == "Head" or v_10.Name == "Left Leg" or v_10.Name == "Right Leg") then
																				local clone_5_upvr = Consume_upvr.burnVfx:Clone()
																				clone_5_upvr.Parent = v_10
																				clone_5_upvr.Enabled = true
																				task.delay(2, function() -- Line 347
																					--[[ Upvalues[1]:
																						[1]: clone_5_upvr (readonly)
																					]]
																					clone_5_upvr.Enabled = false
																				end)
																			end
																		end
																	end
																end
															end
														end
														wait(0.25)
													end
												end
												i_12(var248)
												local _
											end
										end), 5)
									end), 2)
								end), 3)
								var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Once(function() -- Line 368
									--[[ Upvalues[3]:
										[1]: arg1 (copied, readonly)
										[2]: any_LoadAnimation_result1_upvr (readonly)
										[3]: HumanoidRootPart_3_upvr (copied, readonly)
									]]
									any_LoadAnimation_result1_upvr:Stop(0)
									HumanoidRootPart_3_upvr.CFrame = (CFrame.new(arg1.Torso.Position) * HumanoidRootPart_3_upvr.CFrame - HumanoidRootPart_3_upvr.CFrame.p) * CFrame.Angles(0, 180, 0)
								end), 3)
							else
								var3_upvw.Knockback(v_2, clone_upvr.Position, 10, 75)
								var3_upvw.applyStatus(v_2, "Ragdoll", 2.6)
								var3_upvw.applyDamage(v_2, 40)
							end
						end
					end
				end
			end)
			wait(0.03)
		end
		for _, v_11 in clone_upvr:GetDescendants() do
			if v_11:IsA("ParticleEmitter") then
				v_11.Enabled = false
			elseif v_11:IsA("Sound") then
				v_11:Stop()
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr
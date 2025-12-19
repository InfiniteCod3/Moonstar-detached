-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:39
-- Luau version 6, Types version 3
-- Time taken: 0.025632 seconds

local module_upvr = {
	Cooldown = 21;
	GlobalCD = 0.8;
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
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Powerful_Strike_upvr = ReplicatedStorage_upvr.Skills.Greatsword["Powerful Strike"]
	local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Powerful_Strike_upvr.DashAnimation)
	any_LoadAnimation_result1_upvr:Play(0.0001)
	var2_upvw.applyStatus(arg1, "Freeze", 0.8)
	var2_upvw.applyStatus(arg1, "HyperArmor", 0.8)
	var2_upvw.camShake(arg1, "Bump")
	var2_upvw.flashScreen(arg1, Color3.new(0.772549, 0.772549, 0.772549), 0.3)
	var2_upvw.changeFov(arg1, 90, 0.7, 5)
	local clone_7_upvr = Powerful_Strike_upvr.vfx.Dash:Clone()
	clone_7_upvr.Parent = HumanoidRootPart_upvr
	clone_7_upvr:Play()
	game.Debris:AddItem(clone_7_upvr, 0.8)
	clone_7_upvr.Volume = 0
	TweenService_upvr:Create(clone_7_upvr, TweenInfo.new(0.12), {
		Volume = 5;
	}):Play()
	local clone_5 = Powerful_Strike_upvr.vfx.Dash2:Clone()
	clone_5.Parent = HumanoidRootPart_upvr
	clone_5:Play()
	game.Debris:AddItem(clone_5, 5)
	local var15_upvw
	local Greatsword_upvr = arg1:FindFirstChild("Greatsword")
	var15_upvw = ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 54
		--[[ Upvalues[13]:
			[1]: arg2 (readonly)
			[2]: var15_upvw (read and write)
			[3]: any_LoadAnimation_result1_upvr (readonly)
			[4]: clone_7_upvr (readonly)
			[5]: var2_upvw (copied, read and write)
			[6]: arg1 (readonly)
			[7]: Humanoid_upvr (readonly)
			[8]: Powerful_Strike_upvr (readonly)
			[9]: HumanoidRootPart_upvr (readonly)
			[10]: Greatsword_upvr (readonly)
			[11]: Folder_upvr (readonly)
			[12]: TweenService_upvr (copied, readonly)
			[13]: RunService_upvr (copied, readonly)
		]]
		if arg2 == arg1_2 and arg2_2 == "Powerful Strike" then
			var15_upvw:Disconnect()
			any_LoadAnimation_result1_upvr:Stop(0.0001)
			clone_7_upvr:Stop()
			var2_upvw.applyStatus(arg1, "AutoRotate", 0.8)
			var2_upvw.applyStatus(arg1, "Freeze", 0.8)
			var2_upvw.applyStatus(arg1, "HyperArmor", 0.5)
			var2_upvw.applyStatus(arg1, "GlobalCD", 0.8)
			local any_LoadAnimation_result1_upvr_2 = Humanoid_upvr.Animator:LoadAnimation(Powerful_Strike_upvr.StrikeAnimation)
			any_LoadAnimation_result1_upvr_2:Play(0.0001)
			any_LoadAnimation_result1_upvr_2:AdjustSpeed(0.25)
			task.spawn(function() -- Line 71
				--[[ Upvalues[1]:
					[1]: any_LoadAnimation_result1_upvr_2 (readonly)
				]]
				for i = 1, 7 do
					any_LoadAnimation_result1_upvr_2:AdjustSpeed(0.25 + i * 0.1)
					task.wait()
				end
			end)
			local clone_3_upvr = Powerful_Strike_upvr.vfx.HugeShockwave:Clone()
			clone_3_upvr.Parent = HumanoidRootPart_upvr
			game.Debris:AddItem(clone_3_upvr, 10)
			local clone_4_upvr = Powerful_Strike_upvr.vfx.Shockwave:Clone()
			clone_4_upvr.Parent = HumanoidRootPart_upvr
			game.Debris:AddItem(clone_4_upvr, 10)
			clone_4_upvr.Whoosh:Play()
			clone_4_upvr.BodyPrepare:Play()
			any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("strike"):Connect(function() -- Line 89
				--[[ Upvalues[6]:
					[1]: var2_upvw (copied, read and write)
					[2]: arg1 (copied, readonly)
					[3]: clone_4_upvr (readonly)
					[4]: HumanoidRootPart_upvr (copied, readonly)
					[5]: clone_3_upvr (readonly)
					[6]: Powerful_Strike_upvr (copied, readonly)
				]]
				var2_upvw.camShake(arg1, "BigBump")
				var2_upvw.flashScreen(arg1, Color3.new(0.584314, 0.584314, 0.584314), 0.45)
				var2_upvw.changeFov(arg1, 45, 0.01, 2)
				var2_upvw.impactFrame2(arg1)
				task.delay(0.1, function() -- Line 95
					--[[ Upvalues[2]:
						[1]: var2_upvw (copied, read and write)
						[2]: clone_4_upvr (copied, readonly)
					]]
					var2_upvw.EmitAllDescendants(clone_4_upvr)
				end)
				clone_4_upvr.slash:Play()
				clone_4_upvr.Shockwave:Play()
				clone_4_upvr.CoreShockwave:Play()
				clone_4_upvr.hitSFX:Play()
				for _, v in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 8.5, 15), nil do
					var2_upvw.applyDamage(v, 15)
					var2_upvw.applyStatus(v, "Ragdoll", 1.6)
					if v.Humanoid.Health <= 1 then
						for _, v_2 in clone_4_upvr:GetChildren() do
							if v_2:IsA("ParticleEmitter") then
								v_2:Destroy()
							end
						end
						task.delay(0.1, function() -- Line 118
							--[[ Upvalues[2]:
								[1]: var2_upvw (copied, read and write)
								[2]: clone_3_upvr (copied, readonly)
							]]
							var2_upvw.EmitAllDescendants(clone_3_upvr)
							for _, v_3 in clone_3_upvr:GetChildren() do
								v_3:SetAttribute("EmitCount", 0)
							end
						end)
						clone_3_upvr.hitSFX:Play()
						clone_4_upvr.Shockwave.Volume = 7.5
						clone_4_upvr.Shockwave.PlaybackSpeed = 0.5
						var2_upvw.changeFov(arg1, 40, 0.01, 1.5)
						var2_upvw.Knockback(v, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -50, 400, 100)
						local clone_13 = Powerful_Strike_upvr.vfx.Att1:Clone()
						clone_13.Parent = v.Torso
						local clone_10 = Powerful_Strike_upvr.vfx.Att2:Clone()
						clone_10.Parent = v.Torso
						clone_13.Trail.Attachment1 = clone_13
						clone_13.Trail.Attachment0 = clone_10
						clone_13.Trail.Enabled = true
					else
						var2_upvw.Knockback(v, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -100, 90)
					end
					var2_upvw.camShake(v, "BigBump")
					var2_upvw.flashScreen(v, Color3.new(0.658824, 0.658824, 0.658824), 0.5)
					var2_upvw.changeFov(v, 45, 0.01, 1.5)
					var2_upvw.impactFrame2(v)
				end
			end)
		else
			any_LoadAnimation_result1_upvr_2 = arg2
			if any_LoadAnimation_result1_upvr_2 == arg1_2 and arg2_2 == "Powerful Strike v2" then
				any_LoadAnimation_result1_upvr_2 = var15_upvw:Disconnect
				any_LoadAnimation_result1_upvr_2()
				any_LoadAnimation_result1_upvr_2 = any_LoadAnimation_result1_upvr
				clone_4_upvr = 0.0001
				any_LoadAnimation_result1_upvr_2 = any_LoadAnimation_result1_upvr_2:Stop
				any_LoadAnimation_result1_upvr_2(clone_4_upvr)
				any_LoadAnimation_result1_upvr_2 = clone_7_upvr:Stop
				any_LoadAnimation_result1_upvr_2()
				clone_3_upvr = var2_upvw
				any_LoadAnimation_result1_upvr_2 = clone_3_upvr.applyStatus
				clone_3_upvr = arg1
				clone_4_upvr = "AutoRotate"
				any_LoadAnimation_result1_upvr_2(clone_3_upvr, clone_4_upvr, 0.8)
				clone_3_upvr = var2_upvw
				any_LoadAnimation_result1_upvr_2 = clone_3_upvr.applyStatus
				clone_3_upvr = arg1
				clone_4_upvr = "Freeze"
				any_LoadAnimation_result1_upvr_2(clone_3_upvr, clone_4_upvr, 0.8)
				clone_3_upvr = var2_upvw
				any_LoadAnimation_result1_upvr_2 = clone_3_upvr.applyStatus
				clone_3_upvr = arg1
				clone_4_upvr = "HyperArmor"
				any_LoadAnimation_result1_upvr_2(clone_3_upvr, clone_4_upvr, 0.5)
				clone_3_upvr = var2_upvw
				any_LoadAnimation_result1_upvr_2 = clone_3_upvr.applyStatus
				clone_3_upvr = arg1
				clone_4_upvr = "GlobalCD"
				any_LoadAnimation_result1_upvr_2(clone_3_upvr, clone_4_upvr, 0.8)
				clone_3_upvr = Greatsword_upvr
				any_LoadAnimation_result1_upvr_2 = clone_3_upvr.FireVfx:GetChildren()
				local children_3, NONE_2, NONE_8 = clone_3_upvr.FireVfx:GetChildren()
				for _, v_4 in children_3, NONE_2, NONE_8 do
					v_4.Enabled = true
				end
				NONE_2 = Humanoid_upvr
				children_3 = NONE_2.Animator
				NONE_8 = Powerful_Strike_upvr.StrikeAnimation
				children_3 = children_3:LoadAnimation(NONE_8)
				local var44 = children_3
				NONE_2 = var44:Play
				NONE_2(0.0001)
				NONE_2 = var44:AdjustSpeed
				NONE_2(0.75)
				NONE_2 = var44:GetMarkerReachedSignal("strike")
				NONE_2 = NONE_2:Connect
				NONE_2(function() -- Line 169
					--[[ Upvalues[8]:
						[1]: var2_upvw (copied, read and write)
						[2]: arg1 (copied, readonly)
						[3]: Powerful_Strike_upvr (copied, readonly)
						[4]: Folder_upvr (copied, readonly)
						[5]: HumanoidRootPart_upvr (copied, readonly)
						[6]: TweenService_upvr (copied, readonly)
						[7]: RunService_upvr (copied, readonly)
						[8]: Greatsword_upvr (copied, readonly)
					]]
					var2_upvw.camShake(arg1, "BigBump")
					var2_upvw.flashScreen(arg1, Color3.new(1, 0.729412, 0.458824), 0.45)
					var2_upvw.changeFov(arg1, 60, 0.01, 1.5)
					local clone_9 = Powerful_Strike_upvr.SlashEmit:Clone()
					clone_9.Parent = Folder_upvr
					clone_9.CFrame = HumanoidRootPart_upvr.CFrame
					var2_upvw.EmitAllDescendants(clone_9)
					local clone_2_upvr = Powerful_Strike_upvr["Fire Slash"]:Clone()
					clone_2_upvr.Parent = Folder_upvr
					clone_2_upvr.CFrame = HumanoidRootPart_upvr.CFrame
					clone_2_upvr.FireBurst:Play()
					for _, v_5_upvr in clone_2_upvr:GetDescendants() do
						if v_5_upvr:IsA("ParticleEmitter") then
							v_5_upvr.Enabled = true
							task.delay(0.9, function() -- Line 186
								--[[ Upvalues[1]:
									[1]: v_5_upvr (readonly)
								]]
								v_5_upvr.Enabled = false
							end)
						end
					end
					TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.9, Enum.EasingStyle.Linear), {
						CFrame = clone_2_upvr.CFrame + clone_2_upvr.CFrame.LookVector * 80;
					}):Play()
					local var57_upvw = false
					task.delay(0.9, function() -- Line 198
						--[[ Upvalues[2]:
							[1]: var57_upvw (read and write)
							[2]: clone_2_upvr (readonly)
						]]
						var57_upvw = true
						clone_2_upvr.Attachment.char.Enabled = false
					end)
					local var60_upvw
					local tbl_2_upvr = {}
					var60_upvw = RunService_upvr.Stepped:Connect(function() -- Line 205
						--[[ Upvalues[7]:
							[1]: clone_2_upvr (readonly)
							[2]: var57_upvw (read and write)
							[3]: var60_upvw (read and write)
							[4]: var2_upvw (copied, read and write)
							[5]: tbl_2_upvr (readonly)
							[6]: TweenService_upvr (copied, readonly)
							[7]: Powerful_Strike_upvr (copied, readonly)
						]]
						if not clone_2_upvr.Parent or var57_upvw then
							var60_upvw:Disconnect()
						else
							if workspace:Raycast(clone_2_upvr.Position, Vector3.new(0, -3.0999, 0), var2_upvw.raycastParams) and clone_2_upvr.FireParticle.Enabled == true then
								clone_2_upvr.Attachment.char.Enabled = true
							else
								clone_2_upvr.Attachment.char.Enabled = false
							end
							for _, v_7 in var2_upvw.findEnemiesPart(clone_2_upvr.Hitbox, true), nil do
								if not table.find(tbl_2_upvr, v_7) then
									table.insert(tbl_2_upvr, v_7)
									var2_upvw.applyDamage(v_7, 10)
									var2_upvw.Knockback(v_7, clone_2_upvr.Position + clone_2_upvr.CFrame.LookVector * -6, 65)
									var2_upvw.applyStatus(v_7, "Ragdoll", 0.9)
									local clone = clone_2_upvr.Hit:Clone()
									clone.Parent = v_7.Torso
									clone.PlaybackSpeed += math.random(-1, 1) * 0.1
									clone:Play()
									game.Debris:AddItem(clone, 4)
									if v_7.Humanoid.Health <= 1 then
										for _, v_8 in v_7:GetDescendants() do
											if v_8:IsA("Shirt") or v_8:IsA("Pants") then
												v_8:Destroy()
											elseif v_8:IsA("BasePart") then
												v_8.Material = "Neon"
												v_8.Color = Color3.new(1, 0.768627, 0.364706)
												TweenService_upvr:Create(v_8, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
													Color = Color3.new(0, 0, 0);
												}):Play()
												if not v_8:FindFirstChild("burnVfx") and v_8.Name == "Torso" or v_8.Name == "Left Arm" or v_8.Name == "Right Arm" or v_8.Name == "Head" or v_8.Name == "Left Leg" or v_8.Name == "Right Leg" then
													local clone_12 = Powerful_Strike_upvr.burnVfx:Clone()
													clone_12.Parent = v_8
													clone_12.Enabled = true
													local clone_11 = Powerful_Strike_upvr.burnSfx:Clone()
													clone_11.Parent = v_8
													clone_11:Play()
												end
											end
										end
									end
								end
							end
						end
					end)
					for _, v_6 in Greatsword_upvr.FireVfx:GetChildren() do
						v_6.Enabled = false
					end
				end)
			end
		end
	end)
	task.wait(2)
	var15_upvw:Disconnect()
end
return module_upvr
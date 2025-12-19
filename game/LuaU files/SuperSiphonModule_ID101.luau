-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:07
-- Luau version 6, Types version 3
-- Time taken: 0.020406 seconds

local module_upvr = {
	Cooldown = 15;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 20)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Super_Siphon_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"].Ultimate["Super Siphon"]
	local function _(arg1_2, arg2_2, arg3) -- Line 31, Named "Siphon"
		--[[ Upvalues[7]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: TweenService_upvr (copied, readonly)
			[5]: Humanoid_upvr (readonly)
			[6]: var2_upvw (copied, read and write)
			[7]: arg1 (readonly)
		]]
		task.spawn(function() -- Line 32
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
				task.delay(0.3, function() -- Line 46
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
							local var21 = Humanoid_upvr
							var21.Health += arg3
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
	local clone_2_upvr = Super_Siphon_upvr["Electric Aura"]:Clone()
	clone_2_upvr.Parent = arg1
	var2_upvw.applyDebris(clone_2_upvr, 8)
	clone_2_upvr.Torso.DashStart:Play()
	local AuraSFX_upvr = clone_2_upvr.Torso.AuraSFX
	AuraSFX_upvr:Play()
	for _, v in clone_2_upvr:GetChildren() do
		local Weld = v:FindFirstChild("Weld")
		Weld.Part0 = arg1:FindFirstChild(v.Name)
		Weld.Part1 = v
	end
	local tbl_upvr = {}
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "Freeze", 0.95))
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "GlobalCD", 0.95))
	var2_upvw.camShake(arg1, "SmallBump")
	var2_upvw.changeFov(arg1, 95, 0.01, 10)
	var2_upvw.flashScreen(arg1, Color3.new(1, 0.168627, 0.168627), 0.4)
	local any_LoadAnimation_result1_2_upvr = Humanoid_upvr.Animator:LoadAnimation(Super_Siphon_upvr.DashAnimation)
	any_LoadAnimation_result1_2_upvr:Play()
	local var31_upvw
	task.delay(1, function() -- Line 105
		--[[ Upvalues[3]:
			[1]: var31_upvw (read and write)
			[2]: AuraSFX_upvr (readonly)
			[3]: clone_2_upvr (readonly)
		]]
		if not var31_upvw then
		else
			var31_upvw:Disconnect()
			AuraSFX_upvr:Stop()
			for _, v_2 in clone_2_upvr:GetDescendants() do
				if v_2:IsA("ParticleEmitter") then
					v_2.Enabled = false
				end
			end
		end
	end)
	var31_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_3, arg3) -- Line 117
		--[[ Upvalues[14]:
			[1]: arg2 (readonly)
			[2]: tbl_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: arg1 (readonly)
			[5]: any_LoadAnimation_result1_2_upvr (readonly)
			[6]: Humanoid_upvr (readonly)
			[7]: Super_Siphon_upvr (readonly)
			[8]: AuraSFX_upvr (readonly)
			[9]: clone_2_upvr (readonly)
			[10]: Folder_upvr (readonly)
			[11]: HumanoidRootPart_upvr (readonly)
			[12]: ReplicatedStorage_upvr (copied, readonly)
			[13]: TweenService_upvr (copied, readonly)
			[14]: module_upvr (copied, readonly)
		]]
		if arg1_3 ~= arg2 or arg2_3 ~= "Super Siphon" then
		else
			for _, v_3 in tbl_upvr do
				var2_upvw.applyDebris(v_3, 0)
			end
			var2_upvw.applyStatus(arg1, "Freeze", 0.5)
			var2_upvw.applyStatus(arg1, "GlobalCD", 0.5)
			var2_upvw.applyStatus(arg1, "AutoRotate", 0.5)
			any_LoadAnimation_result1_2_upvr.Priority = "Action2"
			any_LoadAnimation_result1_2_upvr:Stop()
			local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Super_Siphon_upvr.SlashAnimation)
			any_LoadAnimation_result1:Play()
			any_LoadAnimation_result1:AdjustSpeed(1)
			var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 135
				--[[ Upvalues[10]:
					[1]: AuraSFX_upvr (copied, readonly)
					[2]: clone_2_upvr (copied, readonly)
					[3]: var2_upvw (copied, read and write)
					[4]: arg1 (copied, readonly)
					[5]: Super_Siphon_upvr (copied, readonly)
					[6]: Folder_upvr (copied, readonly)
					[7]: HumanoidRootPart_upvr (copied, readonly)
					[8]: ReplicatedStorage_upvr (copied, readonly)
					[9]: TweenService_upvr (copied, readonly)
					[10]: Humanoid_upvr (copied, readonly)
				]]
				AuraSFX_upvr:Stop()
				for _, v_4 in clone_2_upvr:GetDescendants() do
					if v_4:IsA("ParticleEmitter") then
						v_4.Enabled = false
					end
				end
				clone_2_upvr.Torso.Slash1:Play()
				clone_2_upvr.Torso.Slash2:Play()
				clone_2_upvr.Torso.Slash3:Play()
				var2_upvw.camShake(arg1, "BigBump")
				var2_upvw.Blur(arg1, 25, 0.5)
				var2_upvw.changeFov(arg1, 55, 0.05, 2)
				var2_upvw.flashScreen(arg1, Color3.new(1, 0.168627, 0.168627), 1.5)
				var2_upvw.impactFrame2(arg1, 0.03)
				local clone = Super_Siphon_upvr.SiphonVFX:Clone()
				clone.Parent = Folder_upvr
				clone.CFrame = HumanoidRootPart_upvr.CFrame
				var2_upvw.EmitAllDescendants(clone)
				var2_upvw.applyDebris(clone, 6)
				local clone_4 = Super_Siphon_upvr.Hitbox:Clone()
				clone_4.Parent = Folder_upvr
				clone_4.weld.Part0 = HumanoidRootPart_upvr
				clone_4.weld.Part1 = clone_4
				var2_upvw.applyDebris(clone_4, 0.5)
				for _, v_5 in var2_upvw.findEnemiesPart(clone_4), nil do
					var2_upvw.applyDamage(v_5, 20)
					var2_upvw.Knockback(v_5, HumanoidRootPart_upvr.Position, 5, 50)
					var2_upvw.applyStatus(v_5, "Ragdoll", 1)
					var2_upvw.applyStatus(v_5, "Stunned", 1)
					local var52_upvr = 3
					local CFrame_upvr = v_5.Torso.CFrame
					local var54_upvr = 1
					task.spawn(function() -- Line 32
						--[[ Upvalues[10]:
							[1]: var52_upvr (readonly)
							[2]: ReplicatedStorage_upvr (copied, readonly)
							[3]: Folder_upvr (copied, readonly)
							[4]: CFrame_upvr (readonly)
							[5]: HumanoidRootPart_upvr (copied, readonly)
							[6]: TweenService_upvr (copied, readonly)
							[7]: Humanoid_upvr (copied, readonly)
							[8]: var54_upvr (readonly)
							[9]: var2_upvw (copied, read and write)
							[10]: arg1 (copied, readonly)
						]]
						for _ = 1, var52_upvr do
							local clone_5_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"].Ultimate.SiphonBall:Clone()
							clone_5_upvr.Parent = Folder_upvr
							clone_5_upvr.CFrame = CFrame_upvr
							clone_5_upvr.CFrame = CFrame.lookAt(clone_5_upvr.Position, HumanoidRootPart_upvr.Position)
							game.Debris:AddItem(clone_5_upvr, 10)
							TweenService_upvr:Create(clone_5_upvr, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
								Position = clone_5_upvr.Position:Lerp(HumanoidRootPart_upvr.Position, 0.5) + (clone_5_upvr.CFrame.RightVector) * (math.random(-4, 4) * 1.5) + (clone_5_upvr.CFrame.UpVector) * (math.random(-4, 4) * 1.5);
							}):Play()
							local Appear = clone_5_upvr.Appear
							Appear.PlaybackSpeed += math.random(-3, 3) * 0.06
							clone_5_upvr.Appear:Play()
							task.delay(0.3, function() -- Line 46
								--[[ Upvalues[7]:
									[1]: TweenService_upvr (copied, readonly)
									[2]: clone_5_upvr (readonly)
									[3]: HumanoidRootPart_upvr (copied, readonly)
									[4]: Humanoid_upvr (copied, readonly)
									[5]: var54_upvr (copied, readonly)
									[6]: var2_upvw (copied, read and write)
									[7]: arg1 (copied, readonly)
								]]
								TweenService_upvr:Create(clone_5_upvr, TweenInfo.new((clone_5_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.03, Enum.EasingStyle.Linear), {
									Position = HumanoidRootPart_upvr.Position;
								}):Play()
								task.wait(0.1)
								while task.wait() and clone_5_upvr.Parent and clone_5_upvr.Transparency ~= 1 do
									TweenService_upvr:Create(clone_5_upvr, TweenInfo.new((clone_5_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.01, Enum.EasingStyle.Linear), {
										Position = HumanoidRootPart_upvr.Position;
									}):Play()
									if (clone_5_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude <= 2 then
										TweenService_upvr:Create(clone_5_upvr, TweenInfo.new(0, Enum.EasingStyle.Linear), {
											Position = HumanoidRootPart_upvr.Position;
										}):Play()
										task.wait()
										clone_5_upvr.Position = HumanoidRootPart_upvr.Position
										local HealSFX = clone_5_upvr.HealSFX
										HealSFX.PlaybackSpeed += math.random(-1, 1) * 0.1
										clone_5_upvr.HealSFX:Play()
										local var64 = Humanoid_upvr
										var64.Health += var54_upvr
										clone_5_upvr.Transparency = 1
										clone_5_upvr.Trail.Enabled = false
										var2_upvw.camShake(arg1, "SmallBump")
										var2_upvw.changeFov(arg1, 65, 0.05, 0.6)
										var2_upvw.flashScreen(arg1, Color3.new(1, 0.32549, 0.32549), 0.1)
									end
								end
							end)
							task.wait(0.05)
						end
					end)
					CFrame_upvr = var2_upvw.camShake
					CFrame_upvr(v_5, "Bump")
					CFrame_upvr = var2_upvw.Blur
					var52_upvr = 0.5
					CFrame_upvr(v_5, 25, var52_upvr)
					CFrame_upvr = var2_upvw.changeFov
					var52_upvr = 0.05
					var54_upvr = 2
					CFrame_upvr(v_5, 55, var52_upvr, var54_upvr)
					CFrame_upvr = var2_upvw.flashScreen
					var52_upvr = 1
					var54_upvr = 0.168627
					var52_upvr = 1
					CFrame_upvr(v_5, Color3.new(var52_upvr, var54_upvr, 0.168627), var52_upvr)
				end
			end), module_upvr.Cooldown)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:57
-- Luau version 6, Types version 3
-- Time taken: 0.036643 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 23
module_upvr.GlobalCD = 1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 18
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Fallen_upvr = ReplicatedStorage_upvr.Skills["Basic Sword"].Ultimate.Fallen
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid"):LoadAnimation(Fallen_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play(0)
	local tbl_upvr = {}
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "Stunned", 3))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "AutoRotate", 3))
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 100, 0.5, 0.8)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 42
		--[[ Upvalues[3]:
			[1]: Fallen_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var3_upvw (copied, read and write)
		]]
		for _, v in Fallen_upvr:GetChildren() do
			if v:IsA("Sound") and v.Name == arg1_2 then
				local clone = v:Clone()
				clone.Parent = HumanoidRootPart_upvr
				clone:Play()
				var3_upvw.applyDebris(clone, clone.TimeLength * clone.PlaybackSpeed)
			end
		end
	end), module_upvr.Cooldown)
	local clone_2_upvr = Fallen_upvr.FallenBall:Clone()
	clone_2_upvr.Parent = HumanoidRootPart_upvr
	clone_2_upvr.weld.Part0 = HumanoidRootPart_upvr
	clone_2_upvr.weld.Part1 = clone_2_upvr
	var3_upvw.applyDebris(clone_2_upvr, 8)
	local clone_4_upvr = Fallen_upvr.Indicator:Clone()
	clone_4_upvr.Parent = Folder_upvr
	clone_4_upvr.weld.Part0 = HumanoidRootPart_upvr
	clone_4_upvr.weld.Part1 = clone_4_upvr
	var3_upvw.applyDebris(clone_4_upvr, 8)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 65
		--[[ Upvalues[3]:
			[1]: var3_upvw (copied, read and write)
			[2]: clone_4_upvr (readonly)
			[3]: clone_2_upvr (readonly)
		]]
		var3_upvw.applyDebris(clone_4_upvr, 0)
		var3_upvw.applyDebris(clone_2_upvr, 0)
	end), module_upvr.Cooldown)
	for _, v_2 in clone_4_upvr:GetDescendants() do
		if v_2:IsA("Beam") then
			v_2.Width0 = 0
			v_2.Width1 = 0
			TweenService_upvr:Create(v_2, TweenInfo.new(0.75), {
				Width0 = v_2.Width0;
				Width1 = v_2.Width1;
			}):Play()
		elseif v_2:IsA("BasePart") then
			v_2.Transparency = 1
			TweenService_upvr:Create(v_2, TweenInfo.new(0.5), {
				Transparency = v_2.Transparency;
			}):Play()
		end
	end
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("explode"):Connect(function() -- Line 82
		--[[ Upvalues[9]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: clone_2_upvr (readonly)
			[4]: clone_4_upvr (readonly)
			[5]: TweenService_upvr (copied, readonly)
			[6]: Fallen_upvr (readonly)
			[7]: Folder_upvr (readonly)
			[8]: module_upvr (copied, readonly)
			[9]: tbl_upvr (readonly)
		]]
		var3_upvw.ReverseFlashScreen(arg1, Color3.new(1, 1, 1), 0.02)
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 65, 0, 2)
		var3_upvw.EmitAllDescendants(clone_2_upvr)
		local _, NONE_6, NONE_5 = clone_2_upvr:GetDescendants()
		local var47
		for _, v_3 in var47, NONE_6, NONE_5 do
			if v_3:IsA("ParticleEmitter") then
				v_3.LockedToPart = false
				v_3.Enabled = false
			end
		end
		var47 = var3_upvw.EmitAllDescendants
		var47(clone_4_upvr.ExplodeVFX)
		var47 = clone_4_upvr:GetDescendants()
		local descendants, NONE_2, NONE_8 = clone_4_upvr:GetDescendants()
		for _, v_4 in descendants, NONE_2, NONE_8 do
			if v_4:IsA("Beam") then
				TweenService_upvr:Create(v_4, TweenInfo.new(0.5), {
					Width0 = 0;
					Width1 = 0;
				}):Play()
			elseif v_4:IsA("BasePart") then
				TweenService_upvr:Create(v_4, TweenInfo.new(0.5), {
					Transparency = 1;
				}):Play()
			elseif v_4:IsA("ParticleEmitter") then
				v_4.Enabled = false
			end
		end
		descendants = false
		for _, v_5_upvr in var3_upvw.findEnemiesPart(clone_4_upvr.Hitbox, true), nil do
			if not var3_upvw.CheckBlock(v_5_upvr, true) then
				descendants = true
				var3_upvw.unragdoll(v_5_upvr)
				var3_upvw.applyDamage(v_5_upvr, 5)
				var3_upvw.applyStatus(v_5_upvr, "Slowed", 1.5)
				var3_upvw.applyStatus(v_5_upvr, "GlobalCD", 1.5)
				var3_upvw.applyStatus(v_5_upvr, "AutoRotate", 1.5)
				task.spawn(function() -- Line 117
					--[[ Upvalues[7]:
						[1]: Fallen_upvr (copied, readonly)
						[2]: Folder_upvr (copied, readonly)
						[3]: v_5_upvr (readonly)
						[4]: var3_upvw (copied, read and write)
						[5]: TweenService_upvr (copied, readonly)
						[6]: arg1 (copied, readonly)
						[7]: module_upvr (copied, readonly)
					]]
					task.wait(0.8)
					for _ = 1, 5 do
						local clone_3_upvr = Fallen_upvr["Fallen Sword"]:Clone()
						clone_3_upvr.Parent = Folder_upvr
						clone_3_upvr.CFrame = v_5_upvr.HumanoidRootPart.CFrame + Vector3.new(math.random(-5, 5), math.random(-5, 5) + 65, math.random(-5, 5))
						var3_upvw.applyDebris(clone_3_upvr, 12)
						task.delay(8, function() -- Line 125
							--[[ Upvalues[2]:
								[1]: clone_3_upvr (readonly)
								[2]: var3_upvw (copied, read and write)
							]]
							if not clone_3_upvr then
							else
								var3_upvw.applyDebris(clone_3_upvr.Neon, 0)
								var3_upvw.EmitAllDescendants(clone_3_upvr.Shatter)
								for _, v_10 in clone_3_upvr.Shatter:GetDescendants() do
									if v_10:IsA("Sound") then
										v_10.PlaybackSpeed += math.random(-1, 1)
										v_10:Play()
									end
								end
							end
						end)
						for _, v_6 in clone_3_upvr.SpawnSounds:GetChildren() do
							v_6.PlaybackSpeed += math.random(-1, 1) * 0.1
							v_6:Play()
						end
						local workspace_Raycast_result1 = workspace:Raycast(clone_3_upvr.Position, Vector3.new(0, -1000, 0), var3_upvw.raycastParams)
						if workspace_Raycast_result1 then
							local any_Create_result1 = TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(0.15 + (clone_3_upvr.Position - workspace_Raycast_result1.Position).Magnitude * 0.002, Enum.EasingStyle.Linear), {
								CFrame = CFrame.new(workspace_Raycast_result1.Position) * clone_3_upvr.CFrame - clone_3_upvr.CFrame.p;
							})
							any_Create_result1:Play()
							var3_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 148
								--[[ Upvalues[3]:
									[1]: var3_upvw (copied, read and write)
									[2]: arg1 (copied, readonly)
									[3]: clone_3_upvr (readonly)
								]]
								var3_upvw.camShake(arg1, "SmallBump")
								var3_upvw.EmitAllDescendants(clone_3_upvr)
								for _, v_7 in clone_3_upvr.ImpactSounds:GetChildren() do
									v_7.PlaybackSpeed += math.random(-1, 1) * 0.1
									v_7:Play()
								end
								for _, v_8 in var3_upvw.findEnemiesMagnitude(clone_3_upvr.Position, 18, true), nil do
									if not var3_upvw.CheckBlock(v_8, true) then
										var3_upvw.applyDamage(v_8, 5)
										var3_upvw.applyStatus(v_8, "Stunned", 1)
										var3_upvw.applyStatus(v_8, "AutoRotate", 1)
									end
								end
							end), module_upvr.Cooldown)
							task.wait(0.8)
						end
					end
				end)
			end
		end
		if descendants then
			for _, v_9 in tbl_upvr do
				var3_upvw.applyDebris(v_9, 0.35)
			end
		end
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 182
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:Stop(0.4)
	end), module_upvr.Cooldown)
end
return module_upvr
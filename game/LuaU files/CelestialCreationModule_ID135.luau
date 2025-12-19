-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:16
-- Luau version 6, Types version 3
-- Time taken: 0.024283 seconds

local module_upvr = {
	Cooldown = 15;
	GlobalCD = 0.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 15
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Celestial_Creation_upvr_2 = ReplicatedStorage_upvr.Skills.Nebula["Celestial Creation"]
	local any_LoadAnimation_result1_2 = arg1:FindFirstChild("Humanoid"):LoadAnimation(Celestial_Creation_upvr_2.Animation)
	any_LoadAnimation_result1_2:Play()
	any_LoadAnimation_result1_2:AdjustSpeed(1.45)
	var2_upvw.applyStatus(arg1, "Slowed", 1.5)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.5)
	local var9_upvw = false
	local any_applySound_result1_upvr = var2_upvw.applySound(Celestial_Creation_upvr_2.Charge, HumanoidRootPart_upvr)
	var2_upvw.conTimer(any_LoadAnimation_result1_2.Stopped:Connect(function() -- Line 38
		--[[ Upvalues[2]:
			[1]: var9_upvw (read and write)
			[2]: any_applySound_result1_upvr (readonly)
		]]
		if var9_upvw then
		else
			any_applySound_result1_upvr:Stop()
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_2:GetMarkerReachedSignal("end"):Connect(function() -- Line 43
		--[[ Upvalues[1]:
			[1]: var9_upvw (read and write)
		]]
		var9_upvw = true
	end), module_upvr.Cooldown)
	var2_upvw.camShake(arg1, "SmallBump")
	var2_upvw.changeFov(arg1, 75, 1.5, 6)
	local tbl_upvr = {}
	local var15_upvw
	var15_upvw = var2_upvw.conTimer(arg2.CharacterRemoving:Connect(function() -- Line 52
		--[[ Upvalues[3]:
			[1]: var15_upvw (read and write)
			[2]: tbl_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
		]]
		var15_upvw:Disconnect()
		for _, v in tbl_upvr do
			var2_upvw.applyDebris(v, 0)
		end
	end), module_upvr.Cooldown)
	local tbl_upvr_2 = {}
	var2_upvw.conTimer(any_LoadAnimation_result1_2:GetMarkerReachedSignal("Create"):Connect(function() -- Line 61
		--[[ Upvalues[10]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Celestial_Creation_upvr_2 (readonly)
			[4]: Folder_upvr (readonly)
			[5]: TweenService_upvr (copied, readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: module_upvr (copied, readonly)
			[8]: tbl_upvr (readonly)
			[9]: tbl_upvr_2 (readonly)
			[10]: var15_upvw (read and write)
		]]
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.Blur(arg1, 10, 1)
		var2_upvw.changeFov(arg1, 60, 2, 5)
		local clone_3 = Celestial_Creation_upvr_2.CelestialCreation:Clone()
		clone_3.Parent = Folder_upvr
		for _, v_2 in clone_3:GetDescendants() do
			if v_2:IsA("BasePart") then
				v_2.CollisionGroup = "noCollision"
			end
		end
		local Celestial_Creation_upvr = clone_3["Celestial Creation"]
		local any_LoadAnimation_result1 = clone_3.AnimationController.Animator:LoadAnimation(Celestial_Creation_upvr_2.PlanetAnimation)
		any_LoadAnimation_result1:Play(0)
		for _, v_3 in Celestial_Creation_upvr.Asteroids:GetChildren() do
			if v_3:IsA("BasePart") then
				v_3.Size = Vector3.new(0, 0, 0)
				TweenService_upvr:Create(v_3, TweenInfo.new(0.5), {
					Size = v_3.Size;
				}):Play()
			end
		end
		Celestial_Creation_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 25 + Vector3.new(0, 10, 0)
		TweenService_upvr:Create(Celestial_Creation_upvr, TweenInfo.new(1.5), {
			CFrame = Celestial_Creation_upvr.CFrame + Vector3.new(0, -10, 0);
		}):Play()
		TweenService_upvr:Create(Celestial_Creation_upvr.AirSpin, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			Size = Celestial_Creation_upvr.AirSpin.Size * 1.5;
			Transparency = 1;
		}):Play()
		var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 96
			--[[ Upvalues[3]:
				[1]: Celestial_Creation_upvr_2 (copied, readonly)
				[2]: var2_upvw (copied, read and write)
				[3]: Celestial_Creation_upvr (readonly)
			]]
			for _, v_4 in Celestial_Creation_upvr_2:GetChildren() do
				if v_4:IsA("Sound") and v_4.Name == arg1_2 then
					var2_upvw.applySound(v_4, Celestial_Creation_upvr)
				end
			end
		end), module_upvr.Cooldown)
		var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Pull"):Connect(function() -- Line 104
			--[[ Upvalues[5]:
				[1]: var2_upvw (copied, read and write)
				[2]: arg1 (copied, readonly)
				[3]: Celestial_Creation_upvr (readonly)
				[4]: tbl_upvr (copied, readonly)
				[5]: TweenService_upvr (copied, readonly)
			]]
			var2_upvw.camShake(arg1, "SmallBump")
			var2_upvw.changeFov(arg1, 65, 0.1, 1)
			for _, v_5 in Celestial_Creation_upvr.AirSpin.VFX:GetChildren() do
				v_5.Enabled = false
			end
			for _, v_6 in var2_upvw.findEnemiesMagnitude(Celestial_Creation_upvr.Position, 22, true), nil do
				if not var2_upvw.CheckBlock(v_6, true) then
					var2_upvw.unragdoll(v_6)
					var2_upvw.applyDamage(v_6, 5)
					var2_upvw.applyStatus(v_6, "Stunned", 0.5)
					var2_upvw.applyStatus(v_6, "AutoRotate", 0.5)
					local BodyVelocity = Instance.new("BodyVelocity", v_6.Head)
					BodyVelocity.MaxForce = Vector3.new(99999, 99999, 99999)
					BodyVelocity.Velocity = Vector3.new(0, 0, 0)
					var2_upvw.applyDebris(BodyVelocity, 5)
					table.insert(tbl_upvr, BodyVelocity)
					TweenService_upvr:Create(v_6.HumanoidRootPart, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						CFrame = CFrame.new(Celestial_Creation_upvr.Position) * Celestial_Creation_upvr.CFrame - Celestial_Creation_upvr.CFrame.p;
					}):Play()
				end
			end
		end), module_upvr.Cooldown)
		var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Planet"):Connect(function() -- Line 135
			--[[ Upvalues[10]:
				[1]: var2_upvw (copied, read and write)
				[2]: arg1 (copied, readonly)
				[3]: Celestial_Creation_upvr (readonly)
				[4]: tbl_upvr_2 (copied, readonly)
				[5]: Celestial_Creation_upvr_2 (copied, readonly)
				[6]: Folder_upvr (copied, readonly)
				[7]: TweenService_upvr (copied, readonly)
				[8]: var15_upvw (copied, read and write)
				[9]: tbl_upvr (copied, readonly)
				[10]: HumanoidRootPart_upvr (copied, readonly)
			]]
			var2_upvw.camShake(arg1, "Bump")
			var2_upvw.changeFov(arg1, 100, 0.1, 3)
			var2_upvw.Blur(arg1, 25, 0.8)
			for _, v_7 in Celestial_Creation_upvr.Planet.Lava.VFX:GetChildren() do
				v_7.Enabled = true
			end
			for i_8_upvr, v_8 in var2_upvw.findEnemiesMagnitude(Celestial_Creation_upvr.Position, 18, true), nil do
				if not var2_upvw.CheckBlock(v_8, true) then
					var2_upvw.applyStatus(v_8, "Stunned", 2.5)
					var2_upvw.applyStatus(v_8, "AutoRotate", 2.5)
					var2_upvw.applyDamage(v_8, 5)
					tbl_upvr_2[v_8.Name] = var2_upvw.applyStatus(v_8, "IFrames", 3)
					local Weld = Instance.new("Weld", Celestial_Creation_upvr)
					Weld.Part0 = Celestial_Creation_upvr
					Weld.Part1 = v_8.HumanoidRootPart
					table.insert({}, Weld)
					var2_upvw.applyDebris(Weld, 2)
				end
			end
			for _ = 1, 12 do
				v_8 = Celestial_Creation_upvr_2
				i_8_upvr = v_8.Rubble:Clone()
				v_8 = Folder_upvr
				i_8_upvr.Parent = v_8
				v_8 = i_8_upvr.Size
				v_8 += Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
				i_8_upvr.Size = v_8
				v_8 = Celestial_Creation_upvr.CFrame * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)))
				i_8_upvr.CFrame = v_8
				v_8 = i_8_upvr.Velocity
				v_8 += Vector3.new(math.random(-60, 60), math.random(0, 50), math.random(-60, 60))
				i_8_upvr.Velocity = v_8
				v_8 = i_8_upvr.RotVelocity
				v_8 += Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				i_8_upvr.RotVelocity = v_8
				v_8 = i_8_upvr.CFrame + i_8_upvr.CFrame.LookVector * 9
				i_8_upvr.CFrame = v_8
				v_8 = "noCollision"
				i_8_upvr.CollisionGroup = v_8
				v_8 = var2_upvw.applyDebris
				v_8(i_8_upvr, 10)
				v_8 = task.delay
				v_8(8, function() -- Line 173
					--[[ Upvalues[2]:
						[1]: TweenService_upvr (copied, readonly)
						[2]: i_8_upvr (readonly)
					]]
					TweenService_upvr:Create(i_8_upvr, TweenInfo.new(2), {
						Size = Vector3.new(0, 0, 0);
					}):Play()
				end)
			end
			for _, v_9 in Celestial_Creation_upvr_2:GetChildren() do
				if v_9.Name == "Explosion" and v_9:IsA("Sound") then
					var2_upvw.applySound(v_9, Celestial_Creation_upvr)
				end
			end
			for _, v_10 in Celestial_Creation_upvr:GetDescendants() do
				if v_10:IsA("BasePart") then
					v_10.Transparency = 1
				end
			end
			Celestial_Creation_upvr.Planet.CFrame = Celestial_Creation_upvr.CFrame
			Celestial_Creation_upvr.Planet.Size = Vector3.new(1, 1, 1)
			Celestial_Creation_upvr.Planet.Transparency = 0
			TweenService_upvr:Create(Celestial_Creation_upvr.Planet, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new(25, 25, 25);
			}):Play()
			Celestial_Creation_upvr.Planet.Lava.Size = Vector3.new(1, 1, 1)
			Celestial_Creation_upvr.Planet.Lava.Transparency = 0
			TweenService_upvr:Create(Celestial_Creation_upvr.Planet.Lava, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new(24.5, 24.5, 24.5);
			}):Play()
			TweenService_upvr:Create(Celestial_Creation_upvr.Planet, TweenInfo.new(5, Enum.EasingStyle.Linear), {
				CFrame = Celestial_Creation_upvr.CFrame * CFrame.Angles((math.pi/2), math.pi, 0);
			}):Play()
			local clone_2 = Celestial_Creation_upvr_2.Shockwave1:Clone()
			clone_2.Parent = Folder_upvr
			clone_2.CFrame = Celestial_Creation_upvr.CFrame
			var2_upvw.applyDebris(clone_2, 3)
			TweenService_upvr:Create(clone_2, TweenInfo.new(1.25, Enum.EasingStyle.Linear), {
				Size = Vector3.new(100, 3, 100);
				Transparency = 1;
			}):Play()
			local clone = Celestial_Creation_upvr_2.Shockwave2:Clone()
			clone.Parent = Folder_upvr
			clone.CFrame = Celestial_Creation_upvr.CFrame
			var2_upvw.applyDebris(clone, 3)
			TweenService_upvr:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = Vector3.new(100, 0.10000, 100);
				Transparency = 1;
			}):Play()
			task.wait(2)
			for i_12, v_11 in tbl_upvr_2 do
				local var92 = workspace.WorldInfo.Live:FindFirstChild(i_12) or false
				if var92 then
					var2_upvw.applyDebris(v_11, 0, var92)
				end
			end
			task.wait()
			var2_upvw.EmitAllDescendants(Celestial_Creation_upvr.ExplosionVFX)
			var2_upvw.camShake(arg1, "Bump")
			var2_upvw.changeFov(arg1, 100, 0.1, 3)
			var2_upvw.Blur(arg1, 25, 0.8)
			for _, v_12 in {} do
				var2_upvw.applyDebris(v_12, 0)
				-- KONSTANTERROR: Expression was reused, decompilation is incorrect
			end
			Celestial_Creation_upvr.Planet:Destroy()
			for i_14_upvr, v_13 in Celestial_Creation_upvr_2:GetChildren() do
				if v_13.Name == "Explosion2" and v_13:IsA("Sound") then
					var2_upvw.applySound(v_13, Celestial_Creation_upvr)
				end
			end
			for _ = 1, 20 do
				v_13 = Celestial_Creation_upvr_2
				i_14_upvr = v_13.Rubble2:Clone()
				v_13 = Folder_upvr
				i_14_upvr.Parent = v_13
				v_13 = i_14_upvr.Size
				v_13 += Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
				i_14_upvr.Size = v_13
				v_13 = Celestial_Creation_upvr.CFrame * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)))
				i_14_upvr.CFrame = v_13
				v_13 = i_14_upvr.CFrame + i_14_upvr.CFrame.LookVector * 9
				i_14_upvr.CFrame = v_13
				v_13 = var2_upvw.applyDebris
				v_13(i_14_upvr, 4)
				v_13 = Instance.new("BodyVelocity", i_14_upvr)
				v_13.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				v_13.Velocity = Vector3.new(math.random(-75, 75), math.random(-75, 75), math.random(-75, 75))
				TweenService_upvr:Create(v_13, TweenInfo.new(1.25), {
					Velocity = Vector3.new(0, 0, 0);
				}):Play()
				task.delay(1, function() -- Line 267
					--[[ Upvalues[2]:
						[1]: TweenService_upvr (copied, readonly)
						[2]: i_14_upvr (readonly)
					]]
					TweenService_upvr:Create(i_14_upvr, TweenInfo.new(math.random(2, 3), Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Size = Vector3.new(0, 0, 0);
					}):Play()
				end)
			end
			var15_upvw:Disconnect()
			for _, v_14 in tbl_upvr do
				var2_upvw.applyDebris(v_14, 0)
			end
			task.wait()
			for _, v_15 in var2_upvw.findEnemiesMagnitude(Celestial_Creation_upvr.Position, 18, true), nil do
				if not var2_upvw.CheckBlock(v_15, true) then
					var2_upvw.applyStatus(v_15, "Ragdoll", 2)
					var2_upvw.applyDamage(v_15, 5)
					var2_upvw.Knockback(v_15, HumanoidRootPart_upvr.Position, 10, 20)
				end
			end
		end), module_upvr.Cooldown)
	end), module_upvr.Cooldown)
end
return module_upvr
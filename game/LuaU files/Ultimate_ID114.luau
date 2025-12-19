-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:54
-- Luau version 6, Types version 3
-- Time taken: 0.071895 seconds

local module_upvr = {
	ModeLength = 75;
	GlobalCD = 3;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 15
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: module_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_2_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_2_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_2_upvr, 23)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills["Soul Lantern"].Ultimate
	for _, v in HumanoidRootPart_upvr:GetChildren() do
		if v.Name == "Theme" and v:IsA("Sound") then
			v:Destroy()
		end
	end
	var2_upvw.applyStatus(arg1, "Stunned", 3)
	var2_upvw.applyStatus(arg1, "AutoRotate", 3)
	var2_upvw.applyStatus(arg1, "IFrames", 3)
	var2_upvw.applyStatus(arg1, "Ultimate", 3)
	local clone_10_upvr = Ultimate_upvr.VFX:Clone()
	clone_10_upvr.Parent = Folder_2_upvr
	clone_10_upvr.CFrame = HumanoidRootPart_upvr.CFrame
	var2_upvw.applyDebris(clone_10_upvr, 16)
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Ultimate_upvr.Animation)
	any_LoadAnimation_result1:Play()
	local any_applySound_result1_upvr = var2_upvw.applySound(Ultimate_upvr.Theme, HumanoidRootPart_upvr, Ultimate_upvr.Theme.TimeLength / Ultimate_upvr.Theme.PlaybackSpeed + 5)
	any_applySound_result1_upvr.Volume = 4.5
	var2_upvw.applySound(Ultimate_upvr.Charge, clone_10_upvr, 8)
	local function enableVFX_upvr(arg1_2, arg2_2) -- Line 53, Named "enableVFX"
		for _, v_2 in arg1_2:GetDescendants() do
			if v_2:IsA("ParticleEmitter") then
				v_2.Enabled = arg2_2
			end
		end
	end
	enableVFX_upvr(clone_10_upvr.SideVFX, true)
	enableVFX_upvr(clone_10_upvr.SideVFX2, true)
	any_LoadAnimation_result1:GetMarkerReachedSignal("Stomp"):Once(function() -- Line 64
		--[[ Upvalues[4]:
			[1]: var2_upvw (copied, read and write)
			[2]: clone_10_upvr (readonly)
			[3]: Ultimate_upvr (readonly)
			[4]: arg1 (readonly)
		]]
		var2_upvw.CreateDebris(clone_10_upvr.Position, 10, 1.5, 1.25, 0.08)
		var2_upvw.crater(1, clone_10_upvr.Position, 3.5, 1.25)
		var2_upvw.EmitAllDescendants(clone_10_upvr.RageVFX)
		var2_upvw.applySound(Ultimate_upvr.Roar, clone_10_upvr, 8)
		var2_upvw.applySound(Ultimate_upvr.Magic, clone_10_upvr, 8)
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 70, 0.05, 0.5)
		var2_upvw.flashScreen(arg1, Color3.new(0.47451, 1, 1), 0.5)
	end)
	any_LoadAnimation_result1:GetMarkerReachedSignal("Smash"):Once(function() -- Line 79
		--[[ Upvalues[8]:
			[1]: var2_upvw (copied, read and write)
			[2]: clone_10_upvr (readonly)
			[3]: enableVFX_upvr (readonly)
			[4]: Ultimate_upvr (readonly)
			[5]: arg1 (readonly)
			[6]: Folder_2_upvr (readonly)
			[7]: arg2 (readonly)
			[8]: HumanoidRootPart_upvr (readonly)
		]]
		var2_upvw.CreateDebris(clone_10_upvr.Position, 10, 1.5, 1.25, 0.08)
		var2_upvw.crater(1, clone_10_upvr.Position, 7, 2.5)
		enableVFX_upvr(clone_10_upvr.SideVFX, false)
		enableVFX_upvr(clone_10_upvr.SideVFX2, false)
		enableVFX_upvr(clone_10_upvr.RedSideVFX, true)
		enableVFX_upvr(clone_10_upvr.RedSideVFX2, true)
		var2_upvw.applySound(Ultimate_upvr.Impact, clone_10_upvr, 8)
		var2_upvw.EmitAllDescendants(clone_10_upvr.SmashVFX)
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 200, 0.05, 1)
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.0627451, 0.0627451), 0.5)
		local function SpawnSoul(arg1_3) -- Line 97
			--[[ Upvalues[4]:
				[1]: Ultimate_upvr (copied, readonly)
				[2]: Folder_2_upvr (copied, readonly)
				[3]: arg2 (copied, readonly)
				[4]: var2_upvw (copied, read and write)
			]]
			local clone_8_upvr = Ultimate_upvr.DecayedSoul:Clone()
			clone_8_upvr.Parent = Folder_2_upvr
			clone_8_upvr.Position = arg1_3
			clone_8_upvr.Presence:Play()
			clone_8_upvr.Anchored = false
			clone_8_upvr:SetNetworkOwner(arg2)
			var2_upvw.applyDebris(clone_8_upvr, 3)
			local BodyPosition = Instance.new("BodyPosition", clone_8_upvr)
			BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyPosition.Position = clone_8_upvr.Position + Vector3.new(0, 20, 0)
			BodyPosition.P += 6000
			task.delay(0.9, function() -- Line 111
				--[[ Upvalues[2]:
					[1]: clone_8_upvr (readonly)
					[2]: var2_upvw (copied, read and write)
				]]
				clone_8_upvr.Transparency = 1
				for _, v_3 in clone_8_upvr:GetDescendants() do
					if v_3:IsA("ParticleEmitter") or v_3:IsA("Trail") then
						v_3.Enabled = false
					elseif v_3:IsA("Sound") and v_3.Looped then
						v_3:Stop()
					end
				end
				var2_upvw.EmitAllDescendants(clone_8_upvr.Explode)
			end)
		end
		for _ = 1, 25 do
			SpawnSoul(HumanoidRootPart_upvr.Position + Vector3.new(math.random(-50, 50), -3, math.random(-50, 50)))
		end
		for _ = 1, 15 do
			SpawnSoul(clone_10_upvr.RedSideVFX.Position)
			SpawnSoul(clone_10_upvr.RedSideVFX2.Position)
			wait(0.1)
		end
		enableVFX_upvr(clone_10_upvr.RedSideVFX, false)
		enableVFX_upvr(clone_10_upvr.RedSideVFX2, false)
	end)
	local Soul_Lantern_upvr = arg1:FindFirstChild("Soul Lantern")
	any_LoadAnimation_result1:GetMarkerReachedSignal("Pull"):Once(function() -- Line 140
		--[[ Upvalues[9]:
			[1]: var2_upvw (copied, read and write)
			[2]: clone_10_upvr (readonly)
			[3]: Ultimate_upvr (readonly)
			[4]: arg1 (readonly)
			[5]: Soul_Lantern_upvr (readonly)
			[6]: module_upvr (copied, readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: Folder_2_upvr (readonly)
			[9]: any_applySound_result1_upvr (readonly)
		]]
		var2_upvw.CreateDebris(clone_10_upvr.Position, 10, 1.5, 1.25, 0.08)
		var2_upvw.crater(1, clone_10_upvr.Position, 4, 1.5)
		var2_upvw.applySound(Ultimate_upvr.PullSFX, clone_10_upvr, 8)
		var2_upvw.EmitAllDescendants(clone_10_upvr.PullVFX)
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 200, 0.05, 2)
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.0627451, 0.0627451), 0.5)
		var2_upvw.impactFrame(arg1, 0.1)
		task.delay(0.1, function() -- Line 152
			--[[ Upvalues[2]:
				[1]: var2_upvw (copied, read and write)
				[2]: arg1 (copied, readonly)
			]]
			var2_upvw.impactFrame2(arg1, 0.1)
		end)
		local hitVFXRed_upvr_2 = Soul_Lantern_upvr:FindFirstChild("hitVFXRed")
		local hitVFX_upvr = Soul_Lantern_upvr:FindFirstChild("hitVFX")
		hitVFXRed_upvr_2.Name = "hitVFX"
		hitVFX_upvr.Name = "OGHitVFX"
		local punchVFX_upvr_2 = Soul_Lantern_upvr:FindFirstChild("punchVFX")
		local punchVFXred_upvr_2 = Soul_Lantern_upvr:FindFirstChild("punchVFXred")
		punchVFX_upvr_2.Name = "OGPunchVFX"
		punchVFXred_upvr_2.Name = "punchVFX"
		for _, v_4 in Soul_Lantern_upvr.VfxRed:GetDescendants() do
			if v_4:IsA("ParticleEmitter") or v_4:IsA("PointLight") then
				v_4.Enabled = true
			end
		end
		for _, v_5 in Soul_Lantern_upvr.Vfx:GetDescendants() do
			if v_5:IsA("ParticleEmitter") or v_5:IsA("PointLight") then
				v_5.Enabled = false
			end
		end
		local clone_9 = Ultimate_upvr.Eyes:Clone()
		clone_9.Parent = arg1
		clone_9.weld.Part0 = arg1.Head
		clone_9.weld.Part1 = clone_9
		game.Debris:AddItem(clone_9, module_upvr.ModeLength)
		local clone_2_upvr = Ultimate_upvr["DecayedBodyVFX "]:Clone()
		clone_2_upvr.Parent = arg1
		clone_2_upvr.weld.Part0 = arg1.Torso
		clone_2_upvr.weld.Part1 = clone_2_upvr
		game.Debris:AddItem(clone_2_upvr, module_upvr.ModeLength)
		local clone_13_upvr = Ultimate_upvr.Creepy:Clone()
		clone_13_upvr.Parent = arg1
		clone_13_upvr.weld.Part0 = arg1.Torso
		clone_13_upvr.weld.Part1 = clone_13_upvr
		game.Debris:AddItem(clone_13_upvr, module_upvr.ModeLength)
		local Folder_3 = Instance.new("Folder", arg1)
		Folder_3.Name = "Mode"
		game.Debris:AddItem(Folder_3, module_upvr.ModeLength)
		task.delay(module_upvr.ModeLength - 3, function() -- Line 200
			--[[ Upvalues[8]:
				[1]: hitVFXRed_upvr_2 (readonly)
				[2]: hitVFX_upvr (readonly)
				[3]: punchVFX_upvr_2 (readonly)
				[4]: punchVFXred_upvr_2 (readonly)
				[5]: Soul_Lantern_upvr (copied, readonly)
				[6]: TweenService_upvr (copied, readonly)
				[7]: clone_2_upvr (readonly)
				[8]: clone_13_upvr (readonly)
			]]
			hitVFXRed_upvr_2.Name = "hitVFXRed"
			hitVFX_upvr.Name = "hitVFX"
			punchVFX_upvr_2.Name = "punchVFX"
			punchVFXred_upvr_2.Name = "punchVFXred"
			for _, v_6 in Soul_Lantern_upvr.VfxRed:GetDescendants() do
				if v_6:IsA("ParticleEmitter") or v_6:IsA("PointLight") then
					v_6.Enabled = false
				elseif v_6:IsA("Beam") then
					TweenService_upvr:Create(v_6, TweenInfo.new(1), {
						Width0 = 0;
						Width1 = 0;
					}):Play()
				end
			end
			for _, v_7 in Soul_Lantern_upvr.Vfx:GetDescendants() do
				if v_7:IsA("ParticleEmitter") or v_7:IsA("PointLight") then
					v_7.Enabled = true
				elseif v_7:IsA("Beam") then
					TweenService_upvr:Create(v_7, TweenInfo.new(1), {
						Width0 = 0;
						Width1 = 0;
					}):Play()
				end
			end
			for _, v_8 in clone_2_upvr:GetDescendants() do
				if v_8:IsA("ParticleEmitter") or v_8:IsA("PointLight") then
					v_8.Enabled = false
				elseif v_8:IsA("Beam") then
					TweenService_upvr:Create(v_8, TweenInfo.new(1), {
						Width0 = 0;
						Width1 = 0;
					}):Play()
				end
			end
			for _, v_9 in clone_13_upvr:GetDescendants() do
				if v_9:IsA("ParticleEmitter") or v_9:IsA("PointLight") then
					v_9.Enabled = false
				elseif v_9:IsA("Beam") then
					TweenService_upvr:Create(v_9, TweenInfo.new(1), {
						Width0 = 0;
						Width1 = 0;
					}):Play()
				end
			end
		end)
		for _ = 1, 2 do
			task.spawn(function() -- Line 240
				--[[ Upvalues[5]:
					[1]: Ultimate_upvr (copied, readonly)
					[2]: Folder_2_upvr (copied, readonly)
					[3]: var2_upvw (copied, read and write)
					[4]: clone_10_upvr (copied, readonly)
					[5]: TweenService_upvr (copied, readonly)
				]]
				for _ = 1, 12 do
					local clone_7 = Ultimate_upvr.Geyser:Clone()
					clone_7.Parent = Folder_2_upvr
					var2_upvw.applyDebris(clone_7, 5)
					local function _(arg1_6, arg2_5) -- Line 246, Named "GetRandom"
						local randint_3 = math.random(arg1_6, arg2_5)
						if randint_3 == 0 then
							randint_3 = 1
						end
						return randint_3
					end
					local randint_6 = math.random(-8, 8)
					if randint_6 == 0 then
						randint_6 = 1
					end
					local randint_8 = math.random(-8, 8)
					if randint_8 == 0 then
						randint_8 = 1
					end
					clone_7.CFrame = CFrame.new(clone_10_upvr.Position + Vector3.new(randint_6 * 20, -3, randint_8 * 20)) * clone_7.CFrame - clone_7.CFrame.p
					var2_upvw.EmitAllDescendants(clone_7)
					var2_upvw.CreateDebris(clone_7.Position + Vector3.new(0, 1, 0), 5, 1.5, 1.25, 0.08)
					var2_upvw.crater(1, clone_7.Position + Vector3.new(0, 1, 0), 4, 1.8)
					local Rocks_3 = clone_7.Rocks
					Rocks_3.PlaybackSpeed += math.random(-1, 1) * 0.1
					clone_7.Rocks:Play()
					local Magic = clone_7.Magic
					Magic.PlaybackSpeed += math.random(-1, 1) * 0.1
					clone_7.Magic:Play()
					for _, v_10 in var2_upvw.findEnemiesPart(clone_7.Hitbox, true), nil do
						if not var2_upvw.CheckBlock(v_10, true) then
							var2_upvw.applyDamage(v_10, 10)
							var2_upvw.applyStatus(v_10, "Ragdoll", 3)
							var2_upvw.Knockback(v_10, clone_10_upvr.Position, 22, 92)
							var2_upvw.camShake(v_10, "Explosion")
							var2_upvw.impactFrame(v_10)
							if v_10.Humanoid.Health <= 1 and not v_10:FindFirstChild("burnVfx") then
								v_10.Humanoid.HealthDisplayType = "AlwaysOff"
								for _, v_11 in v_10:GetDescendants() do
									if v_11:IsA("Shirt") or v_11:IsA("Pants") then
										v_11:Destroy()
									else
										local function INLINED_4() -- Internal function, doesn't exist in bytecode
											TweenService_upvr:Create(v_11, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), tbl_6):Play()
											tbl_6.Transparency = 1
											local tbl_6 = {}
											v_11.Color = Color3.new(1, 0.207843, 0.207843)
											v_11.Material = "Neon"
											return v_11.Name == "Torso"
										end
										if v_11:IsA("BasePart") and (INLINED_4() or v_11.Name == "Left Arm" or v_11.Name == "Right Arm" or v_11.Name == "Head" or v_11.Name == "Left Leg" or v_11.Name == "Right Leg") then
											local clone_5_upvr = Ultimate_upvr.burnVfx:Clone()
											clone_5_upvr.Parent = v_11
											clone_5_upvr.Enabled = true
											task.delay(2, function() -- Line 291
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
			end)
		end
		for _, v_12 in var2_upvw.findEnemiesMagnitude(clone_10_upvr.Position, 60, true), nil do
			if not var2_upvw.CheckBlock(v_12, true) then
				var2_upvw.applyDamage(v_12, 10)
				var2_upvw.applyStatus(v_12, "Ragdoll", 3)
				var2_upvw.Knockback(v_12, clone_10_upvr.Position, 22, 92)
				var2_upvw.camShake(v_12, "Explosion")
				var2_upvw.impactFrame(v_12)
				if v_12.Humanoid.Health <= 1 and not v_12:FindFirstChild("burnVfx") then
					v_12.Humanoid.HealthDisplayType = "AlwaysOff"
					for _, v_13 in v_12:GetDescendants() do
						if v_13:IsA("Shirt") or v_13:IsA("Pants") then
							v_13:Destroy()
						else
							local function INLINED_5() -- Internal function, doesn't exist in bytecode
								TweenService_upvr:Create(v_13, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), tbl_2):Play()
								tbl_2.Transparency = 1
								local tbl_2 = {}
								v_13.Color = Color3.new(1, 0.207843, 0.207843)
								v_13.Material = "Neon"
								return v_13.Name == "Torso"
							end
							if v_13:IsA("BasePart") and (INLINED_5() or v_13.Name == "Left Arm" or v_13.Name == "Right Arm" or v_13.Name == "Head" or v_13.Name == "Left Leg" or v_13.Name == "Right Leg") then
								local clone_upvr = Ultimate_upvr.burnVfx:Clone()
								clone_upvr.Parent = v_13
								clone_upvr.Enabled = true
								task.delay(2, function() -- Line 333
									--[[ Upvalues[1]:
										[1]: clone_upvr (readonly)
									]]
									clone_upvr.Enabled = false
								end)
							end
						end
					end
				end
			end
		end
		task.wait(1)
		TweenService_upvr:Create(any_applySound_result1_upvr, TweenInfo.new(6), {
			Volume = 2.4;
		}):Play()
	end)
	while wait() and clone_10_upvr.Parent do
		clone_10_upvr.CFrame = (CFrame.new(HumanoidRootPart_upvr.Position) * clone_10_upvr.CFrame - clone_10_upvr.CFrame.p) * CFrame.Angles(0, 0.10471975511965978, 0)
	end
end
return module_upvr
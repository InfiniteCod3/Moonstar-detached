-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:13
-- Luau version 6, Types version 3
-- Time taken: 0.012596 seconds

local module_upvr = {}
local var2_upvw
module_upvr.Cooldown = 14
module_upvr.GlobalCD = 0.5
function createPlanet(arg1, arg2) -- Line 12
	local Part = Instance.new("Part", arg1)
	Part.CanQuery = false
	Part.CanCollide = false
	Part.Anchored = false
	Part.Massless = true
	Part.CFrame = arg1.CFrame
	Part.Transparency = 1
	Part.Size = Vector3.new(1, 1, 1)
	Part.Name = arg2
	local Motor6D = Instance.new("Motor6D", Part)
	Motor6D.Part0 = arg1
	Motor6D.Part1 = Part
	Motor6D.Name = arg2
	return Part, Motor6D
end
function lerp(arg1, arg2, arg3) -- Line 31
	return arg1 + (arg2 - arg1) * arg3
end
function planetGrow(arg1) -- Line 35
	--[[ Upvalues[2]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
	]]
	arg1.Particle.Particle:Emit(1)
	task.delay(0.2, function() -- Line 52
		--[[ Upvalues[3]:
			[1]: arg1 (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: module_upvr (copied, readonly)
		]]
		local tick_result1_upvr_2 = tick()
		local Size_upvr = arg1.Size
		local any_conTimer_result1_upvr = var2_upvw.conTimer(game:GetService("RunService").Stepped:Connect(function(arg1_2, arg2) -- Line 59
			--[[ Upvalues[3]:
				[1]: tick_result1_upvr_2 (readonly)
				[2]: arg1 (copied, readonly)
				[3]: Size_upvr (readonly)
			]]
			arg1.Size = Size_upvr:Lerp(Size_upvr * 1.7, (tick() - tick_result1_upvr_2) / 0.15)
		end), module_upvr.Cooldown)
		task.delay(0.15, function() -- Line 63
			--[[ Upvalues[1]:
				[1]: any_conTimer_result1_upvr (readonly)
			]]
			any_conTimer_result1_upvr:Disconnect()
		end)
	end)
end
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 70
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local Celestial_Collide_upvr = ReplicatedStorage_upvr.Skills.Nebula:FindFirstChild("Celestial Collide")
	local createPlanet_result1_upvr_2, createPlanet_result2_upvr_2 = createPlanet(arg1.HumanoidRootPart, "Planet1")
	local createPlanet_result1_upvr, createPlanet_result2_upvr = createPlanet(arg1.HumanoidRootPart, "Planet2")
	wait()
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Celestial_Collide_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.6)
	var2_upvw.applyStatus(arg1, "Slowed", 1.6)
	var2_upvw.applyStatus(arg1, "CombatStun", 2)
	local clone_6_upvr = Celestial_Collide_upvr.Planet1:Clone()
	local clone_7_upvr = Celestial_Collide_upvr.Planet2:Clone()
	clone_6_upvr.Parent = workspace
	clone_7_upvr.Parent = workspace
	clone_6_upvr.CFrame = createPlanet_result1_upvr_2.CFrame
	clone_7_upvr.CFrame = createPlanet_result1_upvr.CFrame
	local tick_result1_upvr = tick()
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local var26_upvw = 0
	local function _(arg1_4) -- Line 111
		--[[ Upvalues[6]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Celestial_Collide_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: var26_upvw (read and write)
			[6]: Folder_upvr (readonly)
		]]
		if arg1_4 == "Explode" then
			var2_upvw.camShake(arg1, "Bump")
			var2_upvw.flashScreen(arg1, Color3.new(0.713725, 0.713725, 0.713725), 0.25)
			var2_upvw.changeFov(arg1, 60, 0.01, 1)
			local clone_5 = Celestial_Collide_upvr.Explosion:Clone()
			clone_5.Parent = workspace
			clone_5.CFrame = arg1.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
			for _, v_upvr in pairs(clone_5:GetDescendants()) do
				if v_upvr:IsA("ParticleEmitter") then
					task.delay(v_upvr:GetAttribute("EmitDelay"), function() -- Line 122
						--[[ Upvalues[1]:
							[1]: v_upvr (readonly)
						]]
						v_upvr:Emit(v_upvr:GetAttribute("EmitCount"))
					end)
				end
			end
			game.Debris:AddItem(clone_5, 6)
			local clone_3 = Celestial_Collide_upvr.Charge:Clone()
			clone_3.Parent = arg1.HumanoidRootPart
			clone_3:Play()
			game.Debris:AddItem(clone_3, 6)
			local clone_8 = Celestial_Collide_upvr.Explode:Clone()
			clone_8.Parent = arg1.HumanoidRootPart
			clone_8:Play()
			game.Debris:AddItem(clone_8, 6)
			var2_upvw.applySound(Celestial_Collide_upvr.Explode2, HumanoidRootPart_upvr)
			for i_2, v_2 in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 7, 20, true), nil do
				if not var2_upvw.CheckBlock(v_2, true) then
					var2_upvw.applyDamage(v_2, 9)
					var2_upvw.applyStatus(v_2, "Stunned", 2)
					var2_upvw.applyStatus(v_2, "Ragdoll", 2)
					local clone_4 = Celestial_Collide_upvr.HitVFX.hitVFX:Clone()
					clone_4.Parent = v_2.Torso
					var2_upvw.EmitAllDescendants(clone_4)
					local hitSfx_2 = clone_4.hitSfx
					hitSfx_2.PlaybackSpeed += math.random(-1, 1) * 0.1
					clone_4.hitSfx:Play()
					var2_upvw.applyDebris(clone_4, 2)
					var2_upvw.camShake(v_2, "SmallBump")
					var2_upvw.changeFov(v_2, 60, 0.01, 0.5)
					var2_upvw.flashScreen(v_2, Color3.new(0.866667, 0.866667, 0.866667), 0.3)
					var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -50, 50, 0)
				end
			end
		else
			if arg1_4 == "HitboxStart" then
				var26_upvw += 1
				local clone_2 = Celestial_Collide_upvr.SwingHitbox:Clone()
				clone_2.Parent = Folder_upvr
				clone_2.weld.Part0 = HumanoidRootPart_upvr
				clone_2.weld.Part1 = clone_2
				var2_upvw.applyDebris(clone_2, 10)
				for _, v_3 in var2_upvw.findEnemiesPart(clone_2), nil do
					v_2 = var2_upvw
					i_2 = v_2.CheckBlock
					v_2 = v_3
					i_2 = i_2(v_2)
					if not i_2 then
						v_2 = var2_upvw.applyDamage
						v_2(v_3, 3)
						v_2 = var2_upvw.applyStatus
						v_2(v_3, "Stunned", 1)
						v_2 = Celestial_Collide_upvr.HitVFX.hitVFX:Clone()
						v_2.Parent = v_3.Torso
						var2_upvw.EmitAllDescendants(v_2)
						local hitSfx = v_2.hitSfx
						hitSfx.PlaybackSpeed += math.random(-1, 1) * 0.1
						v_2.hitSfx:Play()
						var2_upvw.applyDebris(v_2, 2)
						var2_upvw.camShake(v_3, "SmallBump")
						var2_upvw.changeFov(v_3, 60, 0.01, 0.5)
						var2_upvw.flashScreen(v_3, Color3.new(0.866667, 0.866667, 0.866667), 0.3)
						var2_upvw.Knockback(v_3, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -50, 14, 0)
					end
				end
				return
			end
			if arg1_4 == "Woosh" then
				local clone = Celestial_Collide_upvr.Woosh:Clone()
				clone.Parent = arg1.HumanoidRootPart
				clone.PlaybackSpeed = Random.new():NextNumber(0.8, 1.1)
				clone:Play()
				game.Debris:AddItem(clone, 6)
			end
		end
	end
	task.spawn(function() -- Line 203
		--[[ Upvalues[2]:
			[1]: clone_6_upvr (readonly)
			[2]: clone_7_upvr (readonly)
		]]
		wait(0.2)
		for _ = 1, 2 do
			planetGrow(clone_6_upvr)
			planetGrow(clone_7_upvr)
			task.wait(0.35)
		end
	end)
	local any_conTimer_result1_upvr_2 = var2_upvw.conTimer(game:GetService("RunService").Stepped:Connect(function(arg1_3, arg2_2) -- Line 103
		--[[ Upvalues[5]:
			[1]: tick_result1_upvr (readonly)
			[2]: clone_6_upvr (readonly)
			[3]: createPlanet_result1_upvr_2 (readonly)
			[4]: clone_7_upvr (readonly)
			[5]: createPlanet_result1_upvr (readonly)
		]]
		local clamped = math.clamp((tick() - tick_result1_upvr) / 0.2, 0, 1)
		clone_6_upvr.CFrame = clone_6_upvr.CFrame:Lerp(createPlanet_result1_upvr_2.CFrame, arg2_2 * 25)
		clone_7_upvr.CFrame = clone_7_upvr.CFrame:Lerp(createPlanet_result1_upvr.CFrame, arg2_2 * 25)
		clone_6_upvr.Transparency = 1 - clamped
		clone_7_upvr.Transparency = 1 - clamped
	end), module_upvr.Cooldown)
	any_LoadAnimation_result1.Stopped:Once(function() -- Line 212
		--[[ Upvalues[7]:
			[1]: any_conTimer_result1_upvr_2 (readonly)
			[2]: createPlanet_result1_upvr_2 (readonly)
			[3]: createPlanet_result1_upvr (readonly)
			[4]: createPlanet_result2_upvr_2 (readonly)
			[5]: createPlanet_result2_upvr (readonly)
			[6]: clone_6_upvr (readonly)
			[7]: clone_7_upvr (readonly)
		]]
		any_conTimer_result1_upvr_2:Disconnect()
		createPlanet_result1_upvr_2:Destroy()
		createPlanet_result1_upvr:Destroy()
		createPlanet_result2_upvr_2:Destroy()
		createPlanet_result2_upvr:Destroy()
		clone_6_upvr:Destroy()
		clone_7_upvr:Destroy()
	end)
end
return module_upvr
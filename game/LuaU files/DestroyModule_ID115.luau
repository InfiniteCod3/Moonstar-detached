-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:56
-- Luau version 6, Types version 3
-- Time taken: 0.050695 seconds

local module_upvr = {
	Cooldown = 20;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 18
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Destroy_upvr = ReplicatedStorage_upvr.Skills["Soul Lantern"].Ultimate:FindFirstChild("Destroy")
	local function DeathEffects_upvr(arg1_2) -- Line 32, Named "DeathEffects"
		--[[ Upvalues[2]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: Destroy_upvr (readonly)
		]]
		if arg1_2.Humanoid.Health <= 1 and not arg1_2:FindFirstChild("burnVfx") and not arg1_2:GetAttribute("DeathEffect") then
			arg1_2:SetAttribute("DeathEffect", true)
			arg1_2.Humanoid.HealthDisplayType = "AlwaysOff"
			for _, v in arg1_2:GetDescendants() do
				if v:IsA("Shirt") or v:IsA("Pants") then
					v:Destroy()
				else
					local function INLINED() -- Internal function, doesn't exist in bytecode
						TweenService_upvr:Create(v, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), tbl):Play()
						tbl.Transparency = 1
						tbl.Color = Color3.new(0, 0, 0)
						local tbl = {}
						v.Color = Color3.new(1, 0.172549, 0.172549)
						v.Material = "Neon"
						return v.Name == "Torso"
					end
					if v:IsA("BasePart") and (INLINED() or v.Name == "Left Arm" or v.Name == "Right Arm" or v.Name == "Head" or v.Name == "Left Leg" or v.Name == "Right Leg") then
						local clone_5_upvr = Destroy_upvr.burnVfx:Clone()
						clone_5_upvr.Parent = v
						clone_5_upvr.Enabled = true
						task.delay(2, function() -- Line 51
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
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Destroy_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	var2_upvw.applyStatus(arg1, "Stunned", 1.35)
	var2_upvw.changeFov(arg1, 60, 0.3, 5)
	local var17_upvw = false
	local any_applySound_result1_upvr = var2_upvw.applySound(Destroy_upvr.PullSFX, HumanoidRootPart_upvr, 5)
	any_LoadAnimation_result1_upvr.Stopped:Once(function() -- Line 71
		--[[ Upvalues[2]:
			[1]: var17_upvw (read and write)
			[2]: any_applySound_result1_upvr (readonly)
		]]
		if not var17_upvw then
			any_applySound_result1_upvr:Destroy()
		end
	end)
	local tbl_3_upvr = {}
	local tbl_2_upvr = {}
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Pull"):Once(function() -- Line 80
		--[[ Upvalues[12]:
			[1]: var17_upvw (read and write)
			[2]: Destroy_upvr (readonly)
			[3]: Folder_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: tbl_2_upvr (readonly)
			[7]: DeathEffects_upvr (readonly)
			[8]: arg1 (readonly)
			[9]: tbl_3_upvr (readonly)
			[10]: TweenService_upvr (copied, readonly)
			[11]: module_upvr (copied, readonly)
			[12]: any_LoadAnimation_result1_upvr (readonly)
		]]
		var17_upvw = true
		for _ = 1, 2 do
			task.spawn(function() -- Line 84
				--[[ Upvalues[6]:
					[1]: Destroy_upvr (copied, readonly)
					[2]: Folder_upvr (copied, readonly)
					[3]: var2_upvw (copied, read and write)
					[4]: HumanoidRootPart_upvr (copied, readonly)
					[5]: tbl_2_upvr (copied, readonly)
					[6]: DeathEffects_upvr (copied, readonly)
				]]
				for _ = 1, 4 do
					local clone_3 = Destroy_upvr.Geyser:Clone()
					clone_3.Parent = Folder_upvr
					var2_upvw.applyDebris(clone_3, 5)
					local function GetRandom(arg1_3, arg2_2) -- Line 90
						local randint_2 = math.random(arg1_3, arg2_2)
						if randint_2 == 0 then
							randint_2 = 1
						end
						return randint_2
					end
					local randint = math.random(-8, 8)
					if randint == 0 then
						randint = 1
					end
					local randint_6 = math.random(-8, 8)
					if randint_6 == 0 then
						randint_6 = 1
					end
					clone_3.CFrame = CFrame.new(HumanoidRootPart_upvr.Position + Vector3.new(randint * 20, -3, randint_6 * 20)) * clone_3.CFrame - clone_3.CFrame.p
					var2_upvw.EmitAllDescendants(clone_3)
					var2_upvw.CreateDebris(clone_3.Position + Vector3.new(0, 1, 0), 5, 1.5, 1.25, 0.08)
					var2_upvw.crater(1, clone_3.Position + Vector3.new(0, 1, 0), 4, 1.8)
					local Rocks_3 = clone_3.Rocks
					Rocks_3.PlaybackSpeed += math.random(-1, 1) * 0.1
					clone_3.Rocks:Play()
					local Magic_4 = clone_3.Magic
					Magic_4.PlaybackSpeed += math.random(-1, 1) * 0.1
					clone_3.Magic:Play()
					for _, v_2 in var2_upvw.findEnemiesPart(clone_3.Hitbox, true), nil do
						if not table.find(tbl_2_upvr, v_2) and not var2_upvw.CheckBlock(v_2, true) then
							var2_upvw.applyDamage(v_2, 10)
							var2_upvw.applyStatus(v_2, "Ragdoll", 3)
							var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, 22, 92)
							var2_upvw.camShake(v_2, "Explosion")
							var2_upvw.impactFrame(v_2)
							DeathEffects_upvr(v_2)
						end
					end
					wait(0.1)
				end
			end)
		end
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 200, 0.05, 2)
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.0627451, 0.0627451), 0.5)
		for i_5, v_3_upvr in var2_upvw.findEnemiesPart(var2_upvw.applyVFX(Destroy_upvr.PullVFX, Folder_upvr, 5, HumanoidRootPart_upvr.CFrame).Hitbox, true), nil do
			if not var2_upvw.CheckBlock(v_3_upvr) then
				table.insert(tbl_2_upvr, v_3_upvr)
				var2_upvw.unragdoll(v_3_upvr)
				var2_upvw.applyDamage(v_3_upvr, 10, false, true)
				var2_upvw.applyStatus(v_3_upvr, "Stunned", 4)
				var2_upvw.applyStatus(v_3_upvr, "AutoRotate", 4)
				table.insert(tbl_3_upvr, var2_upvw.applyStatus(v_3_upvr, "IFrames", 4))
				var2_upvw.camShake(v_3_upvr, "Bump")
				v_3_upvr.Humanoid.DisplayDistanceType = "None"
				v_3_upvr.Humanoid.HealthDisplayType = "AlwaysOff"
				task.delay(4, function() -- Line 151
					--[[ Upvalues[1]:
						[1]: v_3_upvr (readonly)
					]]
					v_3_upvr.Humanoid.DisplayDistanceType = "Viewer"
					v_3_upvr.Humanoid.HealthDisplayType = "DisplayWhenDamaged"
				end)
				v_3_upvr.HumanoidRootPart.CFrame = CFrame.lookAt(v_3_upvr.HumanoidRootPart.Position, Vector3.new(HumanoidRootPart_upvr.Position.X, v_3_upvr.HumanoidRootPart.Position.Y, HumanoidRootPart_upvr.Position.Z))
				local clone_4_upvr = Destroy_upvr.Soul2:Clone()
				clone_4_upvr.Parent = Folder_upvr
				clone_4_upvr.CFrame = v_3_upvr.Torso.CFrame
				var2_upvw.applyDebris(clone_4_upvr, 3)
				local var41_upvr = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 3) * CFrame.Angles((math.pi/2), math.pi, 0)
				local any_Create_result1 = TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(0.3), {
					CFrame = var41_upvr;
				})
				any_Create_result1:Play()
				var2_upvw.applySound(Destroy_upvr.Travel, v_3_upvr.Torso)
				local clone_7_upvr = Destroy_upvr.TeleportVFX.Att:Clone()
				clone_7_upvr.Parent = v_3_upvr.Torso
				var2_upvw.EmitAllDescendants(clone_7_upvr)
				var2_upvw.applyDebris(clone_7_upvr, 5)
				var2_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 174
					--[[ Upvalues[8]:
						[1]: var2_upvw (copied, read and write)
						[2]: v_3_upvr (readonly)
						[3]: clone_4_upvr (readonly)
						[4]: arg1 (copied, readonly)
						[5]: clone_7_upvr (readonly)
						[6]: Destroy_upvr (copied, readonly)
						[7]: var41_upvr (readonly)
						[8]: HumanoidRootPart_upvr (copied, readonly)
					]]
					var2_upvw.unragdoll(v_3_upvr)
					clone_4_upvr.Transparency = 1
					for _, v_4 in clone_4_upvr:GetChildren() do
						if v_4:IsA("ParticleEmitter") or v_4:IsA("Trail") then
							v_4.Enabled = false
						elseif v_4:IsA("Sound") then
							v_4:Stop()
						end
					end
					var2_upvw.changeFov(arg1, 69, 0, 1)
					var2_upvw.camShake(arg1, "SmallBump")
					var2_upvw.EmitAllDescendants(clone_7_upvr)
					var2_upvw.applySound(Destroy_upvr.Teleport, v_3_upvr.Torso)
					v_3_upvr.HumanoidRootPart.CFrame = var41_upvr
					local BodyPosition = Instance.new("BodyPosition", v_3_upvr.Torso)
					BodyPosition.MaxForce = Vector3.new(1000000, 1000000, 1000000)
					BodyPosition.Position = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 3 + Vector3.new(0, -2.7000, 0)
					BodyPosition.P += 15000
					BodyPosition.D -= 1000
					var2_upvw.applyDebris(BodyPosition, 2)
					var2_upvw.applyStatus(v_3_upvr, "Ragdoll", 3)
					var2_upvw.applyStatus(v_3_upvr, "DashDB", 3)
				end), module_upvr.Cooldown)
			end
		end
		if 0 < #tbl_2_upvr then
			i_5 = 4
			var2_upvw.applyStatus(arg1, "Freeze", i_5)
			i_5 = 4
			var2_upvw.applyStatus(arg1, "GlobalCD", i_5)
			i_5 = 4
			var2_upvw.applyStatus(arg1, "IFrames", i_5)
			any_LoadAnimation_result1_upvr:AdjustSpeed(0.1)
			task.wait(1)
			any_LoadAnimation_result1_upvr:AdjustSpeed(1)
		else
			task.wait(0.25)
			any_LoadAnimation_result1_upvr:Stop()
		end
	end)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Stomp"):Connect(function() -- Line 219
		--[[ Upvalues[7]:
			[1]: Destroy_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: tbl_2_upvr (readonly)
			[6]: DeathEffects_upvr (readonly)
			[7]: arg1 (readonly)
		]]
		for _ = 1, 2 do
			task.spawn(function() -- Line 221
				--[[ Upvalues[6]:
					[1]: Destroy_upvr (copied, readonly)
					[2]: Folder_upvr (copied, readonly)
					[3]: var2_upvw (copied, read and write)
					[4]: HumanoidRootPart_upvr (copied, readonly)
					[5]: tbl_2_upvr (copied, readonly)
					[6]: DeathEffects_upvr (copied, readonly)
				]]
				for _ = 1, 8 do
					local clone = Destroy_upvr.Geyser:Clone()
					clone.Parent = Folder_upvr
					var2_upvw.applyDebris(clone, 5)
					local function _(arg1_4, arg2_3) -- Line 227, Named "GetRandom"
						local randint_4 = math.random(arg1_4, arg2_3)
						if randint_4 == 0 then
							randint_4 = 1
						end
						return randint_4
					end
					local randint_3 = math.random(-8, 8)
					if randint_3 == 0 then
						randint_3 = 1
					end
					local randint_5 = math.random(-8, 8)
					if randint_5 == 0 then
						randint_5 = 1
					end
					clone.CFrame = CFrame.new(HumanoidRootPart_upvr.Position + Vector3.new(randint_3 * 20, -3, randint_5 * 20)) * clone.CFrame - clone.CFrame.p
					var2_upvw.EmitAllDescendants(clone)
					var2_upvw.CreateDebris(clone.Position + Vector3.new(0, 1, 0), 5, 1.5, 1.25, 0.08)
					var2_upvw.crater(1, clone.Position + Vector3.new(0, 1, 0), 4, 1.8)
					local Rocks_4 = clone.Rocks
					Rocks_4.PlaybackSpeed += math.random(-1, 1) * 0.1
					clone.Rocks:Play()
					local Magic_3 = clone.Magic
					Magic_3.PlaybackSpeed += math.random(-1, 1) * 0.1
					clone.Magic:Play()
					for _, v_5 in var2_upvw.findEnemiesPart(clone.Hitbox, true), nil do
						if not table.find(tbl_2_upvr, v_5) and not var2_upvw.CheckBlock(v_5, true) then
							var2_upvw.applyDamage(v_5, 10)
							var2_upvw.applyStatus(v_5, "Ragdoll", 3)
							var2_upvw.Knockback(v_5, HumanoidRootPart_upvr.Position, 22, 92)
							var2_upvw.camShake(v_5, "Explosion")
							var2_upvw.impactFrame(v_5)
							DeathEffects_upvr(v_5)
						end
					end
					wait(0.05)
				end
			end)
		end
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 50, 0.05, 0.5)
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.0627451, 0.0627451), 0.5)
		var2_upvw.impactFrame(arg1)
		local clone_6 = Destroy_upvr.StompVFX:Clone()
		clone_6.Parent = Folder_upvr
		var2_upvw.applyDebris(clone_6, 5)
		clone_6.CFrame = CFrame.new(HumanoidRootPart_upvr.Position + Vector3.new(0, -3, 0) + HumanoidRootPart_upvr.CFrame.LookVector * 1) * clone_6.CFrame - clone_6.CFrame.p
		var2_upvw.EmitAllDescendants(clone_6)
		var2_upvw.CreateDebris(clone_6.Position + Vector3.new(0, 1, 0), 5, 1.5, 1.25, 0.08)
		var2_upvw.crater(1, clone_6.Position + Vector3.new(0, 1, 0), 4, 1.8)
		local Rocks = clone_6.Rocks
		Rocks.PlaybackSpeed += math.random(-1, 1) * 0.1
		clone_6.Rocks:Play()
		local Magic_2 = clone_6.Magic
		Magic_2.PlaybackSpeed += math.random(-1, 1) * 0.1
		clone_6.Magic:Play()
		local SmashSFX = clone_6.SmashSFX
		SmashSFX.PlaybackSpeed += math.random(-1, 1) * 0.1
		clone_6.SmashSFX:Play()
		local function HitTarget(arg1_5) -- Line 289
			--[[ Upvalues[3]:
				[1]: var2_upvw (copied, read and write)
				[2]: HumanoidRootPart_upvr (copied, readonly)
				[3]: DeathEffects_upvr (copied, readonly)
			]]
			if not var2_upvw.CheckBlock(arg1_5, true) then
				var2_upvw.applyDamage(arg1_5, 10, true, false)
				var2_upvw.applyStatus(arg1_5, "Ragdoll", 2)
				var2_upvw.applyStatus(arg1_5, "DashDB", 2)
				var2_upvw.Knockback(arg1_5, HumanoidRootPart_upvr.Position, 0, 5)
				var2_upvw.camShake(arg1_5, "Explosion")
				var2_upvw.impactFrame(arg1_5)
				DeathEffects_upvr(arg1_5)
			end
		end
		for _, v_6 in var2_upvw.findEnemiesPart(clone_6.Hitbox, true), nil do
			if not table.find(tbl_2_upvr, v_6) then
				HitTarget(v_6)
			end
		end
		for _, v_7 in tbl_2_upvr do
			if v_7.Parent and (v_7.HumanoidRootPart.Position - HumanoidRootPart_upvr.Position).Magnitude <= 40 then
				HitTarget(v_7)
			end
		end
	end), module_upvr.Cooldown)
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Kick"):Once(function() -- Line 316
		--[[ Upvalues[7]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Destroy_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: DeathEffects_upvr (readonly)
			[7]: tbl_3_upvr (readonly)
		]]
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 50, 0.05, 0.5)
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.0627451, 0.0627451), 0.5)
		var2_upvw.impactFrame(arg1)
		local clone_2_upvr = Destroy_upvr.KickVFX:Clone()
		clone_2_upvr.Parent = Folder_upvr
		var2_upvw.applyDebris(clone_2_upvr, 5)
		clone_2_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 2
		var2_upvw.EmitAllDescendants(clone_2_upvr)
		var2_upvw.CreateDebris(clone_2_upvr.Position + Vector3.new(0, 1, 0), 5, 1.5, 1.25, 0.08)
		var2_upvw.crater(1, clone_2_upvr.Position + Vector3.new(0, 1, 0), 4, 1.8)
		local Rocks_2 = clone_2_upvr.Rocks
		Rocks_2.PlaybackSpeed += math.random(-1, 1) * 0.1
		clone_2_upvr.Rocks:Play()
		local Magic = clone_2_upvr.Magic
		Magic.PlaybackSpeed += math.random(-1, 1) * 0.1
		clone_2_upvr.Magic:Play()
		local SmashSFX_2 = clone_2_upvr.SmashSFX
		SmashSFX_2.PlaybackSpeed += math.random(-1, 1) * 0.1
		clone_2_upvr.SmashSFX:Play()
		local function HitTarget(arg1_6) -- Line 339
			--[[ Upvalues[3]:
				[1]: var2_upvw (copied, read and write)
				[2]: clone_2_upvr (readonly)
				[3]: DeathEffects_upvr (copied, readonly)
			]]
			if not var2_upvw.CheckBlock(arg1_6, true) then
				var2_upvw.applyDamage(arg1_6, 15, true, false)
				var2_upvw.applyStatus(arg1_6, "Ragdoll", 2)
				var2_upvw.Knockback(arg1_6, clone_2_upvr.Position + clone_2_upvr.CFrame.LookVector * -100, 50, 20)
				var2_upvw.camShake(arg1_6, "Explosion")
				var2_upvw.impactFrame(arg1_6)
				DeathEffects_upvr(arg1_6)
			end
		end
		for _, v_8 in tbl_3_upvr do
			var2_upvw.applyDebris(v_8, 0, arg1)
		end
		wait()
		for _, v_9 in var2_upvw.findEnemiesPart(clone_2_upvr.Hitbox, true), nil do
			HitTarget(v_9)
		end
	end)
end
return module_upvr
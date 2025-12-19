-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:09
-- Luau version 6, Types version 3
-- Time taken: 0.036746 seconds

local module_upvr = {
	Cooldown = 75;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 15
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
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Finale_upvr = ReplicatedStorage_upvr.Skills["Firework Rapier"].Ultimate.Finale
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Finale_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	local Firework_Rapier_upvr = arg1:FindFirstChild("Firework Rapier")
	local function ToggleTrails_upvr(arg1_2) -- Line 32, Named "ToggleTrails"
		--[[ Upvalues[1]:
			[1]: Firework_Rapier_upvr (readonly)
		]]
		for _, v in Firework_Rapier_upvr:GetDescendants() do
			if v:IsA("Trail") and v.Name == "Trail" then
				v.Enabled = arg1_2
			end
		end
	end
	ToggleTrails_upvr(true)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 41
		--[[ Upvalues[1]:
			[1]: ToggleTrails_upvr (readonly)
		]]
		ToggleTrails_upvr(false)
	end), module_upvr.Cooldown)
	local clone_6 = Finale_upvr.SwingCharge:Clone()
	clone_6.Parent = HumanoidRootPart_upvr
	clone_6:Play()
	var2_upvw.applyDebris(clone_6, 5)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("swing"):Connect(function() -- Line 52
		--[[ Upvalues[3]:
			[1]: Finale_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
		]]
		local clone_3 = Finale_upvr.Swing:Clone()
		clone_3.Parent = HumanoidRootPart_upvr
		clone_3:Play()
		var2_upvw.applyDebris(clone_3, 5)
	end), module_upvr.Cooldown)
	var2_upvw.applyStatus(arg1, "Slowed", 1.4)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.4)
	var2_upvw.applyStatus(arg1, "HyperArmor", 1.4)
	var2_upvw.changeFov(arg1, 90, 0.5, 3)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function() -- Line 66
		--[[ Upvalues[10]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: Finale_upvr (readonly)
			[3]: Folder_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: var2_upvw (copied, read and write)
			[6]: arg1 (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
			[9]: RunService_upvr (copied, readonly)
			[10]: ReplicatedStorage_upvr (copied, readonly)
		]]
		any_LoadAnimation_result1_upvr:AdjustSpeed(0.35)
		task.wait(0.05)
		local clone = Finale_upvr.SlashVFX:Clone()
		clone.Parent = Folder_upvr
		clone.CFrame = HumanoidRootPart_upvr.CFrame
		var2_upvw.EmitAllDescendants(clone.Attachment)
		var2_upvw.applyDebris(clone, 5)
		for _, v_2 in clone.Attachment:GetChildren() do
			if v_2:IsA("Sound") then
				v_2:Play()
			end
		end
		var2_upvw.applyStatus(arg1, "GlobalCD", 0.5)
		var2_upvw.applyStatus(arg1, "Freeze", 0.5)
		var2_upvw.applyStatus(arg1, "AutoRotate", 0.5)
		var2_upvw.camShake(arg1, "Explosion")
		var2_upvw.changeFov(arg1, 60, 0.1, 2)
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.654902, 0.309804), 3)
		var2_upvw.Blur(arg1, 25, 1)
		task.wait()
		local clone_5_upvr = Finale_upvr.FireworkBall:Clone()
		clone_5_upvr.Parent = Folder_upvr
		clone_5_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 5
		var2_upvw.applyDebris(clone_5_upvr, 20)
		clone_5_upvr.FireballWhoosh:Play()
		local tbl_upvr_2 = {}
		local tbl_upvr = {}
		local function FinaleExplosion_upvr() -- Line 100, Named "FinaleExplosion"
			--[[ Upvalues[10]:
				[1]: clone_5_upvr (readonly)
				[2]: Finale_upvr (copied, readonly)
				[3]: Folder_upvr (copied, readonly)
				[4]: var2_upvw (copied, read and write)
				[5]: TweenService_upvr (copied, readonly)
				[6]: arg1 (copied, readonly)
				[7]: tbl_upvr (readonly)
				[8]: module_upvr (copied, readonly)
				[9]: tbl_upvr_2 (readonly)
				[10]: HumanoidRootPart_upvr (copied, readonly)
			]]
			clone_5_upvr.Attachment.MovingShockwave.Enabled = false
			for _ = 1, 75 do
				local clone_7_upvr = Finale_upvr.SmallFireworkBall:Clone()
				clone_7_upvr.Parent = Folder_upvr
				local shoot = clone_7_upvr.shoot
				shoot.PlaybackSpeed += math.random(-4, 4) * 0.1
				clone_7_upvr.shoot:Play()
				clone_7_upvr["sizzle sfx"]:Play()
				var2_upvw.applyDebris(clone_7_upvr, 7)
				clone_7_upvr.CFrame = clone_5_upvr.CFrame * CFrame.Angles(math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)), math.rad(math.random(-360, 360)))
				local any_Create_result1 = TweenService_upvr:Create(clone_7_upvr, TweenInfo.new(math.random(4, 5) * 0.1, Enum.EasingStyle.Linear), {
					Position = clone_7_upvr.Position + clone_7_upvr.CFrame.LookVector * math.random(60, 110);
				})
				any_Create_result1:Play()
				var2_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 121
					--[[ Upvalues[4]:
						[1]: clone_7_upvr (readonly)
						[2]: var2_upvw (copied, read and write)
						[3]: arg1 (copied, readonly)
						[4]: tbl_upvr (copied, readonly)
					]]
					clone_7_upvr["sizzle sfx"]:Stop()
					var2_upvw.EmitAllDescendants(clone_7_upvr.FireworkBall.ExplosionVFX)
					for _, v_3 in clone_7_upvr.FireworkBall:GetDescendants() do
						if v_3:IsA("ParticleEmitter") or v_3:IsA("Trail") then
							v_3.Enabled = false
						end
					end
					local ExplodeSFX = clone_7_upvr.FireworkBall.ExplosionVFX.ExplodeSFX
					ExplodeSFX.PlaybackSpeed += math.random(-2, 2) * 0.1
					ExplodeSFX:Play()
					var2_upvw.camShake(arg1, "SmallBump")
					var2_upvw.flashScreen(arg1, Color3.new(1, 0.882353, 0.796078), 0.1)
					for _, v_4 in tbl_upvr do
						var2_upvw.applyDamage(v_4, 1)
						var2_upvw.camShake(v_4, "SmallBump")
						var2_upvw.flashScreen(v_4, Color3.new(1, 0.882353, 0.796078), 0.1)
					end
				end), module_upvr.Cooldown)
				task.wait(0.03)
			end
			for _, _ in tbl_upvr do
			end
			task.wait(1)
			for _, v_6 in clone_5_upvr:GetDescendants() do
				if v_6:IsA("ParticleEmitter") then
					v_6.Enabled = false
				elseif v_6.Name == "PlayerWeld" then
					v_6:Destroy()
				end
			end
			for _, v_7 in tbl_upvr_2 do
				var2_upvw.applyDebris(v_7, 0)
			end
			clone_5_upvr.ExplodeAtt.ExplodeSFX:Play()
			var2_upvw.EmitAllDescendants(clone_5_upvr.ExplodeAtt)
			var2_upvw.camShake(arg1, "Explosion")
			var2_upvw.flashScreen(arg1, Color3.new(1, 0.713725, 0.482353), 2)
			var2_upvw.changeFov(arg1, 300, 0.1, 4)
			var2_upvw.Blur(arg1, 30, 1.2)
			for _, v_8 in tbl_upvr do
				var2_upvw.Knockback(v_8, HumanoidRootPart_upvr.Position, 0, 140)
				var2_upvw.applyDamage(v_8, 5)
				var2_upvw.camShake(v_8, "Explosion")
				var2_upvw.flashScreen(v_8, Color3.new(1, 0.717647, 0.529412), 2)
				var2_upvw.Blur(v_8, 30, 1.2)
				var2_upvw.changeFov(v_8, 300, 0.1, 4)
				local clone_8_upvr = Finale_upvr.TrailVFX:Clone()
				clone_8_upvr.Parent = Folder_upvr
				clone_8_upvr.weld.Part0 = v_8.HumanoidRootPart
				clone_8_upvr.weld.Part1 = clone_8_upvr
				var2_upvw.applyDebris(clone_8_upvr, 10)
				for _, v_9 in clone_8_upvr:GetDescendants() do
					if v_9:IsA("Trail") then
						v_9.Enabled = true
					end
				end
				var2_upvw.conTimer(var2_upvw.applyStatus(v_8, "Ragdoll", 4).Destroying:Connect(function() -- Line 196
					--[[ Upvalues[1]:
						[1]: clone_8_upvr (readonly)
					]]
					for _, v_10 in clone_8_upvr:GetDescendants() do
						if v_10:IsA("Trail") then
							v_10.Enabled = false
						end
					end
				end), module_upvr.Cooldown)
			end
		end
		local var68_upvw
		local var69_upvw = 175
		local var70_upvw = 0
		local var71_upvw = false
		var68_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 215
			--[[ Upvalues[12]:
				[1]: clone_5_upvr (readonly)
				[2]: var68_upvw (read and write)
				[3]: var69_upvw (read and write)
				[4]: var70_upvw (read and write)
				[5]: FinaleExplosion_upvr (readonly)
				[6]: var2_upvw (copied, read and write)
				[7]: tbl_upvr (readonly)
				[8]: ReplicatedStorage_upvr (copied, readonly)
				[9]: arg1 (copied, readonly)
				[10]: tbl_upvr_2 (readonly)
				[11]: Finale_upvr (copied, readonly)
				[12]: var71_upvw (read and write)
			]]
			if not clone_5_upvr.Parent then
				var68_upvw:Disconnect()
			else
				if var69_upvw <= 20 and var70_upvw <= 20 then
					var68_upvw:Disconnect()
					FinaleExplosion_upvr()
					return
				end
				for i_12, v_11 in var2_upvw.findEnemiesPart(clone_5_upvr.Hitbox, true), nil do
					if not table.find(tbl_upvr, v_11) and 1 < v_11.Humanoid.Health then
						table.insert(tbl_upvr, v_11)
						if not var2_upvw.CheckBlock(v_11, true) then
							var2_upvw.unragdoll(v_11)
							for _, v_12 in require(ReplicatedStorage_upvr.Modules.PlayerStatus).FindTable(v_11) do
								if v_12.Name == "IFrames" or v_12.Name == "HyperArmor" then
									var2_upvw.applyDebris(v_12, 0)
								end
							end
							var2_upvw.applyDamage(v_11, 5, false, true)
							var2_upvw.camShake(v_11, "Bump")
							var2_upvw.flashScreen(v_11, Color3.new(1, 0.654902, 0.309804), 2)
							var2_upvw.flashScreen(arg1, Color3.new(1, 0.654902, 0.309804), 0.6)
							table.insert(tbl_upvr_2, var2_upvw.applyStatus(v_11, "Stunned", 5))
							table.insert(tbl_upvr_2, var2_upvw.applyStatus(v_11, "AutoRotate", 5))
							clone_5_upvr.Attachment.HitParticle:Emit(5)
							local clone_4 = Finale_upvr.FireballHit:Clone()
							clone_4.Parent = v_11.HumanoidRootPart
							clone_4.PlaybackSpeed += math.random(-1, 1) * 0.1
							clone_4:Play()
							var2_upvw.applyDebris(clone_4, 5)
							local Motor6D = Instance.new("Motor6D", clone_5_upvr)
							Motor6D.Name = "PlayerWeld"
							Motor6D.Part1 = v_11.HumanoidRootPart
							Motor6D.Part0 = clone_5_upvr
							var2_upvw.applyDebris(Motor6D, 20)
						end
					end
				end
				if 12 < var69_upvw then
					v_11 = clone_5_upvr
					i_12 = v_11.Position
					v_11 = Vector3.new(0, 10, 0)
					v_11 = clone_5_upvr.CFrame.LookVector
					i_12 = v_11 * (var69_upvw * 0.12 + 10)
					v_11 = var2_upvw.raycastParams
					if workspace:Raycast(i_12 + v_11, i_12, v_11) then
						var69_upvw = 12
					end
				end
				if 50 <= var70_upvw then
					var71_upvw = true
				end
				if var71_upvw and 0 < var70_upvw then
					var70_upvw -= 1
				end
				if var69_upvw <= 100 and var70_upvw < 50 and not var71_upvw then
					var70_upvw += 1
				end
				if 0 < var69_upvw then
					var69_upvw -= 0.5
				end
				if var70_upvw ~= 0 or var69_upvw ~= 0 then
					i_12 = clone_5_upvr
					v_11 = clone_5_upvr.Position + clone_5_upvr.CFrame.LookVector * var69_upvw * 0.01
					i_12 = v_11 + Vector3.new(0, var70_upvw * 0.01, 0)
					clone_5_upvr.CFrame = CFrame.lookAt(i_12.Position, i_12)
					v_11 = clone_5_upvr
					i_12 = v_11.CFrame
					v_11 = clone_5_upvr.CFrame.LookVector * var69_upvw * 0.01
					v_11 = 0
					i_12 = Vector3.new(v_11, var70_upvw * 0.01, 0)
					clone_5_upvr.CFrame = i_12 + v_11 + i_12
				end
			end
		end), module_upvr.Cooldown)
	end), module_upvr.Cooldown)
end
return module_upvr
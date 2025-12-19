-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:06
-- Luau version 6, Types version 3
-- Time taken: 0.049001 seconds

local module_upvr = {
	Cooldown = 34;
	GlobalCD = 3;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local RunService_upvr = game:GetService("RunService")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 15
	--[[ Upvalues[5]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: RunService_upvr (readonly)
		[5]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Soul_Devastation_upvr = ReplicatedStorage_upvr.Skills["Soul Lantern"]["Soul Devastation"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Soul_Devastation_upvr.Animation)
	any_LoadAnimation_result1_upvr:AdjustSpeed(1.25)
	task.wait()
	any_LoadAnimation_result1_upvr:Play()
	var2_upvw.applyStatus(arg1, "Slowed", 3)
	local clone_upvr = Soul_Devastation_upvr.Soul:Clone()
	clone_upvr.Parent = Folder_upvr
	clone_upvr.Position = arg1:FindFirstChild("Soul Lantern").Vfx.Position + Vector3.new(math.random(-1, 1) * 0.2, math.random(-1, 1) * 0.2, math.random(-1, 1) * 0.2)
	clone_upvr.Presence:Play()
	clone_upvr.Anchored = false
	clone_upvr:SetNetworkOwner(arg2)
	game.Debris:AddItem(clone_upvr, 2)
	clone_upvr.Spawn:Play()
	local BodyPosition_upvr = Instance.new("BodyPosition", clone_upvr)
	BodyPosition_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BodyPosition_upvr.Position = arg1["Left Arm"].Position + arg1["Left Arm"].CFrame.LookVector * 0.2 + arg1["Left Arm"].CFrame.UpVector * -1.5
	BodyPosition_upvr.P += 15000
	BodyPosition_upvr.D -= 1000
	local var13_upvw
	var13_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 53
		--[[ Upvalues[4]:
			[1]: clone_upvr (readonly)
			[2]: var13_upvw (read and write)
			[3]: BodyPosition_upvr (readonly)
			[4]: arg1 (readonly)
		]]
		if not clone_upvr.Parent then
			var13_upvw:Disconnect()
		end
		BodyPosition_upvr.Position = arg1["Left Arm"].Position + arg1["Left Arm"].CFrame.LookVector * 0.2 + arg1["Left Arm"].CFrame.UpVector * -1.5
	end), module_upvr.Cooldown)
	local clone_upvr_4 = Soul_Devastation_upvr.beam:Clone()
	clone_upvr_4.Parent = Folder_upvr
	clone_upvr_4.CFrame = HumanoidRootPart_upvr.CFrame
	clone_upvr_4.weld.Part0 = HumanoidRootPart_upvr
	var2_upvw.applyDebris(clone_upvr_4, 10)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("fire"):Connect(function(arg1_2) -- Line 64
		--[[ Upvalues[10]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: clone_upvr_4 (readonly)
			[3]: ReplicatedStorage_upvr (copied, readonly)
			[4]: arg1 (readonly)
			[5]: var2_upvw (copied, read and write)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: Soul_Devastation_upvr (readonly)
			[9]: Folder_upvr (readonly)
			[10]: module_upvr (copied, readonly)
		]]
		if arg1_2 == '1' then
			any_LoadAnimation_result1_upvr:AdjustSpeed(1.5)
			clone_upvr_4.Spray:Play()
			clone_upvr_4.Spray2:Play()
			for _, v in clone_upvr_4:GetChildren() do
				if v:IsA("ParticleEmitter") and v.Name ~= "Explosion" then
					v.Enabled = true
				end
			end
			local PlayerStatus = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
			for _ = 1, 10 do
				if PlayerStatus.FindStatus(arg1, "Stunned") then break end
				if PlayerStatus.FindStatus(arg1, "Ragdoll") then break end
				var2_upvw.camShake(arg1, "SmallBump")
				var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 2, 1.2, 0.5, 0.08)
				-- KONSTANTERROR: Expression was reused, decompilation is incorrect
				clone_upvr_4.pebble:Clone().PlaybackSpeed = clone_upvr_4.pebble:Clone().PlaybackSpeed + math.random(-3, 3) * 0.1
				-- KONSTANTERROR: Expression was reused, decompilation is incorrect
				clone_upvr_4.pebble:Clone().Parent = HumanoidRootPart_upvr
				clone_upvr_4.pebble:Clone():Play()
				-- KONSTANTERROR: Expression was reused, decompilation is incorrect
				game.Debris:AddItem(clone_upvr_4.pebble:Clone(), 10)
				for var86, v_2_upvr in var2_upvw.findEnemiesPart(clone_upvr_4.hitbox), nil do
					var2_upvw.applyDamage(v_2_upvr, 1)
					var2_upvw.Knockback(v_2_upvr, HumanoidRootPart_upvr.Position, 6)
					var2_upvw.applyStatus(v_2_upvr, "Stunned", 0.5)
					var2_upvw.camShake(v_2_upvr, "SmallBump")
					v_2_upvr:SetAttribute("Mana", v_2_upvr:GetAttribute("Mana") + 5)
					if v_2_upvr.Humanoid.Health <= 1 and not v_2_upvr:FindFirstChild("burnVfx") and not v_2_upvr:GetAttribute("DeathEffect") then
						v_2_upvr:SetAttribute("DeathEffect", true)
						v_2_upvr.Humanoid.HealthDisplayType = "AlwaysOff"
						for _, v_3 in v_2_upvr:GetDescendants() do
							if v_3:IsA("Shirt") or v_3:IsA("Pants") then
								v_3:Destroy()
							else
								local function INLINED_3() -- Internal function, doesn't exist in bytecode
									TweenService_upvr:Create(v_3, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), tbl):Play()
									tbl.Transparency = 1
									local tbl = {}
									v_3.Color = Color3.new(0.2, 0.988235, 1)
									v_3.Material = "Neon"
									return v_3.Name == "Torso"
								end
								if v_3:IsA("BasePart") and (INLINED_3() or v_3.Name == "Left Arm" or v_3.Name == "Right Arm" or v_3.Name == "Head" or v_3.Name == "Left Leg" or v_3.Name == "Right Leg") then
									local clone_upvr_6 = Soul_Devastation_upvr.burnVfx:Clone()
									clone_upvr_6.Parent = v_3
									clone_upvr_6.Enabled = true
									task.delay(2, function() -- Line 114
										--[[ Upvalues[1]:
											[1]: clone_upvr_6 (readonly)
										]]
										clone_upvr_6.Enabled = false
									end)
								end
							end
						end
					end
				end
				wait(0.05)
			end
			any_LoadAnimation_result1_upvr:AdjustSpeed(0.2)
			TweenService_upvr:Create(clone_upvr_4.Spray, TweenInfo.new(1), {
				Volume = 0;
			}):Play()
			for _, v_4 in clone_upvr_4:GetChildren() do
				if v_4:IsA("ParticleEmitter") then
					v_4.Enabled = false
				end
			end
			task.wait(0.2)
			any_LoadAnimation_result1_upvr:AdjustSpeed(1.5)
		elseif arg1_2 == '2' then
			any_LoadAnimation_result1_upvr:AdjustSpeed(0.75)
			var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 12, 2, 0.5, 0.08)
			var2_upvw.crater(1, HumanoidRootPart_upvr.Position, 4.5, 1.2)
			var2_upvw.EmitAllDescendants(clone_upvr_4)
			var2_upvw.camShake(arg1, "Bump")
			clone_upvr_4.Cast:Play()
			clone_upvr_4.Rocks:Play()
			for _, v_5_upvr in var2_upvw.findEnemiesPart(clone_upvr_4.hitbox, true), nil do
				if not var2_upvw.CheckBlock(v_5_upvr) then
					var86 = 10
					var2_upvw.applyDamage(v_5_upvr, var86)
					var86 = "Stunned"
					v_2_upvr = 1.6
					var2_upvw.applyStatus(v_5_upvr, var86, v_2_upvr)
					var86 = "AutoRotate"
					v_2_upvr = 1.6
					var2_upvw.applyStatus(v_5_upvr, var86, v_2_upvr)
					var86 = "Bump"
					var2_upvw.camShake(v_5_upvr, var86)
					v_2_upvr = v_5_upvr.HumanoidRootPart
					var86 = v_2_upvr.Position
					v_2_upvr = Vector3.new(HumanoidRootPart_upvr.Position.X, v_5_upvr.HumanoidRootPart.Position.Y, HumanoidRootPart_upvr.Position.Z)
					v_5_upvr.HumanoidRootPart.CFrame = CFrame.lookAt(var86, v_2_upvr)
					function var86() -- Line 160
						--[[ Upvalues[2]:
							[1]: v_5_upvr (readonly)
							[2]: Soul_Devastation_upvr (copied, readonly)
						]]
						v_5_upvr.Humanoid:LoadAnimation(Soul_Devastation_upvr.Devestate):Play()
					end
					task.delay(0.1, var86)
					if 1 < v_5_upvr.Humanoid.Health then
						var86 = "Mana"
						v_2_upvr = v_5_upvr:GetAttribute("Mana") + 350
						v_5_upvr:SetAttribute(var86, v_2_upvr)
						local clone_upvr_7 = Soul_Devastation_upvr.Soul2:Clone()
						clone_upvr_7.Parent = Folder_upvr
						var86 = v_5_upvr.Torso
						clone_upvr_7.CFrame = var86.CFrame
						var86 = var2_upvw
						var86 = clone_upvr_7
						v_2_upvr = 3
						var86.applyDebris(var86, v_2_upvr)
						v_2_upvr = HumanoidRootPart_upvr.CFrame
						var86 = v_2_upvr + HumanoidRootPart_upvr.CFrame.LookVector * 7
						v_2_upvr = CFrame.Angles(0, math.pi, 0)
						local var88_upvr = var86 * v_2_upvr
						var86 = TweenService_upvr
						var86 = var86:Create(clone_upvr_7, TweenInfo.new(0.8), {
							CFrame = var88_upvr;
						})
						v_2_upvr = var86:Play
						v_2_upvr()
						v_2_upvr = var2_upvw.applySound
						v_2_upvr(Soul_Devastation_upvr.Travel, v_5_upvr.Torso)
						v_2_upvr = Soul_Devastation_upvr.TeleportVFX.Att:Clone()
						v_2_upvr.Parent = v_5_upvr.Torso
						var2_upvw.EmitAllDescendants(v_2_upvr)
						var2_upvw.applyDebris(v_2_upvr, 5)
						var2_upvw.conTimer(var86.Completed:Connect(function() -- Line 184
							--[[ Upvalues[7]:
								[1]: clone_upvr_7 (readonly)
								[2]: var2_upvw (copied, read and write)
								[3]: arg1 (copied, readonly)
								[4]: v_2_upvr (readonly)
								[5]: Soul_Devastation_upvr (copied, readonly)
								[6]: v_5_upvr (readonly)
								[7]: var88_upvr (readonly)
							]]
							clone_upvr_7.Transparency = 1
							for _, v_6 in clone_upvr_7:GetChildren() do
								if v_6:IsA("ParticleEmitter") or v_6:IsA("Trail") then
									v_6.Enabled = false
								elseif v_6:IsA("Sound") then
									v_6:Stop()
								end
							end
							var2_upvw.changeFov(arg1, 69, 0, 1)
							var2_upvw.camShake(arg1, "SmallBump")
							var2_upvw.EmitAllDescendants(v_2_upvr)
							var2_upvw.applySound(Soul_Devastation_upvr.Teleport, v_5_upvr.Torso)
							v_5_upvr.HumanoidRootPart.CFrame = var88_upvr
						end), module_upvr.Cooldown)
					end
					var88_upvr = v_5_upvr.Humanoid
					clone_upvr_7 = var88_upvr.Health
					var88_upvr = 1
					if clone_upvr_7 <= var88_upvr then
						var86 = "burnVfx"
						clone_upvr_7 = v_5_upvr:FindFirstChild(var86)
						if not clone_upvr_7 then
							clone_upvr_7 = v_5_upvr.Humanoid
							var88_upvr = "AlwaysOff"
							clone_upvr_7.HealthDisplayType = var88_upvr
							clone_upvr_7 = v_5_upvr:GetDescendants()
							for _, v_7 in v_5_upvr:GetDescendants() do
								if v_7:IsA("Shirt") or v_7:IsA("Pants") then
									v_7:Destroy()
								else
									local function INLINED_4() -- Internal function, doesn't exist in bytecode
										TweenService_upvr:Create(v_7, TweenInfo.new(clone_upvr_6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), var99):Play()
										var99.Transparency = 1
										var99.Color = Color3.new(0, 0, 0)
										local var99 = clone_upvr_6
										clone_upvr_6 = {}
										clone_upvr_6 = 3
										v_7.Color = Color3.new(0.2, 0.988235, 1)
										v_7.Material = "Neon"
										return v_7.Name == "Torso"
									end
									if v_7:IsA("BasePart") and (INLINED_4() or v_7.Name == "Left Arm" or v_7.Name == "Right Arm" or v_7.Name == "Head" or v_7.Name == "Left Leg" or v_7.Name == "Right Leg") then
										local clone_upvr_2 = Soul_Devastation_upvr.burnVfx:Clone()
										clone_upvr_2.Parent = v_7
										clone_upvr_2.Enabled = true
										task.delay(3, function() -- Line 222
											--[[ Upvalues[1]:
												[1]: clone_upvr_2 (readonly)
											]]
											clone_upvr_2.Enabled = false
										end)
									end
								end
							end
						end
					end
				end
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 235
		--[[ Upvalues[1]:
			[1]: clone_upvr_4 (readonly)
		]]
		if clone_upvr_4:FindFirstChild(arg1_3) then
			clone_upvr_4[arg1_3]:Play()
		end
	end), module_upvr.Cooldown)
end
return module_upvr
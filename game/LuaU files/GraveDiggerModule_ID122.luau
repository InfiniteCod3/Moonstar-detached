-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:04
-- Luau version 6, Types version 3
-- Time taken: 0.018554 seconds

local module_upvr = {}
local var2_upvw
local _, _ = pcall(function() -- Line 7
	--[[ Upvalues[1]:
		[1]: var2_upvw (read and write)
	]]
	var2_upvw = require(script.Parent.Parent.Parent)
end)
module_upvr.Cooldown = 20
module_upvr.GlobalCD = 2
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
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
	local Grave_Digger_upvr = ReplicatedStorage_upvr.Skills["Soul Lantern"]["Grave Digger"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Grave_Digger_upvr.Animation)
	task.wait()
	var2_upvw.applyStatus(arg1, "Freeze", 2)
	var2_upvw.applyStatus(arg1, "IFrames", 0.5)
	any_LoadAnimation_result1_upvr:Play()
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("pause"):Connect(function() -- Line 37
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:AdjustSpeed(0)
	end), module_upvr.Cooldown)
	local clone_upvr = Grave_Digger_upvr.Dash:Clone()
	clone_upvr.Parent = HumanoidRootPart_upvr
	clone_upvr:Play()
	game.Debris:AddItem(clone_upvr, 5)
	local clone = Grave_Digger_upvr.DashExplode:Clone()
	clone.Parent = HumanoidRootPart_upvr
	clone.PlayOnRemove = true
	clone:Destroy()
	var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 5, 1.2, 1.5, 0.1)
	var2_upvw.changeFov(arg1, 120, 1.1)
	local function slam_upvr() -- Line 59, Named "slam"
		--[[ Upvalues[8]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: any_LoadAnimation_result1_upvr (readonly)
			[4]: Grave_Digger_upvr (readonly)
			[5]: Folder_upvr (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
		]]
		var2_upvw.applyStatus(arg1, "GlobalCD", 1.7)
		var2_upvw.applyStatus(arg1, "Freeze", 1.5)
		var2_upvw.applyStatus(arg1, "AutoRotate", 1.5)
		any_LoadAnimation_result1_upvr:AdjustSpeed(1)
		local clone_2_upvr = Grave_Digger_upvr.Slashes:Clone()
		clone_2_upvr.Parent = Folder_upvr
		clone_2_upvr.CFrame = HumanoidRootPart_upvr.CFrame - Vector3.new(0, 3, 0)
		local var17_upvw = 0
		local tbl_2_upvr = {}
		var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slam"):Connect(function() -- Line 71
			--[[ Upvalues[8]:
				[1]: var17_upvw (read and write)
				[2]: var2_upvw (copied, read and write)
				[3]: arg1 (copied, readonly)
				[4]: clone_2_upvr (readonly)
				[5]: tbl_2_upvr (readonly)
				[6]: TweenService_upvr (copied, readonly)
				[7]: Grave_Digger_upvr (copied, readonly)
				[8]: any_LoadAnimation_result1_upvr (copied, readonly)
			]]
			var17_upvw += 1
			if var17_upvw == 1 then
				var2_upvw.changeFov(arg1, 75, 0.05, 3)
				var2_upvw.flashScreen(arg1, Color3.new(0.454902, 1, 0.980392), 0.5)
				var2_upvw.EmitAllDescendants(clone_2_upvr.MainSlash)
				var2_upvw.CreateDebris(clone_2_upvr.Position, 10, 1.5, 1.25, 0.08)
				var2_upvw.crater(1, clone_2_upvr.Position, 3.5, 1.25)
				clone_2_upvr.MainSlash.Rocks:Play()
				clone_2_upvr.MainSlash.Cast:Play()
				clone_2_upvr.MainSlash.Magic:Play()
				var2_upvw.camShake(arg1, "BigBump")
				for _, v in var2_upvw.findEnemiesMagnitude(clone_2_upvr.Position, 24, true), nil do
					table.insert(tbl_2_upvr, v)
					var2_upvw.applyDamage(v, 10)
					var2_upvw.applyStatus(v, "Ragdoll", 1.7)
					var2_upvw.Knockback(v, clone_2_upvr.Position, 10, 55)
					var2_upvw.camShake(v, "BigBump")
					var2_upvw.impactFrame(v)
					if v.Humanoid.Health <= 1 and not v:FindFirstChild("burnVfx") and not v:GetAttribute("DeathEffect") then
						v:SetAttribute("DeathEffect", true)
						v.Humanoid.HealthDisplayType = "AlwaysOff"
						for _, v_2 in v:GetDescendants() do
							if v_2:IsA("Shirt") or v_2:IsA("Pants") then
								v_2:Destroy()
							else
								local function INLINED() -- Internal function, doesn't exist in bytecode
									TweenService_upvr:Create(v_2, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), tbl_3):Play()
									tbl_3.Transparency = 1
									local tbl_3 = {}
									v_2.Color = Color3.new(0.2, 0.988235, 1)
									v_2.Material = "Neon"
									return v_2.Name == "Torso"
								end
								if v_2:IsA("BasePart") and (INLINED() or v_2.Name == "Left Arm" or v_2.Name == "Right Arm" or v_2.Name == "Head" or v_2.Name == "Left Leg" or v_2.Name == "Right Leg") then
									local clone_3_upvr = Grave_Digger_upvr.burnVfx:Clone()
									clone_3_upvr.Parent = v_2
									clone_3_upvr.Enabled = true
									task.delay(2, function() -- Line 112
										--[[ Upvalues[1]:
											[1]: clone_3_upvr (readonly)
										]]
										clone_3_upvr.Enabled = false
									end)
								end
							end
						end
					end
				end
			elseif var17_upvw == 2 then
				for _, v_3 in var2_upvw.findEnemiesMagnitude(clone_2_upvr.Position, 60, true), nil do
					var2_upvw.applyDamage(v_3, 10)
					var2_upvw.applyStatus(v_3, "Ragdoll", 2.5)
					var2_upvw.Knockback(v_3, clone_2_upvr.Position, 22, 92)
					var2_upvw.camShake(v_3, "Explosion")
					var2_upvw.impactFrame(v_3)
					if v_3.Humanoid.Health <= 1 and not v_3:FindFirstChild("burnVfx") then
						v_3.Humanoid.HealthDisplayType = "AlwaysOff"
						for _, v_4 in v_3:GetDescendants() do
							if v_4:IsA("Shirt") or v_4:IsA("Pants") then
								v_4:Destroy()
							else
								local function INLINED_2() -- Internal function, doesn't exist in bytecode
									TweenService_upvr:Create(v_4, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), tbl):Play()
									tbl.Transparency = 1
									local tbl = {}
									v_4.Color = Color3.new(clone_3_upvr, 0.988235, 1)
									clone_3_upvr = 0.2
									v_4.Material = "Neon"
									return v_4.Name == "Torso"
								end
								if v_4:IsA("BasePart") and (INLINED_2() or v_4.Name == "Left Arm" or v_4.Name == "Right Arm" or v_4.Name == "Head" or v_4.Name == "Left Leg" or v_4.Name == "Right Leg") then
									clone_3_upvr = Grave_Digger_upvr
									local clone_4_upvr = clone_3_upvr.burnVfx:Clone()
									clone_4_upvr.Parent = v_4
									clone_3_upvr = true
									clone_4_upvr.Enabled = clone_3_upvr
									clone_3_upvr = task.delay
									clone_3_upvr(2, function() -- Line 147
										--[[ Upvalues[1]:
											[1]: clone_4_upvr (readonly)
										]]
										clone_4_upvr.Enabled = false
									end)
								end
							end
						end
					end
				end
				var2_upvw.impactFrame(arg1, 0.1)
				task.delay(0.1, function() -- Line 158
					--[[ Upvalues[2]:
						[1]: var2_upvw (copied, read and write)
						[2]: arg1 (copied, readonly)
					]]
					var2_upvw.impactFrame2(arg1, 0.1)
				end)
				var2_upvw.flashScreen(arg1, Color3.new(0.278431, 0.988235, 1), 0.2)
				var2_upvw.Blur(arg1, 24, 0.4)
				any_LoadAnimation_result1_upvr:AdjustSpeed(0.75)
				var2_upvw.changeFov(arg1, 125, 0.2, 3)
				var2_upvw.crater(2, clone_2_upvr.Position, 8, 3)
				var2_upvw.camShake(arg1, "Explosion")
				for _, v_5 in clone_2_upvr:GetChildren() do
					if v_5:IsA("BasePart") and v_5 ~= clone_2_upvr.MainSlash then
						clone_4_upvr = 0.08
						var2_upvw.CreateDebris(v_5.Position, 7, 1.5, 1.25, clone_4_upvr)
						var2_upvw.EmitAllDescendants(v_5)
						local Rocks = v_5.Rocks
						clone_4_upvr = 1
						Rocks.PlaybackSpeed += math.random(-1, clone_4_upvr) * 0.1
						v_5.Rocks:Play()
						local Magic = v_5.Magic
						clone_4_upvr = 1
						Magic.PlaybackSpeed += math.random(-1, clone_4_upvr) * 0.1
						v_5.Magic:Play()
					end
				end
			end
		end), module_upvr.Cooldown)
	end
	local var48_upvw
	var48_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2) -- Line 184
		--[[ Upvalues[4]:
			[1]: arg2 (readonly)
			[2]: var48_upvw (read and write)
			[3]: clone_upvr (readonly)
			[4]: slam_upvr (readonly)
		]]
		if arg1_2 ~= arg2 or arg2_2 ~= "GraveDigger" then
		else
			var48_upvw:Disconnect()
			clone_upvr:Stop()
			slam_upvr()
		end
	end), 3)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 193
		--[[ Upvalues[4]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: ReplicatedStorage_upvr (copied, readonly)
			[4]: arg2 (readonly)
		]]
		var2_upvw.changeFov(arg1, 80, 3)
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "GraveDigger")
	end), module_upvr.Cooldown)
end
return module_upvr
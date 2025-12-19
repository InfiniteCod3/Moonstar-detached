-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:00
-- Luau version 6, Types version 3
-- Time taken: 0.011047 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 15
module_upvr.GlobalCD = 0.1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 19
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown + 10)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Wrath_upvr = ReplicatedStorage_upvr.Skills["Soul Lantern"].Ultimate:FindFirstChild("Wrath")
	local function DeathEffects_upvr(arg1_2) -- Line 33, Named "DeathEffects"
		--[[ Upvalues[2]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: Wrath_upvr (readonly)
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
						local clone_upvr_2 = Wrath_upvr.burnVfx:Clone()
						clone_upvr_2.Parent = v
						clone_upvr_2.Enabled = true
						task.delay(2, function() -- Line 52
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
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Wrath_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(0.8)
	var3_upvw.applyStatus(arg1, "Stunned", 2.2)
	var3_upvw.applyStatus(arg1, "AutoRotate", 2.2)
	var3_upvw.changeFov(arg1, 90, 0.3, 5)
	local clone_upvr_3 = Wrath_upvr.ArmVFX:Clone()
	clone_upvr_3.Parent = arg1
	clone_upvr_3.weld.Part0 = arg1["Right Arm"]
	clone_upvr_3.weld.Part1 = clone_upvr_3
	var3_upvw.applyDebris(clone_upvr_3, 5)
	local clone_upvr = Wrath_upvr.Geyser:Clone()
	clone_upvr.Parent = Folder
	clone_upvr.CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 110 + Vector3.new(0, -2, 0)
	var3_upvw.applyDebris(clone_upvr, 15)
	local clone_upvr_4 = Wrath_upvr.Pentagram:Clone()
	clone_upvr_4.Parent = Folder
	clone_upvr_4.CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 110 + Vector3.new(0, -2, 0)
	var3_upvw.applyDebris(clone_upvr_4, 15)
	local workspace_Raycast_result1 = workspace:Raycast(clone_upvr_4.Position, Vector3.new(0, -500, 0), var3_upvw.raycastParams)
	if workspace_Raycast_result1 then
		clone_upvr_4.CFrame = CFrame.new(workspace_Raycast_result1.Position + Vector3.new(0, 1, 0)) * clone_upvr_4.CFrame - clone_upvr_4.CFrame.p
		clone_upvr.CFrame = CFrame.new(workspace_Raycast_result1.Position + Vector3.new(0, 1, 0)) * clone_upvr.CFrame - clone_upvr.CFrame.p
	end
	var3_upvw.applySound(Wrath_upvr.Spawn, arg1["Right Arm"], 5)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Portal"):Once(function() -- Line 94
		--[[ Upvalues[4]:
			[1]: var3_upvw (copied, read and write)
			[2]: Wrath_upvr (readonly)
			[3]: clone_upvr_4 (readonly)
			[4]: arg1 (readonly)
		]]
		var3_upvw.applySound(Wrath_upvr.Summon, clone_upvr_4, 5)
		var3_upvw.EmitAllDescendants(clone_upvr_4)
		wait(0.4)
		var3_upvw.camShake(arg1, "SmallBump")
		var3_upvw.changeFov(arg1, 90, 0.05, 3)
		var3_upvw.flashScreen(arg1, Color3.new(0, 0, 0), 0.1)
	end), 3)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Explode"):Once(function() -- Line 105
		--[[ Upvalues[7]:
			[1]: clone_upvr_3 (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: clone_upvr (readonly)
			[4]: Wrath_upvr (readonly)
			[5]: TweenService_upvr (copied, readonly)
			[6]: arg1 (readonly)
			[7]: DeathEffects_upvr (readonly)
		]]
		for _, v_2 in clone_upvr_3:GetChildren() do
			if v_2:IsA("ParticleEmitter") then
				v_2.Enabled = false
			end
		end
		var3_upvw.EmitAllDescendants(clone_upvr)
		var3_upvw.applySound(Wrath_upvr.Explosion2, clone_upvr, 5)
		task.delay(0.1, function() -- Line 116
			--[[ Upvalues[4]:
				[1]: var3_upvw (copied, read and write)
				[2]: Wrath_upvr (copied, readonly)
				[3]: clone_upvr (copied, readonly)
				[4]: TweenService_upvr (copied, readonly)
			]]
			var3_upvw.applySound(Wrath_upvr.Spray2, clone_upvr, 5)
			wait(2)
			TweenService_upvr:Create(var3_upvw.applySound(Wrath_upvr.Spray, clone_upvr, 5), TweenInfo.new(1), {
				Volume = 0;
			}):Play()
		end)
		var3_upvw.flashScreen(arg1, Color3.new(1, 0.0941176, 0.0941176), 0.4)
		for _ = 1, 10 do
			task.spawn(function() -- Line 126
				--[[ Upvalues[4]:
					[1]: var3_upvw (copied, read and write)
					[2]: arg1 (copied, readonly)
					[3]: clone_upvr (copied, readonly)
					[4]: DeathEffects_upvr (copied, readonly)
				]]
				var3_upvw.camShake(arg1, "Bump")
				var3_upvw.changeFov(arg1, 60, 0, 0.8)
				var3_upvw.flashScreen(arg1, Color3.new(1, 0.113725, 0.113725), 0.1)
				for _, v_3 in var3_upvw.findEnemiesMagnitude(clone_upvr.Position, 100), nil do
					var3_upvw.camShake(v_3, "Bump")
					var3_upvw.changeFov(v_3, 60, 0, 0.8)
					var3_upvw.flashScreen(v_3, Color3.new(1, 0.113725, 0.113725), 0.1)
				end
				for _, v_4 in var3_upvw.findEnemiesPart(clone_upvr.Hitbox, true), nil do
					if not var3_upvw.CheckBlock(v_4) then
						var3_upvw.applyDamage(v_4, 3)
						var3_upvw.Knockback(v_4, clone_upvr.Position, 0, 50)
						var3_upvw.applyStatus(v_4, "Ragdoll", 2)
						var3_upvw.applyStatus(v_4, "DashDB", 2)
						DeathEffects_upvr(v_4)
					end
				end
			end)
			wait(0.2)
		end
	end), 3)
	var3_upvw.conTimer(any_LoadAnimation_result1.Stopped:Once(function() -- Line 155
		--[[ Upvalues[1]:
			[1]: clone_upvr_3 (readonly)
		]]
		for _, v_5 in clone_upvr_3:GetChildren() do
			if v_5:IsA("ParticleEmitter") then
				v_5.Enabled = false
			end
		end
	end), 3)
end
return module_upvr
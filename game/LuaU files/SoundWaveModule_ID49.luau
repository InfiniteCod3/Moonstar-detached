-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:57
-- Luau version 6, Types version 3
-- Time taken: 0.017457 seconds

local module_upvr = {
	Cooldown = 30;
	GlobalCD = 0.25;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Harp = ReplicatedStorage_upvr.Skills.Harp
	local Sound_Wave = Harp["Sound Wave"]
	local clone_3 = Sound_Wave.Harp:Clone()
	var2_upvw.applyStatus(arg1, "Slowed", 1)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1)
	local var26_upvw = false
	local any_LoadAnimation_result1_2 = Humanoid:LoadAnimation(Harp["Sound Wave"].ChargeAnimation)
	any_LoadAnimation_result1_2:Play(0.2)
	any_LoadAnimation_result1_2.Stopped:Connect(function() -- Line 38
		--[[ Upvalues[1]:
			[1]: var26_upvw (read and write)
		]]
		var26_upvw = true
	end)
	task.wait(0.8)
	if var26_upvw then
	else
		var2_upvw.applyDebris(var2_upvw.applySound(Harp["Sound Wave"].Charge, HumanoidRootPart), 0.1)
		for _, v in var2_upvw.applyVFX(Harp["Sound Wave"].VFX.Charge, HumanoidRootPart, 2.5):GetChildren() do
			v.Enabled = false
		end
		any_LoadAnimation_result1_2:Stop(0.05)
		local any_LoadAnimation_result1_3 = Humanoid:LoadAnimation(Sound_Wave.Animation1)
		any_LoadAnimation_result1_3:Play(0.05)
		any_LoadAnimation_result1_3:AdjustWeight(2)
		any_LoadAnimation_result1_3:AdjustSpeed(2)
		clone_3.Parent = HumanoidRootPart
		clone_3:Play()
		game.Debris:AddItem(clone_3, 3)
		var2_upvw.applyStatus(arg1, "Slowed", 1.25)
		var2_upvw.applyStatus(arg1, "CombatStun", 0.25)
		task.wait(0.1)
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 60, 0.05, 0.5)
		if require(ReplicatedStorage_upvr.Modules.PlayerStatus).FindTable("Stunned") then return end
		local clone_2_upvr = Sound_Wave["slash effect"]:Clone()
		clone_2_upvr.Parent = Folder
		game.Debris:AddItem(clone_2_upvr, 5)
		clone_2_upvr.CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 4
		for _, v_2 in clone_2_upvr:GetChildren() do
			if v_2:IsA("Sound") then
				v_2:Play()
			end
		end
		for _, v_3 in clone_2_upvr:GetDescendants() do
			if v_3:IsA("ParticleEmitter") then
				v_3.Enabled = true
			end
		end
		var2_upvw.EmitAllDescendants(clone_2_upvr)
		TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(1.2), {
			CFrame = clone_2_upvr.CFrame + clone_2_upvr.CFrame.LookVector * 100;
		}):Play()
		task.delay(1, function() -- Line 92
			--[[ Upvalues[1]:
				[1]: clone_2_upvr (readonly)
			]]
			for _, v_4 in clone_2_upvr:GetDescendants() do
				if v_4:IsA("ParticleEmitter") then
					v_4.Enabled = false
				end
			end
		end)
		local tbl = {}
		for _ = 1, 46.666666666666664 do
			for _, v_5 in var2_upvw.findEnemiesPart(clone_2_upvr.hitbox, true), nil do
				if not table.find(tbl, v_5) and not var2_upvw.CheckBlock(v_5) then
					table.insert(tbl, v_5)
					var2_upvw.unragdoll(v_5)
					var2_upvw.applyStatus(v_5, "Stunned", 0.6)
					var2_upvw.applyDamage(v_5, 5)
					var2_upvw.Knockback(v_5, HumanoidRootPart.Position, 0, 20)
					var2_upvw.camShake(v_5, "SmallBump")
					var2_upvw.changeFov(v_5, 60, 0.05, 0.5)
					var2_upvw.camShake(arg1, "SmallBump")
					var2_upvw.changeFov(arg1, 60, 0.05, 0.5)
					local clone = Harp["Sound Wave"].HitVFX:Clone()
					clone.Parent = v_5.HumanoidRootPart
					var2_upvw.EmitAllDescendants(clone)
					var2_upvw.applyDebris(clone, 6)
					clone.Weld.Part0 = v_5.HumanoidRootPart
					clone.Weld.Part1 = clone
					for _, v_6 in clone:GetDescendants() do
						if v_6:IsA("Sound") then
							v_6.PlaybackSpeed += math.random(-1, 1) * 0.1
							v_6:Play()
						end
					end
					local clone_4_upvr = Harp["Sound Wave"].TrapVFX:Clone()
					clone_4_upvr.Parent = v_5.HumanoidRootPart
					var2_upvw.applyDebris(clone_4_upvr, 6)
					clone_4_upvr.Weld.Part0 = v_5.HumanoidRootPart
					clone_4_upvr.Weld.Part1 = clone_4_upvr
					for _, v_7 in clone_4_upvr:GetDescendants() do
						if v_7:IsA("ParticleEmitter") then
							v_7.Enabled = true
						end
					end
					for _, v_8 in clone_4_upvr:GetDescendants() do
						if v_8:IsA("Sound") then
							v_8.PlaybackSpeed += math.random(-1, 1) * 0.1
							v_8:Play()
						end
					end
					local any_LoadAnimation_result1 = v_5.Humanoid:LoadAnimation(Harp["Sound Wave"].StunAnimation)
					any_LoadAnimation_result1:Play()
					local any_applyStatus_result1_upvr = var2_upvw.applyStatus(v_5, "AutoRotate", 2)
					any_LoadAnimation_result1.Stopped:Connect(function() -- Line 159
						--[[ Upvalues[3]:
							[1]: clone_4_upvr (readonly)
							[2]: var2_upvw (copied, read and write)
							[3]: any_applyStatus_result1_upvr (readonly)
						]]
						for _, v_9 in clone_4_upvr:GetDescendants() do
							if v_9:IsA("ParticleEmitter") then
								v_9.Enabled = false
							end
						end
						var2_upvw.applyDebris(any_applyStatus_result1_upvr, 0)
					end)
				end
			end
			task.wait()
		end
	end
end
return module_upvr
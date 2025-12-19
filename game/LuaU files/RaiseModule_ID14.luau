-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:00
-- Luau version 6, Types version 3
-- Time taken: 0.012636 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 26
module_upvr.GlobalCD = 0.5
local var3_upvw
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[3]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Raise_upvr = ReplicatedStorage_upvr.Skills["Basic Sword"].Raise
	local Basic_Sword_upvr = arg1:FindFirstChild("Basic Sword")
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Raise_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(0.45)
	local function _(arg1_2) -- Line 32, Named "toggleTrail"
		--[[ Upvalues[1]:
			[1]: Basic_Sword_upvr (readonly)
		]]
		for _, v in Basic_Sword_upvr.TrailAtt:GetChildren() do
			v.Enabled = arg1_2
		end
	end
	var3_upvw.applySound(Raise_upvr.lift, HumanoidRootPart_upvr)
	for _, v_2 in Basic_Sword_upvr.TrailAtt:GetChildren() do
		v_2.Enabled = true
	end
	local any_applySound_result1_upvr = var3_upvw.applySound(Raise_upvr.Charge, HumanoidRootPart_upvr)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 42
		--[[ Upvalues[2]:
			[1]: any_applySound_result1_upvr (readonly)
			[2]: Basic_Sword_upvr (readonly)
		]]
		any_applySound_result1_upvr:Stop()
		for _, v_3 in Basic_Sword_upvr.TrailAtt:GetChildren() do
			v_3.Enabled = false
		end
	end), module_upvr.Cooldown)
	var3_upvw.applyStatus(arg1, "GlobalCD", 1.5)
	var3_upvw.applyStatus(arg1, "Slowed", 1.5)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 52
		--[[ Upvalues[4]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: Raise_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var3_upvw (copied, read and write)
		]]
		if arg1_3 == "swing" then
			any_LoadAnimation_result1_upvr:AdjustSpeed(1)
		end
		if Raise_upvr:FindFirstChild(arg1_3) then
			local clone = Raise_upvr[arg1_3]:Clone()
			clone.Parent = HumanoidRootPart_upvr
			clone:Play()
			var3_upvw.applyDebris(clone, 4)
		else
			print(arg1_3)
		end
	end), module_upvr.Cooldown)
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 65, 0.25, 5)
	local var29_upvw = 0
	local var30_upvw = false
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function() -- Line 72
		--[[ Upvalues[6]:
			[1]: var29_upvw (read and write)
			[2]: var3_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: Raise_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: var30_upvw (read and write)
		]]
		var29_upvw += 1
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 75, 0, 0.5)
		var3_upvw.applyVFX(Raise_upvr.VFX.slashVFX1, HumanoidRootPart_upvr)
		for i_4, v_4_upvr in var3_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5, 6.4, true), nil do
			if not var3_upvw.CheckBlock(v_4_upvr) and var29_upvw == 1 then
				var30_upvw = true
				var3_upvw.applySound(Raise_upvr.hitSFX)
				var3_upvw.applyVFX(Raise_upvr.VFX.hitVFX, v_4_upvr.Torso)
				var3_upvw.unragdoll(v_4_upvr)
				var3_upvw.applyDamage(v_4_upvr, 12)
				var3_upvw.applyStatus(v_4_upvr, "Stunned", 1.6)
				var3_upvw.applyStatus(v_4_upvr, "AutoRotate", 1.6)
				var3_upvw.Knockback(v_4_upvr, HumanoidRootPart_upvr.Position, 5, 35)
				task.delay(0.5, function() -- Line 97
					--[[ Upvalues[4]:
						[1]: Raise_upvr (copied, readonly)
						[2]: var3_upvw (copied, read and write)
						[3]: arg1 (copied, readonly)
						[4]: v_4_upvr (readonly)
					]]
					for _ = 1, 3 do
						local Slashes = Raise_upvr.Slashes
						var3_upvw.camShake(arg1, "SmallBump")
						var3_upvw.camShake(v_4_upvr, "SmallBump")
						var3_upvw.applySound(Slashes.hitSFX, v_4_upvr.Torso)
						var3_upvw.applySound(Slashes.hitSFX2, v_4_upvr.Torso)
						var3_upvw.applySound(Slashes.slash, v_4_upvr.Torso)
						var3_upvw.applyVFX(Slashes.VFX.slashVFX, v_4_upvr.Torso, 3)
						var3_upvw.applyDamage(v_4_upvr, 1)
						var3_upvw.applyStatus(v_4_upvr, "Stunned", 0.9)
						v_4_upvr.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
						task.wait(0.1)
					end
				end)
			end
		end
		if not var30_upvw then
			i_4 = 1.2
			var3_upvw.applyStatus(arg1, "Stunned", i_4)
			i_4 = 1.2
			var3_upvw.applyStatus(arg1, "AutoRotate", i_4)
		end
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("adjustSpeed"):Connect(function() -- Line 124
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:AdjustSpeed(0.4)
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 128
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:Stop(0.4)
	end), module_upvr.Cooldown)
end
return module_upvr
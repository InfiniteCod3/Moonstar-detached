-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:51
-- Luau version 6, Types version 3
-- Time taken: 0.010380 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 18
module_upvr.GlobalCD = 1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Restrain_upvr = ReplicatedStorage_upvr.Skills.Hallow.Restrain
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Restrain_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	var3_upvw.applyStatus(arg1, "Freeze", 2)
	var3_upvw.applyStatus(arg1, "GlobalCD", 2)
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 65, 0.5, 2)
	local tbl_2 = {}
	tbl_2.Character = arg1
	tbl_2.Replication = "RestrainStart"
	var3_upvw.Replication("All", "Hallow", tbl_2)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Push"):Once(function() -- Line 45
		--[[ Upvalues[2]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
		]]
		local tbl = {}
		tbl.Character = arg1
		tbl.Replication = "RestrainPush"
		var3_upvw.Replication("All", "Hallow", tbl)
	end), 3)
	local var13_upvw = false
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Pull"):Once(function() -- Line 50
		--[[ Upvalues[8]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Restrain_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: var13_upvw (read and write)
			[7]: TweenService_upvr (copied, readonly)
			[8]: any_LoadAnimation_result1_upvr (readonly)
		]]
		local tbl_3 = {}
		tbl_3.Character = arg1
		tbl_3.Replication = "RestrainPull"
		var3_upvw.Replication("All", "Hallow", tbl_3)
		local any_cloneInstance_result1 = var3_upvw.cloneInstance(Restrain_upvr.HitboxHolder, Folder_upvr, 12)
		any_cloneInstance_result1.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * -3
		for i = 1, #any_cloneInstance_result1.Hitboxes:GetChildren() do
			local SOME = any_cloneInstance_result1.Hitboxes:FindFirstChild(i)
			if SOME then
				var3_upvw.changeFov(arg1, 75, 0, 0.5)
				var3_upvw.camShake(arg1, "SmallBump")
				for _, v in var3_upvw.findEnemiesPart(SOME, true), nil do
					if not var3_upvw.CheckBlock(v) then
						var13_upvw = true
						local SOME_2 = any_cloneInstance_result1.Hitboxes:FindFirstChild(i + 1)
						if SOME_2 then
							print(SOME_2)
							TweenService_upvr:Create(v.HumanoidRootPart, TweenInfo.new(0.08), {
								CFrame = CFrame.new(SOME_2.Position + Vector3.new(0, 3, 0)) * SOME_2.CFrame - SOME_2.CFrame.Position;
							}):Play()
						else
							TweenService_upvr:Create(v.HumanoidRootPart, TweenInfo.new(0.08), {
								CFrame = CFrame.new(SOME.Position + Vector3.new(0, 3, 0)) * SOME.CFrame - SOME.CFrame.Position;
							}):Play()
						end
						var3_upvw.unragdoll(v)
						var3_upvw.applyStatus(v, "Stunned", 1)
						var3_upvw.applyStatus(v, "AutoRotate", 1)
						var3_upvw.applyDamage(v, 1)
					end
				end
				wait(0.05)
			end
		end
		if var13_upvw then
			i = "Stunned"
			var3_upvw.applyStatus(arg1, i, 0.5)
			i = 100
			var3_upvw.changeFov(arg1, i, 0.5, 1)
			i = 0.9
			any_LoadAnimation_result1_upvr:AdjustSpeed(i)
		else
			any_LoadAnimation_result1_upvr:Stop(0.5)
			var3_upvw.applyStatus(arg1, "Stunned", 0.45)
		end
	end), 3)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Once(function() -- Line 97
		--[[ Upvalues[3]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 50, 0, 0.55)
		var3_upvw.applyStatus(arg1, "Stunned", 0.6)
		local var28
		for i_3, v_2 in var3_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 13, 13, false), nil do
			if not var3_upvw.CheckBlock(v_2, true) then
				var3_upvw.applyStatus(v_2, "Ragdoll", 2)
				var3_upvw.applyDamage(v_2, 15)
				var3_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -20, 35, 10)
				v_2.HumanoidRootPart.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 6.5) * CFrame.Angles(0, math.pi, 0)
			end
		end
		if nil then
			i_3 = {}
			v_2 = arg1
			i_3.Character = v_2
			v_2 = "RestrainSlash"
			i_3.Replication = v_2
			var3_upvw.Replication("All", "Hallow", i_3)
		end
	end), 5)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Once(function() -- Line 122
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:AdjustSpeed(0)
	end), 3)
end
return module_upvr
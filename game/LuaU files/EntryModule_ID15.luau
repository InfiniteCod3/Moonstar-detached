-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:01
-- Luau version 6, Types version 3
-- Time taken: 0.006998 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 19
module_upvr.GlobalCD = 0.1
local var3_upvw
local Remotes_upvr = ReplicatedStorage_upvr.Remotes
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: Remotes_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Entry_upvr = ReplicatedStorage_upvr.Skills["Basic Sword"].Entry
	local tbl_upvr = {}
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "Freeze", 2))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "GlobalCD", 2))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames", 0.8))
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Entry_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 80, 0.1, 1)
	any_LoadAnimation_result1_upvr:AdjustSpeed(1.1)
	var3_upvw.applySound(Entry_upvr.Sheath, HumanoidRootPart_upvr)
	var3_upvw.applySound(Entry_upvr.Dash, HumanoidRootPart_upvr)
	local var10_upvw
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function() -- Line 48
		--[[ Upvalues[8]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: var10_upvw (read and write)
			[3]: Folder_upvr (readonly)
			[4]: var3_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: Entry_upvr (readonly)
			[7]: HumanoidRootPart_upvr (readonly)
			[8]: tbl_upvr (readonly)
		]]
		repeat
			local var20
			task.wait()
			any_LoadAnimation_result1_upvr:AdjustSpeed(0)
			if var10_upvw then break end
			var20 = Folder_upvr
		until not var20.Parent
		if not var10_upvw then
		else
			any_LoadAnimation_result1_upvr:AdjustSpeed(0.8)
			var20 = var3_upvw
			var20 = arg1
			var20.camShake(var20, "Bump")
			var20 = var3_upvw
			var20 = arg1
			var20.changeFov(var20, 65, 0, 1)
			var20 = var3_upvw
			var20 = Entry_upvr.VFX.slashVFX
			var20.applyVFX(var20, HumanoidRootPart_upvr)
			var20 = var3_upvw
			var20 = Entry_upvr.slash
			var20.applySound(var20, HumanoidRootPart_upvr)
			var20 = var10_upvw.Position
			var20 = false
			for _, v in var3_upvw.findEnemiesMagnitude(var20 + var10_upvw.LookVector * 5, 11, true), nil do
				if not var3_upvw.CheckBlock(v, true) then
					var20 = true
					var3_upvw.applyDamage(v, 15)
					var3_upvw.applyStatus(v, "Ragdoll", 1.5)
					var3_upvw.applyVFX(Entry_upvr.VFX.hitVFX, v.Torso)
					var3_upvw.applySound(Entry_upvr.hitSFX, v.Torso)
					var3_upvw.Knockback(v, var10_upvw.Position + HumanoidRootPart_upvr.CFrame.LookVector * -100, 8)
				end
			end
			if var20 then
				for _, v_2 in tbl_upvr do
					var3_upvw.applyDebris(v_2, 0)
				end
			end
			table.clear(tbl_upvr)
		end
	end), module_upvr.Cooldown)
	local var22_upvw
	var22_upvw = var3_upvw.conTimer(Remotes_upvr.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 83
		--[[ Upvalues[8]:
			[1]: arg2 (readonly)
			[2]: var22_upvw (read and write)
			[3]: var10_upvw (read and write)
			[4]: tbl_upvr (readonly)
			[5]: var3_upvw (copied, read and write)
			[6]: arg1 (readonly)
			[7]: Entry_upvr (readonly)
			[8]: HumanoidRootPart_upvr (readonly)
		]]
		if arg1_2 ~= arg2 or arg2_2 ~= "Entry" then
		else
			var22_upvw:Disconnect()
			var10_upvw = arg3.ClientCF + arg3.ClientCF.LookVector * 12 + Vector3.new(0, -5, 0)
			table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "AutoRotate", 0.5))
			task.wait(0.15)
			var3_upvw.applyVFX(Entry_upvr.VFX.landVFX, HumanoidRootPart_upvr)
			var3_upvw.applySound(Entry_upvr.landSFX, HumanoidRootPart_upvr)
			var3_upvw.CreateDebris(var10_upvw.Position, 10, 1, 0.5, 0.1)
			var3_upvw.crater(1, var10_upvw.Position, 2, 0.7)
		end
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(var22_upvw, 5)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 97
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:Stop(0.4)
	end), module_upvr.Cooldown)
end
return module_upvr
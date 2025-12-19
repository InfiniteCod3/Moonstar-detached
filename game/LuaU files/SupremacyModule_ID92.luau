-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:19
-- Luau version 6, Types version 3
-- Time taken: 0.008133 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 32
module_upvr.GlobalCD = 1.4
local var3_upvw
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 14
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Supremacy_upvr = ReplicatedStorage_upvr.Skills["Titans Edge"].Supremacy
	local tbl_upvr = {}
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "Freeze", 2))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "GlobalCD", 2))
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid"):LoadAnimation(Supremacy_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play(0.1)
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 39
		--[[ Upvalues[2]:
			[1]: tbl_upvr (readonly)
			[2]: var3_upvw (copied, read and write)
		]]
		for _, v in tbl_upvr do
			var3_upvw.applyDebris(v, 0)
		end
	end), module_upvr.Cooldown)
	var3_upvw.applySound(Supremacy_upvr.JumpSFX, HumanoidRootPart_upvr)
	task.delay(0.5, function() -- Line 46
		--[[ Upvalues[3]:
			[1]: var3_upvw (copied, read and write)
			[2]: Supremacy_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		var3_upvw.applySound(Supremacy_upvr.ChargeSFX, HumanoidRootPart_upvr)
	end)
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 60, 1, 3)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("punch"):Connect(function() -- Line 52
		--[[ Upvalues[6]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Supremacy_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: tbl_upvr (readonly)
			[6]: PlayerStatus_upvr (copied, readonly)
		]]
		var3_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 0.4)
		var3_upvw.camShake(arg1, "BigBump")
		var3_upvw.changeFov(arg1, 30, 0, 0.5)
		local clone = Supremacy_upvr.VFX.SmashATT:Clone()
		clone.Parent = HumanoidRootPart_upvr
		var3_upvw.EmitAllDescendants(clone)
		var3_upvw.applyDebris(clone, 5)
		var3_upvw.applySound(Supremacy_upvr.SlamSFX, clone)
		var3_upvw.applySound(Supremacy_upvr.SlamSFX2, clone)
		var3_upvw.applySound(Supremacy_upvr.WindSFX, clone)
		table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "Freeze", 2))
		table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "GlobalCD", 2))
		local var20_upvw
		for _, v_2 in var3_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 35, true), nil do
			if not var3_upvw.CheckBlock(v_2) then
				var20_upvw += 1
				var3_upvw.unragdoll(v_2)
				var3_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, -2, 24, 0.35)
				var3_upvw.applyDamage(v_2, 12)
				var3_upvw.applyStatus(v_2, "Stunned", 1.25)
				var3_upvw.flashScreen(v_2, Color3.new(1, 1, 1), 0.4)
				var3_upvw.camShake(v_2, "Bump")
				var3_upvw.changeFov(v_2, 100, 0, 3)
			end
		end
		task.delay(1.2, function() -- Line 86
			--[[ Upvalues[4]:
				[1]: var20_upvw (read and write)
				[2]: tbl_upvr (copied, readonly)
				[3]: PlayerStatus_upvr (copied, readonly)
				[4]: arg1 (copied, readonly)
			]]
			if 0 < var20_upvw then
				for _, v_3 in tbl_upvr do
					PlayerStatus_upvr.RemoveStatus(arg1, v_3)
				end
			end
		end)
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 96
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:Stop(0.5)
	end), module_upvr.Cooldown)
end
return module_upvr
-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:42
-- Luau version 6, Types version 3
-- Time taken: 0.007788 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 20
module_upvr.GlobalCD = 1
local var3_upvw
function module_upvr.Script(arg1, arg2) -- Line 15
	--[[ Upvalues[3]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Break_upvr = ReplicatedStorage_upvr.Skills.Hallow.Mode.Break
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Break_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	any_LoadAnimation_result1_upvr.Looped = false
	var3_upvw.applyStatus(arg1, "HyperArmor", 1.6)
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 100, 0.2, 2)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Once(function() -- Line 40
		--[[ Upvalues[2]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: arg2 (readonly)
		]]
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "BreakCancel")
	end), 5)
	local var9_upvw = false
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Freeze"):Once(function() -- Line 45
		--[[ Upvalues[2]:
			[1]: var9_upvw (read and write)
			[2]: any_LoadAnimation_result1_upvr (readonly)
		]]
		if var9_upvw then
		else
			any_LoadAnimation_result1_upvr:AdjustSpeed(0)
		end
	end), 3)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 50
		--[[ Upvalues[3]:
			[1]: Break_upvr (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		if Break_upvr:FindFirstChild(arg1_2) then
			var3_upvw.applySound(Break_upvr[arg1_2], HumanoidRootPart_upvr, 5)
		end
	end), 4)
	var3_upvw.applySound(Break_upvr.Charge, HumanoidRootPart_upvr, 5)
	local any_applyStatus_result1_upvr = var3_upvw.applyStatus(arg1, "Stunned", 1.6)
	var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2) -- Line 58
		--[[ Upvalues[9]:
			[1]: arg2 (readonly)
			[2]: var9_upvw (read and write)
			[3]: any_LoadAnimation_result1_upvr (readonly)
			[4]: var3_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: Break_upvr (readonly)
			[7]: Folder_upvr (readonly)
			[8]: HumanoidRootPart_upvr (readonly)
			[9]: any_applyStatus_result1_upvr (readonly)
		]]
		if arg1_3 ~= arg2 or arg2_2 ~= "Break" then
		else
			var9_upvw = true
			any_LoadAnimation_result1_upvr:AdjustSpeed(1)
			var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Once(function() -- Line 63
				--[[ Upvalues[6]:
					[1]: var3_upvw (copied, read and write)
					[2]: arg1 (copied, readonly)
					[3]: Break_upvr (copied, readonly)
					[4]: Folder_upvr (copied, readonly)
					[5]: HumanoidRootPart_upvr (copied, readonly)
					[6]: any_applyStatus_result1_upvr (copied, readonly)
				]]
				var3_upvw.camShake(arg1, "Bump")
				var3_upvw.changeFov(arg1, 60, 0, 0.5)
				local tbl = {}
				tbl.Character = arg1
				tbl.Replication = "BreakSmash"
				var3_upvw.Replication("All", "Hallow", tbl)
				local clone = Break_upvr.CrippleHitbox:Clone()
				clone.Parent = Folder_upvr
				var3_upvw.applyDebris(clone, 5)
				var3_upvw.applySound(Break_upvr.FlameBurst, clone, 5)
				var3_upvw.applySound(Break_upvr.Burst, clone, 5)
				var3_upvw.applySound(Break_upvr.SmashSFX, clone, 5)
				clone.weld.Part0 = HumanoidRootPart_upvr
				clone.weld.Part1 = clone
				var3_upvw.applyDebris(any_applyStatus_result1_upvr, 0.21)
				local var21
				for i, v in var3_upvw.findEnemiesPart(clone, true), nil do
					if not var3_upvw.CheckBlock(v, true) then
						var3_upvw.applyDamage(v, 20)
						var3_upvw.Knockback(v, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -25, 25, 70)
						var3_upvw.applyStatus(v, "Ragdoll", 3.1)
						var3_upvw.applyStatus(v, "DashDB", 1.1)
					end
				end
				if nil then
					i = 0.7
					var3_upvw.applyStatus(arg1, "Stunned", i)
				end
			end), 3)
		end
	end), 5)
end
return module_upvr
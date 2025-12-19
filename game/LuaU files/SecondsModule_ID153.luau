-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:19:07
-- Luau version 6, Types version 3
-- Time taken: 0.012037 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 23
module_upvr.GlobalCD = 1
local var3_upvw
function module_upvr.Script(arg1, arg2) -- Line 17
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
	local Seconds_upvr = ReplicatedStorage_upvr.Skills.Chef.Seconds
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Seconds_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	var3_upvw.applyStatus(arg1, "Freeze", 0.9)
	var3_upvw.applyStatus(arg1, "GlobalCD", 0.9)
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 100, 0.2, 2)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Once(function() -- Line 41
		--[[ Upvalues[1]:
			[1]: arg1 (readonly)
		]]
		if arg1:FindFirstChild("HotPan") then
			arg1.HotPan.Name = "UsedHotPan"
		end
	end), 5)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Fork"):Once(function() -- Line 51
		--[[ Upvalues[6]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Seconds_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: any_LoadAnimation_result1_upvr (readonly)
		]]
		var3_upvw.camShake(arg1, "SmallBump")
		var3_upvw.changeFov(arg1, 74, 0, 0.5)
		local any_cloneInstance_result1_2 = var3_upvw.cloneInstance(Seconds_upvr.HitboxHolder, Folder_upvr, 1)
		any_cloneInstance_result1_2.CFrame = HumanoidRootPart_upvr.CFrame
		local tbl_4 = {
			Replication = "ForkSlash";
		}
		tbl_4.Character = arg1
		var3_upvw.Replication("All", "Chef", tbl_4)
		var3_upvw.Knockback(arg1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 12)
		local any_findEnemiesPart_result1 = var3_upvw.findEnemiesPart(any_cloneInstance_result1_2.Hitbox, true)
		for i, v in any_findEnemiesPart_result1 do
			if not var3_upvw.CheckBlock(v, false) then
				var3_upvw.unragdoll(v)
				local tbl_2 = {
					Replication = "ForkHit";
					Target = v;
				}
				tbl_2.Character = arg1
				var3_upvw.Replication("All", "Chef", tbl_2)
				var3_upvw.applyDamage(v, 5)
				var3_upvw.applyStatus(v, "Stunned", 1)
				var3_upvw.Knockback(v, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 8)
			end
		end
		if #any_findEnemiesPart_result1 <= 0 then
			wait(0.2)
			any_LoadAnimation_result1_upvr:Stop(0.5)
			i = 0.6
			var3_upvw.applyStatus(arg1, "Freeze", i)
			i = 0.6
			var3_upvw.applyStatus(arg1, "GlobalCD", i)
			return
		end
	end), 3)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Pan"):Once(function() -- Line 84
		--[[ Upvalues[5]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Seconds_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: Folder_upvr (readonly)
		]]
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 55, 0, 0.5)
		local var21
		if arg1:FindFirstChild("HotPan") then
			var21 = var3_upvw
			var21 = arg1
			var21.flashScreen(var21, Color3.new(1, 0.435294, 0.435294), 0.25)
			var21 = var3_upvw
			var21 = "All"
			local tbl = {
				Replication = "CriticalSlash";
			}
			tbl.Character = arg1
			var21.Replication(var21, "Chef", tbl)
		else
			var21 = var3_upvw
			var21 = arg1
			var21.flashScreen(var21, Color3.new(1, 0.635294, 0.423529), 0.25)
			var21 = var3_upvw
			var21 = "All"
			local tbl_6 = {
				Replication = "PanSlash";
			}
			tbl_6.Character = arg1
			var21.Replication(var21, "Chef", tbl_6)
		end
		var21 = var3_upvw
		var21 = Seconds_upvr.HitboxHolder2
		local any_cloneInstance_result1 = var21.cloneInstance(var21, Folder_upvr, 1)
		var21 = HumanoidRootPart_upvr.CFrame
		any_cloneInstance_result1.CFrame = var21
		var21 = var3_upvw.Knockback
		var21(arg1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, -10)
		var21 = false
		for _, v_2 in var3_upvw.findEnemiesPart(any_cloneInstance_result1.Hitbox, false), nil do
			if not var3_upvw.CheckBlock(v_2, true) then
				var21 = true
				if arg1:FindFirstChild("HotPan") then
					var3_upvw.applyDamage(v_2, 24)
					local tbl_5 = {
						Replication = "CriticalHit";
						Target = v_2;
					}
					tbl_5.Character = arg1
					var3_upvw.Replication("All", "Chef", tbl_5)
				else
					local tbl_3 = {
						Replication = "PanHit";
						Target = v_2;
					}
					tbl_3.Character = arg1
					var3_upvw.Replication("All", "Chef", tbl_3)
					var3_upvw.applyDamage(v_2, 12)
				end
				var3_upvw.applyStatus(v_2, "Ragdoll", 1.65)
				var3_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 40)
			end
		end
		if var21 then
			_ = 4
		end
		if arg1:FindFirstChild("HotPan") then
			arg1.HotPan.Name = "UsedHotPan"
		end
	end), 3)
end
return module_upvr
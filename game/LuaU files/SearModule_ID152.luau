-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:19:06
-- Luau version 6, Types version 3
-- Time taken: 0.042760 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 22
module_upvr.GlobalCD = 1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 18
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
	local Sear_upvr = ReplicatedStorage_upvr.Skills.Chef.Sear
	local Chef_upvr = arg1:FindFirstChild("Chef")
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Sear_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var3_upvw.applyStatus(arg1, "Freeze", 2)
	var3_upvw.applyStatus(arg1, "GlobalCD", 2)
	if not arg1:FindFirstChild("HotPan") then
		local any_cloneInstance_result1_upvw = var3_upvw.cloneInstance(Sear_upvr.SearPan, arg1, 3)
		any_cloneInstance_result1_upvw.weld.Part0 = Chef_upvr.Pan
		any_cloneInstance_result1_upvw.weld.Part1 = any_cloneInstance_result1_upvw
		delay(0.2, function() -- Line 45
			--[[ Upvalues[3]:
				[1]: TweenService_upvr (copied, readonly)
				[2]: Chef_upvr (readonly)
				[3]: any_cloneInstance_result1_upvw (read and write)
			]]
			TweenService_upvr:Create(Chef_upvr.Pan, TweenInfo.new(0.35), {
				Transparency = 1;
			}):Play()
			TweenService_upvr:Create(any_cloneInstance_result1_upvw, TweenInfo.new(0.35), {
				Transparency = 0;
			}):Play()
			for _, v in any_cloneInstance_result1_upvw:GetChildren() do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				end
			end
		end)
	end
	var3_upvw.conTimer(any_LoadAnimation_result1.Stopped:Once(function() -- Line 56
		--[[ Upvalues[5]:
			[1]: arg1 (readonly)
			[2]: any_cloneInstance_result1_upvw (read and write)
			[3]: TweenService_upvr (copied, readonly)
			[4]: Chef_upvr (readonly)
			[5]: var3_upvw (copied, read and write)
		]]
		delay(0.5, function() -- Line 57
			--[[ Upvalues[1]:
				[1]: arg1 (copied, readonly)
			]]
			if arg1:FindFirstChild("HotPan") then
				arg1.HotPan.Name = "UsedHotPan"
			end
		end)
		if any_cloneInstance_result1_upvw then
			TweenService_upvr:Create(Chef_upvr.Pan, TweenInfo.new(0), {
				Transparency = 0;
			}):Play()
			var3_upvw.applyDebris(any_cloneInstance_result1_upvw, 0)
		end
	end), 5)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Once(function(arg1_2) -- Line 69
		--[[ Upvalues[3]:
			[1]: Sear_upvr (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		if Sear_upvr:FindFirstChild(arg1_2) then
			var3_upvw.applySound(Sear_upvr[arg1_2], HumanoidRootPart_upvr, 5)
		end
	end), 5)
	local any_applySound_result1_upvr = var3_upvw.applySound(Sear_upvr.CookingSFX, HumanoidRootPart_upvr, 4)
	delay(0.5, function() -- Line 79
		--[[ Upvalues[2]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: any_applySound_result1_upvr (readonly)
		]]
		TweenService_upvr:Create(any_applySound_result1_upvr, TweenInfo.new(0.4), {
			Volume = 0;
		}):Play()
	end)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Action"):Once(function() -- Line 83
		--[[ Upvalues[8]:
			[1]: any_cloneInstance_result1_upvw (read and write)
			[2]: TweenService_upvr (copied, readonly)
			[3]: Chef_upvr (readonly)
			[4]: var3_upvw (copied, read and write)
			[5]: Sear_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: HumanoidRootPart_upvr (readonly)
			[8]: arg1 (readonly)
		]]
		if any_cloneInstance_result1_upvw then
			TweenService_upvr:Create(Chef_upvr.Pan, TweenInfo.new(0), {
				Transparency = 0;
			}):Play()
			var3_upvw.applyDebris(any_cloneInstance_result1_upvw, 0)
		end
		local clone_upvr = Sear_upvr.SearHitboxes:Clone()
		clone_upvr.Parent = Folder_upvr
		clone_upvr.CFrame = HumanoidRootPart_upvr.CFrame
		var3_upvw.applyDebris(clone_upvr, 5)
		local tbl = {
			Replication = "SearSmash";
		}
		tbl.Character = arg1
		tbl.AbilityCFrame = clone_upvr.CFrame
		var3_upvw.Replication("All", "Chef", tbl)
		var3_upvw.crater(1, clone_upvr.Smash.Position, 2, 0.1)
		var3_upvw.CreateDebris(clone_upvr.Smash.Position, 6, 1.5, 1, 0.1)
		for _, v_2 in var3_upvw.findEnemiesPart(clone_upvr.Smash, true), nil do
			if not var3_upvw.CheckBlock(v_2, true) then
				var3_upvw.applyDamage(v_2, 10)
				var3_upvw.applyStatus(v_2, "Ragdoll", 1.2)
				var3_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 20, 15)
			end
		end
		local tbl_2_upvr = {}
		local function _(arg1_3) -- Line 113, Named "Eruption"
			--[[ Upvalues[6]:
				[1]: var3_upvw (copied, read and write)
				[2]: clone_upvr (readonly)
				[3]: Sear_upvr (copied, readonly)
				[4]: arg1 (copied, readonly)
				[5]: tbl_2_upvr (readonly)
				[6]: HumanoidRootPart_upvr (copied, readonly)
			]]
			task.spawn(function() -- Line 114
				--[[ Upvalues[7]:
					[1]: var3_upvw (copied, read and write)
					[2]: arg1_3 (readonly)
					[3]: clone_upvr (copied, readonly)
					[4]: Sear_upvr (copied, readonly)
					[5]: arg1 (copied, readonly)
					[6]: tbl_2_upvr (copied, readonly)
					[7]: HumanoidRootPart_upvr (copied, readonly)
				]]
				var3_upvw.crater(1, arg1_3.Position, 1, 0.15)
				var3_upvw.CreateDebris(arg1_3.Position, 6, 1.5, 1, 0.1)
				if arg1_3 == clone_upvr.Eruption1 then
				end
				for _ = 1, 2 do
					var3_upvw.camShake(arg1, "SmallBump")
					var3_upvw.changeFov(arg1, 75, 0, 0.5)
					for _, v_3_upvr in var3_upvw.findEnemiesPart(arg1_3, true), nil do
						if not var3_upvw.CheckBlock(v_3_upvr, false) and not table.find(tbl_2_upvr, v_3_upvr) then
							table.insert(tbl_2_upvr, v_3_upvr)
							delay(0.05, function() -- Line 128
								--[[ Upvalues[2]:
									[1]: tbl_2_upvr (copied, readonly)
									[2]: v_3_upvr (readonly)
								]]
								table.remove(tbl_2_upvr, table.find(tbl_2_upvr, v_3_upvr))
							end)
							var3_upvw.unragdoll(v_3_upvr)
							var3_upvw.applyDamage(v_3_upvr, 5)
							var3_upvw.applyStatus(v_3_upvr, "Stunned", 0.5)
							var3_upvw.Knockback(v_3_upvr, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 0, 0)
						end
					end
					wait(0.1)
				end
				wait(0.2)
				var3_upvw.crater(1, arg1_3.Position, 2, 0.15)
				var3_upvw.CreateDebris(arg1_3.Position, 6, 1.5, 1, 0.1)
				if arg1_3 == clone_upvr.Eruption1 then
				end
				var3_upvw.camShake(arg1, "Bump")
				var3_upvw.changeFov(arg1, 100, 0, 0.5)
				for _, v_4_upvr in var3_upvw.findEnemiesPart(arg1_3, true), nil do
					if not var3_upvw.CheckBlock(v_4_upvr, false) then
						if not table.find(tbl_2_upvr, v_4_upvr) then
							table.insert(tbl_2_upvr, v_4_upvr)
							delay(0.05, function() -- Line 157
								--[[ Upvalues[2]:
									[1]: tbl_2_upvr (copied, readonly)
									[2]: v_4_upvr (readonly)
								]]
								table.remove(tbl_2_upvr, table.find(tbl_2_upvr, v_4_upvr))
							end)
							if arg1:FindFirstChild("HotPan") then
								var3_upvw.applyDamage(v_4_upvr, 20)
							else
								var3_upvw.applyDamage(v_4_upvr, 10)
							end
							var3_upvw.applyStatus(v_4_upvr, "Ragdoll", 2)
							var3_upvw.Knockback(v_4_upvr, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 5, 50)
						end
					end
				end
			end)
		end
		local Eruption1_upvr = clone_upvr.Eruption1
		task.spawn(function() -- Line 114
			--[[ Upvalues[7]:
				[1]: var3_upvw (copied, read and write)
				[2]: Eruption1_upvr (readonly)
				[3]: clone_upvr (readonly)
				[4]: Sear_upvr (copied, readonly)
				[5]: arg1 (copied, readonly)
				[6]: tbl_2_upvr (readonly)
				[7]: HumanoidRootPart_upvr (copied, readonly)
			]]
			var3_upvw.crater(1, Eruption1_upvr.Position, 1, 0.15)
			var3_upvw.CreateDebris(Eruption1_upvr.Position, 6, 1.5, 1, 0.1)
			if Eruption1_upvr == clone_upvr.Eruption1 then
			end
			for _ = 1, 2 do
				var3_upvw.camShake(arg1, "SmallBump")
				var3_upvw.changeFov(arg1, 75, 0, 0.5)
				for _, v_5_upvr in var3_upvw.findEnemiesPart(Eruption1_upvr, true), nil do
					if not var3_upvw.CheckBlock(v_5_upvr, false) and not table.find(tbl_2_upvr, v_5_upvr) then
						table.insert(tbl_2_upvr, v_5_upvr)
						delay(0.05, function() -- Line 128
							--[[ Upvalues[2]:
								[1]: tbl_2_upvr (copied, readonly)
								[2]: v_5_upvr (readonly)
							]]
							table.remove(tbl_2_upvr, table.find(tbl_2_upvr, v_5_upvr))
						end)
						var3_upvw.unragdoll(v_5_upvr)
						var3_upvw.applyDamage(v_5_upvr, 5)
						var3_upvw.applyStatus(v_5_upvr, "Stunned", 0.5)
						var3_upvw.Knockback(v_5_upvr, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 0, 0)
					end
				end
				wait(0.1)
			end
			wait(0.2)
			var3_upvw.crater(1, Eruption1_upvr.Position, 2, 0.15)
			var3_upvw.CreateDebris(Eruption1_upvr.Position, 6, 1.5, 1, 0.1)
			if Eruption1_upvr == clone_upvr.Eruption1 then
			end
			var3_upvw.camShake(arg1, "Bump")
			var3_upvw.changeFov(arg1, 100, 0, 0.5)
			for _, v_6_upvr in var3_upvw.findEnemiesPart(Eruption1_upvr, true), nil do
				if not var3_upvw.CheckBlock(v_6_upvr, false) then
					if not table.find(tbl_2_upvr, v_6_upvr) then
						table.insert(tbl_2_upvr, v_6_upvr)
						delay(0.05, function() -- Line 157
							--[[ Upvalues[2]:
								[1]: tbl_2_upvr (copied, readonly)
								[2]: v_6_upvr (readonly)
							]]
							table.remove(tbl_2_upvr, table.find(tbl_2_upvr, v_6_upvr))
						end)
						if arg1:FindFirstChild("HotPan") then
							var3_upvw.applyDamage(v_6_upvr, 20)
						else
							var3_upvw.applyDamage(v_6_upvr, 10)
						end
						var3_upvw.applyStatus(v_6_upvr, "Ragdoll", 2)
						var3_upvw.Knockback(v_6_upvr, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 5, 50)
					end
				end
			end
		end)
		Eruption1_upvr = clone_upvr.Eruption2
		task.spawn(function() -- Line 114
			--[[ Upvalues[7]:
				[1]: var3_upvw (copied, read and write)
				[2]: Eruption1_upvr (readonly)
				[3]: clone_upvr (readonly)
				[4]: Sear_upvr (copied, readonly)
				[5]: arg1 (copied, readonly)
				[6]: tbl_2_upvr (readonly)
				[7]: HumanoidRootPart_upvr (copied, readonly)
			]]
			var3_upvw.crater(1, Eruption1_upvr.Position, 1, 0.15)
			var3_upvw.CreateDebris(Eruption1_upvr.Position, 6, 1.5, 1, 0.1)
			if Eruption1_upvr == clone_upvr.Eruption1 then
			end
			for _ = 1, 2 do
				var3_upvw.camShake(arg1, "SmallBump")
				var3_upvw.changeFov(arg1, 75, 0, 0.5)
				for _, v_7_upvr in var3_upvw.findEnemiesPart(Eruption1_upvr, true), nil do
					if not var3_upvw.CheckBlock(v_7_upvr, false) and not table.find(tbl_2_upvr, v_7_upvr) then
						table.insert(tbl_2_upvr, v_7_upvr)
						delay(0.05, function() -- Line 128
							--[[ Upvalues[2]:
								[1]: tbl_2_upvr (copied, readonly)
								[2]: v_7_upvr (readonly)
							]]
							table.remove(tbl_2_upvr, table.find(tbl_2_upvr, v_7_upvr))
						end)
						var3_upvw.unragdoll(v_7_upvr)
						var3_upvw.applyDamage(v_7_upvr, 5)
						var3_upvw.applyStatus(v_7_upvr, "Stunned", 0.5)
						var3_upvw.Knockback(v_7_upvr, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 0, 0)
					end
				end
				wait(0.1)
			end
			wait(0.2)
			var3_upvw.crater(1, Eruption1_upvr.Position, 2, 0.15)
			var3_upvw.CreateDebris(Eruption1_upvr.Position, 6, 1.5, 1, 0.1)
			if Eruption1_upvr == clone_upvr.Eruption1 then
			end
			var3_upvw.camShake(arg1, "Bump")
			var3_upvw.changeFov(arg1, 100, 0, 0.5)
			for _, v_8_upvr in var3_upvw.findEnemiesPart(Eruption1_upvr, true), nil do
				if not var3_upvw.CheckBlock(v_8_upvr, false) then
					if not table.find(tbl_2_upvr, v_8_upvr) then
						table.insert(tbl_2_upvr, v_8_upvr)
						delay(0.05, function() -- Line 157
							--[[ Upvalues[2]:
								[1]: tbl_2_upvr (copied, readonly)
								[2]: v_8_upvr (readonly)
							]]
							table.remove(tbl_2_upvr, table.find(tbl_2_upvr, v_8_upvr))
						end)
						if arg1:FindFirstChild("HotPan") then
							var3_upvw.applyDamage(v_8_upvr, 20)
						else
							var3_upvw.applyDamage(v_8_upvr, 10)
						end
						var3_upvw.applyStatus(v_8_upvr, "Ragdoll", 2)
						var3_upvw.Knockback(v_8_upvr, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 5, 50)
					end
				end
			end
		end)
		Eruption1_upvr = wait
		Eruption1_upvr(0.1)
		Eruption1_upvr = clone_upvr.Eruption3
		task.spawn(function() -- Line 114
			--[[ Upvalues[7]:
				[1]: var3_upvw (copied, read and write)
				[2]: Eruption1_upvr (readonly)
				[3]: clone_upvr (readonly)
				[4]: Sear_upvr (copied, readonly)
				[5]: arg1 (copied, readonly)
				[6]: tbl_2_upvr (readonly)
				[7]: HumanoidRootPart_upvr (copied, readonly)
			]]
			var3_upvw.crater(1, Eruption1_upvr.Position, 1, 0.15)
			var3_upvw.CreateDebris(Eruption1_upvr.Position, 6, 1.5, 1, 0.1)
			if Eruption1_upvr == clone_upvr.Eruption1 then
			end
			for _ = 1, 2 do
				var3_upvw.camShake(arg1, "SmallBump")
				var3_upvw.changeFov(arg1, 75, 0, 0.5)
				for _, v_9_upvr in var3_upvw.findEnemiesPart(Eruption1_upvr, true), nil do
					if not var3_upvw.CheckBlock(v_9_upvr, false) and not table.find(tbl_2_upvr, v_9_upvr) then
						table.insert(tbl_2_upvr, v_9_upvr)
						delay(0.05, function() -- Line 128
							--[[ Upvalues[2]:
								[1]: tbl_2_upvr (copied, readonly)
								[2]: v_9_upvr (readonly)
							]]
							table.remove(tbl_2_upvr, table.find(tbl_2_upvr, v_9_upvr))
						end)
						var3_upvw.unragdoll(v_9_upvr)
						var3_upvw.applyDamage(v_9_upvr, 5)
						var3_upvw.applyStatus(v_9_upvr, "Stunned", 0.5)
						var3_upvw.Knockback(v_9_upvr, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 0, 0)
					end
				end
				wait(0.1)
			end
			wait(0.2)
			var3_upvw.crater(1, Eruption1_upvr.Position, 2, 0.15)
			var3_upvw.CreateDebris(Eruption1_upvr.Position, 6, 1.5, 1, 0.1)
			if Eruption1_upvr == clone_upvr.Eruption1 then
			end
			var3_upvw.camShake(arg1, "Bump")
			var3_upvw.changeFov(arg1, 100, 0, 0.5)
			for _, v_10_upvr in var3_upvw.findEnemiesPart(Eruption1_upvr, true), nil do
				if not var3_upvw.CheckBlock(v_10_upvr, false) then
					if not table.find(tbl_2_upvr, v_10_upvr) then
						table.insert(tbl_2_upvr, v_10_upvr)
						delay(0.05, function() -- Line 157
							--[[ Upvalues[2]:
								[1]: tbl_2_upvr (copied, readonly)
								[2]: v_10_upvr (readonly)
							]]
							table.remove(tbl_2_upvr, table.find(tbl_2_upvr, v_10_upvr))
						end)
						if arg1:FindFirstChild("HotPan") then
							var3_upvw.applyDamage(v_10_upvr, 20)
						else
							var3_upvw.applyDamage(v_10_upvr, 10)
						end
						var3_upvw.applyStatus(v_10_upvr, "Ragdoll", 2)
						var3_upvw.Knockback(v_10_upvr, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 5, 50)
					end
				end
			end
		end)
	end), 5)
end
return module_upvr
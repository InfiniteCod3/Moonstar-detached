-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:19:09
-- Luau version 6, Types version 3
-- Time taken: 0.007916 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 28
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
	local Season_upvr = ReplicatedStorage_upvr.Skills.Chef.Season
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Season_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(1)
	var3_upvw.applyStatus(arg1, "Freeze", 1)
	var3_upvw.applyStatus(arg1, "GlobalCD", 1)
	var3_upvw.applyStatus(arg1, "HyperArmor", 1)
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 65, 0.5, 2)
	local Chef_upvr = arg1:FindFirstChild("Chef")
	delay(0.25, function() -- Line 45
		--[[ Upvalues[5]:
			[1]: var3_upvw (copied, read and write)
			[2]: Season_upvr (readonly)
			[3]: arg1 (readonly)
			[4]: Chef_upvr (readonly)
			[5]: TweenService_upvr (copied, readonly)
		]]
		local any_cloneInstance_result1_2_upvr = var3_upvw.cloneInstance(Season_upvr.HotPan, arg1, 11)
		any_cloneInstance_result1_2_upvr.weld.Part0 = Chef_upvr.Pan
		any_cloneInstance_result1_2_upvr.weld.Part1 = any_cloneInstance_result1_2_upvr
		TweenService_upvr:Create(Chef_upvr.Pan, TweenInfo.new(0.5), {
			Transparency = 1;
		}):Play()
		TweenService_upvr:Create(any_cloneInstance_result1_2_upvr, TweenInfo.new(0.5), {
			Transparency = 0;
		}):Play()
		for _, v in any_cloneInstance_result1_2_upvr:GetChildren() do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end
		end
		delay(10, function() -- Line 58
			--[[ Upvalues[1]:
				[1]: any_cloneInstance_result1_2_upvr (readonly)
			]]
			any_cloneInstance_result1_2_upvr.Name = "UsedHotPan"
		end)
		var3_upvw.conTimer(any_cloneInstance_result1_2_upvr:GetPropertyChangedSignal("Name"):Connect(function() -- Line 62
			--[[ Upvalues[3]:
				[1]: any_cloneInstance_result1_2_upvr (readonly)
				[2]: TweenService_upvr (copied, readonly)
				[3]: Chef_upvr (copied, readonly)
			]]
			if any_cloneInstance_result1_2_upvr.Name == "UsedHotPan" then
				TweenService_upvr:Create(Chef_upvr.Pan, TweenInfo.new(0.35), {
					Transparency = 0;
				}):Play()
				TweenService_upvr:Create(any_cloneInstance_result1_2_upvr, TweenInfo.new(0.35), {
					Transparency = 1;
				}):Play()
				for _, v_2 in any_cloneInstance_result1_2_upvr:GetChildren() do
					if v_2:IsA("ParticleEmitter") then
						v_2.Enabled = false
					end
				end
			end
		end), 11)
	end)
	var3_upvw.changeFov(arg1, 90, 1, 3)
	local any_applySound_result1_upvr_2 = var3_upvw.applySound(Season_upvr.CookingSFX, HumanoidRootPart_upvr, 4)
	local any_applySound_result1_upvr = var3_upvw.applySound(Season_upvr.swingSFX, HumanoidRootPart_upvr, 4)
	var3_upvw.conTimer(any_LoadAnimation_result1.Stopped:Once(function() -- Line 80
		--[[ Upvalues[2]:
			[1]: any_applySound_result1_upvr (readonly)
			[2]: any_applySound_result1_upvr_2 (readonly)
		]]
		game.Debris:AddItem(any_applySound_result1_upvr, 0)
		game.Debris:AddItem(any_applySound_result1_upvr_2, 0)
	end), 4)
	delay(0.5, function() -- Line 85
		--[[ Upvalues[2]:
			[1]: any_applySound_result1_upvr_2 (readonly)
			[2]: TweenService_upvr (copied, readonly)
		]]
		if any_applySound_result1_upvr_2 then
			TweenService_upvr:Create(any_applySound_result1_upvr_2, TweenInfo.new(0.3), {
				Volume = 0;
			}):Play()
		end
	end)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Action"):Once(function() -- Line 91
		--[[ Upvalues[5]:
			[1]: var3_upvw (copied, read and write)
			[2]: Season_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: arg1 (readonly)
			[5]: Folder_upvr (readonly)
		]]
		var3_upvw.applySound(Season_upvr.ThrowSFX, HumanoidRootPart_upvr, 5)
		var3_upvw.applySound(Season_upvr.ThrowSFX2, HumanoidRootPart_upvr, 5)
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.flashScreen(arg1, Color3.new(1, 0.4, 0.4), 0.3)
		var3_upvw.changeFov(arg1, 70, 0, 0.5)
		local tbl = {
			Replication = "Season";
		}
		tbl.Character = arg1
		var3_upvw.Replication("All", "Chef", tbl)
		local any_cloneInstance_result1 = var3_upvw.cloneInstance(Season_upvr.HitboxHolder, Folder_upvr, 1)
		any_cloneInstance_result1.CFrame = HumanoidRootPart_upvr.CFrame
		for _, v_3 in var3_upvw.findEnemiesPart(any_cloneInstance_result1.Hitbox, true), nil do
			if not var3_upvw.CheckBlock(v_3, false) then
				var3_upvw.unragdoll(v_3)
				var3_upvw.applyDamage(v_3, 10)
				var3_upvw.applyStatus(v_3, "Stunned", 1.42)
				var3_upvw.Knockback(v_3, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, -15)
				v_3.Humanoid:LoadAnimation(Season_upvr.SneezeAnim):Play()
			end
		end
	end), 3)
end
return module_upvr
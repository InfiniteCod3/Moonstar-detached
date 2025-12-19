-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:09
-- Luau version 6, Types version 3
-- Time taken: 0.008312 seconds

local module_upvr = {
	Cooldown = 19;
	GlobalCD = 0.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 12
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Kneel_upvr = ReplicatedStorage_upvr.Skills.Nebula.Ultimate.Kneel
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Kneel_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.cameraCutscene(arg1, "Kneel")
	var2_upvw.applyStatus(arg1, "Stunned", 3.5)
	var2_upvw.applyStatus(arg1, "AutoRotate", 3.5)
	var2_upvw.applyStatus(arg1, "IFrames", 3.5)
	var2_upvw.applyStatus(arg1, "Ultimate", 3.5)
	local var9_upvr = arg1:FindFirstChild("NebulaHighlight") or false
	if var9_upvr then
		TweenService_upvr:Create(var9_upvr, TweenInfo.new(1), {
			OutlineTransparency = 0.5;
			FillTransparency = 1;
		}):Play()
		task.delay(3, function() -- Line 39
			--[[ Upvalues[2]:
				[1]: TweenService_upvr (copied, readonly)
				[2]: var9_upvr (readonly)
			]]
			TweenService_upvr:Create(var9_upvr, TweenInfo.new(2), {
				OutlineTransparency = 0;
				FillTransparency = 0;
			}):Play()
		end)
	end
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 44
		--[[ Upvalues[3]:
			[1]: Kneel_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		for _, v in Kneel_upvr:GetChildren() do
			if v:IsA("Sound") and v.Name == arg1_2 then
				var2_upvw.applySound(v, HumanoidRootPart_upvr)
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.camShake(arg1, "SmallBump")
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Charge"):Connect(function() -- Line 54
		--[[ Upvalues[4]:
			[1]: var2_upvw (copied, read and write)
			[2]: Kneel_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: arg1 (readonly)
		]]
		var2_upvw.applyVFX(Kneel_upvr.VFX.Charge, HumanoidRootPart_upvr, 5)
		var2_upvw.applySound(Kneel_upvr.Charge, HumanoidRootPart_upvr)
		var2_upvw.camShake(arg1, "SmallBump")
		var2_upvw.changeFov(arg1, 69, 0, 1)
		var2_upvw.Blur(arg1, 5, 1)
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Fire"):Connect(function() -- Line 62
		--[[ Upvalues[5]:
			[1]: var2_upvw (copied, read and write)
			[2]: Kneel_upvr (readonly)
			[3]: Folder_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: arg1 (readonly)
		]]
		local any_applyVFX_result1_upvr = var2_upvw.applyVFX(Kneel_upvr.Gravity, Folder_upvr, 10)
		any_applyVFX_result1_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 100
		local var24_upvw = true
		task.spawn(function() -- Line 67
			--[[ Upvalues[5]:
				[1]: any_applyVFX_result1_upvr (readonly)
				[2]: var24_upvw (read and write)
				[3]: var2_upvw (copied, read and write)
				[4]: arg1 (copied, readonly)
				[5]: Kneel_upvr (copied, readonly)
			]]
			while task.wait(0.1) and any_applyVFX_result1_upvr.Parent and var24_upvw do
				var2_upvw.camShake(arg1, "SmallBump")
				var2_upvw.changeFov(arg1, 75, 0, 0.2)
				var2_upvw.Blur(arg1, 10, 0.12)
				local any_applySound_result1 = var2_upvw.applySound(Kneel_upvr.Rubble, any_applyVFX_result1_upvr)
				any_applySound_result1.PlaybackSpeed += math.random(-2, 2) * 0.1
			end
		end)
		task.spawn(function() -- Line 79
			--[[ Upvalues[4]:
				[1]: any_applyVFX_result1_upvr (readonly)
				[2]: var24_upvw (read and write)
				[3]: var2_upvw (copied, read and write)
				[4]: Kneel_upvr (copied, readonly)
			]]
			while task.wait(0.2) and any_applyVFX_result1_upvr.Parent and var24_upvw do
				for _, v_2 in var2_upvw.findEnemiesPart(any_applyVFX_result1_upvr.Hitbox, true), nil do
					if not var2_upvw.CheckBlock(v_2) then
						var2_upvw.unragdoll(v_2)
						var2_upvw.applyDamage(v_2, 1)
						var2_upvw.applyStatus(v_2, "Stunned", 1.2)
						var2_upvw.applyStatus(v_2, "AutoRotate", 1.2)
						v_2.Humanoid:LoadAnimation(Kneel_upvr.GravityAnim):Play()
					end
				end
			end
		end)
		task.wait(6)
		var24_upvw = false
		for _, v_3 in any_applyVFX_result1_upvr:GetDescendants() do
			if v_3:IsA("ParticleEmitter") then
				v_3.Enabled = false
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 108
	end), module_upvr.Cooldown)
end
return module_upvr
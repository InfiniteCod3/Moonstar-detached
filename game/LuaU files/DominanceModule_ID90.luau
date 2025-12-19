-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:17
-- Luau version 6, Types version 3
-- Time taken: 0.009612 seconds

local module_upvr = {
	Cooldown = 21;
	GlobalCD = 1.4;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
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
	local Dominance_upvr = ReplicatedStorage_upvr.Skills["Titans Edge"].Dominance
	var2_upvw.applyStatus(arg1, "Freeze", 2.2)
	var2_upvw.applyStatus(arg1, "GlobalCD", 2.2)
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid"):LoadAnimation(Dominance_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play(0)
	any_LoadAnimation_result1_upvr:AdjustSpeed(1.5)
	local var9_upvw
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 41
		--[[ Upvalues[4]:
			[1]: var2_upvw (copied, read and write)
			[2]: Dominance_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var9_upvw (read and write)
		]]
		local any_applySound_result1_2 = var2_upvw.applySound(Dominance_upvr[arg1_2], HumanoidRootPart_upvr)
		if any_applySound_result1_2.Name == "HeavyWindBurst" then
			var9_upvw = any_applySound_result1_2
		end
	end), module_upvr.Cooldown)
	task.wait(0.05)
	local clone_upvr = Dominance_upvr.VFX.TrailAtt:Clone()
	clone_upvr.Parent = HumanoidRootPart_upvr
	var2_upvw.applyDebris(clone_upvr, 6)
	local clone_2_upvr = Dominance_upvr.DominanceAura.AuraATT:Clone()
	clone_2_upvr.Parent = HumanoidRootPart_upvr
	var2_upvw.applyDebris(clone_2_upvr, 5)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 58
		--[[ Upvalues[2]:
			[1]: clone_upvr (readonly)
			[2]: clone_2_upvr (readonly)
		]]
		clone_upvr.Trail.Enabled = false
		for _, v in clone_2_upvr:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 1)
	var2_upvw.changeFov(arg1, 60, 3, 5)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("jump"):Connect(function() -- Line 71
		--[[ Upvalues[7]:
			[1]: clone_upvr (readonly)
			[2]: ReplicatedStorage_upvr (copied, readonly)
			[3]: arg2 (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: Dominance_upvr (readonly)
			[7]: HumanoidRootPart_upvr (readonly)
		]]
		clone_upvr.Trail.Enabled = true
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "Dominance")
		var2_upvw.camShake(arg1, "SmallBump")
		local clone_3 = Dominance_upvr.VFX.JumpVFX:Clone()
		clone_3.Parent = HumanoidRootPart_upvr
		var2_upvw.EmitAllDescendants(clone_3)
		var2_upvw.applyDebris(clone_3, 6)
	end), module_upvr.Cooldown)
	local var23_upvw = true
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("land"):Connect(function() -- Line 83
		--[[ Upvalues[4]:
			[1]: var23_upvw (read and write)
			[2]: var2_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: clone_2_upvr (readonly)
		]]
		var23_upvw = false
		var2_upvw.camShake(arg1, "SmallBump")
		for _, v_2 in clone_2_upvr:GetDescendants() do
			if v_2:IsA("ParticleEmitter") then
				v_2.Enabled = false
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function() -- Line 94
		--[[ Upvalues[9]:
			[1]: clone_upvr (readonly)
			[2]: any_LoadAnimation_result1_upvr (readonly)
			[3]: TweenService_upvr (copied, readonly)
			[4]: var9_upvw (read and write)
			[5]: var2_upvw (copied, read and write)
			[6]: arg1 (readonly)
			[7]: Dominance_upvr (readonly)
			[8]: Folder_upvr (readonly)
			[9]: HumanoidRootPart_upvr (readonly)
		]]
		clone_upvr.Trail.Enabled = false
		any_LoadAnimation_result1_upvr:AdjustSpeed(1.2)
		TweenService_upvr:Create(var9_upvw, TweenInfo.new(1.25, Enum.EasingStyle.Linear), {
			Volume = 0;
		}):Play()
		var2_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 0.3)
		var2_upvw.changeFov(arg1, 20, 0, 1)
		task.delay(0.1, function() -- Line 102
			--[[ Upvalues[2]:
				[1]: var2_upvw (copied, read and write)
				[2]: arg1 (copied, readonly)
			]]
			var2_upvw.changeFov(arg1, 90, 0.25, 1)
		end)
		var2_upvw.camShake(arg1, "Bump")
		local clone = Dominance_upvr.DominanceBlast:Clone()
		clone.Parent = Folder_upvr
		clone.CFrame = HumanoidRootPart_upvr.CFrame
		var2_upvw.applyDebris(clone, 8)
		var2_upvw.EmitAllDescendants(clone)
		local var37
		for i_3, v_3 in var2_upvw.findEnemiesPart(clone.Hitbox, true), nil do
			if not var2_upvw.CheckBlock(v_3) then
				local clone_4 = Dominance_upvr.VFX.hitVFX:Clone()
				clone_4.Parent = v_3.Torso
				var2_upvw.applyDebris(clone_4, 6)
				var2_upvw.EmitAllDescendants(clone_4)
				local any_applySound_result1 = var2_upvw.applySound(Dominance_upvr.GreatswordHit, v_3.Torso)
				any_applySound_result1.PlaybackSpeed += math.random(-2, 2) * 0.06
				var2_upvw.applyStatus(v_3, "Ragdoll", 1.8)
				var2_upvw.Knockback(v_3, HumanoidRootPart_upvr.Position, 25, 10)
				var2_upvw.applyDamage(v_3, 20)
			end
		end
		if not nil then
			i_3 = 1.5
			var2_upvw.applyStatus(arg1, "Stunned", i_3)
			i_3 = 1.5
			var2_upvw.applyStatus(arg1, "AutoRotate", i_3)
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 139
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:Stop(0.7)
	end), module_upvr.Cooldown)
end
return module_upvr
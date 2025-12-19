-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:15
-- Luau version 6, Types version 3
-- Time taken: 0.016042 seconds

local module_upvr = {
	Cooldown = 15;
	GlobalCD = 1.2;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 15
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
	local Blood_Slashes_upvr = ReplicatedStorage_upvr.Skills["Blood Sword"]["Blood Slashes"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Blood_Slashes_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "Slowed", 1.1)
	local any_applySound_result1 = var2_upvw.applySound(Blood_Slashes_upvr.pull, HumanoidRootPart_upvr)
	any_applySound_result1.Volume = 0
	TweenService_upvr:Create(any_applySound_result1, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Volume = 2;
	}):Play()
	var2_upvw.applyStatus(arg1, "LightAttack", 1.4)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("hit1"):Connect(function() -- Line 47
		--[[ Upvalues[5]:
			[1]: Blood_Slashes_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: Folder_upvr (readonly)
			[5]: arg1 (readonly)
		]]
		local clone_3 = Blood_Slashes_upvr.swooosh:Clone()
		clone_3.Parent = HumanoidRootPart_upvr
		clone_3:Play()
		game.Debris:AddItem(clone_3, 3)
		local clone_5 = Blood_Slashes_upvr.hitbox:Clone()
		clone_5.Parent = Folder_upvr
		clone_5.CFrame = HumanoidRootPart_upvr.CFrame * CFrame.new(0, 0, -2)
		game.Debris:AddItem(clone_5, 1)
		local clone_8 = Blood_Slashes_upvr.slash:Clone()
		clone_8.Parent = Folder_upvr
		game.Debris:AddItem(clone_8, 2)
		local clone_10 = Blood_Slashes_upvr.bloodEmit:Clone()
		clone_10.Parent = Folder_upvr
		game.Debris:AddItem(clone_10)
		clone_8.CFrame = HumanoidRootPart_upvr.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, -0.33597588100890846)
		var2_upvw.EmitAllDescendants(clone_8.one)
		local WeldConstraint_2 = Instance.new("WeldConstraint", clone_8)
		WeldConstraint_2.Part0 = HumanoidRootPart_upvr
		WeldConstraint_2.Part1 = clone_8
		var2_upvw.camShake(arg1, "SmallBump")
		local any_findEnemiesPart_result1_2 = var2_upvw.findEnemiesPart(clone_5, true)
		if 0 < #any_findEnemiesPart_result1_2 then
			local clone_6 = Blood_Slashes_upvr.slashSFX:Clone()
			clone_6.Parent = HumanoidRootPart_upvr
			game.Debris:AddItem(clone_6, 3)
			clone_6:Play()
			local clone_9 = Blood_Slashes_upvr.SlashSFX2:Clone()
			clone_9.Parent = HumanoidRootPart_upvr
			game.Debris:AddItem(clone_9, 3)
			clone_9:Play()
		end
		for _, v in any_findEnemiesPart_result1_2 do
			clone_10.CFrame = v.HumanoidRootPart.CFrame
			var2_upvw.EmitAllDescendants(clone_10)
			var2_upvw.applyStatus(v, "Stunned", 0.7)
			var2_upvw.applyDamage(v, 5)
			var2_upvw.blood(v, 2)
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("hit2"):Connect(function() -- Line 105
		--[[ Upvalues[5]:
			[1]: Blood_Slashes_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: Folder_upvr (readonly)
			[5]: arg1 (readonly)
		]]
		local clone = Blood_Slashes_upvr.swooosh:Clone()
		clone.Parent = HumanoidRootPart_upvr
		clone:Play()
		clone.PlaybackSpeed -= 0.15
		game.Debris:AddItem(clone, 3)
		local any_applySound_result1_2 = var2_upvw.applySound(Blood_Slashes_upvr.swing, HumanoidRootPart_upvr)
		any_applySound_result1_2.PlaybackSpeed -= 0.15
		local clone_11 = Blood_Slashes_upvr.hitbox:Clone()
		clone_11.Parent = Folder_upvr
		clone_11.CFrame = HumanoidRootPart_upvr.CFrame * CFrame.new(0, 0, -2)
		game.Debris:AddItem(clone_11, 1)
		local clone_12 = Blood_Slashes_upvr.slash:Clone()
		clone_12.Parent = Folder_upvr
		game.Debris:AddItem(clone_12, 2)
		local clone_2 = Blood_Slashes_upvr.bloodEmit:Clone()
		clone_2.Parent = Folder_upvr
		game.Debris:AddItem(clone_2)
		clone_12.CFrame = HumanoidRootPart_upvr.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, -1.290845514775006)
		var2_upvw.EmitAllDescendants(clone_12.two)
		local WeldConstraint = Instance.new("WeldConstraint", clone_12)
		WeldConstraint.Part0 = HumanoidRootPart_upvr
		WeldConstraint.Part1 = clone_12
		var2_upvw.camShake(arg1, "SmallBump")
		local any_findEnemiesPart_result1 = var2_upvw.findEnemiesPart(clone_11, true)
		if 0 < #any_findEnemiesPart_result1 then
			local clone_7 = Blood_Slashes_upvr.slashSFX:Clone()
			clone_7.Parent = HumanoidRootPart_upvr
			game.Debris:AddItem(clone_7, 3)
			clone_7:Play()
			local clone_4 = Blood_Slashes_upvr.SlashSFX2:Clone()
			clone_4.Parent = HumanoidRootPart_upvr
			game.Debris:AddItem(clone_4, 3)
			clone_4:Play()
		else
			var2_upvw.applyStatus(arg1, "Stunned", 0.7)
			var2_upvw.applyStatus(arg1, "AutoRotate", 1.1)
		end
		for _, v_2 in any_findEnemiesPart_result1 do
			clone_2.CFrame = v_2.HumanoidRootPart.CFrame
			var2_upvw.EmitAllDescendants(clone_2)
			var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, 5, 30)
			var2_upvw.applyStatus(v_2, "Ragdoll", 1.6)
			var2_upvw.applyDamage(v_2, 5)
			var2_upvw.blood(v_2, 2)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
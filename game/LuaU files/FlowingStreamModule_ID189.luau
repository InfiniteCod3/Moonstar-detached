-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:54
-- Luau version 6, Types version 3
-- Time taken: 0.013545 seconds

local module_upvr = {
	Cooldown = 30;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown + 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Flowing_Stream_upvr = ReplicatedStorage_upvr.Skills["Water Brawler"]["Flowing Stream"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Flowing_Stream_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	local function SetTrailArm(arg1_2) -- Line 31
		--[[ Upvalues[5]:
			[1]: Flowing_Stream_upvr (readonly)
			[2]: arg1 (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: any_LoadAnimation_result1_upvr (readonly)
			[5]: module_upvr (copied, readonly)
		]]
		local clone_3_upvr = Flowing_Stream_upvr.TrailArm:Clone()
		clone_3_upvr.Parent = arg1
		clone_3_upvr.weld.Part0 = arg1_2
		clone_3_upvr.weld.Part1 = clone_3_upvr
		var2_upvw.applyDebris(clone_3_upvr, 10)
		var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 38
			--[[ Upvalues[1]:
				[1]: clone_3_upvr (readonly)
			]]
			for _, v in clone_3_upvr:GetDescendants() do
				if v:IsA("Trail") then
					v.Enabled = false
				end
			end
		end), module_upvr.Cooldown)
	end
	SetTrailArm(arg1["Left Arm"])
	SetTrailArm(arg1["Right Arm"])
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.6)
	var2_upvw.applyStatus(arg1, "Slowed", 1.6)
	var2_upvw.applyStatus(arg1, "CombatStun", 2)
	var2_upvw.resetm1s()
	local clone_2_upvr = Flowing_Stream_upvr.SlashVFX:Clone()
	clone_2_upvr.Parent = arg1
	clone_2_upvr.weld.Part0 = HumanoidRootPart_upvr
	clone_2_upvr.weld.Part1 = clone_2_upvr
	var2_upvw.applyDebris(clone_2_upvr, 10)
	local clone_4_upvr = Flowing_Stream_upvr.SlashHitbox:Clone()
	clone_4_upvr.Parent = Folder
	clone_4_upvr.weld.Part0 = HumanoidRootPart_upvr
	clone_4_upvr.weld.Part1 = clone_4_upvr
	var2_upvw.applyDebris(clone_4_upvr, 10)
	local var18_upvw = 0
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Slash"):Connect(function(arg1_3) -- Line 68
		--[[ Upvalues[7]:
			[1]: var18_upvw (read and write)
			[2]: clone_2_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: arg1 (readonly)
			[6]: clone_4_upvr (readonly)
			[7]: Flowing_Stream_upvr (readonly)
		]]
		var18_upvw += 1
		local SOME = clone_2_upvr:FindFirstChild(arg1_3)
		var2_upvw.EmitAllDescendants(SOME)
		local _, NONE, NONE_3 = SOME:GetChildren()
		local var31
		for _, v_2 in var31, NONE, NONE_3 do
			if v_2:IsA("Sound") then
				local clone_5 = v_2:Clone()
				clone_5.Parent = HumanoidRootPart_upvr
				clone_5.PlaybackSpeed += math.random(-1, 1) * 0.1
				clone_5:Play()
				var2_upvw.applyDebris(clone_5, 3)
			end
		end
		var31 = var2_upvw.camShake
		var31(arg1, "SmallBump")
		var31 = var2_upvw.changeFov
		var31(arg1, 60, 0.01, 0.5)
		var31 = var2_upvw.flashScreen
		var31(arg1, Color3.new(0.415686, 0.717647, 1), 0.5)
		var31 = var2_upvw.Knockback
		var31(arg1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -50, 12, 0)
		var31 = false
		for i_3, v_3 in var2_upvw.findEnemiesPart(clone_4_upvr), nil do
			var31 = true
			var2_upvw.applyDamage(v_3, 2)
			var2_upvw.applyStatus(v_3, "Stunned", 0.75)
			local clone = Flowing_Stream_upvr.HitVFX.hitVFX:Clone()
			clone.Parent = v_3.Torso
			var2_upvw.EmitAllDescendants(clone)
			local hitSFX = clone.hitSFX
			hitSFX.PlaybackSpeed += math.random(-1, 1) * 0.1
			clone.hitSFX:Play()
			var2_upvw.applyDebris(clone, 2)
			var2_upvw.camShake(v_3, "SmallBump")
			var2_upvw.changeFov(v_3, 60, 0.01, 0.5)
			var2_upvw.flashScreen(v_3, Color3.new(0.415686, 0.717647, 1), 0.5)
			if var18_upvw ~= 8 then
				var2_upvw.Knockback(v_3, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -50, 12, 0)
			else
				var2_upvw.Knockback(v_3, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -50, 72, 0)
			end
		end
		if 8 <= var18_upvw and not var31 then
			i_3 = 1.2
			var2_upvw.applyStatus(arg1, "Stunned", i_3)
			i_3 = 1.2
			var2_upvw.applyStatus(arg1, "AutoRotate", i_3)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
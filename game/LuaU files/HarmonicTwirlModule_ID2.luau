-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:49
-- Luau version 6, Types version 3
-- Time taken: 0.006083 seconds

local module_upvr = {
	Cooldown = 14;
	GlobalCD = 1.55;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 12
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Harmonic_Twirl_upvr = ReplicatedStorage_upvr.Skills["Basic Staff"]["Harmonic Twirl"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Harmonic_Twirl_upvr.Animation)
	any_LoadAnimation_result1:Play()
	local var9_upvw = 0
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("spin"):Connect(function() -- Line 32
		--[[ Upvalues[6]:
			[1]: var9_upvw (read and write)
			[2]: var2_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: Harmonic_Twirl_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: Folder_upvr (readonly)
		]]
		var9_upvw += 1
		var2_upvw.changeFov(arg1, 60, 0.1, 0.5)
		var2_upvw.camShake(arg1, "SmallBump")
		var2_upvw.flashScreen(arg1, Color3.fromRGB(255, 235, 123), 0.5)
		local clone_2 = Harmonic_Twirl_upvr.VFX.TwirlVFX:Clone()
		clone_2.Parent = HumanoidRootPart_upvr
		var2_upvw.EmitAllDescendants(clone_2)
		var2_upvw.applyDebris(clone_2, 5)
		for _, v in clone_2:GetChildren() do
			if v:IsA("Sound") then
				v.PlaybackSpeed += math.random(-1, 1) * 0.1
				v:Play()
			end
		end
		local clone_3 = Harmonic_Twirl_upvr.Hitbox:Clone()
		clone_3.Parent = Folder_upvr
		clone_3.Position = HumanoidRootPart_upvr.Position
		var2_upvw.applyDebris(clone_3, 1)
		for _, v_2 in var2_upvw.findEnemiesPart(clone_3), nil do
			var2_upvw.applyDamage(v_2, 3)
			var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, 15)
			var2_upvw.applyStatus(v_2, "Stunned", 0.5)
			if var9_upvw == 5 then
				var2_upvw.applyStatus(v_2, "Ragdoll", 1.8)
			end
			var2_upvw.changeFov(v_2, 60, 0.1, 0.5)
			var2_upvw.camShake(v_2, "Bump")
			var2_upvw.flashScreen(v_2, Color3.fromRGB(255, 235, 123), 0.5)
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 73
		--[[ Upvalues[3]:
			[1]: Harmonic_Twirl_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
		]]
		for _, v_3 in Harmonic_Twirl_upvr:GetChildren() do
			if v_3.Name == arg1_2 and v_3:IsA("Sound") then
				local clone = v_3:Clone()
				clone.PlaybackSpeed += math.random(-1, 1) * 0.1
				clone.Parent = HumanoidRootPart_upvr
				clone:Play()
				var2_upvw.applyDebris(clone, 8)
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr
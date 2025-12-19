-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:47
-- Luau version 6, Types version 3
-- Time taken: 0.007392 seconds

local module_upvr = {
	Cooldown = 18;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local Snow_Blast_upvr = ReplicatedStorage_upvr.Skills["Snow Blasters"]["Snow Blast"]
	local Snow_Blasters_upvr = arg1:FindFirstChild("Snow Blasters")
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Snow_Blast_upvr.Animation)
	any_LoadAnimation_result1:Play()
	local function ToggleTrails_upvr(arg1_2) -- Line 34, Named "ToggleTrails"
		--[[ Upvalues[1]:
			[1]: Snow_Blasters_upvr (readonly)
		]]
		for _, v in Snow_Blasters_upvr:GetDescendants() do
			if v:IsA("Trail") and v.Name == "Trail" then
				v.Enabled = arg1_2
			end
		end
	end
	ToggleTrails_upvr(true)
	var2_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 43
		--[[ Upvalues[2]:
			[1]: Snow_Blasters_upvr (readonly)
			[2]: ToggleTrails_upvr (readonly)
		]]
		for _, v_2 in Snow_Blasters_upvr.RightBlaster.SnowCharge:GetChildren() do
			v_2.Enabled = false
		end
		ToggleTrails_upvr(false)
	end), module_upvr.Cooldown)
	var2_upvw.applyStatus(arg1, "Slowed", 1.4)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.4)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("SnowCharge"):Connect(function() -- Line 54
		--[[ Upvalues[3]:
			[1]: Snow_Blasters_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: arg1 (readonly)
		]]
		for _, v_3 in Snow_Blasters_upvr.RightBlaster.SnowCharge:GetChildren() do
			v_3.Enabled = true
		end
		var2_upvw.camShake(arg1, "SmallBump")
		var2_upvw.changeFov(arg1, 60, 0, 1)
		var2_upvw.flashScreen(arg1, Color3.new(0.72549, 1, 0.980392), 0.2)
	end), module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 65
		--[[ Upvalues[6]:
			[1]: Snow_Blasters_upvr (readonly)
			[2]: Snow_Blast_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: Folder_upvr (readonly)
		]]
		for _, v_4 in Snow_Blasters_upvr.RightBlaster.SnowCharge:GetChildren() do
			v_4.Enabled = false
		end
		local clone_3 = Snow_Blast_upvr.VFX.SnowBlastVFX:Clone()
		clone_3.Parent = HumanoidRootPart_upvr
		var2_upvw.EmitAllDescendants(clone_3)
		var2_upvw.applyDebris(clone_3, 6)
		var2_upvw.camShake(arg1, "BigBump")
		var2_upvw.changeFov(arg1, 20, 0, 0.32)
		var2_upvw.flashScreen(arg1, Color3.new(0.686275, 1, 0.972549), 1)
		local clone_2 = Snow_Blast_upvr.SnowBlastHitbox:Clone()
		clone_2.Parent = Folder_upvr
		clone_2.CFrame = HumanoidRootPart_upvr.CFrame
		var2_upvw.applyDebris(clone_2, 1)
		for _, v_5 in var2_upvw.findEnemiesPart(clone_2.Hitbox), nil do
			if not var2_upvw.CheckBlock(v_5, true) then
				var2_upvw.applyDamage(v_5, 16)
				var2_upvw.Knockback(v_5, HumanoidRootPart_upvr.Position, 25, 0)
				var2_upvw.applyStatus(v_5, "Ragdoll", 1.2)
				var2_upvw.applyStatus(v_5, "Slowed", 2)
				var2_upvw.camShake(arg1, "BigBump")
				var2_upvw.changeFov(arg1, 20, 0, 0.32)
				var2_upvw.flashScreen(arg1, Color3.new(0.686275, 1, 0.972549), 1)
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 101
		--[[ Upvalues[1]:
			[1]: Snow_Blasters_upvr (readonly)
		]]
		for _, v_6 in Snow_Blasters_upvr.SnowBlastSFX:GetChildren() do
			if v_6.Name == arg1_3 then
				local clone = v_6:Clone()
				clone.Name = "SfxClone"
				clone.Parent = Snow_Blasters_upvr
				clone.PlaybackSpeed += math.random(-1, 1) * 0.1
				clone:Play()
				game.Debris:AddItem(clone, 2)
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr
-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:53
-- Luau version 6, Types version 3
-- Time taken: 0.003837 seconds

local module_upvr = {
	Cooldown = 14.5;
	GlobalCD = 1.2;
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
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Raging_Smashes_upvr = ReplicatedStorage_upvr.Skills["Fire Fists"].Ultimate["Raging Smashes"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Raging_Smashes_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	var2_upvw.applyStatus(arg1, "Freeze", 1.2)
	local clone = Raging_Smashes_upvr.Hitbox:Clone()
	clone.Parent = Folder_upvr
	clone.weld.Part1 = clone
	clone.weld.Part0 = HumanoidRootPart_upvr
	var2_upvw.applyDebris(clone, 0.1)
	clone.Transparency = 1
	local clone_3 = Raging_Smashes_upvr.Whoosh:Clone()
	clone_3.Parent = HumanoidRootPart_upvr
	clone_3:Play()
	clone_3.TimePosition = 0.25
	var2_upvw.applyDebris(clone_3, 5)
	var2_upvw.changeFov(arg1, 100, 0.3, 5)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("grab"):Connect(function() -- Line 54
		--[[ Upvalues[7]:
			[1]: Raging_Smashes_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: any_LoadAnimation_result1_upvr (readonly)
			[7]: module_upvr (copied, readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		local clone_2 = Raging_Smashes_upvr.Hitbox:Clone()
		clone_2.Parent = Folder_upvr
		clone_2.weld.Part1 = clone_2
		clone_2.weld.Part0 = HumanoidRootPart_upvr
		var2_upvw.applyDebris(clone_2, 1)
		clone_2.Transparency = 1
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [324] 235. Error Block 5 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [324] 235. Error Block 5 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [37] 28. Error Block 2 start (CF ANALYSIS FAILED)
		-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [324.7]
		-- KONSTANTERROR: [37] 28. Error Block 2 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
end
return module_upvr
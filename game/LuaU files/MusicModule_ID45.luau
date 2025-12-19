-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:53
-- Luau version 6, Types version 3
-- Time taken: 0.004792 seconds

local module_upvr = {
	Cooldown = 1;
	GlobalCD = 0;
	PlayingMusic = false;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local Harp = arg1.Harp
	-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [62] 39. Error Block 32 start (CF ANALYSIS FAILED)
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(ReplicatedStorage_upvr.Skills.Harp.Music.Animation)
	any_LoadAnimation_result1.Looped = true
	task.wait(0.1)
	any_LoadAnimation_result1:Play()
	local var10_upvw = false
	var2_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 34
		--[[ Upvalues[1]:
			[1]: var10_upvw (read and write)
		]]
		var10_upvw = true
	end), module_upvr.Cooldown)
	for _, v in Harp.Songs:GetChildren() do
		v:Stop()
	end
	Harp.Songs:GetChildren()[math.random(1, #Harp.Songs:GetChildren())]:Play()
	module_upvr.PlayingMusic = true
	task.wait(0.4)
	-- KONSTANTERROR: [62] 39. Error Block 32 end (CF ANALYSIS FAILED)
end
return module_upvr
-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:18
-- Luau version 6, Types version 3
-- Time taken: 0.007908 seconds

local module_upvr = {
	Cooldown = 32;
	GlobalCD = 0.8;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module_upvr.Script(arg1, arg2) -- Line 14
	--[[ Upvalues[3]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Vital_Reap_upvr = ReplicatedStorage_upvr.Skills["Blood Sword"]["Vital Reap"]
	local var8_upvw
	local var9_upvw
	local tbl_upvr = {}
	local function SkillCancel_upvr() -- Line 31, Named "SkillCancel"
		--[[ Upvalues[4]:
			[1]: var8_upvw (read and write)
			[2]: var2_upvw (copied, read and write)
			[3]: tbl_upvr (readonly)
			[4]: var9_upvw (read and write)
		]]
		if var8_upvw then
			var2_upvw.applyDebris(var8_upvw, 0)
		end
		if tbl_upvr then
			for _, v in tbl_upvr do
				var2_upvw.applyDebris(v, 0, var9_upvw)
			end
		end
	end
	local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Vital_Reap_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1.1)
	local var14_upvw = false
	any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 48
		--[[ Upvalues[2]:
			[1]: var14_upvw (read and write)
			[2]: SkillCancel_upvr (readonly)
		]]
		var14_upvw = true
		SkillCancel_upvr()
	end)
	var2_upvw.applyStatus(arg1, "Slowed", 2)
	var2_upvw.applyStatus(arg1, "GlobalCD", 2)
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 56
		--[[ Upvalues[3]:
			[1]: Vital_Reap_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		if Vital_Reap_upvr:FindFirstChild(arg1_2) then
			var2_upvw.applySound(Vital_Reap_upvr[arg1_2], HumanoidRootPart_upvr)
		end
	end)
	var2_upvw.changeFov(arg1, 64, 1, 5)
	var2_upvw.camShake(arg1, "SmallBump")
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("stab"):Connect(function() -- Line 64
		--[[ Upvalues[10]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var9_upvw (read and write)
			[5]: Vital_Reap_upvr (readonly)
			[6]: any_LoadAnimation_result1_upvr (readonly)
			[7]: var8_upvw (read and write)
			[8]: tbl_upvr (readonly)
			[9]: var14_upvw (read and write)
			[10]: Humanoid_upvr (readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		var2_upvw.changeFov(arg1, 74, 0, 5)
		var2_upvw.camShake(arg1, "Bump")
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [261] 207. Error Block 10 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [261] 207. Error Block 10 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [33] 28. Error Block 2 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: Expression was reused, decompilation is incorrect
		-- KONSTANTERROR: [33] 28. Error Block 2 end (CF ANALYSIS FAILED)
	end)
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("pullback"):Connect(function() -- Line 132
		--[[ Upvalues[1]:
			[1]: SkillCancel_upvr (readonly)
		]]
		SkillCancel_upvr()
	end)
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 136
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:Stop(0.5)
	end)
end
return module_upvr
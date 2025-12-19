-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:38
-- Luau version 6, Types version 3
-- Time taken: 0.027251 seconds

local module_upvr = {
	Cooldown = 16;
	GlobalCD = 1.4;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 18
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
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Earth_Shatter_upvr = ReplicatedStorage_upvr.Skills.Greatsword["Earth Shatter"]
	local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Earth_Shatter_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	local clone = Earth_Shatter_upvr.Part.Sounds:Clone()
	clone.Parent = arg1.Torso
	game.Debris:AddItem(clone, 10)
	clone.BodyPrepare:Play()
	clone.Whoosh:Play()
	clone.slash:Play()
	var2_upvw.applyStatus(arg1, "Freeze", 1.4)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("autorotate"):Connect(function() -- Line 47
		--[[ Upvalues[2]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
		]]
		var2_upvw.applyStatus(arg1, "AutoRotate", 0.6)
	end), module_upvr.Cooldown)
	var2_upvw.changeFov(arg1, 100, 1, 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Chain_Finisher_upvr = Earth_Shatter_upvr["Chain Finisher"]
	local Greatsword_upvr = arg1:FindFirstChild("Greatsword")
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slam"):Connect(function() -- Line 52
		--[[ Upvalues[11]:
			[1]: Earth_Shatter_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: TweenService_upvr (copied, readonly)
			[7]: any_LoadAnimation_result1_upvr (readonly)
			[8]: Humanoid_upvr (readonly)
			[9]: Chain_Finisher_upvr (readonly)
			[10]: module_upvr (copied, readonly)
			[11]: Greatsword_upvr (readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 64 start (CF ANALYSIS FAILED)
		local clone_2 = Earth_Shatter_upvr.HitboxHolder:Clone()
		clone_2.Parent = Folder_upvr
		clone_2.CFrame = HumanoidRootPart_upvr.CFrame
		local tbl_2 = {}
		tbl_2.Character = arg1
		tbl_2.Replication = "EarthShatter"
		tbl_2.ShatterCF = clone_2.CFrame
		var2_upvw.Replication("All", "Greatsword", tbl_2)
		task.wait()
		clone_2.Welds:Destroy()
		local var28
		for _, v in clone_2:GetDescendants() do
			var28 = "BasePart"
			if v:IsA(var28) then
				v.Transparency = 1
				v.Anchored = true
			end
		end
		var2_upvw.changeFov(arg1, 70, 0.05, 10)
		var2_upvw.camShake(arg1, "SmallBump")
		-- KONSTANTERROR: [0] 1. Error Block 64 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [399] 303. Error Block 11 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [399] 303. Error Block 11 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [83] 62. Error Block 68 start (CF ANALYSIS FAILED)
		-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [399.9]
		if not nil then
			-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [399.10]
			-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [399.11]
			if nil <= nil then
				if false then
					var2_upvw.applyStatus(arg1, "CombatStun", 1.2)
				end
				-- KONSTANTERROR: Expression was reused, decompilation is incorrect
				if false then return end
				task.delay(0.2, function() -- Line 255
					--[[ Upvalues[1]:
						[1]: Greatsword_upvr (copied, readonly)
					]]
					for _, v_2 in Greatsword_upvr.FireVfx:GetChildren() do
						v_2.Enabled = true
					end
				end)
				task.wait(0.65)
				local tbl = {}
				var28 = arg1
				tbl.Character = var28
				var28 = "EarthShatter2"
				tbl.Replication = var28
				var2_upvw.Replication("All", "Greatsword", tbl)
				var28 = 3
				var2_upvw.changeFov(arg1, 95, 0.01, var28)
				var28 = 0.678431
				var2_upvw.flashScreen(arg1, Color3.new(1, var28, 0.494118), 1.5)
				for _, v_3 in Greatsword_upvr.FireVfx:GetChildren() do
					v_3.Enabled = false
				end
				var2_upvw.camShake(arg1, "Bump")
				var2_upvw.impactFrame2(arg1)
				-- KONSTANTWARNING: GOTO [489] #375
			end
			-- KONSTANTWARNING: GOTO [369] #278
		end
		-- KONSTANTERROR: [83] 62. Error Block 68 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
end
return module_upvr
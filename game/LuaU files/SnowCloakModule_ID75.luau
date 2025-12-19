-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:50
-- Luau version 6, Types version 3
-- Time taken: 0.007074 seconds

local module_upvr = {
	Cooldown = 26;
	GlobalCD = 1;
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
	local Snow_Cloak_upvr = ReplicatedStorage_upvr.Skills["Snow Blasters"]["Snow Cloak"]
	local Snow_Blasters_upvr = arg1:FindFirstChild("Snow Blasters")
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Snow_Cloak_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	local function ToggleTrails_upvr(arg1_2) -- Line 35, Named "ToggleTrails"
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
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 44
		--[[ Upvalues[2]:
			[1]: Snow_Blasters_upvr (readonly)
			[2]: ToggleTrails_upvr (readonly)
		]]
		for _, v_2 in Snow_Blasters_upvr.RightBlaster.SnowCharge:GetChildren() do
			v_2.Enabled = false
		end
		ToggleTrails_upvr(false)
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 51
		--[[ Upvalues[1]:
			[1]: Snow_Blasters_upvr (readonly)
		]]
		if Snow_Blasters_upvr:FindFirstChild(arg1_3) then
			Snow_Blasters_upvr[arg1_3]:Play()
		end
	end), module_upvr.Cooldown)
	local clone = Snow_Cloak_upvr.Summon:Clone()
	clone.Parent = HumanoidRootPart_upvr
	clone:Play()
	var2_upvw.applyDebris(clone, 5)
	var2_upvw.changeFov(arg1, 100, 0.7, 2)
	local tbl_upvr = {}
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "GlobalCD", 2))
	table.insert(tbl_upvr, var2_upvw.applyStatus(arg1, "Slowed", 2))
	local var24_upvw
	var24_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_4, arg2_2, arg3) -- Line 69
		--[[ Upvalues[10]:
			[1]: arg2 (readonly)
			[2]: var24_upvw (read and write)
			[3]: Snow_Blasters_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: any_LoadAnimation_result1_upvr (readonly)
			[7]: tbl_upvr (readonly)
			[8]: HumanoidRootPart_upvr (readonly)
			[9]: Snow_Cloak_upvr (readonly)
			[10]: Folder_upvr (readonly)
		]]
		if arg2_2 ~= "SnowCloak" or arg1_4 ~= arg2 then
		else
			var24_upvw:Disconnect()
			Snow_Blasters_upvr["Light Attack"]:Play()
			var2_upvw.changeFov(arg1, 70, 0, 0)
			any_LoadAnimation_result1_upvr:Stop(0)
			for _, v_3 in tbl_upvr do
				var2_upvw.applyDebris(v_3, 0)
			end
			var2_upvw.camShake(arg1, "Bump")
			var2_upvw.impactFrame(arg1)
			task.delay(0.05, function() -- Line 84
				--[[ Upvalues[2]:
					[1]: var2_upvw (copied, read and write)
					[2]: arg1 (copied, readonly)
				]]
				var2_upvw.impactFrame2(arg1)
				task.wait(0.05)
				var2_upvw.impactFrame(arg1)
			end)
			HumanoidRootPart_upvr.CFrame = CFrame.new(arg3.TeleportPosition) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
			local clone_2 = Snow_Cloak_upvr.TeleportVFX:Clone()
			clone_2.Parent = Folder_upvr
			clone_2.CFrame = HumanoidRootPart_upvr.CFrame
			var2_upvw.EmitAllDescendants(clone_2)
			var2_upvw.applyDebris(clone_2, 6)
			for _, v_4 in clone_2:GetChildren() do
				if v_4:IsA("Sound") then
					v_4:Play()
				end
			end
			for _, v_5 in var2_upvw.findEnemiesMagnitude(clone_2.Position, 18, true), nil do
				if not var2_upvw.CheckBlock(v_5) then
					var2_upvw.applyDamage(v_5, 12)
					var2_upvw.Knockback(v_5, clone_2.Position, 30, 10)
					var2_upvw.applyStatus(v_5, "Ragdoll", 0.5)
					var2_upvw.applyStatus(v_5, "DashDB", 0.5)
					var2_upvw.applyStatus(v_5, "Stunned", 0.9)
					var2_upvw.applyStatus(v_5, "Slowed", 1)
				end
			end
		end
	end), module_upvr.Cooldown)
	task.delay(4, function() -- Line 118
		--[[ Upvalues[1]:
			[1]: var24_upvw (read and write)
		]]
		if not var24_upvw then
		else
			var24_upvw:Disconnect()
		end
	end)
end
return module_upvr
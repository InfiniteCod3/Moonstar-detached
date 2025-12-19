-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:52
-- Luau version 6, Types version 3
-- Time taken: 0.012669 seconds

local module_upvr = {
	Cooldown = 28;
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
	local Chilling_Arc_upvr = ReplicatedStorage_upvr.Skills["Snow Blasters"]["Chilling Arc"]
	local clone_4 = Chilling_Arc_upvr.Indicator.Summon:Clone()
	clone_4.Parent = HumanoidRootPart_upvr
	clone_4:Play()
	var2_upvw.applyDebris(clone_4, 4)
	var2_upvw.changeFov(arg1, 85, 0.7, 2)
	var2_upvw.camShake(arg1, "SmallBump")
	local tbl_3_upvr = {}
	table.insert(tbl_3_upvr, var2_upvw.applyStatus(arg1, "GlobalCD", 2))
	table.insert(tbl_3_upvr, var2_upvw.applyStatus(arg1, "Slowed", 2))
	local var10_upvw
	var10_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 44
		--[[ Upvalues[8]:
			[1]: arg2 (readonly)
			[2]: var10_upvw (read and write)
			[3]: tbl_3_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: Chilling_Arc_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: arg1 (readonly)
			[8]: HumanoidRootPart_upvr (readonly)
		]]
		if arg2_2 ~= "Chilling Arc" or arg1_2 ~= arg2 then
		else
			var10_upvw:Disconnect()
			for _, v in tbl_3_upvr do
				var2_upvw.applyDebris(v, 0.5)
			end
			local clone_5 = Chilling_Arc_upvr.VFX:Clone()
			clone_5.Parent = Folder_upvr
			clone_5.CFrame = arg3.IndicatorCF
			var2_upvw.applyDebris(clone_5, 10)
			local tbl = {}
			for i_2 = 1, 4 do
				local SOME = clone_5:FindFirstChild(i_2)
				local clone = Chilling_Arc_upvr["Light Attack"]:Clone()
				clone.Parent = arg1["Right Arm"]
				clone.PlaybackSpeed += math.random(-1, 1) * 0.05
				clone:Play()
				var2_upvw.applyDebris(clone, 5)
				var2_upvw.camShake(arg1, "SmallBump")
				var2_upvw.changeFov(arg1, 65, 0, 0.1)
				var2_upvw.Blur(arg1, 15, 0.1)
				var2_upvw.flashScreen(arg1, Color3.new(0.709804, 0.996078, 1), 0.5)
				local Snow_Explosion_2 = SOME["Snow Explosion"]
				Snow_Explosion_2.PlaybackSpeed += math.random(-1, 1) * 0.1
				Snow_Explosion_2:Play()
				var2_upvw.EmitAllDescendants(SOME)
				for _, v_2 in var2_upvw.findEnemiesMagnitude(SOME.Position, 18, true), nil do
					if not table.find(tbl, v_2) then
						table.insert(tbl, v_2)
						if not var2_upvw.CheckBlock(v_2) then
							var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, -20, 5)
							var2_upvw.applyStatus(v_2, "Ragdoll", 1)
							var2_upvw.applyStatus(v_2, "Slowed", 1.5)
							var2_upvw.applyDamage(v_2, 13)
							var2_upvw.camShake(v_2, "Bump")
						end
					end
				end
				task.wait(0.06)
			end
		end
	end), module_upvr.Cooldown)
	task.delay(4, function() -- Line 98
		--[[ Upvalues[1]:
			[1]: var10_upvw (read and write)
		]]
		if not var10_upvw then
		else
			var10_upvw:Disconnect()
		end
	end)
end
return module_upvr
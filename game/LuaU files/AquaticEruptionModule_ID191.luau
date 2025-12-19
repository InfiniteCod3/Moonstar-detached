-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:56
-- Luau version 6, Types version 3
-- Time taken: 0.019361 seconds

local module_upvr = {
	Cooldown = 22;
	GlobalCD = 0.1;
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
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Aquatic_Eruption_upvr = ReplicatedStorage_upvr.Skills["Water Brawler"]["Aquatic Eruption"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Aquatic_Eruption_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "Freeze", 1.2)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.2)
	local clone_3 = Aquatic_Eruption_upvr.Whoosh:Clone()
	clone_3.Parent = HumanoidRootPart_upvr
	clone_3:Play()
	var2_upvw.applyDebris(clone_3, 10)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("stomp"):Connect(function() -- Line 39
		--[[ Upvalues[5]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Aquatic_Eruption_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: Folder_upvr (readonly)
		]]
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 60, 0.01, 2)
		var2_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 1)
		var2_upvw.applyStatus(arg1, "Freeze", 1)
		var2_upvw.applyStatus(arg1, "GlobalCD", 1)
		var2_upvw.applyStatus(arg1, "AutoRotate", 1)
		local clone_2 = Aquatic_Eruption_upvr.StompVFX.StompATT:Clone()
		clone_2.Parent = HumanoidRootPart_upvr
		var2_upvw.EmitAllDescendants(clone_2)
		var2_upvw.applyDebris(clone_2, 5)
		for _, v in clone_2:GetChildren() do
			if v:IsA("Sound") then
				v:Play()
			end
		end
		local tbl = {}
		local CFrame = HumanoidRootPart_upvr.CFrame
		for i_2 = 1, 5 do
			local clone_5 = Aquatic_Eruption_upvr.WaterPillar:Clone()
			clone_5.Parent = Folder_upvr
			local var47 = CFrame.Position + (CFrame.LookVector) * (10 * i_2)
			local workspace_Raycast_result1 = workspace:Raycast(var47, Vector3.new(0, -1000, 0), var2_upvw.raycastParams)
			if workspace_Raycast_result1 then
				var47 = workspace_Raycast_result1.Position
			end
			clone_5.CFrame = CFrame.new(var47) * clone_5.CFrame - clone_5.CFrame.p
			var2_upvw.CreateDebris(workspace_Raycast_result1.Position + Vector3.new(0, 0.10000, 0), 10, 1, 0.5, 0.1)
			var2_upvw.crater(1, workspace_Raycast_result1.Position + Vector3.new(0, 0.10000, 0), 2.5, 0.6)
			var2_upvw.EmitAllDescendants(clone_5)
			clone_5.Wave:Play()
			clone_5.Crater:Play()
			local Crater_2 = clone_5.Crater
			Crater_2.PlaybackSpeed += math.random(-2, 2) * 0.1
			var2_upvw.camShake(arg1, "SmallBump")
			var2_upvw.changeFov(arg1, 60, 0.01, 1)
			var2_upvw.flashScreen(arg1, Color3.new(0.690196, 0.815686, 1), 0.5)
			var2_upvw.Blur(arg1, 10, 0.5)
			for _, v_2 in var2_upvw.findEnemiesPart(clone_5.hitbox, true), nil do
				if not table.find(tbl, v_2) then
					table.insert(tbl, v_2)
					if not var2_upvw.CheckBlock(v_2, true) then
						var2_upvw.applyDamage(v_2, 15)
						var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, 0, 50)
						var2_upvw.applyStatus(v_2, "Ragdoll", 2)
						var2_upvw.camShake(v_2, "Bump")
						var2_upvw.changeFov(v_2, 60, 0.01, 1)
						var2_upvw.flashScreen(v_2, Color3.new(0.690196, 0.815686, 1), 1)
						var2_upvw.Blur(v_2, 10, 0.5)
					end
				end
			end
			task.wait(0.2)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
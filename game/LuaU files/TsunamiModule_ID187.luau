-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:52
-- Luau version 6, Types version 3
-- Time taken: 0.009075 seconds

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
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Tsunami_upvr = ReplicatedStorage_upvr.Skills["Water Brawler"].Ultimate.Tsunami
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Tsunami_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "Freeze", 1.2)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.2)
	local clone_2 = Tsunami_upvr.Whoosh:Clone()
	clone_2.Parent = HumanoidRootPart_upvr
	clone_2:Play()
	var2_upvw.applyDebris(clone_2, 10)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("stomp"):Connect(function() -- Line 43
		--[[ Upvalues[5]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Tsunami_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: Folder_upvr (readonly)
		]]
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 60, 0.01, 2)
		var2_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 1)
		var2_upvw.applyStatus(arg1, "Freeze", 1)
		var2_upvw.applyStatus(arg1, "GlobalCD", 1)
		var2_upvw.applyStatus(arg1, "AutoRotate", 1)
		local clone_3 = Tsunami_upvr.StompVFX.StompATT:Clone()
		clone_3.Parent = HumanoidRootPart_upvr
		var2_upvw.EmitAllDescendants(clone_3)
		var2_upvw.applyDebris(clone_3, 5)
		for _, v in clone_3:GetChildren() do
			if v:IsA("Sound") then
				v:Play()
			end
		end
		local tbl = {}
		local CFrame = HumanoidRootPart_upvr.CFrame
		for i_2 = 1, 8 do
			local clone = Tsunami_upvr.WaterPillar:Clone()
			clone.Parent = Folder_upvr
			local var27 = CFrame.Position + (CFrame.LookVector) * (20 * i_2)
			local workspace_Raycast_result1 = workspace:Raycast(var27, Vector3.new(0, -1000, 0), var2_upvw.raycastParams)
			if workspace_Raycast_result1 then
				var27 = workspace_Raycast_result1.Position
			end
			clone.CFrame = CFrame.new(var27) * CFrame - CFrame.p
			var2_upvw.EmitAllDescendants(clone)
			clone.Wave:Play()
			var2_upvw.camShake(arg1, "Bump")
			var2_upvw.changeFov(arg1, 60, 0.01, 1)
			var2_upvw.flashScreen(arg1, Color3.new(0.690196, 0.815686, 1), 0.3)
			var2_upvw.Blur(arg1, 10, 0.5)
			for _, v_2 in var2_upvw.findEnemiesPart(clone.hitbox, true), nil do
				if not table.find(tbl, v_2) then
					table.insert(tbl, v_2)
					var2_upvw.applyDamage(v_2, 30)
					var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position, 0, 80)
					var2_upvw.applyStatus(v_2, "Ragdoll", 2)
					var2_upvw.camShake(v_2, "Bump")
					var2_upvw.changeFov(v_2, 60, 0.01, 1)
					var2_upvw.flashScreen(v_2, Color3.new(0.690196, 0.815686, 1), 1)
					var2_upvw.Blur(v_2, 10, 0.5)
				end
			end
			task.wait(0.125)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
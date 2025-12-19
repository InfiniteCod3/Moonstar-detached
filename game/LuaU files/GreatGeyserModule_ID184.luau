-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:49
-- Luau version 6, Types version 3
-- Time taken: 0.044024 seconds

local module_upvr = {
	Cooldown = 17;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Great_Geyser = ReplicatedStorage_upvr.Skills["Water Brawler"].Ultimate["Great Geyser"]
	arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Great_Geyser.Animation):Play()
	var2_upvw.applyStatus(arg1, "Slowed", 1.5)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.5)
	var2_upvw.applyStatus(arg1, "AutoRotate", 1.5)
	local clone_5 = Great_Geyser.Whoosh1:Clone()
	clone_5.Parent = HumanoidRootPart
	clone_5:Play()
	var2_upvw.applyDebris(clone_5, 6)
	local var105 = HumanoidRootPart.Position + Vector3.new(0, -2.5, 0)
	local workspace_Raycast_result1 = workspace:Raycast(var105, Vector3.new(0, -1000, 0), var2_upvw.raycastParams)
	if workspace_Raycast_result1 then
		var105 = workspace_Raycast_result1.Position
	end
	task.wait(0.05)
	local clone_4 = Great_Geyser.CoreModel:Clone()
	local WaterCore = clone_4.WaterCore
	clone_4.Parent = Folder
	WaterCore.CFrame = CFrame.new(var105) * WaterCore.CFrame - WaterCore.CFrame.p
	var2_upvw.applyDebris(clone_4, 5)
	for _, v in WaterCore:GetChildren() do
		if v:IsA("Sound") then
			v:Play()
		end
	end
	var2_upvw.camShake(arg1, "SmallBump")
	var2_upvw.changeFov(arg1, 60, 0.1, 3)
	var2_upvw.Blur(arg1, 10, 0.5)
	var2_upvw.flashScreen(arg1, Color3.new(0.709804, 0.811765, 1), 1)
	for i_2 = 1, 15 do
		clone_4:ScaleTo(0.05 * i_2 + 0.05)
		task.wait(0.0465)
		local var112_upvr
	end
	task.spawn(function() -- Line 73
		--[[ Upvalues[2]:
			[1]: var112_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
		]]
		for i_3 = 1, 15 do
			var112_upvr:ScaleTo(0.8 - 0.05 * i_3)
			task.wait(0.032)
		end
		var2_upvw.applyDebris(var112_upvr, 0)
	end)
	local clone = Great_Geyser.Whoosh2:Clone()
	clone.Parent = HumanoidRootPart
	clone:Play()
	var2_upvw.applyDebris(clone, 6)
	local clone_3 = Great_Geyser.PullVFX:Clone()
	clone_3.Parent = Folder
	clone_3.CFrame = CFrame.new(var105) * clone_3.CFrame - clone_3.CFrame.p
	var2_upvw.EmitAllDescendants(clone_3)
	var2_upvw.applyDebris(clone_3, 8)
	for _, v_2 in clone_3:GetChildren() do
		if v_2:IsA("Sound") then
			v_2:Play()
		end
	end
	var2_upvw.camShake(arg1, "Bump")
	var2_upvw.changeFov(arg1, 300, 0.1, 2)
	var2_upvw.flashScreen(arg1, Color3.new(0.388235, 0.705882, 1), 1)
	var2_upvw.Blur(arg1, 25, 0.5)
	for _, v_3 in var2_upvw.findEnemiesPart(clone_3.hitbox, true), nil do
		if not var2_upvw.CheckBlock(v_3) then
			for _, v_4 in v_3:GetDescendants() do
				if v_4:IsA("BodyPosition") or v_4:IsA("BodyVelocity") then
					v_4:Destroy()
				end
			end
			var2_upvw.applyDamage(v_3, 2)
			var2_upvw.applyStatus(v_3, "DashDB", 2)
			var2_upvw.applyStatus(v_3, "Ragdoll", 2)
			if not v_3.Head:FindFirstChild("GeyserPull") then
				local BodyPosition = Instance.new("BodyPosition", v_3.Head)
				BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				BodyPosition.Name = "GeyserPull"
				BodyPosition.Position = var105 + Vector3.new(0, 1, 0)
				var2_upvw.applyDebris(BodyPosition, 2)
			end
		end
		var2_upvw.camShake(arg1, "SmallBump")
	end
	task.wait(0.25)
	local clone_2 = Great_Geyser.Geyser:Clone()
	clone_2.Parent = Folder
	clone_2.CFrame = CFrame.new(var105) * clone_2.CFrame - clone_2.CFrame.p
	for _, v_5 in clone_2:GetDescendants() do
		if v_5:IsA("ParticleEmitter") then
			v_5.Enabled = true
		end
	end
	for _, v_6 in clone_2:GetChildren() do
		if v_6:IsA("Sound") and v_6 ~= clone_2.Erupt then
			v_6:Play()
		end
	end
	var2_upvw.camShake(arg1, "Bump")
	var2_upvw.changeFov(arg1, 95, 0.1, 2)
	var2_upvw.flashScreen(arg1, Color3.new(0.388235, 0.705882, 1), 1)
	var2_upvw.Blur(arg1, 25, 0.5)
	local tbl = {}
	for _ = 1, 25 do
		task.wait(0.1)
		for i_10, v_7 in var2_upvw.findEnemiesPart(clone_2.hitbox, true), nil do
			if not var2_upvw.CheckBlock(v_7, true) then
				for _, v_8 in v_7:GetDescendants() do
					if v_8:IsA("BodyPosition") or v_8:IsA("BodyVelocity") then
						v_8:Destroy()
					end
				end
				var2_upvw.applyDamage(v_7, 1)
				var2_upvw.applyStatus(v_7, "DashDB", 0.2)
				var2_upvw.applyStatus(v_7, "Ragdoll", 1)
				if not v_7.Head:FindFirstChild("GiantGeyserBP") then
					local BodyPosition_2 = Instance.new("BodyPosition", v_7.Head)
					BodyPosition_2.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					BodyPosition_2.Name = "GiantGeyserBP"
					BodyPosition_2.Position = clone_2.Position + Vector3.new(0, 100, 0)
					var2_upvw.applyDebris(BodyPosition_2, (25 - i_10) * 0.1)
					table.insert(tbl, BodyPosition_2)
				elseif v_7.Head:FindFirstChild("GiantGeyserBP") then
					v_7.Head.GeyserBP.Position = clone_2.Position + Vector3.new(math.random(-20, 20), math.random(100, 125), math.random(-20, 20))
				end
			end
			var2_upvw.camShake(arg1, "SmallBump")
		end
	end
	for _, v_9 in tbl do
		v_9:Destroy()
	end
	table.clear(tbl)
	for _, v_10 in clone_2:GetDescendants() do
		if v_10:IsA("ParticleEmitter") then
			v_10.Enabled = false
		end
	end
	for _, v_11 in clone_2:GetChildren() do
		if v_11:IsA("Sound") then
			TweenService_upvr:Create(v_11, TweenInfo.new(1), {
				Volume = 0;
			}):Play()
		end
	end
end
return module_upvr
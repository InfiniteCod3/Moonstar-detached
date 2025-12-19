-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:49
-- Luau version 6, Types version 3
-- Time taken: 0.007842 seconds

local module_upvr = {}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Rapid_Ice = ReplicatedStorage_upvr.Skills["Snow Blasters"]["Rapid Ice"]
	local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity.MaxForce = Vector3.new(1000000, 0, 1000000)
	BodyVelocity.Velocity = HumanoidRootPart.CFrame.LookVector * -90
	TweenService_upvr:Create(BodyVelocity, TweenInfo.new(0.3), {
		Velocity = HumanoidRootPart.CFrame.LookVector * -20;
	}):Play()
	game.Debris:AddItem(BodyVelocity, 0.34)
	local clone_3_upvr = Rapid_Ice.Indicator:Clone()
	clone_3_upvr.Parent = Folder
	clone_3_upvr.CFrame = CFrame.new(HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 40) * clone_3_upvr.CFrame - clone_3_upvr.CFrame.p
	game.Debris:AddItem(clone_3_upvr, 4)
	clone_3_upvr.Summon:Play()
	clone_3_upvr.Blizzard:Play()
	clone_3_upvr.Blizzard.Volume = 0
	TweenService_upvr:Create(clone_3_upvr.Blizzard, TweenInfo.new(0.75), {
		Volume = clone_3_upvr.Blizzard.Volume;
	}):Play()
	local var22_upvw = false
	task.delay(0.65, function() -- Line 48
		--[[ Upvalues[3]:
			[1]: var22_upvw (read and write)
			[2]: clone_3_upvr (readonly)
			[3]: TweenService_upvr (copied, readonly)
		]]
		var22_upvw = true
		clone_3_upvr.Despawn:Play()
		for _, v in clone_3_upvr:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			elseif v:IsA("Sound") then
				TweenService_upvr:Create(v, TweenInfo.new(0.8), {
					Volume = 0;
				}):Play()
			end
		end
	end)
	local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 40, Vector3.new(0, -100000, 0), var2_upvw.raycastParams)
	if workspace_Raycast_result1 then
		clone_3_upvr.CFrame = CFrame.new(workspace_Raycast_result1.Position) * clone_3_upvr.CFrame - clone_3_upvr.CFrame.p
	end
	local tbl = {}
	while task.wait() and clone_3_upvr.Parent and not var22_upvw do
		local workspace_Raycast_result1_2 = workspace:Raycast(HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 40, Vector3.new(0, -100000, 0), var2_upvw.raycastParams)
		if workspace_Raycast_result1_2 then
			TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(0.2), {
				CFrame = CFrame.new(workspace_Raycast_result1_2.Position) * clone_3_upvr.CFrame - clone_3_upvr.CFrame.p;
			}):Play()
		end
		local any_findEnemiesPart_result1 = var2_upvw.findEnemiesPart(clone_3_upvr.Hitbox, true)
		for _, v_2 in any_findEnemiesPart_result1 do
			if not table.find(tbl, v_2) then
				table.insert(tbl, v_2)
				local clone = Rapid_Ice.EnemyDetect:Clone()
				clone.Parent = v_2.HumanoidRootPart
				clone.PlaybackSpeed += math.random(-1, 1) * 0.1
				clone:Play()
				var2_upvw.applyDebris(clone, 5)
				local clone_2 = Rapid_Ice.RapidIceHighlight:Clone()
				clone_2.Parent = v_2
				clone_2.Enabled = true
			end
		end
		for _, v_3 in tbl do
			if not table.find(any_findEnemiesPart_result1, v_3) then
				table.remove(tbl, table.find(tbl, v_3))
				for _, v_4 in v_3:GetChildren() do
					if v_4.Name == "RapidIceHighlight" then
						v_4:Destroy()
					end
				end
			end
		end
	end
	ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("RapidIce", {
		enemiesDetected = tbl;
	})
	for _, v_5 in tbl do
		for _, v_6 in v_5:GetChildren() do
			if v_6.Name == "RapidIceHighlight" then
				v_6:Destroy()
			end
		end
	end
	table.clear(tbl)
end
return module_upvr
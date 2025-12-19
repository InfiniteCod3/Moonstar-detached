-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:53
-- Luau version 6, Types version 3
-- Time taken: 0.013477 seconds

local module_upvr = {
	Cooldown = 22;
	GlobalCD = 0.1;
}
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
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local Fluid_Motion_upvr = ReplicatedStorage_upvr.Skills["Water Brawler"]["Fluid Motion"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Fluid_Motion_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(0.5)
	var2_upvw.applyStatus(arg1, "Slowed", 1)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 35
		--[[ Upvalues[6]:
			[1]: Fluid_Motion_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: arg1 (readonly)
			[5]: Folder_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
		]]
		local clone = Fluid_Motion_upvr.VFX.WaterJab:Clone()
		clone.Parent = HumanoidRootPart_upvr
		var2_upvw.EmitAllDescendants(clone)
		var2_upvw.applyDebris(clone, 5)
		local children, _, NONE_3 = clone:GetChildren()
		local var22
		for _, v in children, var22, NONE_3 do
			if v:IsA("Sound") then
				v:Play()
			end
		end
		var22 = var2_upvw
		var22 = arg1
		var22.camShake(var22, "Bump")
		var22 = var2_upvw
		var22 = arg1
		var22.changeFov(var22, 50, 0.01, 2)
		var22 = var2_upvw
		var22 = arg1
		var22.flashScreen(var22, Color3.new(0.388235, 0.705882, 1), 1)
		var22 = var2_upvw
		var22 = arg1
		var22.Blur(var22, 30, 0.5)
		var22 = Fluid_Motion_upvr
		local clone_2 = var22.hitbox:Clone()
		var22 = Folder_upvr
		clone_2.Parent = var22
		var22 = clone_2.weld
		var22.Part0 = HumanoidRootPart_upvr
		var22 = clone_2.weld
		var22.Part1 = clone_2
		var22 = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 50 + Vector3.new(0, -3, 0)
		local workspace_Raycast_result1_2 = workspace:Raycast(HumanoidRootPart_upvr.Position, HumanoidRootPart_upvr.CFrame.LookVector * 50, var2_upvw.raycastParams)
		if workspace_Raycast_result1_2 then
			var22 = workspace_Raycast_result1_2.Position
		end
		local workspace_Raycast_result1 = workspace:Raycast(var22, Vector3.new(0, -100, 0), var2_upvw.raycastParams)
		if workspace_Raycast_result1 then
		end
		local any_findEnemiesPart_result1 = var2_upvw.findEnemiesPart(clone_2)
		for _, v_2 in any_findEnemiesPart_result1 do
			if not var2_upvw.CheckBlock(v_2, true) then
				var2_upvw.applyDamage(v_2, 1)
				var2_upvw.applyStatus(v_2, "Ragdoll", 3)
				local BodyPosition_2 = Instance.new("BodyPosition", v_2.Head)
				BodyPosition_2.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				BodyPosition_2.Name = "GeyserBP"
				BodyPosition_2.Position = workspace_Raycast_result1.Position
				var2_upvw.applyDebris(BodyPosition_2, 2)
			end
		end
		if #any_findEnemiesPart_result1 <= 0 then
		else
			local clone_3_upvr = Fluid_Motion_upvr.Geyser:Clone()
			clone_3_upvr.Parent = Folder_upvr
			-- KONSTANTERROR: Expression was reused, decompilation is incorrect
			local var29 = CFrame.new(workspace_Raycast_result1.Position) * clone_3_upvr.CFrame - clone_3_upvr.CFrame.p
			local workspace_Raycast_result1_3 = workspace:Raycast(var29.Position + Vector3.new(0, 1, 0), Vector3.new(0, -101, 0), var2_upvw.raycastParams)
			if workspace_Raycast_result1_3 then
				var29 = CFrame.new(workspace_Raycast_result1_3.Position) * clone_3_upvr.CFrame - clone_3_upvr.CFrame.p
			end
			clone_3_upvr.CFrame = var29
			clone_3_upvr.Erupt:Play()
			TweenService_upvr:Create(clone_3_upvr.Erupt, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Volume = clone_3_upvr.Erupt.Volume + 1;
			}):Play()
			task.delay(1.5, function() -- Line 98
				--[[ Upvalues[4]:
					[1]: TweenService_upvr (copied, readonly)
					[2]: clone_3_upvr (readonly)
					[3]: var2_upvw (copied, read and write)
					[4]: arg1 (copied, readonly)
				]]
				TweenService_upvr:Create(clone_3_upvr.Erupt, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Volume = 0;
				}):Play()
				for _, v_3 in clone_3_upvr:GetDescendants() do
					if v_3:IsA("ParticleEmitter") then
						v_3.Enabled = true
					end
				end
				for _, v_4 in clone_3_upvr:GetChildren() do
					if v_4:IsA("Sound") and v_4 ~= clone_3_upvr.Erupt then
						v_4:Play()
					end
				end
				var2_upvw.camShake(arg1, "Bump")
				var2_upvw.changeFov(arg1, 95, 0.1, 2)
				var2_upvw.flashScreen(arg1, Color3.new(0.388235, 0.705882, 1), 1)
				var2_upvw.Blur(arg1, 25, 0.5)
				local tbl = {}
				for _ = 1, 15 do
					task.wait(0.1)
					for i_6, v_5 in var2_upvw.findEnemiesPart(clone_3_upvr.hitbox, true), nil do
						if not var2_upvw.CheckBlock(v_5, true) then
							for _, v_6 in v_5:GetDescendants() do
								if v_6:IsA("BodyPosition") or v_6:IsA("BodyVelocity") then
									v_6:Destroy()
								end
							end
							var2_upvw.applyDamage(v_5, 1)
							var2_upvw.applyStatus(v_5, "DashDB", 0.2)
							var2_upvw.applyStatus(v_5, "Ragdoll", 1)
							if not v_5.Head:FindFirstChild("GeyserBP") then
								local BodyPosition = Instance.new("BodyPosition", v_5.Head)
								BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
								BodyPosition.Name = "GeyserBP"
								BodyPosition.Position = clone_3_upvr.Position + Vector3.new(0, 30, 0)
								var2_upvw.applyDebris(BodyPosition, (15 - i_6) * 0.1)
								table.insert(tbl, BodyPosition)
							elseif v_5.Head:FindFirstChild("GeyserBP") then
								v_5.Head.GeyserBP.Position = clone_3_upvr.Position + Vector3.new(math.random(-10, 10), math.random(35, 50), math.random(-10, 10))
							end
						end
						var2_upvw.camShake(arg1, "SmallBump")
					end
				end
				for _, v_7 in tbl do
					v_7:Destroy()
				end
				table.clear(tbl)
				for _, v_8 in clone_3_upvr:GetDescendants() do
					if v_8:IsA("ParticleEmitter") then
						v_8.Enabled = false
					end
				end
				for _, v_9 in clone_3_upvr:GetChildren() do
					if v_9:IsA("Sound") then
						TweenService_upvr:Create(v_9, TweenInfo.new(1), {
							Volume = 0;
						}):Play()
					end
				end
			end)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
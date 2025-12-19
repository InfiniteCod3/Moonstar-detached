-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:44
-- Luau version 6, Types version 3
-- Time taken: 0.023487 seconds

local module_upvr = {
	Cooldown = 16;
	GlobalCD = 1;
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
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Tectonic_Crush_upvr = ReplicatedStorage_upvr.Skills["Earth Hammer"]["Tectonic Crush"]
	local Earth_Hammer_upvr = arg1:FindFirstChild("Earth Hammer")
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Tectonic_Crush_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 33
		--[[ Upvalues[1]:
			[1]: Earth_Hammer_upvr (readonly)
		]]
		Earth_Hammer_upvr.TrailAtt.Trail.Enabled = false
	end), module_upvr.Cooldown)
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	local clone_9_upvr = Tectonic_Crush_upvr.Part.sounds:Clone()
	clone_9_upvr.Parent = arg1.Torso
	var2_upvw.applyDebris(clone_9_upvr, 10)
	var2_upvw.applyStatus(arg1, "Freeze", 1.8)
	var2_upvw.applyStatus(arg1, "AutoRotate", 1.8)
	var2_upvw.applyStatus(arg1, "IFrames", 1.2)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 48
		--[[ Upvalues[4]:
			[1]: HumanoidRootPart_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: clone_9_upvr (readonly)
		]]
		if arg1_2 == "jump" then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = HumanoidRootPart_upvr.CFrame.LookVector * 80 + Vector3.new(0, 10, 0)
			var2_upvw.applyVelocity(arg1.Head, BodyVelocity, 0.1)
		end
		if arg1_2 == "smash" and not workspace:Raycast(HumanoidRootPart_upvr.Position, Vector3.new(0, -7, 0), var2_upvw.raycastParams) then
		elseif clone_9_upvr:FindFirstChild(arg1_2) then
			for _, v_4 in clone_9_upvr:GetChildren() do
				if v_4.Name == arg1_2 then
					v_4:Play()
				end
			end
			return
		end
	end), module_upvr.Cooldown)
	var2_upvw.changeFov(arg1, 95, 0.5, 3)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("smash"):Connect(function() -- Line 77
		--[[ Upvalues[8]:
			[1]: Earth_Hammer_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: arg1 (readonly)
			[5]: Tectonic_Crush_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
		]]
		Earth_Hammer_upvr.TrailAtt.Trail.Enabled = false
		if not workspace:Raycast(HumanoidRootPart_upvr.Position, Vector3.new(0, -7, 0), var2_upvw.raycastParams) then
		else
			var2_upvw.camShake(arg1, "Bump")
			var2_upvw.changeFov(arg1, 65, 0.01, 1)
			var2_upvw.impactFrame2(arg1)
			var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 15, 6, 1, 0.9, 0.1)
			var2_upvw.crater(1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 15, 3, 0.9)
			local clone_7 = Tectonic_Crush_upvr.SmashForward:Clone()
			clone_7.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 9
			clone_7.Parent = Folder_upvr
			var2_upvw.applyDebris(clone_7, 5)
			local clone = Tectonic_Crush_upvr.SmashVfx:Clone()
			clone.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 9
			clone.Parent = Folder_upvr
			var2_upvw.applyDebris(clone, 5)
			local workspace_Raycast_result1 = workspace:Raycast(clone_7.Position, Vector3.new(0, -12, 0), var2_upvw.raycastParams)
			if workspace_Raycast_result1 then
				clone_7.Position = workspace_Raycast_result1.Position
				var2_upvw.EmitAllDescendants(clone_7)
				clone.Position = workspace_Raycast_result1.Position
				var2_upvw.EmitAllDescendants(clone)
			end
			local clone_2 = Tectonic_Crush_upvr.CrushPart:Clone()
			clone_2.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 2 + Vector3.new(0, 1, 0)
			clone_2.Parent = Folder_upvr
			var2_upvw.applyDebris(clone_2, 5)
			local tbl_4_upvr = {}
			local function onHit_upvr(arg1_4) -- Line 112, Named "onHit"
				--[[ Upvalues[2]:
					[1]: var2_upvw (copied, read and write)
					[2]: tbl_4_upvr (readonly)
				]]
				for _, v in var2_upvw.findEnemiesPart(arg1_4, true), nil do
					if not table.find(tbl_4_upvr, v) then
						table.insert(tbl_4_upvr, v)
						var2_upvw.applyStatus(v, "Ragdoll", 2)
						var2_upvw.Knockback(v, arg1_4.Position, 10, 50)
						var2_upvw.applyDamage(v, 15)
					end
				end
			end
			local clone_8 = Tectonic_Crush_upvr.Hitbox:Clone()
			clone_8.Position = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 8 + Vector3.new(0, 1, 0)
			clone_8.Parent = Folder_upvr
			onHit_upvr(clone_8)
			var2_upvw.applyDebris(clone_8, 1)
			for i_2 = 1, 16 do
				for _, v_2 in clone_2:GetChildren() do
					if v_2.Name == tostring(i_2) then
						local workspace_Raycast_result1_4 = workspace:Raycast(v_2.Position + Vector3.new(math.random(-1, 1) * 0.1, 0, math.random(-1, 1) * 0.1), Vector3.new(0, -11, 0), var2_upvw.raycastParams)
						if workspace_Raycast_result1_4 then
							local Part_upvr_2 = Instance.new("Part", workspace.World)
							Part_upvr_2.Position = workspace_Raycast_result1_4.Position
							Part_upvr_2.Size = Vector3.new(0, 0, 0)
							Part_upvr_2.Anchored = true
							Part_upvr_2.Rotation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
							Part_upvr_2.CanCollide = false
							var2_upvw.applyDebris(Part_upvr_2, 6.15)
							local clone_4_upvr = Tectonic_Crush_upvr.rocksfx:Clone()
							clone_4_upvr.Parent = Part_upvr_2
							clone_4_upvr.PlaybackSpeed = math.random(-5, 5) * 0.1
							clone_4_upvr:Play()
							delay(0.5, function() -- Line 149
								--[[ Upvalues[2]:
									[1]: TweenService_upvr (copied, readonly)
									[2]: clone_4_upvr (readonly)
								]]
								TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(math.random(6, 10) * 0.1), {
									Volume = 0;
								}):Play()
							end)
							task.delay(0.3, function() -- Line 153
								--[[ Upvalues[1]:
									[1]: Part_upvr_2 (readonly)
								]]
								Part_upvr_2.CanCollide = true
							end)
							local var74 = i_2 * 0.6
							TweenService_upvr:Create(Part_upvr_2, TweenInfo.new(0.16), {
								Size = Vector3.new(0.5 + var74, 0.5 + var74, 0.5 + var74);
							}):Play()
							Part_upvr_2.Color = workspace_Raycast_result1_4.Instance.Color
							Part_upvr_2.Material = workspace_Raycast_result1_4.Instance.Material
							Part_upvr_2.MaterialVariant = workspace_Raycast_result1_4.Instance.MaterialVariant
							if Part_upvr_2.Material.Name == "Plastic" then
								Part_upvr_2.Material = "SmoothPlastic"
							end
							TweenService_upvr:Create(Part_upvr_2, TweenInfo.new(0.5), {
								Rotation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360));
							}):Play()
							task.delay(0.15, function() -- Line 169
								--[[ Upvalues[5]:
									[1]: onHit_upvr (readonly)
									[2]: Part_upvr_2 (readonly)
									[3]: TweenService_upvr (copied, readonly)
									[4]: var2_upvw (copied, read and write)
									[5]: module_upvr (copied, readonly)
								]]
								onHit_upvr(Part_upvr_2)
								task.wait(5)
								local any_Create_result1_2 = TweenService_upvr:Create(Part_upvr_2, TweenInfo.new(math.random(4, 8) * 0.1), {
									Size = Vector3.new(0, 0, 0);
								})
								any_Create_result1_2:Play()
								var2_upvw.conTimer(any_Create_result1_2.Completed:Connect(function() -- Line 175
									--[[ Upvalues[1]:
										[1]: Part_upvr_2 (copied, readonly)
									]]
									Part_upvr_2:Destroy()
								end), module_upvr.Cooldown)
							end)
							if workspace_Raycast_result1_4.Instance:FindFirstChild("Texture") then
								for _, v_3 in workspace_Raycast_result1_4.Instance:GetChildren() do
									if v_3:IsA("Texture") then
										v_3:Clone().Parent = Part_upvr_2
									end
								end
							end
						end
					end
				end
				task.wait()
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 197
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:Stop(0.9)
	end), module_upvr.Cooldown)
	task.wait()
	Earth_Hammer_upvr.TrailAtt.Trail.Enabled = true
end
return module_upvr
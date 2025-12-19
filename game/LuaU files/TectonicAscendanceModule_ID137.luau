-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:40
-- Luau version 6, Types version 3
-- Time taken: 0.040535 seconds

local module_upvr = {
	Cooldown = 12;
	GlobalCD = 1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
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
	local HumanoidRootPart_2_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Tectonic_Ascendance_upvr = ReplicatedStorage_upvr.Skills["Earth Hammer"].Ultimate["Tectonic Ascendance"]
	local Earth_Hammer_upvr = arg1:FindFirstChild("Earth Hammer")
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Tectonic_Ascendance_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 32
		--[[ Upvalues[1]:
			[1]: Earth_Hammer_upvr (readonly)
		]]
		Earth_Hammer_upvr.TrailAtt.Trail.Enabled = false
	end)
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	local clone_9_upvr = Tectonic_Ascendance_upvr.Part.sounds:Clone()
	clone_9_upvr.Parent = arg1.Torso
	var2_upvw.applyDebris(clone_9_upvr, 10)
	var2_upvw.applyStatus(arg1, "Freeze", 1.8)
	var2_upvw.applyStatus(arg1, "AutoRotate", 1.8)
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 46
		--[[ Upvalues[4]:
			[1]: HumanoidRootPart_2_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: clone_9_upvr (readonly)
		]]
		if arg1_2 == "jump" then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = HumanoidRootPart_2_upvr.CFrame.LookVector * 60 + Vector3.new(0, 15, 0)
			var2_upvw.applyVelocity(arg1.Head, BodyVelocity, 0.1)
		end
		if arg1_2 == "smash" and not workspace:Raycast(HumanoidRootPart_2_upvr.Position, Vector3.new(0, -7, 0), var2_upvw.raycastParams) then
		elseif clone_9_upvr:FindFirstChild(arg1_2) then
			for _, v_9 in clone_9_upvr:GetChildren() do
				if v_9.Name == arg1_2 then
					v_9:Play()
				end
			end
			return
		end
	end)
	var2_upvw.changeFov(arg1, 95, 0.5, 3)
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("smash"):Connect(function() -- Line 75
		--[[ Upvalues[7]:
			[1]: Earth_Hammer_upvr (readonly)
			[2]: HumanoidRootPart_2_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: arg1 (readonly)
			[5]: Tectonic_Ascendance_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
		]]
		Earth_Hammer_upvr.TrailAtt.Trail.Enabled = false
		if not workspace:Raycast(HumanoidRootPart_2_upvr.Position, Vector3.new(0, -7, 0), var2_upvw.raycastParams) then
		else
			var2_upvw.camShake(arg1, "Explosion")
			var2_upvw.changeFov(arg1, 65, 0.01, 1)
			var2_upvw.impactFrame2(arg1)
			var2_upvw.CreateDebris(HumanoidRootPart_2_upvr.Position + HumanoidRootPart_2_upvr.CFrame.LookVector * 15, 6, 1, 0.9, 0.1)
			var2_upvw.crater(1, HumanoidRootPart_2_upvr.Position + HumanoidRootPart_2_upvr.CFrame.LookVector * 15, 4, 0.9)
			local clone_4 = Tectonic_Ascendance_upvr.SmashForward:Clone()
			clone_4.CFrame = HumanoidRootPart_2_upvr.CFrame + HumanoidRootPart_2_upvr.CFrame.LookVector * 15
			clone_4.Parent = Folder_upvr
			var2_upvw.applyDebris(clone_4, 5)
			local clone_7 = Tectonic_Ascendance_upvr.SmashVfx:Clone()
			clone_7.CFrame = HumanoidRootPart_2_upvr.CFrame + HumanoidRootPart_2_upvr.CFrame.LookVector * 15
			clone_7.Parent = Folder_upvr
			var2_upvw.applyDebris(clone_7, 5)
			local workspace_Raycast_result1_3 = workspace:Raycast(clone_4.Position, Vector3.new(0, -12, 0), var2_upvw.raycastParams)
			if workspace_Raycast_result1_3 then
				clone_4.Position = workspace_Raycast_result1_3.Position
				var2_upvw.EmitAllDescendants(clone_4)
				clone_7.Position = workspace_Raycast_result1_3.Position
				var2_upvw.EmitAllDescendants(clone_7)
			end
			local clone_8 = Tectonic_Ascendance_upvr.CrushPart:Clone()
			clone_8.CFrame = HumanoidRootPart_2_upvr.CFrame + HumanoidRootPart_2_upvr.CFrame.LookVector * 8 + Vector3.new(0, 1, 0)
			clone_8.Parent = Folder_upvr
			var2_upvw.applyDebris(clone_8, 5)
			local tbl_2_upvr = {}
			local function onHit_upvr(arg1_4) -- Line 110, Named "onHit"
				--[[ Upvalues[3]:
					[1]: var2_upvw (copied, read and write)
					[2]: tbl_2_upvr (readonly)
					[3]: HumanoidRootPart_2_upvr (copied, readonly)
				]]
				for _, v in var2_upvw.findEnemiesPart(arg1_4, true), nil do
					if not table.find(tbl_2_upvr, v) then
						table.insert(tbl_2_upvr, v)
						var2_upvw.applyStatus(v, "Ragdoll", 2.6)
						if arg1_4.Name ~= "Hitbox" then
							local HumanoidRootPart_3 = v:FindFirstChild("HumanoidRootPart")
							v.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(HumanoidRootPart_3.Position.X, arg1_4.Position.Y + arg1_4.Size.Y / 1.9, HumanoidRootPart_3.Position.Z)) * HumanoidRootPart_3.CFrame - HumanoidRootPart_3.CFrame.p
						end
						var2_upvw.Knockback(v, HumanoidRootPart_2_upvr.Position + HumanoidRootPart_2_upvr.CFrame.LookVector * -50, 15, 50)
						var2_upvw.applyDamage(v, 15)
					end
				end
			end
			local clone = Tectonic_Ascendance_upvr.Hitbox:Clone()
			clone.Position = HumanoidRootPart_2_upvr.Position + HumanoidRootPart_2_upvr.CFrame.LookVector * 8 + Vector3.new(0, 1, 0)
			clone.Parent = Folder_upvr
			onHit_upvr(clone)
			var2_upvw.applyDebris(clone, 1)
			local tbl_9 = {}
			for i_2 = 1, 10 do
				for _, v_2 in clone_8:GetChildren() do
					if v_2.Name == tostring(i_2) then
						local workspace_Raycast_result1 = workspace:Raycast(v_2.Position + Vector3.new(math.random(-1, 1) * 0.1, 0, math.random(-1, 1) * 0.1), Vector3.new(0, -11, 0), var2_upvw.raycastParams)
						if workspace_Raycast_result1 then
							local Part_upvr_2 = Instance.new("Part", workspace.World)
							Part_upvr_2.Position = workspace_Raycast_result1.Position
							Part_upvr_2.Size = Vector3.new(0, 0, 0)
							Part_upvr_2.Anchored = true
							Part_upvr_2.Rotation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
							var2_upvw.applyDebris(Part_upvr_2, 6.15)
							table.insert(tbl_9, Part_upvr_2)
							local clone_2_upvr = Tectonic_Ascendance_upvr.rocksfx:Clone()
							clone_2_upvr.Parent = Part_upvr_2
							clone_2_upvr.PlaybackSpeed = math.random(-5, 5) * 0.1
							clone_2_upvr:Play()
							delay(0.5, function() -- Line 155
								--[[ Upvalues[2]:
									[1]: TweenService_upvr (copied, readonly)
									[2]: clone_2_upvr (readonly)
								]]
								TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(math.random(6, 10) * 0.1), {
									Volume = 0;
								}):Play()
							end)
							task.spawn(function() -- Line 159
								--[[ Upvalues[2]:
									[1]: Tectonic_Ascendance_upvr (copied, readonly)
									[2]: Part_upvr_2 (readonly)
								]]
								for _, v_3 in Tectonic_Ascendance_upvr.vfx:GetChildren() do
									v_3:Clone().Parent = Part_upvr_2
									task.wait()
								end
							end)
							local var114 = i_2 * 2
							TweenService_upvr:Create(Part_upvr_2, TweenInfo.new(0.16), {
								Size = Vector3.new(5 + var114, 5 + var114, 5 + var114);
							}):Play()
							Part_upvr_2.Color = workspace_Raycast_result1.Instance.Color
							Part_upvr_2.Material = workspace_Raycast_result1.Instance.Material
							Part_upvr_2.MaterialVariant = workspace_Raycast_result1.Instance.MaterialVariant
							if Part_upvr_2.Material.Name == "Plastic" then
								Part_upvr_2.Material = "SmoothPlastic"
							end
							TweenService_upvr:Create(Part_upvr_2, TweenInfo.new(0.5), {
								Rotation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360));
							}):Play()
							local var118_upvw = 0
							task.delay(0.15, function() -- Line 179
								--[[ Upvalues[4]:
									[1]: onHit_upvr (readonly)
									[2]: Part_upvr_2 (readonly)
									[3]: TweenService_upvr (copied, readonly)
									[4]: var118_upvw (read and write)
								]]
								onHit_upvr(Part_upvr_2)
								task.wait(0.4)
								Part_upvr_2.Material = Enum.Material.Neon
								Part_upvr_2:WaitForChild("Charge"):Play()
								local any_Create_result1 = TweenService_upvr:Create(Part_upvr_2, TweenInfo.new(1), {
									Color = Color3.new(1, 1, 1);
									Size = Part_upvr_2.Size * Vector3.new(1.5, 1.5, 1.5);
								})
								any_Create_result1:Play()
								any_Create_result1.Completed:Connect(function() -- Line 187
									--[[ Upvalues[2]:
										[1]: Part_upvr_2 (copied, readonly)
										[2]: var118_upvw (copied, read and write)
									]]
									for _, v_4 in Part_upvr_2:GetChildren() do
										if v_4:IsA("Texture") then
											v_4:Destroy()
										end
									end
									var118_upvw += 1
								end)
							end)
							if workspace_Raycast_result1.Instance:FindFirstChild("Texture") then
								for _, v_5 in workspace_Raycast_result1.Instance:GetChildren() do
									if v_5:IsA("Texture") then
										v_5:Clone().Parent = Part_upvr_2
									end
								end
							end
						end
					end
				end
				task.wait(0.05)
			end
			repeat
				task.wait()
			until 70 <= var118_upvw
			var2_upvw.camShake(arg1, "Explosion")
			var2_upvw.impactFrame2(arg1)
			var2_upvw.Blur(arg1, 20, 0.5)
			local tbl_12 = {}
			for _, v_6 in tbl_9 do
				clone_2_upvr = v_6.Size
				Part_upvr_2 = clone_2_upvr.Y
				Part_upvr_2 = true
				Part_upvr_2 = nil
				for _, v_7 in var2_upvw.findEnemiesMagnitude(v_6.Position, Part_upvr_2 * 2, Part_upvr_2), nil, Part_upvr_2 do
					if not table.find(tbl_12, v_7) then
						table.insert(tbl_12, v_7)
						var2_upvw.applyDamage(v_7, 15)
						var2_upvw.Knockback(v_7, v_6.Position, 80, 50)
						var2_upvw.applyStatus(v_7, "Ragdoll", 2.3)
						var2_upvw.camShake(v_7, "Explosion")
						var2_upvw.Blur(v_7, 20, 0.5)
					end
				end
			end
			for _, v_8_upvr in tbl_9 do
				v_8_upvr.Transparency = 1
				v_8_upvr.CanCollide = false
				var2_upvw.EmitAllDescendants(v_8_upvr)
				local sfx_2 = v_8_upvr.sfx
				Part_upvr_2 = math.random(-2, 2)
				sfx_2.PlaybackSpeed += Part_upvr_2 * 0.1
				v_8_upvr.sfx:Play()
				v_8_upvr.Spell:Play()
				local Spell = v_8_upvr.Spell
				Part_upvr_2 = math.random(-2, 2)
				Spell.PlaybackSpeed += Part_upvr_2 * 0.1
				v_8_upvr.explosion:Play()
				local explosion_2 = v_8_upvr.explosion
				Part_upvr_2 = math.random(-2, 2)
				explosion_2.PlaybackSpeed += Part_upvr_2 * 0.1
				task.delay(1.5, function() -- Line 246
					--[[ Upvalues[2]:
						[1]: TweenService_upvr (copied, readonly)
						[2]: v_8_upvr (readonly)
					]]
					TweenService_upvr:Create(v_8_upvr.sfx, TweenInfo.new((v_8_upvr.sfx.TimeLength - v_8_upvr.sfx.TimePosition) * v_8_upvr.sfx.PlaybackSpeed), {
						Volume = 0;
					}):Play()
					TweenService_upvr:Create(v_8_upvr.Spell, TweenInfo.new((v_8_upvr.Spell.TimeLength - v_8_upvr.Spell.TimePosition) * v_8_upvr.Spell.PlaybackSpeed), {
						Volume = 0;
					}):Play()
					TweenService_upvr:Create(v_8_upvr.explosion, TweenInfo.new((v_8_upvr.explosion.TimeLength - v_8_upvr.explosion.TimePosition) * v_8_upvr.explosion.PlaybackSpeed), {
						Volume = 0;
					}):Play()
				end)
			end
		end
	end)
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 256
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:Stop(0.9)
	end)
	task.wait()
	Earth_Hammer_upvr.TrailAtt.Trail.Enabled = true
end
return module_upvr
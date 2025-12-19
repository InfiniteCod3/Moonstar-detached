-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:55
-- Luau version 6, Types version 3
-- Time taken: 0.042415 seconds

local module_upvr = {
	Cooldown = 20;
	GlobalCD = 0.1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[5]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Still_River_upvr = ReplicatedStorage_upvr.Skills["Water Brawler"]["Still River"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Still_River_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	var2_upvw.applyStatus(arg1, "Slowed", 1.2)
	var2_upvw.applyStatus(arg1, "GlobalCD", 1.2)
	local clone = Still_River_upvr.Whoosh:Clone()
	clone.Parent = HumanoidRootPart_upvr
	clone:Play()
	var2_upvw.applyDebris(clone, 10)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("throw"):Connect(function() -- Line 39
		--[[ Upvalues[9]:
			[1]: Still_River_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: TweenService_upvr (copied, readonly)
			[7]: RunService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
			[9]: any_LoadAnimation_result1_upvr (readonly)
		]]
		-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
		local clone_upvr = Still_River_upvr.WaterballModel:Clone()
		local Waterball_upvr = clone_upvr.Waterball
		clone_upvr.Parent = Folder_upvr
		Waterball_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 5
		Waterball_upvr.WaterLoop:Play()
		Waterball_upvr.Throw:Play()
		Waterball_upvr.Splash:Play()
		Waterball_upvr.Impact:Play()
		var2_upvw.applyDebris(clone_upvr, 9)
		var2_upvw.applyStatus(arg1, "AutoRotate", 0.8)
		var2_upvw.applyStatus(arg1, "Freeze", 0.8)
		var2_upvw.applyStatus(arg1, "GlobalCD", 0.8)
		var2_upvw.camShake(arg1, "SmallBump")
		var2_upvw.changeFov(arg1, 60, 0.01, 1)
		var2_upvw.flashScreen(arg1, Color3.new(0.607843, 0.756863, 1), 0.5)
		var2_upvw.Blur(arg1, 10, 1)
		TweenService_upvr:Create(HumanoidRootPart_upvr, TweenInfo.new(0.4), {
			CFrame = CFrame.lookAt(HumanoidRootPart_upvr.Position, Waterball_upvr.Position);
		}):Play()
		local var59_upvw
		task.delay(0.5, function() -- Line 66
			--[[ Upvalues[3]:
				[1]: var59_upvw (read and write)
				[2]: TweenService_upvr (copied, readonly)
				[3]: Waterball_upvr (readonly)
			]]
			if var59_upvw then
			else
				TweenService_upvr:Create(Waterball_upvr, TweenInfo.new(0.5), {
					Transparency = 1;
				}):Play()
				for _, v_7 in Waterball_upvr:GetDescendants() do
					if v_7:IsA("ParticleEmitter") then
						v_7.Enabled = false
					elseif v_7:IsA("Trail") then
						v_7.Enabled = false
					end
				end
			end
		end)
		local tbl_2 = {}
		local tbl = {}
		local var70_upvw
		local var71_upvw = 2
		var70_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 82
			--[[ Upvalues[6]:
				[1]: clone_upvr (readonly)
				[2]: var70_upvw (read and write)
				[3]: var59_upvw (read and write)
				[4]: Waterball_upvr (readonly)
				[5]: var71_upvw (read and write)
				[6]: var2_upvw (copied, read and write)
			]]
			if not clone_upvr.Parent then
				var70_upvw:Disconnect()
			else
				if var59_upvw then
					var70_upvw:Disconnect()
					return
				end
				if workspace:Raycast(Waterball_upvr.Position, Waterball_upvr.CFrame.LookVector * var71_upvw, var2_upvw.raycastParams) then
					var70_upvw:Disconnect()
					return
				end
				Waterball_upvr.CFrame += Waterball_upvr.CFrame.LookVector * var71_upvw
				if 0.05 <= var71_upvw then
					var71_upvw -= 0.05
				end
			end
		end), module_upvr.Cooldown)
		local tbl_3 = {}
		for i_upvw = 1, 33.333333333333336 do
			task.wait()
			for _, v in var2_upvw.findEnemiesMagnitude(Waterball_upvr.Position, 5, true), nil do
				if not table.find(tbl_3, v) then
					if not var2_upvw.CheckBlock(v) then
						var59_upvw = v
						local var73_upvw = var59_upvw
						var2_upvw.unragdoll(v)
						for _, v_2 in v.Humanoid:GetPlayingAnimationTracks() do
							v_2:Stop()
						end
						var2_upvw.applyStatus(arg1, "IFrames", 0.5)
						task.wait(0.1)
						clone_upvr:ScaleTo(1)
						Waterball_upvr.Massless = true
						Waterball_upvr.Anchored = false
						Waterball_upvr.weld.Part0 = v.Torso
						Waterball_upvr.weld.Part1 = Waterball_upvr
						var2_upvw.applyDamage(v, 1)
						var2_upvw.camShake(arg1, "SmallBump")
						var2_upvw.changeFov(arg1, 150, 0.1, 1)
						var2_upvw.flashScreen(arg1, Color3.new(0.607843, 0.756863, 1), 1)
						var2_upvw.Blur(arg1, 15, 1)
						var2_upvw.camShake(var73_upvw, "SmallBump")
						var2_upvw.changeFov(var73_upvw, 150, 0.1, 1)
						var2_upvw.flashScreen(var73_upvw, Color3.new(0.607843, 0.756863, 1), 1)
						var2_upvw.Blur(var73_upvw, 15, 2)
						var2_upvw.applyDebris(clone_upvr, 5)
						table.insert(tbl_2, var2_upvw.applyStatus(v, "Stunned", 5))
						table.insert(tbl_2, var2_upvw.applyStatus(v, "AutoRotate", 5))
						local BodyPosition = Instance.new("BodyPosition", v.Head)
						BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						BodyPosition.Position = v.HumanoidRootPart.Position + CFrame.lookAt(HumanoidRootPart_upvr.CFrame.Position, v.HumanoidRootPart.Position).LookVector * 50 + Vector3.new(0, 25, 0)
						var2_upvw.applyDebris(BodyPosition, 4)
						table.insert(tbl, BodyPosition)
					else
						table.insert(tbl_3, v)
					end
				end
			end
			if var73_upvw then break end
		end
		if var73_upvw then
			Waterball_upvr.BallHit:Play()
			i_upvw = "IFrames"
			var2_upvw.applyStatus(arg1, i_upvw, 2)
			i_upvw = "Freeze"
			var2_upvw.applyStatus(arg1, i_upvw, 2)
			i_upvw = "GlobalCD"
			var2_upvw.applyStatus(arg1, i_upvw, 2)
			i_upvw = "AutoRotate"
			var2_upvw.applyStatus(arg1, i_upvw, 2)
			i_upvw = arg1.Head
			local BodyPosition_2_upvr = Instance.new("BodyPosition", i_upvw)
			BodyPosition_2_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			i_upvw = HumanoidRootPart_upvr
			BodyPosition_2_upvr.Position = i_upvw.Position
			i_upvw = var2_upvw
			i_upvw = BodyPosition_2_upvr
			i_upvw.applyDebris(i_upvw, 4)
			i_upvw = tbl
			table.insert(i_upvw, BodyPosition_2_upvr)
			local var79_upvw = 0
			i_upvw = 0
			var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("jab"):Connect(function() -- Line 169
				--[[ Upvalues[13]:
					[1]: i_upvw (read and write)
					[2]: TweenService_upvr (copied, readonly)
					[3]: HumanoidRootPart_upvr (copied, readonly)
					[4]: Waterball_upvr (readonly)
					[5]: var2_upvw (copied, read and write)
					[6]: arg1 (copied, readonly)
					[7]: var73_upvw (read and write)
					[8]: Still_River_upvr (copied, readonly)
					[9]: Folder_upvr (copied, readonly)
					[10]: RunService_upvr (copied, readonly)
					[11]: var79_upvw (read and write)
					[12]: module_upvr (copied, readonly)
					[13]: BodyPosition_2_upvr (readonly)
				]]
				i_upvw += 1
				TweenService_upvr:Create(HumanoidRootPart_upvr, TweenInfo.new(0.01), {
					CFrame = CFrame.lookAt(HumanoidRootPart_upvr.Position, Waterball_upvr.Position);
				}):Play()
				var2_upvw.camShake(arg1, "SmallBump")
				var2_upvw.changeFov(arg1, 60, 0.01, 0.25)
				var2_upvw.camShake(var73_upvw, "SmallBump")
				var2_upvw.changeFov(var73_upvw, 60, 0.01, 0.25)
				local clone_2_upvr = Still_River_upvr.WaterBullet:Clone()
				clone_2_upvr.Parent = Folder_upvr
				clone_2_upvr.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 3) * CFrame.Angles(0, math.rad(math.random(-30, 30)), math.rad(math.random(-30, 0)))
				var2_upvw.applyDebris(clone_2_upvr, 12)
				for _, v_3 in clone_2_upvr:GetChildren() do
					if v_3.Name == "JabSFX" then
						v_3.PlaybackSpeed += math.random(-1, 1) * 0.1
						v_3:Play()
					end
				end
				clone_2_upvr.Flying:Play()
				local Flying = clone_2_upvr.Flying
				Flying.PlaybackSpeed += math.random(-2, 2) * 0.05
				local var89_upvw = "Slow"
				task.delay(0.4, function() -- Line 195
					--[[ Upvalues[1]:
						[1]: var89_upvw (read and write)
					]]
					var89_upvw = "Fast"
				end)
				local var92_upvw
				var92_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 201
					--[[ Upvalues[8]:
						[1]: clone_2_upvr (readonly)
						[2]: var73_upvw (readonly)
						[3]: var92_upvw (read and write)
						[4]: var89_upvw (read and write)
						[5]: TweenService_upvr (copied, readonly)
						[6]: var2_upvw (copied, read and write)
						[7]: arg1 (copied, readonly)
						[8]: var79_upvw (copied, read and write)
					]]
					if not clone_2_upvr.Parent or not var73_upvw.Parent then
						var92_upvw:Disconnect()
					else
						if not var73_upvw.Parent then
							clone_2_upvr:Destroy()
							var92_upvw:Disconnect()
							return
						end
						if var89_upvw == "Slow" then
							TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(2), {
								CFrame = CFrame.lookAt(clone_2_upvr.Position, var73_upvw.HumanoidRootPart.Position);
							}):Play()
						elseif var89_upvw == "Fast" then
							TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.2), {
								CFrame = CFrame.lookAt(clone_2_upvr.Position, var73_upvw.HumanoidRootPart.Position);
							}):Play()
						elseif var89_upvw == "Really Fast" then
							TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.05), {
								CFrame = CFrame.lookAt(clone_2_upvr.Position, var73_upvw.HumanoidRootPart.Position);
							}):Play()
						end
						local Magnitude = (clone_2_upvr.Position - var73_upvw.HumanoidRootPart.Position).Magnitude
						if Magnitude <= 16 then
							var89_upvw = "Really Fast"
						end
						TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
							Position = clone_2_upvr.Position + clone_2_upvr.CFrame.LookVector * 2;
						}):Play()
						clone_2_upvr.BulletModel.CFrame = clone_2_upvr.CFrame * CFrame.Angles(0, (-math.pi/2), (math.pi/2))
						if Magnitude <= 4 then
							var92_upvw:Disconnect()
							clone_2_upvr.Transparency = 1
							clone_2_upvr.BulletModel.Transparency = 1
							clone_2_upvr.Flying:Stop()
							for _, v_8 in clone_2_upvr:GetDescendants() do
								if v_8:IsA("ParticleEmitter") or v_8:IsA("Trail") then
									v_8.Enabled = false
								end
							end
							var2_upvw.camShake(arg1, "SmallBump")
							var2_upvw.changeFov(arg1, 60, 0.01, 0.25)
							var2_upvw.flashScreen(arg1, Color3.new(0.607843, 0.756863, 1), 0.4)
							var2_upvw.camShake(var73_upvw, "SmallBump")
							var2_upvw.changeFov(var73_upvw, 60, 0.01, 0.25)
							var2_upvw.flashScreen(var73_upvw, Color3.new(0.607843, 0.756863, 1), 0.4)
							var79_upvw += 1
							var2_upvw.EmitAllDescendants(clone_2_upvr.hitVFX)
							for _, v_9 in clone_2_upvr.hitVFX:GetChildren() do
								if v_9:IsA("Sound") then
									v_9.PlaybackSpeed += math.random(-1, 1) * 0.1
									v_9:Play()
								end
							end
							var2_upvw.applyDamage(var73_upvw, 2)
							var2_upvw.applyStatus(var73_upvw, "Stunned", 0.32)
						end
					end
				end), module_upvr.Cooldown)
				if i_upvw == 6 then
					var2_upvw.applyDebris(BodyPosition_2_upvr, 0.5)
				end
			end), module_upvr.Cooldown)
			repeat
				task.wait()
			until not clone_upvr.Parent and var79_upvw == 6
			var2_upvw.applyDebris(clone_upvr, 0)
			for _, v_4 in tbl do
				v = var2_upvw.applyDebris
				v(v_4, 0.1)
			end
			for _, v_5 in tbl_2 do
				v = var2_upvw.applyDebris
				v(v_5, 0.25, var73_upvw)
				local var108
			end
			var2_upvw.applyDamage(var108, 2)
			var2_upvw.camShake(arg1, "Bump")
			var2_upvw.changeFov(arg1, 50, 0.01, 0.5)
			var2_upvw.flashScreen(arg1, Color3.new(0.607843, 0.756863, 1), 1)
			var2_upvw.camShake(var108, "Bump")
			var2_upvw.changeFov(var108, 50, 0.01, 0.5)
			var2_upvw.flashScreen(var108, Color3.new(0.607843, 0.756863, 1), 1)
			var2_upvw.applyStatus(var108, "Ragdoll", 1.1)
			local clone_3 = Still_River_upvr.ExplodeVFX.ExplosionATT:Clone()
			clone_3.Parent = var108.Torso
			var2_upvw.EmitAllDescendants(clone_3)
			var2_upvw.applyDebris(clone_3, 5)
			for _, v_6 in clone_3:GetChildren() do
				if v_6:IsA("Sound") then
					v_6:Play()
				end
			end
		else
			BodyPosition_2_upvr = TweenService_upvr
			local _ = {
				Volume = 0;
			}
			BodyPosition_2_upvr = BodyPosition_2_upvr:Create(Waterball_upvr.WaterLoop, TweenInfo.new(1), _):Play
			BodyPosition_2_upvr()
			BodyPosition_2_upvr = any_LoadAnimation_result1_upvr:Stop
			BodyPosition_2_upvr(0.4)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
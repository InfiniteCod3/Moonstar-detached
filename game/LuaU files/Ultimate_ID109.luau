-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:15
-- Luau version 6, Types version 3
-- Time taken: 0.025344 seconds

local module = {
	GlobalCD = 2.4;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
		[4]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 16)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills.Dagger.Ultimate
	var2_upvw.applyStatus(arg1, "IFrames", 2.4)
	var2_upvw.applyStatus(arg1, "Freeze", 2.4)
	var2_upvw.applyStatus(arg1, "AutoRotate", 2.4)
	local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Ultimate_upvr.AnimationStart)
	any_LoadAnimation_result1_upvr:Play()
	local clone_upvr = Ultimate_upvr.Part.startingsounds:Clone()
	clone_upvr.Parent = arg1.Torso
	game.Debris:AddItem(clone_upvr, 8)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function() -- Line 38
		--[[ Upvalues[5]:
			[1]: var2_upvw (copied, read and write)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: clone_upvr (readonly)
			[4]: arg1 (readonly)
			[5]: TweenService_upvr (copied, readonly)
		]]
		local any_findEnemiesMagnitude_result1_2 = var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 6.5, 7)
		local clone_3 = clone_upvr.swing:Clone()
		clone_3.PlaybackSpeed += math.random(-1, 1) * 0.1
		game.Debris:AddItem(clone_3, 3)
		clone_3.Parent = arg1.Torso
		clone_3:Play()
		if 0 < #any_findEnemiesMagnitude_result1_2 then
			var2_upvw.changeFov(arg1, 65, 0.01, 0.1)
			var2_upvw.flashScreen(arg1, Color3.new(0.533333, 0.054902, 0.054902), 0.5)
			local clone_4 = clone_upvr.Knife:Clone()
			local clone_8 = clone_upvr.Slice:Clone()
			clone_4.PlaybackSpeed += math.random(-1, 1) * 0.1
			clone_8.PlaybackSpeed += math.random(-1, 1) * 0.1
			game.Debris:AddItem(clone_4, 4)
			game.Debris:AddItem(clone_8, 4)
			clone_4.Parent = arg1.Torso
			clone_8.Parent = arg1.Torso
			clone_4:Play()
			clone_8:Play()
		end
		local workspace_Raycast_result1_2 = workspace:Raycast(HumanoidRootPart_upvr.Position, HumanoidRootPart_upvr.CFrame.LookVector * 9.5, var2_upvw.raycastParams)
		if not workspace_Raycast_result1_2 then
			TweenService_upvr:Create(HumanoidRootPart_upvr, TweenInfo.new(0.15), {
				CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 5;
			}):Play()
		end
		for _, v in any_findEnemiesMagnitude_result1_2 do
			var2_upvw.changeFov(v, 65, 0.01, 0.1)
			var2_upvw.flashScreen(v, Color3.new(0.533333, 0.054902, 0.054902), 0.5)
			var2_upvw.applyStatus(v, "Stunned", 0.6)
			var2_upvw.applyStatus(v, "AutoRotate", 0.6)
			var2_upvw.blood(v, 3)
			var2_upvw.applyDamage(v, 5, false, true)
			if workspace_Raycast_result1_2 then break end
			TweenService_upvr:Create(v.HumanoidRootPart, TweenInfo.new(0.15), {
				CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 9.5) * CFrame.Angles(0, math.pi, 0);
			}):Play()
			return
		end
	end), 30)
	local Dagger_upvr = arg1:FindFirstChild("Dagger")
	local function cutscene_upvr(arg1_2) -- Line 82, Named "cutscene"
		--[[ Upvalues[9]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: Humanoid_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: RunService_upvr (copied, readonly)
			[7]: Ultimate_upvr (readonly)
			[8]: Dagger_upvr (readonly)
			[9]: TweenService_upvr (copied, readonly)
		]]
		any_LoadAnimation_result1_upvr:Stop(1e-09)
		var2_upvw.SetRootPriority(arg1, 100, 5)
		arg1_2.Humanoid.DisplayDistanceType = "None"
		arg1_2.Humanoid.HealthDisplayType = "AlwaysOff"
		Humanoid_upvr.DisplayDistanceType = "None"
		Humanoid_upvr.HealthDisplayType = "AlwaysOff"
		var2_upvw.applyStatus(arg1, "Stunned", 5.5)
		var2_upvw.applyStatus(arg1, "AutoRotate", 5.5)
		var2_upvw.applyStatus(arg1, "IFrames", 5.5)
		var2_upvw.applyStatus(arg1, "Ultimate", 5.5)
		var2_upvw.applyStatus(arg1_2, "Stunned", 5.5)
		var2_upvw.applyStatus(arg1_2, "AutoRotate", 5.5)
		var2_upvw.applyStatus(arg1_2, "IFrames", 5.5)
		var2_upvw.applyStatus(arg1_2, "Ultimate", 5.5)
		local BodyVelocity_upvr = Instance.new("BodyVelocity", HumanoidRootPart_upvr)
		BodyVelocity_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		BodyVelocity_upvr.Velocity = Vector3.new(0, 0, 0)
		game.Debris:AddItem(BodyVelocity_upvr, 6)
		HumanoidRootPart_upvr.Anchored = true
		local var25_upvw
		var25_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 111
			--[[ Upvalues[5]:
				[1]: BodyVelocity_upvr (readonly)
				[2]: var25_upvw (read and write)
				[3]: HumanoidRootPart_upvr (copied, readonly)
				[4]: arg1 (copied, readonly)
				[5]: var2_upvw (copied, read and write)
			]]
			if not BodyVelocity_upvr.Parent then
				var25_upvw:Disconnect()
				HumanoidRootPart_upvr.Anchored = false
			else
				local workspace_Raycast_result1 = workspace:Raycast(arg1.Torso.Position + Vector3.new(0, 25, 0), Vector3.new(0, -50, 0), var2_upvw.raycastParams)
				if workspace_Raycast_result1 then
					HumanoidRootPart_upvr.CFrame = CFrame.new(Vector3.new(HumanoidRootPart_upvr.Position.X, workspace_Raycast_result1.Position.Y + 3, HumanoidRootPart_upvr.Position.Z)) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
				end
			end
		end), 20)
		local any_LoadAnimation_result1_upvr_2 = Humanoid_upvr.Animator:LoadAnimation(Ultimate_upvr.Animation)
		any_LoadAnimation_result1_upvr_2:Play()
		local any_LoadAnimation_result1_upvr_3 = arg1_2.Humanoid.Animator:LoadAnimation(Ultimate_upvr.TargetAnimation)
		any_LoadAnimation_result1_upvr_3:Play()
		var2_upvw.cameraCutscene(arg1_2, "Dagger")
		local clone_upvr_2 = Ultimate_upvr.Part.sounds:Clone()
		clone_upvr_2.Parent = HumanoidRootPart_upvr
		game.Debris:AddItem(clone_upvr_2, 10)
		local clone_7_upvr = Ultimate_upvr.AnimationDagger:Clone()
		clone_7_upvr.Parent = arg1
		clone_7_upvr.weld.Part0 = HumanoidRootPart_upvr
		clone_7_upvr.weld.Part1 = clone_7_upvr
		var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("invisdagger"):Connect(function(arg1_3) -- Line 143
			--[[ Upvalues[1]:
				[1]: Dagger_upvr (copied, readonly)
			]]
			Dagger_upvr.Transparency = arg1_3
			for _, v_2 in Dagger_upvr.DaggerParts:GetChildren() do
				if v_2:IsA("BasePart") then
					v_2.Transparency = arg1_3
				end
			end
		end), 30)
		local any_applyWeld_result1_upvr = var2_upvw.applyWeld(arg1_2, Vector3.new(0, 0, 5), Vector3.new(0, 180, 0), 6)
		var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("enemyend"):Connect(function() -- Line 152
			--[[ Upvalues[4]:
				[1]: any_LoadAnimation_result1_upvr_3 (readonly)
				[2]: var2_upvw (copied, read and write)
				[3]: any_applyWeld_result1_upvr (readonly)
				[4]: arg1_2 (readonly)
			]]
			any_LoadAnimation_result1_upvr_3:AdjustSpeed(0)
			var2_upvw.applyDebris(any_applyWeld_result1_upvr, 0)
			var2_upvw.applyDamage(arg1_2, 500, true, false)
		end), 30)
		var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("end"):Connect(function() -- Line 159
			--[[ Upvalues[6]:
				[1]: BodyVelocity_upvr (readonly)
				[2]: arg1 (copied, readonly)
				[3]: any_LoadAnimation_result1_upvr_2 (readonly)
				[4]: HumanoidRootPart_upvr (copied, readonly)
				[5]: Humanoid_upvr (copied, readonly)
				[6]: arg1_2 (readonly)
			]]
			BodyVelocity_upvr:Destroy()
			any_LoadAnimation_result1_upvr_2:Stop(0.000001)
			HumanoidRootPart_upvr.CFrame = arg1.Torso.CFrame
			Humanoid_upvr.DisplayDistanceType = "Viewer"
			Humanoid_upvr.HealthDisplayType = "DisplayWhenDamaged"
			arg1_2.Humanoid.DisplayDistanceType = "Viewer"
			arg1_2.Humanoid.HealthDisplayType = "DisplayWhenDamaged"
		end), 30)
		var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("daggerstab"):Connect(function() -- Line 171
			--[[ Upvalues[5]:
				[1]: clone_upvr_2 (readonly)
				[2]: HumanoidRootPart_upvr (copied, readonly)
				[3]: var2_upvw (copied, read and write)
				[4]: arg1_2 (readonly)
				[5]: arg1 (copied, readonly)
			]]
			local clone_5 = clone_upvr_2.hit:Clone()
			clone_5.Parent = HumanoidRootPart_upvr
			clone_5.PlaybackSpeed += math.random(-1, 1) * 0.05
			clone_5:Play()
			game.Debris:AddItem(clone_5, 5)
			var2_upvw.blood(arg1_2, 3)
			var2_upvw.flashScreen(arg1, Color3.new(0.603922, 0.054902, 0.054902), 0.2)
			var2_upvw.flashScreen(arg1_2, Color3.new(0.603922, 0.054902, 0.054902), 0.2)
			var2_upvw.changeFov(arg1, 55, 0.01, 0.1)
			var2_upvw.changeFov(arg1_2, 55, 0.01, 0.1)
		end), 30)
		var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("sfx"):Connect(function(arg1_4) -- Line 185
			--[[ Upvalues[7]:
				[1]: clone_upvr_2 (readonly)
				[2]: arg1 (copied, readonly)
				[3]: var2_upvw (copied, read and write)
				[4]: arg1_2 (readonly)
				[5]: clone_7_upvr (readonly)
				[6]: TweenService_upvr (copied, readonly)
				[7]: Ultimate_upvr (copied, readonly)
			]]
			if clone_upvr_2:FindFirstChild(arg1_4) then
				local clone = clone_upvr_2[arg1_4]:Clone()
				clone.Parent = arg1.Torso
				clone:Play()
				game.Debris:AddItem(clone, 5)
			end
			if arg1_4 == "Throw" then
				var2_upvw.changeFov(arg1, 100, 0.08, 0.5)
				var2_upvw.changeFov(arg1_2, 100, 0.08, 0.5)
			end
			if arg1_4 == "DaggerThrow" then
				clone_7_upvr.Transparency = 0
				for _, v_3 in clone_7_upvr.DaggerParts:GetChildren() do
					if v_3:IsA("BasePart") then
						v_3.Transparency = 0
					end
				end
			end
			if arg1_4 == "Slide" then
				TweenService_upvr:Create(clone_upvr_2.Slide, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Volume = 0;
				}):Play()
			end
			if arg1_4 == "FinalStab" then
				clone_7_upvr:Destroy()
				local clone_2 = Ultimate_upvr.FaceDagger:Clone()
				clone_2.Parent = arg1_2
				clone_2.weld.Part0 = arg1_2.Head
				clone_2.weld.Part1 = clone_2
				var2_upvw.changeFov(arg1, 60, 0.01, 0.6)
				var2_upvw.changeFov(arg1_2, 45, 0.01, 0.6)
			end
			if arg1_4 == "Slam" then
				var2_upvw.CreateDebris(arg1_2.Torso.Position, 6, 0.4, 0.45, 0.1)
				var2_upvw.crater(1, arg1_2.Torso.Position, 2, 0.45)
				var2_upvw.changeFov(arg1, 50, 0.01, 0.8)
				var2_upvw.changeFov(arg1_2, 50, 0.01, 0.8)
			end
			if arg1_4 == "kick" then
				var2_upvw.changeFov(arg1, 100, 0.01, 0.6)
				var2_upvw.changeFov(arg1_2, 100, 0.01, 6)
			end
			if arg1_4 == "teleport" then
				var2_upvw.changeFov(arg1, 100, 0.01, 1.5)
				var2_upvw.changeFov(arg1_2, 100, 0.01, 1.5)
			end
		end), 30)
	end
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slashend"):Connect(function() -- Line 244
		--[[ Upvalues[5]:
			[1]: var2_upvw (copied, read and write)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: clone_upvr (readonly)
			[4]: arg1 (readonly)
			[5]: cutscene_upvr (readonly)
		]]
		local any_findEnemiesMagnitude_result1 = var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 6.5, 7.5)
		local clone_10 = clone_upvr.swing:Clone()
		clone_10.PlaybackSpeed += math.random(-1, 1) * 0.1
		game.Debris:AddItem(clone_10, 3)
		clone_10.Parent = arg1.Torso
		clone_10:Play()
		if 0 < #any_findEnemiesMagnitude_result1 then
			local clone_9 = clone_upvr.Knife:Clone()
			local clone_6 = clone_upvr.Slice:Clone()
			clone_9.PlaybackSpeed += math.random(-1, 1) * 0.1
			clone_6.PlaybackSpeed += math.random(-1, 1) * 0.1
			game.Debris:AddItem(clone_9, 4)
			game.Debris:AddItem(clone_6, 4)
			clone_9.Parent = arg1.Torso
			clone_6.Parent = arg1.Torso
			clone_9:Play()
			clone_6:Play()
		end
		for _, v_4 in any_findEnemiesMagnitude_result1 do
			var2_upvw.applyStatus(v_4, "Stunned", 0.6)
			var2_upvw.applyStatus(v_4, "AutoRotate", 0.6)
			var2_upvw.changeFov(arg1, 65, 0.01, 0.1)
			var2_upvw.flashScreen(arg1, Color3.new(0, 0, 0), 0.2)
			var2_upvw.Blur(arg1, 30, 0.25)
			var2_upvw.changeFov(v_4, 65, 0.01, 0.1)
			var2_upvw.flashScreen(v_4, Color3.new(0, 0, 0), 0.2)
			var2_upvw.Blur(v_4, 30, 0.25)
			var2_upvw.blood(v_4, 3)
			var2_upvw.applyDamage(v_4, 5, false, true)
			cutscene_upvr(v_4)
			return
		end
	end), 30)
end
return module
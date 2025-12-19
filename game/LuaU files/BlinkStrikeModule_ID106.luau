-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:12
-- Luau version 6, Types version 3
-- Time taken: 0.031313 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 30
module_upvr.GlobalCD = 0.1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Blink_Strike_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"]["Blink Strike"]
	local any_LoadAnimation_result1_upvr = Humanoid.Animator:LoadAnimation(Blink_Strike_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	local CyberKatana_upvr = arg1:FindFirstChild("CyberKatana")
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 33
		--[[ Upvalues[1]:
			[1]: CyberKatana_upvr (readonly)
		]]
		CyberKatana_upvr.TrailAtt.Trail.Enabled = false
	end), module_upvr.Cooldown)
	local var20_upvw = 0
	local tbl_upvr = {}
	var3_upvw.applyStatus(arg1, "GlobalCD", 1.95)
	var3_upvw.applyStatus(arg1, "Freeze", 1.95)
	var3_upvw.applyStatus(arg1, "AutoRotate", 1.95)
	var3_upvw.applyStatus(arg1, "HyperArmor", 1.95)
	var3_upvw.changeFov(arg1, 40, 1.05, 1)
	task.wait()
	local clone_5 = Blink_Strike_upvr.Charge:Clone()
	clone_5.Parent = HumanoidRootPart_upvr
	clone_5:Play()
	var3_upvw.applyDebris(clone_5, 5)
	local clone_7_upvr = Blink_Strike_upvr["Blink Strike"]:Clone()
	clone_7_upvr.Parent = Folder_upvr
	clone_7_upvr.CFrame = HumanoidRootPart_upvr.CFrame
	clone_7_upvr.Weld.Part0 = HumanoidRootPart_upvr
	clone_7_upvr.Weld.Part1 = clone_7_upvr
	var3_upvw.applyDebris(clone_7_upvr, 6)
	TweenService_upvr:Create(clone_7_upvr.Indicator.SurfaceGui.Frame, TweenInfo.new(1), {
		Size = UDim2.new(1, 0, 1, 0);
	}):Play()
	task.wait(1)
	local var57_upvw
	if not clone_7_upvr.Parent then
	else
		clone_7_upvr.Weld.Part0 = nil
		clone_7_upvr.Anchored = true
		var3_upvw.applyDebris(clone_7_upvr.Indicator, 0)
		var3_upvw.EmitAllDescendants(clone_7_upvr.VFX1)
		task.wait()
		clone_5:Stop()
		local clone_2 = Blink_Strike_upvr.Slash:Clone()
		clone_2.Parent = HumanoidRootPart_upvr
		clone_2:Play()
		var57_upvw = 5
		var3_upvw.applyDebris(clone_2, var57_upvw)
		var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 147
			--[[ Upvalues[3]:
				[1]: any_LoadAnimation_result1_upvr (readonly)
				[2]: var3_upvw (copied, read and write)
				[3]: clone_7_upvr (readonly)
			]]
			if any_LoadAnimation_result1_upvr.Length <= any_LoadAnimation_result1_upvr.TimePosition then
			else
				var3_upvw.applyDebris(clone_7_upvr, 0)
			end
		end), module_upvr.Cooldown):Disconnect()
		var57_upvw = 0
		any_LoadAnimation_result1_upvr:Stop(var57_upvw)
		var57_upvw = Blink_Strike_upvr.Animation2
		Humanoid.Animator:LoadAnimation(var57_upvw):Play(0)
		var57_upvw = var3_upvw
		var57_upvw = arg1
		var57_upvw.changeFov(var57_upvw, 1000, 0.3, 0.5)
		var57_upvw = var3_upvw
		var57_upvw = arg1
		var57_upvw.impactFrame2(var57_upvw, 0.15)
		var57_upvw = var3_upvw
		var57_upvw = arg1
		var57_upvw.flashScreen(var57_upvw, Color3.fromRGB(96, 45, 107), 1)
		var57_upvw = 0.3
		task.delay(var57_upvw, function() -- Line 178
			--[[ Upvalues[5]:
				[1]: var3_upvw (copied, read and write)
				[2]: arg1 (readonly)
				[3]: clone_7_upvr (readonly)
				[4]: Blink_Strike_upvr (readonly)
				[5]: HumanoidRootPart_upvr (readonly)
			]]
			var3_upvw.camShake(arg1, "BigBump")
			var3_upvw.changeFov(arg1, 40, 0.05, 1.5)
			var3_upvw.EmitAllDescendants(clone_7_upvr.VFX2)
			var3_upvw.impactFrame(arg1, 0.075)
			var3_upvw.flashScreen(arg1, Color3.fromRGB(115, 54, 129), 0.9)
			local clone_3 = Blink_Strike_upvr.Slash2:Clone()
			clone_3.Parent = HumanoidRootPart_upvr
			clone_3:Play()
			var3_upvw.applyDebris(clone_3, 5)
		end)
		var57_upvw = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 75
		local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position, HumanoidRootPart_upvr.CFrame.LookVector * 75, var3_upvw.raycastParams)
		if workspace_Raycast_result1 then
			var57_upvw = CFrame.new(workspace_Raycast_result1.Position) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
		end
		local any_findEnemiesPart_result1 = var3_upvw.findEnemiesPart(clone_7_upvr.Hitbox)
		if #any_findEnemiesPart_result1 <= 0 then
			var3_upvw.applyStatus(arg1, "Stunned", 1.2)
			var3_upvw.applyStatus(arg1, "AutoRotate", 1.2)
		end
		for _, v_6_upvr in any_findEnemiesPart_result1 do
			if not var3_upvw.CheckBlock(v_6_upvr, true) then
				local HumanoidRootPart_upvr_2 = v_6_upvr:FindFirstChild("HumanoidRootPart")
				task.delay(0.4, function() -- Line 210
					--[[ Upvalues[5]:
						[1]: v_6_upvr (readonly)
						[2]: HumanoidRootPart_upvr_2 (readonly)
						[3]: var57_upvw (read and write)
						[4]: var3_upvw (copied, read and write)
						[5]: HumanoidRootPart_upvr (readonly)
					]]
					for _, v_7 in v_6_upvr.Humanoid:GetPlayingAnimationTracks() do
						v_7:Stop()
					end
					HumanoidRootPart_upvr_2.CFrame = var57_upvw + var57_upvw.LookVector * -8
					var3_upvw.Knockback(v_6_upvr, HumanoidRootPart_upvr.Position, 0, 25)
					var3_upvw.applyDamage(v_6_upvr, 5, true)
				end)
				for _, v_8 in v_6_upvr.Humanoid:GetPlayingAnimationTracks() do
					v_8:AdjustSpeed(0)
				end
				var3_upvw.applyStatus(v_6_upvr, "AutoRotate", 1.7)
				var3_upvw.applyStatus(v_6_upvr, "Stunned", 1.7)
				var3_upvw.applyStatus(v_6_upvr, "IFrames", 0.3)
				var3_upvw.applyDamage(v_6_upvr, 5, true, true)
			end
		end
		;(function(arg1_2) -- Line 39, Named "teleport"
			--[[ Upvalues[8]:
				[1]: var20_upvw (read and write)
				[2]: arg1 (readonly)
				[3]: var3_upvw (copied, read and write)
				[4]: tbl_upvr (readonly)
				[5]: Folder_upvr (readonly)
				[6]: TweenService_upvr (copied, readonly)
				[7]: ReplicatedStorage_upvr (copied, readonly)
				[8]: HumanoidRootPart_upvr (readonly)
			]]
			var20_upvw += 1
			if not arg1.Head:FindFirstChild("LockBV") then
				local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
				BodyVelocity.Name = "LockBV"
				BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				BodyVelocity.Velocity = Vector3.new(0, 0, 0)
				table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames"))
			end
			task.delay(0.3, function() -- Line 53
				--[[ Upvalues[4]:
					[1]: var20_upvw (copied, read and write)
					[2]: tbl_upvr (copied, readonly)
					[3]: var3_upvw (copied, read and write)
					[4]: arg1 (copied, readonly)
				]]
				var20_upvw -= 1
				if var20_upvw <= 0 then
					for _, v in tbl_upvr do
						var3_upvw.applyDebris(v, 0)
					end
					for _, v_2 in arg1.Head:GetChildren() do
						if v_2.Name == "LockBV" then
							v_2:Destroy()
						end
					end
				end
			end)
			for _, v_3 in arg1:GetChildren() do
				if table.find({"Left Arm", "Right Arm", "Head", "Left Leg", "Right Leg", "Torso"}, v_3.Name) and v_3:IsA("BasePart") then
					local clone_6 = v_3:Clone()
					for _, v_4 in clone_6:GetChildren() do
						if not v_4:IsA("SpecialMesh") or not v_4:IsA("CharacterMesh") or not v_4:IsA("BlockMesh") then
							v_4:Destroy()
						end
					end
					clone_6.Transparency = 0.5
					clone_6.Parent = Folder_upvr
					clone_6.Material = Enum.Material.Neon
					clone_6.Anchored = true
					clone_6.CanCollide = false
					TweenService_upvr:Create(clone_6, TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Transparency = 1;
						Size = Vector3.new(0, 0, 0);
					}):Play()
					game.Debris:AddItem(clone_6, 3)
					clone_6.Color = Color3.new(1, 1, 1)
					TweenService_upvr:Create(clone_6, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
						Color = Color3.fromRGB(98, 37, 209);
					}):Play()
					if clone_6.Name == "Torso" then
						local clone = ReplicatedStorage_upvr.Skills["Cyber Katana"].TeleportSFX:Clone()
						clone.Parent = clone_6
						clone.PlaybackSpeed += math.random(-3, 3) * 0.075
						clone:Play()
						local clone_4 = ReplicatedStorage_upvr.Skills["Cyber Katana"].TeleportSFX2:Clone()
						clone_4.Parent = clone_6
						clone_4.PlaybackSpeed += math.random(-3, 3) * 0.075
						clone_4:Play()
					end
				end
			end
			if arg1_2 then
				HumanoidRootPart_upvr.CFrame = arg1_2
			end
			for _, v_5_upvr in arg1:GetDescendants() do
				if v_5_upvr:IsA("BasePart") and v_5_upvr.Transparency == 0 then
					v_5_upvr.Transparency = 1
					task.delay(0.05, function() -- Line 114
						--[[ Upvalues[1]:
							[1]: v_5_upvr (readonly)
						]]
						v_5_upvr.Transparency = 0
					end)
				end
			end
		end)(var57_upvw)
	end
end
return module_upvr
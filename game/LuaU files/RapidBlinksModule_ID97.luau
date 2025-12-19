-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:03
-- Luau version 6, Types version 3
-- Time taken: 0.024961 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 20
module_upvr.GlobalCD = 0.1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 15
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Rapid_Blinks_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"].Ultimate["Rapid Blinks"]
	local function _(arg1_2, arg2_2, arg3) -- Line 29, Named "Siphon"
		--[[ Upvalues[7]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: TweenService_upvr (copied, readonly)
			[5]: Humanoid_upvr (readonly)
			[6]: var3_upvw (copied, read and write)
			[7]: arg1 (readonly)
		]]
		task.spawn(function() -- Line 30
			--[[ Upvalues[10]:
				[1]: arg2_2 (readonly)
				[2]: ReplicatedStorage_upvr (copied, readonly)
				[3]: Folder_upvr (copied, readonly)
				[4]: arg1_2 (readonly)
				[5]: HumanoidRootPart_upvr (copied, readonly)
				[6]: TweenService_upvr (copied, readonly)
				[7]: Humanoid_upvr (copied, readonly)
				[8]: arg3 (readonly)
				[9]: var3_upvw (copied, read and write)
				[10]: arg1 (copied, readonly)
			]]
			for _ = 1, arg2_2 do
				local clone_7_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"].Ultimate.SiphonBall:Clone()
				clone_7_upvr.Parent = Folder_upvr
				clone_7_upvr.CFrame = arg1_2
				clone_7_upvr.CFrame = CFrame.lookAt(clone_7_upvr.Position, HumanoidRootPart_upvr.Position)
				game.Debris:AddItem(clone_7_upvr, 10)
				TweenService_upvr:Create(clone_7_upvr, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Position = clone_7_upvr.Position:Lerp(HumanoidRootPart_upvr.Position, 0.5) + (clone_7_upvr.CFrame.RightVector) * (math.random(-4, 4) * 1.5) + (clone_7_upvr.CFrame.UpVector) * (math.random(-4, 4) * 1.5);
				}):Play()
				local Appear = clone_7_upvr.Appear
				Appear.PlaybackSpeed += math.random(-3, 3) * 0.06
				clone_7_upvr.Appear:Play()
				task.delay(0.3, function() -- Line 44
					--[[ Upvalues[7]:
						[1]: TweenService_upvr (copied, readonly)
						[2]: clone_7_upvr (readonly)
						[3]: HumanoidRootPart_upvr (copied, readonly)
						[4]: Humanoid_upvr (copied, readonly)
						[5]: arg3 (copied, readonly)
						[6]: var3_upvw (copied, read and write)
						[7]: arg1 (copied, readonly)
					]]
					TweenService_upvr:Create(clone_7_upvr, TweenInfo.new((clone_7_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.03, Enum.EasingStyle.Linear), {
						Position = HumanoidRootPart_upvr.Position;
					}):Play()
					task.wait(0.1)
					while task.wait() and clone_7_upvr.Parent and clone_7_upvr.Transparency ~= 1 do
						TweenService_upvr:Create(clone_7_upvr, TweenInfo.new((clone_7_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.01, Enum.EasingStyle.Linear), {
							Position = HumanoidRootPart_upvr.Position;
						}):Play()
						if (clone_7_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude <= 2 then
							TweenService_upvr:Create(clone_7_upvr, TweenInfo.new(0, Enum.EasingStyle.Linear), {
								Position = HumanoidRootPart_upvr.Position;
							}):Play()
							task.wait()
							clone_7_upvr.Position = HumanoidRootPart_upvr.Position
							local HealSFX = clone_7_upvr.HealSFX
							HealSFX.PlaybackSpeed += math.random(-1, 1) * 0.1
							clone_7_upvr.HealSFX:Play()
							local var38 = Humanoid_upvr
							var38.Health += arg3
							clone_7_upvr.Transparency = 1
							clone_7_upvr.Trail.Enabled = false
							var3_upvw.camShake(arg1, "SmallBump")
							var3_upvw.changeFov(arg1, 65, 0.05, 0.6)
							var3_upvw.flashScreen(arg1, Color3.new(1, 0.32549, 0.32549), 0.1)
						end
					end
				end)
				task.wait(0.05)
			end
		end)
	end
	local var39_upvw = 0
	local tbl_2_upvr = {}
	local tbl = {}
	local var80
	for i_7 = 1, 10 do
		if false then return end
		for _, v_6 in Humanoid_upvr:GetPlayingAnimationTracks() do
			v_6:Stop()
		end
		local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Rapid_Blinks_upvr.Animation)
		any_LoadAnimation_result1_upvr:Play()
		var3_upvw.applyStatus(arg1, "GlobalCD", 0.8)
		var3_upvw.applyStatus(arg1, "Freeze", 0.8)
		var3_upvw.applyStatus(arg1, "AutoRotate", 0.8)
		var3_upvw.applyStatus(arg1, "HyperArmor", 0.8)
		var3_upvw.changeFov(arg1, 40, 1.05, 1)
		task.wait()
		if nil then
			var80 = HumanoidRootPart_upvr.CFrame
			HumanoidRootPart_upvr.CFrame = CFrame.lookAt(HumanoidRootPart_upvr.Position, HumanoidRootPart_upvr.Position + var80.LookVector * -250)
		end
		local clone_8 = Rapid_Blinks_upvr.Charge:Clone()
		clone_8.Parent = HumanoidRootPart_upvr
		clone_8:Play()
		var3_upvw.applyDebris(clone_8, 5)
		local clone_2_upvr = Rapid_Blinks_upvr["Blink Strike"]:Clone()
		clone_2_upvr.Parent = Folder_upvr
		clone_2_upvr.CFrame = HumanoidRootPart_upvr.CFrame
		clone_2_upvr.Weld.Part0 = HumanoidRootPart_upvr
		clone_2_upvr.Weld.Part1 = clone_2_upvr
		var3_upvw.applyDebris(clone_2_upvr, 6)
		function var80() -- Line 207
			--[[ Upvalues[3]:
				[1]: any_LoadAnimation_result1_upvr (readonly)
				[2]: var3_upvw (copied, read and write)
				[3]: clone_2_upvr (readonly)
			]]
			if any_LoadAnimation_result1_upvr.Length <= any_LoadAnimation_result1_upvr.TimePosition then
			else
				var3_upvw.applyDebris(clone_2_upvr, 0)
			end
		end
		var80 = module_upvr
		var80 = clone_2_upvr.Indicator.SurfaceGui
		var80 = TweenInfo.new(0.5 - i_7 * 0.04)
		TweenService_upvr:Create(var80.Frame, var80, {
			Size = UDim2.new(1, 0, 1, 0);
		}):Play()
		task.wait(0.5 - i_7 * 0.04)
		if not clone_2_upvr.Parent then return end
		clone_2_upvr.Weld.Part0 = nil
		clone_2_upvr.Anchored = true
		var3_upvw.applyDebris(clone_2_upvr.Indicator, 0)
		var3_upvw.EmitAllDescendants(clone_2_upvr.VFX1)
		task.wait()
		clone_8:Stop()
		local clone_6 = Rapid_Blinks_upvr.Slash:Clone()
		clone_6.Parent = HumanoidRootPart_upvr
		clone_6:Play()
		var80 = 5
		var3_upvw.applyDebris(clone_6, var80)
		var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(var80), var80.Cooldown):Disconnect()
		var80 = 0
		any_LoadAnimation_result1_upvr:Stop(var80)
		var80 = Rapid_Blinks_upvr.Animation2
		Humanoid_upvr.Animator:LoadAnimation(var80):Play(0)
		var80 = var3_upvw
		var80 = arg1
		var80.changeFov(var80, 1000, 0.3, 0.5)
		var80 = var3_upvw
		var80 = arg1
		var80.flashScreen(var80, Color3.fromRGB(198, 26, 26), 0.5)
		var80 = 0.3
		task.delay(var80, function() -- Line 238
			--[[ Upvalues[5]:
				[1]: var3_upvw (copied, read and write)
				[2]: arg1 (readonly)
				[3]: clone_2_upvr (readonly)
				[4]: Rapid_Blinks_upvr (readonly)
				[5]: HumanoidRootPart_upvr (readonly)
			]]
			var3_upvw.camShake(arg1, "BigBump")
			var3_upvw.changeFov(arg1, 40, 0.05, 1.5)
			var3_upvw.EmitAllDescendants(clone_2_upvr.VFX2)
			local clone_5 = Rapid_Blinks_upvr.Slash2:Clone()
			clone_5.Parent = HumanoidRootPart_upvr
			clone_5:Play()
			var3_upvw.applyDebris(clone_5, 5)
		end)
		var80 = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 75
		local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position, HumanoidRootPart_upvr.CFrame.LookVector * 75, var3_upvw.raycastParams)
		if workspace_Raycast_result1 then
			var80 = CFrame.new(workspace_Raycast_result1.Position) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
		end
		local any_findEnemiesPart_result1 = var3_upvw.findEnemiesPart(clone_2_upvr.Hitbox)
		for _, v_7 in any_findEnemiesPart_result1 do
			table.insert(tbl, v_7)
		end
		if #tbl <= 0 then
		end
		for _, v_8 in any_findEnemiesPart_result1 do
			if not var3_upvw.CheckBlock(v_8, true) then
				for _, v_9 in v_8.Humanoid:GetPlayingAnimationTracks() do
					v_9:Stop()
				end
				v_8:FindFirstChild("HumanoidRootPart").CFrame = var80 + var80.LookVector * -5
				var3_upvw.Knockback(v_8, HumanoidRootPart_upvr.Position, 0, 5)
				var3_upvw.applyDamage(v_8, 2, true, true)
				var3_upvw.applyStatus(v_8, "AutoRotate", 1.7)
				var3_upvw.applyStatus(v_8, "Stunned", 1.7)
				var3_upvw.applyStatus(v_8, "IFrames", 0.3)
				var3_upvw.applyDamage(v_8, 1, true, true)
			end
		end
		;(function(arg1_3) -- Line 79, Named "teleport"
			--[[ Upvalues[9]:
				[1]: var39_upvw (read and write)
				[2]: arg1 (readonly)
				[3]: var3_upvw (copied, read and write)
				[4]: tbl_2_upvr (readonly)
				[5]: PlayerStatus_upvr (copied, readonly)
				[6]: Folder_upvr (readonly)
				[7]: TweenService_upvr (copied, readonly)
				[8]: ReplicatedStorage_upvr (copied, readonly)
				[9]: HumanoidRootPart_upvr (readonly)
			]]
			var39_upvw += 1
			if not arg1.Head:FindFirstChild("LockBV") then
				local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
				BodyVelocity.Name = "LockBV"
				BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				BodyVelocity.Velocity = Vector3.new(0, 0, 0)
				table.insert(tbl_2_upvr, var3_upvw.applyStatus(arg1, "IFrames"))
			end
			task.delay(0.3, function() -- Line 93
				--[[ Upvalues[4]:
					[1]: var39_upvw (copied, read and write)
					[2]: tbl_2_upvr (copied, readonly)
					[3]: PlayerStatus_upvr (copied, readonly)
					[4]: arg1 (copied, readonly)
				]]
				var39_upvw -= 1
				if var39_upvw <= 0 then
					for _, v in tbl_2_upvr do
						PlayerStatus_upvr.RemoveStatus(arg1, v)
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
					local clone = v_3:Clone()
					for _, v_4 in clone:GetChildren() do
						if not v_4:IsA("SpecialMesh") or not v_4:IsA("CharacterMesh") or not v_4:IsA("BlockMesh") then
							v_4:Destroy()
						end
					end
					clone.Transparency = 0.5
					clone.Parent = Folder_upvr
					clone.Material = Enum.Material.Neon
					clone.Anchored = true
					clone.CanCollide = false
					TweenService_upvr:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Transparency = 1;
						Size = Vector3.new(0, 0, 0);
					}):Play()
					game.Debris:AddItem(clone, 3)
					clone.Color = Color3.new(1, 1, 1)
					TweenService_upvr:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
						Color = Color3.fromRGB(209, 20, 20);
					}):Play()
					if clone.Name == "Torso" then
						local clone_4 = ReplicatedStorage_upvr.Skills["Cyber Katana"].TeleportSFX:Clone()
						clone_4.Parent = clone
						clone_4.PlaybackSpeed += math.random(-3, 3) * 0.075
						clone_4:Play()
						local clone_3 = ReplicatedStorage_upvr.Skills["Cyber Katana"].TeleportSFX2:Clone()
						clone_3.Parent = clone
						clone_3.PlaybackSpeed += math.random(-3, 3) * 0.075
						clone_3:Play()
					end
				end
			end
			if arg1_3 then
				HumanoidRootPart_upvr.CFrame = arg1_3
			end
			for _, v_5_upvr in arg1:GetDescendants() do
				if v_5_upvr:IsA("BasePart") and v_5_upvr.Transparency == 0 then
					v_5_upvr.Transparency = 1
					task.delay(0.05, function() -- Line 154
						--[[ Upvalues[1]:
							[1]: v_5_upvr (readonly)
						]]
						v_5_upvr.Transparency = 0
					end)
				end
			end
		end)(var80)
	end
end
return module_upvr
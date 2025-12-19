-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:04
-- Luau version 6, Types version 3
-- Time taken: 0.025622 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 19
module_upvr.GlobalCD = 0.1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 17
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
	local Blade_Storm_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"].Ultimate["Blade Storm"]
	local function _(arg1_2, arg2_2, arg3) -- Line 31, Named "Siphon"
		--[[ Upvalues[7]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: TweenService_upvr (copied, readonly)
			[5]: Humanoid_upvr (readonly)
			[6]: var3_upvw (copied, read and write)
			[7]: arg1 (readonly)
		]]
		task.spawn(function() -- Line 32
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
				task.delay(0.3, function() -- Line 46
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
							local var32 = Humanoid_upvr
							var32.Health += arg3
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
	local var33_upvw = 0
	local tbl_upvr_2 = {}
	local function teleport_upvr(arg1_3) -- Line 82, Named "teleport"
		--[[ Upvalues[8]:
			[1]: var33_upvw (read and write)
			[2]: arg1 (readonly)
			[3]: var3_upvw (copied, read and write)
			[4]: tbl_upvr_2 (readonly)
			[5]: Folder_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
			[7]: ReplicatedStorage_upvr (copied, readonly)
			[8]: HumanoidRootPart_upvr (readonly)
		]]
		var33_upvw += 1
		if not arg1.Head:FindFirstChild("LockBV") then
			local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
			BodyVelocity.Name = "LockBV"
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = Vector3.new(0, 0, 0)
			table.insert(tbl_upvr_2, var3_upvw.applyStatus(arg1, "IFrames"))
		end
		task.delay(0.3, function() -- Line 96
			--[[ Upvalues[4]:
				[1]: var33_upvw (copied, read and write)
				[2]: tbl_upvr_2 (copied, readonly)
				[3]: var3_upvw (copied, read and write)
				[4]: arg1 (copied, readonly)
			]]
			var33_upvw -= 1
			if var33_upvw <= 0 then
				for _, v in tbl_upvr_2 do
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
					local clone_6 = ReplicatedStorage_upvr.Skills["Cyber Katana"].TeleportSFX2:Clone()
					clone_6.Parent = clone
					clone_6.PlaybackSpeed += math.random(-3, 3) * 0.075
					clone_6:Play()
				end
			end
		end
		if arg1_3 then
			HumanoidRootPart_upvr.CFrame = arg1_3
		end
		for _, v_5_upvr in arg1:GetDescendants() do
			if v_5_upvr:IsA("BasePart") and v_5_upvr.Transparency == 0 then
				v_5_upvr.Transparency = 1
				task.delay(0.05, function() -- Line 157
					--[[ Upvalues[1]:
						[1]: v_5_upvr (readonly)
					]]
					v_5_upvr.Transparency = 0
				end)
			end
		end
	end
	local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Blade_Storm_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	local tbl_upvr = {}
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "GlobalCD"))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "Freeze"))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames"))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "AutoRotate"))
	local tbl_upvr_4 = {}
	local clone_2_upvr = Blade_Storm_upvr.BladeStormVFX:Clone()
	clone_2_upvr.Parent = Folder_upvr
	clone_2_upvr.weld.Part0 = HumanoidRootPart_upvr
	clone_2_upvr.weld.Part1 = clone_2_upvr
	for _, v_6 in clone_2_upvr.AreaVFX:GetChildren() do
		if v_6:IsA("Sound") then
			v_6:Play()
		end
	end
	var3_upvw.changeFov(arg1, 45, 3, 5)
	task.wait(1.5)
	any_LoadAnimation_result1_upvr:AdjustSpeed(0.5)
	clone_2_upvr.Cylinder.Transparency = 1
	for _, v_7 in clone_2_upvr.AreaVFX:GetDescendants() do
		if v_7:IsA("ParticleEmitter") then
			v_7:Destroy()
		end
	end
	for _, v_8 in clone_2_upvr.ExplosionVFX:GetChildren() do
		if v_8:IsA("Sound") then
			v_8:Play()
		end
	end
	var3_upvw.EmitAllDescendants(clone_2_upvr.ExplosionVFX)
	var3_upvw.changeFov(arg1, 300, 0.1, 5)
	var3_upvw.camShake(arg1, "Bump")
	var3_upvw.flashScreen(arg1, Color3.new(1, 0.172549, 0.172549), 1)
	var3_upvw.Blur(arg1, 25, 0.8)
	for _, v_9 in var3_upvw.findEnemiesPart(clone_2_upvr.Hitbox), nil do
		if not var3_upvw.CheckBlock(v_9, true) then
			var3_upvw.changeFov(v_9, 300, 0.1, 5)
			var3_upvw.camShake(v_9, "Bump")
			var3_upvw.flashScreen(v_9, Color3.new(1, 0.172549, 0.172549), 1)
			var3_upvw.Blur(v_9, 25, 0.8)
			table.insert({}, v_9)
			for _, v_10 in v_9.Humanoid:GetPlayingAnimationTracks() do
				v_10:AdjustSpeed(0)
			end
			for _, v_11 in v_9:GetDescendants() do
				if v_11:IsA("BodyVelocity") or v_11:IsA("BodyPosition") then
					v_11:Destroy()
				end
			end
			local BodyVelocity_2 = Instance.new("BodyVelocity", v_9.Head)
			BodyVelocity_2.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity_2.Velocity = Vector3.new(0, 0, 0)
			var3_upvw.applyDebris(BodyVelocity_2, 1.9)
			table.insert({}, BodyVelocity_2)
			tbl_upvr_4[v_9.Name] = {}
			local var86 = tbl_upvr_4[v_9.Name]
			table.insert(var86, var3_upvw.applyStatus(v_9, "Stunned", 1.9))
			table.insert(var86, var3_upvw.applyStatus(v_9, "AutoRotate", 1.9))
			table.insert(var86, var3_upvw.applyStatus(v_9, "IFrames", 1.9))
			v_9.HumanoidRootPart.CFrame = CFrame.lookAt(v_9.HumanoidRootPart.Position, HumanoidRootPart_upvr.Position)
		end
	end
	local tbl_upvr_5 = {}
	local tbl_upvr_3 = {}
	task.delay(0.5, function() -- Line 252
		--[[ Upvalues[15]:
			[1]: HumanoidRootPart_upvr (readonly)
			[2]: tbl_upvr_5 (readonly)
			[3]: clone_2_upvr (readonly)
			[4]: var3_upvw (copied, read and write)
			[5]: teleport_upvr (readonly)
			[6]: any_LoadAnimation_result1_upvr (readonly)
			[7]: Humanoid_upvr (readonly)
			[8]: Blade_Storm_upvr (readonly)
			[9]: Folder_upvr (readonly)
			[10]: arg1 (readonly)
			[11]: module_upvr (copied, readonly)
			[12]: PlayerStatus_upvr (copied, readonly)
			[13]: tbl_upvr_3 (readonly)
			[14]: tbl_upvr (readonly)
			[15]: tbl_upvr_4 (readonly)
		]]
		for _, v_12 in tbl_upvr_5 do
			for _, v_13 in clone_2_upvr:GetChildren() do
				if v_13:IsA("Sound") then
					local clone_8 = v_13:Clone()
					clone_8.PlaybackSpeed += math.random(-2, 2) * 0.1
					clone_8.Parent = HumanoidRootPart_upvr
					clone_8:Play()
					var3_upvw.applyDebris(clone_8, 5)
				end
			end
			teleport_upvr((v_12.HumanoidRootPart.CFrame + v_12.HumanoidRootPart.CFrame.LookVector * 5) * CFrame.Angles(0, math.pi, 0))
			task.wait(0.06)
		end
		teleport_upvr(HumanoidRootPart_upvr.CFrame)
		any_LoadAnimation_result1_upvr:Stop(0)
		local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Blade_Storm_upvr.Animation2)
		any_LoadAnimation_result1:Play(0)
		var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("teleport"):Connect(function() -- Line 274
			--[[ Upvalues[6]:
				[1]: Blade_Storm_upvr (copied, readonly)
				[2]: Folder_upvr (copied, readonly)
				[3]: HumanoidRootPart_upvr (copied, readonly)
				[4]: var3_upvw (copied, read and write)
				[5]: arg1 (copied, readonly)
				[6]: tbl_upvr_5 (copied, readonly)
			]]
			local clone_5 = Blade_Storm_upvr.ShockwaveVFX:Clone()
			clone_5.Parent = Folder_upvr
			clone_5.CFrame = HumanoidRootPart_upvr.CFrame + Vector3.new(0, -2.5, 0)
			var3_upvw.EmitAllDescendants(clone_5)
			var3_upvw.applyDebris(clone_5, 10)
			for _, v_14 in clone_5:GetChildren() do
				if v_14:IsA("Sound") then
					v_14:Play()
				end
			end
			var3_upvw.camShake(arg1, "Bump")
			var3_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 0.5)
			var3_upvw.Blur(arg1, 50, 0.5)
			var3_upvw.changeFov(arg1, 25, 0.01, 5)
			for _, v_15 in tbl_upvr_5 do
				var3_upvw.camShake(v_15, "Bump")
				var3_upvw.flashScreen(v_15, Color3.new(1, 1, 1), 0.5)
				var3_upvw.Blur(v_15, 50, 0.5)
				var3_upvw.changeFov(v_15, 25, 0.01, 5)
			end
		end), module_upvr.Cooldown)
		task.wait(1.2)
		any_LoadAnimation_result1:AdjustSpeed(0.1)
		if 0 < #tbl_upvr_5 then
			var3_upvw.impactFrame2(arg1, 0.03)
			var3_upvw.camShake(arg1, "BigBump")
			var3_upvw.flashScreen(arg1, Color3.new(1, 0.203922, 0.203922), 2)
			var3_upvw.Blur(arg1, 25, 0.5)
			var3_upvw.changeFov(arg1, 300, 0.01, 4)
		end
		for _, v_16 in tbl_upvr_5 do
			local clone_3 = Blade_Storm_upvr.SlashVFX.SlashATT:Clone()
			clone_3.Parent = v_16.HumanoidRootPart
			var3_upvw.EmitAllDescendants(clone_3)
			var3_upvw.applyDebris(clone_3, 8)
			for _, v_17 in clone_3:GetChildren() do
				if v_17:IsA("Sound") then
					v_17:Play()
				end
			end
			for _, v_18 in PlayerStatus_upvr.FindTable(v_16) do
				if v_18.Name == "IFrames" then
					var3_upvw.applyDebris(v_18, 0)
				end
			end
			var3_upvw.applyDamage(v_16, 30, true)
			var3_upvw.camShake(v_16, "BigBump")
			var3_upvw.flashScreen(v_16, Color3.new(1, 0.203922, 0.203922), 2)
			var3_upvw.Blur(v_16, 25, 0.5)
			var3_upvw.changeFov(v_16, 300, 0.01, 4)
			var3_upvw.impactFrame2(v_16, 0.03)
			var3_upvw.applyStatus(v_16, "Stunned", 1.5)
			var3_upvw.applyStatus(v_16, "AutoRotate", 1.5)
		end
		task.wait(0.65)
		any_LoadAnimation_result1:Stop()
		for _, v_19 in tbl_upvr_3 do
			var3_upvw.applyDebris(v_19, 0)
		end
		for _, v_20 in tbl_upvr do
			var3_upvw.applyDebris(v_20, 0)
		end
		for _, v_21 in tbl_upvr_4 do
			for _, v_22 in v_21 do
				local var129 = workspace.WorldInfo.Live:FindFirstChild(v_21) or nil
				if var129 then
					var3_upvw.applyDebris(v_22, 0, var129)
				end
			end
		end
	end)
end
return module_upvr
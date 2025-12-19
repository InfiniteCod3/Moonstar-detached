-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:09
-- Luau version 6, Types version 3
-- Time taken: 0.027935 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 15
module_upvr.GlobalCD = 1
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[6]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: PlayerStatus_upvr (readonly)
		[6]: RunService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Flash_Overdrive_upvr = ReplicatedStorage_upvr.Skills["Cyber Katana"]["Flash Overdrive"]
	local CyberKatana_upvr = arg1:FindFirstChild("CyberKatana")
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Flash_Overdrive_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 34
		--[[ Upvalues[1]:
			[1]: CyberKatana_upvr (readonly)
		]]
		CyberKatana_upvr.TrailAtt.Trail.Enabled = false
	end)
	var3_upvw.applyStatus(arg1, "Freeze", 1)
	local clone_3 = Flash_Overdrive_upvr.VFX.PrepareSFX:Clone()
	clone_3.Parent = HumanoidRootPart_upvr
	clone_3:Play()
	var3_upvw.applyDebris(clone_3, 5)
	local var14_upvw = 0
	local tbl_upvr_3 = {}
	local function teleport_upvr(arg1_2) -- Line 47, Named "teleport"
		--[[ Upvalues[8]:
			[1]: var14_upvw (read and write)
			[2]: arg1 (readonly)
			[3]: var3_upvw (copied, read and write)
			[4]: tbl_upvr_3 (readonly)
			[5]: Folder_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
			[7]: ReplicatedStorage_upvr (copied, readonly)
			[8]: HumanoidRootPart_upvr (readonly)
		]]
		var14_upvw += 1
		if not arg1.Head:FindFirstChild("LockBV") then
			local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
			BodyVelocity.Name = "LockBV"
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = Vector3.new(0, 0, 0)
			table.insert(tbl_upvr_3, var3_upvw.applyStatus(arg1, "IFrames"))
		end
		task.delay(0.2, function() -- Line 61
			--[[ Upvalues[4]:
				[1]: var14_upvw (copied, read and write)
				[2]: tbl_upvr_3 (copied, readonly)
				[3]: var3_upvw (copied, read and write)
				[4]: arg1 (copied, readonly)
			]]
			var14_upvw -= 1
			if var14_upvw <= 0 then
				for _, v in tbl_upvr_3 do
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
					Color = Color3.fromRGB(98, 37, 209);
				}):Play()
				if clone.Name == "Torso" then
					local clone_8 = ReplicatedStorage_upvr.Skills["Cyber Katana"].TeleportSFX:Clone()
					clone_8.Parent = clone
					clone_8.PlaybackSpeed += math.random(-3, 3) * 0.075
					clone_8:Play()
					local clone_6 = ReplicatedStorage_upvr.Skills["Cyber Katana"].TeleportSFX2:Clone()
					clone_6.Parent = clone
					clone_6.PlaybackSpeed += math.random(-3, 3) * 0.075
					clone_6:Play()
				end
			end
		end
		if arg1_2 then
			HumanoidRootPart_upvr.CFrame = arg1_2
		end
		for _, v_5_upvr in arg1:GetDescendants() do
			if v_5_upvr:IsA("BasePart") and v_5_upvr.Transparency == 0 then
				v_5_upvr.Transparency = 1
				task.delay(0.05, function() -- Line 122
					--[[ Upvalues[1]:
						[1]: v_5_upvr (readonly)
					]]
					v_5_upvr.Transparency = 0
				end)
			end
		end
	end
	local tbl_upvr_2 = {}
	local tbl_upvr = {}
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("teleport"):Connect(function() -- Line 132
		--[[ Upvalues[11]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Flash_Overdrive_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: any_LoadAnimation_result1_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
			[7]: PlayerStatus_upvr (copied, readonly)
			[8]: RunService_upvr (copied, readonly)
			[9]: tbl_upvr_2 (readonly)
			[10]: tbl_upvr (readonly)
			[11]: teleport_upvr (readonly)
		]]
		var3_upvw.camShake(arg1, "Bump")
		local clone_2 = Flash_Overdrive_upvr.VFX.KatanaDash:Clone()
		clone_2.Parent = HumanoidRootPart_upvr
		var3_upvw.EmitAllDescendants(clone_2)
		var3_upvw.applyDebris(clone_2, 10)
		for _, v_6 in clone_2:GetDescendants() do
			if v_6:IsA("Sound") then
				v_6:Play()
			end
		end
		any_LoadAnimation_result1_upvr:AdjustSpeed(0)
		var3_upvw.applyStatus(arg1, "GlobalCD", 1.25)
		var3_upvw.applyStatus(arg1, "Freeze", 1.25)
		var3_upvw.applyStatus(arg1, "AutoRotate", 1.25)
		var3_upvw.applyStatus(arg1, "IFrames", 1.25)
		local var58_upvw = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 75
		local any_Create_result1 = TweenService_upvr:Create(HumanoidRootPart_upvr, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = var58_upvw;
		})
		local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position, HumanoidRootPart_upvr.CFrame.LookVector * 75, var3_upvw.raycastParams)
		if workspace_Raycast_result1 then
			any_Create_result1 = TweenService_upvr:Create(HumanoidRootPart_upvr, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(workspace_Raycast_result1.Position) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p;
			})
			var58_upvw = CFrame.new(workspace_Raycast_result1.Position) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
		end
		any_Create_result1:Play()
		local clone_upvr = Flash_Overdrive_upvr.VFX.BottomTrail:Clone()
		clone_upvr.Parent = HumanoidRootPart_upvr
		var3_upvw.applyDebris(clone_upvr, 4.5)
		local var65_upvw
		any_Create_result1.Completed:Connect(function() -- Line 169
			--[[ Upvalues[8]:
				[1]: any_LoadAnimation_result1_upvr (copied, readonly)
				[2]: var65_upvw (read and write)
				[3]: clone_upvr (readonly)
				[4]: Flash_Overdrive_upvr (copied, readonly)
				[5]: HumanoidRootPart_upvr (copied, readonly)
				[6]: var3_upvw (copied, read and write)
				[7]: arg1 (copied, readonly)
				[8]: PlayerStatus_upvr (copied, readonly)
			]]
			any_LoadAnimation_result1_upvr:AdjustSpeed(1)
			var65_upvw:Disconnect()
			for _, v_7 in clone_upvr:GetChildren() do
				if v_7:IsA("Trail") then
					v_7.Enabled = false
				end
			end
			local clone_7 = Flash_Overdrive_upvr.VFX.Swing:Clone()
			clone_7.Parent = HumanoidRootPart_upvr
			clone_7:Play()
			var3_upvw.applyDebris(clone_7, 8)
			local clone_4 = Flash_Overdrive_upvr.VFX.Swing2:Clone()
			clone_4.Parent = HumanoidRootPart_upvr
			clone_4:Play()
			var3_upvw.applyDebris(clone_4, 8)
			any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("slash"):Connect(function() -- Line 189
				--[[ Upvalues[5]:
					[1]: Flash_Overdrive_upvr (copied, readonly)
					[2]: HumanoidRootPart_upvr (copied, readonly)
					[3]: var3_upvw (copied, read and write)
					[4]: arg1 (copied, readonly)
					[5]: PlayerStatus_upvr (copied, readonly)
				]]
				local clone_5 = Flash_Overdrive_upvr.VFX.SlashVFX:Clone()
				clone_5.Parent = HumanoidRootPart_upvr
				var3_upvw.EmitAllDescendants(clone_5)
				for _, v_8 in clone_5:GetChildren() do
					if v_8:IsA("Sound") then
						v_8:Play()
					end
				end
				var3_upvw.applyDebris(clone_5, 12)
				var3_upvw.camShake(arg1, "Explosion")
				var3_upvw.changeFov(arg1, 25, 0.01, 1)
				var3_upvw.flashScreen(arg1, Color3.fromRGB(98, 37, 209), 1)
				local any_findEnemiesMagnitude_result1 = var3_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 12, true)
				if #any_findEnemiesMagnitude_result1 <= 0 then
					var3_upvw.applyStatus(arg1, "Stunned", 1.6)
					var3_upvw.applyStatus(arg1, "AutoRotate", 1.6)
				end
				for _, v_9 in any_findEnemiesMagnitude_result1 do
					for i_10, v_10 in PlayerStatus_upvr.FindTable(v_9) do
						var3_upvw.applyDebris(v_10, 0)
					end
					if var3_upvw.CheckBlock(v_9) then
						i_10 = "Stunned"
						v_10 = 0.5
						var3_upvw.applyStatus(arg1, i_10, v_10)
						i_10 = "AutoRotate"
						v_10 = 0.5
						var3_upvw.applyStatus(arg1, i_10, v_10)
					else
						i_10 = 3
						var3_upvw.blood(v_9, i_10)
						i_10 = 14
						var3_upvw.applyDamage(v_9, i_10)
						i_10 = "Ragdoll"
						v_10 = 2.5
						var3_upvw.applyStatus(v_9, i_10, v_10)
						v_10 = HumanoidRootPart_upvr.Position
						i_10 = v_10 + HumanoidRootPart_upvr.CFrame.LookVector * -25
						v_10 = 10
						var3_upvw.Knockback(v_9, i_10, v_10, 60)
						i_10 = "Explosion"
						var3_upvw.camShake(v_9, i_10)
						i_10 = 25
						v_10 = 0.01
						var3_upvw.changeFov(v_9, i_10, v_10, 1)
						i_10 = Color3.fromRGB
						v_10 = 98
						i_10 = i_10(v_10, 37, 209)
						v_10 = 1
						var3_upvw.flashScreen(v_9, i_10, v_10)
					end
				end
			end)
		end)
		var65_upvw = RunService_upvr.Stepped:Connect(function() -- Line 239
			--[[ Upvalues[8]:
				[1]: var3_upvw (copied, read and write)
				[2]: HumanoidRootPart_upvr (copied, readonly)
				[3]: tbl_upvr_2 (copied, readonly)
				[4]: tbl_upvr (copied, readonly)
				[5]: PlayerStatus_upvr (copied, readonly)
				[6]: TweenService_upvr (copied, readonly)
				[7]: var58_upvw (read and write)
				[8]: teleport_upvr (copied, readonly)
			]]
			for _, v_11 in var3_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 14, true), nil do
				if not table.find(tbl_upvr_2, v_11) then
					table.insert(tbl_upvr_2, v_11)
					var3_upvw.unragdoll(v_11)
					var3_upvw.applyStatus(v_11, "Stunned", 1)
					var3_upvw.applyStatus(v_11, "AutoRotate", 1)
					table.insert(tbl_upvr, var3_upvw.applyStatus(v_11, "IFrames", 0.5))
					for _, v_12 in v_11.Humanoid:GetPlayingAnimationTracks() do
						v_12:Stop()
					end
					for _, v_13 in PlayerStatus_upvr.FindTable(v_11) do
						if v_13.Name == "HyperArmor" then
							var3_upvw.applyDebris(v_13, 0)
						end
					end
					TweenService_upvr:Create(v_11.HumanoidRootPart, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = (var58_upvw + var58_upvw.LookVector * 5) * CFrame.Angles(0, math.pi, 0);
					}):Play()
				end
			end
			teleport_upvr()
		end)
	end)
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("trail"):Connect(function(arg1_3) -- Line 270
		--[[ Upvalues[1]:
			[1]: CyberKatana_upvr (readonly)
		]]
		if arg1_3 == "true" then
			for _, v_14 in CyberKatana_upvr.TrailAtt:GetChildren() do
				if v_14:IsA("Trail") then
					v_14.Enabled = true
				end
			end
		else
			for _, v_15 in CyberKatana_upvr.TrailAtt:GetChildren() do
				if v_15:IsA("Trail") then
					v_15.Enabled = false
				end
			end
		end
	end)
end
return module_upvr
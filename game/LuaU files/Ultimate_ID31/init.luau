-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:09
-- Luau version 6, Types version 3
-- Time taken: 0.020026 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.ModeLength = 90
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 14
	--[[ Upvalues[6]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: module_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: RunService_upvr (readonly)
		[6]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	var3_upvw.applyDebris(Folder_upvr, 25)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills["Blood Sword"].Ultimate
	local tbl_upvr = {}
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "Freeze", 12))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "GlobalCD", 12))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "AutoRotate", 12))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames", 12))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "Ultimate", 12))
	table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "LockUltimateMeter", module_upvr.ModeLength))
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid"):LoadAnimation(Ultimate_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	local clone_3_upvr = Ultimate_upvr.BloodSwordTheme:Clone()
	clone_3_upvr.Parent = HumanoidRootPart_upvr
	clone_3_upvr:Play()
	arg1.Humanoid.Health = arg1.Humanoid.MaxHealth
	local clone_4_upvr = Ultimate_upvr.SceneCover:Clone()
	clone_4_upvr.Parent = arg2.PlayerGui
	TweenService_upvr:Create(clone_4_upvr.Down, TweenInfo.new(1), {
		Position = UDim2.new(0, 0, 1, 0);
	}):Play()
	TweenService_upvr:Create(clone_4_upvr.Up, TweenInfo.new(1), {
		Position = UDim2.new(0, 0, 0, 0);
	}):Play()
	local clone = Ultimate_upvr.AuraPart.aura:Clone()
	clone.Parent = HumanoidRootPart_upvr
	local var19_upvw = false
	task.delay(8, function() -- Line 55
		--[[ Upvalues[4]:
			[1]: var19_upvw (read and write)
			[2]: TweenService_upvr (copied, readonly)
			[3]: clone_4_upvr (readonly)
			[4]: clone_3_upvr (readonly)
		]]
		var19_upvw = true
		TweenService_upvr:Create(clone_4_upvr.Down, TweenInfo.new(1), {
			Position = UDim2.new(0, 0, 1.12, 0);
		}):Play()
		TweenService_upvr:Create(clone_4_upvr.Up, TweenInfo.new(1), {
			Position = UDim2.new(0, 0, -0.12, 0);
		}):Play()
		TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(2), {
			Volume = 0.45;
		}):Play()
	end)
	local function pulse_upvr() -- Line 62, Named "pulse"
		--[[ Upvalues[3]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: clone_3_upvr (readonly)
		]]
		var3_upvw.camShake(arg1, "SmallBump")
		var3_upvw.changeFov(arg1, 60, 0.01, 0.25)
		var3_upvw.flashScreen(arg1, Color3.new(0, 0, 0), 0.94)
		clone_3_upvr.Volume = 0.75
	end
	var3_upvw.ChangeEnviorment(arg1, "BloodSword")
	pulse_upvr()
	task.spawn(function() -- Line 72
		--[[ Upvalues[2]:
			[1]: var19_upvw (read and write)
			[2]: pulse_upvr (readonly)
		]]
		while task.wait(0.91) and not var19_upvw do
			pulse_upvr()
		end
	end)
	task.spawn(function() -- Line 79
		--[[ Upvalues[12]:
			[1]: Ultimate_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var3_upvw (copied, read and write)
			[5]: RunService_upvr (copied, readonly)
			[6]: arg1 (readonly)
			[7]: module_upvr (copied, readonly)
			[8]: TweenService_upvr (copied, readonly)
			[9]: var19_upvw (read and write)
			[10]: any_LoadAnimation_result1_upvr (readonly)
			[11]: tbl_upvr (readonly)
			[12]: PlayerStatus_upvr (copied, readonly)
		]]
		local clone_2_upvr = Ultimate_upvr.BloodCacoon:Clone()
		clone_2_upvr.Parent = Folder_upvr
		clone_2_upvr.CFrame = HumanoidRootPart_upvr.CFrame
		local BodyVelocity_upvr = Instance.new("BodyVelocity", HumanoidRootPart_upvr)
		BodyVelocity_upvr.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		BodyVelocity_upvr.Velocity = Vector3.new(0, 0, 0)
		local var45_upvw
		var45_upvw = var3_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 89
			--[[ Upvalues[6]:
				[1]: BodyVelocity_upvr (readonly)
				[2]: clone_2_upvr (readonly)
				[3]: arg1 (copied, readonly)
				[4]: var3_upvw (copied, read and write)
				[5]: var45_upvw (read and write)
				[6]: HumanoidRootPart_upvr (copied, readonly)
			]]
			if not BodyVelocity_upvr.Parent or not clone_2_upvr.Parent or not arg1.Parent then
				var3_upvw.applyDebris(BodyVelocity_upvr, 0)
				var45_upvw:Disconnect()
			else
				HumanoidRootPart_upvr.CFrame = CFrame.new(clone_2_upvr.Position) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
			end
		end), module_upvr.ModeLength)
		local var47_upvw = false
		task.spawn(function() -- Line 96
			--[[ Upvalues[3]:
				[1]: clone_2_upvr (readonly)
				[2]: TweenService_upvr (copied, readonly)
				[3]: var47_upvw (read and write)
			]]
			local var48 = clone_2_upvr.Rotation + Vector3.new(359, 359, 0)
			TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
				Rotation = var48;
			}):Play()
			TweenService_upvr:Create(clone_2_upvr.bloodBall, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
				Rotation = var48;
			}):Play()
			while clone_2_upvr.Parent and not var47_upvw do
				local var51 = Vector3.new(16, 16, 16) + Vector3.new(math.random(0, 4), math.random(0, 4), math.random(0, 4))
				TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
					Size = var51;
				}):Play()
				TweenService_upvr:Create(clone_2_upvr.bloodBall, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
					Size = var51 + Vector3.new(1, 1, 1);
				}):Play()
				task.wait(0.2)
			end
		end)
		for _, v in clone_2_upvr:GetDescendants() do
			if v:IsA("Beam") then
				v.Width0 = 0
				v.Width1 = 0
				TweenService_upvr:Create(v, TweenInfo.new(1), {
					Width0 = v.Width0;
					Width1 = v.Width1;
				}):Play()
			end
		end
		local bloodBall = clone_2_upvr.bloodBall
		bloodBall.Size = Vector3.new(0, 0, 0)
		TweenService_upvr:Create(bloodBall, TweenInfo.new(1), {
			Size = Vector3.new(17.6000, 17.6000, 17.6000);
		}):Play()
		clone_2_upvr.Size = Vector3.new(0, 0, 0)
		TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.75), {
			Size = Vector3.new(16, 16, 16);
			CFrame = clone_2_upvr.CFrame + Vector3.new(0, 60, 0);
		}):Play()
		local Position = workspace:Raycast(HumanoidRootPart_upvr.Position, Vector3.new(0, -1000, 0), var3_upvw.raycastParams).Position
		if not Position then
			Position = HumanoidRootPart_upvr.Position
		end
		local BeamPart_upvr = clone_2_upvr.BeamPart
		BeamPart_upvr.CFrame = CFrame.new(Position) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
		task.spawn(function() -- Line 137
			--[[ Upvalues[2]:
				[1]: BeamPart_upvr (readonly)
				[2]: TweenService_upvr (copied, readonly)
			]]
			while task.wait(0.1) and BeamPart_upvr and BeamPart_upvr.Parent do
				TweenService_upvr:Create(BeamPart_upvr, TweenInfo.new(0.25), {
					CFrame = BeamPart_upvr.CFrame * CFrame.Angles(0, 0.7853981633974483, 0);
				}):Play()
			end
		end)
		repeat
			task.wait()
		until var19_upvw
		var47_upvw = true
		for _, v_2 in clone_2_upvr:GetDescendants() do
			if v_2:IsA("ParticleEmitter") then
				v_2.Enabled = false
			end
		end
		TweenService_upvr:Create(bloodBall, TweenInfo.new(2), {
			Size = Vector3.new(0, 0, 0);
		}):Play()
		TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(1.5), {
			Size = Vector3.new(0, 0, 0);
		}):Play()
		TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(1.5), {
			CFrame = CFrame.new(Position + Vector3.new(0, 3, 0)) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p;
		}):Play()
		for _, v_3 in clone_2_upvr:GetDescendants() do
			if v_3:IsA("Beam") then
				TweenService_upvr:Create(v_3, TweenInfo.new(1.5), {
					Width0 = 0;
					Width1 = 0;
				}):Play()
			end
		end
		task.wait(1.5)
		any_LoadAnimation_result1_upvr:Stop(0)
		clone_2_upvr:Destroy()
		for _, v_4 in tbl_upvr do
			PlayerStatus_upvr.RemoveStatus(arg1, v_4)
		end
	end)
	task.wait(module_upvr.ModeLength)
	repeat
		task.wait()
	until not PlayerStatus_upvr.FindStatus(arg1, "GlobalCD")
	var3_upvw.ChangeEnviorment(arg1, "Normal")
	for _, v_5 in clone:GetChildren() do
		if v_5:IsA("ParticleEmitter") then
			v_5.Enabled = false
		elseif v_5:IsA("Sound") then
			v_5:Stop()
		end
	end
end
return module_upvr
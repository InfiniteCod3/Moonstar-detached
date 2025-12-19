-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:53
-- Luau version 6, Types version 3
-- Time taken: 0.019641 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: TweenService_upvr (readonly)
		[4]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 10)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Chilling_Arc = ReplicatedStorage_upvr.Skills["Snow Blasters"]["Chilling Arc"]
	local Snow_Blasters_upvr = arg1:FindFirstChild("Snow Blasters")
	local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity.MaxForce = Vector3.new(1000000, 0, 1000000)
	BodyVelocity.Velocity = HumanoidRootPart.CFrame.LookVector * -60
	TweenService_upvr:Create(BodyVelocity, TweenInfo.new(0.5), {
		Velocity = HumanoidRootPart.CFrame.LookVector * -20;
	}):Play()
	game.Debris:AddItem(BodyVelocity, 0.5)
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Chilling_Arc.Animation)
	any_LoadAnimation_result1:Play()
	local function ToggleTrails_upvr(arg1_2) -- Line 36, Named "ToggleTrails"
		--[[ Upvalues[1]:
			[1]: Snow_Blasters_upvr (readonly)
		]]
		for _, v in Snow_Blasters_upvr:GetDescendants() do
			if v:IsA("Trail") and v.Name == "Trail" then
				v.Enabled = arg1_2
			end
		end
	end
	ToggleTrails_upvr(true)
	var3_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 45
		--[[ Upvalues[2]:
			[1]: Snow_Blasters_upvr (readonly)
			[2]: ToggleTrails_upvr (readonly)
		]]
		for _, v_2 in Snow_Blasters_upvr.RightBlaster.SnowCharge:GetChildren() do
			v_2.Enabled = false
		end
		ToggleTrails_upvr(false)
	end), 60)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 52
		--[[ Upvalues[1]:
			[1]: Snow_Blasters_upvr (readonly)
		]]
		if Snow_Blasters_upvr:FindFirstChild(arg1_3) then
			Snow_Blasters_upvr[arg1_3]:Play()
		end
	end), 60)
	local clone_upvr = Chilling_Arc.Indicator:Clone()
	clone_upvr.Parent = Folder
	clone_upvr.CFrame = CFrame.new(HumanoidRootPart.Position + Vector3.new(0, -2.9000, 0) + HumanoidRootPart.CFrame.LookVector * 26) * HumanoidRootPart.CFrame - HumanoidRootPart.CFrame.p
	game.Debris:AddItem(clone_upvr, 4)
	local descendants_2, NONE, _ = clone_upvr:GetDescendants()
	local var33_upvw
	for _, v_3 in descendants_2, NONE, var33_upvw do
		if v_3:IsA("BasePart") then
			v_3.Size = Vector3.new(1, 1, 1)
			TweenService_upvr:Create(v_3, TweenInfo.new(0.3), {
				Size = v_3.Size;
			}):Play()
		elseif v_3:IsA("ParticleEmitter") then
			v_3.Enabled = true
		elseif v_3:IsA("PointLight") then
			v_3.Brightness = 0
			TweenService_upvr:Create(v_3, TweenInfo.new(0.3), {
				Brightness = v_3.Brightness;
			}):Play()
		end
	end
	clone_upvr.Summon:Play()
	clone_upvr.Blizzard:Play()
	var33_upvw = 0
	clone_upvr.Blizzard.Volume = var33_upvw
	TweenService_upvr:Create(clone_upvr.Blizzard, TweenInfo.new(0.75), {
		Volume = clone_upvr.Blizzard.Volume;
	}):Play()
	local var37_upvw = false
	var33_upvw = var3_upvw.conTimer
	var33_upvw(any_LoadAnimation_result1:GetMarkerReachedSignal("Shoot"):Connect(function() -- Line 88
		--[[ Upvalues[3]:
			[1]: var37_upvw (read and write)
			[2]: clone_upvr (readonly)
			[3]: TweenService_upvr (copied, readonly)
		]]
		var37_upvw = true
		clone_upvr.Despawn:Play()
		clone_upvr.Transparency = 1
		for _, v_4 in clone_upvr:GetDescendants() do
			if v_4:IsA("ParticleEmitter") then
				v_4:Destroy()
			elseif v_4:IsA("Sound") then
				TweenService_upvr:Create(v_4, TweenInfo.new(0.8), {
					Volume = 0;
				}):Play()
			elseif v_4:IsA("BasePart") then
				TweenService_upvr:Create(v_4, TweenInfo.new(0.25), {
					Size = Vector3.new(0, 0, 0);
				}):Play()
			elseif v_4:IsA("PointLight") then
				TweenService_upvr:Create(v_4, TweenInfo.new(0.3), {
					Brightness = 0;
				}):Play()
			end
		end
	end), 60)
	var33_upvw = false
	var3_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 108
		--[[ Upvalues[2]:
			[1]: var33_upvw (read and write)
			[2]: var37_upvw (read and write)
		]]
		var33_upvw = true
		var37_upvw = true
	end), 60)
	while task.wait() and clone_upvr.Parent and not var37_upvw do
		if PlayerStatus_upvr.FindStatus(arg1, "Stunned") or PlayerStatus_upvr.FindStatus(arg1, "Ragdoll") then
			var33_upvw = true
			var37_upvw = true
			return
		end
		TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.3), {
			CFrame = CFrame.new(HumanoidRootPart.Position + Vector3.new(0, -2.9000, 0) + HumanoidRootPart.CFrame.LookVector * 26) * HumanoidRootPart.CFrame - HumanoidRootPart.CFrame.p;
		}):Play()
	end
	if var33_upvw then
	else
		TweenService_upvr:Create(clone_upvr, TweenInfo.new(0), {
			CFrame = clone_upvr.CFrame;
		}):Play()
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireServer("Chilling Arc", {
			IndicatorCF = clone_upvr.CFrame;
		})
	end
end
return module
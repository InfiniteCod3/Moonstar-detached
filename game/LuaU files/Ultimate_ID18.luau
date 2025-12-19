-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:31
-- Luau version 6, Types version 3
-- Time taken: 0.008759 seconds

local module_upvr = {
	GlobalCD = 3.5;
	ModeLength = 96;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: module_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 96)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	var2_upvw.applyStatus(arg1, "Freeze", 3.5)
	var2_upvw.applyStatus(arg1, "AutoRotate", 3.5)
	var2_upvw.applyStatus(arg1, "IFrames", 3.5)
	var2_upvw.applyStatus(arg1, "LockUltimateMeter", module_upvr.ModeLength)
	local clone = ReplicatedStorage_upvr.Skills.Greatsword.Ultimate.Aura:Clone()
	clone.Parent = Folder
	clone.weld.Part0 = HumanoidRootPart
	clone.weld.Part1 = clone
	Humanoid.Health = Humanoid.MaxHealth
	var2_upvw.changeFov(arg1, 100, 0.6, 1)
	task.wait(0.4)
	local clone_2_upvr = clone.Music:Clone()
	clone_2_upvr.Parent = arg1:FindFirstChild("Head") or arg1
	clone_2_upvr:Play()
	clone_2_upvr.Ended:Connect(function() -- Line 53
		--[[ Upvalues[1]:
			[1]: clone_2_upvr (readonly)
		]]
		clone_2_upvr:Destroy()
	end)
	task.wait(0.2)
	for _, v_upvr in clone:GetChildren() do
		if v_upvr:IsA("ParticleEmitter") then
			v_upvr.Enabled = true
			task.delay(2.7, function() -- Line 62
				--[[ Upvalues[1]:
					[1]: v_upvr (readonly)
				]]
				v_upvr.TimeScale = 0.35
				v_upvr.Enabled = false
			end)
		end
	end
	local var23_upvw = false
	task.delay(2.7, function() -- Line 70
		--[[ Upvalues[3]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: clone_2_upvr (readonly)
			[3]: var23_upvw (read and write)
		]]
		TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(9), {
			Volume = 1;
		}):Play()
		var23_upvw = true
	end)
	for _, v_2_upvr in arg1:FindFirstChild("Greatsword").FireVfxUlt:GetChildren() do
		if v_2_upvr:IsA("ParticleEmitter") or v_2_upvr:IsA("Trail") then
			v_2_upvr.Enabled = true
			task.delay(module_upvr.ModeLength, function() -- Line 78
				--[[ Upvalues[1]:
					[1]: v_2_upvr (readonly)
				]]
				v_2_upvr.Enabled = false
			end)
		elseif v_2_upvr:IsA("Sound") then
			v_2_upvr:Play()
			task.delay(module_upvr.ModeLength, function() -- Line 83
				--[[ Upvalues[1]:
					[1]: v_2_upvr (readonly)
				]]
				v_2_upvr:Stop()
			end)
		end
	end
	clone_2_upvr.Volume = 2.2
	TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(2), {
		Volume = 1.5;
	}):Play()
	var2_upvw.impactFrame2(arg1)
	var2_upvw.impactFrame(arg1)
	var2_upvw.changeFov(arg1, 45, 0.01, 0.6)
	var2_upvw.Blur(arg1, 20, 0.2)
	var2_upvw.camShake(arg1, "Explosion")
	for i_3, v_3 in var2_upvw.findEnemiesMagnitude(HumanoidRootPart.Position, 150, true), nil do
		var2_upvw.impactFrame2(arg1)
		var2_upvw.impactFrame(arg1)
		var2_upvw.changeFov(arg1, 45, 0.01, 0.6)
		var2_upvw.Blur(arg1, 20, 0.2)
		var2_upvw.camShake(arg1, "Explosion")
	end
	repeat
		task.wait(0.1)
		var2_upvw.camShake(arg1, "Bump")
		i_3 = 0.05
		var2_upvw.Blur(arg1, 30, i_3)
		i_3 = 1.6
		v_3 = 0.8
		var2_upvw.CreateDebris(HumanoidRootPart.Position, 2, i_3, v_3, 0.4)
		i_3 = true
		i_3 = nil
		for _, v_4 in var2_upvw.findEnemiesMagnitude(HumanoidRootPart.Position, 150, i_3), nil, i_3 do
			var2_upvw.camShake(v_4, "Bump")
		end
	until var23_upvw == true
end
return module_upvr
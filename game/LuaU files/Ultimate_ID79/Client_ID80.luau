-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:08
-- Luau version 6, Types version 3
-- Time taken: 0.005916 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
local RunService_upvr = game:GetService("RunService")
local TweenService_upvr = game:GetService("TweenService")
function module.Script(arg1, arg2) -- Line 11
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: RunService_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Ultimate = ReplicatedStorage_upvr.Skills["Titans Edge"].Ultimate
	game.Lighting.ClockTime = 0
	game.Lighting.Brightness = 0
	for _, v_upvr in game.Lighting:GetChildren() do
		task.delay(0.1, function() -- Line 27
			--[[ Upvalues[1]:
				[1]: v_upvr (readonly)
			]]
			v_upvr:Destroy()
		end)
	end
	for _, v_2 in Ultimate.Lighting:GetChildren() do
		v_2:Clone().Parent = game.Lighting
	end
	local var18_upvw = 15
	local clone_upvr = ReplicatedStorage_upvr.CutsceneCamera:Clone()
	clone_upvr.Parent = arg1
	clone_upvr.CFrame = (arg1.Head.CFrame + arg1.Head.CFrame.LookVector * var18_upvw) * CFrame.Angles(0, math.pi, 0)
	clone_upvr.Anchored = true
	game.Debris:AddItem(clone_upvr, 4)
	task.spawn(function() -- Line 45
		--[[ Upvalues[1]:
			[1]: var18_upvw (read and write)
		]]
		var18_upvw -= 3
		task.wait(0.25)
		var18_upvw -= 3
		task.wait(0.25)
		var18_upvw -= 3
		task.wait(0.25)
	end)
	local var22_upvw
	var22_upvw = var3_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 53
		--[[ Upvalues[5]:
			[1]: clone_upvr (readonly)
			[2]: var22_upvw (read and write)
			[3]: TweenService_upvr (copied, readonly)
			[4]: arg1 (readonly)
			[5]: var18_upvw (read and write)
		]]
		if not clone_upvr.Parent then
			var22_upvw:Disconnect()
		else
			TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.5), {
				CFrame = (arg1.Head.CFrame + arg1.Head.CFrame.LookVector * var18_upvw) * CFrame.Angles(0, math.pi, 0);
			}):Play()
		end
	end), 60)
	local clone_upvr_2 = Ultimate.CoverVFX:Clone()
	clone_upvr_2.Parent = arg1
	clone_upvr_2.weld.Part0 = clone_upvr
	clone_upvr_2.weld.Part1 = clone_upvr_2
	var3_upvw.applyDebris(clone_upvr_2, 10)
	local clone = Ultimate.CoverVFX2:Clone()
	clone.Parent = arg1
	clone.weld.Part0 = arg1:FindFirstChild("HumanoidRootPart")
	clone.weld.Part1 = clone
	var3_upvw.applyDebris(clone, 10)
	task.delay(0.35, function() -- Line 72
		--[[ Upvalues[1]:
			[1]: clone_upvr_2 (readonly)
		]]
		for _, v_3 in clone_upvr_2:GetChildren() do
			if v_3:IsA("ParticleEmitter") then
				v_3.Enabled = false
			end
		end
	end)
	var3_upvw.flashScreen(arg1, Color3.new(0, 0, 0), 4)
	TweenService_upvr:Create(game.Lighting, TweenInfo.new(4), {
		Brightness = 5;
	}):Play()
	task.wait(4)
	clone:Destroy()
	var3_upvw.ResetLighting(true, true)
	var3_upvw.flashScreen(arg1, Color3.new(0, 0, 0), 1)
	TweenService_upvr:Create(game.Lighting, TweenInfo.new(0), {
		Brightness = 5;
	}):Play()
	task.wait()
	TweenService_upvr:Create(game.Lighting, TweenInfo.new(2), {
		Brightness = 3;
	}):Play()
end
return module
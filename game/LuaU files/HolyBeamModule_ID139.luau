-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:42
-- Luau version 6, Types version 3
-- Time taken: 0.010207 seconds

local module_upvr = {
	Cooldown = 100;
	GlobalCD = 1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: module_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 20)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Holy_Beam_upvr = ReplicatedStorage_upvr.Skills["Earth Hammer"].Ultimate["Holy Beam"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Holy_Beam_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	local var17_upvw
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("charge"):Connect(function() -- Line 34
		--[[ Upvalues[4]:
			[1]: var17_upvw (read and write)
			[2]: Holy_Beam_upvr (readonly)
			[3]: arg1 (readonly)
			[4]: var2_upvw (copied, read and write)
		]]
		var17_upvw = Holy_Beam_upvr.BeamBall.BeamChargeVFX:Clone()
		var17_upvw.Parent = arg1["Left Arm"]
		var17_upvw.Flow:Play()
		for _, v in var17_upvw:GetChildren() do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end
		end
		var2_upvw.applyDebris(var17_upvw, 5)
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("pause"):Connect(function() -- Line 46
		--[[ Upvalues[1]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
		]]
		any_LoadAnimation_result1_upvr:AdjustSpeed(0)
	end), module_upvr.Cooldown)
	local clone_5 = Holy_Beam_upvr.Sfx:Clone()
	clone_5.Parent = HumanoidRootPart
	clone_5:Play()
	var2_upvw.applyStatus(arg1, "Stunned", 6.2)
	var2_upvw.applyStatus(arg1, "IFrames", 6.2)
	task.wait(4.58)
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	task.wait(0.42)
	var17_upvw.Flow:Stop()
	for _, v_2 in var17_upvw:GetChildren() do
		if v_2:IsA("ParticleEmitter") then
			v_2.Enabled = false
		end
	end
	local clone = Holy_Beam_upvr.BeamBall.BeamReleaseVFX:Clone()
	clone.Parent = HumanoidRootPart
	var2_upvw.EmitAllDescendants(clone)
	var2_upvw.applyDebris(clone, 5)
	local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 100, Vector3.new(0, -1000, 0), var2_upvw.raycastParams)
	if workspace_Raycast_result1 then
		for _, v_3 in workspace.WorldInfo.Live:GetChildren() do
			var2_upvw.camShake(v_3, "Explosion")
			var2_upvw.impactFrame2(v_3)
		end
		local clone_2 = Holy_Beam_upvr.Beam:Clone()
		clone_2.Parent = Folder
		clone_2.Position = workspace_Raycast_result1.Position
		TweenService_upvr:Create(clone_2, TweenInfo.new(12), {
			Size = Vector3.new(2000, 182, 182);
		}):Play()
		clone_5.Parent = clone_2
		clone_5.Volume = 9
		repeat
			task.wait(0.15)
			if clone_2.Parent then
				for _, v_4 in workspace.WorldInfo.Live:GetChildren() do
					var2_upvw.camShake(v_4, "Bump")
				end
				local clone_4 = Holy_Beam_upvr.BeamSide:Clone()
				clone_4.Parent = Folder
				clone_4.Position = workspace_Raycast_result1.Position + Vector3.new(0, -25, 0)
				TweenService_upvr:Create(clone_4, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
					Position = clone_4.Position + Vector3.new(0, 1000, 0);
				}):Play()
				var2_upvw.applyDebris(clone_4, 1.5)
				local clone_3 = Holy_Beam_upvr.Ring:Clone()
				clone_3.Parent = Folder
				clone_3.Position = workspace_Raycast_result1.Position
				TweenService_upvr:Create(clone_3, TweenInfo.new(1.5), {
					Size = Vector3.new(500, 2, 500);
					Transparency = 1;
				}):Play()
				var2_upvw.applyDebris(clone_3, 1.5)
				for _, v_5 in var2_upvw.findEnemiesPart(clone_2, true), nil do
					var2_upvw.CheckBlock(v_5, true)
					var2_upvw.applyDamage(v_5, 1)
					var2_upvw.applyStatus(v_5, "Ragdoll", 0.5)
					var2_upvw.flashScreen(v_5, Color3.new(0.584314, 0.584314, 0.584314), 0.2)
					v_5:SetAttribute("Mana", 0)
				end
			end
		until not clone_2.Parent
	end
end
return module_upvr
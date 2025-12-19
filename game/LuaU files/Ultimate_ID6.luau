-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:52
-- Luau version 6, Types version 3
-- Time taken: 0.017571 seconds

local module_upvr = {
	GlobalCD = 3.5;
	ModeLength = 92;
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
	game.Debris:AddItem(Folder, 20)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills["Basic Sword"].Ultimate
	local Basic_Sword_upvr = arg1:FindFirstChild("Basic Sword")
	local any_LoadAnimation_result1 = Humanoid.Animator:LoadAnimation(Ultimate_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.cameraCutscene(arg1, "Sword")
	var2_upvw.applyStatus(arg1, "Freeze", 9.5)
	var2_upvw.applyStatus(arg1, "GlobalCD", 9.5)
	var2_upvw.applyStatus(arg1, "AutoRotate", 9.5)
	var2_upvw.applyStatus(arg1, "IFrames", 9.5)
	var2_upvw.applyStatus(arg1, "Ultimate", 9.5)
	var2_upvw.applyStatus(arg1, "LockUltimateMeter", module_upvr.ModeLength)
	local clone_3_upvr = Ultimate_upvr.VFX.Aura:Clone()
	clone_3_upvr.Parent = arg1.Torso
	var2_upvw.applyDebris(clone_3_upvr, module_upvr.ModeLength + 3)
	local clone_5_upvr = Ultimate_upvr.NeonHand:Clone()
	clone_5_upvr.Parent = arg1
	clone_5_upvr.Weld.Part0 = arg1["Right Arm"]
	clone_5_upvr.Weld.Part1 = clone_5_upvr
	var2_upvw.applyDebris(clone_5_upvr, module_upvr.ModeLength + 3)
	Humanoid.Health = Humanoid.MaxHealth
	var2_upvw.changeFov(arg1, 50, 0, 1)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 59
		--[[ Upvalues[3]:
			[1]: Ultimate_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
		]]
		for _, v in Ultimate_upvr:GetChildren() do
			if v.Name == arg1_2 then
				local clone = v:Clone()
				clone.Parent = HumanoidRootPart_upvr
				clone:Play()
				var2_upvw.applyDebris(clone, clone.TimeLength * clone.PlaybackSpeed + 1)
			end
		end
	end), 60)
	Basic_Sword_upvr.Sword.Transparency = 1
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("glow"):Connect(function() -- Line 71
		--[[ Upvalues[1]:
			[1]: Basic_Sword_upvr (readonly)
		]]
		Basic_Sword_upvr.Neon.Transparency = 0
		for _, v_2 in Basic_Sword_upvr.Neon:GetDescendants() do
			if v_2:IsA("ParticleEmitter") then
				v_2.Enabled = true
			end
		end
	end), 60)
	local any_applyVFX_result1_upvr = var2_upvw.applyVFX(Ultimate_upvr.VFX.GlowVFX, arg1.Torso, 12)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("pull"):Connect(function() -- Line 79
		--[[ Upvalues[5]:
			[1]: any_applyVFX_result1_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: Ultimate_upvr (readonly)
			[4]: arg1 (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
		]]
		any_applyVFX_result1_upvr.decay.Enabled = false
		any_applyVFX_result1_upvr.whitedecay.Enabled = false
		var2_upvw.applyVFX(Ultimate_upvr.VFX.PullVFX, arg1.Torso, 5)
		var2_upvw.crater(1, HumanoidRootPart_upvr.Position, 3.5, 1.25)
		var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position + Vector3.new(0, -2.5, 0), 10, 1, 0.6, 0.1)
		var2_upvw.changeFov(arg1, 90, 0.05, 5)
	end), 60)
	local clone_2_upvr = Ultimate_upvr.DecayingSword:Clone()
	clone_2_upvr.Parent = arg1
	clone_2_upvr.weld.Part0 = arg1["Right Arm"]
	clone_2_upvr.weld.Part1 = clone_2_upvr
	clone_2_upvr.Sword.Transparency = 0
	task.delay(0.25, function() -- Line 95
		--[[ Upvalues[5]:
			[1]: any_applyVFX_result1_upvr (readonly)
			[2]: TweenService_upvr (copied, readonly)
			[3]: clone_2_upvr (readonly)
			[4]: clone_5_upvr (readonly)
			[5]: clone_3_upvr (readonly)
		]]
		any_applyVFX_result1_upvr.decay.Enabled = true
		TweenService_upvr:Create(clone_2_upvr.Sword, TweenInfo.new(1), {
			Transparency = 1;
		}):Play()
		TweenService_upvr:Create(clone_2_upvr.Neon, TweenInfo.new(1), {
			Transparency = 0;
		}):Play()
		for _, v_3 in clone_2_upvr.Sword:GetDescendants() do
			if v_3:IsA("ParticleEmitter") then
				v_3.Enabled = true
			end
		end
		task.wait(1.2)
		TweenService_upvr:Create(clone_2_upvr.Neon, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Transparency = 1;
		}):Play()
		task.wait(0.5)
		for _, v_4 in clone_2_upvr.Sword:GetDescendants() do
			if v_4:IsA("ParticleEmitter") then
				v_4.Enabled = false
			end
		end
		any_applyVFX_result1_upvr.decay.Enabled = false
		any_applyVFX_result1_upvr.whitedecay.Enabled = true
		task.wait(0.5)
		TweenService_upvr:Create(clone_5_upvr, TweenInfo.new(1), {
			Transparency = 0;
		}):Play()
		for _, v_5 in clone_3_upvr:GetChildren() do
			v_5.Enabled = true
		end
		task.wait(0.5)
		clone_5_upvr.FireArmVFX.aura.Enabled = true
	end)
	local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity.MaxForce = Vector3.new(1000000, 0, 1000000)
	BodyVelocity.Velocity = Vector3.new(0, 0, 0)
	var2_upvw.applyDebris(BodyVelocity, 4)
	local clone_4_upvr = Ultimate_upvr.ThemeSong:Clone()
	clone_4_upvr.Parent = HumanoidRootPart_upvr
	clone_4_upvr:Play()
	clone_4_upvr.Volume += 2.5
	clone_4_upvr:SetAttribute("ogVolume", clone_4_upvr.Volume - 2.5)
	task.delay(10, function() -- Line 134
		--[[ Upvalues[2]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: clone_4_upvr (readonly)
		]]
		TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(10), {
			Volume = clone_4_upvr:GetAttribute("ogVolume");
		}):Play()
	end)
	task.delay(module_upvr.ModeLength, function() -- Line 138
		--[[ Upvalues[5]:
			[1]: Basic_Sword_upvr (readonly)
			[2]: clone_5_upvr (readonly)
			[3]: TweenService_upvr (copied, readonly)
			[4]: clone_4_upvr (readonly)
			[5]: clone_3_upvr (readonly)
		]]
		for _, v_6 in Basic_Sword_upvr.Neon:GetDescendants() do
			if v_6:IsA("ParticleEmitter") then
				v_6.Enabled = false
			end
		end
		clone_5_upvr.FireArmVFX.aura.Enabled = false
		TweenService_upvr:Create(clone_5_upvr, TweenInfo.new(1.5), {
			Transparency = 1;
		}):Play()
		TweenService_upvr:Create(Basic_Sword_upvr.Sword, TweenInfo.new(1), {
			Transparency = 0;
		}):Play()
		TweenService_upvr:Create(Basic_Sword_upvr.Neon, TweenInfo.new(1), {
			Transparency = 1;
		}):Play()
		TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(1), {
			Volume = 0;
		}):Play()
		for _, v_7 in clone_3_upvr:GetChildren() do
			v_7.Enabled = false
		end
	end)
end
return module_upvr
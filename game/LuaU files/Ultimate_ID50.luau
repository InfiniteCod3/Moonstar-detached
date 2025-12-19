-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:41
-- Luau version 6, Types version 3
-- Time taken: 0.014531 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
if script.Parent.Parent:IsA("ModuleScript") then
	var3_upvw = require(script.Parent.Parent)
end
module_upvr.ModeLength = 105
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: module_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 20)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Mode_upvr = ReplicatedStorage_upvr.Skills.Hallow.Mode
	local Hallow_upvr = arg1:FindFirstChild("Hallow")
	var3_upvw.flashScreen(arg1, Color3.new(0, 0, 0), 1)
	local clone = Mode_upvr.Theme:Clone()
	clone.Parent = HumanoidRootPart_upvr
	clone:Play()
	var3_upvw.applyDebris(clone, module_upvr.ModeLength + 10)
	var3_upvw.applyStatus(arg1, "Stunned", 4.85)
	var3_upvw.applyStatus(arg1, "Ultimate", 4.85)
	var3_upvw.applyStatus(arg1, "AutoRotate", 4.85)
	var3_upvw.applyStatus(arg1, "IFrames", 4.85)
	var3_upvw.changeFov(arg1, 50, 1.65, 0.5)
	Humanoid.Health = Humanoid.MaxHealth
	wait(1.65)
	local any_LoadAnimation_result1 = Humanoid:LoadAnimation(Mode_upvr.Animation)
	any_LoadAnimation_result1:Play(0)
	var3_upvw.applySound(Mode_upvr.ModeSFX, HumanoidRootPart_upvr, 6)
	var3_upvw.applySound(Mode_upvr.Swoosh, HumanoidRootPart_upvr, 6)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Switch"):Once(function() -- Line 57
		--[[ Upvalues[6]:
			[1]: var3_upvw (copied, read and write)
			[2]: Mode_upvr (readonly)
			[3]: arg1 (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: Hallow_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
		]]
		var3_upvw.applyVFX(Mode_upvr.ModeEmit, arg1.Torso, 5)
		var3_upvw.ChangeEnviorment(arg1, "Hallow")
		var3_upvw.applySound(Mode_upvr.SwitchSFX, HumanoidRootPart_upvr, 6)
		delay(0.7, function() -- Line 62
			--[[ Upvalues[3]:
				[1]: var3_upvw (copied, read and write)
				[2]: Mode_upvr (copied, readonly)
				[3]: HumanoidRootPart_upvr (copied, readonly)
			]]
			var3_upvw.applySound(Mode_upvr.Swoosh, HumanoidRootPart_upvr, 6)
		end)
		var3_upvw.flashScreen(arg1, Color3.new(0.0980392, 1, 0.670588), 0.5)
		var3_upvw.changeFov(arg1, 70, 0, 1)
		for _, v in Hallow_upvr.BodyVFX:GetChildren() do
			if v:IsA("ParticleEmitter") or v:IsA("PointLight") then
				v.Enabled = false
			end
		end
		for _, v_2 in Hallow_upvr["BodyVFX(Mode)"]:GetDescendants() do
			if v_2:IsA("ParticleEmitter") or v_2:IsA("PointLight") then
				v_2.Enabled = true
			end
		end
		for _, v_3 in Hallow_upvr.BaseTrails:GetChildren() do
			v_3.Name = "SkillTrail"
			v_3.Enabled = false
		end
		for _, v_4 in Hallow_upvr.ModeTrails:GetChildren() do
			v_4.Name = "Trail"
			v_4.Enabled = false
		end
		for _, v_5 in Hallow_upvr["BodyVFX(Mode)"]:GetChildren() do
			if v_5:IsA("ParticleEmitter") or v_5:IsA("PointLight") then
				v_5.Enabled = true
			end
		end
		TweenService_upvr:Create(Hallow_upvr.Handle, TweenInfo.new(1.1), {
			Transparency = 1;
		}):Play()
		TweenService_upvr:Create(Hallow_upvr["Handle(Mode)"], TweenInfo.new(1.1), {
			Transparency = 0;
		}):Play()
	end), 3)
	local var41_upvw
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("land"):Once(function() -- Line 102
		--[[ Upvalues[6]:
			[1]: var3_upvw (copied, read and write)
			[2]: Mode_upvr (readonly)
			[3]: arg1 (readonly)
			[4]: var41_upvw (read and write)
			[5]: module_upvr (copied, readonly)
			[6]: HumanoidRootPart_upvr (readonly)
		]]
		var3_upvw.applyVFX(Mode_upvr.ModeEmit, arg1.Torso, 5)
		var41_upvw = var3_upvw.cloneInstance(Mode_upvr.ModeAura, arg1, module_upvr.ModeLength + 10)
		var41_upvw.Parent = arg1.Torso
		var3_upvw.applySound(Mode_upvr.LandSFX, HumanoidRootPart_upvr, 6)
		var3_upvw.changeFov(arg1, 70, 0, 1)
	end), 3)
	local hitVFX_upvr = Hallow_upvr.hitVFX
	local hitVFX_Mode__upvr = Hallow_upvr["hitVFX(Mode)"]
	hitVFX_upvr.Name = "BaseVFX"
	hitVFX_Mode__upvr.Name = "hitVFX"
	delay(module_upvr.ModeLength, function() -- Line 118
		--[[ Upvalues[7]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: hitVFX_upvr (readonly)
			[4]: hitVFX_Mode__upvr (readonly)
			[5]: var41_upvw (read and write)
			[6]: Hallow_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
		]]
		var3_upvw.ChangeEnviorment(arg1, "Normal")
		hitVFX_upvr.Name = "hitVFX"
		hitVFX_Mode__upvr.Name = "hitVFX(Mode)"
		for _, v_6 in var41_upvw:GetDescendants() do
			if v_6:IsA("ParticleEmitter") then
				v_6.Enabled = false
			end
		end
		for _, v_7 in Hallow_upvr.BodyVFX:GetChildren() do
			if v_7:IsA("ParticleEmitter") or v_7:IsA("PointLight") then
				v_7.Enabled = true
			end
		end
		for _, v_8 in Hallow_upvr["BodyVFX(Mode)"]:GetDescendants() do
			if v_8:IsA("ParticleEmitter") or v_8:IsA("PointLight") then
				v_8.Enabled = false
			end
		end
		for _, v_9 in Hallow_upvr.BaseTrails:GetChildren() do
			v_9.Name = "Trail"
			v_9.Enabled = false
		end
		for _, v_10 in Hallow_upvr.ModeTrails:GetChildren() do
			v_10.Name = "SkillTrail"
			v_10.Enabled = false
		end
		TweenService_upvr:Create(Hallow_upvr.Handle, TweenInfo.new(0.5), {
			Transparency = 0;
		}):Play()
		TweenService_upvr:Create(Hallow_upvr["Handle(Mode)"], TweenInfo.new(0.5), {
			Transparency = 1;
		}):Play()
	end)
end
return module_upvr
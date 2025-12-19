-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:52
-- Luau version 6, Types version 3
-- Time taken: 0.016500 seconds

local module_upvr = {}
local var2_upvw
if script.Parent.Parent:IsA("ModuleScript") then
	var2_upvw = require(script.Parent.Parent)
end
module_upvr.ModeLength = 60
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[5]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: module_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 20)
	local HumanoidRootPart = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Ultimate = ReplicatedStorage_upvr.Skills["Fire Fists"].Ultimate
	local any_LoadAnimation_result1 = Humanoid.Animator:LoadAnimation(Ultimate.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(1)
	local clone = Ultimate.BodyMove:Clone()
	clone.Parent = HumanoidRootPart
	clone:Play()
	var2_upvw.applyDebris(clone, 5)
	var2_upvw.applyStatus(arg1, "Stunned", 6)
	var2_upvw.applyStatus(arg1, "IFrames", 6)
	var2_upvw.applyStatus(arg1, "AutoRotate", 6)
	var2_upvw.applyStatus(arg1, "Ultimate", 6)
	local clone_4 = Ultimate.FireFistsTheme:Clone()
	clone_4.Parent = HumanoidRootPart
	var2_upvw.applyDebris(clone_4, clone_4.TimeLength)
	clone_4:Play()
	local tbl_upvr = {}
	task.delay(module_upvr.ModeLength, function() -- Line 49
		--[[ Upvalues[3]:
			[1]: tbl_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: TweenService_upvr (copied, readonly)
		]]
		for _, v in tbl_upvr do
			var2_upvw.applyDebris(v, 5)
			if v:IsA("BasePart") then
				TweenService_upvr:Create(v, TweenInfo.new(1), {
					Transparency = 1;
				}):Play()
			end
			for _, v_2 in v:GetDescendants() do
				if v_2:IsA("ParticleEmitter") then
					v_2.Enabled = false
				elseif v_2:IsA("Sound") then
					TweenService_upvr:Create(v_2, TweenInfo.new(1), {
						Volume = 0;
					}):Play()
				end
			end
		end
	end)
	task.wait(0.5)
	Humanoid.Health = Humanoid.MaxHealth
	local clone_5_upvr = ReplicatedStorage_upvr.CutsceneCamera:Clone()
	clone_5_upvr.Parent = arg1
	clone_5_upvr.CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 5 + Vector3.new(0, 3, 0)
	clone_5_upvr.CFrame = CFrame.lookAt(clone_5_upvr.Position, arg1.Head.Position)
	clone_5_upvr.Anchored = true
	local var34_upvw
	local var35_upvw = "HeadFocus"
	var34_upvw = RunService_upvr.Stepped:Connect(function() -- Line 80
		--[[ Upvalues[4]:
			[1]: clone_5_upvr (readonly)
			[2]: var34_upvw (read and write)
			[3]: var35_upvw (read and write)
			[4]: arg1 (readonly)
		]]
		if not clone_5_upvr.Parent then
			var34_upvw:Disconnect()
		else
			if var35_upvw == "HeadFocus" then
				clone_5_upvr.CFrame += clone_5_upvr.CFrame.LookVector * -0.1
				clone_5_upvr.CFrame = CFrame.lookAt(clone_5_upvr.Position, arg1.Head.Position)
				return
			end
			if var35_upvw == "BeamFocus" then
				clone_5_upvr.CFrame = clone_5_upvr.CFrame + clone_5_upvr.CFrame.LookVector * -2 + Vector3.new(0, 1, 0)
				clone_5_upvr.CFrame = CFrame.lookAt(clone_5_upvr.Position, arg1.Head.Position + Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15)))
				return
			end
			if var35_upvw == "SlowBeamFocus" then
				clone_5_upvr.CFrame = clone_5_upvr.CFrame + clone_5_upvr.CFrame.LookVector * -0.5 + Vector3.new(0, 0.25, 0)
				clone_5_upvr.CFrame = CFrame.lookAt(clone_5_upvr.Position, arg1.Head.Position + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5)))
			end
		end
	end)
	local clone_3_upvr = Ultimate.FireBeam:Clone()
	clone_3_upvr.Parent = Folder
	clone_3_upvr.PlayerWeld.Part0 = HumanoidRootPart
	clone_3_upvr.PlayerWeld.Part1 = clone_3_upvr
	clone_3_upvr.BeamStart:Play()
	var2_upvw.applyDebris(clone_3_upvr, 8)
	task.delay(0.2, function() -- Line 107
		--[[ Upvalues[3]:
			[1]: var2_upvw (copied, read and write)
			[2]: clone_3_upvr (readonly)
			[3]: arg1 (readonly)
		]]
		var2_upvw.applyDebris(clone_3_upvr.Glare, 0)
		local clone_2 = clone_3_upvr.Glare:Clone()
		clone_2.Parent = arg1.Head
		var2_upvw.EmitAllDescendants(clone_2)
		var2_upvw.applyDebris(clone_2, 5)
		var2_upvw.flashScreen(arg1, Color3.new(0, 0, 0), 1)
		var2_upvw.changeFov(arg1, 25, 0.01, 1)
	end)
	for _, v_3_upvr in clone_3_upvr:GetDescendants() do
		if v_3_upvr:IsA("Beam") then
			v_3_upvr.Width0 = 0
			v_3_upvr.Width1 = 0
			v_3_upvr.CurveSize0 = 0
			v_3_upvr.CurveSize1 = 0
			local Width0_upvr = v_3_upvr.Width0
			local Width1_upvr = v_3_upvr.Width1
			local CurveSize0_upvr = v_3_upvr.CurveSize0
			local CurveSize1_upvr = v_3_upvr.CurveSize1
			task.delay(1, function() -- Line 122
				--[[ Upvalues[6]:
					[1]: TweenService_upvr (copied, readonly)
					[2]: v_3_upvr (readonly)
					[3]: Width0_upvr (readonly)
					[4]: Width1_upvr (readonly)
					[5]: CurveSize0_upvr (readonly)
					[6]: CurveSize1_upvr (readonly)
				]]
				TweenService_upvr:Create(v_3_upvr, TweenInfo.new(1), {
					Width0 = Width0_upvr;
					Width1 = Width1_upvr;
					CurveSize0 = CurveSize0_upvr;
					CurveSize1 = CurveSize1_upvr;
				}):Play()
			end)
		else
			CurveSize0_upvr = "ParticleEmitter"
			Width0_upvr = v_3_upvr:IsA(CurveSize0_upvr)
			if Width0_upvr then
				Width0_upvr = false
				v_3_upvr.Enabled = Width0_upvr
				Width0_upvr = task.delay
				Width1_upvr = 1
				function CurveSize0_upvr() -- Line 127
					--[[ Upvalues[1]:
						[1]: v_3_upvr (readonly)
					]]
					v_3_upvr.Enabled = true
				end
				Width0_upvr(Width1_upvr, CurveSize0_upvr)
			end
		end
	end
	task.wait(1)
	var2_upvw.impactFrame2(arg1)
	var2_upvw.impactFrame(arg1)
	var2_upvw.changeFov(arg1, 30, 0.01, 0.25)
	Width0_upvr = 0.160784
	var2_upvw.flashScreen(arg1, Color3.new(1, 0.537255, Width0_upvr), 2.5)
	local Equalizer = clone_4:FindFirstChild("Equalizer")
	if not Equalizer then
		Equalizer = clone_4:WaitForChild("Equalizer")
	end
	Equalizer.HighGain = 0
	Equalizer.MidGain = 0
	var35_upvw = "BeamFocus"
	task.delay(0.5, function() -- Line 145
		--[[ Upvalues[1]:
			[1]: var35_upvw (read and write)
		]]
		var35_upvw = "SlowBeamFocus"
	end)
	clone_3_upvr.FireBurst:Play()
	clone_3_upvr.FireBurn:Play()
	task.wait(3)
	for _, v_4 in clone_3_upvr:GetDescendants() do
		CurveSize1_upvr = "Beam"
		Width1_upvr = v_4:IsA(CurveSize1_upvr)
		if Width1_upvr then
			Width1_upvr = TweenService_upvr
			CurveSize1_upvr = v_4
			local _ = {
				Width0 = 0;
				Width1 = 0;
				CurveSize0 = 0;
				CurveSize1 = 0;
			}
			Width1_upvr = Width1_upvr:Create(CurveSize1_upvr, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), _):Play
			Width1_upvr()
		else
			CurveSize1_upvr = "ParticleEmitter"
			Width1_upvr = v_4:IsA(CurveSize1_upvr)
			if Width1_upvr then
				Width1_upvr = false
				v_4.Enabled = Width1_upvr
			end
		end
	end
	var2_upvw.applyDebris(clone_3_upvr, 5)
	Width1_upvr = Enum.EasingStyle.Linear
	local tbl = {}
	Width1_upvr = 0
	tbl.Volume = Width1_upvr
	TweenService_upvr:Create(clone_3_upvr.FireBurn, TweenInfo.new(3.5, Width1_upvr), tbl):Play()
	local function FirePart(arg1_2) -- Line 162
		--[[ Upvalues[2]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: tbl_upvr (readonly)
		]]
		local var60
		if arg1_2.Name == "Head" then
			var60 = ReplicatedStorage_upvr.Skills["Fire Fists"].FireHead:Clone()
		elseif arg1_2.Name == "Torso" then
			var60 = ReplicatedStorage_upvr.Skills["Fire Fists"].FireTorso:Clone()
		else
			var60 = ReplicatedStorage_upvr.Skills["Fire Fists"].FireFist:Clone()
		end
		table.insert(tbl_upvr, var60)
		var60.Parent = arg1_2
		var60.Weld.Part0 = arg1_2
		var60.Weld.Part1 = var60
		local FireArmVFX = var60.FireArmVFX
		FireArmVFX.Parent = var60
		for _, v_5 in FireArmVFX:GetChildren() do
			if v_5:IsA("ParticleEmitter") then
				v_5.Enabled = true
			elseif v_5:IsA("Sound") then
				v_5:Play()
			end
		end
	end
	FirePart(arg1.Torso)
	FirePart(arg1["Left Leg"])
	FirePart(arg1["Right Leg"])
	FirePart(arg1.Head)
	task.wait(1)
	var2_upvw.applyDebris(clone_5_upvr, 0)
end
return module_upvr
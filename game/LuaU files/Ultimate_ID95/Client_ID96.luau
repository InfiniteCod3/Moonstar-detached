-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:02
-- Luau version 6, Types version 3
-- Time taken: 0.011820 seconds

local module = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
local RunService_upvr = game:GetService("RunService")
local TweenService_upvr = game:GetService("TweenService")
function module.Script(arg1, arg2) -- Line 14
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
		[3]: RunService_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Ultimate = ReplicatedStorage_upvr.Skills["Cyber Katana"].Ultimate
	var3_upvw.applyStatus(arg1, "Stunned", 4.2)
	var3_upvw.applyStatus(arg1, "AutoRotate", 4.2)
	task.spawn(function() -- Line 49
		--[[ Upvalues[1]:
			[1]: HumanoidRootPart_upvr (readonly)
		]]
		local CyberKatanaTheme = HumanoidRootPart_upvr:FindFirstChild("CyberKatanaTheme")
		if not CyberKatanaTheme then
			CyberKatanaTheme = HumanoidRootPart_upvr:WaitForChild("CyberKatanaTheme")
		end
		CyberKatanaTheme:Destroy()
	end)
	local clone_upvr_2 = Ultimate["Cutscene Assets"]:Clone()
	clone_upvr_2.Parent = arg1
	for _, v in clone_upvr_2:GetDescendants() do
		if v.Name == "weld" then
			v.Part0 = HumanoidRootPart_upvr
			v.Part1 = v.Parent
		end
	end
	local clone = Ultimate.CyberKatanaTheme:Clone()
	clone.Volume = 0.25
	clone.Parent = arg1
	clone:Play()
	game.Debris:AddItem(clone, 100)
	task.wait()
	;(function(arg1_2) -- Line 29, Named "setupCamera"
		--[[ Upvalues[4]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: arg1 (readonly)
			[3]: var3_upvw (copied, read and write)
			[4]: RunService_upvr (copied, readonly)
		]]
		local CyberKatana_Ultimate_upvr = ReplicatedStorage_upvr.CutsceneCameraFrames["CyberKatana Ultimate"]
		local clone_upvr = ReplicatedStorage_upvr.CutsceneCamera:Clone()
		clone_upvr.Parent = arg1_2
		clone_upvr.Anchored = true
		clone_upvr.CFrame = arg1.HumanoidRootPart.CFrame * CyberKatana_Ultimate_upvr['0'].Value
		local var13_upvw = 0
		local var14_upvw
		var14_upvw = var3_upvw.conTimer(RunService_upvr.RenderStepped:Connect(function() -- Line 38
			--[[ Upvalues[5]:
				[1]: var13_upvw (read and write)
				[2]: CyberKatana_Ultimate_upvr (readonly)
				[3]: clone_upvr (readonly)
				[4]: arg1 (copied, readonly)
				[5]: var14_upvw (read and write)
			]]
			var13_upvw += 1
			if CyberKatana_Ultimate_upvr:FindFirstChild(var13_upvw) then
				clone_upvr.CFrame = arg1.HumanoidRootPart.CFrame * CyberKatana_Ultimate_upvr:FindFirstChild(var13_upvw).Value
			else
				clone_upvr:Destroy()
				var14_upvw:Disconnect()
			end
		end), 60)
	end)(arg1)
	local clone_upvr_3 = Ultimate.ScreenGui:Clone()
	clone_upvr_3.Parent = arg2.PlayerGui
	game.Debris:AddItem(clone_upvr_3, 8)
	task.delay(0.03, function() -- Line 84
		--[[ Upvalues[3]:
			[1]: HumanoidRootPart_upvr (readonly)
			[2]: TweenService_upvr (copied, readonly)
			[3]: clone_upvr_3 (readonly)
		]]
		HumanoidRootPart_upvr.CFrame += Vector3.new(0, 6000, 0)
		TweenService_upvr:Create(clone_upvr_3.Vignette, TweenInfo.new(1), {
			ImageTransparency = 0.75;
			ImageColor3 = Color3.fromRGB(209, 72, 72);
		}):Play()
		task.wait(0.12)
		TweenService_upvr:Create(clone_upvr_3.BlackFrame, TweenInfo.new(0.15), {
			BackgroundTransparency = 1;
		}):Play()
	end)
	local any_LoadAnimation_result1_upvr = arg1.Humanoid.Animator:LoadAnimation(Ultimate.Animation)
	any_LoadAnimation_result1_upvr:Play(0)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("trail"):Connect(function(arg1_3) -- Line 94
		--[[ Upvalues[1]:
			[1]: clone_upvr_2 (readonly)
		]]
		for _, v_2 in clone_upvr_2:GetDescendants() do
			if v_2:IsA("Trail") then
				if arg1_3 == "true" then
					v_2.Enabled = true
				elseif arg1_3 == "false" then
					v_2.Enabled = false
				end
			end
		end
	end), 60)
	local CFrame_upvr = HumanoidRootPart_upvr.CFrame
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 106
		--[[ Upvalues[6]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: clone_upvr_3 (readonly)
			[3]: clone_upvr_2 (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: CFrame_upvr (readonly)
			[6]: any_LoadAnimation_result1_upvr (readonly)
		]]
		TweenService_upvr:Create(clone_upvr_3.BlackFrame, TweenInfo.new(0.01), {
			BackgroundTransparency = 0;
		}):Play()
		task.delay(0.5, function() -- Line 108
			--[[ Upvalues[2]:
				[1]: TweenService_upvr (copied, readonly)
				[2]: clone_upvr_3 (copied, readonly)
			]]
			TweenService_upvr:Create(clone_upvr_3.Vignette, TweenInfo.new(1), {
				ImageTransparency = 1;
			}):Play()
			TweenService_upvr:Create(clone_upvr_3.BlackFrame, TweenInfo.new(1), {
				BackgroundTransparency = 1;
			}):Play()
		end)
		game.Debris:AddItem(clone_upvr_2, 0)
		HumanoidRootPart_upvr.CFrame = CFrame_upvr
		any_LoadAnimation_result1_upvr:Stop(0)
	end), 60)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 118
		--[[ Upvalues[2]:
			[1]: clone_upvr_2 (readonly)
			[2]: arg2 (readonly)
		]]
		game.Debris:AddItem(clone_upvr_2, 0)
		arg2.PlayerGui.Settings.Enabled = true
	end), 60)
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("eyes"):Connect(function() -- Line 126
		--[[ Upvalues[5]:
			[1]: clone_upvr_2 (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: TweenService_upvr (copied, readonly)
			[5]: clone_upvr_3 (readonly)
		]]
		for _, v_3 in clone_upvr_2.VFX:GetDescendants() do
			if v_3:IsA("ParticleEmitter") then
				if v_3.Enabled == false then
					var3_upvw.flashScreen(arg1, Color3.new(1, 0.207843, 0.207843), 1)
					TweenService_upvr:Create(clone_upvr_3.Vignette, TweenInfo.new(0.05), {
						ImageTransparency = 0.5;
					}):Play()
					var3_upvw.Blur(arg1, 30, 1)
					v_3.Enabled = true
				elseif v_3.Enabled == true then
					v_3.Enabled = false
				end
			end
		end
	end), 60)
end
return module
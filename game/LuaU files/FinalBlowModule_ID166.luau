-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:02
-- Luau version 6, Types version 3
-- Time taken: 0.007409 seconds

local module_upvr = {
	Cooldown = 15;
	GlobalCD = 1.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[4]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Final_Blow_upvr = ReplicatedStorage_upvr.Skills["Fire Fists"]["Final Blow"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Final_Blow_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(0.7)
	var2_upvw.applyStatus(arg1, "Freeze", 1.5)
	local clone_3 = Final_Blow_upvr.Whoosh:Clone()
	clone_3.Parent = HumanoidRootPart_upvr
	clone_3:Play()
	clone_3.TimePosition = 0.25
	clone_3.PlaybackSpeed = 1
	var2_upvw.applyDebris(clone_3, 5)
	var2_upvw.changeFov(arg1, 100, 0.8, 5)
	local clone_7 = Final_Blow_upvr["Flame Punch"]:Clone()
	clone_7.Parent = HumanoidRootPart_upvr
	clone_7:Play()
	var2_upvw.applyDebris(clone_7, 5)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("punch"):Connect(function() -- Line 50
		--[[ Upvalues[6]:
			[1]: Final_Blow_upvr (readonly)
			[2]: Folder_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var2_upvw (copied, read and write)
			[5]: TweenService_upvr (copied, readonly)
			[6]: arg1 (readonly)
		]]
		local clone_4_upvr = Final_Blow_upvr.FireFist:Clone()
		clone_4_upvr.Parent = Folder_upvr
		clone_4_upvr.Size = Vector3.new(3.5, 7, 3.5)
		clone_4_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.RightVector * math.random(-0, 0) + HumanoidRootPart_upvr.CFrame.UpVector * math.random(-0, 0)
		var2_upvw.applyDebris(clone_4_upvr, 0.36)
		TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(0.5), {
			CFrame = clone_4_upvr.CFrame + clone_4_upvr.CFrame.LookVector * 100;
			Size = Vector3.new(12, 12, 80);
		}):Play()
		task.delay(0.4, function() -- Line 59
			--[[ Upvalues[2]:
				[1]: TweenService_upvr (copied, readonly)
				[2]: clone_4_upvr (readonly)
			]]
			TweenService_upvr:Create(clone_4_upvr, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Transparency = 1;
			}):Play()
			for _, v in clone_4_upvr:GetDescendants() do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
		end)
		local clone_5 = Final_Blow_upvr["FlameM1(2)"]:Clone()
		clone_5.Parent = HumanoidRootPart_upvr
		clone_5:Play()
		var2_upvw.applyDebris(clone_5, 1.5)
		var2_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 8, 1, 0.5, 0.03)
		local Highlight = Instance.new("Highlight", clone_4_upvr)
		Highlight.OutlineColor = Color3.new(1, 0.372549, 0.0823529)
		Highlight.FillColor = Color3.new(1, 0.47451, 0.101961)
		Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		Highlight.FillTransparency = 0.6
		Highlight.OutlineTransparency = 0.5
		TweenService_upvr:Create(Highlight, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			OutlineTransparency = 1;
			FillTransparency = 1;
		}):Play()
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 40, 0.01, 0.45)
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.658824, 0.239216), 1.2)
		local clone_2 = Final_Blow_upvr.VFX.FireShockwave:Clone()
		clone_2.Parent = HumanoidRootPart_upvr
		var2_upvw.EmitAllDescendants(clone_2)
		var2_upvw.applyDebris(clone_2, 3)
		local tbl = {}
		for _ = 1, 16.666666666666668 do
			for _, v_2 in var2_upvw.findEnemiesPart(clone_4_upvr, true), nil do
				if not table.find(tbl, v_2) then
					table.insert(tbl, v_2)
					var2_upvw.applyDamage(v_2, 25)
					var2_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -50, 80, 10)
					var2_upvw.applyStatus(v_2, "Ragdoll", 1.75)
					var2_upvw.camShake(v_2, "Bump")
					var2_upvw.changeFov(v_2, 40, 0.01, 0.45)
					var2_upvw.flashScreen(v_2, Color3.new(1, 0.658824, 0.239216), 1.2)
					local clone = Final_Blow_upvr.FlameM1:Clone()
					clone.Parent = v_2.HumanoidRootPart
					clone:Play()
					var2_upvw.applyDebris(clone, 1.5)
					local clone_6 = Final_Blow_upvr.VFX.hitVFX:Clone()
					clone_6.Parent = v_2.HumanoidRootPart
					var2_upvw.EmitAllDescendants(clone_6)
					var2_upvw.applyDebris(clone, 2)
				end
			end
			task.wait()
		end
	end), module_upvr.Cooldown)
end
return module_upvr
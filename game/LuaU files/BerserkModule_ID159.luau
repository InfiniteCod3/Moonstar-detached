-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:55
-- Luau version 6, Types version 3
-- Time taken: 0.007477 seconds

local module_upvr = {
	Cooldown = 30;
	GlobalCD = 1.2;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 17
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
	local Berserk_upvr = ReplicatedStorage_upvr.Skills["Fire Fists"].Ultimate.Berserk
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Berserk_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(1)
	var2_upvw.applyStatus(arg1, "Freeze", 1.2)
	local clone_4 = Berserk_upvr.Hitbox:Clone()
	clone_4.Parent = Folder_upvr
	clone_4.weld.Part1 = clone_4
	clone_4.weld.Part0 = HumanoidRootPart_upvr
	var2_upvw.applyDebris(clone_4, 0.1)
	clone_4.Transparency = 1
	local clone = Berserk_upvr.Whoosh:Clone()
	clone.Parent = HumanoidRootPart_upvr
	clone:Play()
	clone.TimePosition = 0.25
	var2_upvw.applyDebris(clone, 5)
	var2_upvw.changeFov(arg1, 100, 0.3, 5)
	local var12_upvw = 0
	local var13_upvw
	local var14_upvw
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("punch"):Connect(function() -- Line 57
		--[[ Upvalues[10]:
			[1]: var12_upvw (read and write)
			[2]: any_LoadAnimation_result1_upvr (readonly)
			[3]: var13_upvw (read and write)
			[4]: Berserk_upvr (readonly)
			[5]: Folder_upvr (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: var2_upvw (copied, read and write)
			[8]: arg1 (readonly)
			[9]: var14_upvw (read and write)
			[10]: TweenService_upvr (copied, readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		var12_upvw += 1
		any_LoadAnimation_result1_upvr:AdjustSpeed(var12_upvw * 0.15 + 1)
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [274] 208. Error Block 20 start (CF ANALYSIS FAILED)
		var2_upvw.applyStatus(arg1, "IFrames", 0.8)
		var2_upvw.applyStatus(arg1, "Freeze", 0.8)
		var2_upvw.applyStatus(arg1, "GlobalCD", 0.8)
		-- KONSTANTERROR: [274] 208. Error Block 20 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [295] 226. Error Block 26 start (CF ANALYSIS FAILED)
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.flashScreen(arg1, Color3.new(1, 0.784314, 0.631373), 0.5)
		var2_upvw.changeFov(arg1, 60, 0.01, 0.5)
		if var13_upvw then
			local var15 = var13_upvw
			var2_upvw.Knockback(arg1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -100, 25)
			local clone_5 = Berserk_upvr.FlameM1:Clone()
			clone_5.Parent = var15.HumanoidRootPart
			clone_5:Play()
			clone_5.PlaybackSpeed += math.random(-1, 1) * 0.08
			var2_upvw.applyDebris(clone_5, 2)
			local clone_6 = Berserk_upvr.VFX.hitVFX:Clone()
			clone_6.Parent = var15.HumanoidRootPart
			var2_upvw.EmitAllDescendants(clone_6)
			var2_upvw.applyDebris(clone_6, 2)
			local clone_2_upvr = Berserk_upvr.FireFist:Clone()
			clone_2_upvr.Parent = Folder_upvr
			clone_2_upvr.Size = Vector3.new(3.5, 7, 3.5)
			clone_2_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.RightVector * math.random(-3, 3) + HumanoidRootPart_upvr.CFrame.UpVector * math.random(-3, 3)
			var2_upvw.applyDebris(clone_2_upvr, 0.36)
			TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.35), {
				CFrame = clone_2_upvr.CFrame + clone_2_upvr.CFrame.LookVector * 25;
				Size = Vector3.new(3.90000, 3.90000, 24);
			}):Play()
			TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Transparency = 1;
			}):Play()
			task.delay(0.35, function() -- Line 159
				--[[ Upvalues[1]:
					[1]: clone_2_upvr (readonly)
				]]
				for _, v in clone_2_upvr:GetDescendants() do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
			end)
			if var12_upvw == 26 then
				if var15.Humanoid.Health - 2 <= 0 then
					var14_upvw:Destroy()
					task.wait()
					var2_upvw.applyDamage(var15, 2, true)
				else
					var2_upvw.applyDamage(var15, 2, true, true)
					game.Debris:AddItem(var14_upvw, 0.45)
					var2_upvw.resetm1s()
				end
			end
			local clone_3 = Berserk_upvr.Whoosh:Clone()
			clone_3.Parent = HumanoidRootPart_upvr
			clone_3:Play()
			var2_upvw.applyDebris(clone_3, 5)
			var2_upvw.applyStatus(arg1, "IFrames", 0.25)
			var2_upvw.applyStatus(arg1, "Freeze", 0.7)
			var2_upvw.applyStatus(arg1, "GlobalCD", 0.25)
			var2_upvw.applyStatus(var15, "Stunned", 0.75)
			var2_upvw.applyStatus(var15, "AutoRotate", 0.75)
			var2_upvw.applyStatus(var15, "IFrames", 0.25)
			var2_upvw.applyDamage(var15, 2, true, true)
		end
		-- KONSTANTERROR: [295] 226. Error Block 26 end (CF ANALYSIS FAILED)
	end), 20)
end
return module_upvr
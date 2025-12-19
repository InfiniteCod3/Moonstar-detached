-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:16:50
-- Luau version 6, Types version 3
-- Time taken: 0.014143 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 22
module_upvr.GlobalCD = 0.8
local var3_upvw
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: PlayerStatus_upvr (readonly)
		[5]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local Kick_Combo_upvr = ReplicatedStorage_upvr.Skills.Kickboxer["Kick Combo"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Kick_Combo_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(0.98)
	var3_upvw.applyStatus(arg1, "Slowed", 0.8)
	local clone_8_upvr = Kick_Combo_upvr.Part.Sounds:Clone()
	clone_8_upvr.Parent = arg1.Torso
	game.Debris:AddItem(clone_8_upvr, 10)
	clone_8_upvr.BigWhoosh:Play()
	local function _(arg1_2) -- Line 41, Named "playSfx"
		--[[ Upvalues[1]:
			[1]: clone_8_upvr (readonly)
		]]
		local clone_4 = arg1_2:Clone()
		clone_4.PlaybackSpeed += math.random(-1, 1) * 0.05
		clone_4.Parent = clone_8_upvr
		clone_4:Play()
	end
	local var12_upvw = 0
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local var14_upvw
	local var15_upvw
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("hit"):Connect(function() -- Line 52
		--[[ Upvalues[12]:
			[1]: var12_upvw (read and write)
			[2]: var3_upvw (copied, read and write)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: PlayerStatus_upvr (copied, readonly)
			[5]: var14_upvw (read and write)
			[6]: arg1 (readonly)
			[7]: Kick_Combo_upvr (readonly)
			[8]: any_LoadAnimation_result1_upvr (readonly)
			[9]: var15_upvw (read and write)
			[10]: module_upvr (copied, readonly)
			[11]: TweenService_upvr (copied, readonly)
			[12]: clone_8_upvr (readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		var12_upvw += 1
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [26] 22. Error Block 33 start (CF ANALYSIS FAILED)
		-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [29.5]
		if PlayerStatus_upvr.FindStatus(nil, "HyperArmor") then
			-- KONSTANTERROR: Expression was reused, decompilation is incorrect
			var3_upvw.applyDamage(nil, 1)
		else
			-- KONSTANTERROR: Expression was reused, decompilation is incorrect
			var14_upvw = nil
		end
		if var14_upvw then
			var3_upvw.SetRootPriority(arg1, 100, 2)
			var3_upvw.applyStatus(arg1, "IFrames", 2)
			var3_upvw.applyStatus(arg1, "GlobalCD", 2)
			var3_upvw.applyStatus(arg1, "Freeze", 2)
			var3_upvw.applyStatus(var14_upvw, "Stunned", 2)
			var3_upvw.applyStatus(var14_upvw, "IFrames", 2)
			var3_upvw.applyStatus(var14_upvw, "AutoRotate", 2)
			var3_upvw.unragdoll(var14_upvw)
			local any_LoadAnimation_result1 = var14_upvw.Humanoid.Animator:LoadAnimation(Kick_Combo_upvr.EnemyAnim)
			any_LoadAnimation_result1:Play()
			any_LoadAnimation_result1.TimePosition = any_LoadAnimation_result1_upvr.TimePosition
			any_LoadAnimation_result1:AdjustSpeed(0.98)
			var15_upvw = var3_upvw.applyWeld(var14_upvw, Vector3.new(0, 0, 3), Vector3.new(0, 180, 0), 1.5)
			var3_upvw.conTimer(var14_upvw:FindFirstChild("Humanoid").Died:Connect(function() -- Line 84
				--[[ Upvalues[1]:
					[1]: var15_upvw (copied, read and write)
				]]
				if var15_upvw and var15_upvw.Parent then
					var15_upvw:Destroy()
				end
			end), module_upvr.Cooldown)
			var3_upvw.conTimer(var14_upvw.AncestryChanged:Connect(function(arg1_3, arg2_2) -- Line 89
				--[[ Upvalues[1]:
					[1]: var15_upvw (copied, read and write)
				]]
				if not arg2_2 and var15_upvw and var15_upvw.Parent then
					var15_upvw:Destroy()
				end
			end), module_upvr.Cooldown)
		else
			any_LoadAnimation_result1_upvr:Stop(0.3)
		end
		-- KONSTANTERROR: [26] 22. Error Block 33 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [172] 138. Error Block 26 start (CF ANALYSIS FAILED)
		if var14_upvw and var12_upvw == 4 then
			local BodyVelocity = Instance.new("BodyVelocity", arg1.Torso)
			BodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
			BodyVelocity.Velocity = Vector3.new(0, 100, 0)
			TweenService_upvr:Create(BodyVelocity, TweenInfo.new(0.75), {
				Velocity = Vector3.new(0, 0, 0);
			}):Play()
			game.Debris:AddItem(BodyVelocity, 1.1)
			clone_8_upvr.Slammed:Play()
		end
		if var14_upvw and var12_upvw < 5 then
			var3_upvw.applyVFX(Kick_Combo_upvr.VFX.kickVFX, var14_upvw.HumanoidRootPart, 5)
			var3_upvw.applyDamage(var14_upvw, 3, true, true)
			var3_upvw.Knockback(arg1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 30)
			var3_upvw.changeFov(arg1, var12_upvw * 2 + 80, 0.2, 1)
			var3_upvw.camShake(arg1, "Bump")
			var3_upvw.changeFov(arg1, 78, 0.01, 0.2)
			var3_upvw.changeFov(var14_upvw, 78, 0.01, 0.02)
			local clone_6 = clone_8_upvr.kick:Clone()
			clone_6.PlaybackSpeed += math.random(-1, 1) * 0.05
			clone_6.Parent = clone_8_upvr
			clone_6:Play()
			local clone = clone_8_upvr.Blood:Clone()
			clone.PlaybackSpeed += math.random(-1, 1) * 0.05
			clone.Parent = clone_8_upvr
			clone:Play()
			local clone_5 = clone_8_upvr.hitSFX:Clone()
			clone_5.PlaybackSpeed += math.random(-1, 1) * 0.05
			clone_5.Parent = clone_8_upvr
			clone_5:Play()
		else
			if var14_upvw and var12_upvw == 5 then
				var3_upvw.applyDebris(var15_upvw, 0)
				var3_upvw.applyVFX(Kick_Combo_upvr.VFX.kickVFX, var14_upvw.HumanoidRootPart, 5)
				var3_upvw.applyDamage(var14_upvw, 3, true)
				var3_upvw.applyStatus(var14_upvw, "Ragdoll", 2)
				var3_upvw.Knockback(var14_upvw, HumanoidRootPart_upvr.Position, 45, 25, 0.2)
				var3_upvw.camShake(arg1, "Bump")
				var3_upvw.changeFov(arg1, 78, 0.01, 0.2)
				var3_upvw.changeFov(var14_upvw, 78, 0.01, 0.02)
				local clone_7 = clone_8_upvr.kick:Clone()
				clone_7.PlaybackSpeed += math.random(-1, 1) * 0.05
				clone_7.Parent = clone_8_upvr
				clone_7:Play()
				local clone_3 = clone_8_upvr.Blood:Clone()
				clone_3.PlaybackSpeed += math.random(-1, 1) * 0.05
				clone_3.Parent = clone_8_upvr
				clone_3:Play()
				local clone_2 = clone_8_upvr.hitSFX:Clone()
				clone_2.PlaybackSpeed += math.random(-1, 1) * 0.05
				clone_2.Parent = clone_8_upvr
				clone_2:Play()
			end
			-- KONSTANTERROR: [172] 138. Error Block 26 end (CF ANALYSIS FAILED)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
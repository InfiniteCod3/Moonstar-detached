-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:16:52
-- Luau version 6, Types version 3
-- Time taken: 0.011842 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 30
module_upvr.GlobalCD = 1
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
	local Rising_Strikes_upvr = ReplicatedStorage_upvr.Skills.Kickboxer["Rising Strikes"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Rising_Strikes_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	var3_upvw.applyStatus(arg1, "Slowed", 1)
	local clone_4_upvr = Rising_Strikes_upvr.Part.Sounds:Clone()
	clone_4_upvr.Parent = arg1.Torso
	game.Debris:AddItem(clone_4_upvr, 10)
	clone_4_upvr.BigWhoosh:Play()
	local function _(arg1_2) -- Line 40, Named "playSfx"
		--[[ Upvalues[1]:
			[1]: clone_4_upvr (readonly)
		]]
		local clone_2 = arg1_2:Clone()
		clone_2.PlaybackSpeed += math.random(-1, 1) * 0.05
		clone_2.Parent = clone_4_upvr
		clone_2:Play()
	end
	local var12_upvw = 0
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local var14_upvw
	local var15_upvw
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("kick"):Connect(function() -- Line 51
		--[[ Upvalues[12]:
			[1]: var12_upvw (read and write)
			[2]: var3_upvw (copied, read and write)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: PlayerStatus_upvr (copied, readonly)
			[5]: var14_upvw (read and write)
			[6]: arg1 (readonly)
			[7]: var15_upvw (read and write)
			[8]: module_upvr (copied, readonly)
			[9]: any_LoadAnimation_result1_upvr (readonly)
			[10]: TweenService_upvr (copied, readonly)
			[11]: clone_4_upvr (readonly)
			[12]: Rising_Strikes_upvr (readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		var12_upvw += 1
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [26] 22. Error Block 29 start (CF ANALYSIS FAILED)
		-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [29.5]
		if PlayerStatus_upvr.FindStatus(nil, "HyperArmor") then
			-- KONSTANTERROR: Expression was reused, decompilation is incorrect
			var3_upvw.applyDamage(nil, 1)
		else
			-- KONSTANTERROR: Expression was reused, decompilation is incorrect
			var14_upvw = nil
		end
		if var14_upvw then
			var3_upvw.SetRootPriority(arg1, 100, 1)
			var3_upvw.applyStatus(arg1, "IFrames", 1)
			var3_upvw.applyStatus(arg1, "GlobalCD", 1)
			var3_upvw.applyStatus(arg1, "Freeze", 1.6)
			var3_upvw.applyStatus(var14_upvw, "Stunned", 2)
			var3_upvw.applyStatus(var14_upvw, "IFrames", 0.9)
			var3_upvw.applyStatus(var14_upvw, "AutoRotate", 1)
			var3_upvw.unragdoll(var14_upvw)
			var15_upvw = var3_upvw.applyWeld(var14_upvw, Vector3.new(0, 0, 3), Vector3.new(0, 180, 0), 1.5)
			var3_upvw.conTimer(var14_upvw:FindFirstChild("Humanoid").Died:Connect(function() -- Line 78
				--[[ Upvalues[1]:
					[1]: var15_upvw (copied, read and write)
				]]
				if var15_upvw and var15_upvw.Parent then
					var15_upvw:Destroy()
				end
			end), module_upvr.Cooldown)
			var3_upvw.conTimer(var14_upvw.AncestryChanged:Connect(function(arg1_4, arg2_3) -- Line 83
				--[[ Upvalues[1]:
					[1]: var15_upvw (copied, read and write)
				]]
				if not arg2_3 and var15_upvw and var15_upvw.Parent then
					var15_upvw:Destroy()
				end
			end), module_upvr.Cooldown)
		else
			any_LoadAnimation_result1_upvr:Stop(0.6)
		end
		-- KONSTANTERROR: [26] 22. Error Block 29 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [149] 123. Error Block 23 start (CF ANALYSIS FAILED)
		if var14_upvw and var12_upvw == 1 then
			local BodyVelocity_2 = Instance.new("BodyVelocity", arg1.Torso)
			BodyVelocity_2.MaxForce = Vector3.new(0, 1000000, 0)
			BodyVelocity_2.Velocity = Vector3.new(0, 100, 0)
			TweenService_upvr:Create(BodyVelocity_2, TweenInfo.new(0.75), {
				Velocity = Vector3.new(0, 0, 0);
			}):Play()
			game.Debris:AddItem(BodyVelocity_2, 2)
			clone_4_upvr.Slammed:Play()
		end
		if var14_upvw then
			var3_upvw.applyVFX(Rising_Strikes_upvr.VFX.kickVFX, var14_upvw.HumanoidRootPart, 5)
			var3_upvw.applyDamage(var14_upvw, 4, true, true)
			var3_upvw.Knockback(arg1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -10, 30)
			var3_upvw.changeFov(arg1, var12_upvw * 2 + 80, 0.2, 1)
			var3_upvw.camShake(arg1, "Bump")
			local clone_3 = clone_4_upvr.kick:Clone()
			clone_3.PlaybackSpeed += math.random(-1, 1) * 0.05
			clone_3.Parent = clone_4_upvr
			clone_3:Play()
			local clone_8 = clone_4_upvr.Blood:Clone()
			clone_8.PlaybackSpeed += math.random(-1, 1) * 0.05
			clone_8.Parent = clone_4_upvr
			clone_8:Play()
			local clone = clone_4_upvr.hitSFX:Clone()
			clone.PlaybackSpeed += math.random(-1, 1) * 0.05
			clone.Parent = clone_4_upvr
			clone:Play()
			if var12_upvw == 3 then
				var3_upvw.applyStatus(arg1, "CombatStun", 0.75)
				task.wait(1.25)
				var3_upvw.applyDebris(var15_upvw, 0)
			end
		end
		-- KONSTANTERROR: [149] 123. Error Block 23 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
end
return module_upvr
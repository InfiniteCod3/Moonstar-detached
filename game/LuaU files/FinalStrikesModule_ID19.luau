-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:15:32
-- Luau version 6, Types version 3
-- Time taken: 0.017282 seconds

local module_upvr = {
	Cooldown = 14;
	GlobalCD = 0.8;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[5]:
		[1]: var2_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: RunService_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Final_Strikes_upvr = ReplicatedStorage_upvr.Skills.Greatsword.Ultimate["Final Strikes"]
	local any_LoadAnimation_result1_upvr_2 = Humanoid_upvr.Animator:LoadAnimation(Final_Strikes_upvr.DashAnimation)
	any_LoadAnimation_result1_upvr_2:Play(0.0001)
	var2_upvw.applyStatus(arg1, "Freeze", 0.8)
	var2_upvw.applyStatus(arg1, "HyperArmor", 0.8)
	var2_upvw.camShake(arg1, "Bump")
	var2_upvw.flashScreen(arg1, Color3.new(0.772549, 0.772549, 0.772549), 0.3)
	var2_upvw.changeFov(arg1, 90, 0.7, 5)
	local clone_6_upvr = Final_Strikes_upvr.vfx.Dash:Clone()
	clone_6_upvr.Parent = HumanoidRootPart_upvr
	clone_6_upvr:Play()
	game.Debris:AddItem(clone_6_upvr, 0.8)
	clone_6_upvr.Volume = 0
	TweenService_upvr:Create(clone_6_upvr, TweenInfo.new(0.12), {
		Volume = 5;
	}):Play()
	local clone_2 = Final_Strikes_upvr.vfx.Dash2:Clone()
	clone_2.Parent = HumanoidRootPart_upvr
	clone_2:Play()
	game.Debris:AddItem(clone_2, 5)
	local var15_upvw
	var15_upvw = var2_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 54
		--[[ Upvalues[13]:
			[1]: arg2 (readonly)
			[2]: var15_upvw (read and write)
			[3]: any_LoadAnimation_result1_upvr_2 (readonly)
			[4]: clone_6_upvr (readonly)
			[5]: var2_upvw (copied, read and write)
			[6]: arg1 (readonly)
			[7]: Humanoid_upvr (readonly)
			[8]: Final_Strikes_upvr (readonly)
			[9]: HumanoidRootPart_upvr (readonly)
			[10]: RunService_upvr (copied, readonly)
			[11]: module_upvr (copied, readonly)
			[12]: Folder_upvr (readonly)
			[13]: TweenService_upvr (copied, readonly)
		]]
		if arg2 == arg1_2 and arg2_2 == "Final Strike" then
			var15_upvw:Disconnect()
			any_LoadAnimation_result1_upvr_2:Stop(0.0001)
			clone_6_upvr:Stop()
			var2_upvw.applyStatus(arg1, "AutoRotate", 0.8)
			var2_upvw.applyStatus(arg1, "Freeze", 0.8)
			var2_upvw.applyStatus(arg1, "HyperArmor", 0.5)
			var2_upvw.applyStatus(arg1, "GlobalCD", 0.8)
			local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Final_Strikes_upvr.StrikeAnimation)
			any_LoadAnimation_result1_upvr:Play(0.0001)
			any_LoadAnimation_result1_upvr:AdjustSpeed(0.25)
			task.spawn(function() -- Line 71
				--[[ Upvalues[1]:
					[1]: any_LoadAnimation_result1_upvr (readonly)
				]]
				for i = 1, 7 do
					any_LoadAnimation_result1_upvr:AdjustSpeed(0.25 + i * 0.1)
					task.wait()
				end
			end)
			local clone_3_upvr = Final_Strikes_upvr.vfx.GiantShockwave:Clone()
			clone_3_upvr.Parent = HumanoidRootPart_upvr
			game.Debris:AddItem(clone_3_upvr, 10)
			local clone_5_upvr = Final_Strikes_upvr.vfx.HugeShockwave:Clone()
			clone_5_upvr.Parent = HumanoidRootPart_upvr
			game.Debris:AddItem(clone_5_upvr, 10)
			local clone_4_upvr = Final_Strikes_upvr.vfx.Shockwave:Clone()
			clone_4_upvr.Parent = HumanoidRootPart_upvr
			game.Debris:AddItem(clone_4_upvr, 10)
			clone_4_upvr.Whoosh:Play()
			clone_4_upvr.BodyPrepare:Play()
			var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("strike"):Connect(function() -- Line 94
				--[[ Upvalues[11]:
					[1]: var2_upvw (copied, read and write)
					[2]: arg1 (copied, readonly)
					[3]: clone_4_upvr (readonly)
					[4]: HumanoidRootPart_upvr (copied, readonly)
					[5]: clone_5_upvr (readonly)
					[6]: Final_Strikes_upvr (copied, readonly)
					[7]: RunService_upvr (copied, readonly)
					[8]: module_upvr (copied, readonly)
					[9]: Humanoid_upvr (copied, readonly)
					[10]: clone_6_upvr (copied, readonly)
					[11]: clone_3_upvr (readonly)
				]]
				-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
				var2_upvw.camShake(arg1, "Explosion")
				var2_upvw.flashScreen(arg1, Color3.new(0.584314, 0.584314, 0.584314), 0.45)
				var2_upvw.changeFov(arg1, 45, 0.01, 2)
				var2_upvw.impactFrame2(arg1)
				task.delay(0.1, function() -- Line 100
					--[[ Upvalues[2]:
						[1]: var2_upvw (copied, read and write)
						[2]: clone_4_upvr (copied, readonly)
					]]
					var2_upvw.EmitAllDescendants(clone_4_upvr)
				end)
				clone_4_upvr.slash:Play()
				clone_4_upvr.Shockwave:Play()
				clone_4_upvr.CoreShockwave:Play()
				clone_4_upvr.hitSFX:Play()
				local LookVector = HumanoidRootPart_upvr.CFrame.LookVector
				-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
				-- KONSTANTERROR: [473] 360. Error Block 12 start (CF ANALYSIS FAILED)
				-- KONSTANTERROR: [473] 360. Error Block 12 end (CF ANALYSIS FAILED)
				-- KONSTANTERROR: [81] 64. Error Block 19 start (CF ANALYSIS FAILED)
				-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [473.7]
				-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [473.8]
				-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [473.9]
				for _, _ in nil do
					-- KONSTANTWARNING: Failed to evaluate expression, replaced with nil [473.12]
					if nil then
					end
				end
				-- KONSTANTERROR: [81] 64. Error Block 19 end (CF ANALYSIS FAILED)
			end), module_upvr.Cooldown)
		else
			any_LoadAnimation_result1_upvr = arg2
			if any_LoadAnimation_result1_upvr == arg1_2 and arg2_2 == "Final Strike v2" then
				any_LoadAnimation_result1_upvr = var15_upvw:Disconnect
				any_LoadAnimation_result1_upvr()
				any_LoadAnimation_result1_upvr = any_LoadAnimation_result1_upvr_2
				clone_5_upvr = 0.0001
				any_LoadAnimation_result1_upvr = any_LoadAnimation_result1_upvr:Stop
				any_LoadAnimation_result1_upvr(clone_5_upvr)
				any_LoadAnimation_result1_upvr = clone_6_upvr:Stop
				any_LoadAnimation_result1_upvr()
				clone_3_upvr = var2_upvw
				any_LoadAnimation_result1_upvr = clone_3_upvr.applyStatus
				clone_3_upvr = arg1
				clone_5_upvr = "AutoRotate"
				clone_4_upvr = 0.8
				any_LoadAnimation_result1_upvr(clone_3_upvr, clone_5_upvr, clone_4_upvr)
				clone_3_upvr = var2_upvw
				any_LoadAnimation_result1_upvr = clone_3_upvr.applyStatus
				clone_3_upvr = arg1
				clone_5_upvr = "Freeze"
				clone_4_upvr = 0.8
				any_LoadAnimation_result1_upvr(clone_3_upvr, clone_5_upvr, clone_4_upvr)
				clone_3_upvr = var2_upvw
				any_LoadAnimation_result1_upvr = clone_3_upvr.applyStatus
				clone_3_upvr = arg1
				clone_5_upvr = "HyperArmor"
				clone_4_upvr = 0.5
				any_LoadAnimation_result1_upvr(clone_3_upvr, clone_5_upvr, clone_4_upvr)
				clone_3_upvr = var2_upvw
				any_LoadAnimation_result1_upvr = clone_3_upvr.applyStatus
				clone_3_upvr = arg1
				clone_5_upvr = "GlobalCD"
				clone_4_upvr = 0.8
				any_LoadAnimation_result1_upvr(clone_3_upvr, clone_5_upvr, clone_4_upvr)
				clone_3_upvr = Humanoid_upvr
				any_LoadAnimation_result1_upvr = clone_3_upvr.Animator
				clone_4_upvr = Final_Strikes_upvr
				clone_5_upvr = clone_4_upvr.StrikeAnimation
				any_LoadAnimation_result1_upvr = any_LoadAnimation_result1_upvr:LoadAnimation(clone_5_upvr)
				local var28 = any_LoadAnimation_result1_upvr
				clone_4_upvr = 0.0001
				clone_3_upvr = var28:Play
				clone_3_upvr(clone_4_upvr)
				clone_4_upvr = 0.75
				clone_3_upvr = var28:AdjustSpeed
				clone_3_upvr(clone_4_upvr)
				clone_5_upvr = var2_upvw
				clone_3_upvr = clone_5_upvr.conTimer
				clone_5_upvr = var28:GetMarkerReachedSignal("strike")
				clone_5_upvr = clone_5_upvr:Connect(function() -- Line 303
					--[[ Upvalues[8]:
						[1]: var2_upvw (copied, read and write)
						[2]: arg1 (copied, readonly)
						[3]: Final_Strikes_upvr (copied, readonly)
						[4]: Folder_upvr (copied, readonly)
						[5]: HumanoidRootPart_upvr (copied, readonly)
						[6]: TweenService_upvr (copied, readonly)
						[7]: RunService_upvr (copied, readonly)
						[8]: module_upvr (copied, readonly)
					]]
					var2_upvw.camShake(arg1, "BigBump")
					var2_upvw.flashScreen(arg1, Color3.new(1, 0.729412, 0.458824), 0.45)
					var2_upvw.changeFov(arg1, 60, 0.01, 1.5)
					local clone_7 = Final_Strikes_upvr.SlashEmit:Clone()
					clone_7.Parent = Folder_upvr
					clone_7.CFrame = HumanoidRootPart_upvr.CFrame
					var2_upvw.EmitAllDescendants(clone_7)
					local clone_upvr = Final_Strikes_upvr["Fire Slash"]:Clone()
					clone_upvr.Parent = Folder_upvr
					clone_upvr.CFrame = HumanoidRootPart_upvr.CFrame
					clone_upvr.FireBurst:Play()
					for _, v_2_upvr in clone_upvr:GetDescendants() do
						if v_2_upvr:IsA("ParticleEmitter") then
							v_2_upvr.Enabled = true
							task.delay(0.9, function() -- Line 320
								--[[ Upvalues[1]:
									[1]: v_2_upvr (readonly)
								]]
								v_2_upvr.Enabled = false
							end)
						end
					end
					TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.9, Enum.EasingStyle.Linear), {
						CFrame = clone_upvr.CFrame + clone_upvr.CFrame.LookVector * 80;
					}):Play()
					local var40_upvw
					local tbl_upvr = {}
					var40_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 333
						--[[ Upvalues[4]:
							[1]: clone_upvr (readonly)
							[2]: var40_upvw (read and write)
							[3]: var2_upvw (copied, read and write)
							[4]: tbl_upvr (readonly)
						]]
						if not clone_upvr.Parent then
							var40_upvw:Disconnect()
						else
							if workspace:Raycast(clone_upvr.Position, Vector3.new(0, -3.0999, 0), var2_upvw.raycastParams) and clone_upvr.FireParticle.Enabled == true then
								clone_upvr.Attachment.char.Enabled = true
							else
								clone_upvr.Attachment.char.Enabled = false
							end
							for _, v_3 in var2_upvw.findEnemiesPart(clone_upvr.Hitbox, true), nil do
								if not table.find(tbl_upvr, v_3) then
									table.insert(tbl_upvr, v_3)
									var2_upvw.applyDamage(v_3, 25)
									var2_upvw.Knockback(v_3, clone_upvr.Position + clone_upvr.CFrame.LookVector * -7, 80)
									var2_upvw.applyStatus(v_3, "Ragdoll", 1.5)
									local clone = clone_upvr.Hit:Clone()
									clone.Parent = v_3.Torso
									clone.PlaybackSpeed += math.random(-1, 1) * 0.1
									clone:Play()
									game.Debris:AddItem(clone, 4)
								end
							end
						end
					end), module_upvr.Cooldown)
				end)
				clone_4_upvr = module_upvr.Cooldown
				clone_3_upvr(clone_5_upvr, clone_4_upvr)
			end
		end
	end), module_upvr.Cooldown)
	task.wait(2)
	var15_upvw:Disconnect()
end
return module_upvr
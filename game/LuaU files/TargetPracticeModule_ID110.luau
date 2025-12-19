-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:16
-- Luau version 6, Types version 3
-- Time taken: 0.016009 seconds

local module_upvr = {
	Cooldown = 24;
	GlobalCD = 0.9;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 15
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
	local Target_Practice_upvr = ReplicatedStorage_upvr.Skills.Dagger["Target Practice"]
	local any_LoadAnimation_result1_upvr_2 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Target_Practice_upvr.Animation)
	any_LoadAnimation_result1_upvr_2:Play()
	any_LoadAnimation_result1_upvr_2:AdjustSpeed(0.95)
	local clone_4_upvr = Target_Practice_upvr.Part.sounds:Clone()
	clone_4_upvr.Parent = arg1.Torso
	game.Debris:AddItem(clone_4_upvr, 10)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 38
		--[[ Upvalues[1]:
			[1]: clone_4_upvr (readonly)
		]]
		clone_4_upvr[arg1_2]:Play()
	end), module_upvr.Cooldown)
	var2_upvw.changeFov(arg1, 85, 0.25, 5)
	var2_upvw.applyStatus(arg1, "Freeze", 0.9)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local var12_upvw
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("push"):Connect(function() -- Line 47
		--[[ Upvalues[10]:
			[1]: var2_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: var12_upvw (read and write)
			[5]: Target_Practice_upvr (readonly)
			[6]: any_LoadAnimation_result1_upvr_2 (readonly)
			[7]: Folder_upvr (readonly)
			[8]: module_upvr (copied, readonly)
			[9]: TweenService_upvr (copied, readonly)
			[10]: clone_4_upvr (readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		var2_upvw.changeFov(arg1, 66, 0, 0.5)
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [35] 30. Error Block 3 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [35] 30. Error Block 3 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [27] 23. Error Block 11 start (CF ANALYSIS FAILED)
		if var12_upvw then
			var2_upvw.applyStatus(arg1, "GlobalCD", 1)
			var2_upvw.applyStatus(arg1, "Freeze", 1)
			var2_upvw.applyStatus(arg1, "AutoRotate", 1)
			var2_upvw.applyStatus(arg1, "IFrames", 1)
			var2_upvw.applyStatus(var12_upvw, "Stunned", 2)
			var2_upvw.applyStatus(var12_upvw, "AutoRotate", 2)
			var2_upvw.applyStatus(var12_upvw, "IFrames", 1)
			var2_upvw.applyDamage(var12_upvw, 5, true, true)
			var2_upvw.changeFov(var12_upvw, 66, 0, 0.5)
			var2_upvw.SetRootPriority(arg1, 100, 1)
			local any_LoadAnimation_result1_upvr = var12_upvw.Humanoid.Animator:LoadAnimation(Target_Practice_upvr.EnemyAnimation)
			any_LoadAnimation_result1_upvr:Play()
			any_LoadAnimation_result1_upvr.TimePosition = any_LoadAnimation_result1_upvr_2.TimePosition
			any_LoadAnimation_result1_upvr:AdjustSpeed(0.95)
			local tbl_upvr = {}
			var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("daggergrab"):Connect(function() -- Line 82
				--[[ Upvalues[4]:
					[1]: Target_Practice_upvr (copied, readonly)
					[2]: Folder_upvr (copied, readonly)
					[3]: arg1 (copied, readonly)
					[4]: tbl_upvr (readonly)
				]]
				for _, v in Target_Practice_upvr.daggers:GetChildren() do
					local clone_2 = v:Clone()
					clone_2.Parent = Folder_upvr
					clone_2.weld.Part1 = clone_2
					clone_2.weld.Part0 = arg1["Left Arm"]
					game.Debris:AddItem(clone_2, 1)
					table.insert(tbl_upvr, clone_2)
				end
			end), module_upvr.Cooldown)
			local any_applyWeld_result1_upvr = var2_upvw.applyWeld(var12_upvw, Vector3.new(0, 0, 5), Vector3.new(0, 180, 0), 1)
			var2_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("throw"):Connect(function() -- Line 93
				--[[ Upvalues[11]:
					[1]: tbl_upvr (readonly)
					[2]: var2_upvw (copied, read and write)
					[3]: arg1 (copied, readonly)
					[4]: Target_Practice_upvr (copied, readonly)
					[5]: Folder_upvr (copied, readonly)
					[6]: var12_upvw (copied, read and write)
					[7]: TweenService_upvr (copied, readonly)
					[8]: any_applyWeld_result1_upvr (readonly)
					[9]: any_LoadAnimation_result1_upvr (readonly)
					[10]: HumanoidRootPart_upvr (copied, readonly)
					[11]: module_upvr (copied, readonly)
				]]
				-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
				for _, v_2 in tbl_upvr do
					v_2:Destroy()
				end
				var2_upvw.changeFov(arg1, 88, 0, 4)
				var2_upvw.changeFov(arg1, 88, 0, 4)
				local clone = Target_Practice_upvr.EnemyDaggers:Clone()
				clone.Parent = Folder_upvr
				clone.Motor6D.Part0 = var12_upvw.Torso
				clone.Motor6D.Part1 = clone
				for i_3_upvr = 1, 3 do
					local SOME_upvr = clone:FindFirstChild(i_3_upvr)
					local clone_3_upvr = Target_Practice_upvr["Throwing Dagger"]:Clone()
					clone_3_upvr.Parent = Folder_upvr
					clone_3_upvr.CFrame = arg1.Torso.CFrame
					clone_3_upvr.CFrame = CFrame.lookAt(clone_3_upvr.Position, SOME_upvr.Position)
					game.Debris:AddItem(clone_3_upvr, 3)
					local any_Create_result1 = TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
						CFrame = CFrame.new(SOME_upvr.Position) * clone_3_upvr.CFrame - clone_3_upvr.CFrame.p;
					})
					any_Create_result1:Play()
					var2_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 117
						--[[ Upvalues[10]:
							[1]: var2_upvw (copied, read and write)
							[2]: var12_upvw (copied, read and write)
							[3]: clone_3_upvr (readonly)
							[4]: SOME_upvr (readonly)
							[5]: arg1 (copied, readonly)
							[6]: i_3_upvr (readonly)
							[7]: any_applyWeld_result1_upvr (copied, readonly)
							[8]: any_LoadAnimation_result1_upvr (copied, readonly)
							[9]: Target_Practice_upvr (copied, readonly)
							[10]: HumanoidRootPart_upvr (copied, readonly)
						]]
						var2_upvw.applyDamage(var12_upvw, 2, true, true)
						var2_upvw.blood(var12_upvw, 2)
						local hitSFX = clone_3_upvr.hitSFX
						hitSFX.PlaybackSpeed += math.random(-1, 1) * 0.1
						clone_3_upvr.hitSFX:Play()
						clone_3_upvr.Anchored = false
						clone_3_upvr.weld.Part1 = clone_3_upvr
						clone_3_upvr.weld.Part0 = SOME_upvr
						var2_upvw.EmitAllDescendants(clone_3_upvr.HitVfx)
						var2_upvw.changeFov(var12_upvw, 65, 0, 1)
						var2_upvw.flashScreen(var12_upvw, Color3.new(1, 0.490196, 0.490196), 0.25)
						var2_upvw.camShake(var12_upvw, "Bump")
						var2_upvw.changeFov(arg1, 65, 0, 1)
						var2_upvw.flashScreen(arg1, Color3.new(1, 0.509804, 0.509804), 0.25)
						var2_upvw.camShake(arg1, "Bump")
						if i_3_upvr == 3 then
							var2_upvw.applyDebris(any_applyWeld_result1_upvr, 0)
							var2_upvw.applyDamage(var12_upvw, 1, true)
							var12_upvw.HumanoidRootPart.CFrame = CFrame.new(var12_upvw.Torso.Position) * var12_upvw.HumanoidRootPart.CFrame - var12_upvw.HumanoidRootPart.CFrame.p
							any_LoadAnimation_result1_upvr:Stop(1e-09)
							var12_upvw.Humanoid.Animator:LoadAnimation(Target_Practice_upvr.HurtAnimation):Play()
							var2_upvw.applyStatus(var12_upvw, "Ragdoll", 1)
							var2_upvw.Knockback(var12_upvw, HumanoidRootPart_upvr.Position, 18)
						end
					end), module_upvr.Cooldown)
					local _
				end
			end), module_upvr.Cooldown)
		else
			any_applyWeld_result1_upvr = any_LoadAnimation_result1_upvr_2
			tbl_upvr = 0.4
			any_applyWeld_result1_upvr = any_applyWeld_result1_upvr:Stop
			any_applyWeld_result1_upvr(tbl_upvr)
			any_LoadAnimation_result1_upvr = clone_4_upvr
			any_applyWeld_result1_upvr = any_LoadAnimation_result1_upvr.push
			any_LoadAnimation_result1_upvr = 0
			any_applyWeld_result1_upvr.Volume = any_LoadAnimation_result1_upvr
			-- KONSTANTERROR: [27] 23. Error Block 11 end (CF ANALYSIS FAILED)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
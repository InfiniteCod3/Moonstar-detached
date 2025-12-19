-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:16:48
-- Luau version 6, Types version 3
-- Time taken: 0.013163 seconds

local module = {
	GlobalCD = 1;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
function module.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[2]:
		[1]: var2_upvw (read and write)
		[2]: ReplicatedStorage_upvr (readonly)
	]]
	var2_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, 9.5)
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Ultimate_upvr = ReplicatedStorage_upvr.Skills.Kickboxer.Ultimate
	local clone_2_upvr = Ultimate_upvr.Part.Sounds:Clone()
	clone_2_upvr.Parent = arg1.Torso
	game.Debris:AddItem(clone_2_upvr, 10)
	clone_2_upvr.ArmWhoosh:Play()
	task.delay(0.1, function() -- Line 32
		--[[ Upvalues[1]:
			[1]: clone_2_upvr (readonly)
		]]
		clone_2_upvr.BigWhoosh:Play()
	end)
	var2_upvw.applyStatus(arg1, "IFrames", 1)
	var2_upvw.applyStatus(arg1, "Slowed", 1)
	local any_LoadAnimation_result1_upvr = Humanoid_upvr.Animator:LoadAnimation(Ultimate_upvr.StartAnim)
	any_LoadAnimation_result1_upvr:Play()
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("kick"):Connect(function() -- Line 43
		--[[ Upvalues[7]:
			[1]: var2_upvw (copied, read and write)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: arg1 (readonly)
			[4]: clone_2_upvr (readonly)
			[5]: any_LoadAnimation_result1_upvr (readonly)
			[6]: Humanoid_upvr (readonly)
			[7]: Ultimate_upvr (readonly)
		]]
		for _, v_upvr in var2_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 8.6, 9, true), nil do
			var2_upvw.SetRootPriority(arg1, 100, 4.5)
			clone_2_upvr.kick:Play()
			any_LoadAnimation_result1_upvr:Stop(1e-07)
			var2_upvw.applyStatus(arg1, "IFrames", 4.5)
			var2_upvw.applyStatus(arg1, "GlobalCD", 4.5)
			var2_upvw.applyStatus(arg1, "Freeze", 4.5)
			var2_upvw.applyStatus(arg1, "AutoRotate", 4.5)
			var2_upvw.applyStatus(arg1, "Ultimate", 4.5)
			var2_upvw.applyStatus(v_upvr, "Stunned", 4.5)
			var2_upvw.applyStatus(v_upvr, "IFrames", 4.5)
			var2_upvw.applyStatus(v_upvr, "AutoRotate", 4.5)
			var2_upvw.applyStatus(v_upvr, "Ultimate", 4.5)
			var2_upvw.unragdoll(v_upvr)
			local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Ultimate_upvr.Animation)
			any_LoadAnimation_result1:Play()
			v_upvr.Humanoid.Animator:LoadAnimation(Ultimate_upvr.AnimationEnemy):Play()
			var2_upvw.cameraCutscene(v_upvr, "Kickboxer")
			var2_upvw.Cutscene(v_upvr, "KickboxerUltimate")
			v_upvr.Humanoid.DisplayDistanceType = "None"
			v_upvr.Humanoid.HealthDisplayType = "AlwaysOff"
			Humanoid_upvr.DisplayDistanceType = "None"
			Humanoid_upvr.HealthDisplayType = "AlwaysOff"
			any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 77
				--[[ Upvalues[3]:
					[1]: clone_2_upvr (copied, readonly)
					[2]: arg1 (copied, readonly)
					[3]: var2_upvw (copied, read and write)
				]]
				local clone_3 = clone_2_upvr:FindFirstChild(arg1_2):Clone()
				clone_3.Parent = arg1.Torso
				clone_3:Play()
				if clone_3.Name == "whoosh" then
					clone_3.PlaybackSpeed += math.random(-1, 1) * 0.1
				elseif clone_3.Name == "jump" then
					var2_upvw.CreateDebris(arg1.Torso.Position, 20, 0.7, 0.5, 0.08)
					var2_upvw.crater(1, arg1.Torso.Position, 1, 0.25)
				end
			end)
			clone_2_upvr.Phase:Play()
			var2_upvw.Blur(arg1, 30, 0.6)
			var2_upvw.changeFov(arg1, 55, 1, 5)
			var2_upvw.Blur(v_upvr, 30, 0.6)
			var2_upvw.changeFov(v_upvr, 55, 1, 5)
			local any_applyWeld_result1_upvr = var2_upvw.applyWeld(v_upvr, Vector3.new(0, 0, 3), Vector3.new(0, 180, 0), 6)
			any_LoadAnimation_result1:GetMarkerReachedSignal("kick"):Connect(function(arg1_3) -- Line 96
				--[[ Upvalues[8]:
					[1]: var2_upvw (copied, read and write)
					[2]: Ultimate_upvr (copied, readonly)
					[3]: v_upvr (readonly)
					[4]: arg1 (copied, readonly)
					[5]: clone_2_upvr (copied, readonly)
					[6]: any_applyWeld_result1_upvr (readonly)
					[7]: HumanoidRootPart_upvr (copied, readonly)
					[8]: Humanoid_upvr (copied, readonly)
				]]
				var2_upvw.applyVFX(Ultimate_upvr.VFX.kickVFX, v_upvr.HumanoidRootPart, 5)
				var2_upvw.applyDamage(v_upvr, 18, true, true)
				var2_upvw.changeFov(arg1, 92, 0.01, 0.12)
				var2_upvw.changeFov(v_upvr, 92, 0.01, 0.12)
				var2_upvw.blood(v_upvr, 2)
				local clone = Ultimate_upvr.Part.HitVfx:Clone()
				clone.Parent = v_upvr.Torso
				var2_upvw.EmitAllDescendants(clone)
				game.Debris:AddItem(clone, 5)
				for i_2, v_2 in clone_2_upvr:GetChildren() do
					if arg1_3 == v_2.Name then
						for _, v_3 in v_2:GetChildren() do
							if v_3:IsA("Sound") then
								v_3:Play()
							end
						end
					end
				end
				if arg1_3 == '6' then
					i_2 = v_upvr
					i_2 = 0.6
					v_2 = 0.4
					var2_upvw.CreateDebris(i_2.Torso.Position, 20, i_2, v_2, 0.08)
					v_2 = v_upvr
					i_2 = v_2.Torso
					i_2 = 1.4
					v_2 = 0.3
					var2_upvw.crater(1, i_2.Position, i_2, v_2)
					clone_2_upvr['5'].Spin:Stop()
				end
				if arg1_3 == '7' then
					var2_upvw.applyDebris(any_applyWeld_result1_upvr, 0)
					i_2 = 3
					var2_upvw.applyStatus(v_upvr, "Ragdoll", i_2)
					i_2 = HumanoidRootPart_upvr
					i_2 = 450
					v_2 = 95
					var2_upvw.Knockback(v_upvr, i_2.Position, i_2, v_2)
					i_2 = true
					var2_upvw.applyDamage(v_upvr, 100, i_2)
					var2_upvw.impactFrame2(arg1, 0.1)
					i_2 = 0.01
					v_2 = 0.12
					var2_upvw.changeFov(arg1, 100, i_2, v_2)
					i_2 = 0.3
					var2_upvw.Blur(arg1, 40, i_2)
					var2_upvw.impactFrame2(v_upvr, 0.1)
					i_2 = 0.01
					v_2 = 0.12
					var2_upvw.changeFov(v_upvr, 100, i_2, v_2)
					i_2 = 0.3
					var2_upvw.Blur(v_upvr, 40, i_2)
					task.wait(1)
					Humanoid_upvr.DisplayDistanceType = "Viewer"
					Humanoid_upvr.HealthDisplayType = "DisplayWhenDamaged"
				end
			end)
			return
		end
	end)
end
return module
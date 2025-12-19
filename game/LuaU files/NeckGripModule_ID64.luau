-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:16:51
-- Luau version 6, Types version 3
-- Time taken: 0.007188 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 18
module_upvr.GlobalCD = 0.8
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local Neck_Grip_upvr = ReplicatedStorage_upvr.Skills.Kickboxer["Neck Grip"]
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Neck_Grip_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	local clone_upvr = Neck_Grip_upvr.Part.Sounds:Clone()
	clone_upvr.Parent = arg1.Torso
	game.Debris:AddItem(clone_upvr, 10)
	clone_upvr.BigWhoosh:Play()
	var3_upvw.applyStatus(arg1, "Slowed", 0.8)
	clone_upvr.woosh:Play()
	clone_upvr.whoosh:Play()
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var3_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("grab"):Connect(function() -- Line 43
		--[[ Upvalues[8]:
			[1]: var3_upvw (copied, read and write)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: arg1 (readonly)
			[4]: clone_upvr (readonly)
			[5]: Neck_Grip_upvr (readonly)
			[6]: any_LoadAnimation_result1_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		local var13_upvw
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [36] 30. Error Block 24 start (CF ANALYSIS FAILED)
		if var13_upvw then
			var3_upvw.unragdoll(var13_upvw)
			task.wait(0.1)
			var3_upvw.applyStatus(arg1, "GlobalCD", 0.7)
			var3_upvw.applyStatus(arg1, "Slowed", 0.75)
			var3_upvw.applyStatus(arg1, "IFrames", 0.75)
			var3_upvw.applyStatus(var13_upvw, "Stunned", 0.75)
			var3_upvw.applyStatus(var13_upvw, "IFrames", 0.75)
			var3_upvw.applyDamage(var13_upvw, 2, true, true)
			var3_upvw.changeFov(arg1, 76, 0.01, 1)
			var3_upvw.changeFov(var13_upvw, 76, 0.01, 1)
			clone_upvr["Grab Sound"]:Play()
			local any_LoadAnimation_result1_upvr_2 = var13_upvw.Humanoid.Animator:LoadAnimation(Neck_Grip_upvr.EnemyAnim)
			any_LoadAnimation_result1_upvr_2:Play()
			any_LoadAnimation_result1_upvr_2.TimePosition = any_LoadAnimation_result1_upvr.TimePosition
			for _, v_upvr in var13_upvw:GetChildren() do
				if v_upvr:IsA("BasePart") and v_upvr.CanCollide == true then
					v_upvr.CanCollide = false
					table.insert({}, v_upvr)
					task.delay(0.75, function() -- Line 86
						--[[ Upvalues[1]:
							[1]: v_upvr (readonly)
						]]
						v_upvr.CanCollide = true
					end)
				end
			end
			HumanoidRootPart_upvr.RootPriority = 10
			local any_applyWeld_result1_upvr = var3_upvw.applyWeld(var13_upvw, Vector3.new(0, 0, 3), Vector3.new(0, 180, 0), 1)
			var3_upvw.conTimer(any_LoadAnimation_result1_upvr_2:GetMarkerReachedSignal("slam"):Connect(function() -- Line 93
				--[[ Upvalues[8]:
					[1]: var3_upvw (copied, read and write)
					[2]: any_applyWeld_result1_upvr (readonly)
					[3]: var13_upvw (read and write)
					[4]: HumanoidRootPart_upvr (copied, readonly)
					[5]: arg1 (copied, readonly)
					[6]: clone_upvr (copied, readonly)
					[7]: TweenService_upvr (copied, readonly)
					[8]: any_LoadAnimation_result1_upvr_2 (readonly)
				]]
				var3_upvw.applyDebris(any_applyWeld_result1_upvr, 0)
				var3_upvw.unragdoll(var13_upvw)
				task.wait()
				HumanoidRootPart_upvr.RootPriority = 0
				var3_upvw.applyDamage(var13_upvw, 13, true)
				var3_upvw.camShake(arg1, "BigBump")
				var3_upvw.camShake(var13_upvw, "BigBump")
				var3_upvw.changeFov(var13_upvw, 60, 0.01, 0.1)
				var3_upvw.changeFov(var13_upvw, 60, 0.01, 0.1)
				clone_upvr.rocks:Play()
				clone_upvr.Slammed:Play()
				TweenService_upvr:Create(var13_upvw.HumanoidRootPart, TweenInfo.new(0.1), {
					Velocity = Vector3.new(0, 0, 0);
				}):Play()
				TweenService_upvr:Create(var13_upvw.HumanoidRootPart, TweenInfo.new(0.1), {
					RotVelocity = Vector3.new(0, 0, 0);
				}):Play()
				any_LoadAnimation_result1_upvr_2:Stop(1e-08)
				var13_upvw.HumanoidRootPart.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * -6 + Vector3.new(0, 2, 0)) * CFrame.Angles((-math.pi/2), 0, 0)
				var13_upvw.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
				local BodyVelocity = Instance.new("BodyVelocity", var13_upvw.Torso)
				BodyVelocity.MaxForce = Vector3.new(1000000, 0, 1000000)
				BodyVelocity.Velocity = Vector3.new(0, 0, 0)
				var3_upvw.applyDebris(BodyVelocity, 0.5)
				task.wait()
				var3_upvw.applyStatus(var13_upvw, "Ragdoll", 2)
				var3_upvw.crater(1, var13_upvw.HumanoidRootPart.Position, 2, 0.4)
				var3_upvw.CreateDebris(var13_upvw.HumanoidRootPart.Position, 15, 0.5, 0.6, 0.08)
			end), module_upvr.Cooldown)
		else
			any_LoadAnimation_result1_upvr_2 = clone_upvr
			any_applyWeld_result1_upvr = any_LoadAnimation_result1_upvr_2.woosh:Stop
			any_applyWeld_result1_upvr()
			any_LoadAnimation_result1_upvr_2 = clone_upvr
			any_applyWeld_result1_upvr = any_LoadAnimation_result1_upvr_2.whoosh:Stop
			any_applyWeld_result1_upvr()
			any_applyWeld_result1_upvr = any_LoadAnimation_result1_upvr:Stop
			any_applyWeld_result1_upvr(0.3)
		end
		-- KONSTANTERROR: [36] 30. Error Block 24 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
end
return module_upvr
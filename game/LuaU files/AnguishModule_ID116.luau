-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:57
-- Luau version 6, Types version 3
-- Time taken: 0.015995 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local var3_upvw
if script.Parent:IsA("ModuleScript") then
	var3_upvw = require(script.Parent.Parent.Parent.Parent)
end
module_upvr.Cooldown = 25
module_upvr.GlobalCD = 0.1
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 17
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown + 10)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Anguish_upvr = ReplicatedStorage_upvr.Skills["Soul Lantern"].Ultimate.Anguish
	local function DeathEffects_upvr(arg1_2) -- Line 31, Named "DeathEffects"
		--[[ Upvalues[4]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: Anguish_upvr (readonly)
			[4]: var3_upvw (copied, read and write)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [7] 5. Error Block 2 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [7] 5. Error Block 2 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [12] 9. Error Block 3 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [12] 9. Error Block 3 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [199] 143. Error Block 29 start (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [199] 143. Error Block 29 end (CF ANALYSIS FAILED)
	end
	local var9_upvw
	local var10_upvw
	local var11_upvw
	local var12_upvw
	local var13_upvw
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Anguish_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	var3_upvw.applyVFX(Anguish_upvr.JumpVFX, Folder_upvr, 5, HumanoidRootPart_upvr.CFrame + Vector3.new(0, -2.5, 0))
	var3_upvw.crater(1, HumanoidRootPart_upvr.Position + Vector3.new(0, 1, 0), 3, 1.2)
	var3_upvw.applySound(Anguish_upvr.ChargeSFX, HumanoidRootPart_upvr, 5)
	var3_upvw.flashScreen(arg1, Color3.new(1, 0.145098, 0.145098), 0.2)
	local var15_upvw = false
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Jump"):Once(function() -- Line 87
		--[[ Upvalues[12]:
			[1]: var9_upvw (read and write)
			[2]: any_LoadAnimation_result1_upvr (readonly)
			[3]: ReplicatedStorage_upvr (copied, readonly)
			[4]: arg2 (readonly)
			[5]: var15_upvw (read and write)
			[6]: var3_upvw (copied, read and write)
			[7]: arg1 (readonly)
			[8]: var12_upvw (read and write)
			[9]: var13_upvw (read and write)
			[10]: Anguish_upvr (readonly)
			[11]: HumanoidRootPart_upvr (readonly)
			[12]: var10_upvw (read and write)
		]]
		if not var9_upvw then
			any_LoadAnimation_result1_upvr:Stop()
			ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "AnguishStop")
		else
			var15_upvw = true
			var3_upvw.applyStatus(arg1, "Stunned", 2.5)
			var3_upvw.applyStatus(arg1, "AutoRotate", 2.5)
			ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "Anguish")
			for _, v_3 in var12_upvw:GetDescendants() do
				if v_3:IsA("ParticleEmitter") or v_3:IsA("PointLight") then
					v_3.Enabled = false
				end
			end
			for _, v_4 in var13_upvw:GetDescendants() do
				if v_4:IsA("ParticleEmitter") or v_4:IsA("PointLight") then
					v_4.Enabled = false
				end
			end
			var3_upvw.crater(1, HumanoidRootPart_upvr.Position + Vector3.new(0, 1, 0), 5, 2)
			any_LoadAnimation_result1_upvr:AdjustSpeed(0.8)
			var10_upvw:AdjustSpeed(0.8)
			var3_upvw.applySound(Anguish_upvr.JumpSFX, HumanoidRootPart_upvr, 5)
			var3_upvw.applySound(Anguish_upvr.PunchPrepare, HumanoidRootPart_upvr, 5)
			var3_upvw.camShake(arg1, "SmallBump")
			var3_upvw.changeFov(arg1, 120, 0.2, 2)
			var3_upvw.flashScreen(arg1, Color3.new(1, 0.145098, 0.145098), 0.3)
			var3_upvw.flashScreen(var9_upvw, Color3.new(1, 0.145098, 0.145098), 0.3)
			var3_upvw.camShake(var9_upvw, "SmallBump")
			var3_upvw.changeFov(var9_upvw, 120, 0.2, 2)
		end
	end)
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Punch"):Once(function() -- Line 125
		--[[ Upvalues[11]:
			[1]: var9_upvw (read and write)
			[2]: any_LoadAnimation_result1_upvr (readonly)
			[3]: var10_upvw (read and write)
			[4]: var3_upvw (copied, read and write)
			[5]: arg1 (readonly)
			[6]: var11_upvw (read and write)
			[7]: PlayerStatus_upvr (copied, readonly)
			[8]: Anguish_upvr (readonly)
			[9]: HumanoidRootPart_upvr (readonly)
			[10]: Folder_upvr (readonly)
			[11]: DeathEffects_upvr (readonly)
		]]
		if not var9_upvw then
			any_LoadAnimation_result1_upvr:Stop()
		else
			any_LoadAnimation_result1_upvr:AdjustSpeed(0)
			var10_upvw:AdjustSpeed(0)
			var3_upvw.impactFrame(var9_upvw, 0.1)
			var3_upvw.impactFrame(arg1, 0.1)
			var3_upvw.camShake(arg1, "SmallBump")
			var3_upvw.changeFov(arg1, 35, 0, 0.1)
			var3_upvw.camShake(var9_upvw, "SmallBump")
			var3_upvw.changeFov(var9_upvw, 35, 0, 0.1)
			task.wait(0.1)
			var3_upvw.flashScreen(arg1, Color3.new(1, 0.145098, 0.145098), 1)
			any_LoadAnimation_result1_upvr:AdjustSpeed(1)
			var10_upvw:AdjustSpeed(1)
			var3_upvw.applyDebris(var11_upvw, 0)
			PlayerStatus_upvr.ClearStatus(var9_upvw)
			var3_upvw.applySound(Anguish_upvr.PunchSFX, HumanoidRootPart_upvr, 6)
			var3_upvw.applyStatus(arg1, "Stunned", 0.5)
			var3_upvw.applyStatus(arg1, "AutoRotate", 0.5)
			var3_upvw.applyDamage(var9_upvw, 12, true, false)
			var3_upvw.Knockback(var9_upvw, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -1000, 100, 35)
			var3_upvw.applyStatus(var9_upvw, "Ragdoll", 3.2)
			var3_upvw.camShake(arg1, "BigBump")
			var3_upvw.changeFov(arg1, 35, 0, 0.5)
			var3_upvw.impactFrame2(arg1)
			var3_upvw.camShake(var9_upvw, "BigBump")
			var3_upvw.changeFov(var9_upvw, 35, 0, 0.5)
			var3_upvw.impactFrame2(var9_upvw)
			DeathEffects_upvr(var9_upvw)
		end
	end)
	local var28_upvw = false
	local any_applyStatus_result1_upvr_2 = var3_upvw.applyStatus(arg1, "Stunned", 8)
	local any_applyStatus_result1_upvr = var3_upvw.applyStatus(arg1, "IFrames", 8)
	any_LoadAnimation_result1_upvr.Stopped:Once(function() -- Line 176
		--[[ Upvalues[7]:
			[1]: var28_upvw (read and write)
			[2]: var3_upvw (copied, read and write)
			[3]: any_applyStatus_result1_upvr_2 (readonly)
			[4]: arg1 (readonly)
			[5]: any_applyStatus_result1_upvr (readonly)
			[6]: var12_upvw (read and write)
			[7]: var13_upvw (read and write)
		]]
		var28_upvw = true
		var3_upvw.applyDebris(any_applyStatus_result1_upvr_2, 0, arg1)
		var3_upvw.applyDebris(any_applyStatus_result1_upvr, 0, arg1)
		for _, v in var12_upvw:GetDescendants() do
			if v:IsA("ParticleEmitter") or v:IsA("PointLight") then
				v.Enabled = false
			end
		end
		if var13_upvw then
			for _, v_2 in var13_upvw:GetDescendants() do
				if v_2:IsA("ParticleEmitter") or v_2:IsA("PointLight") then
					v_2.Enabled = false
				end
			end
		end
	end)
	var3_upvw.changeFov(arg1, 60, 0.3, 5)
	local var43_upvw
	var43_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_3, arg2_2, arg3) -- Line 199
		--[[ Upvalues[12]:
			[1]: arg2 (readonly)
			[2]: PlayerStatus_upvr (copied, readonly)
			[3]: var43_upvw (read and write)
			[4]: var9_upvw (read and write)
			[5]: var3_upvw (copied, read and write)
			[6]: Anguish_upvr (readonly)
			[7]: HumanoidRootPart_upvr (readonly)
			[8]: var13_upvw (read and write)
			[9]: arg1 (readonly)
			[10]: var10_upvw (read and write)
			[11]: any_LoadAnimation_result1_upvr (readonly)
			[12]: var11_upvw (read and write)
		]]
		if arg1_3 ~= arg2 or arg2_2 ~= "Anguish" then
		else
			if PlayerStatus_upvr.FindStatus(arg3, "IFrames") then return end
			var43_upvw:Disconnect()
			var9_upvw = arg3
			var3_upvw.CheckBlock(arg3, true)
			for _, v_5 in arg3.Humanoid.Animator:GetPlayingAnimationTracks() do
				v_5:Stop(0)
			end
			var3_upvw.applySound(Anguish_upvr.GrabSFX, HumanoidRootPart_upvr, 5)
			var13_upvw = Anguish_upvr.DragVFXTarget:Clone()
			var13_upvw.Parent = arg1
			var13_upvw.weld.Part0 = arg1.Torso
			var13_upvw.weld.Part1 = var13_upvw
			var3_upvw.applyDebris(var13_upvw, 6)
			var3_upvw.unragdoll(var9_upvw)
			var10_upvw = var9_upvw.Humanoid.Animator:LoadAnimation(Anguish_upvr.TargetAnimation)
			var10_upvw:Play(0)
			var10_upvw.TimePosition = any_LoadAnimation_result1_upvr.TimePosition
			var3_upvw.applyStatus(var9_upvw, "Stunned", 8)
			var3_upvw.applyStatus(var9_upvw, "AutoRotate", 8)
			var3_upvw.applyStatus(var9_upvw, "IFrames", 8)
			var11_upvw = var3_upvw.applyWeld(var9_upvw, Vector3.new(0, 0, 3), Vector3.new(0, 180, 0), 8)
			var3_upvw.camShake(var9_upvw, "SmallBump")
			var3_upvw.changeFov(var9_upvw, 78, 0.05, 0.5)
			var3_upvw.applyDamage(var9_upvw, 2, true, true)
			var3_upvw.camShake(arg1, "SmallBump")
			var3_upvw.changeFov(arg1, 78, 0.05, 0.5)
		end
	end), 10)
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 120, 0.25, 2)
	any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("Land"):Once(function() -- Line 245
		--[[ Upvalues[9]:
			[1]: var12_upvw (read and write)
			[2]: Anguish_upvr (readonly)
			[3]: arg1 (readonly)
			[4]: var3_upvw (copied, read and write)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: var28_upvw (read and write)
			[8]: var15_upvw (read and write)
			[9]: var9_upvw (read and write)
		]]
		var12_upvw = Anguish_upvr.DragVFX:Clone()
		var12_upvw.Parent = arg1
		var12_upvw.weld.Part0 = arg1.Torso
		var12_upvw.weld.Part1 = var12_upvw
		var3_upvw.applyDebris(var12_upvw, 6)
		local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position, Vector3.new(0, -6, 0), var3_upvw.raycastParams)
		if workspace_Raycast_result1 then
			var3_upvw.applyVFX(Anguish_upvr.LandVFX, Folder_upvr, 5, CFrame.new(workspace_Raycast_result1.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5 + Vector3.new(0, 0.5, 0)) * Anguish_upvr.LandVFX.CFrame - Anguish_upvr.LandVFX.CFrame.p)
		end
		var3_upvw.crater(1, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 5, 2.5, 0.8)
		var3_upvw.applySound(Anguish_upvr.Earthquake, HumanoidRootPart_upvr, 12)
		while task.wait(0.2) and not var28_upvw and not var15_upvw do
			if var9_upvw and var9_upvw.Parent then
				var3_upvw.camShake(var9_upvw, "SmallBump")
				var3_upvw.changeFov(var9_upvw, 78, 0.05, 0.5)
				var3_upvw.applyDamage(var9_upvw, 2, true, true)
			end
			var3_upvw.camShake(arg1, "SmallBump")
			var3_upvw.changeFov(arg1, 78, 0.05, 0.5)
		end
	end)
end
return module_upvr
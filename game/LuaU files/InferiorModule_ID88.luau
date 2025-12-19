-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:18:15
-- Luau version 6, Types version 3
-- Time taken: 0.013264 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 25
module_upvr.GlobalCD = 1.4
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 13
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder.Name = arg1.Name
	game.Debris:AddItem(Folder, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Inferior_upvr = ReplicatedStorage_upvr.Skills["Titans Edge"].Inferior
	var3_upvw.applyStatus(arg1, "Freeze", 1.75)
	var3_upvw.applyStatus(arg1, "GlobalCD", 1.75)
	var3_upvw.applyStatus(arg1, "AutoRotate", 1.75)
	var3_upvw.applyStatus(arg1, "IFrames", 0.5)
	task.wait(0.05)
	local clone_7 = Inferior_upvr.VFX.DashShockwave:Clone()
	clone_7.Parent = HumanoidRootPart_upvr
	var3_upvw.EmitAllDescendants(clone_7)
	var3_upvw.applyDebris(clone_7, 5)
	local any_LoadAnimation_result1_2_upvr = Humanoid_upvr.Animator:LoadAnimation(Inferior_upvr.Animation)
	any_LoadAnimation_result1_2_upvr:Play(0.05)
	any_LoadAnimation_result1_2_upvr:AdjustSpeed(0.65)
	var3_upvw.applySound(Inferior_upvr.Dash, HumanoidRootPart_upvr, 4)
	local any_applySound_result1_upvr = var3_upvw.applySound(Inferior_upvr.Dash2, HumanoidRootPart_upvr, 4)
	task.delay(1, function() -- Line 46
		--[[ Upvalues[2]:
			[1]: TweenService_upvr (copied, readonly)
			[2]: any_applySound_result1_upvr (readonly)
		]]
		TweenService_upvr:Create(any_applySound_result1_upvr, TweenInfo.new(0.75), {
			Volume = 0;
		}):Play()
	end)
	var3_upvw.changeFov(arg1, 60, 0.01, 1)
	var3_upvw.camShake(arg1, "SmallBump")
	local var15_upvw
	local var16_upvw
	local tbl_upvr = {}
	local tbl_upvr_2 = {}
	local var20_upvw
	var3_upvw.conTimer(var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3, arg4) -- Line 60
		--[[ Upvalues[11]:
			[1]: arg2 (readonly)
			[2]: PlayerStatus_upvr (copied, readonly)
			[3]: var16_upvw (read and write)
			[4]: var20_upvw (read and write)
			[5]: var3_upvw (copied, read and write)
			[6]: any_LoadAnimation_result1_2_upvr (readonly)
			[7]: arg1 (readonly)
			[8]: Inferior_upvr (readonly)
			[9]: tbl_upvr_2 (readonly)
			[10]: tbl_upvr (readonly)
			[11]: var15_upvw (read and write)
		]]
		if arg1_2 ~= arg2 or arg2_2 ~= "Inferior" then
		else
			if arg3 and not arg3:FindFirstChild("Inferior") and not PlayerStatus_upvr.FindStatus(arg3, "IFrames") then
				var16_upvw = arg3
			end
			var20_upvw = arg4
			if not arg3:FindFirstChild("Inferior") and not PlayerStatus_upvr.FindStatus(arg3, "IFrames") then
				var3_upvw.unragdoll(var16_upvw)
				any_LoadAnimation_result1_2_upvr:AdjustSpeed(1)
				var3_upvw.CheckBlock(var16_upvw, true)
				var3_upvw.changeFov(arg1, 50, 0.01, 1)
				var3_upvw.camShake(arg1, "Bump")
				var3_upvw.applyDamage(var16_upvw, 5, false, true)
				var3_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 0.8)
				task.wait(0.1)
				for _, v_3 in var16_upvw.Humanoid:GetPlayingAnimationTracks() do
					v_3:Stop()
				end
				local clone_6 = Inferior_upvr.VFX.ShoveVFX:Clone()
				clone_6.Parent = var16_upvw.HumanoidRootPart
				var3_upvw.EmitAllDescendants(clone_6)
				var3_upvw.applyDebris(clone_6, 5)
				var16_upvw.Humanoid:LoadAnimation(Inferior_upvr.EnemyAnimation):Play()
				table.insert(tbl_upvr_2, var3_upvw.applyStatus(var16_upvw, "Stunned", 4))
				table.insert(tbl_upvr_2, var3_upvw.applyStatus(var16_upvw, "AutoRotate", 4))
				table.insert(tbl_upvr_2, var3_upvw.applyStatus(var16_upvw, "IFrames", 4))
				table.insert(tbl_upvr, var3_upvw.applyStatus(arg1, "IFrames", 4))
				var3_upvw.applySound(Inferior_upvr.punch, var16_upvw.Torso, 3)
				var3_upvw.applySound(Inferior_upvr.Shove, var16_upvw.Torso, 3)
				var3_upvw.applySound(Inferior_upvr.WindBlow, var16_upvw.Torso, 3)
				task.wait()
				var15_upvw = var3_upvw.applyWeld(var16_upvw, Vector3.new(0, 0, 4), Vector3.new(0, 180, 0), 3)
				local Folder_2 = Instance.new("Folder", arg3)
				Folder_2.Name = "Inferior"
				var3_upvw.applyDebris(Folder_2, 3)
			end
		end
	end), module_upvr.Cooldown), 3)
	var3_upvw.conTimer(any_LoadAnimation_result1_2_upvr:GetMarkerReachedSignal("end"):Connect(function() -- Line 116
		--[[ Upvalues[12]:
			[1]: any_LoadAnimation_result1_2_upvr (readonly)
			[2]: var16_upvw (read and write)
			[3]: Humanoid_upvr (readonly)
			[4]: Inferior_upvr (readonly)
			[5]: var3_upvw (copied, read and write)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: module_upvr (copied, readonly)
			[8]: var15_upvw (read and write)
			[9]: tbl_upvr (readonly)
			[10]: PlayerStatus_upvr (copied, readonly)
			[11]: arg1 (readonly)
			[12]: tbl_upvr_2 (readonly)
		]]
		any_LoadAnimation_result1_2_upvr:AdjustSpeed(1)
		if var16_upvw then
			local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Inferior_upvr.Animation2)
			any_LoadAnimation_result1:Play()
			var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_3) -- Line 123
				--[[ Upvalues[3]:
					[1]: Inferior_upvr (copied, readonly)
					[2]: HumanoidRootPart_upvr (copied, readonly)
					[3]: var3_upvw (copied, read and write)
				]]
				local clone_5 = Inferior_upvr:FindFirstChild(arg1_3):Clone()
				clone_5.Parent = HumanoidRootPart_upvr
				clone_5:Play()
				var3_upvw.applyDebris(clone_5, 8)
			end), module_upvr.Cooldown)
			var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 130
				--[[ Upvalues[9]:
					[1]: var3_upvw (copied, read and write)
					[2]: var16_upvw (copied, read and write)
					[3]: var15_upvw (copied, read and write)
					[4]: tbl_upvr (copied, readonly)
					[5]: PlayerStatus_upvr (copied, readonly)
					[6]: arg1 (copied, readonly)
					[7]: tbl_upvr_2 (copied, readonly)
					[8]: Inferior_upvr (copied, readonly)
					[9]: HumanoidRootPart_upvr (copied, readonly)
				]]
				var3_upvw.CheckBlock(var16_upvw, true)
				var15_upvw:Destroy()
				for _, v in tbl_upvr do
					PlayerStatus_upvr.RemoveStatus(arg1, v)
				end
				for _, v_2 in tbl_upvr_2 do
					PlayerStatus_upvr.RemoveStatus(var16_upvw, v_2)
				end
				task.wait()
				local clone = Inferior_upvr.VFX.punchVFX2:Clone()
				clone.Parent = HumanoidRootPart_upvr
				var3_upvw.EmitAllDescendants(clone)
				var3_upvw.applyDebris(clone, 5)
				local clone_4 = Inferior_upvr.VFX.ShockwaveVFX:Clone()
				clone_4.Parent = HumanoidRootPart_upvr
				var3_upvw.EmitAllDescendants(clone_4)
				var3_upvw.applyDebris(clone_4, 5)
				local clone_3 = Inferior_upvr.VFX.hitVFX:Clone()
				clone_3.Parent = var16_upvw.HumanoidRootPart
				var3_upvw.EmitAllDescendants(clone_3)
				var3_upvw.applyDebris(clone_3, 5)
				local clone_2 = Inferior_upvr.VFX.SlashVFX:Clone()
				clone_2.Parent = HumanoidRootPart_upvr
				var3_upvw.EmitAllDescendants(clone_2)
				var3_upvw.applyDebris(clone_2, 5)
				task.delay(0.2, function() -- Line 165
					--[[ Upvalues[3]:
						[1]: var3_upvw (copied, read and write)
						[2]: Inferior_upvr (copied, readonly)
						[3]: HumanoidRootPart_upvr (copied, readonly)
					]]
					var3_upvw.applySound(Inferior_upvr.Shine, HumanoidRootPart_upvr, 5)
				end)
				var3_upvw.applySound(Inferior_upvr.GreatswordHit, HumanoidRootPart_upvr, 5)
				var3_upvw.applySound(Inferior_upvr.Shockwave, HumanoidRootPart_upvr, 6)
				var3_upvw.applySound(Inferior_upvr.GreatswordHit2, var16_upvw.Torso, 5)
				var3_upvw.applyStatus(var16_upvw, "Ragdoll", 2)
				var3_upvw.Knockback(var16_upvw, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -5, 60)
				var3_upvw.applyDamage(var16_upvw, 10)
				var3_upvw.changeFov(arg1, 5, 0.01, 0.3)
				var3_upvw.Blur(arg1, 20, 1)
				var3_upvw.camShake(arg1, "BigBump")
			end), module_upvr.Cooldown)
			var3_upvw.applySound(Inferior_upvr.Charge, HumanoidRootPart_upvr, 5)
			task.delay(1, function() -- Line 182
				--[[ Upvalues[3]:
					[1]: var3_upvw (copied, read and write)
					[2]: Inferior_upvr (copied, readonly)
					[3]: HumanoidRootPart_upvr (copied, readonly)
				]]
				var3_upvw.applySound(Inferior_upvr.SwordSwing, HumanoidRootPart_upvr, 5)
				task.wait(0.5)
				var3_upvw.applySound(Inferior_upvr.TitanSlash, HumanoidRootPart_upvr, 5)
			end)
			var3_upvw.changeFov(arg1, 25, 1, 3)
			var3_upvw.Blur(arg1, 20, 1)
			var3_upvw.applyStatus(var16_upvw, "Stunned", 3)
			var3_upvw.applyStatus(var16_upvw, "AutoRotate", 3)
			var3_upvw.applyStatus(arg1, "Freeze", 2.5)
			var3_upvw.applyStatus(arg1, "GlobalCD", 2.5)
			var3_upvw.applyStatus(arg1, "AutoRotate", 2.5)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
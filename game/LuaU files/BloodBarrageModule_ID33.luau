-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:11
-- Luau version 6, Types version 3
-- Time taken: 0.020088 seconds

local module_upvr = {
	Cooldown = 15;
	GlobalCD = 3.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 16
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
	local Blood_Barrage_upvr = ReplicatedStorage_upvr.Skills["Blood Sword"].Ultimate["Blood Barrage"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Blood_Barrage_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(0.7)
	var2_upvw.applySound(Blood_Barrage_upvr.Charge, HumanoidRootPart_upvr)
	var2_upvw.applyStatus(arg1, "Slowed", 4.4)
	local clone_7_upvr = Blood_Barrage_upvr.bloodEmit.ChargeVFX:Clone()
	clone_7_upvr.Parent = HumanoidRootPart_upvr
	var2_upvw.applyDebris(clone_7_upvr, 3)
	task.delay(0.4, function() -- Line 42
		--[[ Upvalues[1]:
			[1]: clone_7_upvr (readonly)
		]]
		for _, v in clone_7_upvr:GetChildren() do
			v.Enabled = false
		end
	end)
	for _ = 1, 33.333333333333336 do
		var2_upvw.camShake(arg1, "SmallBump")
		task.wait()
	end
	if not any_LoadAnimation_result1.IsPlaying then
	else
		any_LoadAnimation_result1:AdjustSpeed(1)
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 68, 0, 1)
		local clone_3 = Blood_Barrage_upvr.bloodEmit.HitVFX:Clone()
		clone_3.Parent = HumanoidRootPart_upvr
		var2_upvw.EmitAllDescendants(clone_3)
		var2_upvw.applyDebris(clone_3, 7)
		local clone_5 = Blood_Barrage_upvr.Whoosh:Clone()
		clone_5.Parent = HumanoidRootPart_upvr
		clone_5:Play()
		var2_upvw.applyDebris(clone_5, 3)
		local function _() -- Line 70, Named "swingSFX"
			--[[ Upvalues[3]:
				[1]: Blood_Barrage_upvr (readonly)
				[2]: HumanoidRootPart_upvr (readonly)
				[3]: var2_upvw (copied, read and write)
			]]
			task.delay(0.2, function() -- Line 71
				--[[ Upvalues[3]:
					[1]: Blood_Barrage_upvr (copied, readonly)
					[2]: HumanoidRootPart_upvr (copied, readonly)
					[3]: var2_upvw (copied, read and write)
				]]
				local clone_6 = Blood_Barrage_upvr.Swing:Clone()
				clone_6.Parent = HumanoidRootPart_upvr
				clone_6.PlaybackSpeed += math.random(-2, 2) * 0.05
				clone_6:Play()
				var2_upvw.applyDebris(clone_6, 3)
				task.delay(0.15, function() -- Line 78
					--[[ Upvalues[3]:
						[1]: Blood_Barrage_upvr (copied, readonly)
						[2]: HumanoidRootPart_upvr (copied, readonly)
						[3]: var2_upvw (copied, read and write)
					]]
					local clone_4 = Blood_Barrage_upvr.Blood:Clone()
					clone_4.Parent = HumanoidRootPart_upvr
					clone_4.PlaybackSpeed += math.random(-2, 2) * 0.05
					clone_4:Play()
					var2_upvw.applyDebris(clone_4, 3)
					local clone_12 = Blood_Barrage_upvr.Swing2:Clone()
					clone_12.Parent = HumanoidRootPart_upvr
					clone_12.PlaybackSpeed += math.random(-2, 2) * 0.05
					clone_12:Play()
					var2_upvw.applyDebris(clone_12, 3)
				end)
			end)
		end
		task.delay(0.15, function() -- Line 94
			--[[ Upvalues[3]:
				[1]: Blood_Barrage_upvr (readonly)
				[2]: HumanoidRootPart_upvr (readonly)
				[3]: var2_upvw (copied, read and write)
			]]
			task.delay(0.2, function() -- Line 71
				--[[ Upvalues[3]:
					[1]: Blood_Barrage_upvr (copied, readonly)
					[2]: HumanoidRootPart_upvr (copied, readonly)
					[3]: var2_upvw (copied, read and write)
				]]
				local clone_10 = Blood_Barrage_upvr.Swing:Clone()
				clone_10.Parent = HumanoidRootPart_upvr
				clone_10.PlaybackSpeed += math.random(-2, 2) * 0.05
				clone_10:Play()
				var2_upvw.applyDebris(clone_10, 3)
				task.delay(0.15, function() -- Line 78
					--[[ Upvalues[3]:
						[1]: Blood_Barrage_upvr (copied, readonly)
						[2]: HumanoidRootPart_upvr (copied, readonly)
						[3]: var2_upvw (copied, read and write)
					]]
					local clone_13 = Blood_Barrage_upvr.Blood:Clone()
					clone_13.Parent = HumanoidRootPart_upvr
					clone_13.PlaybackSpeed += math.random(-2, 2) * 0.05
					clone_13:Play()
					var2_upvw.applyDebris(clone_13, 3)
					local clone_14 = Blood_Barrage_upvr.Swing2:Clone()
					clone_14.Parent = HumanoidRootPart_upvr
					clone_14.PlaybackSpeed += math.random(-2, 2) * 0.05
					clone_14:Play()
					var2_upvw.applyDebris(clone_14, 3)
				end)
			end)
		end)
		local var32_upvw = 0
		local var33_upvw = 1
		var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function() -- Line 100
			--[[ Upvalues[10]:
				[1]: var32_upvw (read and write)
				[2]: Blood_Barrage_upvr (readonly)
				[3]: HumanoidRootPart_upvr (readonly)
				[4]: var2_upvw (copied, read and write)
				[5]: Folder_upvr (readonly)
				[6]: var33_upvw (read and write)
				[7]: arg1 (readonly)
				[8]: TweenService_upvr (copied, readonly)
				[9]: RunService_upvr (copied, readonly)
				[10]: module_upvr (copied, readonly)
			]]
			var32_upvw += 1
			if var32_upvw ~= 9 then
				task.delay(0.2, function() -- Line 71
					--[[ Upvalues[3]:
						[1]: Blood_Barrage_upvr (copied, readonly)
						[2]: HumanoidRootPart_upvr (copied, readonly)
						[3]: var2_upvw (copied, read and write)
					]]
					local clone = Blood_Barrage_upvr.Swing:Clone()
					clone.Parent = HumanoidRootPart_upvr
					clone.PlaybackSpeed += math.random(-2, 2) * 0.05
					clone:Play()
					var2_upvw.applyDebris(clone, 3)
					task.delay(0.15, function() -- Line 78
						--[[ Upvalues[3]:
							[1]: Blood_Barrage_upvr (copied, readonly)
							[2]: HumanoidRootPart_upvr (copied, readonly)
							[3]: var2_upvw (copied, read and write)
						]]
						local clone_11 = Blood_Barrage_upvr.Blood:Clone()
						clone_11.Parent = HumanoidRootPart_upvr
						clone_11.PlaybackSpeed += math.random(-2, 2) * 0.05
						clone_11:Play()
						var2_upvw.applyDebris(clone_11, 3)
						local clone_8 = Blood_Barrage_upvr.Swing2:Clone()
						clone_8.Parent = HumanoidRootPart_upvr
						clone_8.PlaybackSpeed += math.random(-2, 2) * 0.05
						clone_8:Play()
						var2_upvw.applyDebris(clone_8, 3)
					end)
				end)
			end
			local var39_upvw = true
			local clone_9_upvr = Blood_Barrage_upvr.BloodSlash:Clone()
			clone_9_upvr.Parent = Folder_upvr
			clone_9_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 1
			var2_upvw.applyDebris(clone_9_upvr, 5)
			task.delay(1.6, function() -- Line 112
				--[[ Upvalues[2]:
					[1]: clone_9_upvr (readonly)
					[2]: var39_upvw (read and write)
				]]
				for _, v_2 in clone_9_upvr:GetDescendants() do
					if v_2:IsA("BasePart") then
						v_2.Transparency = 1
					elseif v_2:IsA("ParticleEmitter") then
						v_2.Enabled = false
					end
				end
				var39_upvw = false
			end)
			if var33_upvw == 1 then
				var33_upvw = 2
				clone_9_upvr.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 1) * CFrame.Angles(0, 0, 0.7853981633974483)
			elseif var33_upvw == 2 then
				var33_upvw = 1
				clone_9_upvr.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 1) * CFrame.Angles(0, 0, -0.7853981633974483)
			end
			var2_upvw.changeFov(arg1, 50, 0.01, 1)
			var2_upvw.flashScreen(arg1, Color3.new(0.501961, 0.282353, 0.282353), 0.6)
			TweenService_upvr:Create(clone_9_upvr, TweenInfo.new(1.5), {
				CFrame = clone_9_upvr.CFrame + clone_9_upvr.CFrame.LookVector * 200;
			}):Play()
			task.delay(0.6, function() -- Line 136
				--[[ Upvalues[2]:
					[1]: clone_9_upvr (readonly)
					[2]: TweenService_upvr (copied, readonly)
				]]
				for _, v_3 in clone_9_upvr:GetChildren() do
					if v_3:IsA("BasePart") then
						TweenService_upvr:Create(v_3, TweenInfo.new(0.5), {
							Transparency = 1;
						}):Play()
					end
				end
				for _, v_4 in clone_9_upvr:GetDescendants() do
					if v_4:IsA("ParticleEmitter") then
						v_4.Enabled = false
					end
				end
			end)
			local var61_upvw
			local tbl_upvr = {}
			var61_upvw = var2_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 153
				--[[ Upvalues[7]:
					[1]: clone_9_upvr (readonly)
					[2]: var39_upvw (read and write)
					[3]: var61_upvw (read and write)
					[4]: var2_upvw (copied, read and write)
					[5]: tbl_upvr (readonly)
					[6]: Blood_Barrage_upvr (copied, readonly)
					[7]: HumanoidRootPart_upvr (copied, readonly)
				]]
				if not clone_9_upvr.Parent or not var39_upvw then
					var61_upvw:Disconnect()
				else
					for _, var64 in var2_upvw.findEnemiesPart(clone_9_upvr.Hitbox), nil do
						if not table.find(tbl_upvr, var64) then
							table.insert(tbl_upvr, var64)
							local clone_2 = Blood_Barrage_upvr.VFX.BloodSplat:Clone()
							clone_2.Parent = var64.HumanoidRootPart
							var2_upvw.EmitAllDescendants(clone_2)
							clone_2.HitSFX:Play()
							clone_2.HitSFX2:Play()
							var2_upvw.applyDebris(clone_2, 5)
							var2_upvw.Knockback(var64, HumanoidRootPart_upvr.Position, 25, 0)
							var2_upvw.applyDamage(var64, 4)
							var2_upvw.applyStatus(var64, "Stunned", 1.5)
							var2_upvw.applyStatus(var64, "AutoRotate", 1.5)
							var64.HumanoidRootPart.CFrame = CFrame.lookAt(var64.HumanoidRootPart.Position, HumanoidRootPart_upvr.Position)
							var2_upvw.blood(var64, 3)
							var2_upvw.Blur(var64, 25, 0.6)
							var2_upvw.camShake(var64, "Bump")
						end
					end
				end
			end), module_upvr.Cooldown)
		end), module_upvr.Cooldown)
	end
end
return module_upvr
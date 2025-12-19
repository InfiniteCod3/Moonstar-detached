-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:13:12
-- Luau version 6, Types version 3
-- Time taken: 0.015343 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 17
module_upvr.GlobalCD = 1
local var3_upvw
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 16
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: PlayerStatus_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Clutch_upvr = ReplicatedStorage_upvr.Skills["Blood Sword"].Ultimate.Clutch
	for _, v in Humanoid:GetPlayingAnimationTracks() do
		v:Stop(0)
	end
	local any_LoadAnimation_result1 = Humanoid.Animator:LoadAnimation(Clutch_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(1)
	any_LoadAnimation_result1.Priority = Enum.AnimationPriority.Action3
	var3_upvw.applyStatus(arg1, "Slowed", 1.5)
	var3_upvw.applyStatus(arg1, "GlobalCD", 1.5)
	var3_upvw.changeFov(arg1, 72, 1, 5)
	var3_upvw.applySound(Clutch_upvr.Charge, HumanoidRootPart_upvr)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("clutch"):Connect(function() -- Line 47
		--[[ Upvalues[6]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: Clutch_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: HumanoidRootPart_upvr (readonly)
			[6]: PlayerStatus_upvr (copied, readonly)
		]]
		var3_upvw.applyStatus(arg1, "Freeze", 0.6)
		var3_upvw.applyStatus(arg1, "GlobalCD", 0.6)
		local clone = Clutch_upvr.ClutchVFX:Clone()
		clone.Parent = Folder_upvr
		clone.CFrame = HumanoidRootPart_upvr.CFrame
		var3_upvw.EmitAllDescendants(clone)
		var3_upvw.applyDebris(clone, 10)
		var3_upvw.applySound(Clutch_upvr.Cast1, clone.Hitbox)
		var3_upvw.applySound(Clutch_upvr.Cast2, clone.Hitbox)
		var3_upvw.applySound(Clutch_upvr.Cast3, clone.Hitbox)
		var3_upvw.applySound(Clutch_upvr.Cast4, clone.Hitbox)
		var3_upvw.applySound(Clutch_upvr.Cast5, clone.Hitbox)
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 90, 0, 2)
		var3_upvw.Blur(arg1, 10, 2)
		for _, v_2_upvr in var3_upvw.findEnemiesPart(clone.Hitbox, true), nil do
			task.spawn(function() -- Line 69
				--[[ Upvalues[7]:
					[1]: var3_upvw (copied, read and write)
					[2]: v_2_upvr (readonly)
					[3]: Clutch_upvr (copied, readonly)
					[4]: HumanoidRootPart_upvr (copied, readonly)
					[5]: Folder_upvr (copied, readonly)
					[6]: PlayerStatus_upvr (copied, readonly)
					[7]: arg1 (copied, readonly)
				]]
				if not var3_upvw.CheckBlock(v_2_upvr, true) then
					var3_upvw.unragdoll(v_2_upvr)
					task.wait(0.1)
					local clone_3 = Clutch_upvr.HitVFX.Att:Clone()
					clone_3.Parent = v_2_upvr.Torso
					var3_upvw.EmitAllDescendants(clone_3)
					var3_upvw.applyDebris(clone_3, 5)
					var3_upvw.applyDamage(v_2_upvr, 10)
					var3_upvw.Knockback(v_2_upvr, HumanoidRootPart_upvr.Position, math.random(-5, 5), math.random(120, 200))
					local clone_2 = Clutch_upvr.Cacoon:Clone()
					clone_2.Parent = Folder_upvr
					clone_2.CFrame = v_2_upvr.Torso.CFrame
					clone_2.Weld.Part0 = v_2_upvr.Torso
					clone_2.Weld.Part1 = clone_2
					task.spawn(function() -- Line 99
						--[[ Upvalues[3]:
							[1]: v_2_upvr (copied, readonly)
							[2]: var3_upvw (copied, read and write)
							[3]: PlayerStatus_upvr (copied, readonly)
						]]
						-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
						task.wait(0.8)
						local HumanoidRootPart = v_2_upvr.HumanoidRootPart
						repeat
							task.wait(0.05)
							var3_upvw.applyStatus(v_2_upvr, "AutoRotate", 0.5)
							var3_upvw.applyStatus(v_2_upvr, "Freeze", 0.5)
							var3_upvw.applyStatus(v_2_upvr, "IFrames", 0.15)
							var3_upvw.applyStatus(v_2_upvr, "GlobalCD", 0.5)
							local var24
							if game.Players:FindFirstChild(v_2_upvr.Name) then
								var24 = workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -3, 0), var3_upvw.raycastParams)
							else
								var24 = workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -3, 0), var3_upvw.raycastParams)
							end
							if var24 and var24.Position.Y < HumanoidRootPart.Position.Y then
								local var25 = false
								local var26
							end
							if var25 == true then
								if (HumanoidRootPart.Position - v_2_upvr.HumanoidRootPart.Position).Magnitude <= 1 then
									var26 += 1
								end
								if var26 == 20 then break end
							end
						until var25 == false and not v_2_upvr.Parent and not PlayerStatus_upvr.FindStatus(v_2_upvr, "Ragdoll")
						if not PlayerStatus_upvr.FindStatus(v_2_upvr, "Ragdoll") then
						else
							PlayerStatus_upvr.ClearStatus(v_2_upvr)
						end
					end)
					repeat
						task.wait()
					until not PlayerStatus_upvr.FindStatus(v_2_upvr, "Ragdoll") and not v_2_upvr.Parent
					var3_upvw.camShake(arg1, "Bump")
					var3_upvw.applyDebris(clone_2, 0.1)
					clone_2.Transparency = 1
					clone_2.bloodBall.Transparency = 1
					local clone_4 = Clutch_upvr.SmashVFX:Clone()
					clone_4.Parent = Folder_upvr
					clone_4.CFrame = clone_2.CFrame
					var3_upvw.EmitAllDescendants(clone_4)
					var3_upvw.applyDebris(clone_4, 6)
					var3_upvw.applySound(Clutch_upvr.Explode1, clone_4)
					var3_upvw.applySound(Clutch_upvr.Explode2, clone_4)
					var3_upvw.applySound(Clutch_upvr.Explode3, clone_4)
					var3_upvw.applySound(Clutch_upvr.Explode4, clone_4)
					if not v_2_upvr.Parent then return end
					clone_2.Weld.Part0 = nil
					var3_upvw.applyStatus(v_2_upvr, "Ragdoll", 3)
					var3_upvw.applyDamage(v_2_upvr, 20)
				end
			end)
		end
	end), module_upvr.Cooldown)
end
return module_upvr
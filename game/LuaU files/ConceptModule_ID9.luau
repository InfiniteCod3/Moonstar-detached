-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:55
-- Luau version 6, Types version 3
-- Time taken: 0.024176 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 20
module_upvr.GlobalCD = 1.4
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local RunService_upvr = game:GetService("RunService")
function module_upvr.Script(arg1, arg2) -- Line 18
	--[[ Upvalues[5]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
		[5]: RunService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Concept_upvr = ReplicatedStorage_upvr.Skills["Basic Sword"].Ultimate.Concept
	var3_upvw.applyStatus(arg1, "Slowed", 1.5)
	var3_upvw.applyStatus(arg1, "GlobalCD", 1.5)
	local any_applyVFX_result1_upvr = var3_upvw.applyVFX(Concept_upvr.VFX.ChargeVFX, HumanoidRootPart_upvr)
	var3_upvw.applyDebris(any_applyVFX_result1_upvr, 3)
	local var11_upvw
	local any_applySound_result1_8_upvr = var3_upvw.applySound(Concept_upvr.Charge, HumanoidRootPart_upvr)
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	var11_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 42
		--[[ Upvalues[13]:
			[1]: arg2 (readonly)
			[2]: var11_upvw (read and write)
			[3]: any_applyVFX_result1_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: any_applySound_result1_8_upvr (readonly)
			[6]: var3_upvw (copied, read and write)
			[7]: Concept_upvr (readonly)
			[8]: arg1 (readonly)
			[9]: Folder_upvr (readonly)
			[10]: Humanoid_upvr (readonly)
			[11]: module_upvr (copied, readonly)
			[12]: TweenService_upvr (copied, readonly)
			[13]: RunService_upvr (copied, readonly)
		]]
		local var26
		if arg1_2 ~= arg2 or arg2_2 ~= "Concept" then
		else
			var11_upvw:Disconnect()
			local children, NONE_2, NONE = any_applyVFX_result1_upvr:GetChildren()
			for _, v in children, NONE_2, NONE do
				v.Enabled = false
			end
			NONE_2 = CFrame.new(arg3.TeleportPosition) * HumanoidRootPart_upvr.CFrame - HumanoidRootPart_upvr.CFrame.p
			HumanoidRootPart_upvr.CFrame = NONE_2
			any_applySound_result1_8_upvr:Stop()
			NONE_2 = var3_upvw
			NONE_2 = Concept_upvr.Jab
			NONE_2.applySound(NONE_2, HumanoidRootPart_upvr)
			NONE_2 = var3_upvw
			NONE_2 = Concept_upvr.Slash
			NONE_2.applySound(NONE_2, HumanoidRootPart_upvr)
			NONE_2 = var3_upvw
			NONE_2 = Concept_upvr.Unsheathe
			NONE_2.applySound(NONE_2, HumanoidRootPart_upvr)
			NONE_2 = var3_upvw
			NONE_2 = Concept_upvr.teleport
			NONE_2.applySound(NONE_2, HumanoidRootPart_upvr)
			NONE_2 = var3_upvw
			NONE_2 = arg1
			NONE_2.camShake(NONE_2, "Bump")
			NONE_2 = Concept_upvr
			local clone_2 = NONE_2.SlashVFX:Clone()
			NONE_2 = Folder_upvr
			clone_2.Parent = NONE_2
			NONE_2 = HumanoidRootPart_upvr.CFrame
			clone_2.CFrame = NONE_2
			NONE_2 = var3_upvw.EmitAllDescendants
			NONE_2(clone_2)
			NONE_2 = false
			for i_2, v_2 in var3_upvw.findEnemiesPart(clone_2.hitbox), nil do
				if not var3_upvw.CheckBlock(v_2) then
					NONE_2 = true
					var3_upvw.applyDamage(v_2, 5)
					var3_upvw.Knockback(v_2, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -25, 80)
					var3_upvw.applyStatus(v_2, "Stunned", 3)
					var3_upvw.applyStatus(v_2, "AutoRotate", 3)
					v_2.HumanoidRootPart.CFrame = CFrame.lookAt(v_2.HumanoidRootPart.Position, HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * -25)
					v_2.Humanoid:LoadAnimation(Concept_upvr.TargetAnimation):Play(0)
				end
			end
			if NONE_2 then
				i_2 = 2
				var3_upvw.applyStatus(arg1, "Freeze", i_2)
				i_2 = 2
				var3_upvw.applyStatus(arg1, "GlobalCD", i_2)
				task.delay(0.5, function() -- Line 87
					--[[ Upvalues[3]:
						[1]: var3_upvw (copied, read and write)
						[2]: Concept_upvr (copied, readonly)
						[3]: HumanoidRootPart_upvr (copied, readonly)
					]]
					var3_upvw.applySound(Concept_upvr.cloth, HumanoidRootPart_upvr)
				end)
				i_2 = Concept_upvr
				Humanoid_upvr:LoadAnimation(i_2.Animation2):Play()
				local tbl_upvr = {}
				i_2 = var3_upvw
				i_2 = Humanoid_upvr:LoadAnimation(i_2.Animation2):GetMarkerReachedSignal("slash")
				i_2 = i_2:Connect(function() -- Line 95
					--[[ Upvalues[6]:
						[1]: var3_upvw (copied, read and write)
						[2]: Concept_upvr (copied, readonly)
						[3]: HumanoidRootPart_upvr (copied, readonly)
						[4]: Folder_upvr (copied, readonly)
						[5]: tbl_upvr (readonly)
						[6]: arg1 (copied, readonly)
					]]
					local any_applySound_result1_6 = var3_upvw.applySound(Concept_upvr.SlashDash, HumanoidRootPart_upvr)
					any_applySound_result1_6.PlaybackSpeed += math.random(-2, 2) * 0.1
					local any_applySound_result1_2 = var3_upvw.applySound(Concept_upvr.cloth, HumanoidRootPart_upvr)
					any_applySound_result1_2.PlaybackSpeed += math.random(-2, 2) * 0.1
					local any_applySound_result1_4 = var3_upvw.applySound(Concept_upvr.dash, HumanoidRootPart_upvr)
					any_applySound_result1_4.PlaybackSpeed += math.random(-2, 2) * 0.1
					local any_applySound_result1_3 = var3_upvw.applySound(Concept_upvr.Dash2, HumanoidRootPart_upvr)
					any_applySound_result1_3.PlaybackSpeed += math.random(-2, 2) * 0.1
					local clone_3 = Concept_upvr.SlashVFX2:Clone()
					clone_3.Parent = Folder_upvr
					clone_3.CFrame = (HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 5) * CFrame.Angles(0, 0, math.rad(math.random(-180, 180)))
					var3_upvw.EmitAllDescendants(clone_3)
					table.insert(tbl_upvr, clone_3)
					var3_upvw.changeFov(arg1, 69.5, 0, 3)
					var3_upvw.camShake(arg1, "SmallBump")
				end)
				v_2 = module_upvr.Cooldown
				i_2.conTimer(i_2, v_2)
				i_2 = 2
				task.wait(i_2)
				i_2 = var3_upvw
				v_2 = Concept_upvr
				i_2 = v_2.Fire
				v_2 = HumanoidRootPart_upvr
				i_2.applySound(i_2, v_2)
				i_2 = var3_upvw
				v_2 = Concept_upvr
				i_2 = v_2.Fire2
				v_2 = HumanoidRootPart_upvr
				i_2.applySound(i_2, v_2)
				local function Explode_upvr(arg1_3) -- Line 123, Named "Explode"
					--[[ Upvalues[3]:
						[1]: Concept_upvr (copied, readonly)
						[2]: var3_upvw (copied, read and write)
						[3]: arg1 (copied, readonly)
					]]
					if arg1_3:GetAttribute("Exploded") then
					else
						arg1_3:SetAttribute("Exploded", true)
						arg1_3.Slash.Transparency = 1
						local clone = Concept_upvr.VFX.ExplodeVFX:Clone()
						clone.Parent = arg1_3
						var3_upvw.EmitAllDescendants(clone)
						var3_upvw.applyDebris(clone, 5)
						local any_applySound_result1_5 = var3_upvw.applySound(Concept_upvr.Slash2, clone)
						any_applySound_result1_5.PlaybackSpeed += math.random(-2, 2) * 0.1
						local any_applySound_result1 = var3_upvw.applySound(Concept_upvr.explode, clone)
						any_applySound_result1.PlaybackSpeed += math.random(-2, 2) * 0.1
						local any_applySound_result1_7 = var3_upvw.applySound(Concept_upvr.explode2, clone)
						any_applySound_result1_7.PlaybackSpeed += math.random(-2, 2) * 0.1
						var3_upvw.camShake(arg1, "SmallBump")
						for _, v_4_upvr in var3_upvw.findEnemiesMagnitude(arg1_3.Position, 20), nil do
							if not var3_upvw.CheckBlock(v_4_upvr) then
								var3_upvw.applyDamage(v_4_upvr, 5)
								var3_upvw.applyStatus(v_4_upvr, "Stunned", 1)
								task.delay(0.12, function() -- Line 152
									--[[ Upvalues[3]:
										[1]: var3_upvw (copied, read and write)
										[2]: v_4_upvr (readonly)
										[3]: arg1_3 (readonly)
									]]
									var3_upvw.applyStatus(v_4_upvr, "Ragdoll", 2)
									var3_upvw.Knockback(v_4_upvr, arg1_3.Position + arg1_3.CFrame.LookVector * -1000, 60, 20)
								end)
							end
						end
					end
				end
				i_2 = tbl_upvr
				v_2 = nil
				for _, v_3_upvr in i_2, v_2 do
					local var47 = v_3_upvr.Position + v_3_upvr.CFrame.LookVector * 250
					local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position, v_3_upvr.CFrame.LookVector * 250, var3_upvw.raycastParams)
					if workspace_Raycast_result1 then
						var47 = workspace_Raycast_result1.Position
					end
					local any_Create_result1 = TweenService_upvr:Create(v_3_upvr, TweenInfo.new(0.1 + (v_3_upvr.Position - var47).Magnitude * 0.005, Enum.EasingStyle.Linear), {
						CFrame = CFrame.new(var47) * v_3_upvr.CFrame - v_3_upvr.CFrame.p;
					})
					any_Create_result1:Play()
					local var52_upvw
					var52_upvw = var3_upvw.conTimer(RunService_upvr.Stepped:Connect(function() -- Line 171
						--[[ Upvalues[4]:
							[1]: var3_upvw (copied, read and write)
							[2]: v_3_upvr (readonly)
							[3]: var52_upvw (read and write)
							[4]: Explode_upvr (readonly)
						]]
						if 0 < #var3_upvw.findEnemiesPart(v_3_upvr.hitbox) then
							var52_upvw:Disconnect()
							Explode_upvr(v_3_upvr)
						end
					end), module_upvr.Cooldown)
					local var53_upvw = var52_upvw
					var3_upvw.conTimer(var53_upvw, 7)
					var3_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 177
						--[[ Upvalues[3]:
							[1]: var53_upvw (read and write)
							[2]: Explode_upvr (readonly)
							[3]: v_3_upvr (readonly)
						]]
						var53_upvw:Disconnect()
						Explode_upvr(v_3_upvr)
					end), module_upvr.Cooldown)
				end
			end
		end
	end), 5)
	var3_upvw.conTimer(var11_upvw, 5)
end
return module_upvr
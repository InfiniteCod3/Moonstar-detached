-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:19:00
-- Luau version 6, Types version 3
-- Time taken: 0.012448 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 25
module_upvr.GlobalCD = 2
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
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local Aerial_Smite_upvr = ReplicatedStorage_upvr.Skills["Wind Spear"]["Aerial Smite"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Aerial_Smite_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var3_upvw.applyStatus(arg1, "Freeze", 1.2)
	var3_upvw.applyStatus(arg1, "GlobalCD", 1.2)
	var3_upvw.applyStatus(arg1, "IFrames", 1)
	local clone = Aerial_Smite_upvr.leapSFX:Clone()
	clone.Parent = arg1:FindFirstChild("HumanoidRootPart")
	clone:Play()
	var3_upvw.applyDebris(clone, 3)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("throw"):Connect(function() -- Line 40
		--[[ Upvalues[2]:
			[1]: ReplicatedStorage_upvr (copied, readonly)
			[2]: arg2 (readonly)
		]]
		ReplicatedStorage_upvr.Remotes.ClientInfo:FireClient(arg2, "Aerial Smite")
	end), module_upvr.Cooldown)
	local var12_upvw
	task.delay(2, function() -- Line 45
		--[[ Upvalues[1]:
			[1]: var12_upvw (read and write)
		]]
		if not var12_upvw then
		else
			var12_upvw:Disconnect()
		end
	end)
	local Wind_Spear_upvr = arg1:FindFirstChild("Wind Spear")
	var12_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 50
		--[[ Upvalues[9]:
			[1]: arg2 (readonly)
			[2]: Wind_Spear_upvr (readonly)
			[3]: TweenService_upvr (copied, readonly)
			[4]: var3_upvw (copied, read and write)
			[5]: Aerial_Smite_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: arg1 (readonly)
			[8]: PlayerStatus_upvr (copied, readonly)
			[9]: module_upvr (copied, readonly)
		]]
		if arg2_2 ~= "Aerial Smite" or arg1_2 ~= arg2 then
		else
			Wind_Spear_upvr.Transparency = 1
			Wind_Spear_upvr.Glow.Transparency = 1
			delay(1, function() -- Line 55
				--[[ Upvalues[2]:
					[1]: TweenService_upvr (copied, readonly)
					[2]: Wind_Spear_upvr (copied, readonly)
				]]
				TweenService_upvr:Create(Wind_Spear_upvr, TweenInfo.new(1), {
					Transparency = 0;
				}):Play()
				TweenService_upvr:Create(Wind_Spear_upvr.Glow, TweenInfo.new(1), {
					Transparency = 0;
				}):Play()
			end)
			local workspace_Raycast_result1_upvr = workspace:Raycast(arg3.ClientCF.p, Vector3.new(0, -500, 0), var3_upvw.raycastParams)
			if workspace_Raycast_result1_upvr then
				local clone_3_upvr = Aerial_Smite_upvr.SpearThrow:Clone()
				clone_3_upvr.Parent = Folder_upvr
				clone_3_upvr.CFrame = arg3.ClientCF + Vector3.new(0, -5, 0)
				clone_3_upvr.CFrame = CFrame.lookAt(clone_3_upvr.Position, workspace_Raycast_result1_upvr.Position) * CFrame.Angles((-math.pi/2), 0, 0)
				clone_3_upvr.WindExplode.explosionSFX:Play()
				var3_upvw.applyDebris(clone_3_upvr, 5)
				local any_Create_result1 = TweenService_upvr:Create(clone_3_upvr, TweenInfo.new((clone_3_upvr.Position - workspace_Raycast_result1_upvr.Position).Magnitude * 0.01, Enum.EasingStyle.Linear), {
					CFrame = CFrame.new(workspace_Raycast_result1_upvr.Position) * clone_3_upvr.CFrame - clone_3_upvr.CFrame.p;
				})
				any_Create_result1:Play()
				var3_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 75
					--[[ Upvalues[8]:
						[1]: var3_upvw (copied, read and write)
						[2]: clone_3_upvr (readonly)
						[3]: arg1 (copied, readonly)
						[4]: Aerial_Smite_upvr (copied, readonly)
						[5]: Folder_upvr (copied, readonly)
						[6]: workspace_Raycast_result1_upvr (readonly)
						[7]: TweenService_upvr (copied, readonly)
						[8]: PlayerStatus_upvr (copied, readonly)
					]]
					var3_upvw.applyDebris(clone_3_upvr, 1)
					clone_3_upvr.GroundHit:Play()
					clone_3_upvr.Slash:Play()
					var3_upvw.camShake(arg1, "Bump")
					var3_upvw.flashScreen(arg1, Color3.new(1, 1, 1), 1)
					var3_upvw.changeFov(arg1, 50, 0.1, 1)
					var3_upvw.Blur(arg1, 20, 0.5)
					local clone_upvr = Aerial_Smite_upvr.Tornado:Clone()
					clone_upvr.Parent = Folder_upvr
					clone_upvr.CFrame = CFrame.new(workspace_Raycast_result1_upvr.Position) * clone_upvr.CFrame - clone_upvr.CFrame.p
					clone_upvr.sfx:Play()
					clone_upvr.bang:Play()
					task.delay(2, function() -- Line 89
						--[[ Upvalues[1]:
							[1]: clone_upvr (readonly)
						]]
						clone_upvr.bang.Volume = 0
					end)
					local var29_upvw = false
					task.delay(1.2, function() -- Line 95
						--[[ Upvalues[3]:
							[1]: var29_upvw (read and write)
							[2]: clone_upvr (readonly)
							[3]: TweenService_upvr (copied, readonly)
						]]
						var29_upvw = true
						for _, v in clone_upvr:GetDescendants() do
							if v:IsA("ParticleEmitter") then
								v.Enabled = false
							elseif v:IsA("Sound") then
								TweenService_upvr:Create(v, TweenInfo.new(1), {
									Volume = 0;
								}):Play()
							end
						end
					end)
					local tbl_upvr = {}
					clone_upvr.Explosion.hitSFX:Play()
					var3_upvw.EmitAllDescendants(clone_upvr.Explosion)
					for i_2, v_2_upvr in var3_upvw.findEnemiesPart(clone_upvr.ExplosionHitbox, true), nil do
						if not PlayerStatus_upvr.FindStatus(v_2_upvr, "Blocking") then
							local BodyPosition = Instance.new("BodyPosition", v_2_upvr.HumanoidRootPart)
							BodyPosition.MaxForce = Vector3.new(1000000, 1000000, 1000000)
							BodyPosition.Position = clone_upvr.Position + Vector3.new(0, 2, 0)
							var3_upvw.applyDebris(BodyPosition, 1)
							var3_upvw.applyStatus(v_2_upvr, "Stunned", 1)
							var3_upvw.applyDamage(v_2_upvr, 3)
							var3_upvw.camShake(v_2_upvr, "Bump")
							var3_upvw.changeFov(v_2_upvr, 75, 0.01, 0.5)
						else
							table.insert(tbl_upvr, v_2_upvr)
							task.delay(0.4, function() -- Line 126
								--[[ Upvalues[2]:
									[1]: tbl_upvr (readonly)
									[2]: v_2_upvr (readonly)
								]]
								table.remove(tbl_upvr, table.find(tbl_upvr, v_2_upvr))
							end)
							local BodyVelocity = Instance.new("BodyVelocity")
							BodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
							BodyVelocity.Velocity = CFrame.lookAt(clone_upvr.Position, v_2_upvr.HumanoidRootPart.Position).LookVector * 55
							BodyVelocity.Parent = v_2_upvr.Torso
							var3_upvw.applyDebris(BodyVelocity, 0.35)
						end
					end
					repeat
						task.wait(0.2)
						i_2 = "SmallBump"
						var3_upvw.camShake(arg1, i_2)
						i_2 = true
						local any_findEnemiesPart_result1 = var3_upvw.findEnemiesPart(clone_upvr.Hitbox, i_2)
						i_2 = 0
						if i_2 < #any_findEnemiesPart_result1 then
							i_2 = var3_upvw
							i_2 = arg1
							v_2_upvr = Color3.new(0.862745, 0.862745, 0.862745)
							i_2.flashScreen(i_2, v_2_upvr, 0.4)
							i_2 = var3_upvw
							i_2 = arg1
							v_2_upvr = 76
							i_2.changeFov(i_2, v_2_upvr, 0.1, 0.5)
						end
						i_2 = nil
						v_2_upvr = nil
						for _, v_3 in any_findEnemiesPart_result1, i_2, v_2_upvr do
							if not table.find(tbl_upvr, v_3) then
								local clone_2 = Aerial_Smite_upvr.hitSFX:Clone()
								clone_2.Parent = v_3.HumanoidRootPart
								clone_2.PlaybackSpeed += math.random(-1, 1) * 0.1
								clone_2:Play()
								var3_upvw.applyDebris(clone_2, 5)
								var3_upvw.Knockback(v_3, clone_upvr.Hitbox.Position, -5, 1)
								var3_upvw.applyStatus(v_3, "Stunned", 0.5)
								var3_upvw.applyDamage(v_3, 2)
								var3_upvw.camShake(v_3, "SmallBump")
								var3_upvw.changeFov(v_3, 75, 0.01, 0.5)
							end
						end
					until var29_upvw
				end), module_upvr.Cooldown)
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr
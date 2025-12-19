-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:17
-- Luau version 6, Types version 3
-- Time taken: 0.020570 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 28
module_upvr.GlobalCD = 0.9
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 18
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
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Flashing_Strikes_upvr = ReplicatedStorage_upvr.Skills.Dagger["Flashing Strikes"]
	local clone_upvr = Flashing_Strikes_upvr["Animation Dagger"]:Clone()
	clone_upvr.Parent = arg1
	clone_upvr.weld.Part0 = HumanoidRootPart_upvr
	clone_upvr.weld.Part1 = clone_upvr
	game.Debris:AddItem(clone_upvr, 5)
	local any_LoadAnimation_result1_2 = Humanoid_upvr.Animator:LoadAnimation(Flashing_Strikes_upvr.Animation)
	any_LoadAnimation_result1_2:Play()
	var3_upvw.applyStatus(arg1, "Slowed", 1)
	local clone_3_upvr = Flashing_Strikes_upvr.Part.sounds:Clone()
	clone_3_upvr.Parent = arg1.Torso
	game.Debris:AddItem(clone_3_upvr, 10)
	clone_3_upvr.ArmWhoosh:Play()
	var3_upvw.conTimer(any_LoadAnimation_result1_2:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 50
		--[[ Upvalues[2]:
			[1]: clone_3_upvr (readonly)
			[2]: arg1 (readonly)
		]]
		local clone = clone_3_upvr:FindFirstChild(arg1_2):Clone()
		clone.Parent = arg1.Torso
		clone:Play()
		game.Debris:AddItem(clone, 5)
	end), module_upvr.Cooldown)
	local Combat_upvr = require(arg1.ServerScript.Combat)
	var3_upvw.conTimer(any_LoadAnimation_result1_2:GetMarkerReachedSignal("throw"):Connect(function() -- Line 58
		--[[ Upvalues[12]:
			[1]: clone_upvr (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: arg1 (readonly)
			[4]: Flashing_Strikes_upvr (readonly)
			[5]: Folder_upvr (readonly)
			[6]: HumanoidRootPart_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: PlayerStatus_upvr (copied, readonly)
			[9]: clone_3_upvr (readonly)
			[10]: module_upvr (copied, readonly)
			[11]: Combat_upvr (readonly)
			[12]: Humanoid_upvr (readonly)
		]]
		clone_upvr:Destroy()
		var3_upvw.changeFov(arg1, 90, 0.01, 0.45)
		var3_upvw.Blur(arg1, 15, 0.5)
		local clone_5_upvr = Flashing_Strikes_upvr["Throwing Dagger"]:Clone()
		clone_5_upvr.Parent = Folder_upvr
		clone_5_upvr.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 2
		clone_5_upvr.throw:Play()
		clone_5_upvr.throw2:Play()
		var3_upvw.EmitAllDescendants(clone_5_upvr.shockwave)
		local any_Create_result1_upvr = TweenService_upvr:Create(clone_5_upvr, TweenInfo.new(0.5), {
			CFrame = clone_5_upvr.CFrame + clone_5_upvr.CFrame.LookVector * 40;
		})
		any_Create_result1_upvr:Play()
		var3_upvw.conTimer(any_Create_result1_upvr.Completed:Connect(function() -- Line 73
			--[[ Upvalues[6]:
				[1]: PlayerStatus_upvr (copied, readonly)
				[2]: arg1 (copied, readonly)
				[3]: var3_upvw (copied, read and write)
				[4]: HumanoidRootPart_upvr (copied, readonly)
				[5]: clone_5_upvr (readonly)
				[6]: clone_3_upvr (copied, readonly)
			]]
			if PlayerStatus_upvr.FindStatus(arg1, "Stunned") then
			else
				for _, v_3 in PlayerStatus_upvr.FindTable(arg1) do
					if v_3.Name == "Ragdoll" then
						var3_upvw.applyDebris(v_3, 0)
					end
				end
				var3_upvw.changeFov(arg1, 72, 0.01, 0.15)
				var3_upvw.Blur(arg1, 22, 0.55)
				HumanoidRootPart_upvr.CFrame = clone_5_upvr.CFrame
				clone_3_upvr.Warp:Play()
			end
		end), module_upvr.Cooldown)
		local clone_6 = Flashing_Strikes_upvr.Hitbox:Clone()
		clone_6.Parent = Folder_upvr
		clone_6.weld.Part0 = HumanoidRootPart_upvr
		clone_6.weld.Part1 = clone_6
		game.Debris:AddItem(clone_6, 3)
		local any_findEnemiesPart_result1 = var3_upvw.findEnemiesPart(clone_6)
		local workspace_Raycast_result1_upvr = workspace:Raycast(HumanoidRootPart_upvr.Position, HumanoidRootPart_upvr.CFrame.LookVector * 49.5, var3_upvw.raycastParams)
		if workspace_Raycast_result1_upvr and #any_findEnemiesPart_result1 <= 0 then
			task.delay((workspace_Raycast_result1_upvr.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.007, function() -- Line 102
				--[[ Upvalues[4]:
					[1]: any_Create_result1_upvr (readonly)
					[2]: clone_5_upvr (readonly)
					[3]: workspace_Raycast_result1_upvr (readonly)
					[4]: var3_upvw (copied, read and write)
				]]
				any_Create_result1_upvr:Cancel()
				clone_5_upvr.CFrame = CFrame.new(workspace_Raycast_result1_upvr.Position) * clone_5_upvr.CFrame - clone_5_upvr.CFrame.p
				var3_upvw.CreateDebris(workspace_Raycast_result1_upvr.Position + clone_5_upvr.CFrame.LookVector * 0.1, 8, 0.4, 0.3, 0.15)
				clone_5_upvr.GroundHit:Play()
				local GroundHit = clone_5_upvr.GroundHit
				GroundHit.PlaybackSpeed += math.random(-2, 2) * 0.1
			end)
		end
		if #any_findEnemiesPart_result1 <= 0 and not workspace_Raycast_result1_upvr then
			game.Debris:AddItem(clone_5_upvr, 0.5)
		else
			task.delay(5, function() -- Line 114
				--[[ Upvalues[2]:
					[1]: TweenService_upvr (copied, readonly)
					[2]: clone_5_upvr (readonly)
				]]
				TweenService_upvr:Create(clone_5_upvr, TweenInfo.new(1), {
					Transparency = 1;
				}):Play()
				for _, v in clone_5_upvr.DaggerParts:GetChildren() do
					if v:IsA("BasePart") then
						TweenService_upvr:Create(v, TweenInfo.new(1), {
							Transparency = 1;
						}):Play()
					end
				end
			end)
			game.Debris:AddItem(clone_5_upvr, 6)
		end
		for _, v_2_upvr in any_findEnemiesPart_result1 do
			task.delay((v_2_upvr.HumanoidRootPart.Position - HumanoidRootPart_upvr.Position).Magnitude * 0.007, function() -- Line 126
				--[[ Upvalues[11]:
					[1]: var3_upvw (copied, read and write)
					[2]: v_2_upvr (readonly)
					[3]: HumanoidRootPart_upvr (copied, readonly)
					[4]: clone_3_upvr (copied, readonly)
					[5]: any_Create_result1_upvr (readonly)
					[6]: clone_5_upvr (readonly)
					[7]: Combat_upvr (copied, readonly)
					[8]: arg1 (copied, readonly)
					[9]: Humanoid_upvr (copied, readonly)
					[10]: Flashing_Strikes_upvr (copied, readonly)
					[11]: module_upvr (copied, readonly)
				]]
				if not var3_upvw.CheckBlock(v_2_upvr) then
					var3_upvw.applyStatus(v_2_upvr, "Stunned", 0.7)
					var3_upvw.blood(v_2_upvr, 3)
					var3_upvw.applyDamage(v_2_upvr, 1, false, true)
					v_2_upvr.HumanoidRootPart.CFrame = CFrame.lookAt(v_2_upvr.HumanoidRootPart.Position, Vector3.new(HumanoidRootPart_upvr.Position.X, v_2_upvr.HumanoidRootPart.Position.Y, HumanoidRootPart_upvr.Position.Z))
					local clone_4 = clone_3_upvr.hit:Clone()
					clone_4.Parent = v_2_upvr.Torso
					clone_4.PlaybackSpeed += math.random(-1, 1) * 0.05
					clone_4:Play()
					game.Debris:AddItem(clone_4, 4)
					var3_upvw.Blur(v_2_upvr, 22, 0.55)
					var3_upvw.changeFov(v_2_upvr, 75, 0.01, 0.15)
					any_Create_result1_upvr:Cancel()
					clone_5_upvr.TrailAtt.Trail.Enabled = false
					clone_5_upvr.Anchored = false
					clone_5_upvr.weld.Part0 = v_2_upvr.Torso
					clone_5_upvr.weld.Part1 = clone_5_upvr
					var3_upvw.EmitAllDescendants(clone_5_upvr.HitVfx)
					if 0 < Combat_upvr.punchNum then
						var3_upvw.applyStatus(arg1, "CombatStun", 2.85)
					end
					task.wait()
					local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Flashing_Strikes_upvr.Animation2)
					any_LoadAnimation_result1:Play()
					var3_upvw.applyStatus(arg1, "GlobalCD", 2.05)
					var3_upvw.applyStatus(arg1, "Freeze", 2.15)
					var3_upvw.applyStatus(arg1, "AutoRotate", 2.15)
					var3_upvw.applyStatus(arg1, "IFrames", 2.15)
					var3_upvw.applyStatus(v_2_upvr, "Stunned", 3.05)
					var3_upvw.applyStatus(v_2_upvr, "AutoRotate", 2.15)
					var3_upvw.applyStatus(v_2_upvr, "IFrames", 2.15)
					local tbl_upvr = {v_2_upvr.Humanoid.Animator:LoadAnimation(game:GetService("ServerScriptService").CharacterInserter.stun1), v_2_upvr.Humanoid.Animator:LoadAnimation(game:GetService("ServerScriptService").CharacterInserter.stun2), v_2_upvr.Humanoid.Animator:LoadAnimation(game:GetService("ServerScriptService").CharacterInserter.stun3), v_2_upvr.Humanoid.Animator:LoadAnimation(game:GetService("ServerScriptService").CharacterInserter.stun4)}
					local any_applyWeld_result1_upvr = var3_upvw.applyWeld(v_2_upvr, Vector3.new(0, 0, 5), Vector3.new(0, 180, 0), 2.4)
					var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("slash"):Connect(function(arg1_3) -- Line 179
						--[[ Upvalues[6]:
							[1]: var3_upvw (copied, read and write)
							[2]: any_applyWeld_result1_upvr (readonly)
							[3]: v_2_upvr (copied, readonly)
							[4]: arg1 (copied, readonly)
							[5]: tbl_upvr (readonly)
							[6]: clone_3_upvr (copied, readonly)
						]]
						if arg1_3 == "last" then
							var3_upvw.applyDebris(any_applyWeld_result1_upvr, 0)
							var3_upvw.applyDamage(v_2_upvr, 1, true)
						else
							var3_upvw.applyDamage(v_2_upvr, 0.8, true, true)
						end
						var3_upvw.blood(v_2_upvr, 2)
						var3_upvw.changeFov(arg1, 68, 0.01, 0.1)
						var3_upvw.camShake(arg1, "SmallBump")
						var3_upvw.changeFov(v_2_upvr, 68, 0.01, 0.1)
						var3_upvw.camShake(arg1, "SmallBump")
						tbl_upvr[math.random(1, #tbl_upvr)]:Play()
						local clone_2 = clone_3_upvr.hit:Clone()
						clone_2.Parent = v_2_upvr.Torso
						clone_2.PlaybackSpeed += math.random(-1, 1) * 0.05
						clone_2:Play()
						game.Debris:AddItem(clone_2, 4)
					end), module_upvr.Cooldown)
				else
					any_applyWeld_result1_upvr = var3_upvw
					any_applyWeld_result1_upvr = v_2_upvr
					any_applyWeld_result1_upvr.applyDamage(any_applyWeld_result1_upvr, 1)
				end
			end)
			return
		end
	end), module_upvr.Cooldown)
end
return module_upvr
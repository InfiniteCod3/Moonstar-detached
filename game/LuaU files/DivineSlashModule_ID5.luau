-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:51
-- Luau version 6, Types version 3
-- Time taken: 0.016443 seconds

local module_upvr = {
	Cooldown = 20;
	GlobalCD = 1.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 13
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
	local DivineSlash_upvr = ReplicatedStorage_upvr.Skills["Basic Staff"].DivineSlash
	local Basic_Staff_upvr = arg1:FindFirstChild("Basic Staff")
	local any_LoadAnimation_result1_upvr = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(DivineSlash_upvr.Animation)
	any_LoadAnimation_result1_upvr:Play()
	any_LoadAnimation_result1_upvr:AdjustSpeed(0.75)
	Basic_Staff_upvr.Aura:Play()
	local tbl_3_upvr = {}
	for _, v in DivineSlash_upvr.ArmVFX:GetChildren() do
		local clone = v:Clone()
		clone.Parent = arg1["Left Arm"]
		table.insert(tbl_3_upvr, clone)
	end
	for _, v_2 in tbl_3_upvr do
		v_2.Enabled = true
	end
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr.Stopped:Connect(function() -- Line 45
		--[[ Upvalues[1]:
			[1]: tbl_3_upvr (readonly)
		]]
		for _, v_3 in tbl_3_upvr do
			v_3.Enabled = false
		end
	end), module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("skill"):Connect(function() -- Line 51
		--[[ Upvalues[8]:
			[1]: any_LoadAnimation_result1_upvr (readonly)
			[2]: DivineSlash_upvr (readonly)
			[3]: Folder_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: var2_upvw (copied, read and write)
			[6]: TweenService_upvr (copied, readonly)
			[7]: arg1 (readonly)
			[8]: module_upvr (copied, readonly)
		]]
		any_LoadAnimation_result1_upvr:AdjustSpeed(1.55)
		local clone_3 = DivineSlash_upvr["Divine Slash"]:Clone()
		clone_3.Parent = Folder_upvr
		clone_3.CFrame = HumanoidRootPart_upvr.CFrame
		var2_upvw.EmitAllDescendants(clone_3.LeftLine)
		var2_upvw.EmitAllDescendants(clone_3.RightLine)
		clone_3.Sound:Play()
		clone_3.laser:Play()
		TweenService_upvr:Create(clone_3.laser, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Volume = 0;
		}):Play()
		var2_upvw.changeFov(arg1, 70, 0.01, 3)
		var2_upvw.flashScreen(arg1, Color3.new(1, 1, 0.513725), 0.65)
		task.wait(0.7)
		clone_3:FindFirstChild("Hitbox").explosion:Play()
		var2_upvw.Blur(arg1, 20, 0.5)
		var2_upvw.EmitAllDescendants(clone_3.Slash1)
		var2_upvw.EmitAllDescendants(clone_3.Slash2)
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 100, 0.01, 0.8)
		var2_upvw.flashScreen(arg1, Color3.new(1, 1, 0.513725), 0.4)
		var2_upvw.findEnemiesPart(clone_3.Hitbox, true)
		for _, v_4_upvr in var2_upvw.FoundEnemies do
			var2_upvw.camShake(v_4_upvr, "Bump")
			var2_upvw.applyDamage(v_4_upvr, 5)
			var2_upvw.Knockback(v_4_upvr, clone_3.Position, 0, 180)
			var2_upvw.applyStatus(v_4_upvr, "Stunned", 2)
			var2_upvw.applyStatus(v_4_upvr, "Ragdoll", 0.55)
			var2_upvw.applyStatus(v_4_upvr, "DashDB", 0.75)
			local HumanoidRootPart_upvr_2 = v_4_upvr:FindFirstChild("HumanoidRootPart")
			task.delay(0.6 + math.random(-1, 1) * 0.1, function() -- Line 88
				--[[ Upvalues[8]:
					[1]: HumanoidRootPart_upvr_2 (readonly)
					[2]: var2_upvw (copied, read and write)
					[3]: v_4_upvr (readonly)
					[4]: DivineSlash_upvr (copied, readonly)
					[5]: Folder_upvr (copied, readonly)
					[6]: TweenService_upvr (copied, readonly)
					[7]: arg1 (copied, readonly)
					[8]: module_upvr (copied, readonly)
				]]
				if not workspace:Raycast(HumanoidRootPart_upvr_2.Position, Vector3.new(0, -8, 0), var2_upvw.raycastParams) then
					local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr_2.Position, Vector3.new(0, -200, 0), var2_upvw.raycastParams)
					if workspace_Raycast_result1 then
						var2_upvw.applyStatus(v_4_upvr, "Stunned", 2)
						local clone_2_upvr = DivineSlash_upvr.ChainRing:Clone()
						clone_2_upvr.Parent = Folder_upvr
						clone_2_upvr.Position = workspace_Raycast_result1.Position
						clone_2_upvr.Spawn:Play()
						game.Debris:AddItem(clone_2_upvr, 3)
						clone_2_upvr.Size = Vector3.new(0, 0, 0)
						TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.5), {
							Size = clone_2_upvr.Size;
						}):Play()
						local EnemyAtt_upvr_2 = clone_2_upvr.EnemyAtt
						EnemyAtt_upvr_2.Parent = HumanoidRootPart_upvr_2
						game.Debris:AddItem(EnemyAtt_upvr_2, 3)
						TweenService_upvr:Create(clone_2_upvr.Beam, TweenInfo.new(1), {
							TextureSpeed = -3;
						}):Play()
						local BodyVelocity = Instance.new("BodyVelocity", v_4_upvr.Torso)
						BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						game.Debris:AddItem(BodyVelocity, 0.75)
						local any_Create_result1_2 = TweenService_upvr:Create(HumanoidRootPart_upvr_2, TweenInfo.new(0.65, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
							CFrame = CFrame.new(clone_2_upvr.Position + Vector3.new(0, 1, 0)) * HumanoidRootPart_upvr_2.CFrame - HumanoidRootPart_upvr_2.CFrame.p;
						})
						any_Create_result1_2:Play()
						var2_upvw.conTimer(any_Create_result1_2.Completed:Connect(function() -- Line 120
							--[[ Upvalues[8]:
								[1]: EnemyAtt_upvr_2 (readonly)
								[2]: TweenService_upvr (copied, readonly)
								[3]: clone_2_upvr (readonly)
								[4]: var2_upvw (copied, read and write)
								[5]: v_4_upvr (copied, readonly)
								[6]: HumanoidRootPart_upvr_2 (copied, readonly)
								[7]: arg1 (copied, readonly)
								[8]: DivineSlash_upvr (copied, readonly)
							]]
							EnemyAtt_upvr_2:Destroy()
							TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.2), {
								Size = Vector3.new(20, 0, 20);
								Transparency = 1;
							}):Play()
							var2_upvw.applyDamage(v_4_upvr, 5)
							var2_upvw.camShake(v_4_upvr, "Bump")
							var2_upvw.CreateDebris(HumanoidRootPart_upvr_2.Position, 6, 0.9, 0.8, 0.08)
							var2_upvw.crater(1, HumanoidRootPart_upvr_2.Position, 3, 0.52)
							clone_2_upvr.explosion:Play()
							var2_upvw.changeFov(arg1, 70, 0.01, 0.5)
							var2_upvw.flashScreen(arg1, Color3.new(1, 1, 0.513725), 0.3)
							var2_upvw.camShake(arg1, "Bump")
							v_4_upvr.Humanoid.Animator:LoadAnimation(DivineSlash_upvr.HurtAnimation):Play()
							task.wait(0.1)
							var2_upvw.applyStatus(v_4_upvr, "Ragdoll", 2)
						end), module_upvr.Cooldown)
					end
				end
			end)
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1_upvr:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 151
		--[[ Upvalues[1]:
			[1]: Basic_Staff_upvr (readonly)
		]]
		Basic_Staff_upvr:FindFirstChild(arg1_2):Play()
	end), module_upvr.Cooldown)
end
return module_upvr
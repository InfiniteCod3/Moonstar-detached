-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:50
-- Luau version 6, Types version 3
-- Time taken: 0.014154 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 26
module_upvr.GlobalCD = 1.2
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 16
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
	local CelestialUplift_upvr = ReplicatedStorage_upvr.Skills["Basic Staff"].CelestialUplift
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(CelestialUplift_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(1.1)
	var3_upvw.applyStatus(arg1, "Freeze", 1.2)
	var3_upvw.changeFov(arg1, 90, 0.8, 4)
	arg1:FindFirstChild("Basic Staff").Spin:Play()
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local clone_upvw = CelestialUplift_upvr.VFX.UpliftVFX:Clone()
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("strike"):Connect(function() -- Line 40
		--[[ Upvalues[9]:
			[1]: var3_upvw (copied, read and write)
			[2]: arg1 (readonly)
			[3]: CelestialUplift_upvr (readonly)
			[4]: HumanoidRootPart_upvr (readonly)
			[5]: clone_upvw (read and write)
			[6]: Folder_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: PlayerStatus_upvr (copied, readonly)
			[9]: module_upvr (copied, readonly)
		]]
		var3_upvw.camShake(arg1, "Bump")
		var3_upvw.changeFov(arg1, 72, 0.01, 0.8)
		var3_upvw.flashScreen(arg1, Color3.new(1, 1, 0.513725), 1)
		local clone = CelestialUplift_upvr.VFX.UpliftVFX:Clone()
		clone.Parent = HumanoidRootPart_upvr
		var3_upvw.EmitAllDescendants(clone)
		var3_upvw.applyDebris(clone, 8)
		clone_upvw = CelestialUplift_upvr.SmashDownVFX:Clone()
		clone_upvw.Parent = Folder_upvr
		clone_upvw.Position = HumanoidRootPart_upvr.Position
		var3_upvw.applyDebris(clone_upvw, 15)
		local clone_3_upvr = CelestialUplift_upvr.Shockwave:Clone()
		clone_3_upvr.Parent = Folder_upvr
		clone_3_upvr.CFrame = HumanoidRootPart_upvr.CFrame - Vector3.new(0, 3, 0)
		for _, v in clone_3_upvr:GetChildren() do
			if v:IsA("Sound") then
				v:Play()
			end
		end
		TweenService_upvr:Create(clone_3_upvr, TweenInfo.new(1.1), {
			Size = clone_3_upvr.Size + Vector3.new(100, -clone_3_upvr.Size.Y, 100);
		}):Play()
		delay(1.45, function() -- Line 62
			--[[ Upvalues[1]:
				[1]: clone_3_upvr (readonly)
			]]
			clone_3_upvr.Transparency = 1
		end)
		game.Debris:AddItem(clone_3_upvr, 3)
		task.wait(0.15)
		var3_upvw.applyStatus(arg1, "CombatStun", 1.8)
		local tbl_2 = {}
		local tbl = {}
		for _ = 1, 33.333333333333336 do
			task.wait()
			var3_upvw.findEnemiesMagnitude(clone_3_upvr.Position, clone_3_upvr.Size.X / 2, true)
			for _, v_2 in var3_upvw.FoundEnemies do
				if not table.find(tbl, v_2) then
					table.insert(tbl, v_2)
					if not PlayerStatus_upvr.FindStatus(v_2, "HyperArmor") then
						for _, v_3 in PlayerStatus_upvr.FindTable(v_2) do
							if v_3 == "Ragdoll" then
								PlayerStatus_upvr.RemoveStatus(arg1, v_3)
							end
						end
						var3_upvw.unragdoll(v_2)
						local BodyVelocity = Instance.new("BodyVelocity", v_2.Torso)
						BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						BodyVelocity.Velocity = Vector3.new(0, 0, 0)
						game.Debris:AddItem(BodyVelocity, 1.8)
						table.insert(tbl_2, v_2)
						TweenService_upvr:Create(v_2.HumanoidRootPart, TweenInfo.new(1), {
							CFrame = v_2.HumanoidRootPart.CFrame + Vector3.new(0, 20, 0);
						}):Play()
						local clone_2 = clone_3_upvr.hitVfx:Clone()
						clone_2.Parent = v_2.Torso
						clone_2.liftSfx:Play()
						clone_2.holdSfx:Play()
						table.insert({}, clone_2.explosion)
					end
					if not var3_upvw.CheckBlock(v_2) then
						var3_upvw.applyDamage(v_2, 0.01)
						var3_upvw.applyStatus(v_2, "Stunned", 3.2)
						var3_upvw.applyStatus(v_2, "AutoRotate", 3.2)
					end
				end
			end
		end
		task.wait(0.5)
		if 0 < #tbl_2 then
			var3_upvw.resetm1s()
			var3_upvw.EmitAllDescendants(clone_upvw)
			for _, v_4 in clone_upvw:GetDescendants() do
				v_2 = "Sound"
				if v_4:IsA(v_2) then
					v_4:Play()
				end
			end
		end
		for _, v_5_upvr in tbl_2 do
			if not v_5_upvr:FindFirstChild("HumanoidRootPart") then return end
			local HumanoidRootPart_upvr_2 = v_5_upvr.HumanoidRootPart
			local any_Create_result1 = TweenService_upvr:Create(HumanoidRootPart_upvr_2, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				CFrame = HumanoidRootPart_upvr_2.CFrame + Vector3.new(0, -20, 0);
			})
			local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr_2.Position, Vector3.new(0, -50, 0), var3_upvw.raycastParams)
			if workspace_Raycast_result1 then
				any_Create_result1 = TweenService_upvr:Create(HumanoidRootPart_upvr_2, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
					CFrame = CFrame.new(workspace_Raycast_result1.Position + Vector3.new(0, 3, 0)) * HumanoidRootPart_upvr_2.CFrame - HumanoidRootPart_upvr_2.CFrame.p;
				})
			end
			any_Create_result1:Play()
			var3_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 140
				--[[ Upvalues[4]:
					[1]: v_5_upvr (readonly)
					[2]: var3_upvw (copied, read and write)
					[3]: CelestialUplift_upvr (copied, readonly)
					[4]: HumanoidRootPart_upvr_2 (readonly)
				]]
				if not v_5_upvr:FindFirstChild("Humanoid") then
				else
					var3_upvw.applyDamage(v_5_upvr, 5)
					local _, _ = pcall(function() -- Line 145
						--[[ Upvalues[2]:
							[1]: CelestialUplift_upvr (copied, readonly)
							[2]: v_5_upvr (copied, readonly)
						]]
						local Animation = Instance.new("Animation")
						Animation.AnimationId = CelestialUplift_upvr.HurtAnimation.AnimationId
						task.wait()
						v_5_upvr.Humanoid.Animator:LoadAnimation(Animation):Play()
					end)
					if not var3_upvw.CheckBlock(v_5_upvr) then
						var3_upvw.applyStatus(v_5_upvr, "Stunned", 1.5)
						var3_upvw.applyStatus(v_5_upvr, "AutoRotate", 1.5)
						var3_upvw.CreateDebris(HumanoidRootPart_upvr_2.Position, 5, 0.7, 0.65, 0.1)
						var3_upvw.crater(1, HumanoidRootPart_upvr_2.Position, 2, 0.3)
					end
					var3_upvw.camShake(v_5_upvr, "Bump")
				end
			end), module_upvr.Cooldown)
		end
		if 0 < #tbl then
			task.wait(0.5)
			var3_upvw.camShake(arg1, "Bump")
			for _, v_6 in {} do
				HumanoidRootPart_upvr_2 = v_6:Play
				HumanoidRootPart_upvr_2()
				-- KONSTANTERROR: Expression was reused, decompilation is incorrect
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr
-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:14:56
-- Luau version 6, Types version 3
-- Time taken: 0.031651 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 12
module_upvr.GlobalCD = 1.2
local var3_upvw
local PlayerStatus_upvr = require(ReplicatedStorage_upvr.Modules.PlayerStatus)
function module_upvr.Script(arg1, arg2) -- Line 17
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
	local Humanoid_upvr = arg1:FindFirstChild("Humanoid")
	local Body_Slam_upvr = ReplicatedStorage_upvr.Skills["Fire Fists"].Ultimate["Body Slam"]
	local any_LoadAnimation_result1_2_upvr = Humanoid_upvr.Animator:LoadAnimation(Body_Slam_upvr.Animation)
	any_LoadAnimation_result1_2_upvr:Play()
	local clone_upvr = Body_Slam_upvr.Trail:Clone()
	clone_upvr.Parent = arg1
	clone_upvr.Weld.Part0 = HumanoidRootPart_upvr
	clone_upvr.Weld.Part1 = clone_upvr
	var3_upvw.applyDebris(clone_upvr, 20)
	var3_upvw.conTimer(any_LoadAnimation_result1_2_upvr.Stopped:Connect(function() -- Line 41
		--[[ Upvalues[1]:
			[1]: clone_upvr (readonly)
		]]
		clone_upvr.NormalTrail.Enabled = false
	end), module_upvr.Cooldown)
	var3_upvw.applyStatus(arg1, "Freeze", 1.2)
	var3_upvw.changeFov(arg1, 100, 0.3, 5)
	local clone_5 = Body_Slam_upvr.Dash:Clone()
	clone_5.Parent = HumanoidRootPart_upvr
	clone_5:Play()
	var3_upvw.applyDebris(clone_5, 5)
	local clone_3 = Body_Slam_upvr.Dash2:Clone()
	clone_3.Parent = HumanoidRootPart_upvr
	clone_3:Play()
	var3_upvw.applyDebris(clone_3, 5)
	var3_upvw.camShake(arg1, "Bump")
	var3_upvw.CreateDebris(HumanoidRootPart_upvr.Position, 5, 0.8, 0.4, 0.03)
	local var15_upvw
	var15_upvw = var3_upvw.conTimer(ReplicatedStorage_upvr.Remotes.ClientInfo.OnServerEvent:Connect(function(arg1_2, arg2_2, arg3) -- Line 67
		--[[ Upvalues[11]:
			[1]: arg2 (readonly)
			[2]: var15_upvw (read and write)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: any_LoadAnimation_result1_2_upvr (readonly)
			[5]: var3_upvw (copied, read and write)
			[6]: arg1 (readonly)
			[7]: Body_Slam_upvr (readonly)
			[8]: Folder_upvr (readonly)
			[9]: PlayerStatus_upvr (copied, readonly)
			[10]: Humanoid_upvr (readonly)
			[11]: clone_upvr (readonly)
		]]
		-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
		if arg2_2 ~= "BodySlam" or arg1_2 ~= arg2 or not var15_upvw then
		else
			var15_upvw:Disconnect()
			if arg3 then
				HumanoidRootPart_upvr.CFrame = arg3
			end
			any_LoadAnimation_result1_2_upvr:Stop()
			var3_upvw.applyStatus(arg1, "IFrames", 0.1)
			local clone_6 = Body_Slam_upvr.Hitbox:Clone()
			clone_6.Parent = Folder_upvr
			clone_6.weld.Part1 = clone_6
			clone_6.weld.Part0 = HumanoidRootPart_upvr
			var3_upvw.applyDebris(clone_6, 1)
			clone_6.Transparency = 1
			for _, v in var3_upvw.findEnemiesPart(clone_6, true), nil do
				local var63
				if var3_upvw.CheckBlock(v, true) then break end
				var3_upvw.unragdoll(v)
				for _, v_2 in PlayerStatus_upvr.FindTable(v) do
					if v_2.Name == "HyperArmor" then
						var3_upvw.applyDebris(v_2, 0)
					end
				end
				var3_upvw.applyDamage(v, 5, false, true)
				local clone_7 = Body_Slam_upvr["Dash(Slam)"]:Clone()
				local clone = Body_Slam_upvr["Dash2(Slam)"]:Clone()
				clone_7.Parent = HumanoidRootPart_upvr
				clone.Parent = HumanoidRootPart_upvr
				clone_7:Play()
				clone:Play()
				var3_upvw.applyDebris(clone, 5)
				var3_upvw.applyDebris(clone_7, 8)
				local clone_2 = Body_Slam_upvr.Grab:Clone()
				clone_2.Parent = HumanoidRootPart_upvr
				clone_2:Play()
				var3_upvw.applyDebris(clone_2, 5)
				var3_upvw.applyStatus(arg1, "IFrames", 1)
				var3_upvw.applyStatus(arg1, "GlobalCD", 1)
				var3_upvw.applyStatus(arg1, "Freeze", 1)
				var3_upvw.applyStatus(arg1, "AutoRotate", 1)
				var3_upvw.applyStatus(v, "Stunned", 1)
				var3_upvw.applyStatus(v, "AutoRotate", 1)
				var3_upvw.applyStatus(v, "IFrames", 1)
				var3_upvw.SetRootPriority(arg1, 100)
				local any_LoadAnimation_result1 = Humanoid_upvr.Animator:LoadAnimation(Body_Slam_upvr.SlamAnim)
				any_LoadAnimation_result1:Play()
				local any_LoadAnimation_result1_3 = v.Humanoid.Animator:LoadAnimation(Body_Slam_upvr.SlamAnimTarget)
				any_LoadAnimation_result1_3:Play()
				clone_upvr.FireTrail.Enabled = true
				var63 = HumanoidRootPart_upvr.Position
				var63 = 80
				local any_Knockback_result1_upvr = var3_upvw.Knockback(arg1, var63 + HumanoidRootPart_upvr.CFrame.LookVector * -50, var63, 75, 100, "Server")
				function var63() -- Line 141
					--[[ Upvalues[1]:
						[1]: any_Knockback_result1_upvr (readonly)
					]]
					any_Knockback_result1_upvr.MaxForce = Vector3.new(1000000, 0, 1000000)
				end
				task.delay(0.3, var63)
				task.wait(0.2)
				var63 = true
				repeat
					task.wait(0.05)
					var3_upvw.applyStatus(arg1, "AutoRotate", 0.5)
					var3_upvw.applyStatus(arg1, "Freeze", 0.5)
					var3_upvw.applyStatus(arg1, "IFrames", 0.15)
					var3_upvw.applyStatus(arg1, "GlobalCD", 0.5)
					var3_upvw.applyStatus(v, "AutoRotate", 0.5)
					var3_upvw.applyStatus(v, "Stunned", 0.5)
					var3_upvw.applyStatus(v, "IFrames", 0.15)
					local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position, Vector3.new(HumanoidRootPart_upvr.Velocity.X * 0.2, -3 + HumanoidRootPart_upvr.Velocity.Y * 0.24, HumanoidRootPart_upvr.Velocity.Z * 0.2), var3_upvw.raycastParams)
					if workspace_Raycast_result1 and workspace_Raycast_result1.Position.Y < HumanoidRootPart_upvr.Position.Y then
						var63 = false
						local Position = workspace_Raycast_result1.Position
						local var66
					end
					if var63 == true then
						if HumanoidRootPart_upvr.Velocity.Y == 0 then
							var66 += 1
						end
						if var66 == 3 then break end
					end
				until var63 == false and Humanoid_upvr.Health <= 0
				var3_upvw.SetRootPriority(arg1, 0)
				var3_upvw.applyDebris(var3_upvw.applyWeld(v, Vector3.new(0, 0, 1), Vector3.new(0, 180, 0)), 0)
				any_Knockback_result1_upvr.Velocity = Vector3.new(0, 0, 0)
				var3_upvw.applyDebris(any_Knockback_result1_upvr, 0.1)
				any_LoadAnimation_result1:Stop()
				any_LoadAnimation_result1_3:Stop()
				var3_upvw.applyDebris(clone_upvr, 1.5)
				clone_upvr.FireTrail.Enabled = false
				if var63 then break end
				for _, v_3 in var3_upvw.findEnemiesMagnitude(HumanoidRootPart_upvr.Position, 20, true), nil do
					var3_upvw.applyDamage(v_3, 20, false, false)
					var3_upvw.applyStatus(v_3, "Ragdoll", 2.2)
					var3_upvw.Knockback(v_3, Position + HumanoidRootPart_upvr.CFrame.LookVector * -250, 0, -20)
					var3_upvw.camShake(v_3, "Explosion")
					var3_upvw.changeFov(v_3, 30, 0.01, 1)
					var3_upvw.flashScreen(v_3, Color3.new(1, 0.643137, 0.329412), 0.75)
				end
				local clone_4 = Body_Slam_upvr.SlamVFX:Clone()
				clone_4.Parent = Folder_upvr
				clone_4.Position = Position
				var3_upvw.applyDebris(clone_4, 10)
				var3_upvw.EmitAllDescendants(clone_4)
				for _, v_4 in clone_4:GetDescendants() do
					if v_4:IsA("Sound") then
						v_4:Play()
					end
				end
				var3_upvw.camShake(arg1, "Explosion")
				var3_upvw.changeFov(arg1, 30, 0.01, 1)
				var3_upvw.camShake(v, "Explosion")
				var3_upvw.changeFov(v, 30, 0.01, 1)
				var3_upvw.flashScreen(arg1, Color3.new(1, 0.643137, 0.329412), 0.75)
				var3_upvw.flashScreen(v, Color3.new(1, 0.643137, 0.329412), 0.75)
				var3_upvw.crater(1, Position, 4, 2)
				var3_upvw.CreateDebris(Position, 8, 1, 1, 0.05)
				var3_upvw.applyDamage(v, 20, true, false)
				var3_upvw.applyStatus(v, "Ragdoll", 2.2)
				var3_upvw.Knockback(v, Position + HumanoidRootPart_upvr.CFrame.LookVector * -250, 0, -20)
				for _ = 1, 4 do
					v.HumanoidRootPart.CFrame = CFrame.new(Position) * v.HumanoidRootPart.CFrame - v.HumanoidRootPart.CFrame.p
					task.wait()
				end
				do
					return
				end
				return
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr
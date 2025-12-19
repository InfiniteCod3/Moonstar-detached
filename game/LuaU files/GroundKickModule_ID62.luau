-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:16:49
-- Luau version 6, Types version 3
-- Time taken: 0.018173 seconds

local module_upvr = {
	Cooldown = 20;
	GlobalCD = 0.8;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 16
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
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Humanoid = arg1:FindFirstChild("Humanoid")
	local Ground_Kick_upvr = ReplicatedStorage_upvr.Skills.Kickboxer["Ground Kick"]
	local var13
	var2_upvw.applyStatus(arg1, "Freeze", 0.8)
	local var14_upvw = false
	if workspace:Raycast(HumanoidRootPart_upvr.Position, Vector3.new(0, -3.5, 0), var2_upvw.raycastParams) then
		var13 = Humanoid.Animator:LoadAnimation(Ground_Kick_upvr.Animation)
		var13:Play()
	else
		for _, v in Humanoid.Animator:GetPlayingAnimationTracks() do
			v:Stop()
		end
		var14_upvw = true
		var13 = Humanoid.Animator:LoadAnimation(Ground_Kick_upvr.AirAnimation)
		var13:Play()
	end
	var2_upvw.changeFov(arg1, 72, 0.3, 5)
	var2_upvw.conTimer(var13:GetMarkerReachedSignal("stomp"):Connect(function() -- Line 49
		--[[ Upvalues[8]:
			[1]: var14_upvw (read and write)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
			[4]: arg1 (readonly)
			[5]: Ground_Kick_upvr (readonly)
			[6]: Folder_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: module_upvr (copied, readonly)
		]]
		-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
		local var25 = var14_upvw
		-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [15] 12. Error Block 28 start (CF ANALYSIS FAILED)
		local Position = HumanoidRootPart_upvr.Position
		var2_upvw.crater(1, Position, 5, 1.4)
		var2_upvw.CreateDebris(Position, 20, 0.7, 0.7, 0.08)
		var2_upvw.Blur(arg1, 35, 0.32)
		var2_upvw.camShake(arg1, "BigBump")
		var2_upvw.changeFov(arg1, 92, 0.2, 3)
		local clone_2 = Ground_Kick_upvr.StompVfx:Clone()
		clone_2.Parent = Folder_upvr
		clone_2.CFrame = CFrame.new(var25.Position) * CFrame.Angles(math.rad(var25.Instance.Rotation.X), math.rad(var25.Instance.Rotation.Y), math.rad(var25.Instance.Rotation.Z))
		var2_upvw.EmitAllDescendants(clone_2)
		clone_2.rocks:Play()
		clone_2.Impact:Play()
		for _, v_2_upvr in clone_2:GetDescendants() do
			if v_2_upvr:IsA("Decal") then
				task.delay(3, function() -- Line 70
					--[[ Upvalues[2]:
						[1]: TweenService_upvr (copied, readonly)
						[2]: v_2_upvr (readonly)
					]]
					TweenService_upvr:Create(v_2_upvr, TweenInfo.new(3), {
						Transparency = 1;
					}):Play()
				end)
			end
		end
		for i_3_upvr, v_3 in var2_upvw.findEnemiesMagnitude(Position, 22, true), nil do
			local BodyVelocity = Instance.new("BodyVelocity", v_3.HumanoidRootPart)
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = Vector3.new(0, 24, 0)
			TweenService_upvr:Create(BodyVelocity, TweenInfo.new(0.4), {
				Velocity = Vector3.new(0, 2, 0);
			}):Play()
			game.Debris:AddItem(BodyVelocity, 0.6)
			var2_upvw.applyStatus(v_3, "Ragdoll", 2)
			var2_upvw.applyDamage(v_3, 10)
		end
		do
			return
		end
		-- KONSTANTERROR: [15] 12. Error Block 28 end (CF ANALYSIS FAILED)
		-- KONSTANTERROR: [206] 153. Error Block 34 start (CF ANALYSIS FAILED)
		if var14_upvw then
			local clone = Ground_Kick_upvr.AirStomp:Clone()
			clone.Parent = Folder_upvr
			clone.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 5 + Vector3.new(0, -3, 0)
			var2_upvw.EmitAllDescendants(clone)
			clone.sfx:Play()
			clone.sfx2:Play()
			var2_upvw.Blur(arg1, 35, 0.32)
			var2_upvw.camShake(arg1, "BigBump")
			var2_upvw.changeFov(arg1, 92, 0.2, 3)
			for _, v_4_upvr in var2_upvw.findEnemiesMagnitude(clone.Position, 9, true), nil do
				v_3 = "enemyWeld"
				if v_4_upvr:FindFirstChild(v_3) then
					v_4_upvr.enemyWeld:Destroy()
				end
				i_3_upvr = var2_upvw
				i_3_upvr = v_4_upvr
				v_3 = true
				v_3 = var2_upvw
				i_3_upvr = v_3.applyStatus
				v_3 = v_4_upvr
				i_3_upvr(v_3, "Stunned", 1)
				v_3 = var2_upvw
				i_3_upvr = v_3.applyDamage
				v_3 = v_4_upvr
				i_3_upvr(v_3, 5, false, true)
				i_3_upvr = workspace:Raycast(v_4_upvr.HumanoidRootPart.Position, Vector3.new(0, -35, 0), var2_upvw.raycastParams)
				if i_3_upvr then
					v_3 = TweenService_upvr
					v_3 = v_3:Create(v_4_upvr.HumanoidRootPart, TweenInfo.new((v_4_upvr.HumanoidRootPart.Position - i_3_upvr.Position).Magnitude * 0.007, Enum.EasingStyle.Linear), {
						CFrame = CFrame.new(i_3_upvr.Position) * v_4_upvr.HumanoidRootPart.CFrame - v_4_upvr.HumanoidRootPart.CFrame.p;
					})
					v_3:Play()
					var2_upvw.conTimer(v_3.Completed:Connect(function() -- Line 118
						--[[ Upvalues[5]:
							[1]: i_3_upvr (readonly)
							[2]: var2_upvw (copied, read and write)
							[3]: Ground_Kick_upvr (copied, readonly)
							[4]: Folder_upvr (copied, readonly)
							[5]: v_4_upvr (readonly)
						]]
						local Position_2 = i_3_upvr.Position
						var2_upvw.crater(1, Position_2, 5, 1.4)
						var2_upvw.CreateDebris(Position_2, 20, 0.7, 0.7, 0.08)
						local clone_4 = Ground_Kick_upvr.StompVfx:Clone()
						clone_4.Parent = Folder_upvr
						clone_4.CFrame = CFrame.new(i_3_upvr.Position) * CFrame.Angles(math.rad(i_3_upvr.Instance.Rotation.X), math.rad(i_3_upvr.Instance.Rotation.Y), math.rad(i_3_upvr.Instance.Rotation.Z))
						var2_upvw.EmitAllDescendants(clone_4)
						clone_4.rocks:Play()
						clone_4.Impact:Play()
						clone_4.Impact.Volume = 0.3
						var2_upvw.applyStatus(v_4_upvr, "Ragdoll", 2)
						var2_upvw.applyDamage(v_4_upvr, 10)
					end), module_upvr.Cooldown)
				else
					v_3 = TweenService_upvr
					local _ = {
						CFrame = CFrame.new(v_4_upvr.HumanoidRootPart.Position + Vector3.new(0, -35, 0)) * v_4_upvr.HumanoidRootPart.CFrame - v_4_upvr.HumanoidRootPart.CFrame.p;
					}
					v_3 = v_3:Create(v_4_upvr.HumanoidRootPart, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), _):Play
					v_3()
				end
			end
		end
		-- KONSTANTERROR: [206] 153. Error Block 34 end (CF ANALYSIS FAILED)
	end), module_upvr.Cooldown)
	task.wait()
	local clone_3 = Ground_Kick_upvr.lift:Clone()
	clone_3.Parent = HumanoidRootPart_upvr
	clone_3:Play()
	game.Debris:AddItem(clone_3, 1)
end
return module_upvr
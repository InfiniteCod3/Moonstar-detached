-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:08
-- Luau version 6, Types version 3
-- Time taken: 0.013985 seconds

local module_upvr = {
	Cooldown = 18;
	GlobalCD = 0.5;
}
local var2_upvw
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 12
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
	local HumanoidRootPart_2_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Mark_upvr = ReplicatedStorage_upvr.Skills.Nebula.Ultimate.Mark
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Mark_upvr.Animation)
	any_LoadAnimation_result1:Play()
	var2_upvw.applyStatus(arg1, "GlobalCD", 2)
	var2_upvw.applyStatus(arg1, "Slowed", 2)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 33
		--[[ Upvalues[3]:
			[1]: Mark_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: HumanoidRootPart_2_upvr (readonly)
		]]
		for _, v in Mark_upvr:GetChildren() do
			if v:IsA("Sound") and v.Name == arg1_2 then
				var2_upvw.applySound(v, HumanoidRootPart_2_upvr)
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Charge"):Connect(function() -- Line 41
		--[[ Upvalues[4]:
			[1]: var2_upvw (copied, read and write)
			[2]: Mark_upvr (readonly)
			[3]: HumanoidRootPart_2_upvr (readonly)
			[4]: arg1 (readonly)
		]]
		var2_upvw.applyVFX(Mark_upvr.VFX.Charge, HumanoidRootPart_2_upvr, 5)
		var2_upvw.applySound(Mark_upvr.Charge, HumanoidRootPart_2_upvr)
		var2_upvw.camShake(arg1, "SmallBump")
		var2_upvw.changeFov(arg1, 69, 0, 1)
		var2_upvw.Blur(arg1, 5, 1)
	end), module_upvr.Cooldown)
	var2_upvw.camShake(arg1, "SmallBump")
	local var16_upvw
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Snap"):Connect(function() -- Line 52
		--[[ Upvalues[4]:
			[1]: var16_upvw (read and write)
			[2]: var2_upvw (copied, read and write)
			[3]: Mark_upvr (readonly)
			[4]: arg1 (readonly)
		]]
		var16_upvw = var2_upvw.applyVFX(Mark_upvr.VFX.ArmStar, arg1["Right Arm"], 2)
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Mark"):Connect(function() -- Line 56
		--[[ Upvalues[7]:
			[1]: var2_upvw (copied, read and write)
			[2]: var16_upvw (read and write)
			[3]: arg1 (readonly)
			[4]: Mark_upvr (readonly)
			[5]: HumanoidRootPart_2_upvr (readonly)
			[6]: TweenService_upvr (copied, readonly)
			[7]: Folder_upvr (readonly)
		]]
		task.wait()
		var2_upvw.applyDebris(var16_upvw, 0)
		var2_upvw.camShake(arg1, "Bump")
		var2_upvw.changeFov(arg1, 90, 0, 2)
		var2_upvw.Blur(arg1, 25, 1)
		var2_upvw.applySound(Mark_upvr.Explode, HumanoidRootPart_2_upvr)
		var2_upvw.applyVFX(Mark_upvr.VFX.Mark, HumanoidRootPart_2_upvr, 5)
		local function TargetHit_upvr(arg1_3, arg2_2) -- Line 69, Named "TargetHit"
			--[[ Upvalues[5]:
				[1]: var2_upvw (copied, read and write)
				[2]: HumanoidRootPart_2_upvr (copied, readonly)
				[3]: TweenService_upvr (copied, readonly)
				[4]: Mark_upvr (copied, readonly)
				[5]: arg1 (copied, readonly)
			]]
			for _, v_2 in arg1_3:GetDescendants() do
				if v_2:IsA("BodyVelocity") then
					v_2:Destroy()
				end
			end
			var2_upvw.unragdoll(arg1_3)
			task.wait()
			local HumanoidRootPart = arg1_3:FindFirstChild("HumanoidRootPart")
			var2_upvw.applyDamage(arg1_3, 10, false, true)
			local BodyVelocity = Instance.new("BodyVelocity", arg1_3.Head)
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = Vector3.new(0, 0, 0)
			var2_upvw.applyDebris(BodyVelocity, 4)
			var2_upvw.applyStatus(arg1_3, "Stunned", 4)
			var2_upvw.applyStatus(arg1_3, "AutoRotate", 4)
			HumanoidRootPart.CFrame = CFrame.lookAt(Vector3.new(HumanoidRootPart.Position.X, HumanoidRootPart_2_upvr.Position.Y, HumanoidRootPart.Position.Z), HumanoidRootPart_2_upvr.Position)
			local var37 = HumanoidRootPart.CFrame + arg2_2.CFrame.LookVector * 50
			local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart.Position, arg2_2.CFrame.LookVector * 50, var2_upvw.raycastParams)
			if workspace_Raycast_result1 then
				var37 = CFrame.new(workspace_Raycast_result1.Position) * HumanoidRootPart.CFrame - HumanoidRootPart.CFrame.p
			end
			local any_Create_result1 = TweenService_upvr:Create(HumanoidRootPart, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				CFrame = var37;
			})
			any_Create_result1:Play()
			local any_applySound_result1 = var2_upvw.applySound(Mark_upvr.Raise, HumanoidRootPart)
			any_applySound_result1.PlaybackSpeed += math.random(-1, 1) * 0.1
			local clone = Mark_upvr.VFX.Star:Clone()
			clone.Parent = HumanoidRootPart
			var2_upvw.applyDebris(clone, 4)
			task.wait(1 + math.random(0, 5) * 0.1)
			var2_upvw.applyVFX(Mark_upvr.VFX.Shine, HumanoidRootPart, 5)
			var2_upvw.applySound(Mark_upvr.Star, HumanoidRootPart)
			var2_upvw.camShake(arg1, "SmallBump")
			task.wait(1)
			any_Create_result1:Cancel()
			var2_upvw.camShake(arg1, "Bump")
			var2_upvw.changeFov(arg1, 90, 0, 0.5)
			var2_upvw.Blur(arg1, 5, 1)
			var2_upvw.applyDebris(clone, 0)
			var2_upvw.applyDebris(BodyVelocity, 0)
			var2_upvw.applyVFX(Mark_upvr.VFX.Explode, HumanoidRootPart)
			for _, v_3 in Mark_upvr:GetChildren() do
				if v_3.Name == "Explosion3" then
					var2_upvw.applySound(v_3, HumanoidRootPart)
				end
			end
			var2_upvw.applyDamage(arg1_3, 20)
			var2_upvw.Knockback(arg1_3, HumanoidRootPart.Position, 10, 60)
			var2_upvw.applyStatus(arg1_3, "Ragdoll", 3)
		end
		local tbl = {}
		for _ = 1, 10 do
			local clone_upvr = Mark_upvr.MarkRing:Clone()
			clone_upvr.Parent = Folder_upvr
			clone_upvr.CFrame = HumanoidRootPart_2_upvr.CFrame + HumanoidRootPart_2_upvr.CFrame.LookVector * 20
			var2_upvw.applyDebris(clone_upvr, 5)
			var2_upvw.EmitAllDescendants(clone_upvr)
			TweenService_upvr:Create(clone_upvr.RingMesh, TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Transparency = 1;
				Size = Vector3.new(100, 2, 100);
			}):Play()
			for _, v_4 in Mark_upvr:GetChildren() do
				if v_4.Name == "Explosion2" then
					var2_upvw.applySound(v_4, clone_upvr)
				end
			end
			for _, v_5_upvr in var2_upvw.findEnemiesPart(clone_upvr.Hitbox, true), nil do
				if not var2_upvw.CheckBlock(v_5_upvr) and not table.find(tbl, v_5_upvr) then
					table.insert(tbl, v_5_upvr)
					task.spawn(function() -- Line 163
						--[[ Upvalues[3]:
							[1]: TargetHit_upvr (readonly)
							[2]: v_5_upvr (readonly)
							[3]: clone_upvr (readonly)
						]]
						TargetHit_upvr(v_5_upvr, clone_upvr)
					end)
				end
			end
			task.wait(0.2)
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 174
		--[[ Upvalues[2]:
			[1]: var2_upvw (copied, read and write)
			[2]: var16_upvw (read and write)
		]]
		var2_upvw.applyDebris(var16_upvw, 0)
	end), module_upvr.Cooldown)
end
return module_upvr
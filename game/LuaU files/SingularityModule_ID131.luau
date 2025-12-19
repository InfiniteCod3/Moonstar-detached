-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:17:12
-- Luau version 6, Types version 3
-- Time taken: 0.026378 seconds

local module_upvr = {}
local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
module_upvr.Cooldown = 17
module_upvr.GlobalCD = 0.5
local var3_upvw
local TweenService_upvr = game:GetService("TweenService")
function module_upvr.Script(arg1, arg2) -- Line 15
	--[[ Upvalues[4]:
		[1]: var3_upvw (read and write)
		[2]: module_upvr (readonly)
		[3]: ReplicatedStorage_upvr (readonly)
		[4]: TweenService_upvr (readonly)
	]]
	var3_upvw = require(arg1.ServerScript.Skills)
	local Folder_upvr = Instance.new("Folder", workspace.WorldInfo.Thrown)
	Folder_upvr.Name = arg1.Name
	game.Debris:AddItem(Folder_upvr, module_upvr.Cooldown)
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Singularity_upvr = ReplicatedStorage_upvr.Skills.Nebula.Ultimate.Singularity
	local BodyVelocity = Instance.new("BodyVelocity", arg1.Head)
	BodyVelocity.MaxForce = Vector3.new(0, 99999, 0)
	BodyVelocity.Velocity = Vector3.new(0, 30, 0)
	var3_upvw.applyDebris(BodyVelocity, 1.4)
	var3_upvw.camShake(arg1, "SmallBump")
	var3_upvw.changeFov(arg1, 85, 0.5)
	var3_upvw.Blur(arg1, 5, 1)
	TweenService_upvr:Create(BodyVelocity, TweenInfo.new(0.6), {
		Velocity = Vector3.new(0, 0, 0);
	}):Play()
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid"):LoadAnimation(Singularity_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(0.75)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 44
		--[[ Upvalues[3]:
			[1]: Singularity_upvr (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: HumanoidRootPart_upvr (readonly)
		]]
		print(arg1_2)
		for _, v in Singularity_upvr:GetChildren() do
			if v:IsA("Sound") and v.Name == arg1_2 then
				var3_upvw.applySound(v, HumanoidRootPart_upvr)
			end
		end
	end), module_upvr.Cooldown)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Charge"):Connect(function() -- Line 53
		--[[ Upvalues[4]:
			[1]: var3_upvw (copied, read and write)
			[2]: Singularity_upvr (readonly)
			[3]: HumanoidRootPart_upvr (readonly)
			[4]: arg1 (readonly)
		]]
		var3_upvw.applyVFX(Singularity_upvr.VFX.Charge, HumanoidRootPart_upvr, 5)
		var3_upvw.applySound(Singularity_upvr.Charge, HumanoidRootPart_upvr)
		var3_upvw.camShake(arg1, "SmallBump")
		var3_upvw.changeFov(arg1, 69, 0, 1)
		var3_upvw.Blur(arg1, 5, 1)
	end), module_upvr.Cooldown)
	local var18_upvr = arg1:FindFirstChild("NebulaHighlight") or false
	if var18_upvr then
		TweenService_upvr:Create(var18_upvr, TweenInfo.new(0.25), {
			OutlineTransparency = 1;
			FillTransparency = 1;
		}):Play()
		task.delay(3, function() -- Line 64
			--[[ Upvalues[2]:
				[1]: var18_upvr (readonly)
				[2]: TweenService_upvr (copied, readonly)
			]]
			if not var18_upvr then
			else
				TweenService_upvr:Create(var18_upvr, TweenInfo.new(2), {
					OutlineTransparency = 0;
					FillTransparency = 0;
				}):Play()
			end
		end)
	end
	local clone_upvr_2 = Singularity_upvr.SingularityHold:Clone()
	clone_upvr_2.Parent = arg1
	clone_upvr_2.weld.Part0 = arg1["Right Arm"]
	clone_upvr_2.weld.Part1 = clone_upvr_2
	local var23_upvw = false
	var3_upvw.conTimer(any_LoadAnimation_result1.Stopped:Connect(function() -- Line 76
		--[[ Upvalues[3]:
			[1]: var23_upvw (read and write)
			[2]: var3_upvw (copied, read and write)
			[3]: clone_upvr_2 (readonly)
		]]
		if var23_upvw then
		else
			var3_upvw.applyDebris(clone_upvr_2, 0)
		end
	end), module_upvr.Cooldown)
	var3_upvw.applyStatus(arg1, "Slowed", 2)
	var3_upvw.applyStatus(arg1, "GlobalCD", 2)
	var3_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("Singularity"):Connect(function() -- Line 84
		--[[ Upvalues[9]:
			[1]: HumanoidRootPart_upvr (readonly)
			[2]: var3_upvw (copied, read and write)
			[3]: var23_upvw (read and write)
			[4]: arg1 (readonly)
			[5]: clone_upvr_2 (readonly)
			[6]: Folder_upvr (readonly)
			[7]: TweenService_upvr (copied, readonly)
			[8]: Singularity_upvr (readonly)
			[9]: module_upvr (copied, readonly)
		]]
		local var26 = HumanoidRootPart_upvr.Position + HumanoidRootPart_upvr.CFrame.LookVector * 100 + Vector3.new(0, -20, 0)
		local workspace_Raycast_result1 = workspace:Raycast(HumanoidRootPart_upvr.Position, HumanoidRootPart_upvr.CFrame.LookVector * 100 + Vector3.new(0, -20, 0), var3_upvw.raycastParams)
		if workspace_Raycast_result1 then
			var26 = workspace_Raycast_result1.Position
		end
		var23_upvw = true
		HumanoidRootPart_upvr.CFrame = CFrame.lookAt(HumanoidRootPart_upvr.Position, var26)
		var3_upvw.camShake(arg1, "SmallBump")
		var3_upvw.changeFov(arg1, 75, 0.5)
		var3_upvw.Blur(arg1, 10, 1)
		clone_upvr_2.weld.Part0 = nil
		clone_upvr_2.Anchored = true
		clone_upvr_2.CFrame = HumanoidRootPart_upvr.CFrame + HumanoidRootPart_upvr.CFrame.LookVector * 4
		var3_upvw.applyDebris(clone_upvr_2, 10)
		local Model = Instance.new("Model", Folder_upvr)
		clone_upvr_2.Parent = Model
		var3_upvw.applyDebris(Model, 10)
		Model:ScaleTo(1.6)
		local any_Create_result1 = TweenService_upvr:Create(clone_upvr_2, TweenInfo.new(0.1 + (HumanoidRootPart_upvr.Position - var26).Magnitude * 0.004, Enum.EasingStyle.Linear), {
			CFrame = CFrame.new(var26) * clone_upvr_2.CFrame - clone_upvr_2.CFrame.p;
		})
		any_Create_result1:Play()
		var3_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 114
			--[[ Upvalues[6]:
				[1]: var3_upvw (copied, read and write)
				[2]: arg1 (copied, readonly)
				[3]: clone_upvr_2 (copied, readonly)
				[4]: Singularity_upvr (copied, readonly)
				[5]: Folder_upvr (copied, readonly)
				[6]: TweenService_upvr (copied, readonly)
			]]
			-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
			var3_upvw.camShake(arg1, "Bump")
			var3_upvw.changeFov(arg1, 90, 0.5)
			var3_upvw.Blur(arg1, 20, 1)
			var3_upvw.flashScreen(arg1, Color3.new(0, 0, 0), 1)
			var3_upvw.applyDebris(clone_upvr_2, 0)
			local clone_upvr = Singularity_upvr.Singularity:Clone()
			clone_upvr.Parent = Folder_upvr
			clone_upvr.CFrame = clone_upvr_2.CFrame
			for _, v_2 in Singularity_upvr:GetChildren() do
				if v_2.Name == "Explosion" and v_2:IsA("Sound") then
					var3_upvw.applySound(v_2, clone_upvr)
				end
			end
			TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true), {
				Size = Vector3.new(45, 45, 45);
			}):Play()
			TweenService_upvr:Create(clone_upvr.Black, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true), {
				Size = Vector3.new(43, 43, 43);
			}):Play()
			local var67_upvw = true
			task.spawn(function() -- Line 140
				--[[ Upvalues[5]:
					[1]: var67_upvw (read and write)
					[2]: clone_upvr (readonly)
					[3]: var3_upvw (copied, read and write)
					[4]: arg1 (copied, readonly)
					[5]: TweenService_upvr (copied, readonly)
				]]
				task.wait(0.2)
				while task.wait(0.1) and var67_upvw and clone_upvr.Parent do
					var3_upvw.camShake(arg1, "SmallBump")
					var3_upvw.changeFov(arg1, 75, 0.1)
					var3_upvw.Blur(arg1, 8, 0.1)
					TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true), {
						Size = Vector3.new(34, 34, 34);
					}):Play()
					TweenService_upvr:Create(clone_upvr.Black, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true), {
						Size = Vector3.new(32, 32, 32);
					}):Play()
				end
			end)
			for _ = 1, 25 do
				for _, v_3 in var3_upvw.findEnemiesMagnitude(clone_upvr.Position, 30, true), nil do
					var3_upvw.unragdoll(v_3)
					var3_upvw.applyDamage(v_3, 1)
					var3_upvw.applyStatus(v_3, "Stunned", 0.5)
					TweenService_upvr:Create(v_3.HumanoidRootPart, TweenInfo.new(0.5), {
						CFrame = clone_upvr.CFrame;
					}):Play()
				end
				task.wait(0.1)
			end
			var67_upvw = false
			for _, v_4 in clone_upvr:GetDescendants() do
				if v_4:IsA("ParticleEmitter") then
					v_4.Enabled = false
				end
			end
			TweenService_upvr:Create(clone_upvr, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0), {
				Size = Vector3.new(0, 0, 0);
			}):Play()
			TweenService_upvr:Create(clone_upvr.Black, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0), {
				Size = Vector3.new(0, 0, 0);
			}):Play()
		end), module_upvr.Cooldown)
	end), module_upvr.Cooldown)
end
return module_upvr
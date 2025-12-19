-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Decompiler will be improved VERY SOON!
-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2025-12-14 11:12:51
-- Luau version 6, Types version 3
-- Time taken: 0.007022 seconds

local module_upvr = {
	Cooldown = 22;
	GlobalCD = 0.75;
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
	local HumanoidRootPart_upvr = arg1:FindFirstChild("HumanoidRootPart")
	local Glowing_Hail_upvr = ReplicatedStorage_upvr.Skills["Basic Staff"]["Glowing Hail"]
	local any_LoadAnimation_result1 = arg1:FindFirstChild("Humanoid").Animator:LoadAnimation(Glowing_Hail_upvr.Animation)
	any_LoadAnimation_result1:Play()
	any_LoadAnimation_result1:AdjustSpeed(1)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("snap"):Connect(function() -- Line 32
		--[[ Upvalues[7]:
			[1]: HumanoidRootPart_upvr (readonly)
			[2]: var2_upvw (copied, read and write)
			[3]: Glowing_Hail_upvr (readonly)
			[4]: Folder_upvr (readonly)
			[5]: TweenService_upvr (copied, readonly)
			[6]: arg1 (readonly)
			[7]: module_upvr (copied, readonly)
		]]
		local CFrame = HumanoidRootPart_upvr.CFrame
		local workspace_Raycast_result1_upvr = workspace:Raycast(HumanoidRootPart_upvr.Position + CFrame.LookVector * 18 + Vector3.new(0, 5.5, 0), Vector3.new(0, -100, 0), var2_upvw.raycastParams)
		if workspace_Raycast_result1_upvr then
			for i = 1, 5 do
				local clone_2_upvr = Glowing_Hail_upvr.Ball:Clone()
				clone_2_upvr.Parent = Folder_upvr
				clone_2_upvr.CFrame = CFrame + CFrame.LookVector * 18 + Vector3.new(math.random(-4, 4) * 2, 9 + i * 2, math.random(-4, 4) * 2)
				for _, v in clone_2_upvr:GetChildren() do
					if v:IsA("Sound") then
						v.PlaybackSpeed += math.random(-2, 2) * 0.1
						v:Play()
					end
				end
				local any_Create_result1 = TweenService_upvr:Create(clone_2_upvr, TweenInfo.new(0.1 + (clone_2_upvr.Position - workspace_Raycast_result1_upvr.Position).Magnitude * 0.035, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
					CFrame = CFrame.new(workspace_Raycast_result1_upvr.Position) * clone_2_upvr.CFrame - clone_2_upvr.CFrame.p;
				})
				any_Create_result1:Play()
				var2_upvw.conTimer(any_Create_result1.Completed:Connect(function() -- Line 54
					--[[ Upvalues[6]:
						[1]: var2_upvw (copied, read and write)
						[2]: arg1 (copied, readonly)
						[3]: clone_2_upvr (readonly)
						[4]: Glowing_Hail_upvr (copied, readonly)
						[5]: Folder_upvr (copied, readonly)
						[6]: workspace_Raycast_result1_upvr (readonly)
					]]
					var2_upvw.camShake(arg1, "SmallBump")
					var2_upvw.changeFov(arg1, 50, 0.01, 0.5)
					var2_upvw.flashScreen(arg1, Color3.fromRGB(255, 235, 123), 0.5)
					var2_upvw.applyDebris(clone_2_upvr, 0)
					local clone = Glowing_Hail_upvr.Explosion:Clone()
					clone.Parent = Folder_upvr
					clone.CFrame = CFrame.new(workspace_Raycast_result1_upvr.Position) * clone.CFrame - clone.CFrame.p
					var2_upvw.EmitAllDescendants(clone)
					var2_upvw.applyDebris(clone, 6)
					for _, v_2 in clone:GetChildren() do
						if v_2:IsA("Sound") then
							v_2.PlaybackSpeed += math.random(-2, 2) * 0.1
							v_2:Play()
						end
					end
					for _, v_3 in var2_upvw.findEnemiesMagnitude(workspace_Raycast_result1_upvr.Position, 16, true), nil do
						var2_upvw.applyDamage(v_3, 5)
						var2_upvw.applyStatus(v_3, "Ragdoll", 1)
						var2_upvw.Knockback(v_3, workspace_Raycast_result1_upvr.Position, 8, 10)
						var2_upvw.camShake(v_3, "Bump")
						var2_upvw.changeFov(v_3, 50, 0.01, 0.5)
						var2_upvw.flashScreen(v_3, Color3.fromRGB(255, 235, 123), 0.5)
					end
				end), module_upvr.Cooldown)
				task.wait(0.1)
			end
		end
	end), module_upvr.Cooldown)
	var2_upvw.conTimer(any_LoadAnimation_result1:GetMarkerReachedSignal("sfx"):Connect(function(arg1_2) -- Line 90
		--[[ Upvalues[3]:
			[1]: Glowing_Hail_upvr (readonly)
			[2]: HumanoidRootPart_upvr (readonly)
			[3]: var2_upvw (copied, read and write)
		]]
		for _, v_4 in Glowing_Hail_upvr:GetChildren() do
			if v_4.Name == arg1_2 and v_4:IsA("Sound") then
				local clone_3 = v_4:Clone()
				clone_3.PlaybackSpeed += math.random(-1, 1) * 0.1
				clone_3.Parent = HumanoidRootPart_upvr
				clone_3:Play()
				var2_upvw.applyDebris(clone_3, 8)
			end
		end
	end), module_upvr.Cooldown)
end
return module_upvr